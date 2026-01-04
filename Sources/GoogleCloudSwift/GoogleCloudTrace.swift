import Foundation

// MARK: - Cloud Trace Span

/// Represents a Cloud Trace span
public struct GoogleCloudTraceSpan: Codable, Sendable, Equatable {
    public let traceID: String
    public let spanID: String
    public let projectID: String
    public let displayName: String
    public let parentSpanID: String?
    public let startTime: Date?
    public let endTime: Date?
    public let status: SpanStatus?
    public let attributes: [String: String]?
    public let links: [SpanLink]?
    public let childSpanCount: Int?

    public struct SpanStatus: Codable, Sendable, Equatable {
        public let code: StatusCode
        public let message: String?

        public enum StatusCode: String, Codable, Sendable, Equatable {
            case unspecified = "UNSPECIFIED"
            case ok = "OK"
            case cancelled = "CANCELLED"
            case unknown = "UNKNOWN"
            case invalidArgument = "INVALID_ARGUMENT"
            case deadlineExceeded = "DEADLINE_EXCEEDED"
            case notFound = "NOT_FOUND"
            case alreadyExists = "ALREADY_EXISTS"
            case permissionDenied = "PERMISSION_DENIED"
            case resourceExhausted = "RESOURCE_EXHAUSTED"
            case failedPrecondition = "FAILED_PRECONDITION"
            case aborted = "ABORTED"
            case outOfRange = "OUT_OF_RANGE"
            case unimplemented = "UNIMPLEMENTED"
            case `internal` = "INTERNAL"
            case unavailable = "UNAVAILABLE"
            case dataLoss = "DATA_LOSS"
            case unauthenticated = "UNAUTHENTICATED"
        }

        public init(code: StatusCode, message: String? = nil) {
            self.code = code
            self.message = message
        }
    }

    public struct SpanLink: Codable, Sendable, Equatable {
        public let traceID: String
        public let spanID: String
        public let type: LinkType?

        public enum LinkType: String, Codable, Sendable, Equatable {
            case typeUnspecified = "TYPE_UNSPECIFIED"
            case childLinkedSpan = "CHILD_LINKED_SPAN"
            case parentLinkedSpan = "PARENT_LINKED_SPAN"
        }

        public init(traceID: String, spanID: String, type: LinkType? = nil) {
            self.traceID = traceID
            self.spanID = spanID
            self.type = type
        }
    }

    public init(
        traceID: String,
        spanID: String,
        projectID: String,
        displayName: String,
        parentSpanID: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        status: SpanStatus? = nil,
        attributes: [String: String]? = nil,
        links: [SpanLink]? = nil,
        childSpanCount: Int? = nil
    ) {
        self.traceID = traceID
        self.spanID = spanID
        self.projectID = projectID
        self.displayName = displayName
        self.parentSpanID = parentSpanID
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.attributes = attributes
        self.links = links
        self.childSpanCount = childSpanCount
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/traces/\(traceID)/spans/\(spanID)"
    }

    /// Trace resource name
    public var traceResourceName: String {
        "projects/\(projectID)/traces/\(traceID)"
    }

    /// Command to list traces
    public static func listTracesCommand(projectID: String, filter: String? = nil, limit: Int? = nil) -> String {
        var cmd = "gcloud trace traces list --project=\(projectID)"

        if let filter = filter {
            cmd += " --filter='\(filter)'"
        }

        if let limit = limit {
            cmd += " --limit=\(limit)"
        }

        return cmd
    }

    /// Command to describe a trace
    public static func describeTraceCommand(traceID: String, projectID: String) -> String {
        "gcloud trace traces describe \(traceID) --project=\(projectID)"
    }
}

// MARK: - Cloud Trace Sink

/// Represents a Cloud Trace sink for exporting trace data
public struct GoogleCloudTraceSink: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let destination: String
    public let filter: String?
    public let writerIdentity: String?

    public init(
        name: String,
        projectID: String,
        destination: String,
        filter: String? = nil,
        writerIdentity: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.destination = destination
        self.filter = filter
        self.writerIdentity = writerIdentity
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/traceSinks/\(name)"
    }

    /// Command to create the sink (using API)
    public var createAPICommand: String {
        var body: [String: Any] = [
            "name": name,
            "outputConfig": ["destination": destination]
        ]

        if let filter = filter {
            body["filter"] = filter
        }

        return """
        curl -X POST "https://cloudtrace.googleapis.com/v2/projects/\(projectID)/traceSinks" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
          -H "Content-Type: application/json" \\
          -d '{"name": "\(name)", "outputConfig": {"destination": "\(destination)"}}'
        """
    }

    /// Command to delete the sink (using API)
    public var deleteAPICommand: String {
        """
        curl -X DELETE "https://cloudtrace.googleapis.com/v2/projects/\(projectID)/traceSinks/\(name)" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """
    }

    /// Command to list sinks
    public static func listSinksCommand(projectID: String) -> String {
        """
        curl -X GET "https://cloudtrace.googleapis.com/v2/projects/\(projectID)/traceSinks" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """
    }
}

// MARK: - Trace Configuration

/// Represents Cloud Trace configuration settings
public struct GoogleCloudTraceConfig: Codable, Sendable, Equatable {
    public let projectID: String
    public let sampleRate: Double
    public let tracingEnabled: Bool
    public let spanAttributeLimit: Int?
    public let annotationEventsPerSpanLimit: Int?
    public let messageEventsPerSpanLimit: Int?

    public init(
        projectID: String,
        sampleRate: Double = 1.0,
        tracingEnabled: Bool = true,
        spanAttributeLimit: Int? = nil,
        annotationEventsPerSpanLimit: Int? = nil,
        messageEventsPerSpanLimit: Int? = nil
    ) {
        self.projectID = projectID
        self.sampleRate = sampleRate
        self.tracingEnabled = tracingEnabled
        self.spanAttributeLimit = spanAttributeLimit
        self.annotationEventsPerSpanLimit = annotationEventsPerSpanLimit
        self.messageEventsPerSpanLimit = messageEventsPerSpanLimit
    }

    /// Sample rate percentage (0-100)
    public var sampleRatePercentage: Double {
        sampleRate * 100
    }
}

// MARK: - Trace Operations

/// Helper operations for Cloud Trace
public struct TraceOperations: Sendable {

    /// Command to enable Cloud Trace API
    public static var enableAPICommand: String {
        "gcloud services enable cloudtrace.googleapis.com"
    }

    /// Command to get IAM policy for trace
    public static func getIAMPolicyCommand(projectID: String) -> String {
        "gcloud projects get-iam-policy \(projectID) --flatten='bindings[].members' --format='table(bindings.role)' --filter='bindings.members:trace'"
    }

    /// Command to add trace agent role
    public static func addTraceAgentRoleCommand(projectID: String, serviceAccount: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=serviceAccount:\(serviceAccount) --role=roles/cloudtrace.agent"
    }

    /// Command to add trace admin role
    public static func addTraceAdminRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=roles/cloudtrace.admin"
    }

    /// IAM roles for Cloud Trace
    public struct Roles {
        public static let admin = "roles/cloudtrace.admin"
        public static let agent = "roles/cloudtrace.agent"
        public static let user = "roles/cloudtrace.user"
    }

    /// Trace header format for W3C Trace Context
    public static func w3cTraceContextHeader(traceID: String, spanID: String, sampled: Bool = true) -> String {
        let flags = sampled ? "01" : "00"
        return "traceparent: 00-\(traceID)-\(spanID)-\(flags)"
    }

    /// Trace header format for Google Cloud Trace
    public static func googleTraceHeader(traceID: String, spanID: String, sampled: Bool = true) -> String {
        let options = sampled ? "o=1" : "o=0"
        return "X-Cloud-Trace-Context: \(traceID)/\(spanID);\(options)"
    }
}

// MARK: - Trace Analysis

/// Helper for trace analysis queries
public struct TraceAnalysis: Sendable {

    /// Generate latency analysis query
    public static func latencyAnalysisFilter(serviceName: String, minLatencyMs: Int) -> String {
        "+span:\(serviceName) latency:>\(minLatencyMs)ms"
    }

    /// Generate error trace filter
    public static func errorTraceFilter(serviceName: String? = nil) -> String {
        var filter = "status.code!=OK"
        if let service = serviceName {
            filter = "+span:\(service) \(filter)"
        }
        return filter
    }

    /// Generate time range filter
    public static func timeRangeFilter(startTime: String, endTime: String) -> String {
        "start_time>='\(startTime)' AND end_time<='\(endTime)'"
    }

    /// Generate span name filter
    public static func spanNameFilter(pattern: String) -> String {
        "span:\(pattern)"
    }

    /// Generate attribute filter
    public static func attributeFilter(key: String, value: String) -> String {
        "span.attributes.\(key):\(value)"
    }

    /// Generate HTTP method filter
    public static func httpMethodFilter(method: String) -> String {
        attributeFilter(key: "http.method", value: method)
    }

    /// Generate HTTP status code filter
    public static func httpStatusFilter(statusCode: Int) -> String {
        attributeFilter(key: "http.status_code", value: String(statusCode))
    }
}

// MARK: - OpenTelemetry Integration

/// Helper for OpenTelemetry configuration with Cloud Trace
public struct OpenTelemetryTraceConfig: Sendable {
    public let projectID: String
    public let serviceName: String
    public let serviceVersion: String?
    public let environment: String?

    public init(
        projectID: String,
        serviceName: String,
        serviceVersion: String? = nil,
        environment: String? = nil
    ) {
        self.projectID = projectID
        self.serviceName = serviceName
        self.serviceVersion = serviceVersion
        self.environment = environment
    }

    /// Environment variables for OpenTelemetry with Cloud Trace
    public var environmentVariables: [String: String] {
        var vars: [String: String] = [
            "OTEL_EXPORTER_OTLP_ENDPOINT": "https://cloudtrace.googleapis.com",
            "OTEL_SERVICE_NAME": serviceName,
            "OTEL_TRACES_EXPORTER": "otlp",
            "GOOGLE_CLOUD_PROJECT": projectID
        ]

        if let version = serviceVersion {
            vars["OTEL_SERVICE_VERSION"] = version
        }

        if let env = environment {
            vars["OTEL_RESOURCE_ATTRIBUTES"] = "deployment.environment=\(env)"
        }

        return vars
    }

    /// Docker run command with OpenTelemetry configuration
    public func dockerRunCommand(image: String) -> String {
        var cmd = "docker run"
        for (key, value) in environmentVariables {
            cmd += " -e \(key)=\(value)"
        }
        cmd += " \(image)"
        return cmd
    }
}

// MARK: - DAIS Trace Template

/// Production-ready Cloud Trace templates for DAIS systems
public struct DAISTraceTemplate: Sendable {
    public let projectID: String
    public let serviceName: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        serviceName: String = "dais-service",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.serviceName = serviceName
        self.serviceAccount = serviceAccount
    }

    /// OpenTelemetry configuration
    public var openTelemetryConfig: OpenTelemetryTraceConfig {
        OpenTelemetryTraceConfig(
            projectID: projectID,
            serviceName: serviceName,
            serviceVersion: "1.0.0",
            environment: "production"
        )
    }

    /// Trace configuration with recommended settings
    public var traceConfig: GoogleCloudTraceConfig {
        GoogleCloudTraceConfig(
            projectID: projectID,
            sampleRate: 0.1,  // 10% sampling for production
            tracingEnabled: true,
            spanAttributeLimit: 32,
            annotationEventsPerSpanLimit: 128,
            messageEventsPerSpanLimit: 128
        )
    }

    /// BigQuery sink for trace analytics
    public func bigQuerySink(datasetID: String) -> GoogleCloudTraceSink {
        GoogleCloudTraceSink(
            name: "dais-trace-bq-sink",
            projectID: projectID,
            destination: "bigquery.googleapis.com/projects/\(projectID)/datasets/\(datasetID)"
        )
    }

    /// Latency alert filter
    public var highLatencyFilter: String {
        TraceAnalysis.latencyAnalysisFilter(serviceName: serviceName, minLatencyMs: 1000)
    }

    /// Error trace filter
    public var errorFilter: String {
        TraceAnalysis.errorTraceFilter(serviceName: serviceName)
    }

    /// Setup script
    public var setupScript: String {
        var script = """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"

        echo "Enabling Cloud Trace API..."
        \(TraceOperations.enableAPICommand)

        """

        if let sa = serviceAccount {
            script += """
            echo "Granting trace agent role..."
            \(TraceOperations.addTraceAgentRoleCommand(projectID: projectID, serviceAccount: sa))

            """
        }

        script += """
        echo ""
        echo "DAIS Cloud Trace setup complete!"
        echo ""
        echo "OpenTelemetry Environment Variables:"
        """

        for (key, value) in openTelemetryConfig.environmentVariables {
            script += "\necho \"  \(key)=\(value)\""
        }

        script += """

        echo ""
        echo "Sample Trace Queries:"
        echo "  High Latency: \(highLatencyFilter)"
        echo "  Errors: \(errorFilter)"
        """

        return script
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        echo "Cloud Trace teardown - no resources to delete"
        echo "Traces are automatically retained according to retention policy"
        """
    }
}
