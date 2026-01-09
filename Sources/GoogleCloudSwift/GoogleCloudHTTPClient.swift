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
    case cancelled
    case maxRetriesExceeded(lastError: Error)
    case timeout(TimeInterval)
    case operationFailed(String)
}

/// Configuration for retry behavior.
public struct RetryConfiguration: Sendable {
    /// Maximum number of retry attempts (0 means no retries).
    public let maxRetries: Int
    /// Base delay between retries in seconds.
    public let baseDelay: TimeInterval
    /// Maximum delay between retries in seconds.
    public let maxDelay: TimeInterval
    /// Jitter factor (0.0 to 1.0) to randomize retry delays.
    public let jitterFactor: Double

    /// Default retry configuration with exponential backoff.
    public static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        jitterFactor: 0.2
    )

    /// No retries.
    public static let none = RetryConfiguration(
        maxRetries: 0,
        baseDelay: 0,
        maxDelay: 0,
        jitterFactor: 0
    )

    public init(maxRetries: Int, baseDelay: TimeInterval, maxDelay: TimeInterval, jitterFactor: Double) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.jitterFactor = jitterFactor
    }

    /// Calculate delay for a given retry attempt using exponential backoff with jitter.
    func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        let cappedDelay = min(exponentialDelay, maxDelay)
        let jitter = cappedDelay * jitterFactor * Double.random(in: -1...1)
        return max(0, cappedDelay + jitter)
    }

    /// Check if a status code is retryable.
    func isRetryable(statusCode: Int) -> Bool {
        // Retry on 429 (Too Many Requests), 500, 502, 503, 504
        return statusCode == 429 || (statusCode >= 500 && statusCode <= 504)
    }
}

extension GoogleCloudAPIError: LocalizedError {
    public var errorDescription: String? {
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
        case .cancelled:
            return "Operation was cancelled"
        case .maxRetriesExceeded(let lastError):
            return "Max retries exceeded, last error: \(lastError)"
        case .timeout(let seconds):
            return "Operation timed out after \(seconds) seconds"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .httpError(let code, _):
            if code == 401 { return "Authentication failed or token expired" }
            if code == 403 { return "Permission denied" }
            if code == 404 { return "Resource not found" }
            if code == 429 { return "Rate limit exceeded" }
            if code >= 500 { return "Google Cloud service error" }
            return nil
        case .networkError:
            return "Network connectivity issue"
        case .timeout:
            return "The operation took too long to complete"
        case .cancelled:
            return "The operation was explicitly cancelled"
        default:
            return nil
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .httpError(let code, _):
            if code == 401 { return "Check your credentials or refresh the auth token" }
            if code == 403 { return "Verify the service account has the required permissions" }
            if code == 404 { return "Verify the resource exists and the name is correct" }
            if code == 429 { return "Wait and retry the request, or reduce request frequency" }
            if code >= 500 { return "Retry the request after a short delay" }
            return nil
        case .networkError:
            return "Check your network connection and try again"
        case .timeout:
            return "Try increasing the timeout or check if the operation is still running"
        case .decodingError:
            return "This may indicate an API change; check for library updates"
        default:
            return nil
        }
    }
}

extension GoogleCloudAPIError: CustomStringConvertible {
    public var description: String {
        errorDescription ?? "Unknown Google Cloud API error"
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
    private let retryConfiguration: RetryConfiguration
    private let requestTimeout: TimeInterval

    /// Initialize the HTTP client.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - baseURL: The base URL for API requests (e.g., "https://compute.googleapis.com").
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds (default: 60).
    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        baseURL: String,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) {
        self.authClient = authClient
        self.httpClient = httpClient
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.retryConfiguration = retryConfiguration
        self.requestTimeout = requestTimeout
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
        var lastError: Error?

        for attempt in 0...retryConfiguration.maxRetries {
            // Check for cancellation before each attempt
            try Task.checkCancellation()

            do {
                return try await executeRequest(
                    method: method,
                    path: path,
                    body: body,
                    queryParameters: queryParameters,
                    allowEmptyResponse: allowEmptyResponse
                )
            } catch let error as GoogleCloudAPIError {
                lastError = error

                // Check if this error is retryable
                if case .httpError(let statusCode, _) = error,
                   retryConfiguration.isRetryable(statusCode: statusCode),
                   attempt < retryConfiguration.maxRetries {
                    let delay = retryConfiguration.delay(for: attempt)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }

                // Also retry on network errors
                if case .networkError = error, attempt < retryConfiguration.maxRetries {
                    let delay = retryConfiguration.delay(for: attempt)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }

                throw error
            } catch is CancellationError {
                throw GoogleCloudAPIError.cancelled
            } catch {
                lastError = error
                throw error
            }
        }

        throw GoogleCloudAPIError.maxRetriesExceeded(lastError: lastError ?? GoogleCloudAPIError.requestFailed("Unknown error"))
    }

    private func executeRequest<T: Decodable & Sendable, B: Encodable & Sendable>(
        method: GoogleCloudHTTPMethod,
        path: String,
        body: B?,
        queryParameters: [String: String]?,
        allowEmptyResponse: Bool
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
            response = try await httpClient.execute(request, timeout: .seconds(Int64(requestTimeout)))
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

    /// Returns true if there are more pages of results.
    public var hasMorePages: Bool {
        nextPageToken != nil && !nextPageToken!.isEmpty
    }

    /// Returns the items or an empty array if nil.
    public var itemsOrEmpty: [T] {
        items ?? []
    }
}

// MARK: - Pagination Helper

/// A helper for fetching all pages of a paginated API.
public struct PaginationHelper<T: Decodable & Sendable>: AsyncSequence {
    public typealias Element = [T]

    private let fetchPage: (String?) async throws -> GoogleCloudListResponse<T>

    /// Create a pagination helper.
    /// - Parameter fetchPage: A closure that fetches a page given an optional page token.
    public init(fetchPage: @escaping (String?) async throws -> GoogleCloudListResponse<T>) {
        self.fetchPage = fetchPage
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(fetchPage: fetchPage)
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let fetchPage: (String?) async throws -> GoogleCloudListResponse<T>
        private var nextPageToken: String?
        private var hasStarted = false
        private var isDone = false

        init(fetchPage: @escaping (String?) async throws -> GoogleCloudListResponse<T>) {
            self.fetchPage = fetchPage
        }

        public mutating func next() async throws -> [T]? {
            guard !isDone else { return nil }

            // Check for cancellation
            try Task.checkCancellation()

            let response = try await fetchPage(hasStarted ? nextPageToken : nil)
            hasStarted = true

            nextPageToken = response.nextPageToken
            if nextPageToken == nil || nextPageToken!.isEmpty {
                isDone = true
            }

            let items = response.items ?? []
            return items.isEmpty && isDone ? nil : items
        }
    }

    /// Collect all items from all pages into a single array.
    public func collectAll() async throws -> [T] {
        var allItems: [T] = []
        for try await items in self {
            try Task.checkCancellation()
            allItems.append(contentsOf: items)
        }
        return allItems
    }
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
    public let insertTime: Date?
    public let startTime: Date?
    public let endTime: Date?
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

// MARK: - HTTPClient Factory

/// Factory for creating and managing HTTPClient instances.
///
/// This helper simplifies HTTPClient lifecycle management for Google Cloud API usage.
///
/// ## Example Usage
/// ```swift
/// // Option 1: Use withHTTPClient for automatic cleanup
/// try await GoogleCloudHTTPClientFactory.withHTTPClient { httpClient in
///     let authClient = try GoogleCloudAuthClient(
///         credentialsPath: "/path/to/credentials.json",
///         httpClient: httpClient
///     )
///     let computeAPI = await GoogleCloudComputeAPI.create(
///         authClient: authClient,
///         httpClient: httpClient
///     )
///     // Use the API...
/// }
/// // HTTPClient is automatically shut down when the closure returns
///
/// // Option 2: Create a shared client for long-lived applications
/// let httpClient = GoogleCloudHTTPClientFactory.makeHTTPClient()
/// defer { GoogleCloudHTTPClientFactory.shutdown(httpClient) }
/// ```
public enum GoogleCloudHTTPClientFactory {
    /// Create a new HTTPClient configured for Google Cloud API usage.
    ///
    /// - Important: You are responsible for calling `shutdown(_:)` when done.
    /// - Returns: A configured HTTPClient instance.
    public static func makeHTTPClient() -> HTTPClient {
        HTTPClient(eventLoopGroupProvider: .singleton)
    }

    /// Shut down an HTTPClient gracefully.
    ///
    /// Call this when you're done using the HTTPClient to release resources.
    /// - Parameter client: The HTTPClient to shut down.
    public static func shutdown(_ client: HTTPClient) {
        try? client.syncShutdown()
    }

    /// Execute a closure with a managed HTTPClient that is automatically shut down.
    ///
    /// This is the recommended approach for scripts and short-lived operations.
    ///
    /// - Parameter operation: An async closure that receives the HTTPClient.
    /// - Returns: The result of the operation.
    /// - Throws: Any error thrown by the operation.
    public static func withHTTPClient<T: Sendable>(
        _ operation: @Sendable (HTTPClient) async throws -> T
    ) async throws -> T {
        let client = makeHTTPClient()
        do {
            let result = try await operation(client)
            try? await client.shutdown()
            return result
        } catch {
            try? await client.shutdown()
            throw error
        }
    }
}
