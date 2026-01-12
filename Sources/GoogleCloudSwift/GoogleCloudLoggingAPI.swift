//
//  GoogleCloudLoggingAPI.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import AsyncHTTPClient
import Foundation
import NIOCore

/// REST API client for Google Cloud Logging.
///
/// Provides methods for reading and writing log entries, managing log sinks,
/// exclusions, buckets, and metrics via the REST API v2.
///
/// ## Example Usage
/// ```swift
/// let loggingAPI = await GoogleCloudLoggingAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // Write log entries
/// try await loggingAPI.writeLogEntries(
///     logName: "my-app",
///     entries: [
///         LogEntry(severity: .info, textPayload: "Application started")
///     ]
/// )
///
/// // Read log entries
/// let entries = try await loggingAPI.listLogEntries(
///     filter: "severity >= ERROR"
/// )
/// ```
public actor GoogleCloudLoggingAPI {
    private let client: GoogleCloudHTTPClient
    private let _projectId: String

    /// The Google Cloud project ID this client operates on.
    public var projectId: String { _projectId }

    private static let baseURL = "https://logging.googleapis.com"

    /// Initialize the Cloud Logging API client.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - projectId: The Google Cloud project ID.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds.
    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        projectId: String,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) {
        self._projectId = projectId
        self.client = GoogleCloudHTTPClient(
            authClient: authClient,
            httpClient: httpClient,
            baseURL: Self.baseURL,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    /// Create a Cloud Logging API client, inferring project ID from auth credentials.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds.
    /// - Returns: A configured Cloud Logging API client.
    public static func create(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) async -> GoogleCloudLoggingAPI {
        let projectId = await authClient.projectId
        return GoogleCloudLoggingAPI(
            authClient: authClient,
            httpClient: httpClient,
            projectId: projectId,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    // MARK: - Log Entries

    /// Write log entries to Cloud Logging.
    /// - Parameters:
    ///   - logName: The log name to write to.
    ///   - entries: The log entries to write.
    ///   - resource: The monitored resource (defaults to global).
    ///   - labels: Default labels for all entries.
    ///   - partialSuccess: If true, allows partial success.
    ///   - dryRun: If true, validates without writing.
    /// - Returns: Any entries that failed to write.
    @discardableResult
    public func writeLogEntries(
        logName: String,
        entries: [LoggingLogEntry],
        resource: LoggingMonitoredResource? = nil,
        labels: [String: String]? = nil,
        partialSuccess: Bool = true,
        dryRun: Bool = false
    ) async throws -> LoggingWriteResponse {
        let fullLogName = "projects/\(_projectId)/logs/\(logName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? logName)"

        let request = LoggingWriteRequest(
            logName: fullLogName,
            resource: resource ?? LoggingMonitoredResource(type: "global"),
            labels: labels,
            entries: entries,
            partialSuccess: partialSuccess,
            dryRun: dryRun
        )

        let response: GoogleCloudAPIResponse<LoggingWriteResponse> = try await client.post(
            path: "/v2/entries:write",
            body: request
        )
        return response.data
    }

    /// List log entries from Cloud Logging.
    /// - Parameters:
    ///   - filter: A filter expression (see Cloud Logging filter syntax).
    ///   - orderBy: Sort order ("timestamp asc" or "timestamp desc").
    ///   - pageSize: Maximum entries to return.
    ///   - pageToken: Token for pagination.
    ///   - resourceNames: Resources to query (defaults to project).
    /// - Returns: A list of log entries.
    public func listLogEntries(
        filter: String? = nil,
        orderBy: String? = nil,
        pageSize: Int? = nil,
        pageToken: String? = nil,
        resourceNames: [String]? = nil
    ) async throws -> LoggingEntryListResponse {
        let request = LoggingListEntriesRequest(
            resourceNames: resourceNames ?? ["projects/\(_projectId)"],
            filter: filter,
            orderBy: orderBy,
            pageSize: pageSize,
            pageToken: pageToken
        )

        let response: GoogleCloudAPIResponse<LoggingEntryListResponse> = try await client.post(
            path: "/v2/entries:list",
            body: request
        )
        return response.data
    }

    /// Get a pagination helper for listing all log entries.
    /// - Parameters:
    ///   - filter: A filter expression.
    ///   - orderBy: Sort order.
    ///   - pageSize: Maximum entries per page.
    /// - Returns: A pagination helper.
    public func listAllLogEntries(
        filter: String? = nil,
        orderBy: String? = nil,
        pageSize: Int? = nil
    ) -> PaginationHelper<LoggingEntry> {
        PaginationHelper { pageToken in
            let response = try await self.listLogEntries(
                filter: filter,
                orderBy: orderBy,
                pageSize: pageSize,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.entries,
                nextPageToken: response.nextPageToken
            )
        }
    }

    // MARK: - Logs

    /// List logs in the project.
    /// - Parameters:
    ///   - pageSize: Maximum logs to return.
    ///   - pageToken: Token for pagination.
    ///   - resourceNames: Additional resource names to query.
    /// - Returns: A list of log names.
    public func listLogs(
        pageSize: Int? = nil,
        pageToken: String? = nil,
        resourceNames: [String]? = nil
    ) async throws -> LoggingLogListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }
        if let resourceNames = resourceNames {
            params["resourceNames"] = resourceNames.joined(separator: ",")
        }

        let response: GoogleCloudAPIResponse<LoggingLogListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/logs",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Delete a log and all its entries.
    /// - Parameter logName: The log name to delete.
    public func deleteLog(logName: String) async throws {
        let encodedName = logName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? logName
        try await client.deleteNoContent(
            path: "/v2/projects/\(_projectId)/logs/\(encodedName)"
        )
    }

    // MARK: - Log Sinks

    /// List all log sinks in the project.
    /// - Parameters:
    ///   - pageSize: Maximum sinks to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of sinks.
    public func listSinks(
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> LoggingSinkListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<LoggingSinkListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/sinks",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a pagination helper for listing all sinks.
    /// - Parameter pageSize: Maximum sinks per page.
    /// - Returns: A pagination helper.
    public func listAllSinks(
        pageSize: Int? = nil
    ) -> PaginationHelper<LoggingSink> {
        PaginationHelper { pageToken in
            let response = try await self.listSinks(
                pageSize: pageSize,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.sinks,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get a log sink.
    /// - Parameter sinkName: The sink name.
    /// - Returns: The sink details.
    public func getSink(sinkName: String) async throws -> LoggingSink {
        let response: GoogleCloudAPIResponse<LoggingSink> = try await client.get(
            path: "/v2/projects/\(_projectId)/sinks/\(sinkName)"
        )
        return response.data
    }

    /// Create a log sink.
    /// - Parameters:
    ///   - sink: The sink configuration.
    ///   - uniqueWriterIdentity: If true, creates a unique service account for the sink.
    /// - Returns: The created sink.
    public func createSink(
        sink: LoggingSinkRequest,
        uniqueWriterIdentity: Bool = true
    ) async throws -> LoggingSink {
        let params = ["uniqueWriterIdentity": String(uniqueWriterIdentity)]

        let response: GoogleCloudAPIResponse<LoggingSink> = try await client.post(
            path: "/v2/projects/\(_projectId)/sinks",
            body: sink,
            queryParameters: params
        )
        return response.data
    }

    /// Update a log sink.
    /// - Parameters:
    ///   - sinkName: The sink name.
    ///   - sink: The updated sink configuration.
    ///   - uniqueWriterIdentity: If true, maintains a unique writer identity.
    ///   - updateMask: Fields to update (optional).
    /// - Returns: The updated sink.
    public func updateSink(
        sinkName: String,
        sink: LoggingSinkRequest,
        uniqueWriterIdentity: Bool = true,
        updateMask: String? = nil
    ) async throws -> LoggingSink {
        var params = ["uniqueWriterIdentity": String(uniqueWriterIdentity)]
        if let updateMask = updateMask {
            params["updateMask"] = updateMask
        }

        let response: GoogleCloudAPIResponse<LoggingSink> = try await client.put(
            path: "/v2/projects/\(_projectId)/sinks/\(sinkName)",
            body: sink,
            queryParameters: params
        )
        return response.data
    }

    /// Delete a log sink.
    /// - Parameter sinkName: The sink name.
    public func deleteSink(sinkName: String) async throws {
        try await client.deleteNoContent(
            path: "/v2/projects/\(_projectId)/sinks/\(sinkName)"
        )
    }

    // MARK: - Log Exclusions

    /// List all log exclusions in the project.
    /// - Parameters:
    ///   - pageSize: Maximum exclusions to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of exclusions.
    public func listExclusions(
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> LoggingExclusionListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<LoggingExclusionListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/exclusions",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a log exclusion.
    /// - Parameter exclusionName: The exclusion name.
    /// - Returns: The exclusion details.
    public func getExclusion(exclusionName: String) async throws -> LoggingExclusion {
        let response: GoogleCloudAPIResponse<LoggingExclusion> = try await client.get(
            path: "/v2/projects/\(_projectId)/exclusions/\(exclusionName)"
        )
        return response.data
    }

    /// Create a log exclusion.
    /// - Parameter exclusion: The exclusion configuration.
    /// - Returns: The created exclusion.
    public func createExclusion(exclusion: LoggingExclusionRequest) async throws -> LoggingExclusion {
        let response: GoogleCloudAPIResponse<LoggingExclusion> = try await client.post(
            path: "/v2/projects/\(_projectId)/exclusions",
            body: exclusion
        )
        return response.data
    }

    /// Update a log exclusion.
    /// - Parameters:
    ///   - exclusionName: The exclusion name.
    ///   - exclusion: The updated exclusion configuration.
    ///   - updateMask: Fields to update.
    /// - Returns: The updated exclusion.
    public func updateExclusion(
        exclusionName: String,
        exclusion: LoggingExclusionRequest,
        updateMask: String
    ) async throws -> LoggingExclusion {
        let params = ["updateMask": updateMask]

        let response: GoogleCloudAPIResponse<LoggingExclusion> = try await client.patch(
            path: "/v2/projects/\(_projectId)/exclusions/\(exclusionName)",
            body: exclusion,
            queryParameters: params
        )
        return response.data
    }

    /// Delete a log exclusion.
    /// - Parameter exclusionName: The exclusion name.
    public func deleteExclusion(exclusionName: String) async throws {
        try await client.deleteNoContent(
            path: "/v2/projects/\(_projectId)/exclusions/\(exclusionName)"
        )
    }

    // MARK: - Log-Based Metrics

    /// List all log-based metrics in the project.
    /// - Parameters:
    ///   - pageSize: Maximum metrics to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of metrics.
    public func listMetrics(
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> LoggingMetricListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<LoggingMetricListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/metrics",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a log-based metric.
    /// - Parameter metricName: The metric name.
    /// - Returns: The metric details.
    public func getMetric(metricName: String) async throws -> LoggingMetric {
        let response: GoogleCloudAPIResponse<LoggingMetric> = try await client.get(
            path: "/v2/projects/\(_projectId)/metrics/\(metricName)"
        )
        return response.data
    }

    /// Create a log-based metric.
    /// - Parameter metric: The metric configuration.
    /// - Returns: The created metric.
    public func createMetric(metric: LoggingMetricRequest) async throws -> LoggingMetric {
        let response: GoogleCloudAPIResponse<LoggingMetric> = try await client.post(
            path: "/v2/projects/\(_projectId)/metrics",
            body: metric
        )
        return response.data
    }

    /// Update a log-based metric.
    /// - Parameters:
    ///   - metricName: The metric name.
    ///   - metric: The updated metric configuration.
    /// - Returns: The updated metric.
    public func updateMetric(
        metricName: String,
        metric: LoggingMetricRequest
    ) async throws -> LoggingMetric {
        let response: GoogleCloudAPIResponse<LoggingMetric> = try await client.put(
            path: "/v2/projects/\(_projectId)/metrics/\(metricName)",
            body: metric
        )
        return response.data
    }

    /// Delete a log-based metric.
    /// - Parameter metricName: The metric name.
    public func deleteMetric(metricName: String) async throws {
        try await client.deleteNoContent(
            path: "/v2/projects/\(_projectId)/metrics/\(metricName)"
        )
    }

    // MARK: - Log Buckets

    /// List all log buckets in a location.
    /// - Parameters:
    ///   - location: The location (region) or "-" for all locations.
    ///   - pageSize: Maximum buckets to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of buckets.
    public func listBuckets(
        location: String = "-",
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> LoggingBucketListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<LoggingBucketListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a log bucket.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    /// - Returns: The bucket details.
    public func getBucket(location: String, bucketId: String) async throws -> LoggingBucket {
        let response: GoogleCloudAPIResponse<LoggingBucket> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)"
        )
        return response.data
    }

    /// Create a log bucket.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - bucket: The bucket configuration.
    /// - Returns: The created bucket.
    public func createBucket(
        location: String,
        bucketId: String,
        bucket: LoggingBucketRequest
    ) async throws -> LoggingBucket {
        let params = ["bucketId": bucketId]

        let response: GoogleCloudAPIResponse<LoggingBucket> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets",
            body: bucket,
            queryParameters: params
        )
        return response.data
    }

    /// Update a log bucket.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - bucket: The updated bucket configuration.
    ///   - updateMask: Fields to update.
    /// - Returns: The updated bucket.
    public func updateBucket(
        location: String,
        bucketId: String,
        bucket: LoggingBucketRequest,
        updateMask: String
    ) async throws -> LoggingBucket {
        let params = ["updateMask": updateMask]

        let response: GoogleCloudAPIResponse<LoggingBucket> = try await client.patch(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)",
            body: bucket,
            queryParameters: params
        )
        return response.data
    }

    /// Delete a log bucket.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    public func deleteBucket(location: String, bucketId: String) async throws {
        try await client.deleteNoContent(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)"
        )
    }

    /// Undelete a log bucket (within grace period).
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    public func undeleteBucket(location: String, bucketId: String) async throws {
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId):undelete",
            body: EmptyBody()
        )
    }

    // MARK: - Log Views

    /// List all views in a log bucket.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - pageSize: Maximum views to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of views.
    public func listViews(
        location: String,
        bucketId: String,
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> LoggingViewListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<LoggingViewListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)/views",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a log view.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - viewId: The view ID.
    /// - Returns: The view details.
    public func getView(
        location: String,
        bucketId: String,
        viewId: String
    ) async throws -> LoggingView {
        let response: GoogleCloudAPIResponse<LoggingView> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)/views/\(viewId)"
        )
        return response.data
    }

    /// Create a log view.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - viewId: The view ID.
    ///   - view: The view configuration.
    /// - Returns: The created view.
    public func createView(
        location: String,
        bucketId: String,
        viewId: String,
        view: LoggingViewRequest
    ) async throws -> LoggingView {
        let params = ["viewId": viewId]

        let response: GoogleCloudAPIResponse<LoggingView> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)/views",
            body: view,
            queryParameters: params
        )
        return response.data
    }

    /// Update a log view.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - viewId: The view ID.
    ///   - view: The updated view configuration.
    ///   - updateMask: Fields to update.
    /// - Returns: The updated view.
    public func updateView(
        location: String,
        bucketId: String,
        viewId: String,
        view: LoggingViewRequest,
        updateMask: String
    ) async throws -> LoggingView {
        let params = ["updateMask": updateMask]

        let response: GoogleCloudAPIResponse<LoggingView> = try await client.patch(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)/views/\(viewId)",
            body: view,
            queryParameters: params
        )
        return response.data
    }

    /// Delete a log view.
    /// - Parameters:
    ///   - location: The location.
    ///   - bucketId: The bucket ID.
    ///   - viewId: The view ID.
    public func deleteView(
        location: String,
        bucketId: String,
        viewId: String
    ) async throws {
        try await client.deleteNoContent(
            path: "/v2/projects/\(_projectId)/locations/\(location)/buckets/\(bucketId)/views/\(viewId)"
        )
    }
}

// MARK: - Request Types

/// Request to write log entries.
struct LoggingWriteRequest: Encodable, Sendable {
    let logName: String
    let resource: LoggingMonitoredResource
    let labels: [String: String]?
    let entries: [LoggingLogEntry]
    let partialSuccess: Bool
    let dryRun: Bool
}

/// Request to list log entries.
struct LoggingListEntriesRequest: Encodable, Sendable {
    let resourceNames: [String]
    let filter: String?
    let orderBy: String?
    let pageSize: Int?
    let pageToken: String?
}

/// Log entry for writing.
public struct LoggingLogEntry: Encodable, Sendable {
    public let severity: String?
    public let textPayload: String?
    public let jsonPayload: [String: AnyCodable]?
    public let labels: [String: String]?
    public let trace: String?
    public let spanId: String?
    public let traceSampled: Bool?
    public let sourceLocation: LoggingSourceLocation?
    public let httpRequest: LoggingHTTPRequest?

    public init(
        severity: LoggingEntrySeverity = .default,
        textPayload: String? = nil,
        jsonPayload: [String: Any]? = nil,
        labels: [String: String]? = nil,
        trace: String? = nil,
        spanId: String? = nil,
        traceSampled: Bool? = nil,
        sourceLocation: LoggingSourceLocation? = nil,
        httpRequest: LoggingHTTPRequest? = nil
    ) {
        self.severity = severity.rawValue
        self.textPayload = textPayload
        self.jsonPayload = jsonPayload?.mapValues { AnyCodable($0) }
        self.labels = labels
        self.trace = trace
        self.spanId = spanId
        self.traceSampled = traceSampled
        self.sourceLocation = sourceLocation
        self.httpRequest = httpRequest
    }

    /// Create a text log entry.
    public static func text(
        _ message: String,
        severity: LoggingEntrySeverity = .default,
        labels: [String: String]? = nil
    ) -> LoggingLogEntry {
        LoggingLogEntry(severity: severity, textPayload: message, labels: labels)
    }

    /// Create a JSON log entry.
    public static func json(
        _ payload: [String: Any],
        severity: LoggingEntrySeverity = .default,
        labels: [String: String]? = nil
    ) -> LoggingLogEntry {
        LoggingLogEntry(severity: severity, jsonPayload: payload, labels: labels)
    }
}

/// Source location for a log entry.
public struct LoggingSourceLocation: Codable, Sendable {
    public let file: String?
    public let line: String?
    public let function: String?

    public init(file: String? = nil, line: String? = nil, function: String? = nil) {
        self.file = file
        self.line = line
        self.function = function
    }
}

/// HTTP request information for a log entry.
public struct LoggingHTTPRequest: Codable, Sendable {
    public let requestMethod: String?
    public let requestUrl: String?
    public let requestSize: String?
    public let status: Int?
    public let responseSize: String?
    public let userAgent: String?
    public let remoteIp: String?
    public let serverIp: String?
    public let referer: String?
    public let latency: String?
    public let cacheLookup: Bool?
    public let cacheHit: Bool?
    public let cacheValidatedWithOriginServer: Bool?
    public let cacheFillBytes: String?
    public let protocol_: String?

    enum CodingKeys: String, CodingKey {
        case requestMethod, requestUrl, requestSize, status, responseSize
        case userAgent, remoteIp, serverIp, referer, latency
        case cacheLookup, cacheHit, cacheValidatedWithOriginServer, cacheFillBytes
        case protocol_ = "protocol"
    }

    public init(
        requestMethod: String? = nil,
        requestUrl: String? = nil,
        requestSize: String? = nil,
        status: Int? = nil,
        responseSize: String? = nil,
        userAgent: String? = nil,
        remoteIp: String? = nil,
        serverIp: String? = nil,
        referer: String? = nil,
        latency: String? = nil,
        cacheLookup: Bool? = nil,
        cacheHit: Bool? = nil,
        cacheValidatedWithOriginServer: Bool? = nil,
        cacheFillBytes: String? = nil,
        protocol_: String? = nil
    ) {
        self.requestMethod = requestMethod
        self.requestUrl = requestUrl
        self.requestSize = requestSize
        self.status = status
        self.responseSize = responseSize
        self.userAgent = userAgent
        self.remoteIp = remoteIp
        self.serverIp = serverIp
        self.referer = referer
        self.latency = latency
        self.cacheLookup = cacheLookup
        self.cacheHit = cacheHit
        self.cacheValidatedWithOriginServer = cacheValidatedWithOriginServer
        self.cacheFillBytes = cacheFillBytes
        self.protocol_ = protocol_
    }
}

/// Monitored resource for log entries.
public struct LoggingMonitoredResource: Codable, Sendable {
    public let type: String
    public let labels: [String: String]?

    public init(type: String, labels: [String: String]? = nil) {
        self.type = type
        self.labels = labels
    }

    /// Global resource.
    public static let global = LoggingMonitoredResource(type: "global")

    /// GCE instance resource.
    public static func gceInstance(projectId: String, instanceId: String, zone: String) -> LoggingMonitoredResource {
        LoggingMonitoredResource(
            type: "gce_instance",
            labels: ["project_id": projectId, "instance_id": instanceId, "zone": zone]
        )
    }

    /// Cloud Run revision resource.
    public static func cloudRunRevision(
        projectId: String,
        serviceName: String,
        revisionName: String,
        location: String
    ) -> LoggingMonitoredResource {
        LoggingMonitoredResource(
            type: "cloud_run_revision",
            labels: [
                "project_id": projectId,
                "service_name": serviceName,
                "revision_name": revisionName,
                "location": location
            ]
        )
    }
}

/// Request to create a log sink.
public struct LoggingSinkRequest: Encodable, Sendable {
    public let name: String
    public let destination: String
    public let filter: String?
    public let description: String?
    public let disabled: Bool?
    public let exclusions: [LoggingSinkExclusion]?
    public let outputVersionFormat: String?
    public let bigqueryOptions: LoggingBigQueryOptions?

    public init(
        name: String,
        destination: String,
        filter: String? = nil,
        description: String? = nil,
        disabled: Bool? = nil,
        exclusions: [LoggingSinkExclusion]? = nil,
        outputVersionFormat: String? = nil,
        bigqueryOptions: LoggingBigQueryOptions? = nil
    ) {
        self.name = name
        self.destination = destination
        self.filter = filter
        self.description = description
        self.disabled = disabled
        self.exclusions = exclusions
        self.outputVersionFormat = outputVersionFormat
        self.bigqueryOptions = bigqueryOptions
    }

    /// Create a sink to Cloud Storage.
    public static func toStorage(
        name: String,
        bucketName: String,
        filter: String? = nil
    ) -> LoggingSinkRequest {
        LoggingSinkRequest(
            name: name,
            destination: "storage.googleapis.com/\(bucketName)",
            filter: filter
        )
    }

    /// Create a sink to BigQuery.
    public static func toBigQuery(
        name: String,
        projectId: String,
        datasetId: String,
        filter: String? = nil,
        usePartitionedTables: Bool = true
    ) -> LoggingSinkRequest {
        LoggingSinkRequest(
            name: name,
            destination: "bigquery.googleapis.com/projects/\(projectId)/datasets/\(datasetId)",
            filter: filter,
            bigqueryOptions: LoggingBigQueryOptions(usePartitionedTables: usePartitionedTables)
        )
    }

    /// Create a sink to Pub/Sub.
    public static func toPubSub(
        name: String,
        projectId: String,
        topicId: String,
        filter: String? = nil
    ) -> LoggingSinkRequest {
        LoggingSinkRequest(
            name: name,
            destination: "pubsub.googleapis.com/projects/\(projectId)/topics/\(topicId)",
            filter: filter
        )
    }
}

/// Sink exclusion.
public struct LoggingSinkExclusion: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let filter: String?
    public let disabled: Bool?

    public init(name: String? = nil, description: String? = nil, filter: String? = nil, disabled: Bool? = nil) {
        self.name = name
        self.description = description
        self.filter = filter
        self.disabled = disabled
    }
}

/// BigQuery options for sinks.
public struct LoggingBigQueryOptions: Codable, Sendable {
    public let usePartitionedTables: Bool?
    public let usesTimestampColumnPartitioning: Bool?

    public init(usePartitionedTables: Bool? = nil, usesTimestampColumnPartitioning: Bool? = nil) {
        self.usePartitionedTables = usePartitionedTables
        self.usesTimestampColumnPartitioning = usesTimestampColumnPartitioning
    }
}

/// Request to create a log exclusion.
public struct LoggingExclusionRequest: Encodable, Sendable {
    public let name: String
    public let filter: String
    public let description: String?
    public let disabled: Bool?

    public init(name: String, filter: String, description: String? = nil, disabled: Bool? = nil) {
        self.name = name
        self.filter = filter
        self.description = description
        self.disabled = disabled
    }
}

/// Request to create a log-based metric.
public struct LoggingMetricRequest: Encodable, Sendable {
    public let name: String
    public let filter: String
    public let description: String?
    public let disabled: Bool?
    public let metricDescriptor: LoggingMetricDescriptor?
    public let valueExtractor: String?
    public let labelExtractors: [String: String]?
    public let bucketOptions: LoggingBucketOptions?

    public init(
        name: String,
        filter: String,
        description: String? = nil,
        disabled: Bool? = nil,
        metricDescriptor: LoggingMetricDescriptor? = nil,
        valueExtractor: String? = nil,
        labelExtractors: [String: String]? = nil,
        bucketOptions: LoggingBucketOptions? = nil
    ) {
        self.name = name
        self.filter = filter
        self.description = description
        self.disabled = disabled
        self.metricDescriptor = metricDescriptor
        self.valueExtractor = valueExtractor
        self.labelExtractors = labelExtractors
        self.bucketOptions = bucketOptions
    }

    /// Create a counter metric.
    public static func counter(name: String, filter: String, description: String? = nil) -> LoggingMetricRequest {
        LoggingMetricRequest(name: name, filter: filter, description: description)
    }
}

/// Metric descriptor for custom metrics.
public struct LoggingMetricDescriptor: Codable, Sendable {
    public let metricKind: String?
    public let valueType: String?
    public let unit: String?
    public let labels: [LoggingLabelDescriptor]?
    public let displayName: String?
    public let description: String?

    public init(
        metricKind: String? = nil,
        valueType: String? = nil,
        unit: String? = nil,
        labels: [LoggingLabelDescriptor]? = nil,
        displayName: String? = nil,
        description: String? = nil
    ) {
        self.metricKind = metricKind
        self.valueType = valueType
        self.unit = unit
        self.labels = labels
        self.displayName = displayName
        self.description = description
    }
}

/// Label descriptor for metrics.
public struct LoggingLabelDescriptor: Codable, Sendable {
    public let key: String?
    public let valueType: String?
    public let description: String?

    public init(key: String? = nil, valueType: String? = nil, description: String? = nil) {
        self.key = key
        self.valueType = valueType
        self.description = description
    }
}

/// Bucket options for distribution metrics.
public struct LoggingBucketOptions: Codable, Sendable {
    public let linearBuckets: LoggingLinearBuckets?
    public let exponentialBuckets: LoggingExponentialBuckets?
    public let explicitBuckets: LoggingExplicitBuckets?

    public init(
        linearBuckets: LoggingLinearBuckets? = nil,
        exponentialBuckets: LoggingExponentialBuckets? = nil,
        explicitBuckets: LoggingExplicitBuckets? = nil
    ) {
        self.linearBuckets = linearBuckets
        self.exponentialBuckets = exponentialBuckets
        self.explicitBuckets = explicitBuckets
    }
}

/// Linear bucket configuration.
public struct LoggingLinearBuckets: Codable, Sendable {
    public let numFiniteBuckets: Int?
    public let width: Double?
    public let offset: Double?

    public init(numFiniteBuckets: Int? = nil, width: Double? = nil, offset: Double? = nil) {
        self.numFiniteBuckets = numFiniteBuckets
        self.width = width
        self.offset = offset
    }
}

/// Exponential bucket configuration.
public struct LoggingExponentialBuckets: Codable, Sendable {
    public let numFiniteBuckets: Int?
    public let growthFactor: Double?
    public let scale: Double?

    public init(numFiniteBuckets: Int? = nil, growthFactor: Double? = nil, scale: Double? = nil) {
        self.numFiniteBuckets = numFiniteBuckets
        self.growthFactor = growthFactor
        self.scale = scale
    }
}

/// Explicit bucket configuration.
public struct LoggingExplicitBuckets: Codable, Sendable {
    public let bounds: [Double]?

    public init(bounds: [Double]? = nil) {
        self.bounds = bounds
    }
}

/// Request to create a log bucket.
public struct LoggingBucketRequest: Encodable, Sendable {
    public let description: String?
    public let retentionDays: Int?
    public let locked: Bool?
    public let analyticsEnabled: Bool?
    public let restrictedFields: [String]?
    public let indexConfigs: [LoggingIndexConfig]?

    public init(
        description: String? = nil,
        retentionDays: Int? = nil,
        locked: Bool? = nil,
        analyticsEnabled: Bool? = nil,
        restrictedFields: [String]? = nil,
        indexConfigs: [LoggingIndexConfig]? = nil
    ) {
        self.description = description
        self.retentionDays = retentionDays
        self.locked = locked
        self.analyticsEnabled = analyticsEnabled
        self.restrictedFields = restrictedFields
        self.indexConfigs = indexConfigs
    }
}

/// Index configuration for log buckets.
public struct LoggingIndexConfig: Codable, Sendable {
    public let fieldPath: String?
    public let type: String?
    public let createTime: Date?

    public init(fieldPath: String? = nil, type: String? = nil, createTime: Date? = nil) {
        self.fieldPath = fieldPath
        self.type = type
        self.createTime = createTime
    }
}

/// Request to create a log view.
public struct LoggingViewRequest: Encodable, Sendable {
    public let description: String?
    public let filter: String?

    public init(description: String? = nil, filter: String? = nil) {
        self.description = description
        self.filter = filter
    }
}

// MARK: - Response Types

/// Write log entries response.
public struct LoggingWriteResponse: Codable, Sendable {
    // Empty response on success, or contains partial failure info
}

/// List log entries response.
public struct LoggingEntryListResponse: Codable, Sendable {
    public let entries: [LoggingEntry]?
    public let nextPageToken: String?
}

/// Log entry.
public struct LoggingEntry: Codable, Sendable {
    public let logName: String?
    public let resource: LoggingMonitoredResource?
    public let timestamp: Date?
    public let receiveTimestamp: Date?
    public let severity: String?
    public let insertId: String?
    public let httpRequest: LoggingHTTPRequest?
    public let labels: [String: String]?
    public let trace: String?
    public let spanId: String?
    public let traceSampled: Bool?
    public let sourceLocation: LoggingSourceLocation?
    public let textPayload: String?
    public let jsonPayload: [String: AnyCodable]?
    public let protoPayload: [String: AnyCodable]?

    /// Get the severity as an enum.
    public var severityLevel: LoggingEntrySeverity? {
        severity.flatMap { LoggingEntrySeverity(rawValue: $0) }
    }
}

/// List logs response.
public struct LoggingLogListResponse: Codable, Sendable {
    public let logNames: [String]?
    public let nextPageToken: String?
}

/// List sinks response.
public struct LoggingSinkListResponse: Codable, Sendable {
    public let sinks: [LoggingSink]?
    public let nextPageToken: String?
}

/// Log sink.
public struct LoggingSink: Codable, Sendable {
    public let name: String?
    public let destination: String?
    public let filter: String?
    public let description: String?
    public let disabled: Bool?
    public let exclusions: [LoggingSinkExclusion]?
    public let outputVersionFormat: String?
    public let writerIdentity: String?
    public let includeChildren: Bool?
    public let bigqueryOptions: LoggingBigQueryOptions?
    public let createTime: Date?
    public let updateTime: Date?
}

/// List exclusions response.
public struct LoggingExclusionListResponse: Codable, Sendable {
    public let exclusions: [LoggingExclusion]?
    public let nextPageToken: String?
}

/// Log exclusion.
public struct LoggingExclusion: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let filter: String?
    public let disabled: Bool?
    public let createTime: Date?
    public let updateTime: Date?
}

/// List metrics response.
public struct LoggingMetricListResponse: Codable, Sendable {
    public let metrics: [LoggingMetric]?
    public let nextPageToken: String?
}

/// Log-based metric.
public struct LoggingMetric: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let filter: String?
    public let disabled: Bool?
    public let metricDescriptor: LoggingMetricDescriptor?
    public let valueExtractor: String?
    public let labelExtractors: [String: String]?
    public let bucketOptions: LoggingBucketOptions?
    public let createTime: Date?
    public let updateTime: Date?
    public let version: String?
}

/// List buckets response.
public struct LoggingBucketListResponse: Codable, Sendable {
    public let buckets: [LoggingBucket]?
    public let nextPageToken: String?
}

/// Log bucket.
public struct LoggingBucket: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let createTime: Date?
    public let updateTime: Date?
    public let retentionDays: Int?
    public let locked: Bool?
    public let lifecycleState: String?
    public let analyticsEnabled: Bool?
    public let restrictedFields: [String]?
    public let indexConfigs: [LoggingIndexConfig]?
}

/// List views response.
public struct LoggingViewListResponse: Codable, Sendable {
    public let views: [LoggingView]?
    public let nextPageToken: String?
}

/// Log view.
public struct LoggingView: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let createTime: Date?
    public let updateTime: Date?
    public let filter: String?
}

// MARK: - Enums

/// Log entry severity levels.
public enum LoggingEntrySeverity: String, Codable, Sendable, CaseIterable {
    case `default` = "DEFAULT"
    case debug = "DEBUG"
    case info = "INFO"
    case notice = "NOTICE"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    case alert = "ALERT"
    case emergency = "EMERGENCY"

    /// Numeric severity value.
    public var numericValue: Int {
        switch self {
        case .default: return 0
        case .debug: return 100
        case .info: return 200
        case .notice: return 300
        case .warning: return 400
        case .error: return 500
        case .critical: return 600
        case .alert: return 700
        case .emergency: return 800
        }
    }
}

// MARK: - Filter Helpers

/// Helpers for building Cloud Logging filter expressions.
public enum LoggingFilter {
    /// Filter by severity.
    public static func severity(_ op: String, _ level: LoggingEntrySeverity) -> String {
        "severity \(op) \(level.rawValue)"
    }

    /// Filter for errors and above.
    public static let errors = "severity >= ERROR"

    /// Filter for warnings and above.
    public static let warnings = "severity >= WARNING"

    /// Filter by resource type.
    public static func resourceType(_ type: String) -> String {
        "resource.type = \"\(type)\""
    }

    /// Filter by label.
    public static func label(_ key: String, _ value: String) -> String {
        "labels.\(key) = \"\(value)\""
    }

    /// Filter by log name.
    public static func logName(_ name: String, projectId: String) -> String {
        "logName = \"projects/\(projectId)/logs/\(name)\""
    }

    /// Filter by text content.
    public static func textPayload(contains text: String) -> String {
        "textPayload : \"\(text)\""
    }

    /// Filter by JSON field.
    public static func jsonPayload(_ field: String, equals value: String) -> String {
        "jsonPayload.\(field) = \"\(value)\""
    }

    /// Filter by timestamp range.
    public static func timeRange(start: Date, end: Date? = nil) -> String {
        let formatter = ISO8601DateFormatter()
        var filter = "timestamp >= \"\(formatter.string(from: start))\""
        if let end = end {
            filter += " AND timestamp <= \"\(formatter.string(from: end))\""
        }
        return filter
    }

    /// Combine filters with AND.
    public static func and(_ filters: String...) -> String {
        filters.joined(separator: " AND ")
    }

    /// Combine filters with OR.
    public static func or(_ filters: String...) -> String {
        "(\(filters.joined(separator: " OR ")))"
    }
}
