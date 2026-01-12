//
//  GoogleCloudConfiguration.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation

// MARK: - Global Configuration

/// Centralized configuration for Google Cloud Swift SDK.
///
/// Use this to customize timeouts, retry behavior, rate limiting, and other settings
/// across all Google Cloud API clients.
///
/// ## Example Usage
/// ```swift
/// // Use default configuration
/// let config = GoogleCloudConfiguration.default
///
/// // Create custom configuration
/// let customConfig = GoogleCloudConfiguration(
///     requestTimeout: 120,
///     retryConfiguration: .aggressive,
///     operationPolling: .fast
/// )
///
/// // Create API clients with custom configuration
/// let storageAPI = await GoogleCloudStorageAPI.create(
///     authClient: authClient,
///     httpClient: httpClient,
///     configuration: customConfig
/// )
/// ```
public struct GoogleCloudConfiguration: Sendable {
    /// Configuration for HTTP request timeouts.
    public let timeouts: TimeoutConfiguration

    /// Configuration for retry behavior on transient failures.
    public let retry: RetryConfiguration

    /// Configuration for operation polling (long-running operations).
    public let operationPolling: OperationPollingConfiguration

    /// Configuration for metrics collection.
    public let metrics: MetricsConfiguration

    /// Configuration for pagination defaults.
    public let pagination: PaginationConfiguration

    /// Default configuration with sensible defaults for most use cases.
    public static let `default` = GoogleCloudConfiguration(
        timeouts: .default,
        retry: .default,
        operationPolling: .default,
        metrics: .default,
        pagination: .default
    )

    /// Conservative configuration with longer timeouts and more retries.
    /// Suitable for unreliable networks or batch processing.
    public static let conservative = GoogleCloudConfiguration(
        timeouts: .conservative,
        retry: .conservative,
        operationPolling: .conservative,
        metrics: .default,
        pagination: .default
    )

    /// Aggressive configuration with shorter timeouts and faster polling.
    /// Suitable for interactive applications requiring quick feedback.
    public static let aggressive = GoogleCloudConfiguration(
        timeouts: .aggressive,
        retry: .aggressive,
        operationPolling: .fast,
        metrics: .default,
        pagination: .default
    )

    /// Batch processing configuration optimized for high-throughput operations.
    public static let batch = GoogleCloudConfiguration(
        timeouts: .batch,
        retry: .batch,
        operationPolling: .conservative,
        metrics: .minimal,
        pagination: .large
    )

    /// Initialize with custom configuration values.
    public init(
        timeouts: TimeoutConfiguration = .default,
        retry: RetryConfiguration = .default,
        operationPolling: OperationPollingConfiguration = .default,
        metrics: MetricsConfiguration = .default,
        pagination: PaginationConfiguration = .default
    ) {
        self.timeouts = timeouts
        self.retry = retry
        self.operationPolling = operationPolling
        self.metrics = metrics
        self.pagination = pagination
    }

    /// Create a configuration with a specific request timeout.
    public func withRequestTimeout(_ timeout: TimeInterval) -> GoogleCloudConfiguration {
        GoogleCloudConfiguration(
            timeouts: TimeoutConfiguration(
                request: timeout,
                connection: timeouts.connection,
                upload: timeouts.upload,
                download: timeouts.download
            ),
            retry: retry,
            operationPolling: operationPolling,
            metrics: metrics,
            pagination: pagination
        )
    }

    /// Create a configuration with a specific retry configuration.
    public func withRetry(_ retryConfig: RetryConfiguration) -> GoogleCloudConfiguration {
        GoogleCloudConfiguration(
            timeouts: timeouts,
            retry: retryConfig,
            operationPolling: operationPolling,
            metrics: metrics,
            pagination: pagination
        )
    }

    /// Create a configuration with no retries.
    public func withNoRetries() -> GoogleCloudConfiguration {
        withRetry(.none)
    }
}

// MARK: - Timeout Configuration

/// Configuration for various timeout values.
public struct TimeoutConfiguration: Sendable {
    /// Timeout for individual HTTP requests in seconds.
    public let request: TimeInterval

    /// Timeout for establishing a connection in seconds.
    public let connection: TimeInterval

    /// Timeout for upload operations in seconds.
    public let upload: TimeInterval

    /// Timeout for download operations in seconds.
    public let download: TimeInterval

    /// Default timeout configuration.
    public static let `default` = TimeoutConfiguration(
        request: 60,
        connection: 30,
        upload: 300,
        download: 300
    )

    /// Conservative timeouts for slow networks.
    public static let conservative = TimeoutConfiguration(
        request: 120,
        connection: 60,
        upload: 600,
        download: 600
    )

    /// Aggressive timeouts for fast networks.
    public static let aggressive = TimeoutConfiguration(
        request: 30,
        connection: 15,
        upload: 120,
        download: 120
    )

    /// Batch processing timeouts.
    public static let batch = TimeoutConfiguration(
        request: 300,
        connection: 60,
        upload: 1800,
        download: 1800
    )

    public init(
        request: TimeInterval = 60,
        connection: TimeInterval = 30,
        upload: TimeInterval = 300,
        download: TimeInterval = 300
    ) {
        self.request = request
        self.connection = connection
        self.upload = upload
        self.download = download
    }
}

// MARK: - Retry Configuration Extensions

extension RetryConfiguration {
    /// Conservative retry configuration with more attempts and longer delays.
    public static let conservative = RetryConfiguration(
        maxRetries: 5,
        baseDelay: 2.0,
        maxDelay: 60.0,
        jitterFactor: 0.3
    )

    /// Aggressive retry configuration with fewer attempts and shorter delays.
    public static let aggressive = RetryConfiguration(
        maxRetries: 2,
        baseDelay: 0.5,
        maxDelay: 10.0,
        jitterFactor: 0.1
    )

    /// Batch processing retry configuration.
    public static let batch = RetryConfiguration(
        maxRetries: 10,
        baseDelay: 1.0,
        maxDelay: 120.0,
        jitterFactor: 0.25
    )

    /// Create a custom retry configuration.
    public static func custom(
        maxRetries: Int,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        jitterFactor: Double = 0.2
    ) -> RetryConfiguration {
        RetryConfiguration(
            maxRetries: maxRetries,
            baseDelay: baseDelay,
            maxDelay: maxDelay,
            jitterFactor: jitterFactor
        )
    }
}

// MARK: - Operation Polling Configuration

/// Configuration for polling long-running operations.
public struct OperationPollingConfiguration: Sendable {
    /// Default timeout for waiting for an operation to complete.
    public let timeout: TimeInterval

    /// Interval between polling attempts.
    public let pollInterval: TimeInterval

    /// Minimum poll interval (used with exponential backoff).
    public let minPollInterval: TimeInterval

    /// Maximum poll interval (used with exponential backoff).
    public let maxPollInterval: TimeInterval

    /// Whether to use exponential backoff for polling.
    public let useExponentialBackoff: Bool

    /// Default polling configuration.
    public static let `default` = OperationPollingConfiguration(
        timeout: 300,
        pollInterval: 5,
        minPollInterval: 1,
        maxPollInterval: 30,
        useExponentialBackoff: false
    )

    /// Fast polling for interactive operations.
    public static let fast = OperationPollingConfiguration(
        timeout: 120,
        pollInterval: 2,
        minPollInterval: 1,
        maxPollInterval: 10,
        useExponentialBackoff: false
    )

    /// Conservative polling for long-running operations.
    public static let conservative = OperationPollingConfiguration(
        timeout: 1800,
        pollInterval: 10,
        minPollInterval: 5,
        maxPollInterval: 60,
        useExponentialBackoff: true
    )

    /// Very patient polling for extremely long operations.
    public static let patient = OperationPollingConfiguration(
        timeout: 7200,
        pollInterval: 30,
        minPollInterval: 10,
        maxPollInterval: 120,
        useExponentialBackoff: true
    )

    public init(
        timeout: TimeInterval = 300,
        pollInterval: TimeInterval = 5,
        minPollInterval: TimeInterval = 1,
        maxPollInterval: TimeInterval = 30,
        useExponentialBackoff: Bool = false
    ) {
        self.timeout = timeout
        self.pollInterval = pollInterval
        self.minPollInterval = minPollInterval
        self.maxPollInterval = maxPollInterval
        self.useExponentialBackoff = useExponentialBackoff
    }

    /// Calculate the poll interval for a given attempt.
    public func interval(for attempt: Int) -> TimeInterval {
        if useExponentialBackoff {
            let exponentialInterval = minPollInterval * pow(1.5, Double(attempt))
            return min(exponentialInterval, maxPollInterval)
        }
        return pollInterval
    }
}

// MARK: - Metrics Configuration

/// Configuration for metrics collection.
public struct MetricsConfiguration: Sendable {
    /// Whether metrics collection is enabled.
    public let enabled: Bool

    /// Maximum number of metrics to store in memory.
    public let maxStoredMetrics: Int

    /// Duration after which metrics are considered stale.
    public let retentionPeriod: TimeInterval

    /// Whether to collect detailed timing breakdowns.
    public let collectDetailedTimings: Bool

    /// Whether to include request/response sizes.
    public let collectSizes: Bool

    /// Default metrics configuration.
    public static let `default` = MetricsConfiguration(
        enabled: true,
        maxStoredMetrics: 10000,
        retentionPeriod: 3600,
        collectDetailedTimings: true,
        collectSizes: true
    )

    /// Minimal metrics for production.
    public static let minimal = MetricsConfiguration(
        enabled: true,
        maxStoredMetrics: 1000,
        retentionPeriod: 1800,
        collectDetailedTimings: false,
        collectSizes: false
    )

    /// Disabled metrics.
    public static let disabled = MetricsConfiguration(
        enabled: false,
        maxStoredMetrics: 0,
        retentionPeriod: 0,
        collectDetailedTimings: false,
        collectSizes: false
    )

    /// Verbose metrics for debugging.
    public static let verbose = MetricsConfiguration(
        enabled: true,
        maxStoredMetrics: 50000,
        retentionPeriod: 7200,
        collectDetailedTimings: true,
        collectSizes: true
    )

    public init(
        enabled: Bool = true,
        maxStoredMetrics: Int = 10000,
        retentionPeriod: TimeInterval = 3600,
        collectDetailedTimings: Bool = true,
        collectSizes: Bool = true
    ) {
        self.enabled = enabled
        self.maxStoredMetrics = maxStoredMetrics
        self.retentionPeriod = retentionPeriod
        self.collectDetailedTimings = collectDetailedTimings
        self.collectSizes = collectSizes
    }
}

// MARK: - Pagination Configuration

/// Configuration for pagination defaults.
public struct PaginationConfiguration: Sendable {
    /// Default page size for list operations.
    public let defaultPageSize: Int

    /// Maximum page size for list operations.
    public let maxPageSize: Int

    /// Whether to automatically fetch all pages.
    public let autoFetchAllPages: Bool

    /// Maximum number of pages to fetch automatically.
    public let maxAutoFetchPages: Int

    /// Default pagination configuration.
    public static let `default` = PaginationConfiguration(
        defaultPageSize: 100,
        maxPageSize: 500,
        autoFetchAllPages: false,
        maxAutoFetchPages: 100
    )

    /// Small pages for memory-constrained environments.
    public static let small = PaginationConfiguration(
        defaultPageSize: 25,
        maxPageSize: 100,
        autoFetchAllPages: false,
        maxAutoFetchPages: 50
    )

    /// Large pages for batch processing.
    public static let large = PaginationConfiguration(
        defaultPageSize: 500,
        maxPageSize: 1000,
        autoFetchAllPages: true,
        maxAutoFetchPages: 1000
    )

    public init(
        defaultPageSize: Int = 100,
        maxPageSize: Int = 500,
        autoFetchAllPages: Bool = false,
        maxAutoFetchPages: Int = 100
    ) {
        self.defaultPageSize = defaultPageSize
        self.maxPageSize = maxPageSize
        self.autoFetchAllPages = autoFetchAllPages
        self.maxAutoFetchPages = maxAutoFetchPages
    }
}

// MARK: - Service-Specific Configuration

/// Configuration presets for specific Google Cloud services.
public enum ServiceConfiguration {
    /// Configuration optimized for Cloud Storage operations.
    public static let storage = GoogleCloudConfiguration(
        timeouts: TimeoutConfiguration(
            request: 120,
            connection: 30,
            upload: 1800,
            download: 1800
        ),
        retry: .default,
        operationPolling: .default,
        metrics: .default,
        pagination: .large
    )

    /// Configuration optimized for Compute Engine operations.
    public static let compute = GoogleCloudConfiguration(
        timeouts: .default,
        retry: .default,
        operationPolling: OperationPollingConfiguration(
            timeout: 600,
            pollInterval: 5,
            minPollInterval: 2,
            maxPollInterval: 30,
            useExponentialBackoff: true
        ),
        metrics: .default,
        pagination: .default
    )

    /// Configuration optimized for Cloud Run deployments.
    public static let cloudRun = GoogleCloudConfiguration(
        timeouts: TimeoutConfiguration(
            request: 120,
            connection: 30,
            upload: 600,
            download: 300
        ),
        retry: .default,
        operationPolling: OperationPollingConfiguration(
            timeout: 900,
            pollInterval: 5,
            minPollInterval: 2,
            maxPollInterval: 30,
            useExponentialBackoff: true
        ),
        metrics: .default,
        pagination: .default
    )

    /// Configuration optimized for Secret Manager.
    public static let secretManager = GoogleCloudConfiguration(
        timeouts: TimeoutConfiguration(
            request: 30,
            connection: 15,
            upload: 60,
            download: 60
        ),
        retry: .aggressive,
        operationPolling: .default,
        metrics: .minimal,
        pagination: .small
    )

    /// Configuration optimized for Cloud Logging.
    public static let logging = GoogleCloudConfiguration(
        timeouts: TimeoutConfiguration(
            request: 60,
            connection: 30,
            upload: 120,
            download: 300
        ),
        retry: .default,
        operationPolling: .default,
        metrics: .default,
        pagination: .large
    )

    /// Configuration optimized for IAM operations.
    public static let iam = GoogleCloudConfiguration(
        timeouts: .aggressive,
        retry: .default,
        operationPolling: .default,
        metrics: .default,
        pagination: .default
    )

    /// Configuration optimized for BigQuery.
    public static let bigQuery = GoogleCloudConfiguration(
        timeouts: TimeoutConfiguration(
            request: 300,
            connection: 30,
            upload: 1800,
            download: 3600
        ),
        retry: .conservative,
        operationPolling: .patient,
        metrics: .default,
        pagination: .large
    )
}

// MARK: - Environment-Based Configuration

extension GoogleCloudConfiguration {
    /// Create configuration from environment variables.
    ///
    /// Supported environment variables:
    /// - `GOOGLE_CLOUD_REQUEST_TIMEOUT`: Request timeout in seconds
    /// - `GOOGLE_CLOUD_MAX_RETRIES`: Maximum retry attempts
    /// - `GOOGLE_CLOUD_RETRY_BASE_DELAY`: Base delay between retries
    /// - `GOOGLE_CLOUD_POLL_INTERVAL`: Operation polling interval
    /// - `GOOGLE_CLOUD_POLL_TIMEOUT`: Operation polling timeout
    public static func fromEnvironment() -> GoogleCloudConfiguration {
        let env = ProcessInfo.processInfo.environment

        let requestTimeout = env["GOOGLE_CLOUD_REQUEST_TIMEOUT"]
            .flatMap { TimeInterval($0) } ?? 60

        let maxRetries = env["GOOGLE_CLOUD_MAX_RETRIES"]
            .flatMap { Int($0) } ?? 3

        let baseDelay = env["GOOGLE_CLOUD_RETRY_BASE_DELAY"]
            .flatMap { TimeInterval($0) } ?? 1.0

        let pollInterval = env["GOOGLE_CLOUD_POLL_INTERVAL"]
            .flatMap { TimeInterval($0) } ?? 5

        let pollTimeout = env["GOOGLE_CLOUD_POLL_TIMEOUT"]
            .flatMap { TimeInterval($0) } ?? 300

        return GoogleCloudConfiguration(
            timeouts: TimeoutConfiguration(request: requestTimeout),
            retry: RetryConfiguration(
                maxRetries: maxRetries,
                baseDelay: baseDelay,
                maxDelay: 30.0,
                jitterFactor: 0.2
            ),
            operationPolling: OperationPollingConfiguration(
                timeout: pollTimeout,
                pollInterval: pollInterval
            ),
            metrics: .default,
            pagination: .default
        )
    }
}
