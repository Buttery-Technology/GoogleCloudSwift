//
//  GoogleCloudRun.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

/// Represents a Google Cloud Run service.
///
/// Cloud Run is a fully managed platform for deploying and scaling containerized
/// applications. It automatically scales your containers based on incoming requests.
///
/// ## Example Usage
/// ```swift
/// let service = GoogleCloudRunService(
///     name: "my-api",
///     projectID: "my-project",
///     region: "us-central1",
///     image: "gcr.io/my-project/my-api:latest",
///     port: 8080,
///     memoryMB: 512,
///     cpu: "1"
/// )
/// print(service.deployCommand)
/// ```
public struct GoogleCloudRunService: Codable, Sendable, Equatable {
    /// Service name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Region where the service is deployed
    public let region: String

    /// Container image URL
    public let image: String

    /// Port the container listens on
    public let port: Int

    /// Memory allocation (e.g., 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768 MB)
    public let memoryMB: Int

    /// CPU allocation (e.g., "1", "2", "4", "8", or fractional like "0.5")
    public let cpu: String

    /// Minimum number of instances (0 for scale to zero)
    public let minInstances: Int

    /// Maximum number of instances
    public let maxInstances: Int

    /// Maximum concurrent requests per instance
    public let concurrency: Int

    /// Request timeout in seconds (up to 3600)
    public let timeoutSeconds: Int

    /// Environment variables
    public let environmentVariables: [String: String]

    /// Secret environment variables (from Secret Manager)
    public let secrets: [SecretMount]

    /// Service account email
    public let serviceAccountEmail: String?

    /// VPC connector for private network access
    public let vpcConnector: String?

    /// VPC egress setting
    public let vpcEgress: VPCEgress

    /// Ingress settings
    public let ingress: IngressSetting

    /// Whether to allow unauthenticated access
    public let allowUnauthenticated: Bool

    /// Execution environment
    public let executionEnvironment: ExecutionEnvironment

    /// CPU allocation type
    public let cpuAllocationType: CPUAllocationType

    /// Labels for organization
    public let labels: [String: String]

    /// Annotations
    public let annotations: [String: String]

    /// Description
    public let description: String?

    public init(
        name: String,
        projectID: String,
        region: String,
        image: String,
        port: Int = 8080,
        memoryMB: Int = 512,
        cpu: String = "1",
        minInstances: Int = 0,
        maxInstances: Int = 100,
        concurrency: Int = 80,
        timeoutSeconds: Int = 300,
        environmentVariables: [String: String] = [:],
        secrets: [SecretMount] = [],
        serviceAccountEmail: String? = nil,
        vpcConnector: String? = nil,
        vpcEgress: VPCEgress = .privateRangesOnly,
        ingress: IngressSetting = .all,
        allowUnauthenticated: Bool = false,
        executionEnvironment: ExecutionEnvironment = .gen2,
        cpuAllocationType: CPUAllocationType = .requestBased,
        labels: [String: String] = [:],
        annotations: [String: String] = [:],
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.image = image
        self.port = port
        self.memoryMB = memoryMB
        self.cpu = cpu
        self.minInstances = minInstances
        self.maxInstances = maxInstances
        self.concurrency = concurrency
        self.timeoutSeconds = timeoutSeconds
        self.environmentVariables = environmentVariables
        self.secrets = secrets
        self.serviceAccountEmail = serviceAccountEmail
        self.vpcConnector = vpcConnector
        self.vpcEgress = vpcEgress
        self.ingress = ingress
        self.allowUnauthenticated = allowUnauthenticated
        self.executionEnvironment = executionEnvironment
        self.cpuAllocationType = cpuAllocationType
        self.labels = labels
        self.annotations = annotations
        self.description = description
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/services/\(name)"
    }

    /// Service URL (after deployment)
    public var serviceURL: String {
        "https://\(name)-\(projectID.hashValue & 0xFFFFFF).\(region).run.app"
    }

    /// gcloud command to deploy this service
    public var deployCommand: String {
        var cmd = "gcloud run deploy \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --image=\(image)"
        cmd += " --port=\(port)"
        cmd += " --memory=\(memoryMB)Mi"
        cmd += " --cpu=\(cpu)"
        cmd += " --min-instances=\(minInstances)"
        cmd += " --max-instances=\(maxInstances)"
        cmd += " --concurrency=\(concurrency)"
        cmd += " --timeout=\(timeoutSeconds)s"

        if !environmentVariables.isEmpty {
            let envPairs = environmentVariables.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --set-env-vars=\(envPairs)"
        }

        for secret in secrets {
            switch secret.mountType {
            case .environmentVariable(let envName):
                cmd += " --set-secrets=\(envName)=\(secret.secretName):\(secret.version)"
            case .volume(let mountPath):
                cmd += " --set-secrets=\(mountPath)=\(secret.secretName):\(secret.version)"
            }
        }

        if let serviceAccountEmail = serviceAccountEmail {
            cmd += " --service-account=\(serviceAccountEmail)"
        }

        if let vpcConnector = vpcConnector {
            cmd += " --vpc-connector=\(vpcConnector)"
            cmd += " --vpc-egress=\(vpcEgress.rawValue)"
        }

        cmd += " --ingress=\(ingress.rawValue)"

        if allowUnauthenticated {
            cmd += " --allow-unauthenticated"
        } else {
            cmd += " --no-allow-unauthenticated"
        }

        cmd += " --execution-environment=\(executionEnvironment.rawValue)"

        if cpuAllocationType == .alwaysAllocated {
            cmd += " --cpu-boost"
            cmd += " --no-cpu-throttling"
        }

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// gcloud command to delete this service
    public var deleteCommand: String {
        "gcloud run services delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this service
    public var describeCommand: String {
        "gcloud run services describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to get service URL
    public var getURLCommand: String {
        "gcloud run services describe \(name) --project=\(projectID) --region=\(region) --format='value(status.url)'"
    }

    /// gcloud command to list revisions
    public var listRevisionsCommand: String {
        "gcloud run revisions list --service=\(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to get logs
    public var logsCommand: String {
        "gcloud run services logs read \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to update traffic
    public func updateTrafficCommand(revisions: [String: Int]) -> String {
        let trafficPairs = revisions.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
        return "gcloud run services update-traffic \(name) --project=\(projectID) --region=\(region) --to-revisions=\(trafficPairs)"
    }

    /// gcloud command to route all traffic to latest
    public var routeToLatestCommand: String {
        "gcloud run services update-traffic \(name) --project=\(projectID) --region=\(region) --to-latest"
    }

    /// gcloud command to list services
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud run services list --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }
}

// MARK: - Secret Mount

extension GoogleCloudRunService {
    /// How to mount a secret in the container
    public struct SecretMount: Codable, Sendable, Equatable {
        /// Secret name in Secret Manager
        public let secretName: String

        /// Secret version
        public let version: String

        /// Mount type (env var or volume)
        public let mountType: MountType

        public init(secretName: String, version: String = "latest", mountType: MountType) {
            self.secretName = secretName
            self.version = version
            self.mountType = mountType
        }

        /// Convenience for environment variable mount
        public static func envVar(name: String, secretName: String, version: String = "latest") -> SecretMount {
            SecretMount(secretName: secretName, version: version, mountType: .environmentVariable(name: name))
        }

        /// Convenience for volume mount
        public static func volume(path: String, secretName: String, version: String = "latest") -> SecretMount {
            SecretMount(secretName: secretName, version: version, mountType: .volume(path: path))
        }

        /// Mount type options
        public enum MountType: Codable, Sendable, Equatable {
            /// Mount as environment variable
            case environmentVariable(name: String)
            /// Mount as file in volume
            case volume(path: String)
        }
    }
}

// MARK: - VPC Egress

extension GoogleCloudRunService {
    /// VPC egress settings
    public enum VPCEgress: String, Codable, Sendable {
        /// Route only private IP ranges through VPC
        case privateRangesOnly = "private-ranges-only"
        /// Route all traffic through VPC
        case allTraffic = "all-traffic"
    }
}

// MARK: - Ingress Setting

extension GoogleCloudRunService {
    /// Ingress settings for network access
    public enum IngressSetting: String, Codable, Sendable {
        /// Allow all traffic
        case all = "all"
        /// Allow only internal traffic
        case `internal` = "internal"
        /// Allow internal traffic and Cloud Load Balancing
        case internalAndCloudLoadBalancing = "internal-and-cloud-load-balancing"
    }
}

// MARK: - Execution Environment

extension GoogleCloudRunService {
    /// Execution environment
    public enum ExecutionEnvironment: String, Codable, Sendable {
        /// First generation (legacy)
        case gen1 = "gen1"
        /// Second generation (recommended)
        case gen2 = "gen2"
    }
}

// MARK: - CPU Allocation

extension GoogleCloudRunService {
    /// CPU allocation type
    public enum CPUAllocationType: String, Codable, Sendable {
        /// CPU allocated only during request processing
        case requestBased = "request-based"
        /// CPU always allocated (for background tasks)
        case alwaysAllocated = "always-allocated"
    }
}

// MARK: - Cloud Run Job

/// Represents a Cloud Run Job for batch/scheduled workloads.
public struct GoogleCloudRunJob: Codable, Sendable, Equatable {
    /// Job name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Region
    public let region: String

    /// Container image URL
    public let image: String

    /// Command to run (overrides container entrypoint)
    public let command: [String]?

    /// Arguments to pass to the command
    public let args: [String]?

    /// Number of tasks to run
    public let taskCount: Int

    /// Maximum parallel tasks
    public let parallelism: Int

    /// Task timeout in seconds
    public let taskTimeoutSeconds: Int

    /// Maximum retries per task
    public let maxRetries: Int

    /// Memory allocation in MB
    public let memoryMB: Int

    /// CPU allocation
    public let cpu: String

    /// Environment variables
    public let environmentVariables: [String: String]

    /// Secret environment variables
    public let secrets: [GoogleCloudRunService.SecretMount]

    /// Service account email
    public let serviceAccountEmail: String?

    /// VPC connector
    public let vpcConnector: String?

    /// Labels
    public let labels: [String: String]

    public init(
        name: String,
        projectID: String,
        region: String,
        image: String,
        command: [String]? = nil,
        args: [String]? = nil,
        taskCount: Int = 1,
        parallelism: Int = 1,
        taskTimeoutSeconds: Int = 600,
        maxRetries: Int = 3,
        memoryMB: Int = 512,
        cpu: String = "1",
        environmentVariables: [String: String] = [:],
        secrets: [GoogleCloudRunService.SecretMount] = [],
        serviceAccountEmail: String? = nil,
        vpcConnector: String? = nil,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.image = image
        self.command = command
        self.args = args
        self.taskCount = taskCount
        self.parallelism = parallelism
        self.taskTimeoutSeconds = taskTimeoutSeconds
        self.maxRetries = maxRetries
        self.memoryMB = memoryMB
        self.cpu = cpu
        self.environmentVariables = environmentVariables
        self.secrets = secrets
        self.serviceAccountEmail = serviceAccountEmail
        self.vpcConnector = vpcConnector
        self.labels = labels
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/jobs/\(name)"
    }

    /// gcloud command to create this job
    public var createCommand: String {
        var cmd = "gcloud run jobs create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --image=\(image)"

        if let command = command, !command.isEmpty {
            cmd += " --command=\(command.joined(separator: ","))"
        }

        if let args = args, !args.isEmpty {
            cmd += " --args=\(args.joined(separator: ","))"
        }

        cmd += " --tasks=\(taskCount)"
        cmd += " --parallelism=\(parallelism)"
        cmd += " --task-timeout=\(taskTimeoutSeconds)s"
        cmd += " --max-retries=\(maxRetries)"
        cmd += " --memory=\(memoryMB)Mi"
        cmd += " --cpu=\(cpu)"

        if !environmentVariables.isEmpty {
            let envPairs = environmentVariables.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --set-env-vars=\(envPairs)"
        }

        for secret in secrets {
            if case .environmentVariable(let envName) = secret.mountType {
                cmd += " --set-secrets=\(envName)=\(secret.secretName):\(secret.version)"
            }
        }

        if let serviceAccountEmail = serviceAccountEmail {
            cmd += " --service-account=\(serviceAccountEmail)"
        }

        if let vpcConnector = vpcConnector {
            cmd += " --vpc-connector=\(vpcConnector)"
        }

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        return cmd
    }

    /// gcloud command to execute this job
    public var executeCommand: String {
        "gcloud run jobs execute \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to execute with overrides
    public func executeCommand(taskCount: Int? = nil, args: [String]? = nil) -> String {
        var cmd = "gcloud run jobs execute \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"

        if let taskCount = taskCount {
            cmd += " --tasks=\(taskCount)"
        }

        if let args = args, !args.isEmpty {
            cmd += " --args=\(args.joined(separator: ","))"
        }

        return cmd
    }

    /// gcloud command to delete this job
    public var deleteCommand: String {
        "gcloud run jobs delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this job
    public var describeCommand: String {
        "gcloud run jobs describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list executions
    public var listExecutionsCommand: String {
        "gcloud run jobs executions list --job=\(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list jobs
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud run jobs list --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }
}

// MARK: - Cloud Run Revision

/// Represents a Cloud Run revision (immutable snapshot of a service).
public struct GoogleCloudRunRevision: Codable, Sendable, Equatable {
    /// Revision name
    public let name: String

    /// Service name
    public let serviceName: String

    /// Project ID
    public let projectID: String

    /// Region
    public let region: String

    public init(
        name: String,
        serviceName: String,
        projectID: String,
        region: String
    ) {
        self.name = name
        self.serviceName = serviceName
        self.projectID = projectID
        self.region = region
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/services/\(serviceName)/revisions/\(name)"
    }

    /// gcloud command to describe this revision
    public var describeCommand: String {
        "gcloud run revisions describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to delete this revision
    public var deleteCommand: String {
        "gcloud run revisions delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }
}

// MARK: - Domain Mapping

/// Represents a custom domain mapping for a Cloud Run service.
public struct GoogleCloudRunDomainMapping: Codable, Sendable, Equatable {
    /// Domain name
    public let domain: String

    /// Service name
    public let serviceName: String

    /// Project ID
    public let projectID: String

    /// Region
    public let region: String

    public init(
        domain: String,
        serviceName: String,
        projectID: String,
        region: String
    ) {
        self.domain = domain
        self.serviceName = serviceName
        self.projectID = projectID
        self.region = region
    }

    /// gcloud command to create this domain mapping
    public var createCommand: String {
        "gcloud run domain-mappings create --domain=\(domain) --service=\(serviceName) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to delete this domain mapping
    public var deleteCommand: String {
        "gcloud run domain-mappings delete --domain=\(domain) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this domain mapping
    public var describeCommand: String {
        "gcloud run domain-mappings describe --domain=\(domain) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list domain mappings
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud run domain-mappings list --project=\(projectID) --region=\(region)"
    }
}

// MARK: - Traffic Split

/// Represents traffic splitting configuration for Cloud Run.
public struct CloudRunTrafficSplit: Codable, Sendable, Equatable {
    /// Revision to traffic percentage mapping
    public let revisions: [String: Int]

    /// Whether to route to latest revision
    public let routeToLatest: Bool

    public init(revisions: [String: Int] = [:], routeToLatest: Bool = true) {
        self.revisions = revisions
        self.routeToLatest = routeToLatest
    }

    /// Create a split with specific revision percentages
    public static func split(_ revisions: [String: Int]) -> CloudRunTrafficSplit {
        CloudRunTrafficSplit(revisions: revisions, routeToLatest: false)
    }

    /// Route all traffic to the latest revision
    public static var latest: CloudRunTrafficSplit {
        CloudRunTrafficSplit(routeToLatest: true)
    }

    /// Canary deployment (small percentage to new revision)
    public static func canary(stableRevision: String, canaryRevision: String, canaryPercent: Int) -> CloudRunTrafficSplit {
        CloudRunTrafficSplit(
            revisions: [
                stableRevision: 100 - canaryPercent,
                canaryRevision: canaryPercent
            ],
            routeToLatest: false
        )
    }
}

// MARK: - Cloud Run IAM

extension GoogleCloudRunService {
    /// IAM roles for Cloud Run
    public enum CloudRunRole: String, Codable, Sendable {
        /// Full control over Cloud Run resources
        case admin = "roles/run.admin"
        /// Deploy and manage services
        case developer = "roles/run.developer"
        /// View services
        case viewer = "roles/run.viewer"
        /// Invoke services
        case invoker = "roles/run.invoker"
    }

    /// gcloud command to add IAM binding for invoking this service
    public func addInvokerCommand(member: String) -> String {
        "gcloud run services add-iam-policy-binding \(name) --project=\(projectID) --region=\(region) --member=\(member) --role=roles/run.invoker"
    }

    /// gcloud command to make service publicly accessible
    public var makePublicCommand: String {
        "gcloud run services add-iam-policy-binding \(name) --project=\(projectID) --region=\(region) --member=allUsers --role=roles/run.invoker"
    }

    /// gcloud command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud run services get-iam-policy \(name) --project=\(projectID) --region=\(region)"
    }
}

// MARK: - DAIS Cloud Run Templates

/// Predefined Cloud Run configurations for DAIS.
public enum DAISCloudRunTemplate {

    /// DAIS gRPC service
    public static func grpcService(
        projectID: String,
        region: String,
        deploymentName: String,
        image: String,
        grpcPort: Int = 9090
    ) -> GoogleCloudRunService {
        GoogleCloudRunService(
            name: "\(deploymentName)-grpc",
            projectID: projectID,
            region: region,
            image: image,
            port: grpcPort,
            memoryMB: 1024,
            cpu: "2",
            minInstances: 1,
            maxInstances: 10,
            concurrency: 100,
            timeoutSeconds: 300,
            allowUnauthenticated: false,
            cpuAllocationType: .alwaysAllocated,
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "grpc-service"
            ],
            description: "DAIS gRPC service for \(deploymentName)"
        )
    }

    /// DAIS HTTP API service
    public static func httpAPI(
        projectID: String,
        region: String,
        deploymentName: String,
        image: String,
        httpPort: Int = 8080
    ) -> GoogleCloudRunService {
        GoogleCloudRunService(
            name: "\(deploymentName)-api",
            projectID: projectID,
            region: region,
            image: image,
            port: httpPort,
            memoryMB: 512,
            cpu: "1",
            minInstances: 0,
            maxInstances: 50,
            concurrency: 80,
            timeoutSeconds: 60,
            allowUnauthenticated: true,
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "http-api"
            ],
            description: "DAIS HTTP API for \(deploymentName)"
        )
    }

    /// DAIS worker service (background processing)
    public static func worker(
        projectID: String,
        region: String,
        deploymentName: String,
        image: String,
        concurrency: Int = 1
    ) -> GoogleCloudRunService {
        GoogleCloudRunService(
            name: "\(deploymentName)-worker",
            projectID: projectID,
            region: region,
            image: image,
            port: 8080,
            memoryMB: 2048,
            cpu: "2",
            minInstances: 1,
            maxInstances: 20,
            concurrency: concurrency,
            timeoutSeconds: 3600,
            allowUnauthenticated: false,
            cpuAllocationType: .alwaysAllocated,
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "worker"
            ],
            description: "DAIS background worker for \(deploymentName)"
        )
    }

    /// DAIS batch job
    public static func batchJob(
        projectID: String,
        region: String,
        deploymentName: String,
        image: String,
        taskCount: Int = 1,
        parallelism: Int = 1
    ) -> GoogleCloudRunJob {
        GoogleCloudRunJob(
            name: "\(deploymentName)-batch",
            projectID: projectID,
            region: region,
            image: image,
            taskCount: taskCount,
            parallelism: parallelism,
            taskTimeoutSeconds: 3600,
            maxRetries: 3,
            memoryMB: 2048,
            cpu: "2",
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "batch-job"
            ]
        )
    }

    /// DAIS maintenance job
    public static func maintenanceJob(
        projectID: String,
        region: String,
        deploymentName: String,
        image: String
    ) -> GoogleCloudRunJob {
        GoogleCloudRunJob(
            name: "\(deploymentName)-maintenance",
            projectID: projectID,
            region: region,
            image: image,
            command: ["/app/maintenance"],
            taskCount: 1,
            parallelism: 1,
            taskTimeoutSeconds: 1800,
            maxRetries: 2,
            memoryMB: 1024,
            cpu: "1",
            labels: [
                "app": "butteryai",
                "deployment": deploymentName,
                "component": "maintenance"
            ]
        )
    }

    /// Service with secrets from Secret Manager
    public static func serviceWithSecrets(
        projectID: String,
        region: String,
        deploymentName: String,
        image: String,
        secretNames: [String: String]  // env var name -> secret name
    ) -> GoogleCloudRunService {
        let secrets = secretNames.map { envName, secretName in
            GoogleCloudRunService.SecretMount.envVar(
                name: envName,
                secretName: secretName
            )
        }

        return GoogleCloudRunService(
            name: "\(deploymentName)-service",
            projectID: projectID,
            region: region,
            image: image,
            secrets: secrets,
            labels: [
                "app": "butteryai",
                "deployment": deploymentName
            ]
        )
    }

    /// Generate setup script for DAIS Cloud Run deployment
    public static func setupScript(
        projectID: String,
        region: String,
        deploymentName: String,
        grpcImage: String,
        apiImage: String
    ) -> String {
        let grpcService = grpcService(
            projectID: projectID,
            region: region,
            deploymentName: deploymentName,
            image: grpcImage
        )

        let apiService = httpAPI(
            projectID: projectID,
            region: region,
            deploymentName: deploymentName,
            image: apiImage
        )

        return """
        #!/bin/bash
        # DAIS Cloud Run Setup Script
        # Deployment: \(deploymentName)
        # Project: \(projectID)

        set -e

        echo "========================================"
        echo "DAIS Cloud Run Deployment"
        echo "========================================"

        # Enable required APIs
        echo "Enabling Cloud Run API..."
        gcloud services enable run.googleapis.com --project=\(projectID)
        gcloud services enable containerregistry.googleapis.com --project=\(projectID)
        gcloud services enable artifactregistry.googleapis.com --project=\(projectID)

        # Deploy gRPC service
        echo "Deploying gRPC service..."
        \(grpcService.deployCommand)

        # Deploy HTTP API service
        echo "Deploying HTTP API service..."
        \(apiService.deployCommand)

        # Get service URLs
        echo ""
        echo "Deployment complete!"
        echo ""
        echo "Service URLs:"
        GRPC_URL=$(\(grpcService.getURLCommand))
        API_URL=$(\(apiService.getURLCommand))
        echo "  gRPC Service: $GRPC_URL"
        echo "  HTTP API: $API_URL"
        """
    }

    /// Generate Dockerfile for DAIS service
    public static func dockerfile(
        baseImage: String = "swift:5.10-jammy",
        executableName: String,
        port: Int = 8080
    ) -> String {
        """
        # DAIS Service Dockerfile
        # Generated by GoogleCloudSwift

        FROM \(baseImage) AS builder

        WORKDIR /app
        COPY . .

        RUN swift build -c release

        FROM swift:5.10-jammy-slim

        WORKDIR /app

        COPY --from=builder /app/.build/release/\(executableName) /app/

        ENV PORT=\(port)
        EXPOSE \(port)

        CMD ["/app/\(executableName)"]
        """
    }

    /// Generate cloudbuild.yaml for automated deployments
    public static func cloudbuildConfig(
        projectID: String,
        region: String,
        serviceName: String,
        imageName: String
    ) -> String {
        """
        # Cloud Build configuration for DAIS
        # Generated by GoogleCloudSwift

        steps:
          # Build the container image
          - name: 'gcr.io/cloud-builders/docker'
            args:
              - 'build'
              - '-t'
              - 'gcr.io/\(projectID)/\(imageName):$COMMIT_SHA'
              - '-t'
              - 'gcr.io/\(projectID)/\(imageName):latest'
              - '.'

          # Push the container image
          - name: 'gcr.io/cloud-builders/docker'
            args:
              - 'push'
              - 'gcr.io/\(projectID)/\(imageName):$COMMIT_SHA'

          - name: 'gcr.io/cloud-builders/docker'
            args:
              - 'push'
              - 'gcr.io/\(projectID)/\(imageName):latest'

          # Deploy to Cloud Run
          - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
            entrypoint: 'gcloud'
            args:
              - 'run'
              - 'deploy'
              - '\(serviceName)'
              - '--image=gcr.io/\(projectID)/\(imageName):$COMMIT_SHA'
              - '--region=\(region)'
              - '--platform=managed'

        images:
          - 'gcr.io/\(projectID)/\(imageName):$COMMIT_SHA'
          - 'gcr.io/\(projectID)/\(imageName):latest'

        options:
          logging: CLOUD_LOGGING_ONLY
        """
    }
}

// MARK: - Container Registry

/// Container registry locations for Cloud Run images.
public enum ContainerRegistry: Codable, Sendable {
    /// Google Container Registry (gcr.io)
    case gcr(projectID: String, imageName: String, tag: String)
    /// Artifact Registry
    case artifactRegistry(projectID: String, location: String, repository: String, imageName: String, tag: String)
    /// Docker Hub
    case dockerHub(imageName: String, tag: String)

    /// Full image URL
    public var imageURL: String {
        switch self {
        case .gcr(let projectID, let imageName, let tag):
            return "gcr.io/\(projectID)/\(imageName):\(tag)"
        case .artifactRegistry(let projectID, let location, let repository, let imageName, let tag):
            return "\(location)-docker.pkg.dev/\(projectID)/\(repository)/\(imageName):\(tag)"
        case .dockerHub(let imageName, let tag):
            return "\(imageName):\(tag)"
        }
    }
}
