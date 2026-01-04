import Foundation

// MARK: - Error Event

/// Represents an error event in Cloud Error Reporting
public struct GoogleCloudErrorEvent: Codable, Sendable, Equatable {
    public let projectID: String
    public let eventTime: Date?
    public let serviceContext: ServiceContext
    public let message: String
    public let context: ErrorContext?

    public struct ServiceContext: Codable, Sendable, Equatable {
        public let service: String
        public let version: String?
        public let resourceType: String?

        public init(service: String, version: String? = nil, resourceType: String? = nil) {
            self.service = service
            self.version = version
            self.resourceType = resourceType
        }
    }

    public struct ErrorContext: Codable, Sendable, Equatable {
        public let httpRequest: HTTPRequestContext?
        public let user: String?
        public let reportLocation: ReportLocation?
        public let sourceReferences: [SourceReference]?

        public struct HTTPRequestContext: Codable, Sendable, Equatable {
            public let method: String?
            public let url: String?
            public let userAgent: String?
            public let referrer: String?
            public let responseStatusCode: Int?
            public let remoteIp: String?

            public init(
                method: String? = nil,
                url: String? = nil,
                userAgent: String? = nil,
                referrer: String? = nil,
                responseStatusCode: Int? = nil,
                remoteIp: String? = nil
            ) {
                self.method = method
                self.url = url
                self.userAgent = userAgent
                self.referrer = referrer
                self.responseStatusCode = responseStatusCode
                self.remoteIp = remoteIp
            }
        }

        public struct ReportLocation: Codable, Sendable, Equatable {
            public let filePath: String?
            public let lineNumber: Int?
            public let functionName: String?

            public init(filePath: String? = nil, lineNumber: Int? = nil, functionName: String? = nil) {
                self.filePath = filePath
                self.lineNumber = lineNumber
                self.functionName = functionName
            }
        }

        public struct SourceReference: Codable, Sendable, Equatable {
            public let repository: String?
            public let revisionID: String?

            public init(repository: String? = nil, revisionID: String? = nil) {
                self.repository = repository
                self.revisionID = revisionID
            }
        }

        public init(
            httpRequest: HTTPRequestContext? = nil,
            user: String? = nil,
            reportLocation: ReportLocation? = nil,
            sourceReferences: [SourceReference]? = nil
        ) {
            self.httpRequest = httpRequest
            self.user = user
            self.reportLocation = reportLocation
            self.sourceReferences = sourceReferences
        }
    }

    public init(
        projectID: String,
        eventTime: Date? = nil,
        serviceContext: ServiceContext,
        message: String,
        context: ErrorContext? = nil
    ) {
        self.projectID = projectID
        self.eventTime = eventTime
        self.serviceContext = serviceContext
        self.message = message
        self.context = context
    }

    /// Command to report an error via gcloud
    public var reportCommand: String {
        let escapedMessage = message.replacingOccurrences(of: "\"", with: "\\\"")
        return """
        gcloud beta error-reporting events report \\
          --project=\(projectID) \\
          --service=\(serviceContext.service) \\
          --message="\(escapedMessage)"
        """
    }
}

// MARK: - Error Group

/// Represents an error group in Cloud Error Reporting
public struct GoogleCloudErrorGroup: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let groupID: String
    public let trackingIssues: [TrackingIssue]?
    public let resolutionStatus: ResolutionStatus?

    public struct TrackingIssue: Codable, Sendable, Equatable {
        public let url: String

        public init(url: String) {
            self.url = url
        }
    }

    public enum ResolutionStatus: String, Codable, Sendable, Equatable {
        case open = "OPEN"
        case acknowledged = "ACKNOWLEDGED"
        case resolved = "RESOLVED"
        case muted = "MUTED"
    }

    public init(
        name: String,
        projectID: String,
        groupID: String,
        trackingIssues: [TrackingIssue]? = nil,
        resolutionStatus: ResolutionStatus? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.groupID = groupID
        self.trackingIssues = trackingIssues
        self.resolutionStatus = resolutionStatus
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/groups/\(groupID)"
    }

    /// Command to get error group
    public var getCommand: String {
        """
        curl -X GET "https://clouderrorreporting.googleapis.com/v1beta1/projects/\(projectID)/groups/\(groupID)" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """
    }

    /// Command to update error group (set resolution status)
    public func updateResolutionCommand(status: ResolutionStatus) -> String {
        """
        curl -X PUT "https://clouderrorreporting.googleapis.com/v1beta1/projects/\(projectID)/groups/\(groupID)" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
          -H "Content-Type: application/json" \\
          -d '{"name": "\(resourceName)", "resolutionStatus": "\(status.rawValue)"}'
        """
    }
}

// MARK: - Error Group Stats

/// Represents statistics for an error group
public struct GoogleCloudErrorGroupStats: Codable, Sendable, Equatable {
    public let projectID: String
    public let groupID: String
    public let count: Int64
    public let affectedUsersCount: Int64?
    public let timedCountDuration: String?
    public let firstSeenTime: Date?
    public let lastSeenTime: Date?
    public let affectedServices: [String]?
    public let numAffectedServices: Int?
    public let representative: GoogleCloudErrorEvent?

    public init(
        projectID: String,
        groupID: String,
        count: Int64,
        affectedUsersCount: Int64? = nil,
        timedCountDuration: String? = nil,
        firstSeenTime: Date? = nil,
        lastSeenTime: Date? = nil,
        affectedServices: [String]? = nil,
        numAffectedServices: Int? = nil,
        representative: GoogleCloudErrorEvent? = nil
    ) {
        self.projectID = projectID
        self.groupID = groupID
        self.count = count
        self.affectedUsersCount = affectedUsersCount
        self.timedCountDuration = timedCountDuration
        self.firstSeenTime = firstSeenTime
        self.lastSeenTime = lastSeenTime
        self.affectedServices = affectedServices
        self.numAffectedServices = numAffectedServices
        self.representative = representative
    }
}

// MARK: - Error Reporting Operations

/// Helper operations for Cloud Error Reporting
public struct ErrorReportingOperations: Sendable {

    /// Command to enable Error Reporting API
    public static var enableAPICommand: String {
        "gcloud services enable clouderrorreporting.googleapis.com"
    }

    /// Command to list error groups
    public static func listGroupsCommand(projectID: String, service: String? = nil, timeRange: String? = nil) -> String {
        var cmd = """
        curl -X GET "https://clouderrorreporting.googleapis.com/v1beta1/projects/\(projectID)/groupStats
        """

        var params: [String] = []
        if let service = service {
            params.append("serviceFilter.service=\(service)")
        }

        if let range = timeRange {
            params.append("timeRange.period=\(range)")
        }

        if !params.isEmpty {
            cmd += "?\(params.joined(separator: "&"))"
        }

        cmd += """
        " \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """

        return cmd
    }

    /// Command to list events for a group
    public static func listEventsCommand(projectID: String, groupID: String, pageSize: Int? = nil) -> String {
        var cmd = """
        curl -X GET "https://clouderrorreporting.googleapis.com/v1beta1/projects/\(projectID)/events?groupId=\(groupID)
        """

        if let size = pageSize {
            cmd += "&pageSize=\(size)"
        }

        cmd += """
        " \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """

        return cmd
    }

    /// Command to delete events
    public static func deleteEventsCommand(projectID: String) -> String {
        """
        curl -X DELETE "https://clouderrorreporting.googleapis.com/v1beta1/projects/\(projectID)/events" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """
    }

    /// IAM roles for Error Reporting
    public struct Roles {
        public static let admin = "roles/errorreporting.admin"
        public static let user = "roles/errorreporting.user"
        public static let viewer = "roles/errorreporting.viewer"
        public static let writer = "roles/errorreporting.writer"
    }

    /// Command to add error reporting admin role
    public static func addAdminRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=roles/errorreporting.admin"
    }

    /// Command to add error reporting writer role
    public static func addWriterRoleCommand(projectID: String, serviceAccount: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=serviceAccount:\(serviceAccount) --role=roles/errorreporting.writer"
    }

    /// Time ranges for queries
    public struct TimeRanges {
        public static let period1Hour = "PERIOD_1_HOUR"
        public static let period6Hours = "PERIOD_6_HOURS"
        public static let period1Day = "PERIOD_1_DAY"
        public static let period1Week = "PERIOD_1_WEEK"
        public static let period30Days = "PERIOD_30_DAYS"
    }
}

// MARK: - Language-Specific Configurations

/// Language-specific error reporting configurations
public struct ErrorReportingLanguageConfig: Sendable {

    /// Go error reporting configuration
    public struct Go: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Go code snippet to initialize error reporting
        public var initCode: String {
            """
            import (
                "context"
                "cloud.google.com/go/errorreporting"
            )

            func initErrorReporting(ctx context.Context) (*errorreporting.Client, error) {
                client, err := errorreporting.NewClient(ctx, "\(projectID)", errorreporting.Config{
                    ServiceName:    "\(service)",
                    ServiceVersion: "\(serviceVersion)",
                    OnError: func(err error) {
                        log.Printf("Error reporting error: %v", err)
                    },
                })
                if err != nil {
                    return nil, err
                }
                return client, nil
            }

            // Report an error
            func reportError(client *errorreporting.Client, err error) {
                client.Report(errorreporting.Entry{
                    Error: err,
                })
            }
            """
        }

        /// Go module dependency
        public static var moduleDependency: String {
            "cloud.google.com/go/errorreporting"
        }
    }

    /// Python error reporting configuration
    public struct Python: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Python code snippet to initialize error reporting
        public var initCode: String {
            """
            from google.cloud import error_reporting

            def init_error_reporting():
                client = error_reporting.Client(
                    project='\(projectID)',
                    service='\(service)',
                    version='\(serviceVersion)'
                )
                return client

            # Report an exception
            def report_exception(client):
                try:
                    # Code that may raise an exception
                    raise Exception("Example error")
                except Exception:
                    client.report_exception()

            # Report a custom message
            def report_message(client, message):
                client.report(message)
            """
        }

        /// Pip install command
        public static var pipInstallCommand: String {
            "pip install google-cloud-error-reporting"
        }
    }

    /// Node.js error reporting configuration
    public struct NodeJS: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Node.js code snippet to initialize error reporting
        public var initCode: String {
            """
            const {ErrorReporting} = require('@google-cloud/error-reporting');

            const errors = new ErrorReporting({
                projectId: '\(projectID)',
                serviceContext: {
                    service: '\(service)',
                    version: '\(serviceVersion)',
                },
            });

            // Report an error
            errors.report('Something went wrong!');

            // Report an exception
            try {
                throw new Error('Example error');
            } catch (e) {
                errors.report(e);
            }

            // Express middleware
            app.use(errors.express);
            """
        }

        /// npm install command
        public static var npmInstallCommand: String {
            "npm install @google-cloud/error-reporting"
        }
    }

    /// Java error reporting configuration
    public struct Java: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Java code snippet for error reporting
        public var initCode: String {
            """
            import com.google.cloud.errorreporting.v1beta1.ReportErrorsServiceClient;
            import com.google.devtools.clouderrorreporting.v1beta1.*;

            public class ErrorReporter {
                private static final String PROJECT_ID = "\(projectID)";
                private static final String SERVICE = "\(service)";
                private static final String VERSION = "\(serviceVersion)";

                public static void reportError(Exception e) throws Exception {
                    try (ReportErrorsServiceClient client = ReportErrorsServiceClient.create()) {
                        ErrorContext errorContext = ErrorContext.newBuilder()
                            .build();

                        ServiceContext serviceContext = ServiceContext.newBuilder()
                            .setService(SERVICE)
                            .setVersion(VERSION)
                            .build();

                        ReportedErrorEvent errorEvent = ReportedErrorEvent.newBuilder()
                            .setMessage(e.getMessage())
                            .setContext(errorContext)
                            .setServiceContext(serviceContext)
                            .build();

                        ProjectName projectName = ProjectName.of(PROJECT_ID);
                        client.reportErrorEvent(projectName, errorEvent);
                    }
                }
            }
            """
        }

        /// Maven dependency
        public static var mavenDependency: String {
            """
            <dependency>
                <groupId>com.google.cloud</groupId>
                <artifactId>google-cloud-errorreporting</artifactId>
            </dependency>
            """
        }
    }
}

// MARK: - DAIS Error Reporting Template

/// Production-ready Cloud Error Reporting templates for DAIS systems
public struct DAISErrorReportingTemplate: Sendable {
    public let projectID: String
    public let service: String
    public let serviceVersion: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        service: String = "dais-service",
        serviceVersion: String = "1.0.0",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.service = service
        self.serviceVersion = serviceVersion
        self.serviceAccount = serviceAccount
    }

    /// Service context for errors
    public var serviceContext: GoogleCloudErrorEvent.ServiceContext {
        GoogleCloudErrorEvent.ServiceContext(
            service: service,
            version: serviceVersion
        )
    }

    /// Sample error event
    public func errorEvent(message: String) -> GoogleCloudErrorEvent {
        GoogleCloudErrorEvent(
            projectID: projectID,
            serviceContext: serviceContext,
            message: message
        )
    }

    /// Go configuration
    public var goConfig: ErrorReportingLanguageConfig.Go {
        ErrorReportingLanguageConfig.Go(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Python configuration
    public var pythonConfig: ErrorReportingLanguageConfig.Python {
        ErrorReportingLanguageConfig.Python(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Node.js configuration
    public var nodeJSConfig: ErrorReportingLanguageConfig.NodeJS {
        ErrorReportingLanguageConfig.NodeJS(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Java configuration
    public var javaConfig: ErrorReportingLanguageConfig.Java {
        ErrorReportingLanguageConfig.Java(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Command to list errors
    public var listErrorsCommand: String {
        ErrorReportingOperations.listGroupsCommand(
            projectID: projectID,
            service: service,
            timeRange: ErrorReportingOperations.TimeRanges.period1Day
        )
    }

    /// Setup script
    public var setupScript: String {
        var script = """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        SERVICE_NAME="\(service)"
        SERVICE_VERSION="\(serviceVersion)"

        echo "Enabling Cloud Error Reporting API..."
        \(ErrorReportingOperations.enableAPICommand)

        """

        if let sa = serviceAccount {
            script += """
            echo "Granting error reporting writer role..."
            \(ErrorReportingOperations.addWriterRoleCommand(projectID: projectID, serviceAccount: sa))

            """
        }

        script += """
        echo ""
        echo "DAIS Cloud Error Reporting setup complete!"
        echo ""
        echo "Service: $SERVICE_NAME"
        echo "Version: $SERVICE_VERSION"
        echo ""
        echo "View errors at:"
        echo "  https://console.cloud.google.com/errors?project=$PROJECT_ID&service=$SERVICE_NAME"
        """

        return script
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        echo "Cloud Error Reporting teardown"
        echo ""
        echo "To delete all error events:"
        echo "  \(ErrorReportingOperations.deleteEventsCommand(projectID: projectID))"
        """
    }
}
