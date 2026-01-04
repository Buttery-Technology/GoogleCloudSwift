//
//  GoogleCloudFunctions.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

/// Represents a Google Cloud Function.
///
/// Cloud Functions is a serverless execution environment for building and
/// connecting cloud services. Functions are triggered by events and scale automatically.
///
/// ## Example Usage
/// ```swift
/// let function = GoogleCloudFunction(
///     name: "process-events",
///     projectID: "my-project",
///     region: "us-central1",
///     runtime: .python312,
///     entryPoint: "main",
///     trigger: .pubsub(topic: "my-events"),
///     memoryMB: 256,
///     timeoutSeconds: 60
/// )
/// print(function.deployCommand)
/// ```
public struct GoogleCloudFunction: Codable, Sendable, Equatable {
    /// Function name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Region where the function is deployed
    public let region: String

    /// Runtime environment
    public let runtime: CloudFunctionRuntime

    /// Entry point function name
    public let entryPoint: String

    /// Source code location
    public let source: FunctionSource

    /// Trigger configuration
    public let trigger: FunctionTrigger

    /// Memory allocation in MB (128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768)
    public let memoryMB: Int

    /// Timeout in seconds (1-540 for 1st gen, 1-3600 for 2nd gen)
    public let timeoutSeconds: Int

    /// Minimum number of instances (0 for scale to zero)
    public let minInstances: Int

    /// Maximum number of instances
    public let maxInstances: Int?

    /// Environment variables
    public let environmentVariables: [String: String]

    /// Secret environment variables (from Secret Manager)
    public let secretEnvironmentVariables: [SecretEnvVar]

    /// Service account email for the function
    public let serviceAccountEmail: String?

    /// VPC connector for private network access
    public let vpcConnector: String?

    /// Ingress settings
    public let ingressSettings: IngressSettings

    /// Cloud Function generation (1st or 2nd gen)
    public let generation: FunctionGeneration

    /// Labels for organization
    public let labels: [String: String]

    /// Description of the function
    public let description: String?

    public init(
        name: String,
        projectID: String,
        region: String,
        runtime: CloudFunctionRuntime,
        entryPoint: String,
        source: FunctionSource = .localDirectory(path: "."),
        trigger: FunctionTrigger = .http(allowUnauthenticated: false),
        memoryMB: Int = 256,
        timeoutSeconds: Int = 60,
        minInstances: Int = 0,
        maxInstances: Int? = nil,
        environmentVariables: [String: String] = [:],
        secretEnvironmentVariables: [SecretEnvVar] = [],
        serviceAccountEmail: String? = nil,
        vpcConnector: String? = nil,
        ingressSettings: IngressSettings = .all,
        generation: FunctionGeneration = .gen2,
        labels: [String: String] = [:],
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.runtime = runtime
        self.entryPoint = entryPoint
        self.source = source
        self.trigger = trigger
        self.memoryMB = memoryMB
        self.timeoutSeconds = timeoutSeconds
        self.minInstances = minInstances
        self.maxInstances = maxInstances
        self.environmentVariables = environmentVariables
        self.secretEnvironmentVariables = secretEnvironmentVariables
        self.serviceAccountEmail = serviceAccountEmail
        self.vpcConnector = vpcConnector
        self.ingressSettings = ingressSettings
        self.generation = generation
        self.labels = labels
        self.description = description
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/functions/\(name)"
    }

    /// gcloud command to deploy this function
    public var deployCommand: String {
        var cmd: String

        switch generation {
        case .gen1:
            cmd = "gcloud functions deploy \(name)"
        case .gen2:
            cmd = "gcloud functions deploy \(name) --gen2"
        }

        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --runtime=\(runtime.rawValue)"
        cmd += " --entry-point=\(entryPoint)"

        // Source
        switch source {
        case .localDirectory(let path):
            cmd += " --source=\(path)"
        case .gcs(let bucket, let object):
            cmd += " --source=gs://\(bucket)/\(object)"
        case .repository(let repo, let directory, let branch):
            cmd += " --source=\(repo)"
            if let dir = directory {
                cmd += " --source-dir=\(dir)"
            }
            if let branch = branch {
                cmd += " --source-branch=\(branch)"
            }
        }

        // Trigger
        switch trigger {
        case .http(let allowUnauthenticated):
            cmd += " --trigger-http"
            if allowUnauthenticated {
                cmd += " --allow-unauthenticated"
            } else {
                cmd += " --no-allow-unauthenticated"
            }
        case .pubsub(let topic):
            cmd += " --trigger-topic=\(topic)"
        case .storage(let bucket, let event):
            cmd += " --trigger-bucket=\(bucket)"
            if let event = event {
                cmd += " --trigger-event=\(event.rawValue)"
            }
        case .firestore(let document, let event):
            cmd += " --trigger-event=\(event.rawValue)"
            cmd += " --trigger-resource=\(document)"
        case .eventarc(let eventType, let filters):
            cmd += " --trigger-event=\(eventType)"
            for (key, value) in filters {
                cmd += " --trigger-event-filters=\(key)=\(value)"
            }
        case .scheduler(let schedule, let timezone):
            // Scheduler triggers require a separate Cloud Scheduler job
            cmd += " --trigger-http"
            cmd += " --no-allow-unauthenticated"
            // Note: Schedule is configured separately
            _ = schedule
            _ = timezone
        }

        cmd += " --memory=\(memoryMB)MB"
        cmd += " --timeout=\(timeoutSeconds)s"

        if minInstances > 0 {
            cmd += " --min-instances=\(minInstances)"
        }

        if let maxInstances = maxInstances {
            cmd += " --max-instances=\(maxInstances)"
        }

        if !environmentVariables.isEmpty {
            let envPairs = environmentVariables.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --set-env-vars=\(envPairs)"
        }

        for secretVar in secretEnvironmentVariables {
            cmd += " --set-secrets=\(secretVar.variableName)=\(secretVar.secretName):\(secretVar.version)"
        }

        if let serviceAccountEmail = serviceAccountEmail {
            cmd += " --service-account=\(serviceAccountEmail)"
        }

        if let vpcConnector = vpcConnector {
            cmd += " --vpc-connector=\(vpcConnector)"
        }

        cmd += " --ingress-settings=\(ingressSettings.rawValue)"

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// gcloud command to delete this function
    public var deleteCommand: String {
        var cmd = "gcloud functions delete \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if generation == .gen2 {
            cmd += " --gen2"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe this function
    public var describeCommand: String {
        var cmd = "gcloud functions describe \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if generation == .gen2 {
            cmd += " --gen2"
        }
        return cmd
    }

    /// gcloud command to get function logs
    public var logsCommand: String {
        var cmd = "gcloud functions logs read \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if generation == .gen2 {
            cmd += " --gen2"
        }
        return cmd
    }

    /// gcloud command to call the function (for HTTP triggers)
    public func callCommand(data: String? = nil) -> String {
        var cmd = "gcloud functions call \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if generation == .gen2 {
            cmd += " --gen2"
        }
        if let data = data {
            cmd += " --data='\(data)'"
        }
        return cmd
    }

    /// gcloud command to list functions
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud functions list --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// HTTP URL for the function (only for HTTP triggered functions)
    public var httpURL: String? {
        switch trigger {
        case .http:
            switch generation {
            case .gen1:
                return "https://\(region)-\(projectID).cloudfunctions.net/\(name)"
            case .gen2:
                return "https://\(name)-\(projectID.hashValue & 0xFFFFFF).\(region).run.app"
            }
        default:
            return nil
        }
    }
}

// MARK: - Function Source

extension GoogleCloudFunction {
    /// Source code location for a Cloud Function
    public enum FunctionSource: Codable, Sendable, Equatable {
        /// Local directory containing function code
        case localDirectory(path: String)
        /// Cloud Storage bucket and object
        case gcs(bucket: String, object: String)
        /// Source repository
        case repository(url: String, directory: String?, branch: String?)
    }
}

// MARK: - Function Trigger

extension GoogleCloudFunction {
    /// Trigger type for a Cloud Function
    public enum FunctionTrigger: Codable, Sendable, Equatable {
        /// HTTP trigger
        case http(allowUnauthenticated: Bool)
        /// Pub/Sub trigger
        case pubsub(topic: String)
        /// Cloud Storage trigger
        case storage(bucket: String, event: StorageEvent?)
        /// Firestore trigger
        case firestore(document: String, event: FirestoreEvent)
        /// Eventarc trigger (2nd gen)
        case eventarc(eventType: String, filters: [String: String])
        /// Cloud Scheduler trigger (creates HTTP trigger + scheduler job)
        case scheduler(schedule: String, timezone: String)
    }

    /// Cloud Storage events
    public enum StorageEvent: String, Codable, Sendable {
        case finalize = "google.storage.object.finalize"
        case delete = "google.storage.object.delete"
        case archive = "google.storage.object.archive"
        case metadataUpdate = "google.storage.object.metadataUpdate"
    }

    /// Firestore events
    public enum FirestoreEvent: String, Codable, Sendable {
        case create = "providers/cloud.firestore/eventTypes/document.create"
        case update = "providers/cloud.firestore/eventTypes/document.update"
        case delete = "providers/cloud.firestore/eventTypes/document.delete"
        case write = "providers/cloud.firestore/eventTypes/document.write"
    }
}

// MARK: - Function Runtime

/// Supported Cloud Function runtimes
public enum CloudFunctionRuntime: String, Codable, Sendable, CaseIterable {
    // Node.js
    case nodejs18 = "nodejs18"
    case nodejs20 = "nodejs20"
    case nodejs22 = "nodejs22"

    // Python
    case python39 = "python39"
    case python310 = "python310"
    case python311 = "python311"
    case python312 = "python312"

    // Go
    case go119 = "go119"
    case go120 = "go120"
    case go121 = "go121"
    case go122 = "go122"

    // Java
    case java11 = "java11"
    case java17 = "java17"
    case java21 = "java21"

    // .NET
    case dotnet6 = "dotnet6"
    case dotnet8 = "dotnet8"

    // Ruby
    case ruby30 = "ruby30"
    case ruby32 = "ruby32"
    case ruby33 = "ruby33"

    // PHP
    case php81 = "php81"
    case php82 = "php82"
    case php83 = "php83"

    /// Language family
    public var language: String {
        switch self {
        case .nodejs18, .nodejs20, .nodejs22:
            return "Node.js"
        case .python39, .python310, .python311, .python312:
            return "Python"
        case .go119, .go120, .go121, .go122:
            return "Go"
        case .java11, .java17, .java21:
            return "Java"
        case .dotnet6, .dotnet8:
            return ".NET"
        case .ruby30, .ruby32, .ruby33:
            return "Ruby"
        case .php81, .php82, .php83:
            return "PHP"
        }
    }

    /// Whether this runtime is recommended (latest LTS)
    public var isRecommended: Bool {
        switch self {
        case .nodejs20, .python312, .go122, .java21, .dotnet8, .ruby33, .php83:
            return true
        default:
            return false
        }
    }
}

// MARK: - Function Generation

extension GoogleCloudFunction {
    /// Cloud Function generation
    public enum FunctionGeneration: String, Codable, Sendable {
        /// 1st generation (legacy)
        case gen1 = "1st-gen"
        /// 2nd generation (recommended, uses Cloud Run)
        case gen2 = "2nd-gen"
    }
}

// MARK: - Ingress Settings

extension GoogleCloudFunction {
    /// Ingress settings for controlling network access
    public enum IngressSettings: String, Codable, Sendable {
        /// Allow all traffic
        case all = "all"
        /// Allow only internal traffic
        case internalOnly = "internal-only"
        /// Allow internal traffic and traffic from Cloud Load Balancing
        case internalAndGclb = "internal-and-gclb"
    }
}

// MARK: - Secret Environment Variable

extension GoogleCloudFunction {
    /// Secret environment variable configuration
    public struct SecretEnvVar: Codable, Sendable, Equatable {
        /// Environment variable name
        public let variableName: String
        /// Secret name in Secret Manager
        public let secretName: String
        /// Secret version (e.g., "latest", "1")
        public let version: String

        public init(variableName: String, secretName: String, version: String = "latest") {
            self.variableName = variableName
            self.secretName = secretName
            self.version = version
        }
    }
}

// MARK: - Cloud Function Event

/// Represents an event that can trigger a Cloud Function
public struct CloudFunctionEvent: Codable, Sendable, Equatable {
    /// Event type
    public let eventType: String

    /// Event filters
    public let filters: [String: String]

    /// Resource path
    public let resource: String?

    public init(eventType: String, filters: [String: String] = [:], resource: String? = nil) {
        self.eventType = eventType
        self.filters = filters
        self.resource = resource
    }

    /// Common Pub/Sub event
    public static func pubsub(topic: String, projectID: String) -> CloudFunctionEvent {
        CloudFunctionEvent(
            eventType: "google.cloud.pubsub.topic.v1.messagePublished",
            filters: ["topic": "projects/\(projectID)/topics/\(topic)"]
        )
    }

    /// Common Cloud Storage event
    public static func storage(bucket: String, eventType: GoogleCloudFunction.StorageEvent = .finalize) -> CloudFunctionEvent {
        CloudFunctionEvent(
            eventType: eventType.rawValue,
            resource: bucket
        )
    }
}

// MARK: - Cloud Scheduler Job (for scheduled functions)

/// Represents a Cloud Scheduler job for triggering functions
public struct CloudSchedulerJob: Codable, Sendable, Equatable {
    /// Job name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location/region
    public let location: String

    /// Cron schedule expression
    public let schedule: String

    /// Timezone (e.g., "America/Los_Angeles")
    public let timezone: String

    /// Target function
    public let targetFunction: String

    /// HTTP method
    public let httpMethod: String

    /// Request body
    public let body: String?

    /// Service account for authentication
    public let serviceAccountEmail: String?

    /// Description
    public let description: String?

    public init(
        name: String,
        projectID: String,
        location: String,
        schedule: String,
        timezone: String = "UTC",
        targetFunction: String,
        httpMethod: String = "POST",
        body: String? = nil,
        serviceAccountEmail: String? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.schedule = schedule
        self.timezone = timezone
        self.targetFunction = targetFunction
        self.httpMethod = httpMethod
        self.body = body
        self.serviceAccountEmail = serviceAccountEmail
        self.description = description
    }

    /// gcloud command to create this scheduler job
    public var createCommand: String {
        var cmd = "gcloud scheduler jobs create http \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --schedule=\"\(schedule)\""
        cmd += " --time-zone=\"\(timezone)\""
        cmd += " --uri=\(targetFunction)"
        cmd += " --http-method=\(httpMethod)"

        if let body = body {
            cmd += " --message-body='\(body)'"
        }

        if let serviceAccountEmail = serviceAccountEmail {
            cmd += " --oidc-service-account-email=\(serviceAccountEmail)"
        }

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// gcloud command to delete this job
    public var deleteCommand: String {
        "gcloud scheduler jobs delete \(name) --project=\(projectID) --location=\(location) --quiet"
    }

    /// gcloud command to pause this job
    public var pauseCommand: String {
        "gcloud scheduler jobs pause \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to resume this job
    public var resumeCommand: String {
        "gcloud scheduler jobs resume \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to run this job immediately
    public var runCommand: String {
        "gcloud scheduler jobs run \(name) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - VPC Connector

/// Represents a Serverless VPC Access connector
public struct VPCConnector: Codable, Sendable, Equatable {
    /// Connector name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Region
    public let region: String

    /// VPC network
    public let network: String

    /// IP CIDR range (e.g., "10.8.0.0/28")
    public let ipCidrRange: String

    /// Minimum throughput (200-1000 Mbps)
    public let minThroughput: Int

    /// Maximum throughput (200-1000 Mbps)
    public let maxThroughput: Int

    public init(
        name: String,
        projectID: String,
        region: String,
        network: String = "default",
        ipCidrRange: String,
        minThroughput: Int = 200,
        maxThroughput: Int = 300
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.network = network
        self.ipCidrRange = ipCidrRange
        self.minThroughput = minThroughput
        self.maxThroughput = maxThroughput
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/connectors/\(name)"
    }

    /// gcloud command to create this connector
    public var createCommand: String {
        var cmd = "gcloud compute networks vpc-access connectors create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --network=\(network)"
        cmd += " --range=\(ipCidrRange)"
        cmd += " --min-throughput=\(minThroughput)"
        cmd += " --max-throughput=\(maxThroughput)"
        return cmd
    }

    /// gcloud command to delete this connector
    public var deleteCommand: String {
        "gcloud compute networks vpc-access connectors delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this connector
    public var describeCommand: String {
        "gcloud compute networks vpc-access connectors describe \(name) --project=\(projectID) --region=\(region)"
    }
}

// MARK: - DAIS Function Templates

/// Predefined Cloud Function configurations for DAIS
public enum DAISFunctionTemplate {

    /// Event processor function for handling Pub/Sub messages
    public static func eventProcessor(
        projectID: String,
        region: String,
        deploymentName: String,
        eventsTopic: String,
        runtime: CloudFunctionRuntime = .python312
    ) -> GoogleCloudFunction {
        GoogleCloudFunction(
            name: "\(deploymentName)-event-processor",
            projectID: projectID,
            region: region,
            runtime: runtime,
            entryPoint: "process_event",
            trigger: .pubsub(topic: eventsTopic),
            memoryMB: 512,
            timeoutSeconds: 120,
            minInstances: 0,
            maxInstances: 100,
            environmentVariables: [
                "DEPLOYMENT_NAME": deploymentName,
                "PROJECT_ID": projectID
            ],
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "event-processor"
            ],
            description: "DAIS event processor for \(deploymentName)"
        )
    }

    /// HTTP health check endpoint
    public static func healthCheck(
        projectID: String,
        region: String,
        deploymentName: String,
        runtime: CloudFunctionRuntime = .python312
    ) -> GoogleCloudFunction {
        GoogleCloudFunction(
            name: "\(deploymentName)-health-check",
            projectID: projectID,
            region: region,
            runtime: runtime,
            entryPoint: "health_check",
            trigger: .http(allowUnauthenticated: true),
            memoryMB: 128,
            timeoutSeconds: 10,
            minInstances: 0,
            maxInstances: 10,
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "health-check"
            ],
            description: "DAIS health check endpoint"
        )
    }

    /// Webhook handler for external integrations
    public static func webhookHandler(
        projectID: String,
        region: String,
        deploymentName: String,
        runtime: CloudFunctionRuntime = .python312,
        allowUnauthenticated: Bool = false
    ) -> GoogleCloudFunction {
        GoogleCloudFunction(
            name: "\(deploymentName)-webhook",
            projectID: projectID,
            region: region,
            runtime: runtime,
            entryPoint: "handle_webhook",
            trigger: .http(allowUnauthenticated: allowUnauthenticated),
            memoryMB: 256,
            timeoutSeconds: 60,
            minInstances: 0,
            maxInstances: 50,
            environmentVariables: [
                "DEPLOYMENT_NAME": deploymentName,
                "PROJECT_ID": projectID
            ],
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "webhook"
            ],
            description: "DAIS webhook handler for external integrations"
        )
    }

    /// Scheduled maintenance function
    public static func scheduledMaintenance(
        projectID: String,
        region: String,
        deploymentName: String,
        schedule: String = "0 2 * * *",  // Daily at 2 AM
        timezone: String = "UTC",
        runtime: CloudFunctionRuntime = .python312
    ) -> (function: GoogleCloudFunction, scheduler: CloudSchedulerJob) {
        let function = GoogleCloudFunction(
            name: "\(deploymentName)-maintenance",
            projectID: projectID,
            region: region,
            runtime: runtime,
            entryPoint: "run_maintenance",
            trigger: .http(allowUnauthenticated: false),
            memoryMB: 512,
            timeoutSeconds: 540,
            minInstances: 0,
            maxInstances: 1,
            environmentVariables: [
                "DEPLOYMENT_NAME": deploymentName,
                "PROJECT_ID": projectID
            ],
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "maintenance"
            ],
            description: "DAIS scheduled maintenance tasks"
        )

        let scheduler = CloudSchedulerJob(
            name: "\(deploymentName)-maintenance-trigger",
            projectID: projectID,
            location: region,
            schedule: schedule,
            timezone: timezone,
            targetFunction: function.httpURL ?? "",
            serviceAccountEmail: "\(deploymentName)-invoker@\(projectID).iam.gserviceaccount.com",
            description: "Trigger maintenance function for \(deploymentName)"
        )

        return (function, scheduler)
    }

    /// Storage event handler for processing uploaded files
    public static func storageProcessor(
        projectID: String,
        region: String,
        deploymentName: String,
        bucket: String,
        runtime: CloudFunctionRuntime = .python312
    ) -> GoogleCloudFunction {
        GoogleCloudFunction(
            name: "\(deploymentName)-storage-processor",
            projectID: projectID,
            region: region,
            runtime: runtime,
            entryPoint: "process_file",
            trigger: .storage(bucket: bucket, event: .finalize),
            memoryMB: 1024,
            timeoutSeconds: 300,
            minInstances: 0,
            maxInstances: 50,
            environmentVariables: [
                "DEPLOYMENT_NAME": deploymentName,
                "PROJECT_ID": projectID,
                "BUCKET_NAME": bucket
            ],
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "storage-processor"
            ],
            description: "DAIS storage event processor"
        )
    }

    /// Python code template for event processor
    public static func eventProcessorCode() -> String {
        """
        import base64
        import json
        import os
        from datetime import datetime

        def process_event(event, context):
            \"\"\"Process a Pub/Sub message.

            Args:
                event: The Pub/Sub message payload
                context: The event metadata
            \"\"\"
            deployment_name = os.environ.get('DEPLOYMENT_NAME', 'unknown')
            project_id = os.environ.get('PROJECT_ID', 'unknown')

            # Decode the message
            if 'data' in event:
                message_data = base64.b64decode(event['data']).decode('utf-8')
                try:
                    payload = json.loads(message_data)
                except json.JSONDecodeError:
                    payload = {'raw': message_data}
            else:
                payload = {}

            # Get message attributes
            attributes = event.get('attributes', {})

            print(f"[{deployment_name}] Processing event at {datetime.utcnow().isoformat()}")
            print(f"Message ID: {context.event_id}")
            print(f"Payload: {json.dumps(payload)}")
            print(f"Attributes: {json.dumps(attributes)}")

            # TODO: Implement your event processing logic here

            return 'OK'
        """
    }

    /// Python code template for health check
    public static func healthCheckCode() -> String {
        """
        import json
        from datetime import datetime

        def health_check(request):
            \"\"\"HTTP health check endpoint.

            Args:
                request: The HTTP request object

            Returns:
                JSON response with health status
            \"\"\"
            response = {
                'status': 'healthy',
                'timestamp': datetime.utcnow().isoformat(),
                'version': '1.0.0'
            }

            return json.dumps(response), 200, {'Content-Type': 'application/json'}
        """
    }

    /// Generate setup script for DAIS functions
    public static func setupScript(
        projectID: String,
        region: String,
        deploymentName: String,
        eventsTopic: String
    ) -> String {
        let eventProcessor = eventProcessor(
            projectID: projectID,
            region: region,
            deploymentName: deploymentName,
            eventsTopic: eventsTopic
        )

        let healthCheck = healthCheck(
            projectID: projectID,
            region: region,
            deploymentName: deploymentName
        )

        let webhook = webhookHandler(
            projectID: projectID,
            region: region,
            deploymentName: deploymentName
        )

        return """
        #!/bin/bash
        # DAIS Cloud Functions Setup Script
        # Deployment: \(deploymentName)
        # Project: \(projectID)

        set -e

        echo "========================================"
        echo "DAIS Cloud Functions Deployment"
        echo "========================================"

        # Enable required APIs
        echo "Enabling Cloud Functions API..."
        gcloud services enable cloudfunctions.googleapis.com --project=\(projectID)
        gcloud services enable cloudbuild.googleapis.com --project=\(projectID)
        gcloud services enable run.googleapis.com --project=\(projectID)

        # Create function source directories
        echo "Creating function source directories..."
        mkdir -p /tmp/dais-functions/event-processor
        mkdir -p /tmp/dais-functions/health-check
        mkdir -p /tmp/dais-functions/webhook

        # Write event processor code
        cat > /tmp/dais-functions/event-processor/main.py << 'PYTHON_EOF'
        \(eventProcessorCode())
        PYTHON_EOF

        cat > /tmp/dais-functions/event-processor/requirements.txt << 'REQ_EOF'
        functions-framework==3.*
        REQ_EOF

        # Write health check code
        cat > /tmp/dais-functions/health-check/main.py << 'PYTHON_EOF'
        \(healthCheckCode())
        PYTHON_EOF

        cat > /tmp/dais-functions/health-check/requirements.txt << 'REQ_EOF'
        functions-framework==3.*
        REQ_EOF

        # Deploy event processor
        echo "Deploying event processor function..."
        cd /tmp/dais-functions/event-processor
        \(eventProcessor.deployCommand)

        # Deploy health check
        echo "Deploying health check function..."
        cd /tmp/dais-functions/health-check
        \(healthCheck.deployCommand)

        echo ""
        echo "Deployment complete!"
        echo ""
        echo "Functions deployed:"
        echo "  - Event Processor: \(eventProcessor.name)"
        echo "  - Health Check: \(healthCheck.httpURL ?? "N/A")"
        echo "  - Webhook: \(webhook.name) (deploy manually with authentication config)"
        """
    }
}

// MARK: - Function IAM

extension GoogleCloudFunction {
    /// IAM roles for Cloud Functions
    public enum FunctionRole: String, Codable, Sendable {
        /// Full control over functions
        case admin = "roles/cloudfunctions.admin"
        /// Deploy and manage functions
        case developer = "roles/cloudfunctions.developer"
        /// View functions
        case viewer = "roles/cloudfunctions.viewer"
        /// Invoke functions
        case invoker = "roles/cloudfunctions.invoker"
    }

    /// gcloud command to add IAM binding for invoking this function
    public func addInvokerCommand(member: String) -> String {
        var cmd = "gcloud functions add-iam-policy-binding \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if generation == .gen2 {
            cmd += " --gen2"
        }
        cmd += " --member=\(member)"
        cmd += " --role=roles/cloudfunctions.invoker"
        return cmd
    }

    /// gcloud command to get IAM policy for this function
    public var getIAMPolicyCommand: String {
        var cmd = "gcloud functions get-iam-policy \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if generation == .gen2 {
            cmd += " --gen2"
        }
        return cmd
    }
}
