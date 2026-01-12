//
//  GoogleCloudStreaming.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOFoundationCompat

// MARK: - Streaming Types

/// A chunk of data from a streaming response.
public struct StreamChunk: Sendable {
    /// The raw data of the chunk.
    public let data: Data

    /// Whether this is the last chunk.
    public let isLast: Bool

    /// The sequence number of this chunk (0-indexed).
    public let sequenceNumber: Int

    /// Timestamp when this chunk was received.
    public let receivedAt: Date

    public init(data: Data, isLast: Bool, sequenceNumber: Int, receivedAt: Date = Date()) {
        self.data = data
        self.isLast = isLast
        self.sequenceNumber = sequenceNumber
        self.receivedAt = receivedAt
    }
}

/// A server-sent event from a streaming response.
public struct ServerSentEvent: Sendable {
    /// Event type (e.g., "message", "error").
    public let event: String?

    /// Event data.
    public let data: String

    /// Event ID (for resumption).
    public let id: String?

    /// Retry interval in milliseconds (if suggested by server).
    public let retry: Int?

    public init(event: String? = nil, data: String, id: String? = nil, retry: Int? = nil) {
        self.event = event
        self.data = data
        self.id = id
        self.retry = retry
    }

    /// Parse the data as JSON.
    public func parseJSON<T: Decodable>(_ type: T.Type) throws -> T {
        guard let jsonData = data.data(using: .utf8) else {
            throw StreamingError.invalidData("Could not convert data to UTF-8")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
        return try decoder.decode(type, from: jsonData)
    }
}

/// Errors that can occur during streaming operations.
public enum StreamingError: Error, Sendable, LocalizedError {
    case connectionFailed(String)
    case streamClosed
    case invalidData(String)
    case timeout
    case serverError(Int, String?)

    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .streamClosed:
            return "Stream was closed unexpectedly"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .timeout:
            return "Stream timed out"
        case .serverError(let code, let message):
            return "Server error \(code): \(message ?? "Unknown")"
        }
    }

    public var failureReason: String? {
        switch self {
        case .connectionFailed:
            return "The connection to the streaming endpoint could not be established."
        case .streamClosed:
            return "The server closed the connection before the stream completed."
        case .invalidData:
            return "The received data could not be parsed or processed."
        case .timeout:
            return "No data was received within the expected time period."
        case .serverError(let code, _):
            return "The server returned HTTP status code \(code)."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .connectionFailed:
            return "Check your network connection and try again."
        case .streamClosed:
            return "Retry the request. If the problem persists, the service may be experiencing issues."
        case .invalidData:
            return "This may indicate an API version mismatch or unexpected response format."
        case .timeout:
            return "Increase the timeout duration or check if the service is responding."
        case .serverError(let code, _):
            if code >= 500 {
                return "This is a server-side error. Retry the request after a short delay."
            } else {
                return "Check the request parameters and authentication."
            }
        }
    }
}

// MARK: - Streaming Client

/// A client for streaming responses from Google Cloud APIs.
///
/// This client supports:
/// - Chunked transfer encoding for large responses
/// - Server-Sent Events (SSE) for real-time updates
/// - Long-polling for operation status updates
///
/// ## Example Usage
/// ```swift
/// let streamingClient = GoogleCloudStreamingClient(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // Stream chunks
/// for try await chunk in streamingClient.streamChunks(url: downloadURL) {
///     processChunk(chunk.data)
/// }
///
/// // Stream Server-Sent Events
/// for try await event in streamingClient.streamEvents(url: eventURL) {
///     if let message = event.data {
///         handleMessage(message)
///     }
/// }
/// ```
public actor GoogleCloudStreamingClient {
    private let authClient: GoogleCloudAuthClient
    private let httpClient: HTTPClient
    private let configuration: GoogleCloudConfiguration

    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        configuration: GoogleCloudConfiguration = .default
    ) {
        self.authClient = authClient
        self.httpClient = httpClient
        self.configuration = configuration
    }

    // MARK: - Chunk Streaming

    /// Stream a response as chunks of data.
    ///
    /// This is useful for downloading large files or processing streaming responses.
    public func streamChunks(
        url: String,
        headers: [String: String] = [:]
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let token = try await self.authClient.getAccessToken()

                    var request = HTTPClientRequest(url: url)
                    request.method = .GET
                    request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
                    for (key, value) in headers {
                        request.headers.add(name: key, value: value)
                    }

                    let response = try await self.httpClient.execute(
                        request,
                        timeout: .seconds(Int64(self.configuration.timeouts.download))
                    )

                    if response.status.code >= 400 {
                        continuation.finish(throwing: StreamingError.serverError(
                            Int(response.status.code),
                            response.status.reasonPhrase
                        ))
                        return
                    }

                    var sequenceNumber = 0
                    for try await buffer in response.body {
                        let data = Data(buffer: buffer)
                        let chunk = StreamChunk(
                            data: data,
                            isLast: false,
                            sequenceNumber: sequenceNumber
                        )
                        continuation.yield(chunk)
                        sequenceNumber += 1
                    }

                    // Yield final empty chunk to indicate completion
                    let finalChunk = StreamChunk(
                        data: Data(),
                        isLast: true,
                        sequenceNumber: sequenceNumber
                    )
                    continuation.yield(finalChunk)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Stream chunks and accumulate into complete data.
    public func downloadStreaming(
        url: String,
        progressHandler: (@Sendable (Int, Int?) -> Void)? = nil
    ) async throws -> Data {
        var accumulatedData = Data()
        var totalReceived = 0

        for try await chunk in streamChunks(url: url) {
            accumulatedData.append(chunk.data)
            totalReceived += chunk.data.count
            progressHandler?(totalReceived, nil)
        }

        return accumulatedData
    }

    // MARK: - Server-Sent Events

    /// Stream Server-Sent Events from a URL.
    ///
    /// Server-Sent Events are a standard for server-to-client streaming,
    /// commonly used for real-time updates.
    public func streamEvents(
        url: String,
        lastEventId: String? = nil
    ) -> AsyncThrowingStream<ServerSentEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let token = try await self.authClient.getAccessToken()

                    var request = HTTPClientRequest(url: url)
                    request.method = .GET
                    request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
                    request.headers.add(name: "Accept", value: "text/event-stream")
                    request.headers.add(name: "Cache-Control", value: "no-cache")

                    if let lastEventId = lastEventId {
                        request.headers.add(name: "Last-Event-ID", value: lastEventId)
                    }

                    let response = try await self.httpClient.execute(
                        request,
                        timeout: .seconds(Int64(self.configuration.timeouts.download))
                    )

                    if response.status.code >= 400 {
                        continuation.finish(throwing: StreamingError.serverError(
                            Int(response.status.code),
                            response.status.reasonPhrase
                        ))
                        return
                    }

                    var buffer = ""

                    for try await chunk in response.body {
                        let data = Data(buffer: chunk)
                        guard let text = String(data: data, encoding: .utf8) else { continue }

                        buffer += text

                        // Parse complete events from buffer
                        while let eventEnd = buffer.range(of: "\n\n") {
                            let eventText = String(buffer[..<eventEnd.lowerBound])
                            buffer = String(buffer[eventEnd.upperBound...])

                            if let event = self.parseServerSentEvent(eventText) {
                                continuation.yield(event)
                            }
                        }
                    }

                    // Parse any remaining event in buffer
                    if !buffer.isEmpty {
                        if let event = self.parseServerSentEvent(buffer) {
                            continuation.yield(event)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func parseServerSentEvent(_ text: String) -> ServerSentEvent? {
        var event: String?
        var data: [String] = []
        var id: String?
        var retry: Int?

        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("event:") {
                event = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("data:") {
                data.append(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces))
            } else if line.hasPrefix("id:") {
                id = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("retry:") {
                retry = Int(String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces))
            }
        }

        guard !data.isEmpty else { return nil }

        return ServerSentEvent(
            event: event,
            data: data.joined(separator: "\n"),
            id: id,
            retry: retry
        )
    }

    // MARK: - NDJSON Streaming

    /// Stream newline-delimited JSON objects.
    ///
    /// NDJSON is a common format for streaming JSON objects, where each line
    /// is a complete JSON object.
    public func streamNDJSON<T: Decodable & Sendable>(
        url: String,
        type: T.Type
    ) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let token = try await self.authClient.getAccessToken()

                    var request = HTTPClientRequest(url: url)
                    request.method = .GET
                    request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
                    request.headers.add(name: "Accept", value: "application/x-ndjson")

                    let response = try await self.httpClient.execute(
                        request,
                        timeout: .seconds(Int64(self.configuration.timeouts.download))
                    )

                    if response.status.code >= 400 {
                        continuation.finish(throwing: StreamingError.serverError(
                            Int(response.status.code),
                            response.status.reasonPhrase
                        ))
                        return
                    }

                    var buffer = ""
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy

                    for try await chunk in response.body {
                        let data = Data(buffer: chunk)
                        guard let text = String(data: data, encoding: .utf8) else { continue }

                        buffer += text

                        // Parse complete lines from buffer
                        while let lineEnd = buffer.firstIndex(of: "\n") {
                            let line = String(buffer[..<lineEnd])
                            buffer = String(buffer[buffer.index(after: lineEnd)...])

                            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                            guard !trimmedLine.isEmpty else { continue }

                            if let jsonData = trimmedLine.data(using: .utf8) {
                                do {
                                    let object = try decoder.decode(T.self, from: jsonData)
                                    continuation.yield(object)
                                } catch {
                                    // Skip malformed JSON lines
                                    continue
                                }
                            }
                        }
                    }

                    // Parse any remaining line in buffer
                    let trimmedBuffer = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedBuffer.isEmpty, let jsonData = trimmedBuffer.data(using: .utf8) {
                        if let object = try? decoder.decode(T.self, from: jsonData) {
                            continuation.yield(object)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Long Polling

/// Helper for long-polling operations.
///
/// Long-polling is useful for waiting on operation completion or
/// watching for resource changes.
public actor LongPollingClient {
    private let authClient: GoogleCloudAuthClient
    private let httpClient: HTTPClient
    private let configuration: GoogleCloudConfiguration

    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        configuration: GoogleCloudConfiguration = .default
    ) {
        self.authClient = authClient
        self.httpClient = httpClient
        self.configuration = configuration
    }

    /// Poll an operation until it completes or times out.
    public func pollOperation<T: Decodable & Sendable>(
        url: String,
        isDone: @Sendable (T) -> Bool,
        timeout: TimeInterval? = nil,
        pollInterval: TimeInterval? = nil
    ) async throws -> T {
        let effectiveTimeout = timeout ?? configuration.operationPolling.timeout
        let effectivePollInterval = pollInterval ?? configuration.operationPolling.pollInterval
        let startTime = Date()

        var attempt = 0

        while true {
            // Check timeout
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= effectiveTimeout {
                throw StreamingError.timeout
            }

            // Fetch current state
            let token = try await authClient.getAccessToken()

            var request = HTTPClientRequest(url: url)
            request.method = .GET
            request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")

            let response = try await httpClient.execute(
                request,
                timeout: .seconds(Int64(configuration.timeouts.request))
            )

            guard response.status.code >= 200 && response.status.code < 300 else {
                throw StreamingError.serverError(
                    Int(response.status.code),
                    response.status.reasonPhrase
                )
            }

            let body = try await response.body.collect(upTo: 10 * 1024 * 1024)
            let data = Data(buffer: body)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
            let result = try decoder.decode(T.self, from: data)

            if isDone(result) {
                return result
            }

            // Wait before next poll
            let interval = configuration.operationPolling.interval(for: attempt)
            let effectiveInterval = min(interval, effectivePollInterval)
            try await Task.sleep(nanoseconds: UInt64(effectiveInterval * 1_000_000_000))
            attempt += 1
        }
    }

    /// Watch a resource for changes using long-polling.
    public func watch<T: Decodable & Sendable & Equatable>(
        url: String,
        type: T.Type,
        onChange: @Sendable (T, T?) async -> Bool
    ) async throws {
        var lastValue: T?
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy

        while true {
            let token = try await authClient.getAccessToken()

            var request = HTTPClientRequest(url: url)
            request.method = .GET
            request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")

            let response = try await httpClient.execute(
                request,
                timeout: .seconds(Int64(configuration.timeouts.request))
            )

            guard response.status.code >= 200 && response.status.code < 300 else {
                throw StreamingError.serverError(
                    Int(response.status.code),
                    response.status.reasonPhrase
                )
            }

            let body = try await response.body.collect(upTo: 10 * 1024 * 1024)
            let data = Data(buffer: body)
            let currentValue = try decoder.decode(T.self, from: data)

            // Check if value changed
            if lastValue == nil || currentValue != lastValue {
                let shouldContinue = await onChange(currentValue, lastValue)
                if !shouldContinue {
                    return
                }
                lastValue = currentValue
            }

            // Wait before next poll
            let interval = configuration.operationPolling.pollInterval
            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
    }
}

// MARK: - Streaming Upload

/// Helper for streaming uploads to Google Cloud Storage.
public actor StreamingUploader {
    private let authClient: GoogleCloudAuthClient
    private let httpClient: HTTPClient
    private let configuration: GoogleCloudConfiguration

    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        configuration: GoogleCloudConfiguration = .default
    ) {
        self.authClient = authClient
        self.httpClient = httpClient
        self.configuration = configuration
    }

    /// Start a resumable upload session.
    ///
    /// This returns a session URL that can be used to upload data in chunks.
    public func startResumableUpload(
        bucket: String,
        objectName: String,
        contentType: String,
        totalSize: Int?
    ) async throws -> String {
        let token = try await authClient.getAccessToken()
        let encodedName = objectName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? objectName

        var url = "https://storage.googleapis.com/upload/storage/v1/b/\(bucket)/o"
        url += "?uploadType=resumable&name=\(encodedName)"

        var request = HTTPClientRequest(url: url)
        request.method = .POST
        request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
        request.headers.add(name: "Content-Type", value: "application/json; charset=UTF-8")
        request.headers.add(name: "X-Upload-Content-Type", value: contentType)

        if let totalSize = totalSize {
            request.headers.add(name: "X-Upload-Content-Length", value: String(totalSize))
        }

        // Empty body for initial request
        request.body = .bytes(.init(data: "{}".data(using: .utf8)!))

        let response = try await httpClient.execute(
            request,
            timeout: .seconds(Int64(configuration.timeouts.request))
        )

        guard response.status.code == 200 else {
            throw StreamingError.serverError(
                Int(response.status.code),
                response.status.reasonPhrase
            )
        }

        guard let sessionURL = response.headers.first(name: "Location") else {
            throw StreamingError.invalidData("No session URL returned")
        }

        return sessionURL
    }

    /// Upload a chunk of data to a resumable upload session.
    public func uploadChunk(
        sessionURL: String,
        data: Data,
        offset: Int,
        totalSize: Int,
        isLast: Bool
    ) async throws -> StorageObject? {
        let token = try await authClient.getAccessToken()
        let endByte = offset + data.count - 1
        let contentRange: String

        if isLast {
            contentRange = "bytes \(offset)-\(endByte)/\(totalSize)"
        } else {
            contentRange = "bytes \(offset)-\(endByte)/*"
        }

        var request = HTTPClientRequest(url: sessionURL)
        request.method = .PUT
        request.headers.add(name: "Authorization", value: "\(token.tokenType) \(token.token)")
        request.headers.add(name: "Content-Length", value: String(data.count))
        request.headers.add(name: "Content-Range", value: contentRange)
        request.body = .bytes(.init(data: data))

        let response = try await httpClient.execute(
            request,
            timeout: .seconds(Int64(configuration.timeouts.upload))
        )

        if response.status.code == 200 || response.status.code == 201 {
            // Upload complete
            let body = try await response.body.collect(upTo: 1024 * 1024)
            let responseData = Data(buffer: body)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
            return try decoder.decode(StorageObject.self, from: responseData)
        } else if response.status.code == 308 {
            // Chunk accepted, more to come
            return nil
        } else {
            throw StreamingError.serverError(
                Int(response.status.code),
                response.status.reasonPhrase
            )
        }
    }

    /// Upload data using streaming with automatic chunking.
    public func uploadStreaming(
        bucket: String,
        objectName: String,
        data: AsyncThrowingStream<Data, Error>,
        contentType: String,
        chunkSize: Int = 256 * 1024 // 256KB default chunk size
    ) async throws -> StorageObject {
        // Start resumable upload (total size unknown)
        let sessionURL = try await startResumableUpload(
            bucket: bucket,
            objectName: objectName,
            contentType: contentType,
            totalSize: nil
        )

        var buffer = Data()
        var offset = 0
        var totalSize = 0
        var lastResult: StorageObject?

        for try await chunk in data {
            buffer.append(chunk)
            totalSize += chunk.count

            // Upload complete chunks
            while buffer.count >= chunkSize {
                let chunkData = buffer.prefix(chunkSize)
                buffer = Data(buffer.dropFirst(chunkSize))

                lastResult = try await uploadChunk(
                    sessionURL: sessionURL,
                    data: Data(chunkData),
                    offset: offset,
                    totalSize: totalSize,
                    isLast: false
                )
                offset += chunkSize
            }
        }

        // Upload remaining data
        if !buffer.isEmpty || offset == 0 {
            lastResult = try await uploadChunk(
                sessionURL: sessionURL,
                data: buffer,
                offset: offset,
                totalSize: totalSize,
                isLast: true
            )
        }

        guard let result = lastResult else {
            throw StreamingError.invalidData("Upload did not return object metadata")
        }

        return result
    }
}

// MARK: - Async Sequence Extensions

extension AsyncThrowingStream where Element == StreamChunk {
    /// Collect all chunks into a single Data object.
    public func collect() async throws -> Data {
        var result = Data()
        for try await chunk in self {
            result.append(chunk.data)
        }
        return result
    }
}

extension AsyncThrowingStream where Element == ServerSentEvent {
    /// Filter events by type.
    public func filter(eventType: String) -> AsyncThrowingFilterSequence<Self> {
        self.filter { $0.event == eventType }
    }
}
