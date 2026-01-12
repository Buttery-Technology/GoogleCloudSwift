//
//  GoogleCloudSecurity.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Crypto
import _CryptoExtras
import AsyncHTTPClient
import NIOCore
import NIOFoundationCompat

// MARK: - Request Coalescing

/// A utility for coalescing multiple concurrent requests into a single request.
///
/// When multiple concurrent callers need the same resource, this ensures only one
/// actual fetch operation is performed, and all callers receive the same result.
///
/// ## Example Usage
/// ```swift
/// let coalescer = RequestCoalescer<String, AccessToken>()
///
/// // Multiple concurrent callers will share the same fetch
/// let token = try await coalescer.coalesce(key: "token") {
///     try await fetchNewToken()
/// }
/// ```
public actor RequestCoalescer<Key: Hashable & Sendable, Value: Sendable>: Sendable {
    private var inFlightRequests: [Key: Task<Value, Error>] = [:]

    public init() {}

    /// Execute an operation, coalescing with any in-flight request for the same key.
    /// - Parameters:
    ///   - key: A unique key identifying the request.
    ///   - operation: The async operation to perform.
    /// - Returns: The result of the operation.
    public func coalesce(
        key: Key,
        operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        // Check if there's already an in-flight request
        if let existingTask = inFlightRequests[key] {
            return try await existingTask.value
        }

        // Create a new task for this request
        let task = Task<Value, Error> {
            try await operation()
        }

        inFlightRequests[key] = task

        do {
            let result = try await task.value
            inFlightRequests.removeValue(forKey: key)
            return result
        } catch {
            inFlightRequests.removeValue(forKey: key)
            throw error
        }
    }

    /// Check if there's an in-flight request for a key.
    /// - Parameter key: The request key.
    /// - Returns: `true` if a request is in progress.
    public func hasInFlightRequest(for key: Key) -> Bool {
        inFlightRequests[key] != nil
    }

    /// Cancel all in-flight requests.
    public func cancelAll() {
        for task in inFlightRequests.values {
            task.cancel()
        }
        inFlightRequests.removeAll()
    }

    /// Cancel a specific in-flight request.
    /// - Parameter key: The request key.
    public func cancel(key: Key) {
        inFlightRequests[key]?.cancel()
        inFlightRequests.removeValue(forKey: key)
    }
}

// MARK: - Token Refresh Coalescer

/// A specialized coalescer for OAuth token refresh operations.
///
/// This ensures that when multiple requests detect an expired token simultaneously,
/// only one token refresh is performed.
///
/// ## Example Usage
/// ```swift
/// let coalescer = TokenRefreshCoalescer()
///
/// let token = try await coalescer.refreshToken(scope: "cloud-platform") {
///     try await authClient.fetchNewToken()
/// }
/// ```
public actor TokenRefreshCoalescer: Sendable {
    private var refreshTasks: [String: Task<GoogleCloudAccessToken, Error>] = [:]
    private var lastRefreshTimes: [String: Date] = [:]

    /// Minimum time between refresh attempts in seconds.
    public let minRefreshInterval: TimeInterval

    public init(minRefreshInterval: TimeInterval = 1.0) {
        self.minRefreshInterval = minRefreshInterval
    }

    /// Refresh a token, coalescing with any in-flight refresh for the same scope.
    /// - Parameters:
    ///   - scope: The OAuth scope being refreshed.
    ///   - refresh: The async operation to refresh the token.
    /// - Returns: The refreshed token.
    public func refreshToken(
        scope: String,
        refresh: @escaping @Sendable () async throws -> GoogleCloudAccessToken
    ) async throws -> GoogleCloudAccessToken {
        // Check if we recently refreshed
        if let lastRefresh = lastRefreshTimes[scope] {
            let elapsed = Date().timeIntervalSince(lastRefresh)
            if elapsed < minRefreshInterval {
                // Wait a bit to avoid hammering the token endpoint
                try await Task.sleep(nanoseconds: UInt64((minRefreshInterval - elapsed) * 1_000_000_000))
            }
        }

        // Check for in-flight refresh
        if let existingTask = refreshTasks[scope] {
            return try await existingTask.value
        }

        // Create new refresh task
        let task = Task<GoogleCloudAccessToken, Error> {
            try await refresh()
        }

        refreshTasks[scope] = task

        do {
            let token = try await task.value
            refreshTasks.removeValue(forKey: scope)
            lastRefreshTimes[scope] = Date()
            return token
        } catch {
            refreshTasks.removeValue(forKey: scope)
            throw error
        }
    }

    /// Check if a refresh is in progress for a scope.
    /// - Parameter scope: The OAuth scope.
    /// - Returns: `true` if a refresh is in progress.
    public func isRefreshing(scope: String) -> Bool {
        refreshTasks[scope] != nil
    }
}

// MARK: - Secure String

/// A string type that attempts to minimize the time sensitive data exists in memory.
///
/// This type provides:
/// - Automatic zeroing of memory when deallocated
/// - No string interning (uses raw bytes)
/// - Explicit memory clearing
///
/// ## Important Security Notes
/// - Swift's memory management doesn't guarantee immediate deallocation
/// - This provides defense in depth, not absolute security
/// - For highest security, consider using Apple's Keychain
///
/// ## Example Usage
/// ```swift
/// let privateKey = SecureString(string: pemKeyContent)
/// defer { privateKey.clear() }
///
/// // Use the key
/// let signature = try sign(data: input, key: privateKey.utf8String)
/// ```
public final class SecureString: @unchecked Sendable {
    private var bytes: ContiguousArray<UInt8>
    private let lock = NSLock()

    /// Create a secure string from a regular string.
    /// - Parameter string: The string to secure.
    public init(string: String) {
        self.bytes = ContiguousArray(string.utf8)
    }

    /// Create a secure string from raw bytes.
    /// - Parameter bytes: The bytes to secure.
    public init(bytes: [UInt8]) {
        self.bytes = ContiguousArray(bytes)
    }

    /// Create a secure string from data.
    /// - Parameter data: The data to secure.
    public init(data: Data) {
        self.bytes = ContiguousArray(data)
    }

    deinit {
        clear()
    }

    /// Get the string value.
    /// - Note: This creates a new String which may be interned. Prefer `withUTF8String` when possible.
    public var utf8String: String {
        lock.lock()
        defer { lock.unlock() }
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Get the data representation.
    public var data: Data {
        lock.lock()
        defer { lock.unlock() }
        return Data(bytes)
    }

    /// Get the raw bytes.
    public var rawBytes: [UInt8] {
        lock.lock()
        defer { lock.unlock() }
        return Array(bytes)
    }

    /// The length of the secure string in bytes.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return bytes.count
    }

    /// Whether the string has been cleared.
    public var isCleared: Bool {
        lock.lock()
        defer { lock.unlock() }
        return bytes.isEmpty || bytes.allSatisfy { $0 == 0 }
    }

    /// Execute a closure with the UTF-8 string value.
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    public func withUTF8String<T>(_ body: (String) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(String(decoding: bytes, as: UTF8.self))
    }

    /// Execute a closure with the raw bytes.
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    public func withBytes<T>(_ body: (ContiguousArray<UInt8>) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(bytes)
    }

    /// Zero out the memory and clear the bytes.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        // Overwrite with zeros
        for i in bytes.indices {
            bytes[i] = 0
        }

        // Then clear
        bytes.removeAll()
    }
}

// MARK: - Secure Credentials

/// A secure wrapper for Google Cloud service account credentials.
///
/// This class stores the private key securely and provides methods to
/// access credentials while minimizing exposure of sensitive data.
///
/// ## Example Usage
/// ```swift
/// let credentials = try SecureServiceAccountCredentials.load(from: path)
/// defer { credentials.clear() }
///
/// // Sign data without exposing the raw key
/// let signature = try credentials.sign(data: jwtInput)
/// ```
public final class SecureServiceAccountCredentials: @unchecked Sendable {
    /// The type field from the credentials file.
    public let type: String

    /// The project ID.
    public let projectId: String

    /// The private key ID.
    public let privateKeyId: String

    /// The client email (service account email).
    public let clientEmail: String

    /// The client ID.
    public let clientId: String

    /// The auth URI.
    public let authUri: String

    /// The token URI.
    public let tokenUri: String

    /// The auth provider X509 cert URL.
    public let authProviderX509CertUrl: String

    /// The client X509 cert URL.
    public let clientX509CertUrl: String

    /// The universe domain.
    public let universeDomain: String?

    /// The securely stored private key.
    private let securePrivateKey: SecureString

    /// The parsed RSA private key (lazily loaded).
    private var _rsaPrivateKey: _RSA.Signing.PrivateKey?
    private let keyLock = NSLock()

    /// Create secure credentials from a standard credentials object.
    /// - Parameter credentials: The credentials to secure.
    public init(from credentials: GoogleCloudServiceAccountCredentials) {
        self.type = credentials.type
        self.projectId = credentials.projectId
        self.privateKeyId = credentials.privateKeyId
        self.clientEmail = credentials.clientEmail
        self.clientId = credentials.clientId
        self.authUri = credentials.authUri
        self.tokenUri = credentials.tokenUri
        self.authProviderX509CertUrl = credentials.authProviderX509CertUrl
        self.clientX509CertUrl = credentials.clientX509CertUrl
        self.universeDomain = credentials.universeDomain
        self.securePrivateKey = SecureString(string: credentials.privateKey)
    }

    deinit {
        clear()
    }

    /// Load secure credentials from a JSON file.
    /// - Parameter path: Path to the credentials file.
    /// - Returns: The secure credentials.
    public static func load(from path: String) throws -> SecureServiceAccountCredentials {
        let credentials = try GoogleCloudServiceAccountCredentials.load(from: path)
        return SecureServiceAccountCredentials(from: credentials)
    }

    /// Load secure credentials from JSON data.
    /// - Parameter data: The JSON data.
    /// - Returns: The secure credentials.
    public static func load(from data: Data) throws -> SecureServiceAccountCredentials {
        let credentials = try GoogleCloudServiceAccountCredentials.load(from: data)
        return SecureServiceAccountCredentials(from: credentials)
    }

    /// Sign data using the private key.
    /// - Parameter data: The data to sign.
    /// - Returns: The signature.
    public func sign(_ data: Data) throws -> Data {
        let key = try getOrCreateRSAKey()

        let signature = try key.signature(for: data, padding: .insecurePKCS1v1_5)
        return Data(signature.rawRepresentation)
    }

    /// Sign a string using the private key.
    /// - Parameter string: The string to sign.
    /// - Returns: The signature.
    public func sign(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw GoogleCloudAuthError.invalidCredentials("Failed to encode string to UTF-8")
        }
        return try sign(data)
    }

    /// Clear all sensitive data from memory.
    public func clear() {
        securePrivateKey.clear()

        keyLock.lock()
        _rsaPrivateKey = nil
        keyLock.unlock()
    }

    // MARK: - Private Methods

    private func getOrCreateRSAKey() throws -> _RSA.Signing.PrivateKey {
        keyLock.lock()
        defer { keyLock.unlock() }

        if let existing = _rsaPrivateKey {
            return existing
        }

        let key = try parsePrivateKey()
        _rsaPrivateKey = key
        return key
    }

    private func parsePrivateKey() throws -> _RSA.Signing.PrivateKey {
        return try securePrivateKey.withUTF8String { pemString in
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
                return try _RSA.Signing.PrivateKey(derRepresentation: keyData)
            } catch {
                throw GoogleCloudAuthError.invalidPrivateKey("Failed to parse RSA private key: \(error)")
            }
        }
    }
}

// MARK: - Secure Auth Client

/// A secure authentication client that uses secure credential storage and request coalescing.
///
/// This client provides:
/// - Secure storage of private keys with automatic zeroing
/// - Request coalescing to prevent duplicate token refreshes
/// - Key rotation support
///
/// ## Example Usage
/// ```swift
/// let authClient = try SecureGoogleCloudAuthClient(
///     credentialsPath: "path/to/credentials.json",
///     httpClient: httpClient
/// )
///
/// let token = try await authClient.getAccessToken()
/// ```
public actor SecureGoogleCloudAuthClient: Sendable {
    private let credentials: SecureServiceAccountCredentials
    private let httpClient: HTTPClient
    private let scopes: [String]
    private var cachedToken: GoogleCloudAccessToken?
    private let tokenCoalescer = TokenRefreshCoalescer()

    /// Initialize with secure credentials.
    /// - Parameters:
    ///   - credentials: The secure credentials.
    ///   - httpClient: The HTTP client for token requests.
    ///   - scopes: The OAuth scopes to request.
    public init(
        credentials: SecureServiceAccountCredentials,
        httpClient: HTTPClient,
        scopes: [String] = GoogleCloudAuthClient.defaultScopes
    ) {
        self.credentials = credentials
        self.httpClient = httpClient
        self.scopes = scopes
    }

    /// Initialize by loading credentials from a file.
    /// - Parameters:
    ///   - credentialsPath: Path to the credentials file.
    ///   - httpClient: The HTTP client for token requests.
    ///   - scopes: The OAuth scopes to request.
    public init(
        credentialsPath: String,
        httpClient: HTTPClient,
        scopes: [String] = GoogleCloudAuthClient.defaultScopes
    ) throws {
        self.credentials = try SecureServiceAccountCredentials.load(from: credentialsPath)
        self.httpClient = httpClient
        self.scopes = scopes
    }

    /// Get a valid access token, refreshing if necessary.
    /// - Returns: A valid access token.
    public func getAccessToken() async throws -> GoogleCloudAccessToken {
        if let token = cachedToken, !token.isExpired {
            return token
        }

        // Use coalescing to prevent duplicate refreshes
        let scopeKey = scopes.joined(separator: ",")
        let token = try await tokenCoalescer.refreshToken(scope: scopeKey) { [self] in
            try await fetchNewToken()
        }

        cachedToken = token
        return token
    }

    /// Force refresh the access token.
    /// - Returns: A new access token.
    public func refreshToken() async throws -> GoogleCloudAccessToken {
        let scopeKey = scopes.joined(separator: ",")
        let token = try await tokenCoalescer.refreshToken(scope: scopeKey) { [self] in
            try await fetchNewToken()
        }
        cachedToken = token
        return token
    }

    /// The project ID from the credentials.
    public var projectId: String {
        credentials.projectId
    }

    /// The service account email from the credentials.
    public var serviceAccountEmail: String {
        credentials.clientEmail
    }

    /// Clear sensitive data from memory.
    public func clearCredentials() {
        credentials.clear()
        cachedToken = nil
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
            exp: now + 3600
        )

        let encoder = JSONEncoder()
        let headerData = try encoder.encode(header)
        let claimsData = try encoder.encode(claims)

        let headerBase64 = base64URLEncode(headerData)
        let claimsBase64 = base64URLEncode(claimsData)

        let signatureInput = "\(headerBase64).\(claimsBase64)"

        guard let inputData = signatureInput.data(using: .utf8) else {
            throw GoogleCloudAuthError.invalidCredentials("Failed to encode JWT input")
        }

        let signature = try credentials.sign(inputData)
        let signatureBase64 = base64URLEncode(signature)

        return "\(signatureInput).\(signatureBase64)"
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

        let responseBody = try await response.body.collect(upTo: 1024 * 1024)
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

// MARK: - Key Rotation Support

/// A manager for rotating service account keys.
///
/// This class helps manage key rotation by:
/// - Tracking multiple active keys
/// - Providing seamless key transition
/// - Cleaning up old keys after rotation
///
/// ## Example Usage
/// ```swift
/// let rotator = ServiceAccountKeyRotator(
///     iamAPI: iamAPI,
///     serviceAccountEmail: "my-sa@project.iam.gserviceaccount.com"
/// )
///
/// // Rotate to a new key
/// let newCredentials = try await rotator.rotateKey(currentKeyId: oldKeyId)
/// ```
public actor ServiceAccountKeyRotator: Sendable {
    private let iamAPI: GoogleCloudIAMAPI
    private let projectId: String
    private let serviceAccountEmail: String

    /// Keys pending deletion (after rotation grace period).
    private var pendingDeletions: [(keyId: String, deleteAfter: Date)] = []

    /// Grace period before deleting old keys (default: 1 hour).
    public let keyDeletionGracePeriod: TimeInterval

    /// Create a key rotator.
    /// - Parameters:
    ///   - iamAPI: The IAM API client.
    ///   - projectId: The project ID.
    ///   - serviceAccountEmail: The service account email.
    ///   - keyDeletionGracePeriod: How long to keep old keys after rotation.
    public init(
        iamAPI: GoogleCloudIAMAPI,
        projectId: String,
        serviceAccountEmail: String,
        keyDeletionGracePeriod: TimeInterval = 3600
    ) {
        self.iamAPI = iamAPI
        self.projectId = projectId
        self.serviceAccountEmail = serviceAccountEmail
        self.keyDeletionGracePeriod = keyDeletionGracePeriod
    }

    /// Rotate to a new key.
    /// - Parameter currentKeyId: The ID of the current key (will be scheduled for deletion).
    /// - Returns: The new credentials (JSON string).
    /// - Throws: If key creation fails.
    public func rotateKey(currentKeyId: String? = nil) async throws -> String {
        // Create a new key
        let newKey = try await iamAPI.createServiceAccountKey(
            email: serviceAccountEmail,
            keyAlgorithm: .keyAlgRsa2048,
            privateKeyType: .googleCredentialsFile
        )

        guard let keyData = newKey.privateKeyData,
              let decodedData = Data(base64Encoded: keyData),
              let jsonString = String(data: decodedData, encoding: .utf8) else {
            throw GoogleCloudAuthError.invalidCredentials("Failed to decode new key data")
        }

        // Schedule old key for deletion
        if let currentKeyId = currentKeyId {
            pendingDeletions.append((
                keyId: currentKeyId,
                deleteAfter: Date().addingTimeInterval(keyDeletionGracePeriod)
            ))
        }

        return jsonString
    }

    /// Clean up old keys that have passed their grace period.
    /// - Returns: Number of keys deleted.
    @discardableResult
    public func cleanupOldKeys() async throws -> Int {
        let now = Date()
        var deletedCount = 0

        // Find keys ready for deletion
        let readyForDeletion = pendingDeletions.filter { $0.deleteAfter <= now }

        for item in readyForDeletion {
            do {
                try await iamAPI.deleteServiceAccountKey(
                    email: serviceAccountEmail,
                    keyId: item.keyId
                )
                deletedCount += 1
            } catch {
                // Log error but continue with other deletions
                print("Warning: Failed to delete old key \(item.keyId): \(error)")
            }
        }

        // Remove deleted keys from pending list
        pendingDeletions.removeAll { $0.deleteAfter <= now }

        return deletedCount
    }

    /// List all keys for the service account.
    /// - Returns: List of keys.
    public func listKeys() async throws -> [IAMServiceAccountKey] {
        let response = try await iamAPI.listServiceAccountKeys(email: serviceAccountEmail)
        return response.keys ?? []
    }

    /// Get the count of keys pending deletion.
    public var pendingDeletionCount: Int {
        pendingDeletions.count
    }

    /// Cancel pending deletions for a key.
    /// - Parameter keyId: The key ID to cancel deletion for.
    public func cancelDeletion(keyId: String) {
        pendingDeletions.removeAll { $0.keyId == keyId }
    }

    /// Force delete a key immediately.
    /// - Parameter keyId: The key ID to delete.
    public func forceDeleteKey(keyId: String) async throws {
        try await iamAPI.deleteServiceAccountKey(
            email: serviceAccountEmail,
            keyId: keyId
        )

        // Remove from pending if present
        pendingDeletions.removeAll { $0.keyId == keyId }
    }
}

// MARK: - Credential Validator

/// Utilities for validating credentials before use.
public enum CredentialValidator {
    /// Validate service account credentials.
    /// - Parameter credentials: The credentials to validate.
    /// - Throws: If validation fails.
    public static func validate(_ credentials: GoogleCloudServiceAccountCredentials) throws {
        // Check required fields
        guard !credentials.projectId.isEmpty else {
            throw GoogleCloudAuthError.invalidCredentials("Missing project_id")
        }

        guard !credentials.clientEmail.isEmpty else {
            throw GoogleCloudAuthError.invalidCredentials("Missing client_email")
        }

        guard !credentials.privateKey.isEmpty else {
            throw GoogleCloudAuthError.invalidCredentials("Missing private_key")
        }

        guard !credentials.tokenUri.isEmpty else {
            throw GoogleCloudAuthError.invalidCredentials("Missing token_uri")
        }

        // Validate email format
        guard credentials.clientEmail.contains("@") && credentials.clientEmail.contains(".") else {
            throw GoogleCloudAuthError.invalidCredentials("Invalid client_email format")
        }

        // Validate private key format
        guard credentials.privateKey.contains("-----BEGIN") &&
              credentials.privateKey.contains("-----END") else {
            throw GoogleCloudAuthError.invalidPrivateKey("Private key missing PEM headers")
        }

        // Validate token URI format
        guard let url = URL(string: credentials.tokenUri),
              url.scheme == "https" else {
            throw GoogleCloudAuthError.invalidCredentials("Invalid token_uri - must be HTTPS")
        }
    }

    /// Validate secure credentials.
    /// - Parameter credentials: The credentials to validate.
    /// - Throws: If validation fails.
    public static func validate(_ credentials: SecureServiceAccountCredentials) throws {
        guard !credentials.projectId.isEmpty else {
            throw GoogleCloudAuthError.invalidCredentials("Missing project_id")
        }

        guard !credentials.clientEmail.isEmpty else {
            throw GoogleCloudAuthError.invalidCredentials("Missing client_email")
        }

        guard !credentials.isCleared else {
            throw GoogleCloudAuthError.invalidCredentials("Credentials have been cleared")
        }
    }
}

extension SecureServiceAccountCredentials {
    /// Whether the credentials have been cleared.
    var isCleared: Bool {
        securePrivateKey.isCleared
    }
}
