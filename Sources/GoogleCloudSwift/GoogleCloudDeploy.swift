// GoogleCloudDeploy.swift
// Cloud Deploy API for continuous delivery to GKE and Cloud Run

import Foundation

// MARK: - Delivery Pipeline

/// Represents a Cloud Deploy delivery pipeline
public struct GoogleCloudDeliveryPipeline: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let serialPipeline: SerialPipeline?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let suspended: Bool?

    /// Serial pipeline configuration
    public struct SerialPipeline: Codable, Sendable, Equatable {
        public let stages: [Stage]

        public struct Stage: Codable, Sendable, Equatable {
            public let targetId: String
            public let profiles: [String]?
            public let strategy: DeploymentStrategy?

            public init(
                targetId: String,
                profiles: [String]? = nil,
                strategy: DeploymentStrategy? = nil
            ) {
                self.targetId = targetId
                self.profiles = profiles
                self.strategy = strategy
            }
        }

        public init(stages: [Stage]) {
            self.stages = stages
        }
    }

    /// Deployment strategy
    public struct DeploymentStrategy: Codable, Sendable, Equatable {
        public let standard: StandardStrategy?
        public let canary: CanaryStrategy?

        public struct StandardStrategy: Codable, Sendable, Equatable {
            public let verify: Bool?
            public let predeploy: Predeploy?
            public let postdeploy: Postdeploy?

            public struct Predeploy: Codable, Sendable, Equatable {
                public let actions: [String]

                public init(actions: [String]) {
                    self.actions = actions
                }
            }

            public struct Postdeploy: Codable, Sendable, Equatable {
                public let actions: [String]

                public init(actions: [String]) {
                    self.actions = actions
                }
            }

            public init(
                verify: Bool? = nil,
                predeploy: Predeploy? = nil,
                postdeploy: Postdeploy? = nil
            ) {
                self.verify = verify
                self.predeploy = predeploy
                self.postdeploy = postdeploy
            }
        }

        public struct CanaryStrategy: Codable, Sendable, Equatable {
            public let runtimeConfig: RuntimeConfig?
            public let canaryDeployment: CanaryDeployment?

            public struct RuntimeConfig: Codable, Sendable, Equatable {
                public let kubernetes: KubernetesConfig?
                public let cloudRun: CloudRunConfig?

                public struct KubernetesConfig: Codable, Sendable, Equatable {
                    public let gatewayServiceMesh: GatewayServiceMesh?
                    public let serviceNetworking: ServiceNetworking?

                    public struct GatewayServiceMesh: Codable, Sendable, Equatable {
                        public let httpRoute: String
                        public let service: String
                        public let deployment: String

                        public init(httpRoute: String, service: String, deployment: String) {
                            self.httpRoute = httpRoute
                            self.service = service
                            self.deployment = deployment
                        }
                    }

                    public struct ServiceNetworking: Codable, Sendable, Equatable {
                        public let service: String
                        public let deployment: String

                        public init(service: String, deployment: String) {
                            self.service = service
                            self.deployment = deployment
                        }
                    }

                    public init(
                        gatewayServiceMesh: GatewayServiceMesh? = nil,
                        serviceNetworking: ServiceNetworking? = nil
                    ) {
                        self.gatewayServiceMesh = gatewayServiceMesh
                        self.serviceNetworking = serviceNetworking
                    }
                }

                public struct CloudRunConfig: Codable, Sendable, Equatable {
                    public let automaticTrafficControl: Bool?

                    public init(automaticTrafficControl: Bool? = nil) {
                        self.automaticTrafficControl = automaticTrafficControl
                    }
                }

                public init(
                    kubernetes: KubernetesConfig? = nil,
                    cloudRun: CloudRunConfig? = nil
                ) {
                    self.kubernetes = kubernetes
                    self.cloudRun = cloudRun
                }
            }

            public struct CanaryDeployment: Codable, Sendable, Equatable {
                public let percentages: [Int]
                public let verify: Bool?

                public init(percentages: [Int], verify: Bool? = nil) {
                    self.percentages = percentages
                    self.verify = verify
                }
            }

            public init(
                runtimeConfig: RuntimeConfig? = nil,
                canaryDeployment: CanaryDeployment? = nil
            ) {
                self.runtimeConfig = runtimeConfig
                self.canaryDeployment = canaryDeployment
            }
        }

        public init(
            standard: StandardStrategy? = nil,
            canary: CanaryStrategy? = nil
        ) {
            self.standard = standard
            self.canary = canary
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        description: String? = nil,
        serialPipeline: SerialPipeline? = nil,
        labels: [String: String]? = nil,
        annotations: [String: String]? = nil,
        suspended: Bool? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.serialPipeline = serialPipeline
        self.labels = labels
        self.annotations = annotations
        self.suspended = suspended
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/deliveryPipelines/\(name)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "gcloud deploy delivery-pipelines create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(location)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelString)"
        }
        return cmd
    }

    /// Create from file command
    public func createFromFileCommand(filePath: String) -> String {
        "gcloud deploy apply --file=\(filePath) --project=\(projectID) --region=\(location)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud deploy delivery-pipelines describe \(name) --project=\(projectID) --region=\(location)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud deploy delivery-pipelines delete \(name) --project=\(projectID) --region=\(location) --quiet"
    }

    /// List command
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud deploy delivery-pipelines list --project=\(projectID) --region=\(location)"
    }
}

// MARK: - Target

/// Represents a Cloud Deploy target
public struct GoogleCloudDeployTarget: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let targetType: TargetType
    public let requireApproval: Bool?
    public let labels: [String: String]?
    public let executionConfigs: [ExecutionConfig]?

    /// Target type
    public enum TargetType: Codable, Sendable, Equatable {
        case gke(cluster: String, internalIP: Bool?)
        case cloudRun(location: String)
        case anthosCluster(membership: String)
        case customTarget(customTargetType: String)

        private enum CodingKeys: String, CodingKey {
            case gke, cloudRun, anthosCluster, customTarget
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let gkeConfig = try? container.decode(GKEConfig.self, forKey: .gke) {
                self = .gke(cluster: gkeConfig.cluster, internalIP: gkeConfig.internalIP)
            } else if let runConfig = try? container.decode(CloudRunConfig.self, forKey: .cloudRun) {
                self = .cloudRun(location: runConfig.location)
            } else if let anthosConfig = try? container.decode(AnthosConfig.self, forKey: .anthosCluster) {
                self = .anthosCluster(membership: anthosConfig.membership)
            } else if let customConfig = try? container.decode(CustomConfig.self, forKey: .customTarget) {
                self = .customTarget(customTargetType: customConfig.customTargetType)
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown target type"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .gke(let cluster, let internalIP):
                try container.encode(GKEConfig(cluster: cluster, internalIP: internalIP), forKey: .gke)
            case .cloudRun(let location):
                try container.encode(CloudRunConfig(location: location), forKey: .cloudRun)
            case .anthosCluster(let membership):
                try container.encode(AnthosConfig(membership: membership), forKey: .anthosCluster)
            case .customTarget(let customTargetType):
                try container.encode(CustomConfig(customTargetType: customTargetType), forKey: .customTarget)
            }
        }

        private struct GKEConfig: Codable {
            let cluster: String
            let internalIP: Bool?
        }
        private struct CloudRunConfig: Codable {
            let location: String
        }
        private struct AnthosConfig: Codable {
            let membership: String
        }
        private struct CustomConfig: Codable {
            let customTargetType: String
        }
    }

    /// Execution configuration
    public struct ExecutionConfig: Codable, Sendable, Equatable {
        public let usages: [Usage]
        public let workerPool: String?
        public let serviceAccount: String?
        public let artifactStorage: String?
        public let executionTimeout: String?

        public enum Usage: String, Codable, Sendable, Equatable {
            case render = "RENDER"
            case deploy = "DEPLOY"
            case verify = "VERIFY"
            case predeploy = "PREDEPLOY"
            case postdeploy = "POSTDEPLOY"
        }

        public init(
            usages: [Usage],
            workerPool: String? = nil,
            serviceAccount: String? = nil,
            artifactStorage: String? = nil,
            executionTimeout: String? = nil
        ) {
            self.usages = usages
            self.workerPool = workerPool
            self.serviceAccount = serviceAccount
            self.artifactStorage = artifactStorage
            self.executionTimeout = executionTimeout
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        description: String? = nil,
        targetType: TargetType,
        requireApproval: Bool? = nil,
        labels: [String: String]? = nil,
        executionConfigs: [ExecutionConfig]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.targetType = targetType
        self.requireApproval = requireApproval
        self.labels = labels
        self.executionConfigs = executionConfigs
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/targets/\(name)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "gcloud deploy targets create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(location)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        switch targetType {
        case .gke(let cluster, let internalIP):
            cmd += " --gke-cluster=\(cluster)"
            if internalIP == true {
                cmd += " --internal-ip"
            }
        case .cloudRun(let runLocation):
            cmd += " --run-location=\(runLocation)"
        case .anthosCluster(let membership):
            cmd += " --anthos-membership=\(membership)"
        case .customTarget(let customTargetType):
            cmd += " --custom-target-type=\(customTargetType)"
        }
        if requireApproval == true {
            cmd += " --require-approval"
        }
        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelString)"
        }
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud deploy targets describe \(name) --project=\(projectID) --region=\(location)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud deploy targets delete \(name) --project=\(projectID) --region=\(location) --quiet"
    }

    /// List command
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud deploy targets list --project=\(projectID) --region=\(location)"
    }
}

// MARK: - Release

/// Represents a Cloud Deploy release
public struct GoogleCloudDeployRelease: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let pipelineName: String
    public let description: String?
    public let buildArtifacts: [BuildArtifact]?
    public let skaffoldConfigUri: String?
    public let skaffoldConfigPath: String?
    public let labels: [String: String]?

    /// Build artifact
    public struct BuildArtifact: Codable, Sendable, Equatable {
        public let image: String
        public let tag: String

        public init(image: String, tag: String) {
            self.image = image
            self.tag = tag
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        pipelineName: String,
        description: String? = nil,
        buildArtifacts: [BuildArtifact]? = nil,
        skaffoldConfigUri: String? = nil,
        skaffoldConfigPath: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.pipelineName = pipelineName
        self.description = description
        self.buildArtifacts = buildArtifacts
        self.skaffoldConfigUri = skaffoldConfigUri
        self.skaffoldConfigPath = skaffoldConfigPath
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/deliveryPipelines/\(pipelineName)/releases/\(name)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "gcloud deploy releases create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(location)"
        cmd += " --delivery-pipeline=\(pipelineName)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let artifacts = buildArtifacts, !artifacts.isEmpty {
            let artifactString = artifacts.map { "\($0.image)=\($0.tag)" }.joined(separator: ",")
            cmd += " --images=\(artifactString)"
        }
        if let skaffoldUri = skaffoldConfigUri {
            cmd += " --source=\(skaffoldUri)"
        }
        if let skaffoldPath = skaffoldConfigPath {
            cmd += " --skaffold-file=\(skaffoldPath)"
        }
        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelString)"
        }
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud deploy releases describe \(name) --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName)"
    }

    /// List command
    public static func listCommand(projectID: String, location: String, pipelineName: String) -> String {
        "gcloud deploy releases list --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName)"
    }

    /// Promote command
    public func promoteCommand(toTarget: String? = nil) -> String {
        var cmd = "gcloud deploy releases promote --release=\(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(location)"
        cmd += " --delivery-pipeline=\(pipelineName)"
        if let target = toTarget {
            cmd += " --to-target=\(target)"
        }
        return cmd
    }
}

// MARK: - Rollout

/// Represents a Cloud Deploy rollout
public struct GoogleCloudDeployRollout: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let pipelineName: String
    public let releaseName: String
    public let targetId: String
    public let state: RolloutState?

    /// Rollout state
    public enum RolloutState: String, Codable, Sendable, Equatable {
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
        case inProgress = "IN_PROGRESS"
        case pendingApproval = "PENDING_APPROVAL"
        case approvalRejected = "APPROVAL_REJECTED"
        case pending = "PENDING"
        case pendingRelease = "PENDING_RELEASE"
        case cancelling = "CANCELLING"
        case cancelled = "CANCELLED"
        case halted = "HALTED"
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        pipelineName: String,
        releaseName: String,
        targetId: String,
        state: RolloutState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.pipelineName = pipelineName
        self.releaseName = releaseName
        self.targetId = targetId
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/deliveryPipelines/\(pipelineName)/releases/\(releaseName)/rollouts/\(name)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud deploy rollouts describe \(name) --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName) --release=\(releaseName)"
    }

    /// List command
    public static func listCommand(projectID: String, location: String, pipelineName: String, releaseName: String) -> String {
        "gcloud deploy rollouts list --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName) --release=\(releaseName)"
    }

    /// Approve command
    public var approveCommand: String {
        "gcloud deploy rollouts approve \(name) --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName) --release=\(releaseName)"
    }

    /// Reject command
    public var rejectCommand: String {
        "gcloud deploy rollouts reject \(name) --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName) --release=\(releaseName)"
    }

    /// Retry command
    public var retryCommand: String {
        "gcloud deploy rollouts retry-job \(name) --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName) --release=\(releaseName)"
    }

    /// Cancel command
    public var cancelCommand: String {
        "gcloud deploy rollouts cancel \(name) --project=\(projectID) --region=\(location) --delivery-pipeline=\(pipelineName) --release=\(releaseName)"
    }
}

// MARK: - Cloud Deploy Operations

/// Operations helper for Cloud Deploy
public struct CloudDeployOperations {

    /// Enable Cloud Deploy API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable clouddeploy.googleapis.com --project=\(projectID)"
    }

    /// Get service account
    public static func getServiceAccountCommand(projectID: String, location: String) -> String {
        "gcloud deploy get-config --project=\(projectID) --region=\(location)"
    }

    /// Create automation
    public static func createAutomationCommand(
        name: String,
        projectID: String,
        location: String,
        pipelineName: String,
        targetId: String,
        serviceAccount: String,
        automationType: AutomationType
    ) -> String {
        var cmd = "gcloud deploy automations create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(location)"
        cmd += " --delivery-pipeline=\(pipelineName)"
        cmd += " --selector-targets=\(targetId)"
        cmd += " --service-account=\(serviceAccount)"
        switch automationType {
        case .promoteRelease:
            cmd += " --promote-release-rule=promoteRule"
        case .advanceRollout:
            cmd += " --advance-rollout-rule=advanceRule"
        }
        return cmd
    }

    /// Automation type
    public enum AutomationType {
        case promoteRelease
        case advanceRollout
    }
}

// MARK: - DAIS Cloud Deploy Template

/// Cloud Deploy templates for DAIS deployments
public struct DAISCloudDeployTemplate {

    /// Create delivery pipeline for Cloud Run
    public static func cloudRunPipeline(
        projectID: String,
        location: String,
        deploymentName: String,
        stages: [(name: String, runLocation: String, requireApproval: Bool)]
    ) -> GoogleCloudDeliveryPipeline {
        GoogleCloudDeliveryPipeline(
            name: "\(deploymentName)-pipeline",
            projectID: projectID,
            location: location,
            description: "DAIS \(deploymentName) delivery pipeline",
            serialPipeline: GoogleCloudDeliveryPipeline.SerialPipeline(
                stages: stages.map { stage in
                    GoogleCloudDeliveryPipeline.SerialPipeline.Stage(
                        targetId: stage.name,
                        profiles: [stage.name]
                    )
                }
            ),
            labels: [
                "deployment": deploymentName,
                "managed-by": "dais"
            ]
        )
    }

    /// Create Cloud Run target
    public static func cloudRunTarget(
        projectID: String,
        location: String,
        deploymentName: String,
        environment: String,
        runLocation: String,
        requireApproval: Bool = false
    ) -> GoogleCloudDeployTarget {
        GoogleCloudDeployTarget(
            name: "\(deploymentName)-\(environment)",
            projectID: projectID,
            location: location,
            description: "DAIS \(deploymentName) \(environment) target",
            targetType: .cloudRun(location: runLocation),
            requireApproval: requireApproval,
            labels: [
                "deployment": deploymentName,
                "environment": environment,
                "managed-by": "dais"
            ]
        )
    }

    /// Create GKE target
    public static func gkeTarget(
        projectID: String,
        location: String,
        deploymentName: String,
        environment: String,
        clusterName: String,
        clusterLocation: String,
        requireApproval: Bool = false
    ) -> GoogleCloudDeployTarget {
        let cluster = "projects/\(projectID)/locations/\(clusterLocation)/clusters/\(clusterName)"
        return GoogleCloudDeployTarget(
            name: "\(deploymentName)-\(environment)",
            projectID: projectID,
            location: location,
            description: "DAIS \(deploymentName) \(environment) GKE target",
            targetType: .gke(cluster: cluster, internalIP: false),
            requireApproval: requireApproval,
            labels: [
                "deployment": deploymentName,
                "environment": environment,
                "managed-by": "dais"
            ]
        )
    }

    /// Generate skaffold.yaml for Cloud Run
    public static func skaffoldYamlCloudRun(
        projectID: String,
        serviceName: String,
        image: String
    ) -> String {
        """
        apiVersion: skaffold/v4beta7
        kind: Config
        metadata:
          name: \(serviceName)
        manifests:
          rawYaml:
            - service.yaml
        deploy:
          cloudrun: {}
        """
    }

    /// Generate service.yaml for Cloud Run
    public static func cloudRunServiceYaml(
        serviceName: String,
        image: String,
        port: Int = 8080,
        memory: String = "512Mi",
        cpu: String = "1"
    ) -> String {
        """
        apiVersion: serving.knative.dev/v1
        kind: Service
        metadata:
          name: \(serviceName)
        spec:
          template:
            spec:
              containers:
                - image: \(image)
                  ports:
                    - containerPort: \(port)
                  resources:
                    limits:
                      memory: \(memory)
                      cpu: \(cpu)
        """
    }

    /// Setup script
    public static func setupScript(
        projectID: String,
        location: String,
        deploymentName: String,
        environments: [(name: String, runLocation: String, requireApproval: Bool)]
    ) -> String {
        var script = """
        #!/bin/bash
        set -e

        # Cloud Deploy Setup for \(deploymentName)
        # Project: \(projectID)
        # Region: \(location)

        echo "Enabling Cloud Deploy API..."
        gcloud services enable clouddeploy.googleapis.com --project=\(projectID)

        echo "Creating targets..."

        """

        for env in environments {
            script += """
            echo "Creating target: \(deploymentName)-\(env.name)"
            gcloud deploy targets create \(deploymentName)-\(env.name) \\
                --project=\(projectID) \\
                --region=\(location) \\
                --run-location=\(env.runLocation) \\
                --description="DAIS \(deploymentName) \(env.name)" \\
            \(env.requireApproval ? "    --require-approval \\" : "")
                --labels=deployment=\(deploymentName),environment=\(env.name),managed-by=dais || true


            """
        }

        script += """
        echo "Creating delivery pipeline..."
        cat > /tmp/\(deploymentName)-pipeline.yaml << 'EOF'
        apiVersion: deploy.cloud.google.com/v1
        kind: DeliveryPipeline
        metadata:
          name: \(deploymentName)-pipeline
          labels:
            deployment: \(deploymentName)
            managed-by: dais
        description: DAIS \(deploymentName) delivery pipeline
        serialPipeline:
          stages:

        """

        for env in environments {
            script += """
            - targetId: \(deploymentName)-\(env.name)
              profiles:
                - \(env.name)

        """
        }

        script += """
        EOF

        gcloud deploy apply --file=/tmp/\(deploymentName)-pipeline.yaml \\
            --project=\(projectID) \\
            --region=\(location)

        echo "Cloud Deploy setup complete!"
        echo "Pipeline: \(deploymentName)-pipeline"
        """

        return script
    }

    /// Teardown script
    public static func teardownScript(
        projectID: String,
        location: String,
        deploymentName: String,
        environments: [String]
    ) -> String {
        var script = """
        #!/bin/bash
        set -e

        # Cloud Deploy Teardown for \(deploymentName)

        echo "Deleting delivery pipeline..."
        gcloud deploy delivery-pipelines delete \(deploymentName)-pipeline \\
            --project=\(projectID) \\
            --region=\(location) \\
            --force \\
            --quiet || true

        echo "Deleting targets..."

        """

        for env in environments {
            script += """
            gcloud deploy targets delete \(deploymentName)-\(env) \\
                --project=\(projectID) \\
                --region=\(location) \\
                --quiet || true

            """
        }

        script += """

        echo "Cloud Deploy teardown complete!"
        """

        return script
    }
}
