//
//  GoogleCloudLogging.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

// MARK: - Log Entry

/// Represents a log entry in Cloud Logging.
///
/// Log entries are the fundamental unit of data in Cloud Logging.
/// Each entry contains a payload (text or structured data) and metadata.
///
/// ## Example Usage
/// ```swift
/// let entry = GoogleCloudLogEntry(
///     logName: "my-app",
///     projectID: "my-project",
///     severity: .error,
///     textPayload: "Connection failed to database"
/// )
/// print(entry.writeCommand)
/// ```
public struct GoogleCloudLogEntry: Codable, Sendable, Equatable {
    /// Name of the log
    public let logName: String

    /// Project ID
    public let projectID: String

    /// Severity level
    public let severity: LogSeverity

    /// Text payload (for simple messages)
    public let textPayload: String?

    /// JSON payload (for structured logs)
    public let jsonPayload: [String: String]?

    /// Labels for the log entry
    public let labels: [String: String]

    /// Resource type (e.g., "gce_instance", "cloud_function")
    public let resourceType: String?

    /// Resource labels
    public let resourceLabels: [String: String]

    /// Trace ID for distributed tracing
    public let trace: String?

    /// Span ID within the trace
    public let spanID: String?

    public init(
        logName: String,
        projectID: String,
        severity: LogSeverity = .default,
        textPayload: String? = nil,
        jsonPayload: [String: String]? = nil,
        labels: [String: String] = [:],
        resourceType: String? = nil,
        resourceLabels: [String: String] = [:],
        trace: String? = nil,
        spanID: String? = nil
    ) {
        self.logName = logName
        self.projectID = projectID
        self.severity = severity
        self.textPayload = textPayload
        self.jsonPayload = jsonPayload
        self.labels = labels
        self.resourceType = resourceType
        self.resourceLabels = resourceLabels
        self.trace = trace
        self.spanID = spanID
    }

    /// Full resource name for the log
    public var resourceName: String {
        "projects/\(projectID)/logs/\(logName)"
    }

    /// gcloud command to write this log entry
    public var writeCommand: String {
        var cmd = "gcloud logging write \(logName)"
        if let text = textPayload {
            cmd += " \"\(text)\""
        } else if let json = jsonPayload {
            let jsonStr = json.map { "\"\($0.key)\": \"\($0.value)\"" }.joined(separator: ", ")
            cmd += " '{\(jsonStr)}'"
        }
        cmd += " --project=\(projectID)"
        cmd += " --severity=\(severity.rawValue)"
        if let resourceType = resourceType {
            cmd += " --resource-type=\(resourceType)"
        }
        return cmd
    }

    /// gcloud command to read logs
    public static func readCommand(
        projectID: String,
        logName: String? = nil,
        filter: String? = nil,
        limit: Int = 100,
        format: OutputFormat = .json
    ) -> String {
        var cmd = "gcloud logging read"
        var filters: [String] = []
        if let logName = logName {
            filters.append("logName=\"projects/\(projectID)/logs/\(logName)\"")
        }
        if let filter = filter {
            filters.append(filter)
        }
        if !filters.isEmpty {
            cmd += " '\(filters.joined(separator: " AND "))'"
        }
        cmd += " --project=\(projectID)"
        cmd += " --limit=\(limit)"
        cmd += " --format=\(format.rawValue)"
        return cmd
    }

    /// gcloud command to delete logs
    public static func deleteCommand(projectID: String, logName: String) -> String {
        "gcloud logging logs delete \(logName) --project=\(projectID) --quiet"
    }

    /// gcloud command to list logs
    public static func listCommand(projectID: String) -> String {
        "gcloud logging logs list --project=\(projectID)"
    }

    /// Output format for log reads
    public enum OutputFormat: String, Codable, Sendable {
        case json = "json"
        case text = "text"
        case table = "table"
        case yaml = "yaml"
    }
}

// MARK: - Log Severity

/// Log severity levels following the Cloud Logging API.
public enum LogSeverity: String, Codable, Sendable, CaseIterable {
    /// Default log level (equivalent to DEBUG)
    case `default` = "DEFAULT"
    /// Debug information
    case debug = "DEBUG"
    /// Routine information
    case info = "INFO"
    /// Normal but significant events
    case notice = "NOTICE"
    /// Warning events
    case warning = "WARNING"
    /// Error events
    case error = "ERROR"
    /// Critical events
    case critical = "CRITICAL"
    /// System is unusable
    case alert = "ALERT"
    /// Action must be taken immediately
    case emergency = "EMERGENCY"

    /// Numeric severity value
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

// MARK: - Log Sink

/// Represents a log sink for exporting logs to external destinations.
///
/// Log sinks route logs to Cloud Storage, BigQuery, Pub/Sub, or another project.
///
/// ## Example Usage
/// ```swift
/// let sink = GoogleCloudLogSink(
///     name: "error-logs-to-bigquery",
///     projectID: "my-project",
///     destination: .bigQuery(datasetID: "logs_dataset"),
///     filter: "severity >= ERROR"
/// )
/// print(sink.createCommand)
/// ```
public struct GoogleCloudLogSink: Codable, Sendable, Equatable {
    /// Name of the sink
    public let name: String

    /// Project ID
    public let projectID: String

    /// Destination for the logs
    public let destination: SinkDestination

    /// Filter to select which logs to export
    public let filter: String?

    /// Description of the sink
    public let description: String?

    /// Whether the sink is disabled
    public let disabled: Bool

    /// Exclusion filters
    public let exclusions: [LogExclusion]

    /// Include children (for organization/folder sinks)
    public let includeChildren: Bool

    public init(
        name: String,
        projectID: String,
        destination: SinkDestination,
        filter: String? = nil,
        description: String? = nil,
        disabled: Bool = false,
        exclusions: [LogExclusion] = [],
        includeChildren: Bool = false
    ) {
        self.name = name
        self.projectID = projectID
        self.destination = destination
        self.filter = filter
        self.description = description
        self.disabled = disabled
        self.exclusions = exclusions
        self.includeChildren = includeChildren
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/sinks/\(name)"
    }

    /// gcloud command to create this sink
    public var createCommand: String {
        var cmd = "gcloud logging sinks create \(name) \(destination.destinationURI(projectID: projectID))"
        cmd += " --project=\(projectID)"
        if let filter = filter {
            cmd += " --log-filter='\(filter)'"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if disabled {
            cmd += " --disabled"
        }
        if includeChildren {
            cmd += " --include-children"
        }
        return cmd
    }

    /// gcloud command to update this sink
    public var updateCommand: String {
        var cmd = "gcloud logging sinks update \(name)"
        cmd += " --project=\(projectID)"
        if let filter = filter {
            cmd += " --log-filter='\(filter)'"
        }
        if disabled {
            cmd += " --disabled"
        }
        return cmd
    }

    /// gcloud command to delete this sink
    public var deleteCommand: String {
        "gcloud logging sinks delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this sink
    public var describeCommand: String {
        "gcloud logging sinks describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list sinks
    public static func listCommand(projectID: String) -> String {
        "gcloud logging sinks list --project=\(projectID)"
    }

    /// Exclusion filter within a sink
    public struct LogExclusion: Codable, Sendable, Equatable {
        public let name: String
        public let filter: String
        public let description: String?
        public let disabled: Bool

        public init(
            name: String,
            filter: String,
            description: String? = nil,
            disabled: Bool = false
        ) {
            self.name = name
            self.filter = filter
            self.description = description
            self.disabled = disabled
        }
    }
}

// MARK: - Sink Destination

/// Destination types for log sinks.
public enum SinkDestination: Codable, Sendable, Equatable {
    /// Export to Cloud Storage bucket
    case storage(bucketName: String)
    /// Export to BigQuery dataset
    case bigQuery(datasetID: String)
    /// Export to Pub/Sub topic
    case pubSub(topicName: String)
    /// Export to another project's log bucket
    case logBucket(bucketID: String, location: String)
    /// Export to Splunk
    case splunk(endpoint: String)

    /// Generate the destination URI
    public func destinationURI(projectID: String) -> String {
        switch self {
        case .storage(let bucket):
            return "storage.googleapis.com/\(bucket)"
        case .bigQuery(let dataset):
            return "bigquery.googleapis.com/projects/\(projectID)/datasets/\(dataset)"
        case .pubSub(let topic):
            return "pubsub.googleapis.com/projects/\(projectID)/topics/\(topic)"
        case .logBucket(let bucket, let location):
            return "logging.googleapis.com/projects/\(projectID)/locations/\(location)/buckets/\(bucket)"
        case .splunk(let endpoint):
            return endpoint
        }
    }
}

// MARK: - Log Bucket

/// Represents a log storage bucket in Cloud Logging.
///
/// Log buckets are regional storage containers for log entries.
/// They control retention and access to logs.
///
/// ## Example Usage
/// ```swift
/// let bucket = GoogleCloudLogBucket(
///     name: "long-term-logs",
///     projectID: "my-project",
///     location: "us-central1",
///     retentionDays: 365
/// )
/// print(bucket.createCommand)
/// ```
public struct GoogleCloudLogBucket: Codable, Sendable, Equatable {
    /// Name of the bucket
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location (region) for the bucket
    public let location: String

    /// Retention period in days
    public let retentionDays: Int

    /// Description of the bucket
    public let description: String?

    /// Whether the bucket is locked (retention cannot be reduced)
    public let locked: Bool

    /// Enable analytics on this bucket
    public let analyticsEnabled: Bool

    public init(
        name: String,
        projectID: String,
        location: String,
        retentionDays: Int = 30,
        description: String? = nil,
        locked: Bool = false,
        analyticsEnabled: Bool = false
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.retentionDays = retentionDays
        self.description = description
        self.locked = locked
        self.analyticsEnabled = analyticsEnabled
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/buckets/\(name)"
    }

    /// gcloud command to create this bucket
    public var createCommand: String {
        var cmd = "gcloud logging buckets create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --retention-days=\(retentionDays)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if analyticsEnabled {
            cmd += " --enable-analytics"
        }
        return cmd
    }

    /// gcloud command to update this bucket
    public var updateCommand: String {
        var cmd = "gcloud logging buckets update \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --retention-days=\(retentionDays)"
        if locked {
            cmd += " --locked"
        }
        return cmd
    }

    /// gcloud command to delete this bucket
    public var deleteCommand: String {
        "gcloud logging buckets delete \(name) --project=\(projectID) --location=\(location) --quiet"
    }

    /// gcloud command to describe this bucket
    public var describeCommand: String {
        "gcloud logging buckets describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to list buckets
    public static func listCommand(projectID: String, location: String = "-") -> String {
        "gcloud logging buckets list --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to undelete a bucket
    public var undeleteCommand: String {
        "gcloud logging buckets undelete \(name) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Log View

/// Represents a view on a log bucket for filtered access.
///
/// Log views provide filtered access to logs within a bucket,
/// allowing you to control what logs different users can see.
///
/// ## Example Usage
/// ```swift
/// let view = GoogleCloudLogView(
///     name: "error-logs-only",
///     bucketName: "_Default",
///     projectID: "my-project",
///     location: "global",
///     filter: "severity >= ERROR"
/// )
/// print(view.createCommand)
/// ```
public struct GoogleCloudLogView: Codable, Sendable, Equatable {
    /// Name of the view
    public let name: String

    /// Parent bucket name
    public let bucketName: String

    /// Project ID
    public let projectID: String

    /// Location of the bucket
    public let location: String

    /// Filter for the view
    public let filter: String?

    /// Description of the view
    public let description: String?

    public init(
        name: String,
        bucketName: String,
        projectID: String,
        location: String,
        filter: String? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.bucketName = bucketName
        self.projectID = projectID
        self.location = location
        self.filter = filter
        self.description = description
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/buckets/\(bucketName)/views/\(name)"
    }

    /// gcloud command to create this view
    public var createCommand: String {
        var cmd = "gcloud logging views create \(name)"
        cmd += " --bucket=\(bucketName)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        if let filter = filter {
            cmd += " --log-filter='\(filter)'"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// gcloud command to update this view
    public var updateCommand: String {
        var cmd = "gcloud logging views update \(name)"
        cmd += " --bucket=\(bucketName)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        if let filter = filter {
            cmd += " --log-filter='\(filter)'"
        }
        return cmd
    }

    /// gcloud command to delete this view
    public var deleteCommand: String {
        "gcloud logging views delete \(name) --bucket=\(bucketName) --project=\(projectID) --location=\(location) --quiet"
    }

    /// gcloud command to describe this view
    public var describeCommand: String {
        "gcloud logging views describe \(name) --bucket=\(bucketName) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to list views
    public static func listCommand(bucketName: String, projectID: String, location: String) -> String {
        "gcloud logging views list --bucket=\(bucketName) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Log Exclusion

/// Represents an exclusion filter to prevent logs from being ingested.
///
/// Exclusions reduce logging costs by filtering out unwanted logs
/// before they are stored.
///
/// ## Example Usage
/// ```swift
/// let exclusion = GoogleCloudLogExclusion(
///     name: "exclude-debug-logs",
///     projectID: "my-project",
///     filter: "severity = DEBUG"
/// )
/// print(exclusion.createCommand)
/// ```
public struct GoogleCloudLogExclusion: Codable, Sendable, Equatable {
    /// Name of the exclusion
    public let name: String

    /// Project ID
    public let projectID: String

    /// Filter for logs to exclude
    public let filter: String

    /// Description of the exclusion
    public let description: String?

    /// Whether the exclusion is disabled
    public let disabled: Bool

    public init(
        name: String,
        projectID: String,
        filter: String,
        description: String? = nil,
        disabled: Bool = false
    ) {
        self.name = name
        self.projectID = projectID
        self.filter = filter
        self.description = description
        self.disabled = disabled
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/exclusions/\(name)"
    }

    /// gcloud command to create this exclusion
    public var createCommand: String {
        var cmd = "gcloud logging sinks create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --log-filter='\(filter)'"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if disabled {
            cmd += " --disabled"
        }
        // Note: Exclusions use the exclusions subcommand
        return "gcloud logging exclusions create \(name) --project=\(projectID) --filter='\(filter)'" +
               (description.map { " --description=\"\($0)\"" } ?? "") +
               (disabled ? " --disabled" : "")
    }

    /// gcloud command to update this exclusion
    public var updateCommand: String {
        var cmd = "gcloud logging exclusions update \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --filter='\(filter)'"
        if disabled {
            cmd += " --disabled"
        }
        return cmd
    }

    /// gcloud command to delete this exclusion
    public var deleteCommand: String {
        "gcloud logging exclusions delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this exclusion
    public var describeCommand: String {
        "gcloud logging exclusions describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list exclusions
    public static func listCommand(projectID: String) -> String {
        "gcloud logging exclusions list --project=\(projectID)"
    }
}

// MARK: - Log-Based Metric

/// Represents a log-based metric for Cloud Monitoring.
///
/// Log-based metrics count log entries or extract values from logs
/// to create custom metrics for dashboards and alerts.
///
/// ## Example Usage
/// ```swift
/// let metric = GoogleCloudLogMetric(
///     name: "error-count",
///     projectID: "my-project",
///     filter: "severity >= ERROR",
///     metricType: .counter
/// )
/// print(metric.createCommand)
/// ```
public struct GoogleCloudLogMetric: Codable, Sendable, Equatable {
    /// Name of the metric
    public let name: String

    /// Project ID
    public let projectID: String

    /// Filter for logs to include in the metric
    public let filter: String

    /// Description of the metric
    public let description: String?

    /// Type of metric
    public let metricType: MetricType

    /// Value extractor for distribution metrics
    public let valueExtractor: String?

    /// Bucket options for distribution metrics
    public let bucketOptions: BucketOptions?

    /// Label extractors for adding dimensions
    public let labelExtractors: [String: String]

    public init(
        name: String,
        projectID: String,
        filter: String,
        description: String? = nil,
        metricType: MetricType = .counter,
        valueExtractor: String? = nil,
        bucketOptions: BucketOptions? = nil,
        labelExtractors: [String: String] = [:]
    ) {
        self.name = name
        self.projectID = projectID
        self.filter = filter
        self.description = description
        self.metricType = metricType
        self.valueExtractor = valueExtractor
        self.bucketOptions = bucketOptions
        self.labelExtractors = labelExtractors
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/metrics/\(name)"
    }

    /// Full metric name for use in Cloud Monitoring
    public var monitoringMetricName: String {
        "logging.googleapis.com/user/\(name)"
    }

    /// gcloud command to create this metric
    public var createCommand: String {
        var cmd = "gcloud logging metrics create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --log-filter='\(filter)'"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// gcloud command to update this metric
    public var updateCommand: String {
        var cmd = "gcloud logging metrics update \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --log-filter='\(filter)'"
        return cmd
    }

    /// gcloud command to delete this metric
    public var deleteCommand: String {
        "gcloud logging metrics delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this metric
    public var describeCommand: String {
        "gcloud logging metrics describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list metrics
    public static func listCommand(projectID: String) -> String {
        "gcloud logging metrics list --project=\(projectID)"
    }

    /// Metric types
    public enum MetricType: String, Codable, Sendable {
        /// Counts matching log entries
        case counter = "COUNTER"
        /// Extracts numeric values and creates distribution
        case distribution = "DISTRIBUTION"
    }

    /// Bucket options for distribution metrics
    public struct BucketOptions: Codable, Sendable, Equatable {
        public let type: BucketType

        public enum BucketType: Codable, Sendable, Equatable {
            case linear(numBuckets: Int, width: Double, offset: Double)
            case exponential(numBuckets: Int, growthFactor: Double, scale: Double)
            case explicit(bounds: [Double])
        }

        public init(type: BucketType) {
            self.type = type
        }
    }
}

// MARK: - Log Router

/// Utility for managing log routing configuration.
///
/// The Log Router processes all logs and routes them to the appropriate
/// destinations based on sinks and exclusions.
public enum LogRouter {
    /// Generate a filter for specific resource types
    public static func resourceFilter(type: String, labels: [String: String] = [:]) -> String {
        var filter = "resource.type=\"\(type)\""
        for (key, value) in labels {
            filter += " AND resource.labels.\(key)=\"\(value)\""
        }
        return filter
    }

    /// Generate a filter for specific log names
    public static func logNameFilter(projectID: String, logNames: [String]) -> String {
        let logFilters = logNames.map { "logName=\"projects/\(projectID)/logs/\($0)\"" }
        return logFilters.joined(separator: " OR ")
    }

    /// Generate a severity filter
    public static func severityFilter(minSeverity: LogSeverity) -> String {
        "severity >= \(minSeverity.rawValue)"
    }

    /// Generate a time range filter
    public static func timeRangeFilter(start: Date, end: Date? = nil) -> String {
        let formatter = ISO8601DateFormatter()
        var filter = "timestamp >= \"\(formatter.string(from: start))\""
        if let end = end {
            filter += " AND timestamp <= \"\(formatter.string(from: end))\""
        }
        return filter
    }

    /// Common resource types
    public enum ResourceType: String, Sendable {
        case gceInstance = "gce_instance"
        case cloudFunction = "cloud_function"
        case cloudRunRevision = "cloud_run_revision"
        case cloudRunJob = "cloud_run_job"
        case gkeContainer = "k8s_container"
        case gkePod = "k8s_pod"
        case gkeCluster = "k8s_cluster"
        case cloudSQLDatabase = "cloudsql_database"
        case pubsubTopic = "pubsub_topic"
        case pubsubSubscription = "pubsub_subscription"
        case global = "global"
    }
}

// MARK: - Log Alert Policy

/// Represents a log-based alert policy configuration.
///
/// While alerts are created in Cloud Monitoring, this provides
/// the log-based metric configuration needed for alerts.
public struct LogAlertConfiguration: Codable, Sendable, Equatable {
    /// Name for the alert
    public let name: String

    /// Metric to alert on
    public let metric: GoogleCloudLogMetric

    /// Threshold value
    public let threshold: Double

    /// Comparison type
    public let comparison: Comparison

    /// Duration for the condition
    public let duration: String

    /// Notification channels
    public let notificationChannels: [String]

    public init(
        name: String,
        metric: GoogleCloudLogMetric,
        threshold: Double,
        comparison: Comparison = .greaterThan,
        duration: String = "60s",
        notificationChannels: [String] = []
    ) {
        self.name = name
        self.metric = metric
        self.threshold = threshold
        self.comparison = comparison
        self.duration = duration
        self.notificationChannels = notificationChannels
    }

    public enum Comparison: String, Codable, Sendable {
        case greaterThan = "COMPARISON_GT"
        case greaterThanOrEqual = "COMPARISON_GE"
        case lessThan = "COMPARISON_LT"
        case lessThanOrEqual = "COMPARISON_LE"
        case equal = "COMPARISON_EQ"
        case notEqual = "COMPARISON_NE"
    }
}

// MARK: - Predefined Log Filters

/// Common log filters for Cloud Logging.
public enum PredefinedLogFilter {
    /// Filter for errors only
    public static let errorsOnly = "severity >= ERROR"

    /// Filter for warnings and above
    public static let warningsAndAbove = "severity >= WARNING"

    /// Filter for HTTP 5xx errors
    public static let http5xxErrors = "httpRequest.status >= 500"

    /// Filter for HTTP 4xx errors
    public static let http4xxErrors = "httpRequest.status >= 400 AND httpRequest.status < 500"

    /// Filter for slow requests (> 1 second)
    public static let slowRequests = "httpRequest.latency > \"1s\""

    /// Filter for Cloud Run requests
    public static let cloudRunRequests = "resource.type = \"cloud_run_revision\""

    /// Filter for Cloud Functions
    public static let cloudFunctions = "resource.type = \"cloud_function\""

    /// Filter for GCE instances
    public static let gceInstances = "resource.type = \"gce_instance\""

    /// Filter for GKE containers
    public static let gkeContainers = "resource.type = \"k8s_container\""

    /// Filter for audit logs
    public static let auditLogs = "logName =~ \"cloudaudit.googleapis.com\""

    /// Filter for data access logs
    public static let dataAccessLogs = "logName =~ \"data_access\""
}

// MARK: - DAIS Logging Templates

/// Predefined logging configurations for DAIS deployments.
public enum DAISLoggingTemplate {
    /// Create a log sink for DAIS error logs to BigQuery
    public static func errorLogsSink(
        projectID: String,
        deploymentName: String,
        datasetID: String
    ) -> GoogleCloudLogSink {
        GoogleCloudLogSink(
            name: "\(deploymentName)-error-logs",
            projectID: projectID,
            destination: .bigQuery(datasetID: datasetID),
            filter: "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND severity >= ERROR",
            description: "Export DAIS error logs to BigQuery for analysis"
        )
    }

    /// Create a log sink for DAIS audit logs to Cloud Storage
    public static func auditLogsSink(
        projectID: String,
        deploymentName: String,
        bucketName: String
    ) -> GoogleCloudLogSink {
        GoogleCloudLogSink(
            name: "\(deploymentName)-audit-logs",
            projectID: projectID,
            destination: .storage(bucketName: bucketName),
            filter: "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND logName =~ \"audit\"",
            description: "Archive DAIS audit logs to Cloud Storage"
        )
    }

    /// Create a log bucket for DAIS logs with extended retention
    public static func logBucket(
        projectID: String,
        deploymentName: String,
        location: String,
        retentionDays: Int = 90
    ) -> GoogleCloudLogBucket {
        GoogleCloudLogBucket(
            name: "\(deploymentName)-logs",
            projectID: projectID,
            location: location,
            retentionDays: retentionDays,
            description: "DAIS deployment logs with extended retention",
            analyticsEnabled: true
        )
    }

    /// Create a log view for DAIS errors only
    public static func errorLogsView(
        projectID: String,
        deploymentName: String,
        location: String
    ) -> GoogleCloudLogView {
        GoogleCloudLogView(
            name: "\(deploymentName)-errors",
            bucketName: "_Default",
            projectID: projectID,
            location: location,
            filter: "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND severity >= ERROR",
            description: "View for DAIS error logs only"
        )
    }

    /// Create an exclusion for DAIS debug logs in production
    public static func debugLogExclusion(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudLogExclusion {
        GoogleCloudLogExclusion(
            name: "\(deploymentName)-exclude-debug",
            projectID: projectID,
            filter: "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND severity = DEBUG",
            description: "Exclude debug logs from DAIS production deployment"
        )
    }

    /// Create error count metric for DAIS
    public static func errorCountMetric(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudLogMetric {
        GoogleCloudLogMetric(
            name: "\(deploymentName)-error-count",
            projectID: projectID,
            filter: "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND severity >= ERROR",
            description: "Count of errors in DAIS deployment",
            metricType: .counter,
            labelExtractors: [
                "node": "EXTRACT(labels.node)",
                "component": "EXTRACT(labels.component)"
            ]
        )
    }

    /// Create latency metric for DAIS gRPC calls
    public static func grpcLatencyMetric(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudLogMetric {
        GoogleCloudLogMetric(
            name: "\(deploymentName)-grpc-latency",
            projectID: projectID,
            filter: "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND labels.type=\"grpc\"",
            description: "gRPC call latency distribution",
            metricType: .distribution,
            valueExtractor: "EXTRACT(jsonPayload.latency_ms)",
            bucketOptions: GoogleCloudLogMetric.BucketOptions(
                type: .exponential(numBuckets: 20, growthFactor: 2, scale: 1)
            ),
            labelExtractors: [
                "method": "EXTRACT(labels.method)",
                "status": "EXTRACT(labels.status)"
            ]
        )
    }

    /// Generate a complete DAIS logging setup script
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        location: String,
        bigQueryDataset: String? = nil,
        storageBucket: String? = nil
    ) -> String {
        var script = """
        #!/bin/bash
        # DAIS Logging Setup Script
        # Deployment: \(deploymentName)
        # Project: \(projectID)

        set -e

        echo "========================================"
        echo "DAIS Logging Configuration"
        echo "========================================"

        # Enable Cloud Logging API
        echo "Enabling Cloud Logging API..."
        gcloud services enable logging.googleapis.com --project=\(projectID)

        """

        // Add log bucket
        let bucket = logBucket(projectID: projectID, deploymentName: deploymentName, location: location)
        script += """

        # Create log bucket with extended retention
        echo "Creating log bucket..."
        \(bucket.createCommand) || echo "Bucket may already exist"

        """

        // Add error view
        let view = errorLogsView(projectID: projectID, deploymentName: deploymentName, location: location)
        script += """

        # Create error logs view
        echo "Creating error logs view..."
        \(view.createCommand) || echo "View may already exist"

        """

        // Add debug exclusion
        let exclusion = debugLogExclusion(projectID: projectID, deploymentName: deploymentName)
        script += """

        # Create debug log exclusion
        echo "Creating debug log exclusion..."
        \(exclusion.createCommand) || echo "Exclusion may already exist"

        """

        // Add error metric
        let errorMetric = errorCountMetric(projectID: projectID, deploymentName: deploymentName)
        script += """

        # Create error count metric
        echo "Creating error count metric..."
        \(errorMetric.createCommand) || echo "Metric may already exist"

        """

        // Add BigQuery sink if dataset provided
        if let dataset = bigQueryDataset {
            let sink = errorLogsSink(projectID: projectID, deploymentName: deploymentName, datasetID: dataset)
            script += """

            # Create BigQuery sink for error logs
            echo "Creating BigQuery log sink..."
            \(sink.createCommand) || echo "Sink may already exist"

            """
        }

        // Add Storage sink if bucket provided
        if let bucket = storageBucket {
            let sink = auditLogsSink(projectID: projectID, deploymentName: deploymentName, bucketName: bucket)
            script += """

            # Create Cloud Storage sink for audit logs
            echo "Creating Cloud Storage log sink..."
            \(sink.createCommand) || echo "Sink may already exist"

            """
        }

        script += """

        echo ""
        echo "Logging configuration complete!"
        echo ""
        echo "View logs: gcloud logging read 'labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\"' --project=\(projectID) --limit=50"
        echo "View errors: gcloud logging read 'labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\" AND severity >= ERROR' --project=\(projectID)"
        """

        return script
    }

    /// Common log queries for DAIS
    public static func daisLogQuery(
        projectID: String,
        deploymentName: String,
        nodeName: String? = nil,
        component: String? = nil,
        minSeverity: LogSeverity = .info
    ) -> String {
        var filter = "labels.app=\"butteryai\" AND labels.deployment=\"\(deploymentName)\""
        filter += " AND severity >= \(minSeverity.rawValue)"
        if let node = nodeName {
            filter += " AND labels.node=\"\(node)\""
        }
        if let component = component {
            filter += " AND labels.component=\"\(component)\""
        }
        return filter
    }
}

// MARK: - Structured Logging Helper

/// Helper for creating structured log entries.
public struct StructuredLogEntry: Codable, Sendable, Equatable {
    public let message: String
    public let severity: LogSeverity
    public let component: String?
    public let requestID: String?
    public let userID: String?
    public let latencyMs: Double?
    public let errorCode: String?
    public let metadata: [String: String]

    public init(
        message: String,
        severity: LogSeverity = .info,
        component: String? = nil,
        requestID: String? = nil,
        userID: String? = nil,
        latencyMs: Double? = nil,
        errorCode: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.message = message
        self.severity = severity
        self.component = component
        self.requestID = requestID
        self.userID = userID
        self.latencyMs = latencyMs
        self.errorCode = errorCode
        self.metadata = metadata
    }

    /// Convert to JSON string for logging
    public var jsonString: String {
        var dict: [String: Any] = [
            "message": message,
            "severity": severity.rawValue
        ]
        if let component = component { dict["component"] = component }
        if let requestID = requestID { dict["requestId"] = requestID }
        if let userID = userID { dict["userId"] = userID }
        if let latencyMs = latencyMs { dict["latencyMs"] = latencyMs }
        if let errorCode = errorCode { dict["errorCode"] = errorCode }
        for (key, value) in metadata {
            dict[key] = value
        }

        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{\"message\": \"\(message)\"}"
    }
}
