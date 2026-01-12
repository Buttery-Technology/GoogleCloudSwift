//
//  GoogleCloudMetrics.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation

// MARK: - Metrics Types

/// Represents a single API request metric.
public struct APIRequestMetric: Sendable {
    /// The API service (e.g., "compute", "storage", "logging").
    public let service: String

    /// The operation name (e.g., "listInstances", "uploadObject").
    public let operation: String

    /// HTTP method used.
    public let method: String

    /// Request path (without query parameters).
    public let path: String

    /// HTTP status code of the response.
    public let statusCode: Int

    /// Duration of the request in seconds.
    public let duration: TimeInterval

    /// Size of the request body in bytes (if applicable).
    public let requestSize: Int?

    /// Size of the response body in bytes (if applicable).
    public let responseSize: Int?

    /// Whether the request was successful (2xx status code).
    public let success: Bool

    /// Error message if the request failed.
    public let errorMessage: String?

    /// Number of retry attempts.
    public let retryCount: Int

    /// Timestamp when the request started.
    public let timestamp: Date

    /// Custom labels for additional context.
    public let labels: [String: String]

    public init(
        service: String,
        operation: String,
        method: String,
        path: String,
        statusCode: Int,
        duration: TimeInterval,
        requestSize: Int? = nil,
        responseSize: Int? = nil,
        success: Bool,
        errorMessage: String? = nil,
        retryCount: Int = 0,
        timestamp: Date = Date(),
        labels: [String: String] = [:]
    ) {
        self.service = service
        self.operation = operation
        self.method = method
        self.path = path
        self.statusCode = statusCode
        self.duration = duration
        self.requestSize = requestSize
        self.responseSize = responseSize
        self.success = success
        self.errorMessage = errorMessage
        self.retryCount = retryCount
        self.timestamp = timestamp
        self.labels = labels
    }
}

/// Aggregated metrics for a time period.
public struct AggregatedMetrics: Sendable {
    /// Total number of requests.
    public let totalRequests: Int

    /// Number of successful requests.
    public let successfulRequests: Int

    /// Number of failed requests.
    public let failedRequests: Int

    /// Average request duration in seconds.
    public let averageDuration: TimeInterval

    /// 50th percentile (median) duration.
    public let p50Duration: TimeInterval

    /// 95th percentile duration.
    public let p95Duration: TimeInterval

    /// 99th percentile duration.
    public let p99Duration: TimeInterval

    /// Maximum duration.
    public let maxDuration: TimeInterval

    /// Minimum duration.
    public let minDuration: TimeInterval

    /// Total bytes sent.
    public let totalBytesSent: Int

    /// Total bytes received.
    public let totalBytesReceived: Int

    /// Requests per second.
    public let requestsPerSecond: Double

    /// Error rate (0.0 to 1.0).
    public let errorRate: Double

    /// Breakdown by status code.
    public let statusCodeCounts: [Int: Int]

    /// Breakdown by service.
    public let serviceCounts: [String: Int]

    /// Time period start.
    public let periodStart: Date

    /// Time period end.
    public let periodEnd: Date
}

// MARK: - Metrics Observer Protocol

/// Protocol for receiving metrics events.
///
/// Implement this protocol to collect and process metrics from Google Cloud API calls.
///
/// ## Example Implementation
/// ```swift
/// class MyMetricsObserver: GoogleCloudMetricsObserver {
///     func didCompleteRequest(_ metric: APIRequestMetric) {
///         print("[\(metric.service)] \(metric.operation): \(metric.statusCode) in \(metric.duration)s")
///
///         // Send to your metrics system
///         myMetricsSystem.recordLatency(
///             service: metric.service,
///             operation: metric.operation,
///             duration: metric.duration
///         )
///     }
///
///     func didStartRequest(service: String, operation: String, path: String) {
///         print("Starting request: \(service).\(operation)")
///     }
/// }
/// ```
public protocol GoogleCloudMetricsObserver: AnyObject, Sendable {
    /// Called when a request completes (success or failure).
    func didCompleteRequest(_ metric: APIRequestMetric)

    /// Called when a request starts.
    func didStartRequest(service: String, operation: String, path: String)

    /// Called when a retry occurs.
    func didRetryRequest(service: String, operation: String, attempt: Int, reason: String)

    /// Called when authentication refreshes.
    func didRefreshAuthentication(success: Bool, duration: TimeInterval)
}

// MARK: - Default Implementations

extension GoogleCloudMetricsObserver {
    public func didStartRequest(service: String, operation: String, path: String) {}
    public func didRetryRequest(service: String, operation: String, attempt: Int, reason: String) {}
    public func didRefreshAuthentication(success: Bool, duration: TimeInterval) {}
}

// MARK: - Metrics Collector

/// A centralized metrics collector for Google Cloud API operations.
///
/// ## Example Usage
/// ```swift
/// // Create and configure the collector
/// let collector = GoogleCloudMetricsCollector.shared
/// collector.addObserver(myMetricsObserver)
///
/// // Enable console logging for development
/// collector.enableConsoleLogging = true
///
/// // Later, get aggregated metrics
/// if let metrics = await collector.getAggregatedMetrics(for: .lastHour) {
///     print("Error rate: \(metrics.errorRate * 100)%")
///     print("P95 latency: \(metrics.p95Duration)s")
/// }
/// ```
public actor GoogleCloudMetricsCollector {
    /// Shared singleton instance.
    public static let shared = GoogleCloudMetricsCollector()

    private var observers: [WeakObserver] = []
    private var recentMetrics: [APIRequestMetric] = []
    private var maxStoredMetrics: Int = 10000

    /// Enable console logging of all requests.
    public var enableConsoleLogging: Bool = false

    /// Log level for console output.
    public var logLevel: LogLevel = .info

    private init() {}

    /// Add an observer to receive metrics events.
    public func addObserver(_ observer: GoogleCloudMetricsObserver) {
        // Clean up any nil weak references
        observers.removeAll { $0.observer == nil }
        observers.append(WeakObserver(observer))
    }

    /// Remove an observer.
    public func removeObserver(_ observer: GoogleCloudMetricsObserver) {
        observers.removeAll { $0.observer === observer || $0.observer == nil }
    }

    /// Record a completed request.
    public func recordRequest(_ metric: APIRequestMetric) {
        // Store the metric
        recentMetrics.append(metric)
        if recentMetrics.count > maxStoredMetrics {
            recentMetrics.removeFirst(recentMetrics.count - maxStoredMetrics)
        }

        // Console logging
        if enableConsoleLogging {
            logToConsole(metric)
        }

        // Notify observers
        for weakObserver in observers {
            weakObserver.observer?.didCompleteRequest(metric)
        }
    }

    /// Notify that a request is starting.
    public func notifyRequestStarted(service: String, operation: String, path: String) {
        if enableConsoleLogging && logLevel.rawValue <= LogLevel.debug.rawValue {
            print("[GoogleCloud] Starting \(service).\(operation): \(path)")
        }

        for weakObserver in observers {
            weakObserver.observer?.didStartRequest(service: service, operation: operation, path: path)
        }
    }

    /// Notify that a retry is occurring.
    public func notifyRetry(service: String, operation: String, attempt: Int, reason: String) {
        if enableConsoleLogging {
            print("[GoogleCloud] Retrying \(service).\(operation) (attempt \(attempt)): \(reason)")
        }

        for weakObserver in observers {
            weakObserver.observer?.didRetryRequest(service: service, operation: operation, attempt: attempt, reason: reason)
        }
    }

    /// Notify that authentication was refreshed.
    public func notifyAuthRefresh(success: Bool, duration: TimeInterval) {
        if enableConsoleLogging {
            let status = success ? "succeeded" : "failed"
            print("[GoogleCloud] Auth refresh \(status) in \(String(format: "%.3f", duration))s")
        }

        for weakObserver in observers {
            weakObserver.observer?.didRefreshAuthentication(success: success, duration: duration)
        }
    }

    /// Get aggregated metrics for a time period.
    public func getAggregatedMetrics(for period: TimePeriod) -> AggregatedMetrics? {
        let now = Date()
        let startDate: Date

        switch period {
        case .lastMinute:
            startDate = now.addingTimeInterval(-60)
        case .lastHour:
            startDate = now.addingTimeInterval(-3600)
        case .lastDay:
            startDate = now.addingTimeInterval(-86400)
        case .custom(let start, _):
            startDate = start
        }

        let filteredMetrics = recentMetrics.filter { $0.timestamp >= startDate }

        guard !filteredMetrics.isEmpty else { return nil }

        return calculateAggregates(metrics: filteredMetrics, start: startDate, end: now)
    }

    /// Get metrics filtered by service.
    public func getMetrics(service: String, limit: Int = 100) -> [APIRequestMetric] {
        recentMetrics
            .filter { $0.service == service }
            .suffix(limit)
            .reversed()
            .map { $0 }
    }

    /// Get recent error metrics.
    public func getRecentErrors(limit: Int = 100) -> [APIRequestMetric] {
        recentMetrics
            .filter { !$0.success }
            .suffix(limit)
            .reversed()
            .map { $0 }
    }

    /// Clear all stored metrics.
    public func clear() {
        recentMetrics.removeAll()
    }

    /// Set the maximum number of metrics to store.
    public func setMaxStoredMetrics(_ count: Int) {
        maxStoredMetrics = count
        if recentMetrics.count > maxStoredMetrics {
            recentMetrics.removeFirst(recentMetrics.count - maxStoredMetrics)
        }
    }

    // MARK: - Private Methods

    private func logToConsole(_ metric: APIRequestMetric) {
        let status = metric.success ? "OK" : "ERROR"
        let durationStr = String(format: "%.3f", metric.duration)

        var message = "[GoogleCloud] \(metric.service).\(metric.operation) \(status)"
        message += " \(metric.statusCode) \(durationStr)s"

        if metric.retryCount > 0 {
            message += " (retries: \(metric.retryCount))"
        }

        if let error = metric.errorMessage, !metric.success {
            message += " - \(error)"
        }

        print(message)
    }

    private func calculateAggregates(metrics: [APIRequestMetric], start: Date, end: Date) -> AggregatedMetrics {
        let durations = metrics.map { $0.duration }.sorted()
        let totalRequests = metrics.count
        let successfulRequests = metrics.filter { $0.success }.count
        let failedRequests = totalRequests - successfulRequests

        let averageDuration = durations.reduce(0, +) / Double(totalRequests)

        let p50Index = Int(Double(durations.count) * 0.50)
        let p95Index = Int(Double(durations.count) * 0.95)
        let p99Index = Int(Double(durations.count) * 0.99)

        let p50 = durations[min(p50Index, durations.count - 1)]
        let p95 = durations[min(p95Index, durations.count - 1)]
        let p99 = durations[min(p99Index, durations.count - 1)]

        let totalBytesSent = metrics.compactMap { $0.requestSize }.reduce(0, +)
        let totalBytesReceived = metrics.compactMap { $0.responseSize }.reduce(0, +)

        let periodSeconds = end.timeIntervalSince(start)
        let requestsPerSecond = periodSeconds > 0 ? Double(totalRequests) / periodSeconds : 0

        var statusCodeCounts: [Int: Int] = [:]
        var serviceCounts: [String: Int] = [:]

        for metric in metrics {
            statusCodeCounts[metric.statusCode, default: 0] += 1
            serviceCounts[metric.service, default: 0] += 1
        }

        return AggregatedMetrics(
            totalRequests: totalRequests,
            successfulRequests: successfulRequests,
            failedRequests: failedRequests,
            averageDuration: averageDuration,
            p50Duration: p50,
            p95Duration: p95,
            p99Duration: p99,
            maxDuration: durations.last ?? 0,
            minDuration: durations.first ?? 0,
            totalBytesSent: totalBytesSent,
            totalBytesReceived: totalBytesReceived,
            requestsPerSecond: requestsPerSecond,
            errorRate: totalRequests > 0 ? Double(failedRequests) / Double(totalRequests) : 0,
            statusCodeCounts: statusCodeCounts,
            serviceCounts: serviceCounts,
            periodStart: start,
            periodEnd: end
        )
    }
}

// MARK: - Supporting Types

/// Time period for metrics aggregation.
public enum TimePeriod: Sendable {
    case lastMinute
    case lastHour
    case lastDay
    case custom(start: Date, end: Date)
}

/// Log level for console output.
public enum LogLevel: Int, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
}

/// Weak reference wrapper for observers.
private final class WeakObserver: @unchecked Sendable {
    weak var observer: GoogleCloudMetricsObserver?

    init(_ observer: GoogleCloudMetricsObserver) {
        self.observer = observer
    }
}

// MARK: - Logging Observer

/// A simple logging observer that prints metrics to the console.
///
/// ## Example Usage
/// ```swift
/// let loggingObserver = LoggingMetricsObserver(minLogLevel: .info)
/// GoogleCloudMetricsCollector.shared.addObserver(loggingObserver)
/// ```
public final class LoggingMetricsObserver: GoogleCloudMetricsObserver, @unchecked Sendable {
    private let minLogLevel: LogLevel
    private let includeHeaders: Bool

    public init(minLogLevel: LogLevel = .info, includeHeaders: Bool = false) {
        self.minLogLevel = minLogLevel
        self.includeHeaders = includeHeaders
    }

    public func didCompleteRequest(_ metric: APIRequestMetric) {
        let level: LogLevel = metric.success ? .info : .error

        guard level.rawValue >= minLogLevel.rawValue else { return }

        let emoji = metric.success ? "✓" : "✗"
        let durationMs = Int(metric.duration * 1000)

        var output = "\(emoji) [\(metric.service)] \(metric.operation)"
        output += " → \(metric.statusCode) (\(durationMs)ms)"

        if metric.retryCount > 0 {
            output += " [retries: \(metric.retryCount)]"
        }

        if let error = metric.errorMessage, !metric.success {
            output += "\n  Error: \(error)"
        }

        print(output)
    }

    public func didStartRequest(service: String, operation: String, path: String) {
        guard minLogLevel.rawValue <= LogLevel.debug.rawValue else { return }
        print("→ [\(service)] Starting \(operation)")
    }

    public func didRetryRequest(service: String, operation: String, attempt: Int, reason: String) {
        print("↻ [\(service)] Retry \(operation) #\(attempt): \(reason)")
    }

    public func didRefreshAuthentication(success: Bool, duration: TimeInterval) {
        let status = success ? "✓" : "✗"
        let durationMs = Int(duration * 1000)
        print("\(status) [Auth] Token refresh (\(durationMs)ms)")
    }
}

// MARK: - Metrics Middleware

/// Middleware that automatically records metrics for HTTP client operations.
///
/// This can be used to wrap the HTTP client and automatically collect metrics.
public struct MetricsMiddleware: Sendable {
    private let service: String
    private let collector: GoogleCloudMetricsCollector

    public init(service: String, collector: GoogleCloudMetricsCollector = .shared) {
        self.service = service
        self.collector = collector
    }

    /// Wrap an async operation and record its metrics.
    public func measure<T>(
        operation: String,
        method: String,
        path: String,
        execute: () async throws -> (T, Int)
    ) async throws -> T {
        let startTime = Date()

        await collector.notifyRequestStarted(service: service, operation: operation, path: path)

        do {
            let (result, statusCode) = try await execute()

            let metric = APIRequestMetric(
                service: service,
                operation: operation,
                method: method,
                path: path,
                statusCode: statusCode,
                duration: Date().timeIntervalSince(startTime),
                success: statusCode >= 200 && statusCode < 300,
                timestamp: startTime
            )

            await collector.recordRequest(metric)

            return result
        } catch {
            let statusCode: Int
            let errorMessage: String

            if let apiError = error as? GoogleCloudAPIError {
                switch apiError {
                case .httpError(let code, _):
                    statusCode = code
                    errorMessage = apiError.localizedDescription
                default:
                    statusCode = 0
                    errorMessage = apiError.localizedDescription
                }
            } else {
                statusCode = 0
                errorMessage = error.localizedDescription
            }

            let metric = APIRequestMetric(
                service: service,
                operation: operation,
                method: method,
                path: path,
                statusCode: statusCode,
                duration: Date().timeIntervalSince(startTime),
                success: false,
                errorMessage: errorMessage,
                timestamp: startTime
            )

            await collector.recordRequest(metric)

            throw error
        }
    }
}

// MARK: - Health Check

/// Health check result for Google Cloud services.
public struct ServiceHealthCheckResult: Sendable {
    /// Whether the service is healthy.
    public let healthy: Bool

    /// Latency of the health check in seconds.
    public let latency: TimeInterval

    /// Error message if unhealthy.
    public let errorMessage: String?

    /// Timestamp of the check.
    public let timestamp: Date

    /// Service that was checked.
    public let service: String
}

/// Utility for performing health checks on Google Cloud services.
public enum GoogleCloudHealthChecker {
    /// Perform a health check by listing resources (non-destructive).
    public static func checkHealth<API: Actor>(
        api: API,
        service: String,
        check: @Sendable (API) async throws -> Void
    ) async -> ServiceHealthCheckResult {
        let startTime = Date()

        do {
            try await check(api)

            return ServiceHealthCheckResult(
                healthy: true,
                latency: Date().timeIntervalSince(startTime),
                errorMessage: nil,
                timestamp: startTime,
                service: service
            )
        } catch {
            return ServiceHealthCheckResult(
                healthy: false,
                latency: Date().timeIntervalSince(startTime),
                errorMessage: error.localizedDescription,
                timestamp: startTime,
                service: service
            )
        }
    }
}
