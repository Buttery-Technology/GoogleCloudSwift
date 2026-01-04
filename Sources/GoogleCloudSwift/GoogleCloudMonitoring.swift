//
//  GoogleCloudMonitoring.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

// MARK: - Alert Policy

/// Represents an alerting policy in Cloud Monitoring.
///
/// Alert policies define conditions that trigger alerts and the notification
/// channels to use when alerts fire.
///
/// ## Example Usage
/// ```swift
/// let policy = GoogleCloudAlertPolicy(
///     displayName: "High CPU Usage",
///     projectID: "my-project",
///     conditions: [
///         .threshold(
///             displayName: "CPU > 80%",
///             filter: "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
///             comparison: .greaterThan,
///             threshold: 0.8,
///             duration: "300s"
///         )
///     ],
///     notificationChannels: ["projects/my-project/notificationChannels/123"]
/// )
/// print(policy.createCommand)
/// ```
public struct GoogleCloudAlertPolicy: Codable, Sendable, Equatable {
    /// Display name for the policy
    public let displayName: String

    /// Project ID
    public let projectID: String

    /// Conditions that trigger the alert
    public let conditions: [AlertCondition]

    /// How to combine multiple conditions
    public let combiner: ConditionCombiner

    /// Notification channels to alert
    public let notificationChannels: [String]

    /// Documentation for the alert
    public let documentation: AlertDocumentation?

    /// Whether the policy is enabled
    public let enabled: Bool

    /// User-defined labels
    public let userLabels: [String: String]

    /// Severity of the alert
    public let severity: AlertSeverity?

    public init(
        displayName: String,
        projectID: String,
        conditions: [AlertCondition],
        combiner: ConditionCombiner = .or,
        notificationChannels: [String] = [],
        documentation: AlertDocumentation? = nil,
        enabled: Bool = true,
        userLabels: [String: String] = [:],
        severity: AlertSeverity? = nil
    ) {
        self.displayName = displayName
        self.projectID = projectID
        self.conditions = conditions
        self.combiner = combiner
        self.notificationChannels = notificationChannels
        self.documentation = documentation
        self.enabled = enabled
        self.userLabels = userLabels
        self.severity = severity
    }

    /// gcloud command to create this policy (requires JSON file)
    public var createCommand: String {
        "gcloud alpha monitoring policies create --policy-from-file=policy.json --project=\(projectID)"
    }

    /// gcloud command to list policies
    public static func listCommand(projectID: String) -> String {
        "gcloud alpha monitoring policies list --project=\(projectID)"
    }

    /// gcloud command to describe a policy
    public static func describeCommand(policyID: String, projectID: String) -> String {
        "gcloud alpha monitoring policies describe \(policyID) --project=\(projectID)"
    }

    /// gcloud command to delete a policy
    public static func deleteCommand(policyID: String, projectID: String) -> String {
        "gcloud alpha monitoring policies delete \(policyID) --project=\(projectID) --quiet"
    }

    /// gcloud command to enable/disable a policy
    public static func updateEnabledCommand(policyID: String, projectID: String, enabled: Bool) -> String {
        "gcloud alpha monitoring policies update \(policyID) --project=\(projectID) --\(enabled ? "enabled" : "no-enabled")"
    }

    /// How to combine conditions
    public enum ConditionCombiner: String, Codable, Sendable {
        /// Alert when any condition is met
        case or = "OR"
        /// Alert when all conditions are met
        case and = "AND"
        /// Alert when all conditions are met simultaneously
        case andWithMatchingResource = "AND_WITH_MATCHING_RESOURCE"
    }

    /// Alert severity levels
    public enum AlertSeverity: String, Codable, Sendable {
        case critical = "CRITICAL"
        case error = "ERROR"
        case warning = "WARNING"
    }
}

// MARK: - Alert Condition

/// Represents a condition that can trigger an alert.
public enum AlertCondition: Codable, Sendable, Equatable {
    /// Threshold-based condition
    case threshold(
        displayName: String,
        filter: String,
        comparison: ComparisonType,
        threshold: Double,
        duration: String,
        aggregation: Aggregation?
    )

    /// Absence-based condition (no data)
    case absence(
        displayName: String,
        filter: String,
        duration: String
    )

    /// Log match condition
    case logMatch(
        displayName: String,
        filter: String,
        labelExtractors: [String: String]
    )

    /// Monitoring Query Language (MQL) condition
    case mql(
        displayName: String,
        query: String,
        duration: String
    )

    /// Prometheus Query Language (PromQL) condition
    case promql(
        displayName: String,
        query: String,
        duration: String,
        evaluationInterval: String?
    )

    /// Convenience initializer for threshold condition
    public static func threshold(
        displayName: String,
        filter: String,
        comparison: ComparisonType,
        threshold: Double,
        duration: String
    ) -> AlertCondition {
        .threshold(
            displayName: displayName,
            filter: filter,
            comparison: comparison,
            threshold: threshold,
            duration: duration,
            aggregation: nil
        )
    }

    /// Comparison types for threshold conditions
    public enum ComparisonType: String, Codable, Sendable {
        case greaterThan = "COMPARISON_GT"
        case greaterThanOrEqual = "COMPARISON_GE"
        case lessThan = "COMPARISON_LT"
        case lessThanOrEqual = "COMPARISON_LE"
        case equal = "COMPARISON_EQ"
        case notEqual = "COMPARISON_NE"
    }

    /// Aggregation configuration
    public struct Aggregation: Codable, Sendable, Equatable {
        public let alignmentPeriod: String
        public let perSeriesAligner: Aligner
        public let crossSeriesReducer: Reducer?
        public let groupByFields: [String]

        public init(
            alignmentPeriod: String = "60s",
            perSeriesAligner: Aligner = .alignMean,
            crossSeriesReducer: Reducer? = nil,
            groupByFields: [String] = []
        ) {
            self.alignmentPeriod = alignmentPeriod
            self.perSeriesAligner = perSeriesAligner
            self.crossSeriesReducer = crossSeriesReducer
            self.groupByFields = groupByFields
        }

        /// Time series aligners
        public enum Aligner: String, Codable, Sendable {
            case alignNone = "ALIGN_NONE"
            case alignDelta = "ALIGN_DELTA"
            case alignRate = "ALIGN_RATE"
            case alignInterpolate = "ALIGN_INTERPOLATE"
            case alignNextOlder = "ALIGN_NEXT_OLDER"
            case alignMin = "ALIGN_MIN"
            case alignMax = "ALIGN_MAX"
            case alignMean = "ALIGN_MEAN"
            case alignCount = "ALIGN_COUNT"
            case alignSum = "ALIGN_SUM"
            case alignStddev = "ALIGN_STDDEV"
            case alignCountTrue = "ALIGN_COUNT_TRUE"
            case alignCountFalse = "ALIGN_COUNT_FALSE"
            case alignFractionTrue = "ALIGN_FRACTION_TRUE"
            case alignPercentile99 = "ALIGN_PERCENTILE_99"
            case alignPercentile95 = "ALIGN_PERCENTILE_95"
            case alignPercentile50 = "ALIGN_PERCENTILE_50"
            case alignPercentChange = "ALIGN_PERCENT_CHANGE"
        }

        /// Cross-series reducers
        public enum Reducer: String, Codable, Sendable {
            case reduceNone = "REDUCE_NONE"
            case reduceMean = "REDUCE_MEAN"
            case reduceMin = "REDUCE_MIN"
            case reduceMax = "REDUCE_MAX"
            case reduceSum = "REDUCE_SUM"
            case reduceStddev = "REDUCE_STDDEV"
            case reduceCount = "REDUCE_COUNT"
            case reduceCountTrue = "REDUCE_COUNT_TRUE"
            case reduceCountFalse = "REDUCE_COUNT_FALSE"
            case reduceFractionTrue = "REDUCE_FRACTION_TRUE"
            case reducePercentile99 = "REDUCE_PERCENTILE_99"
            case reducePercentile95 = "REDUCE_PERCENTILE_95"
            case reducePercentile50 = "REDUCE_PERCENTILE_50"
        }
    }
}

// MARK: - Alert Documentation

/// Documentation attached to an alert policy.
public struct AlertDocumentation: Codable, Sendable, Equatable {
    /// Content of the documentation (supports Markdown)
    public let content: String

    /// MIME type of the content
    public let mimeType: String

    /// Subject line for notifications
    public let subject: String?

    public init(
        content: String,
        mimeType: String = "text/markdown",
        subject: String? = nil
    ) {
        self.content = content
        self.mimeType = mimeType
        self.subject = subject
    }
}

// MARK: - Notification Channel

/// Represents a notification channel in Cloud Monitoring.
///
/// Notification channels define how alerts are delivered (email, SMS, etc.).
///
/// ## Example Usage
/// ```swift
/// let emailChannel = GoogleCloudNotificationChannel(
///     displayName: "On-Call Team",
///     projectID: "my-project",
///     type: .email,
///     labels: ["email_address": "oncall@example.com"]
/// )
/// print(emailChannel.createCommand)
/// ```
public struct GoogleCloudNotificationChannel: Codable, Sendable, Equatable {
    /// Display name for the channel
    public let displayName: String

    /// Project ID
    public let projectID: String

    /// Type of notification channel
    public let type: ChannelType

    /// Labels for the channel (type-specific)
    public let labels: [String: String]

    /// Description of the channel
    public let description: String?

    /// Whether the channel is enabled
    public let enabled: Bool

    /// User-defined labels
    public let userLabels: [String: String]

    public init(
        displayName: String,
        projectID: String,
        type: ChannelType,
        labels: [String: String] = [:],
        description: String? = nil,
        enabled: Bool = true,
        userLabels: [String: String] = [:]
    ) {
        self.displayName = displayName
        self.projectID = projectID
        self.type = type
        self.labels = labels
        self.description = description
        self.enabled = enabled
        self.userLabels = userLabels
    }

    /// gcloud command to create this channel
    public var createCommand: String {
        var cmd = "gcloud alpha monitoring channels create"
        cmd += " --display-name=\"\(displayName)\""
        cmd += " --type=\(type.rawValue)"
        cmd += " --project=\(projectID)"
        for (key, value) in labels {
            cmd += " --channel-labels=\(key)=\(value)"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if !enabled {
            cmd += " --no-enabled"
        }
        return cmd
    }

    /// gcloud command to list channels
    public static func listCommand(projectID: String) -> String {
        "gcloud alpha monitoring channels list --project=\(projectID)"
    }

    /// gcloud command to describe a channel
    public static func describeCommand(channelID: String, projectID: String) -> String {
        "gcloud alpha monitoring channels describe \(channelID) --project=\(projectID)"
    }

    /// gcloud command to delete a channel
    public static func deleteCommand(channelID: String, projectID: String) -> String {
        "gcloud alpha monitoring channels delete \(channelID) --project=\(projectID) --quiet"
    }

    /// gcloud command to verify a channel
    public static func verifyCommand(channelID: String, projectID: String) -> String {
        "gcloud alpha monitoring channels verify \(channelID) --project=\(projectID)"
    }

    /// Notification channel types
    public enum ChannelType: String, Codable, Sendable {
        case email = "email"
        case sms = "sms"
        case slack = "slack"
        case pagerDuty = "pagerduty"
        case webhook = "webhook_tokenauth"
        case webhookBasicAuth = "webhook_basicauth"
        case pubsub = "pubsub"
        case campfire = "campfire"
        case hipchat = "hipchat"
    }

    /// Create an email notification channel
    public static func email(
        displayName: String,
        projectID: String,
        emailAddress: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel(
            displayName: displayName,
            projectID: projectID,
            type: .email,
            labels: ["email_address": emailAddress]
        )
    }

    /// Create a Slack notification channel
    public static func slack(
        displayName: String,
        projectID: String,
        channelName: String,
        authToken: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel(
            displayName: displayName,
            projectID: projectID,
            type: .slack,
            labels: ["channel_name": channelName, "auth_token": authToken]
        )
    }

    /// Create a PagerDuty notification channel
    public static func pagerDuty(
        displayName: String,
        projectID: String,
        serviceKey: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel(
            displayName: displayName,
            projectID: projectID,
            type: .pagerDuty,
            labels: ["service_key": serviceKey]
        )
    }

    /// Create a webhook notification channel
    public static func webhook(
        displayName: String,
        projectID: String,
        url: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel(
            displayName: displayName,
            projectID: projectID,
            type: .webhook,
            labels: ["url": url]
        )
    }

    /// Create a Pub/Sub notification channel
    public static func pubsub(
        displayName: String,
        projectID: String,
        topic: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel(
            displayName: displayName,
            projectID: projectID,
            type: .pubsub,
            labels: ["topic": topic]
        )
    }
}

// MARK: - Uptime Check

/// Represents an uptime check configuration in Cloud Monitoring.
///
/// Uptime checks verify that your services are responding correctly.
///
/// ## Example Usage
/// ```swift
/// let check = GoogleCloudUptimeCheck(
///     displayName: "API Health Check",
///     projectID: "my-project",
///     monitoredResource: .uptime(host: "api.example.com"),
///     httpCheck: .init(
///         path: "/health",
///         port: 443,
///         useSsl: true,
///         validateSsl: true
///     ),
///     period: .oneMinute
/// )
/// print(check.createCommand)
/// ```
public struct GoogleCloudUptimeCheck: Codable, Sendable, Equatable {
    /// Display name for the check
    public let displayName: String

    /// Project ID
    public let projectID: String

    /// Resource to monitor
    public let monitoredResource: MonitoredResource

    /// HTTP check configuration
    public let httpCheck: HTTPCheckConfig?

    /// TCP check configuration
    public let tcpCheck: TCPCheckConfig?

    /// Check period
    public let period: CheckPeriod

    /// Timeout for each check
    public let timeout: String

    /// Regions to check from
    public let selectedRegions: [CheckRegion]

    /// Content matchers
    public let contentMatchers: [ContentMatcher]

    public init(
        displayName: String,
        projectID: String,
        monitoredResource: MonitoredResource,
        httpCheck: HTTPCheckConfig? = nil,
        tcpCheck: TCPCheckConfig? = nil,
        period: CheckPeriod = .oneMinute,
        timeout: String = "10s",
        selectedRegions: [CheckRegion] = [],
        contentMatchers: [ContentMatcher] = []
    ) {
        self.displayName = displayName
        self.projectID = projectID
        self.monitoredResource = monitoredResource
        self.httpCheck = httpCheck
        self.tcpCheck = tcpCheck
        self.period = period
        self.timeout = timeout
        self.selectedRegions = selectedRegions
        self.contentMatchers = contentMatchers
    }

    /// gcloud command to create this uptime check
    public var createCommand: String {
        var cmd = "gcloud alpha monitoring uptime create \"\(displayName)\""
        cmd += " --project=\(projectID)"

        switch monitoredResource {
        case .uptime(let host):
            cmd += " --resource-type=uptime-url"
            cmd += " --resource-labels=host=\(host)"
        case .instance(let projectID, let instanceID, let zone):
            cmd += " --resource-type=gce-instance"
            cmd += " --resource-labels=project_id=\(projectID),instance_id=\(instanceID),zone=\(zone)"
        case .appEngine(let projectID, let moduleID):
            cmd += " --resource-type=gae-app"
            cmd += " --resource-labels=project_id=\(projectID),module_id=\(moduleID)"
        case .cloudRun(let projectID, let serviceName, let location):
            cmd += " --resource-type=cloud-run-revision"
            cmd += " --resource-labels=project_id=\(projectID),service_name=\(serviceName),location=\(location)"
        }

        if let http = httpCheck {
            cmd += " --protocol=\(http.useSsl ? "https" : "http")"
            cmd += " --port=\(http.port)"
            if let path = http.path {
                cmd += " --path=\(path)"
            }
        } else if let tcp = tcpCheck {
            cmd += " --protocol=tcp"
            cmd += " --port=\(tcp.port)"
        }

        cmd += " --period=\(period.rawValue)"
        cmd += " --timeout=\(timeout)"

        return cmd
    }

    /// gcloud command to list uptime checks
    public static func listCommand(projectID: String) -> String {
        "gcloud alpha monitoring uptime list-configs --project=\(projectID)"
    }

    /// gcloud command to describe an uptime check
    public static func describeCommand(checkID: String, projectID: String) -> String {
        "gcloud alpha monitoring uptime describe \(checkID) --project=\(projectID)"
    }

    /// gcloud command to delete an uptime check
    public static func deleteCommand(checkID: String, projectID: String) -> String {
        "gcloud alpha monitoring uptime delete \(checkID) --project=\(projectID) --quiet"
    }

    /// Check period options
    public enum CheckPeriod: String, Codable, Sendable {
        case oneMinute = "60s"
        case fiveMinutes = "300s"
        case tenMinutes = "600s"
        case fifteenMinutes = "900s"
    }

    /// Regions for uptime checks
    public enum CheckRegion: String, Codable, Sendable {
        case usa = "USA"
        case europe = "EUROPE"
        case southAmerica = "SOUTH_AMERICA"
        case asiaPacific = "ASIA_PACIFIC"
    }

    /// Monitored resource types
    public enum MonitoredResource: Codable, Sendable, Equatable {
        case uptime(host: String)
        case instance(projectID: String, instanceID: String, zone: String)
        case appEngine(projectID: String, moduleID: String)
        case cloudRun(projectID: String, serviceName: String, location: String)
    }

    /// HTTP check configuration
    public struct HTTPCheckConfig: Codable, Sendable, Equatable {
        public let path: String?
        public let port: Int
        public let useSsl: Bool
        public let validateSsl: Bool
        public let requestMethod: HTTPMethod
        public let headers: [String: String]
        public let body: String?
        public let acceptedResponseStatusCodes: [StatusCodeRange]

        public init(
            path: String? = "/",
            port: Int = 443,
            useSsl: Bool = true,
            validateSsl: Bool = true,
            requestMethod: HTTPMethod = .get,
            headers: [String: String] = [:],
            body: String? = nil,
            acceptedResponseStatusCodes: [StatusCodeRange] = []
        ) {
            self.path = path
            self.port = port
            self.useSsl = useSsl
            self.validateSsl = validateSsl
            self.requestMethod = requestMethod
            self.headers = headers
            self.body = body
            self.acceptedResponseStatusCodes = acceptedResponseStatusCodes
        }

        public enum HTTPMethod: String, Codable, Sendable {
            case get = "GET"
            case post = "POST"
        }

        public struct StatusCodeRange: Codable, Sendable, Equatable {
            public let statusClass: StatusClass?
            public let statusValue: Int?

            public enum StatusClass: String, Codable, Sendable {
                case informational = "STATUS_CLASS_1XX"
                case success = "STATUS_CLASS_2XX"
                case redirect = "STATUS_CLASS_3XX"
                case clientError = "STATUS_CLASS_4XX"
                case serverError = "STATUS_CLASS_5XX"
                case any = "STATUS_CLASS_ANY"
            }

            public init(statusClass: StatusClass) {
                self.statusClass = statusClass
                self.statusValue = nil
            }

            public init(statusValue: Int) {
                self.statusClass = nil
                self.statusValue = statusValue
            }
        }
    }

    /// TCP check configuration
    public struct TCPCheckConfig: Codable, Sendable, Equatable {
        public let port: Int

        public init(port: Int) {
            self.port = port
        }
    }

    /// Content matcher for response validation
    public struct ContentMatcher: Codable, Sendable, Equatable {
        public let content: String
        public let matcher: MatcherType

        public init(content: String, matcher: MatcherType = .contains) {
            self.content = content
            self.matcher = matcher
        }

        public enum MatcherType: String, Codable, Sendable {
            case contains = "CONTAINS_STRING"
            case notContains = "NOT_CONTAINS_STRING"
            case matchesRegex = "MATCHES_REGEX"
            case notMatchesRegex = "NOT_MATCHES_REGEX"
            case matchesJsonPath = "MATCHES_JSON_PATH"
            case notMatchesJsonPath = "NOT_MATCHES_JSON_PATH"
        }
    }
}

// MARK: - Custom Metric

/// Represents a custom metric descriptor in Cloud Monitoring.
///
/// Custom metrics allow you to create your own metrics for monitoring.
///
/// ## Example Usage
/// ```swift
/// let metric = GoogleCloudMetricDescriptor(
///     type: "custom.googleapis.com/my_app/request_count",
///     projectID: "my-project",
///     metricKind: .cumulative,
///     valueType: .int64,
///     description: "Number of requests processed"
/// )
/// print(metric.createCommand)
/// ```
public struct GoogleCloudMetricDescriptor: Codable, Sendable, Equatable {
    /// Metric type (e.g., "custom.googleapis.com/my_app/requests")
    public let type: String

    /// Project ID
    public let projectID: String

    /// Kind of metric
    public let metricKind: MetricKind

    /// Value type
    public let valueType: ValueType

    /// Unit of measurement
    public let unit: String?

    /// Description of the metric
    public let description: String?

    /// Display name
    public let displayName: String?

    /// Labels for the metric
    public let labels: [LabelDescriptor]

    /// Launch stage
    public let launchStage: LaunchStage

    public init(
        type: String,
        projectID: String,
        metricKind: MetricKind,
        valueType: ValueType,
        unit: String? = nil,
        description: String? = nil,
        displayName: String? = nil,
        labels: [LabelDescriptor] = [],
        launchStage: LaunchStage = .ga
    ) {
        self.type = type
        self.projectID = projectID
        self.metricKind = metricKind
        self.valueType = valueType
        self.unit = unit
        self.description = description
        self.displayName = displayName
        self.labels = labels
        self.launchStage = launchStage
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/metricDescriptors/\(type)"
    }

    /// gcloud command to create this metric descriptor
    public var createCommand: String {
        var cmd = "gcloud alpha monitoring metrics-descriptors create \(type)"
        cmd += " --project=\(projectID)"
        cmd += " --metric-kind=\(metricKind.rawValue)"
        cmd += " --value-type=\(valueType.rawValue)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }
        if let unit = unit {
            cmd += " --unit=\"\(unit)\""
        }
        return cmd
    }

    /// gcloud command to list metric descriptors
    public static func listCommand(projectID: String, filter: String? = nil) -> String {
        var cmd = "gcloud alpha monitoring metrics-descriptors list --project=\(projectID)"
        if let filter = filter {
            cmd += " --filter=\"\(filter)\""
        }
        return cmd
    }

    /// gcloud command to describe a metric descriptor
    public static func describeCommand(type: String, projectID: String) -> String {
        "gcloud alpha monitoring metrics-descriptors describe \(type) --project=\(projectID)"
    }

    /// gcloud command to delete a metric descriptor
    public static func deleteCommand(type: String, projectID: String) -> String {
        "gcloud alpha monitoring metrics-descriptors delete \(type) --project=\(projectID) --quiet"
    }

    /// Metric kinds
    public enum MetricKind: String, Codable, Sendable {
        /// Instantaneous measurement
        case gauge = "GAUGE"
        /// Change over time (always increasing)
        case cumulative = "CUMULATIVE"
        /// Change since last measurement
        case delta = "DELTA"
    }

    /// Value types
    public enum ValueType: String, Codable, Sendable {
        case bool = "BOOL"
        case int64 = "INT64"
        case double = "DOUBLE"
        case string = "STRING"
        case distribution = "DISTRIBUTION"
        case money = "MONEY"
    }

    /// Label descriptor
    public struct LabelDescriptor: Codable, Sendable, Equatable {
        public let key: String
        public let valueType: LabelValueType
        public let description: String?

        public init(key: String, valueType: LabelValueType = .string, description: String? = nil) {
            self.key = key
            self.valueType = valueType
            self.description = description
        }

        public enum LabelValueType: String, Codable, Sendable {
            case string = "STRING"
            case bool = "BOOL"
            case int64 = "INT64"
        }
    }

    /// Launch stage
    public enum LaunchStage: String, Codable, Sendable {
        case unimplemented = "UNIMPLEMENTED"
        case prelaunch = "PRELAUNCH"
        case earlyAccess = "EARLY_ACCESS"
        case alpha = "ALPHA"
        case beta = "BETA"
        case ga = "GA"
        case deprecated = "DEPRECATED"
    }
}

// MARK: - Dashboard

/// Represents a dashboard in Cloud Monitoring.
///
/// Dashboards provide visualizations of your metrics and logs.
public struct GoogleCloudDashboard: Codable, Sendable, Equatable {
    /// Display name
    public let displayName: String

    /// Project ID
    public let projectID: String

    /// Dashboard layout
    public let layout: DashboardLayout

    /// Labels
    public let labels: [String: String]

    public init(
        displayName: String,
        projectID: String,
        layout: DashboardLayout = .grid(columns: 2),
        labels: [String: String] = [:]
    ) {
        self.displayName = displayName
        self.projectID = projectID
        self.layout = layout
        self.labels = labels
    }

    /// gcloud command to create a dashboard (requires JSON file)
    public var createCommand: String {
        "gcloud monitoring dashboards create --config-from-file=dashboard.json --project=\(projectID)"
    }

    /// gcloud command to list dashboards
    public static func listCommand(projectID: String) -> String {
        "gcloud monitoring dashboards list --project=\(projectID)"
    }

    /// gcloud command to describe a dashboard
    public static func describeCommand(dashboardID: String, projectID: String) -> String {
        "gcloud monitoring dashboards describe \(dashboardID) --project=\(projectID)"
    }

    /// gcloud command to delete a dashboard
    public static func deleteCommand(dashboardID: String, projectID: String) -> String {
        "gcloud monitoring dashboards delete \(dashboardID) --project=\(projectID) --quiet"
    }

    /// Dashboard layout types
    public enum DashboardLayout: Codable, Sendable, Equatable {
        case grid(columns: Int)
        case mosaic
        case row
        case column
    }
}

// MARK: - Group

/// Represents a resource group in Cloud Monitoring.
///
/// Groups allow you to organize and monitor related resources together.
public struct GoogleCloudMonitoringGroup: Codable, Sendable, Equatable {
    /// Display name
    public let displayName: String

    /// Project ID
    public let projectID: String

    /// Filter for group membership
    public let filter: String

    /// Parent group name (for subgroups)
    public let parentName: String?

    /// Whether this is a cluster
    public let isCluster: Bool

    public init(
        displayName: String,
        projectID: String,
        filter: String,
        parentName: String? = nil,
        isCluster: Bool = false
    ) {
        self.displayName = displayName
        self.projectID = projectID
        self.filter = filter
        self.parentName = parentName
        self.isCluster = isCluster
    }

    /// gcloud command to create a group
    public var createCommand: String {
        var cmd = "gcloud alpha monitoring groups create"
        cmd += " --display-name=\"\(displayName)\""
        cmd += " --filter=\"\(filter)\""
        cmd += " --project=\(projectID)"
        if let parent = parentName {
            cmd += " --parent-name=\(parent)"
        }
        if isCluster {
            cmd += " --is-cluster"
        }
        return cmd
    }

    /// gcloud command to list groups
    public static func listCommand(projectID: String) -> String {
        "gcloud alpha monitoring groups list --project=\(projectID)"
    }

    /// gcloud command to describe a group
    public static func describeCommand(groupID: String, projectID: String) -> String {
        "gcloud alpha monitoring groups describe \(groupID) --project=\(projectID)"
    }

    /// gcloud command to delete a group
    public static func deleteCommand(groupID: String, projectID: String) -> String {
        "gcloud alpha monitoring groups delete \(groupID) --project=\(projectID) --quiet"
    }
}

// MARK: - Service Level Objective (SLO)

/// Represents a Service Level Objective in Cloud Monitoring.
///
/// SLOs define targets for service reliability and performance.
public struct GoogleCloudSLO: Codable, Sendable, Equatable {
    /// Display name
    public let displayName: String

    /// Service name
    public let serviceName: String

    /// Project ID
    public let projectID: String

    /// Goal (0.0 to 1.0)
    public let goal: Double

    /// Rolling period (e.g., "30d")
    public let rollingPeriod: String?

    /// Calendar period
    public let calendarPeriod: CalendarPeriod?

    /// Service Level Indicator
    public let sli: ServiceLevelIndicator

    public init(
        displayName: String,
        serviceName: String,
        projectID: String,
        goal: Double,
        rollingPeriod: String? = "30d",
        calendarPeriod: CalendarPeriod? = nil,
        sli: ServiceLevelIndicator
    ) {
        self.displayName = displayName
        self.serviceName = serviceName
        self.projectID = projectID
        self.goal = goal
        self.rollingPeriod = rollingPeriod
        self.calendarPeriod = calendarPeriod
        self.sli = sli
    }

    /// Calendar period options
    public enum CalendarPeriod: String, Codable, Sendable {
        case day = "DAY"
        case week = "WEEK"
        case fortnight = "FORTNIGHT"
        case month = "MONTH"
        case quarter = "QUARTER"
        case half = "HALF"
        case year = "YEAR"
    }

    /// Service Level Indicator types
    public enum ServiceLevelIndicator: Codable, Sendable, Equatable {
        /// Request-based SLI
        case requestBased(
            goodTotalRatio: GoodTotalRatio?,
            distributionCut: DistributionCut?
        )
        /// Windows-based SLI
        case windowsBased(
            windowPeriod: String,
            goodBadMetricFilter: String?,
            goodTotalRatioThreshold: GoodTotalRatio?
        )

        public struct GoodTotalRatio: Codable, Sendable, Equatable {
            public let goodServiceFilter: String?
            public let badServiceFilter: String?
            public let totalServiceFilter: String?

            public init(
                goodServiceFilter: String? = nil,
                badServiceFilter: String? = nil,
                totalServiceFilter: String? = nil
            ) {
                self.goodServiceFilter = goodServiceFilter
                self.badServiceFilter = badServiceFilter
                self.totalServiceFilter = totalServiceFilter
            }
        }

        public struct DistributionCut: Codable, Sendable, Equatable {
            public let distributionFilter: String
            public let range: Range

            public struct Range: Codable, Sendable, Equatable {
                public let min: Double?
                public let max: Double?

                public init(min: Double? = nil, max: Double? = nil) {
                    self.min = min
                    self.max = max
                }
            }

            public init(distributionFilter: String, range: Range) {
                self.distributionFilter = distributionFilter
                self.range = range
            }
        }
    }
}

// MARK: - Predefined Metric Filters

/// Common metric filters for Cloud Monitoring.
public enum PredefinedMetricFilter {
    // Compute Engine metrics
    public static let cpuUtilization = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
    public static let diskReadBytes = "metric.type=\"compute.googleapis.com/instance/disk/read_bytes_count\""
    public static let diskWriteBytes = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\""
    public static let networkReceivedBytes = "metric.type=\"compute.googleapis.com/instance/network/received_bytes_count\""
    public static let networkSentBytes = "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\""

    // Cloud Run metrics
    public static let cloudRunRequestCount = "metric.type=\"run.googleapis.com/request_count\""
    public static let cloudRunRequestLatencies = "metric.type=\"run.googleapis.com/request_latencies\""
    public static let cloudRunContainerCPU = "metric.type=\"run.googleapis.com/container/cpu/utilizations\""
    public static let cloudRunContainerMemory = "metric.type=\"run.googleapis.com/container/memory/utilizations\""

    // Cloud Functions metrics
    public static let functionExecutionCount = "metric.type=\"cloudfunctions.googleapis.com/function/execution_count\""
    public static let functionExecutionTimes = "metric.type=\"cloudfunctions.googleapis.com/function/execution_times\""
    public static let functionActiveInstances = "metric.type=\"cloudfunctions.googleapis.com/function/active_instances\""

    // Cloud SQL metrics
    public static let sqlCPUUtilization = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
    public static let sqlMemoryUtilization = "metric.type=\"cloudsql.googleapis.com/database/memory/utilization\""
    public static let sqlDiskUtilization = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\""
    public static let sqlConnections = "metric.type=\"cloudsql.googleapis.com/database/network/connections\""

    // Pub/Sub metrics
    public static let pubsubPublishMessageCount = "metric.type=\"pubsub.googleapis.com/topic/send_message_operation_count\""
    public static let pubsubSubscriptionBacklog = "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\""
    public static let pubsubOldestUnackedMessage = "metric.type=\"pubsub.googleapis.com/subscription/oldest_unacked_message_age\""

    // Load Balancer metrics
    public static let lbRequestCount = "metric.type=\"loadbalancing.googleapis.com/https/request_count\""
    public static let lbTotalLatencies = "metric.type=\"loadbalancing.googleapis.com/https/total_latencies\""
    public static let lbBackendLatencies = "metric.type=\"loadbalancing.googleapis.com/https/backend_latencies\""
}

// MARK: - DAIS Monitoring Templates

/// Predefined monitoring configurations for DAIS deployments.
public enum DAISMonitoringTemplate {
    /// Create email notification channel for DAIS alerts
    public static func emailChannel(
        projectID: String,
        deploymentName: String,
        email: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel.email(
            displayName: "\(deploymentName) Alerts",
            projectID: projectID,
            emailAddress: email
        )
    }

    /// Create Slack notification channel for DAIS alerts
    public static func slackChannel(
        projectID: String,
        deploymentName: String,
        channelName: String,
        authToken: String
    ) -> GoogleCloudNotificationChannel {
        GoogleCloudNotificationChannel.slack(
            displayName: "\(deploymentName) Slack Alerts",
            projectID: projectID,
            channelName: channelName,
            authToken: authToken
        )
    }

    /// Create CPU usage alert policy for DAIS
    public static func cpuAlertPolicy(
        projectID: String,
        deploymentName: String,
        threshold: Double = 0.8,
        notificationChannels: [String] = []
    ) -> GoogleCloudAlertPolicy {
        GoogleCloudAlertPolicy(
            displayName: "\(deploymentName) High CPU Usage",
            projectID: projectID,
            conditions: [
                .threshold(
                    displayName: "CPU > \(Int(threshold * 100))%",
                    filter: "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.labels.instance_name=starts_with(\"\(deploymentName)\")",
                    comparison: .greaterThan,
                    threshold: threshold,
                    duration: "300s",
                    aggregation: AlertCondition.Aggregation(
                        alignmentPeriod: "60s",
                        perSeriesAligner: .alignMean
                    )
                )
            ],
            notificationChannels: notificationChannels,
            documentation: AlertDocumentation(
                content: "CPU utilization has exceeded \(Int(threshold * 100))% for DAIS deployment '\(deploymentName)'.\n\nConsider scaling up or investigating high-CPU processes.",
                subject: "High CPU Alert: \(deploymentName)"
            ),
            userLabels: ["app": "butteryai", "deployment": deploymentName],
            severity: .warning
        )
    }

    /// Create memory usage alert policy for DAIS
    public static func memoryAlertPolicy(
        projectID: String,
        deploymentName: String,
        threshold: Double = 0.85,
        notificationChannels: [String] = []
    ) -> GoogleCloudAlertPolicy {
        GoogleCloudAlertPolicy(
            displayName: "\(deploymentName) High Memory Usage",
            projectID: projectID,
            conditions: [
                .threshold(
                    displayName: "Memory > \(Int(threshold * 100))%",
                    filter: "metric.type=\"compute.googleapis.com/instance/memory/percent_used\" AND resource.labels.instance_name=starts_with(\"\(deploymentName)\")",
                    comparison: .greaterThan,
                    threshold: threshold,
                    duration: "300s"
                )
            ],
            notificationChannels: notificationChannels,
            documentation: AlertDocumentation(
                content: "Memory utilization has exceeded \(Int(threshold * 100))% for DAIS deployment '\(deploymentName)'.",
                subject: "High Memory Alert: \(deploymentName)"
            ),
            userLabels: ["app": "butteryai", "deployment": deploymentName],
            severity: .warning
        )
    }

    /// Create error rate alert policy for DAIS
    public static func errorRateAlertPolicy(
        projectID: String,
        deploymentName: String,
        threshold: Double = 0.01,
        notificationChannels: [String] = []
    ) -> GoogleCloudAlertPolicy {
        GoogleCloudAlertPolicy(
            displayName: "\(deploymentName) High Error Rate",
            projectID: projectID,
            conditions: [
                .threshold(
                    displayName: "Error Rate > \(Int(threshold * 100))%",
                    filter: "metric.type=\"logging.googleapis.com/user/\(deploymentName)-error-count\"",
                    comparison: .greaterThan,
                    threshold: threshold,
                    duration: "60s"
                )
            ],
            notificationChannels: notificationChannels,
            documentation: AlertDocumentation(
                content: "Error rate has exceeded \(Int(threshold * 100))% for DAIS deployment '\(deploymentName)'.\n\nCheck logs for details.",
                subject: "High Error Rate: \(deploymentName)"
            ),
            userLabels: ["app": "butteryai", "deployment": deploymentName],
            severity: .error
        )
    }

    /// Create uptime check for DAIS HTTP endpoint
    public static func httpUptimeCheck(
        projectID: String,
        deploymentName: String,
        host: String,
        path: String = "/health",
        port: Int = 443
    ) -> GoogleCloudUptimeCheck {
        GoogleCloudUptimeCheck(
            displayName: "\(deploymentName) HTTP Health",
            projectID: projectID,
            monitoredResource: .uptime(host: host),
            httpCheck: GoogleCloudUptimeCheck.HTTPCheckConfig(
                path: path,
                port: port,
                useSsl: port == 443,
                validateSsl: true
            ),
            period: .oneMinute,
            contentMatchers: [
                GoogleCloudUptimeCheck.ContentMatcher(content: "ok", matcher: .contains)
            ]
        )
    }

    /// Create uptime check for DAIS gRPC endpoint
    public static func grpcUptimeCheck(
        projectID: String,
        deploymentName: String,
        host: String,
        port: Int = 9090
    ) -> GoogleCloudUptimeCheck {
        GoogleCloudUptimeCheck(
            displayName: "\(deploymentName) gRPC Health",
            projectID: projectID,
            monitoredResource: .uptime(host: host),
            tcpCheck: GoogleCloudUptimeCheck.TCPCheckConfig(port: port),
            period: .oneMinute
        )
    }

    /// Create custom metric for DAIS request latency
    public static func requestLatencyMetric(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudMetricDescriptor {
        GoogleCloudMetricDescriptor(
            type: "custom.googleapis.com/dais/\(deploymentName)/request_latency",
            projectID: projectID,
            metricKind: .gauge,
            valueType: .distribution,
            unit: "ms",
            description: "Request latency for DAIS deployment",
            displayName: "\(deploymentName) Request Latency",
            labels: [
                GoogleCloudMetricDescriptor.LabelDescriptor(key: "method", description: "gRPC method name"),
                GoogleCloudMetricDescriptor.LabelDescriptor(key: "status", description: "Response status")
            ]
        )
    }

    /// Create custom metric for DAIS active connections
    public static func activeConnectionsMetric(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudMetricDescriptor {
        GoogleCloudMetricDescriptor(
            type: "custom.googleapis.com/dais/\(deploymentName)/active_connections",
            projectID: projectID,
            metricKind: .gauge,
            valueType: .int64,
            unit: "1",
            description: "Active gRPC connections",
            displayName: "\(deploymentName) Active Connections",
            labels: [
                GoogleCloudMetricDescriptor.LabelDescriptor(key: "node", description: "DAIS node name")
            ]
        )
    }

    /// Create a monitoring group for DAIS instances
    public static func instanceGroup(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudMonitoringGroup {
        GoogleCloudMonitoringGroup(
            displayName: "\(deploymentName) DAIS Nodes",
            projectID: projectID,
            filter: "resource.metadata.name=starts_with(\"\(deploymentName)\") AND resource.type=\"gce_instance\"",
            isCluster: true
        )
    }

    /// Generate a complete DAIS monitoring setup script
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        alertEmail: String,
        httpHost: String? = nil,
        grpcHost: String? = nil
    ) -> String {
        var script = """
        #!/bin/bash
        # DAIS Monitoring Setup Script
        # Deployment: \(deploymentName)
        # Project: \(projectID)

        set -e

        echo "========================================"
        echo "DAIS Monitoring Configuration"
        echo "========================================"

        # Enable Cloud Monitoring API
        echo "Enabling Cloud Monitoring API..."
        gcloud services enable monitoring.googleapis.com --project=\(projectID)

        """

        // Add notification channel
        let emailChannel = emailChannel(projectID: projectID, deploymentName: deploymentName, email: alertEmail)
        script += """

        # Create email notification channel
        echo "Creating notification channel..."
        \(emailChannel.createCommand)

        """

        // Add monitoring group
        let group = instanceGroup(projectID: projectID, deploymentName: deploymentName)
        script += """

        # Create monitoring group for DAIS instances
        echo "Creating monitoring group..."
        \(group.createCommand)

        """

        // Add uptime checks if hosts provided
        if let host = httpHost {
            let httpCheck = httpUptimeCheck(projectID: projectID, deploymentName: deploymentName, host: host)
            script += """

            # Create HTTP uptime check
            echo "Creating HTTP uptime check..."
            \(httpCheck.createCommand)

            """
        }

        if let host = grpcHost {
            let grpcCheck = grpcUptimeCheck(projectID: projectID, deploymentName: deploymentName, host: host)
            script += """

            # Create gRPC uptime check
            echo "Creating gRPC uptime check..."
            \(grpcCheck.createCommand)

            """
        }

        // Add custom metrics
        let latencyMetric = requestLatencyMetric(projectID: projectID, deploymentName: deploymentName)
        let connectionsMetric = activeConnectionsMetric(projectID: projectID, deploymentName: deploymentName)
        script += """

        # Create custom metrics
        echo "Creating custom metrics..."
        \(latencyMetric.createCommand)
        \(connectionsMetric.createCommand)

        """

        script += """

        echo ""
        echo "Monitoring configuration complete!"
        echo ""
        echo "Note: Alert policies require JSON configuration. Use the following commands to create them:"
        echo "  gcloud alpha monitoring policies create --policy-from-file=cpu-alert.json --project=\(projectID)"
        echo ""
        echo "View monitoring: https://console.cloud.google.com/monitoring?project=\(projectID)"
        """

        return script
    }

    /// Generate alert policy JSON for DAIS
    public static func alertPolicyJSON(
        policy: GoogleCloudAlertPolicy
    ) -> String {
        """
        {
          "displayName": "\(policy.displayName)",
          "combiner": "\(policy.combiner.rawValue)",
          "conditions": [
            // Conditions would be generated here based on policy.conditions
          ],
          "notificationChannels": \(policy.notificationChannels),
          "userLabels": \(policy.userLabels),
          "enabled": \(policy.enabled)
        }
        """
    }
}

// MARK: - Monitoring Query Helpers

/// Helpers for building Monitoring Query Language (MQL) queries.
public enum MQLQueryBuilder {
    /// Build a fetch query for a metric
    public static func fetch(metricType: String, resourceType: String? = nil) -> String {
        var query = "fetch \(resourceType ?? "generic_task")"
        query += "\n| metric '\(metricType)'"
        return query
    }

    /// Add a filter to a query
    public static func filter(_ query: String, condition: String) -> String {
        "\(query)\n| filter \(condition)"
    }

    /// Add grouping to a query
    public static func groupBy(_ query: String, fields: [String], reducer: String = "mean") -> String {
        "\(query)\n| group_by [\(fields.joined(separator: ", "))], [\(reducer)(value)]"
    }

    /// Add alignment to a query
    public static func align(_ query: String, aligner: String = "mean", period: String = "1m") -> String {
        "\(query)\n| align \(aligner)(\(period))"
    }

    /// Add a time window
    public static func withinDuration(_ query: String, duration: String) -> String {
        "\(query)\n| within \(duration)"
    }
}
