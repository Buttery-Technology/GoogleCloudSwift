import Foundation
import AsyncHTTPClient
import NIOCore
import NIOFoundationCompat
import NIOHTTP1

// MARK: - HTTP Client Errors

/// Errors that can occur during Google Cloud API requests.
public enum GoogleCloudAPIError: Error, Sendable {
    case requestFailed(String)
    case invalidResponse(String)
    case httpError(Int, GoogleCloudErrorResponse?)
    case decodingError(String)
    case encodingError(String)
    case networkError(String)
}

extension GoogleCloudAPIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .httpError(let code, let error):
            if let error = error {
                return "HTTP error \(code): \(error.error.message)"
            }
            return "HTTP error \(code)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Google Cloud Error Response

/// Standard Google Cloud API error response format.
public struct GoogleCloudErrorResponse: Codable, Sendable {
    public let error: GoogleCloudErrorDetails
}

public struct GoogleCloudErrorDetails: Codable, Sendable {
    public let code: Int
    public let message: String
    public let status: String?
    public let errors: [GoogleCloudErrorItem]?
}

public struct GoogleCloudErrorItem: Codable, Sendable {
    public let domain: String?
    public let reason: String?
    public let message: String?
}

// MARK: - HTTP Method

public enum GoogleCloudHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Response

/// A generic response wrapper for Google Cloud API responses.
public struct GoogleCloudAPIResponse<T: Decodable & Sendable>: Sendable {
    public let data: T
    public let statusCode: Int
    public let headers: [(String, String)]
}

// MARK: - Google Cloud HTTP Client

/// A client for making authenticated HTTP requests to Google Cloud APIs.
public actor GoogleCloudHTTPClient {
    private let authClient: GoogleCloudAuthClient
    private let httpClient: HTTPClient
    private let baseURL: String

    /// Initialize the HTTP client.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - baseURL: The base URL for API requests (e.g., "https://compute.googleapis.com").
    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        baseURL: String
    ) {
        self.authClient = authClient
        self.httpClient = httpClient
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
    }

    /// Perform a GET request.
    public func get<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(method: .get, path: path, queryParameters: queryParameters)
    }

    /// Perform a POST request with a JSON body.
    public func post<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(method: .post, path: path, body: body, queryParameters: queryParameters)
    }

    /// Perform a POST request without a body.
    public func post<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(method: .post, path: path, queryParameters: queryParameters)
    }

    /// Perform a PUT request with a JSON body.
    public func put<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(method: .put, path: path, body: body, queryParameters: queryParameters)
    }

    /// Perform a PATCH request with a JSON body.
    public func patch<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(method: .patch, path: path, body: body, queryParameters: queryParameters)
    }

    /// Perform a DELETE request.
    public func delete<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(method: .delete, path: path, queryParameters: queryParameters)
    }

    /// Perform a DELETE request that returns no content.
    public func deleteNoContent(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws {
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await request(
            method: .delete,
            path: path,
            queryParameters: queryParameters,
            allowEmptyResponse: true
        )
    }

    /// Get the project ID from the auth client.
    public func getProjectId() async -> String {
        await authClient.projectId
    }

    // MARK: - Private Methods

    private func request<T: Decodable & Sendable>(
        method: GoogleCloudHTTPMethod,
        path: String,
        queryParameters: [String: String]? = nil,
        allowEmptyResponse: Bool = false
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await request(
            method: method,
            path: path,
            body: Optional<EmptyBody>.none,
            queryParameters: queryParameters,
            allowEmptyResponse: allowEmptyResponse
        )
    }

    private func request<T: Decodable & Sendable, B: Encodable & Sendable>(
        method: GoogleCloudHTTPMethod,
        path: String,
        body: B?,
        queryParameters: [String: String]? = nil,
        allowEmptyResponse: Bool = false
    ) async throws -> GoogleCloudAPIResponse<T> {
        let token = try await authClient.getAccessToken()

        let urlString = buildURL(path: path, queryParameters: queryParameters)
        var request = HTTPClientRequest(url: urlString)
        request.method = HTTPMethod(rawValue: method.rawValue)

        request.headers.add(name: "Authorization", value: "Bearer \(token.token)")
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Accept", value: "application/json")

        if let body = body {
            let encoder = JSONEncoder()
            // Google Cloud APIs use camelCase natively - no conversion needed
            do {
                let bodyData = try encoder.encode(body)
                request.body = .bytes(ByteBuffer(data: bodyData))
            } catch {
                throw GoogleCloudAPIError.encodingError("Failed to encode request body: \(error)")
            }
        }

        let response: HTTPClientResponse
        do {
            response = try await httpClient.execute(request, timeout: .seconds(60))
        } catch {
            throw GoogleCloudAPIError.networkError("Request failed: \(error)")
        }

        let responseBody = try await response.body.collect(upTo: 10 * 1024 * 1024) // 10MB max
        let responseData = Data(buffer: responseBody)

        let headers = response.headers.map { ($0.name, $0.value) }

        guard response.status.code >= 200 && response.status.code < 300 else {
            let errorResponse = try? JSONDecoder().decode(GoogleCloudErrorResponse.self, from: responseData)
            throw GoogleCloudAPIError.httpError(Int(response.status.code), errorResponse)
        }

        // Handle empty responses
        if responseData.isEmpty || (allowEmptyResponse && response.status == .noContent) {
            if let emptyResponse = EmptyResponse() as? T {
                return GoogleCloudAPIResponse(
                    data: emptyResponse,
                    statusCode: Int(response.status.code),
                    headers: headers
                )
            }
        }

        let decoder = JSONDecoder()
        // Google Cloud APIs use camelCase natively - no conversion needed
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try decoder.decode(T.self, from: responseData)
            return GoogleCloudAPIResponse(
                data: data,
                statusCode: Int(response.status.code),
                headers: headers
            )
        } catch {
            let responseString = String(data: responseData, encoding: .utf8) ?? "Unable to decode response"
            throw GoogleCloudAPIError.decodingError("Failed to decode response: \(error). Response: \(responseString)")
        }
    }

    private func buildURL(path: String, queryParameters: [String: String]?) -> String {
        var urlString = "\(baseURL)\(path.hasPrefix("/") ? path : "/\(path)")"

        if let params = queryParameters, !params.isEmpty {
            // Use a character set that excludes & and = to properly encode query values
            var queryValueAllowed = CharacterSet.urlQueryAllowed
            queryValueAllowed.remove(charactersIn: "&=+")

            let queryString = params
                .sorted { $0.key < $1.key }
                .map { key, value in
                    let encodedKey = key.addingPercentEncoding(withAllowedCharacters: queryValueAllowed) ?? key
                    let encodedValue = value.addingPercentEncoding(withAllowedCharacters: queryValueAllowed) ?? value
                    return "\(encodedKey)=\(encodedValue)"
                }
                .joined(separator: "&")
            urlString += "?\(queryString)"
        }

        return urlString
    }
}

// MARK: - Helper Types

private struct EmptyBody: Encodable {}

public struct EmptyResponse: Decodable, Sendable {
    public init() {}
}

// MARK: - List Response

/// A generic list response for Google Cloud API paginated results.
public struct GoogleCloudListResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let items: [T]?
    public let nextPageToken: String?
    public let selfLink: String?
}

// MARK: - Operation Response

/// Represents a long-running operation in Google Cloud.
public struct GoogleCloudOperation: Codable, Sendable {
    public let kind: String?
    public let id: String?
    public let name: String?
    public let description: String?
    public let operationType: String?
    public let status: String?
    public let statusMessage: String?
    public let targetLink: String?
    public let targetId: String?
    public let user: String?
    public let progress: Int?
    public let insertTime: String?
    public let startTime: String?
    public let endTime: String?
    public let selfLink: String?
    public let zone: String?
    public let region: String?
    public let httpErrorStatusCode: Int?
    public let httpErrorMessage: String?
    public let error: OperationError?
    public let warnings: [OperationWarning]?

    public var isDone: Bool {
        status == "DONE"
    }

    public var hasError: Bool {
        error != nil || httpErrorStatusCode != nil
    }

    /// Get a descriptive error message from the operation.
    public var errorMessage: String? {
        if let httpError = httpErrorMessage {
            return httpError
        }
        return error?.errors?.first?.message
    }
}

public struct OperationWarning: Codable, Sendable {
    public let code: String?
    public let message: String?
    public let data: [OperationWarningData]?
}

public struct OperationWarningData: Codable, Sendable {
    public let key: String?
    public let value: String?
}

public struct OperationError: Codable, Sendable {
    public let errors: [OperationErrorItem]?
}

public struct OperationErrorItem: Codable, Sendable {
    public let code: String?
    public let message: String?
    public let location: String?
}
