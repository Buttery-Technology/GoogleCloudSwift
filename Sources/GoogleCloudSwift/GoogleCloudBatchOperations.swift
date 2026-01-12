//
//  GoogleCloudBatchOperations.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import AsyncHTTPClient
import NIOCore

// MARK: - Batch Request Types

/// A single operation within a batch request.
public struct BatchOperation<T: Decodable & Sendable>: Sendable {
    /// Unique identifier for this operation within the batch.
    public let id: String

    /// HTTP method for the operation.
    public let method: GoogleCloudHTTPMethod

    /// API path for the operation.
    public let path: String

    /// Query parameters for the operation.
    public let queryParameters: [String: String]?

    /// Request body (if applicable).
    public let body: Data?

    /// Content type for the body.
    public let contentType: String?

    /// Type used for decoding (internal use).
    internal let responseType: T.Type

    public init(
        id: String = UUID().uuidString,
        method: GoogleCloudHTTPMethod,
        path: String,
        queryParameters: [String: String]? = nil,
        body: Data? = nil,
        contentType: String? = "application/json"
    ) where T == EmptyResponse {
        self.id = id
        self.method = method
        self.path = path
        self.queryParameters = queryParameters
        self.body = body
        self.contentType = contentType
        self.responseType = T.self
    }

    public init(
        id: String = UUID().uuidString,
        method: GoogleCloudHTTPMethod,
        path: String,
        queryParameters: [String: String]? = nil,
        body: Data? = nil,
        contentType: String? = "application/json",
        responseType: T.Type
    ) {
        self.id = id
        self.method = method
        self.path = path
        self.queryParameters = queryParameters
        self.body = body
        self.contentType = contentType
        self.responseType = responseType
    }
}

/// Result of a single operation within a batch response.
public enum BatchOperationResult<T: Decodable & Sendable>: Sendable {
    case success(T)
    case failure(BatchOperationError)

    /// Get the successful result or throw the error.
    public func get() throws -> T {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    /// Whether this operation succeeded.
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

/// Error from a batch operation.
public struct BatchOperationError: Error, Sendable {
    public let operationId: String
    public let statusCode: Int
    public let message: String
    public let details: GoogleCloudErrorResponse?

    public init(operationId: String, statusCode: Int, message: String, details: GoogleCloudErrorResponse? = nil) {
        self.operationId = operationId
        self.statusCode = statusCode
        self.message = message
        self.details = details
    }
}

extension BatchOperationError: LocalizedError {
    public var errorDescription: String? {
        if let details = details {
            return "Batch operation \(operationId) failed with status \(statusCode): \(details.error.message)"
        }
        return "Batch operation \(operationId) failed with status \(statusCode): \(message)"
    }
}

/// Response from a batch request.
public struct BatchResponse<T: Decodable & Sendable>: Sendable {
    /// Results indexed by operation ID.
    public let results: [String: BatchOperationResult<T>]

    /// All successful results.
    public var successes: [(id: String, value: T)] {
        results.compactMap { id, result in
            if case .success(let value) = result {
                return (id, value)
            }
            return nil
        }
    }

    /// All failures.
    public var failures: [(id: String, error: BatchOperationError)] {
        results.compactMap { id, result in
            if case .failure(let error) = result {
                return (id, error)
            }
            return nil
        }
    }

    /// Whether all operations succeeded.
    public var allSucceeded: Bool {
        results.values.allSatisfy { $0.isSuccess }
    }

    /// Number of successful operations.
    public var successCount: Int {
        results.values.filter { $0.isSuccess }.count
    }

    /// Number of failed operations.
    public var failureCount: Int {
        results.count - successCount
    }
}

// MARK: - Batch Request Builder

/// Builder for constructing batch requests.
public actor BatchRequestBuilder {
    private var operations: [AnyBatchOperation] = []

    public init() {}

    /// Add a GET operation to the batch.
    @discardableResult
    public func get<T: Decodable & Sendable>(
        id: String = UUID().uuidString,
        path: String,
        queryParameters: [String: String]? = nil,
        responseType: T.Type
    ) -> Self {
        let operation = BatchOperation<T>(
            id: id,
            method: .get,
            path: path,
            queryParameters: queryParameters,
            responseType: responseType
        )
        operations.append(AnyBatchOperation(operation))
        return self
    }

    /// Add a POST operation to the batch.
    @discardableResult
    public func post<T: Decodable & Sendable, B: Encodable & Sendable>(
        id: String = UUID().uuidString,
        path: String,
        body: B,
        queryParameters: [String: String]? = nil,
        responseType: T.Type
    ) throws -> Self {
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)

        let operation = BatchOperation<T>(
            id: id,
            method: .post,
            path: path,
            queryParameters: queryParameters,
            body: bodyData,
            contentType: "application/json",
            responseType: responseType
        )
        operations.append(AnyBatchOperation(operation))
        return self
    }

    /// Add a DELETE operation to the batch.
    @discardableResult
    public func delete(
        id: String = UUID().uuidString,
        path: String,
        queryParameters: [String: String]? = nil
    ) -> Self {
        let operation = BatchOperation<EmptyResponse>(
            id: id,
            method: .delete,
            path: path,
            queryParameters: queryParameters
        )
        operations.append(AnyBatchOperation(operation))
        return self
    }

    /// Get all operations.
    public func build() -> [AnyBatchOperation] {
        operations
    }

    /// Clear all operations.
    public func clear() {
        operations.removeAll()
    }

    /// Number of operations in the batch.
    public var count: Int {
        operations.count
    }
}

/// Type-erased batch operation for heterogeneous batches.
public struct AnyBatchOperation: Sendable {
    public let id: String
    public let method: GoogleCloudHTTPMethod
    public let path: String
    public let queryParameters: [String: String]?
    public let body: Data?
    public let contentType: String?

    internal let decode: @Sendable (Data) throws -> Any

    public init<T: Decodable & Sendable>(_ operation: BatchOperation<T>) {
        self.id = operation.id
        self.method = operation.method
        self.path = operation.path
        self.queryParameters = operation.queryParameters
        self.body = operation.body
        self.contentType = operation.contentType
        self.decode = { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
            return try decoder.decode(T.self, from: data)
        }
    }
}

// MARK: - Batch Executor

/// Executor for batch requests.
///
/// Google Cloud APIs support batch requests using multipart/mixed content type.
/// This executor handles constructing and parsing batch requests.
///
/// ## Example Usage
/// ```swift
/// let executor = BatchExecutor(
///     authClient: authClient,
///     httpClient: httpClient,
///     baseURL: "https://storage.googleapis.com"
/// )
///
/// let operations = [
///     BatchOperation<StorageBucket>(
///         id: "get-bucket-1",
///         method: .get,
///         path: "/storage/v1/b/my-bucket-1",
///         responseType: StorageBucket.self
///     ),
///     BatchOperation<StorageBucket>(
///         id: "get-bucket-2",
///         method: .get,
///         path: "/storage/v1/b/my-bucket-2",
///         responseType: StorageBucket.self
///     )
/// ]
///
/// let response = try await executor.execute(operations)
/// for (id, result) in response.results {
///     switch result {
///     case .success(let bucket):
///         print("Bucket \(id): \(bucket.name)")
///     case .failure(let error):
///         print("Error \(id): \(error)")
///     }
/// }
/// ```
public actor BatchExecutor {
    private let authClient: GoogleCloudAuthClient
    private let httpClient: HTTPClient
    private let baseURL: String
    private let configuration: GoogleCloudConfiguration

    /// Maximum operations per batch request (Google Cloud limit is typically 100-1000 depending on API).
    public static let defaultMaxOperationsPerBatch = 100

    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        baseURL: String,
        configuration: GoogleCloudConfiguration = .default
    ) {
        self.authClient = authClient
        self.httpClient = httpClient
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.configuration = configuration
    }

    /// Execute a batch of homogeneous operations (all returning the same type).
    public func execute<T: Decodable & Sendable>(
        _ operations: [BatchOperation<T>]
    ) async throws -> BatchResponse<T> {
        guard !operations.isEmpty else {
            return BatchResponse(results: [:])
        }

        // Split into chunks if exceeding max operations
        if operations.count > Self.defaultMaxOperationsPerBatch {
            return try await executeInChunks(operations)
        }

        return try await executeSingleBatch(operations)
    }

    /// Execute heterogeneous operations (different return types).
    public func executeHeterogeneous(
        _ operations: [AnyBatchOperation]
    ) async throws -> [String: Result<Any, BatchOperationError>] {
        guard !operations.isEmpty else {
            return [:]
        }

        let token = try await authClient.getAccessToken()
        let boundary = "batch_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"

        // Build multipart request body
        var bodyParts: [String] = []
        for operation in operations {
            let part = buildRequestPart(operation: operation, boundary: boundary)
            bodyParts.append(part)
        }

        let requestBody = bodyParts.joined() + "--\(boundary)--\r\n"

        // Create the batch request
        var request = HTTPClientRequest(url: "\(baseURL)/batch")
        request.method = .POST
        request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
        request.headers.add(name: "Content-Type", value: "multipart/mixed; boundary=\(boundary)")
        request.body = .bytes(.init(data: requestBody.data(using: .utf8)!))

        // Execute the request
        let response = try await httpClient.execute(
            request,
            timeout: .seconds(Int64(configuration.timeouts.request))
        )

        // Parse the multipart response
        let responseBody = try await response.body.collect(upTo: 100 * 1024 * 1024) // 100MB limit
        let responseData = Data(buffer: responseBody)

        return try parseHeterogeneousResponse(
            data: responseData,
            contentType: response.headers.first(name: "Content-Type") ?? "",
            operations: operations
        )
    }

    // MARK: - Private Methods

    private func executeSingleBatch<T: Decodable & Sendable>(
        _ operations: [BatchOperation<T>]
    ) async throws -> BatchResponse<T> {
        let token = try await authClient.getAccessToken()
        let boundary = "batch_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"

        // Build multipart request body
        var bodyParts: [String] = []
        for operation in operations {
            let anyOp = AnyBatchOperation(operation)
            let part = buildRequestPart(operation: anyOp, boundary: boundary)
            bodyParts.append(part)
        }

        let requestBody = bodyParts.joined() + "--\(boundary)--\r\n"

        // Create the batch request
        var request = HTTPClientRequest(url: "\(baseURL)/batch")
        request.method = .POST
        request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
        request.headers.add(name: "Content-Type", value: "multipart/mixed; boundary=\(boundary)")
        request.body = .bytes(.init(data: requestBody.data(using: .utf8)!))

        // Execute the request
        let response = try await httpClient.execute(
            request,
            timeout: .seconds(Int64(configuration.timeouts.request))
        )

        // Parse the multipart response
        let responseBody = try await response.body.collect(upTo: 100 * 1024 * 1024) // 100MB limit
        let responseData = Data(buffer: responseBody)

        return try parseResponse(
            data: responseData,
            contentType: response.headers.first(name: "Content-Type") ?? "",
            operations: operations
        )
    }

    private func executeInChunks<T: Decodable & Sendable>(
        _ operations: [BatchOperation<T>]
    ) async throws -> BatchResponse<T> {
        var allResults: [String: BatchOperationResult<T>] = [:]

        // Split into chunks
        let chunks = stride(from: 0, to: operations.count, by: Self.defaultMaxOperationsPerBatch)
            .map { Array(operations[$0..<min($0 + Self.defaultMaxOperationsPerBatch, operations.count)]) }

        // Execute each chunk
        for chunk in chunks {
            let chunkResponse = try await executeSingleBatch(chunk)
            allResults.merge(chunkResponse.results) { _, new in new }
        }

        return BatchResponse(results: allResults)
    }

    private func buildRequestPart(operation: AnyBatchOperation, boundary: String) -> String {
        var part = "--\(boundary)\r\n"
        part += "Content-Type: application/http\r\n"
        part += "Content-ID: \(operation.id)\r\n"
        part += "\r\n"

        // Build the inner HTTP request
        var url = operation.path
        if let queryParams = operation.queryParameters, !queryParams.isEmpty {
            let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            url += "?\(queryString)"
        }

        part += "\(operation.method.rawValue) \(url) HTTP/1.1\r\n"

        if let contentType = operation.contentType, operation.body != nil {
            part += "Content-Type: \(contentType)\r\n"
        }

        part += "\r\n"

        if let body = operation.body, let bodyString = String(data: body, encoding: .utf8) {
            part += bodyString
        }

        part += "\r\n"
        return part
    }

    private func parseResponse<T: Decodable & Sendable>(
        data: Data,
        contentType: String,
        operations: [BatchOperation<T>]
    ) throws -> BatchResponse<T> {
        // Extract boundary from content type
        guard let boundary = extractBoundary(from: contentType) else {
            throw GoogleCloudAPIError.invalidResponse("Missing boundary in batch response")
        }

        var results: [String: BatchOperationResult<T>] = [:]

        // Parse each part
        let parts = try parseMultipartResponse(data: data, boundary: boundary)

        for part in parts {
            guard let contentId = part.contentId else { continue }

            // Clean the content ID (remove angle brackets if present)
            let cleanId = contentId
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: "response-", with: "")

            if part.statusCode >= 200 && part.statusCode < 300 {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
                    let value = try decoder.decode(T.self, from: part.body)
                    results[cleanId] = .success(value)
                } catch {
                    results[cleanId] = .failure(BatchOperationError(
                        operationId: cleanId,
                        statusCode: part.statusCode,
                        message: "Failed to decode response: \(error.localizedDescription)"
                    ))
                }
            } else {
                let errorResponse = try? JSONDecoder().decode(GoogleCloudErrorResponse.self, from: part.body)
                results[cleanId] = .failure(BatchOperationError(
                    operationId: cleanId,
                    statusCode: part.statusCode,
                    message: errorResponse?.error.message ?? "Unknown error",
                    details: errorResponse
                ))
            }
        }

        return BatchResponse(results: results)
    }

    private func parseHeterogeneousResponse(
        data: Data,
        contentType: String,
        operations: [AnyBatchOperation]
    ) throws -> [String: Result<Any, BatchOperationError>] {
        guard let boundary = extractBoundary(from: contentType) else {
            throw GoogleCloudAPIError.invalidResponse("Missing boundary in batch response")
        }

        let operationsById = Dictionary(uniqueKeysWithValues: operations.map { ($0.id, $0) })
        var results: [String: Result<Any, BatchOperationError>] = [:]

        let parts = try parseMultipartResponse(data: data, boundary: boundary)

        for part in parts {
            guard let contentId = part.contentId else { continue }

            let cleanId = contentId
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: "response-", with: "")

            guard let operation = operationsById[cleanId] else { continue }

            if part.statusCode >= 200 && part.statusCode < 300 {
                do {
                    let value = try operation.decode(part.body)
                    results[cleanId] = .success(value)
                } catch {
                    results[cleanId] = .failure(BatchOperationError(
                        operationId: cleanId,
                        statusCode: part.statusCode,
                        message: "Failed to decode response: \(error.localizedDescription)"
                    ))
                }
            } else {
                let errorResponse = try? JSONDecoder().decode(GoogleCloudErrorResponse.self, from: part.body)
                results[cleanId] = .failure(BatchOperationError(
                    operationId: cleanId,
                    statusCode: part.statusCode,
                    message: errorResponse?.error.message ?? "Unknown error",
                    details: errorResponse
                ))
            }
        }

        return results
    }

    private func extractBoundary(from contentType: String) -> String? {
        let parts = contentType.components(separatedBy: ";")
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("boundary=") {
                return String(trimmed.dropFirst("boundary=".count))
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }
        }
        return nil
    }

    private struct ResponsePart {
        let contentId: String?
        let statusCode: Int
        let headers: [String: String]
        let body: Data
    }

    private func parseMultipartResponse(data: Data, boundary: String) throws -> [ResponsePart] {
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw GoogleCloudAPIError.invalidResponse("Could not decode batch response as UTF-8")
        }

        var parts: [ResponsePart] = []
        let partDelimiter = "--\(boundary)"

        let rawParts = responseString.components(separatedBy: partDelimiter)

        for rawPart in rawParts {
            let trimmed = rawPart.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed == "--" || rawPart.hasPrefix("--") { continue }

            // Parse part headers and body
            let sections = rawPart.components(separatedBy: "\r\n\r\n")
            guard sections.count >= 2 else { continue }

            let partHeaders = sections[0]
            var contentId: String?

            // Extract Content-ID from part headers
            for line in partHeaders.components(separatedBy: "\r\n") {
                if line.lowercased().hasPrefix("content-id:") {
                    contentId = String(line.dropFirst("content-id:".count)).trimmingCharacters(in: .whitespaces)
                }
            }

            // The inner HTTP response is in sections[1]
            let innerResponse = sections.dropFirst().joined(separator: "\r\n\r\n")
            let innerLines = innerResponse.components(separatedBy: "\r\n")

            // Parse HTTP status line
            var statusCode = 200
            if let statusLine = innerLines.first, statusLine.hasPrefix("HTTP/") {
                let statusParts = statusLine.components(separatedBy: " ")
                if statusParts.count >= 2 {
                    statusCode = Int(statusParts[1]) ?? 200
                }
            }

            // Find the body (after empty line in inner response)
            var bodyStartIndex = 0
            for (index, line) in innerLines.enumerated() {
                if line.isEmpty && index > 0 {
                    bodyStartIndex = index + 1
                    break
                }
            }

            let bodyLines = Array(innerLines.dropFirst(bodyStartIndex))
            let bodyString = bodyLines.joined(separator: "\r\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let bodyData = bodyString.data(using: .utf8) ?? Data()

            parts.append(ResponsePart(
                contentId: contentId,
                statusCode: statusCode,
                headers: [:],
                body: bodyData
            ))
        }

        return parts
    }
}

// MARK: - Batch Helpers

/// Convenience extensions for common batch operations.
extension BatchExecutor {
    /// Execute multiple GET requests in a batch.
    public func batchGet<T: Decodable & Sendable>(
        paths: [String],
        responseType: T.Type
    ) async throws -> BatchResponse<T> {
        let operations = paths.enumerated().map { index, path in
            BatchOperation<T>(
                id: "get-\(index)",
                method: .get,
                path: path,
                responseType: responseType
            )
        }
        return try await execute(operations)
    }

    /// Execute multiple DELETE requests in a batch.
    public func batchDelete(
        paths: [String]
    ) async throws -> BatchResponse<EmptyResponse> {
        let operations = paths.enumerated().map { index, path in
            BatchOperation<EmptyResponse>(
                id: "delete-\(index)",
                method: .delete,
                path: path
            )
        }
        return try await execute(operations)
    }
}

// MARK: - Concurrent Batch Execution

/// Helper for executing operations concurrently with controlled parallelism.
///
/// This is useful when you need to execute many operations but want to control
/// the number of concurrent requests to avoid overwhelming the API or client.
///
/// ## Example Usage
/// ```swift
/// let executor = ConcurrentBatchExecutor(maxConcurrency: 10)
///
/// let bucketNames = ["bucket1", "bucket2", "bucket3", ...]
/// let results = try await executor.execute(operations: bucketNames) { bucketName in
///     try await storageAPI.getBucket(name: bucketName)
/// }
///
/// for (name, result) in results {
///     switch result {
///     case .success(let bucket):
///         print("Got bucket: \(bucket.name ?? name)")
///     case .failure(let error):
///         print("Failed to get \(name): \(error)")
///     }
/// }
/// ```
public actor ConcurrentBatchExecutor {
    private let maxConcurrency: Int
    private let retryConfiguration: RetryConfiguration

    public init(
        maxConcurrency: Int = 10,
        retryConfiguration: RetryConfiguration = .default
    ) {
        self.maxConcurrency = maxConcurrency
        self.retryConfiguration = retryConfiguration
    }

    /// Execute operations concurrently with controlled parallelism.
    public func execute<T: Sendable>(
        operations: [String],
        operation: @Sendable @escaping (String) async throws -> T
    ) async throws -> [String: Result<T, Error>] {
        var results: [String: Result<T, Error>] = [:]

        await withTaskGroup(of: (String, Result<T, Error>).self) { group in
            var pending = operations.makeIterator()
            var activeCount = 0

            // Start initial batch
            while activeCount < maxConcurrency, let op = pending.next() {
                activeCount += 1
                group.addTask {
                    do {
                        let result = try await operation(op)
                        return (op, .success(result))
                    } catch {
                        return (op, .failure(error))
                    }
                }
            }

            // Process results and add new tasks as slots become available
            for await (id, result) in group {
                results[id] = result
                activeCount -= 1

                if let op = pending.next() {
                    activeCount += 1
                    group.addTask {
                        do {
                            let result = try await operation(op)
                            return (op, .success(result))
                        } catch {
                            return (op, .failure(error))
                        }
                    }
                }
            }
        }

        return results
    }

    /// Execute operations with automatic retry on failure.
    public func executeWithRetry<T: Sendable>(
        operations: [String],
        operation: @Sendable @escaping (String) async throws -> T
    ) async throws -> [String: Result<T, Error>] {
        var results: [String: Result<T, Error>] = [:]
        var remainingOps = Set(operations)

        for attempt in 0...retryConfiguration.maxRetries {
            let currentOps = Array(remainingOps)

            let batchResults = try await execute(
                operations: currentOps,
                operation: operation
            )

            for (id, result) in batchResults {
                switch result {
                case .success:
                    results[id] = result
                    remainingOps.remove(id)
                case .failure:
                    if attempt == retryConfiguration.maxRetries {
                        results[id] = result
                        remainingOps.remove(id)
                    }
                }
            }

            if remainingOps.isEmpty || attempt == retryConfiguration.maxRetries {
                break
            }

            // Wait before retry
            let delay = retryConfiguration.delay(for: attempt)
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        return results
    }
}

// MARK: - Parallel List Helper

/// Helper for fetching items from multiple pages in parallel.
public actor ParallelListFetcher {
    private let maxConcurrency: Int

    public init(maxConcurrency: Int = 5) {
        self.maxConcurrency = maxConcurrency
    }

    /// Fetch all pages of a list operation in parallel.
    ///
    /// This is useful when you know the total number of pages upfront
    /// (e.g., from an initial request) and want to fetch them all efficiently.
    public func fetchAllPages<T: Sendable>(
        pageTokens: [String?],
        fetcher: @Sendable @escaping (String?) async throws -> (items: [T], nextPageToken: String?)
    ) async throws -> [T] {
        var allItems: [T] = []

        await withTaskGroup(of: [T].self) { group in
            var pending = pageTokens.makeIterator()
            var activeCount = 0

            while activeCount < maxConcurrency, let token = pending.next() {
                activeCount += 1
                group.addTask {
                    do {
                        let (items, _) = try await fetcher(token)
                        return items
                    } catch {
                        return []
                    }
                }
            }

            for await items in group {
                allItems.append(contentsOf: items)
                activeCount -= 1

                if let token = pending.next() {
                    activeCount += 1
                    group.addTask {
                        do {
                            let (items, _) = try await fetcher(token)
                            return items
                        } catch {
                            return []
                        }
                    }
                }
            }
        }

        return allItems
    }
}
