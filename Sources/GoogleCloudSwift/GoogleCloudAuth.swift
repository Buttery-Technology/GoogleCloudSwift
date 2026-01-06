import Foundation
import AsyncHTTPClient
import NIOCore
import NIOFoundationCompat
import Crypto
import _CryptoExtras

// MARK: - Service Account Credentials

/// Represents a Google Cloud service account JSON key file.
public struct GoogleCloudServiceAccountCredentials: Codable, Sendable {
    public let type: String
    public let projectId: String
    public let privateKeyId: String
    public let privateKey: String
    public let clientEmail: String
    public let clientId: String
    public let authUri: String
    public let tokenUri: String
    public let authProviderX509CertUrl: String
    public let clientX509CertUrl: String
    public let universeDomain: String?

    enum CodingKeys: String, CodingKey {
        case type
        case projectId = "project_id"
        case privateKeyId = "private_key_id"
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case clientId = "client_id"
        case authUri = "auth_uri"
        case tokenUri = "token_uri"
        case authProviderX509CertUrl = "auth_provider_x509_cert_url"
        case clientX509CertUrl = "client_x509_cert_url"
        case universeDomain = "universe_domain"
    }

    /// Load credentials from a JSON file path.
    public static func load(from path: String) throws -> GoogleCloudServiceAccountCredentials {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(GoogleCloudServiceAccountCredentials.self, from: data)
    }

    /// Load credentials from JSON data.
    public static func load(from data: Data) throws -> GoogleCloudServiceAccountCredentials {
        let decoder = JSONDecoder()
        return try decoder.decode(GoogleCloudServiceAccountCredentials.self, from: data)
    }

    /// Load credentials from a JSON string.
    public static func loadFromString(_ jsonString: String) throws -> GoogleCloudServiceAccountCredentials {
        guard let data = jsonString.data(using: .utf8) else {
            throw GoogleCloudAuthError.invalidCredentials("Invalid JSON string encoding")
        }
        return try load(from: data)
    }
}

// MARK: - Auth Errors

/// Errors that can occur during Google Cloud authentication.
public enum GoogleCloudAuthError: Error, Sendable {
    case invalidCredentials(String)
    case invalidPrivateKey(String)
    case tokenRequestFailed(String)
    case tokenParsingFailed(String)
    case httpError(Int, String)
    case networkError(String)
}

extension GoogleCloudAuthError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidCredentials(let message):
            return "Invalid credentials: \(message)"
        case .invalidPrivateKey(let message):
            return "Invalid private key: \(message)"
        case .tokenRequestFailed(let message):
            return "Token request failed: \(message)"
        case .tokenParsingFailed(let message):
            return "Token parsing failed: \(message)"
        case .httpError(let code, let message):
            return "HTTP error \(code): \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Access Token

/// Represents a Google Cloud OAuth2 access token.
public struct GoogleCloudAccessToken: Sendable {
    public let token: String
    public let tokenType: String
    public let expiresAt: Date

    /// Check if the token is expired or about to expire (within 60 seconds).
    public var isExpired: Bool {
        Date().addingTimeInterval(60) >= expiresAt
    }
}

// MARK: - Token Response

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - JWT Components

struct JWTHeader: Codable {
    let alg: String
    let typ: String
    let kid: String?

    static func rs256(keyId: String? = nil) -> JWTHeader {
        JWTHeader(alg: "RS256", typ: "JWT", kid: keyId)
    }
}

struct JWTClaims: Codable {
    let iss: String
    let scope: String
    let aud: String
    let iat: Int
    let exp: Int
}

// MARK: - Google Cloud Auth Client

/// A client for authenticating with Google Cloud APIs using service account credentials.
public actor GoogleCloudAuthClient {
    private let credentials: GoogleCloudServiceAccountCredentials
    private let httpClient: HTTPClient
    private let scopes: [String]
    private var cachedToken: GoogleCloudAccessToken?

    /// Default OAuth2 scopes for Google Cloud APIs.
    public static let defaultScopes = [
        "https://www.googleapis.com/auth/cloud-platform"
    ]

    /// Compute Engine specific scopes.
    public static let computeScopes = [
        "https://www.googleapis.com/auth/compute"
    ]

    /// Storage specific scopes.
    public static let storageScopes = [
        "https://www.googleapis.com/auth/devstorage.full_control"
    ]

    /// Initialize the auth client with service account credentials.
    /// - Parameters:
    ///   - credentials: The service account credentials.
    ///   - httpClient: The HTTP client to use for token requests.
    ///   - scopes: The OAuth2 scopes to request. Defaults to cloud-platform scope.
    public init(
        credentials: GoogleCloudServiceAccountCredentials,
        httpClient: HTTPClient,
        scopes: [String] = defaultScopes
    ) {
        self.credentials = credentials
        self.httpClient = httpClient
        self.scopes = scopes
    }

    /// Initialize the auth client by loading credentials from a file path.
    /// - Parameters:
    ///   - credentialsPath: Path to the service account JSON key file.
    ///   - httpClient: The HTTP client to use for token requests.
    ///   - scopes: The OAuth2 scopes to request.
    public init(
        credentialsPath: String,
        httpClient: HTTPClient,
        scopes: [String] = defaultScopes
    ) throws {
        self.credentials = try GoogleCloudServiceAccountCredentials.load(from: credentialsPath)
        self.httpClient = httpClient
        self.scopes = scopes
    }

    /// Get a valid access token, refreshing if necessary.
    public func getAccessToken() async throws -> GoogleCloudAccessToken {
        if let token = cachedToken, !token.isExpired {
            return token
        }

        let token = try await fetchNewToken()
        cachedToken = token
        return token
    }

    /// Force refresh the access token.
    public func refreshToken() async throws -> GoogleCloudAccessToken {
        let token = try await fetchNewToken()
        cachedToken = token
        return token
    }

    /// Get the project ID from the credentials.
    public var projectId: String {
        credentials.projectId
    }

    /// Get the service account email from the credentials.
    public var serviceAccountEmail: String {
        credentials.clientEmail
    }

    // MARK: - Private Methods

    private func fetchNewToken() async throws -> GoogleCloudAccessToken {
        let jwt = try createSignedJWT()
        return try await exchangeJWTForToken(jwt)
    }

    private func createSignedJWT() throws -> String {
        let now = Int(Date().timeIntervalSince1970)

        let header = JWTHeader.rs256(keyId: credentials.privateKeyId)
        let claims = JWTClaims(
            iss: credentials.clientEmail,
            scope: scopes.joined(separator: " "),
            aud: credentials.tokenUri,
            iat: now,
            exp: now + 3600 // 1 hour
        )

        let encoder = JSONEncoder()
        let headerData = try encoder.encode(header)
        let claimsData = try encoder.encode(claims)

        let headerBase64 = base64URLEncode(headerData)
        let claimsBase64 = base64URLEncode(claimsData)

        let signatureInput = "\(headerBase64).\(claimsBase64)"

        let signature = try signRS256(signatureInput, with: credentials.privateKey)
        let signatureBase64 = base64URLEncode(signature)

        return "\(signatureInput).\(signatureBase64)"
    }

    private func signRS256(_ input: String, with pemKey: String) throws -> Data {
        let privateKey = try parsePrivateKey(pemKey)

        guard let inputData = input.data(using: .utf8) else {
            throw GoogleCloudAuthError.invalidCredentials("Failed to encode JWT input")
        }

        let signature = try privateKey.signature(for: inputData, padding: .insecurePKCS1v1_5)
        return Data(signature.rawRepresentation)
    }

    private func parsePrivateKey(_ pemString: String) throws -> _RSA.Signing.PrivateKey {
        // Remove PEM headers and decode
        let keyString = pemString
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")

        guard let keyData = Data(base64Encoded: keyString) else {
            throw GoogleCloudAuthError.invalidPrivateKey("Failed to decode base64 private key")
        }

        do {
            // Try PKCS#8 format first (what Google uses)
            return try _RSA.Signing.PrivateKey(derRepresentation: keyData)
        } catch {
            throw GoogleCloudAuthError.invalidPrivateKey("Failed to parse RSA private key: \(error)")
        }
    }

    private func exchangeJWTForToken(_ jwt: String) async throws -> GoogleCloudAccessToken {
        var request = HTTPClientRequest(url: credentials.tokenUri)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")

        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
        request.body = .bytes(ByteBuffer(string: body))

        let response: HTTPClientResponse
        do {
            response = try await httpClient.execute(request, timeout: .seconds(30))
        } catch {
            throw GoogleCloudAuthError.networkError("Failed to connect to token endpoint: \(error)")
        }

        let responseBody = try await response.body.collect(upTo: 1024 * 1024) // 1MB max
        let responseData = Data(buffer: responseBody)

        guard response.status == .ok else {
            let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw GoogleCloudAuthError.httpError(Int(response.status.code), errorMessage)
        }

        let decoder = JSONDecoder()
        let tokenResponse: TokenResponse
        do {
            tokenResponse = try decoder.decode(TokenResponse.self, from: responseData)
        } catch {
            throw GoogleCloudAuthError.tokenParsingFailed("Failed to parse token response: \(error)")
        }

        return GoogleCloudAccessToken(
            token: tokenResponse.accessToken,
            tokenType: tokenResponse.tokenType,
            expiresAt: Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        )
    }

    private func base64URLEncode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
