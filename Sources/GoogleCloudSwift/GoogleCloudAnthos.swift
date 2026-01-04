// GoogleCloudAnthos.swift
// Anthos - Hybrid and multi-cloud platform
// Service #60

import Foundation

// MARK: - Anthos Membership

/// An Anthos membership for a cluster
public struct GoogleCloudAnthosMembership: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let externalId: String?
    public let endpoint: Endpoint?
    public let authority: Authority?
    public let labels: [String: String]?
    public let state: State?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        description: String? = nil,
        externalId: String? = nil,
        endpoint: Endpoint? = nil,
        authority: Authority? = nil,
        labels: [String: String]? = nil,
        state: State? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.externalId = externalId
        self.endpoint = endpoint
        self.authority = authority
        self.labels = labels
        self.state = state
    }

    /// Membership endpoint
    public struct Endpoint: Codable, Sendable, Equatable {
        public let gkeCluster: GKECluster?
        public let onPremCluster: OnPremCluster?
        public let multiCloudCluster: MultiCloudCluster?
        public let kubernetesMetadata: KubernetesMetadata?

        public init(
            gkeCluster: GKECluster? = nil,
            onPremCluster: OnPremCluster? = nil,
            multiCloudCluster: MultiCloudCluster? = nil,
            kubernetesMetadata: KubernetesMetadata? = nil
        ) {
            self.gkeCluster = gkeCluster
            self.onPremCluster = onPremCluster
            self.multiCloudCluster = multiCloudCluster
            self.kubernetesMetadata = kubernetesMetadata
        }

        public struct GKECluster: Codable, Sendable, Equatable {
            public let resourceLink: String
            public let clusterMissing: Bool?

            public init(resourceLink: String, clusterMissing: Bool? = nil) {
                self.resourceLink = resourceLink
                self.clusterMissing = clusterMissing
            }
        }

        public struct OnPremCluster: Codable, Sendable, Equatable {
            public let resourceLink: String?
            public let clusterMissing: Bool?
            public let adminCluster: Bool?
            public let clusterType: ClusterType?

            public init(
                resourceLink: String? = nil,
                clusterMissing: Bool? = nil,
                adminCluster: Bool? = nil,
                clusterType: ClusterType? = nil
            ) {
                self.resourceLink = resourceLink
                self.clusterMissing = clusterMissing
                self.adminCluster = adminCluster
                self.clusterType = clusterType
            }

            public enum ClusterType: String, Codable, Sendable {
                case clusterTypeUnspecified = "CLUSTERTYPE_UNSPECIFIED"
                case bootstrap = "BOOTSTRAP"
                case hybrid = "HYBRID"
                case standalone = "STANDALONE"
                case user = "USER"
            }
        }

        public struct MultiCloudCluster: Codable, Sendable, Equatable {
            public let resourceLink: String?
            public let clusterMissing: Bool?

            public init(resourceLink: String? = nil, clusterMissing: Bool? = nil) {
                self.resourceLink = resourceLink
                self.clusterMissing = clusterMissing
            }
        }

        public struct KubernetesMetadata: Codable, Sendable, Equatable {
            public let kubernetesApiServerVersion: String?
            public let nodeProviderId: String?
            public let nodeCount: Int?
            public let vcpuCount: Int?
            public let memoryMb: Int?

            public init(
                kubernetesApiServerVersion: String? = nil,
                nodeProviderId: String? = nil,
                nodeCount: Int? = nil,
                vcpuCount: Int? = nil,
                memoryMb: Int? = nil
            ) {
                self.kubernetesApiServerVersion = kubernetesApiServerVersion
                self.nodeProviderId = nodeProviderId
                self.nodeCount = nodeCount
                self.vcpuCount = vcpuCount
                self.memoryMb = memoryMb
            }
        }
    }

    /// Authority for workload identity
    public struct Authority: Codable, Sendable, Equatable {
        public let issuer: String?
        public let workloadIdentityPool: String?
        public let identityProvider: String?
        public let oidcJwks: String?

        public init(
            issuer: String? = nil,
            workloadIdentityPool: String? = nil,
            identityProvider: String? = nil,
            oidcJwks: String? = nil
        ) {
            self.issuer = issuer
            self.workloadIdentityPool = workloadIdentityPool
            self.identityProvider = identityProvider
            self.oidcJwks = oidcJwks
        }
    }

    /// Membership state
    public struct State: Codable, Sendable, Equatable {
        public let code: Code?
        public let description: String?

        public init(code: Code? = nil, description: String? = nil) {
            self.code = code
            self.description = description
        }

        public enum Code: String, Codable, Sendable {
            case codeUnspecified = "CODE_UNSPECIFIED"
            case creating = "CREATING"
            case ready = "READY"
            case deleting = "DELETING"
            case updating = "UPDATING"
            case serviceUpdating = "SERVICE_UPDATING"
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/memberships/\(name)"
    }

    /// Register command
    public var registerCommand: String {
        "gcloud container hub memberships register \(name) --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud container hub memberships describe \(name) --project=\(projectID)"
    }

    /// Delete command
    public var unregisterCommand: String {
        "gcloud container hub memberships unregister \(name) --project=\(projectID)"
    }
}

// MARK: - Anthos Feature

/// An Anthos feature (e.g., Config Management, Service Mesh)
public struct GoogleCloudAnthosFeature: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let featureType: FeatureType
    public let labels: [String: String]?
    public let spec: FeatureSpec?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        featureType: FeatureType,
        labels: [String: String]? = nil,
        spec: FeatureSpec? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.featureType = featureType
        self.labels = labels
        self.spec = spec
    }

    /// Anthos feature type
    public enum FeatureType: String, Codable, Sendable {
        case configManagement = "configmanagement"
        case serviceMesh = "servicemesh"
        case identityService = "identityservice"
        case multiClusterIngress = "multiclusteringress"
        case multiClusterServiceDiscovery = "multiclusterservicediscovery"
        case fleetObservability = "fleetobservability"
        case policyController = "policycontroller"
        case clusterUpgrade = "clusterupgrade"
    }

    /// Feature specification
    public struct FeatureSpec: Codable, Sendable, Equatable {
        public let multiClusterIngress: MultiClusterIngressSpec?
        public let fleetObservability: FleetObservabilitySpec?

        public init(
            multiClusterIngress: MultiClusterIngressSpec? = nil,
            fleetObservability: FleetObservabilitySpec? = nil
        ) {
            self.multiClusterIngress = multiClusterIngress
            self.fleetObservability = fleetObservability
        }

        public struct MultiClusterIngressSpec: Codable, Sendable, Equatable {
            public let configMembership: String

            public init(configMembership: String) {
                self.configMembership = configMembership
            }
        }

        public struct FleetObservabilitySpec: Codable, Sendable, Equatable {
            public let loggingConfig: LoggingConfig?

            public init(loggingConfig: LoggingConfig? = nil) {
                self.loggingConfig = loggingConfig
            }

            public struct LoggingConfig: Codable, Sendable, Equatable {
                public let defaultConfig: DefaultConfig?
                public let fleetScopeLogsConfig: FleetScopeLogsConfig?

                public init(defaultConfig: DefaultConfig? = nil, fleetScopeLogsConfig: FleetScopeLogsConfig? = nil) {
                    self.defaultConfig = defaultConfig
                    self.fleetScopeLogsConfig = fleetScopeLogsConfig
                }

                public struct DefaultConfig: Codable, Sendable, Equatable {
                    public let mode: Mode?

                    public init(mode: Mode? = nil) {
                        self.mode = mode
                    }

                    public enum Mode: String, Codable, Sendable {
                        case modeUnspecified = "MODE_UNSPECIFIED"
                        case copy = "COPY"
                        case move = "MOVE"
                    }
                }

                public struct FleetScopeLogsConfig: Codable, Sendable, Equatable {
                    public let mode: DefaultConfig.Mode?

                    public init(mode: DefaultConfig.Mode? = nil) {
                        self.mode = mode
                    }
                }
            }
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/features/\(featureType.rawValue)"
    }

    /// Enable command
    public var enableCommand: String {
        "gcloud container hub features enable \(featureType.rawValue) --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud container hub features describe \(featureType.rawValue) --project=\(projectID)"
    }

    /// Disable command
    public var disableCommand: String {
        "gcloud container hub features disable \(featureType.rawValue) --project=\(projectID)"
    }
}

// MARK: - Anthos Config Management

/// Anthos Config Management configuration
public struct GoogleCloudAnthosConfigManagement: Codable, Sendable, Equatable {
    public let membership: String
    public let projectID: String
    public let configSync: ConfigSync?
    public let policyController: PolicyController?
    public let hierarchyController: HierarchyController?
    public let version: String?

    public init(
        membership: String,
        projectID: String,
        configSync: ConfigSync? = nil,
        policyController: PolicyController? = nil,
        hierarchyController: HierarchyController? = nil,
        version: String? = nil
    ) {
        self.membership = membership
        self.projectID = projectID
        self.configSync = configSync
        self.policyController = policyController
        self.hierarchyController = hierarchyController
        self.version = version
    }

    /// Config Sync settings
    public struct ConfigSync: Codable, Sendable, Equatable {
        public let enabled: Bool?
        public let sourceFormat: SourceFormat?
        public let git: GitConfig?
        public let oci: OCIConfig?
        public let preventDrift: Bool?

        public init(
            enabled: Bool? = nil,
            sourceFormat: SourceFormat? = nil,
            git: GitConfig? = nil,
            oci: OCIConfig? = nil,
            preventDrift: Bool? = nil
        ) {
            self.enabled = enabled
            self.sourceFormat = sourceFormat
            self.git = git
            self.oci = oci
            self.preventDrift = preventDrift
        }

        public enum SourceFormat: String, Codable, Sendable {
            case unstructured = "unstructured"
            case hierarchy = "hierarchy"
        }

        public struct GitConfig: Codable, Sendable, Equatable {
            public let syncRepo: String
            public let syncBranch: String?
            public let policyDir: String?
            public let secretType: SecretType?
            public let syncWaitSecs: Int?
            public let syncRev: String?
            public let gcpServiceAccountEmail: String?
            public let httpsProxy: String?

            public init(
                syncRepo: String,
                syncBranch: String? = nil,
                policyDir: String? = nil,
                secretType: SecretType? = nil,
                syncWaitSecs: Int? = nil,
                syncRev: String? = nil,
                gcpServiceAccountEmail: String? = nil,
                httpsProxy: String? = nil
            ) {
                self.syncRepo = syncRepo
                self.syncBranch = syncBranch
                self.policyDir = policyDir
                self.secretType = secretType
                self.syncWaitSecs = syncWaitSecs
                self.syncRev = syncRev
                self.gcpServiceAccountEmail = gcpServiceAccountEmail
                self.httpsProxy = httpsProxy
            }

            public enum SecretType: String, Codable, Sendable {
                case none = "none"
                case ssh = "ssh"
                case cookiefile = "cookiefile"
                case token = "token"
                case gcpServiceAccount = "gcpserviceaccount"
                case gceNode = "gcenode"
                case gitHubApp = "githubapp"
            }
        }

        public struct OCIConfig: Codable, Sendable, Equatable {
            public let syncRepo: String
            public let policyDir: String?
            public let secretType: String?
            public let gcpServiceAccountEmail: String?

            public init(
                syncRepo: String,
                policyDir: String? = nil,
                secretType: String? = nil,
                gcpServiceAccountEmail: String? = nil
            ) {
                self.syncRepo = syncRepo
                self.policyDir = policyDir
                self.secretType = secretType
                self.gcpServiceAccountEmail = gcpServiceAccountEmail
            }
        }
    }

    /// Policy Controller settings
    public struct PolicyController: Codable, Sendable, Equatable {
        public let enabled: Bool?
        public let templateLibraryInstalled: Bool?
        public let referentialRulesEnabled: Bool?
        public let logDeniesEnabled: Bool?
        public let mutationEnabled: Bool?
        public let auditIntervalSeconds: Int?
        public let exemptableNamespaces: [String]?

        public init(
            enabled: Bool? = nil,
            templateLibraryInstalled: Bool? = nil,
            referentialRulesEnabled: Bool? = nil,
            logDeniesEnabled: Bool? = nil,
            mutationEnabled: Bool? = nil,
            auditIntervalSeconds: Int? = nil,
            exemptableNamespaces: [String]? = nil
        ) {
            self.enabled = enabled
            self.templateLibraryInstalled = templateLibraryInstalled
            self.referentialRulesEnabled = referentialRulesEnabled
            self.logDeniesEnabled = logDeniesEnabled
            self.mutationEnabled = mutationEnabled
            self.auditIntervalSeconds = auditIntervalSeconds
            self.exemptableNamespaces = exemptableNamespaces
        }
    }

    /// Hierarchy Controller settings
    public struct HierarchyController: Codable, Sendable, Equatable {
        public let enabled: Bool?
        public let enablePodTreeLabels: Bool?
        public let enableHierarchicalResourceQuota: Bool?

        public init(
            enabled: Bool? = nil,
            enablePodTreeLabels: Bool? = nil,
            enableHierarchicalResourceQuota: Bool? = nil
        ) {
            self.enabled = enabled
            self.enablePodTreeLabels = enablePodTreeLabels
            self.enableHierarchicalResourceQuota = enableHierarchicalResourceQuota
        }
    }

    /// Apply command
    public var applyCommand: String {
        "gcloud container hub config-management apply --membership=\(membership) --project=\(projectID)"
    }

    /// Status command
    public var statusCommand: String {
        "gcloud container hub config-management status --project=\(projectID)"
    }
}

// MARK: - Anthos Service Mesh

/// Anthos Service Mesh configuration
public struct GoogleCloudAnthosServiceMesh: Codable, Sendable, Equatable {
    public let membership: String
    public let projectID: String
    public let controlPlane: ControlPlane?
    public let dataPlane: DataPlane?
    public let meshConfig: MeshConfig?

    public init(
        membership: String,
        projectID: String,
        controlPlane: ControlPlane? = nil,
        dataPlane: DataPlane? = nil,
        meshConfig: MeshConfig? = nil
    ) {
        self.membership = membership
        self.projectID = projectID
        self.controlPlane = controlPlane
        self.dataPlane = dataPlane
        self.meshConfig = meshConfig
    }

    /// Control plane configuration
    public struct ControlPlane: Codable, Sendable, Equatable {
        public let management: Management?

        public init(management: Management? = nil) {
            self.management = management
        }

        public enum Management: String, Codable, Sendable {
            case managementUnspecified = "MANAGEMENT_UNSPECIFIED"
            case automatic = "AUTOMATIC"
            case manual = "MANUAL"
        }
    }

    /// Data plane configuration
    public struct DataPlane: Codable, Sendable, Equatable {
        public let management: Management?

        public init(management: Management? = nil) {
            self.management = management
        }

        public enum Management: String, Codable, Sendable {
            case managementUnspecified = "MANAGEMENT_UNSPECIFIED"
            case automatic = "AUTOMATIC"
            case manual = "MANUAL"
        }
    }

    /// Mesh configuration
    public struct MeshConfig: Codable, Sendable, Equatable {
        public let accessLogging: AccessLoggingConfig?
        public let enableAutoMtls: Bool?
        public let defaultProviders: [String]?

        public init(
            accessLogging: AccessLoggingConfig? = nil,
            enableAutoMtls: Bool? = nil,
            defaultProviders: [String]? = nil
        ) {
            self.accessLogging = accessLogging
            self.enableAutoMtls = enableAutoMtls
            self.defaultProviders = defaultProviders
        }

        public struct AccessLoggingConfig: Codable, Sendable, Equatable {
            public let enabled: Bool?
            public let filter: String?

            public init(enabled: Bool? = nil, filter: String? = nil) {
                self.enabled = enabled
                self.filter = filter
            }
        }
    }

    /// Apply command
    public var applyCommand: String {
        "gcloud container hub mesh update --membership=\(membership) --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud container hub mesh describe --membership=\(membership) --project=\(projectID)"
    }
}

// MARK: - Anthos Fleet

/// An Anthos Fleet for managing multiple clusters
public struct GoogleCloudAnthosFleet: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let displayName: String?
    public let defaultClusterConfig: DefaultClusterConfig?

    public init(
        name: String = "default",
        projectID: String,
        displayName: String? = nil,
        defaultClusterConfig: DefaultClusterConfig? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.displayName = displayName
        self.defaultClusterConfig = defaultClusterConfig
    }

    /// Default cluster configuration
    public struct DefaultClusterConfig: Codable, Sendable, Equatable {
        public let securityPostureConfig: SecurityPostureConfig?
        public let binaryAuthorizationConfig: BinaryAuthorizationConfig?

        public init(
            securityPostureConfig: SecurityPostureConfig? = nil,
            binaryAuthorizationConfig: BinaryAuthorizationConfig? = nil
        ) {
            self.securityPostureConfig = securityPostureConfig
            self.binaryAuthorizationConfig = binaryAuthorizationConfig
        }

        public struct SecurityPostureConfig: Codable, Sendable, Equatable {
            public let mode: Mode?
            public let vulnerabilityMode: VulnerabilityMode?

            public init(mode: Mode? = nil, vulnerabilityMode: VulnerabilityMode? = nil) {
                self.mode = mode
                self.vulnerabilityMode = vulnerabilityMode
            }

            public enum Mode: String, Codable, Sendable {
                case modeUnspecified = "MODE_UNSPECIFIED"
                case disabled = "DISABLED"
                case basic = "BASIC"
                case enterprise = "ENTERPRISE"
            }

            public enum VulnerabilityMode: String, Codable, Sendable {
                case vulnerabilityModeUnspecified = "VULNERABILITY_MODE_UNSPECIFIED"
                case vulnerabilityDisabled = "VULNERABILITY_DISABLED"
                case vulnerabilityBasic = "VULNERABILITY_BASIC"
                case vulnerabilityEnterprise = "VULNERABILITY_ENTERPRISE"
            }
        }

        public struct BinaryAuthorizationConfig: Codable, Sendable, Equatable {
            public let evaluationMode: EvaluationMode?
            public let policyBindings: [PolicyBinding]?

            public init(evaluationMode: EvaluationMode? = nil, policyBindings: [PolicyBinding]? = nil) {
                self.evaluationMode = evaluationMode
                self.policyBindings = policyBindings
            }

            public enum EvaluationMode: String, Codable, Sendable {
                case evaluationModeUnspecified = "EVALUATION_MODE_UNSPECIFIED"
                case disabled = "DISABLED"
                case policyBindings = "POLICY_BINDINGS"
            }

            public struct PolicyBinding: Codable, Sendable, Equatable {
                public let name: String

                public init(name: String) {
                    self.name = name
                }
            }
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/global/fleets/\(name)"
    }

    /// Create command
    public var createCommand: String {
        "gcloud container hub fleets create --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud container hub fleets describe --project=\(projectID)"
    }
}

// MARK: - Anthos Operations

/// Operations for Anthos
public struct AnthosOperations: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Enable Anthos API
    public var enableAPICommand: String {
        "gcloud services enable gkehub.googleapis.com anthos.googleapis.com anthosconfigmanagement.googleapis.com mesh.googleapis.com --project=\(projectID)"
    }

    /// List memberships
    public var listMembershipsCommand: String {
        "gcloud container hub memberships list --project=\(projectID)"
    }

    /// List features
    public var listFeaturesCommand: String {
        "gcloud container hub features list --project=\(projectID)"
    }

    /// Register GKE cluster
    public func registerGKEClusterCommand(
        membershipName: String,
        clusterName: String,
        location: String
    ) -> String {
        "gcloud container hub memberships register \(membershipName) --gke-cluster=\(location)/\(clusterName) --enable-workload-identity --project=\(projectID)"
    }

    /// Register external cluster
    public func registerExternalClusterCommand(
        membershipName: String,
        kubeconfigPath: String,
        context: String? = nil
    ) -> String {
        var cmd = "gcloud container hub memberships register \(membershipName) --kubeconfig=\(kubeconfigPath) --project=\(projectID)"
        if let ctx = context {
            cmd += " --context=\(ctx)"
        }
        return cmd
    }

    /// Generate connect agent manifest
    public func generateConnectAgentCommand(membershipName: String) -> String {
        "gcloud container hub memberships generate-gateway-rbac --membership=\(membershipName) --project=\(projectID)"
    }

    /// Enable feature
    public func enableFeatureCommand(feature: GoogleCloudAnthosFeature.FeatureType) -> String {
        "gcloud container hub features enable \(feature.rawValue) --project=\(projectID)"
    }

    /// Get Config Management status
    public var configManagementStatusCommand: String {
        "gcloud container hub config-management status --project=\(projectID)"
    }

    /// Get Service Mesh status
    public func serviceMeshStatusCommand(membership: String) -> String {
        "gcloud container hub mesh describe --membership=\(membership) --project=\(projectID)"
    }

    /// Apply Config Management config from file
    public func applyConfigManagementCommand(membership: String, configFile: String) -> String {
        "gcloud container hub config-management apply --membership=\(membership) --config=\(configFile) --project=\(projectID)"
    }

    /// IAM roles for Anthos
    public enum AnthosRole: String, Sendable {
        case gkehubAdmin = "roles/gkehub.admin"
        case gkehubEditor = "roles/gkehub.editor"
        case gkehubViewer = "roles/gkehub.viewer"
        case gkehubGatewayAdmin = "roles/gkehub.gatewayAdmin"
        case anthosServiceMeshAdmin = "roles/anthosservicemesh.admin"
        case anthosConfigManagementAdmin = "roles/anthosconfigmanagement.admin"
    }

    /// Add IAM binding
    public func addIAMBindingCommand(member: String, role: AnthosRole) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=\(role.rawValue)"
    }
}

// MARK: - DAIS Anthos Template

/// DAIS template for Anthos configurations
public struct DAISAnthosTemplate: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Create a GKE membership
    public func gkeMembership(
        name: String,
        clusterResourceLink: String,
        location: String = "global"
    ) -> GoogleCloudAnthosMembership {
        GoogleCloudAnthosMembership(
            name: name,
            projectID: projectID,
            location: location,
            endpoint: .init(
                gkeCluster: .init(resourceLink: clusterResourceLink)
            )
        )
    }

    /// Create an on-prem membership
    public func onPremMembership(
        name: String,
        clusterType: GoogleCloudAnthosMembership.Endpoint.OnPremCluster.ClusterType = .user,
        location: String = "global"
    ) -> GoogleCloudAnthosMembership {
        GoogleCloudAnthosMembership(
            name: name,
            projectID: projectID,
            location: location,
            endpoint: .init(
                onPremCluster: .init(clusterType: clusterType)
            )
        )
    }

    /// Create a Config Management feature
    public func configManagementFeature() -> GoogleCloudAnthosFeature {
        GoogleCloudAnthosFeature(
            name: "configmanagement",
            projectID: projectID,
            featureType: .configManagement
        )
    }

    /// Create a Service Mesh feature
    public func serviceMeshFeature() -> GoogleCloudAnthosFeature {
        GoogleCloudAnthosFeature(
            name: "servicemesh",
            projectID: projectID,
            featureType: .serviceMesh
        )
    }

    /// Create Config Management with Git sync
    public func configManagementWithGit(
        membership: String,
        gitRepo: String,
        branch: String = "main",
        policyDir: String = "/",
        secretType: GoogleCloudAnthosConfigManagement.ConfigSync.GitConfig.SecretType = .none
    ) -> GoogleCloudAnthosConfigManagement {
        GoogleCloudAnthosConfigManagement(
            membership: membership,
            projectID: projectID,
            configSync: .init(
                enabled: true,
                sourceFormat: .unstructured,
                git: .init(
                    syncRepo: gitRepo,
                    syncBranch: branch,
                    policyDir: policyDir,
                    secretType: secretType
                ),
                preventDrift: true
            ),
            policyController: .init(
                enabled: true,
                templateLibraryInstalled: true,
                referentialRulesEnabled: true,
                logDeniesEnabled: true
            )
        )
    }

    /// Create Service Mesh with automatic management
    public func serviceMeshAutomatic(membership: String) -> GoogleCloudAnthosServiceMesh {
        GoogleCloudAnthosServiceMesh(
            membership: membership,
            projectID: projectID,
            controlPlane: .init(management: .automatic),
            dataPlane: .init(management: .automatic),
            meshConfig: .init(
                enableAutoMtls: true
            )
        )
    }

    /// Create a fleet with security posture
    public func secureFleet(displayName: String) -> GoogleCloudAnthosFleet {
        GoogleCloudAnthosFleet(
            projectID: projectID,
            displayName: displayName,
            defaultClusterConfig: .init(
                securityPostureConfig: .init(
                    mode: .basic,
                    vulnerabilityMode: .vulnerabilityBasic
                )
            )
        )
    }

    /// Operations helper
    public var operations: AnthosOperations {
        AnthosOperations(projectID: projectID)
    }

    /// Generate fleet setup script
    public func fleetSetupScript(
        fleetName: String,
        clusterNames: [String],
        region: String
    ) -> String {
        """
        #!/bin/bash
        # Anthos Fleet Setup Script
        # Project: \(projectID)
        # Fleet: \(fleetName)

        set -e

        PROJECT="\(projectID)"
        REGION="\(region)"

        echo "=== Enabling Anthos APIs ==="
        gcloud services enable \\
            gkehub.googleapis.com \\
            anthos.googleapis.com \\
            anthosconfigmanagement.googleapis.com \\
            mesh.googleapis.com \\
            --project=$PROJECT

        echo ""
        echo "=== Creating Fleet ==="
        gcloud container hub fleets create \\
            --project=$PROJECT \\
            2>/dev/null || echo "Fleet already exists"

        echo ""
        echo "=== Registering Clusters ==="
        \(clusterNames.map { cluster in
            """
            echo "Registering \(cluster)..."
            gcloud container hub memberships register \(cluster) \\
                --gke-cluster=$REGION/\(cluster) \\
                --enable-workload-identity \\
                --project=$PROJECT
            """
        }.joined(separator: "\n"))

        echo ""
        echo "=== Enabling Config Management ==="
        gcloud container hub features enable configmanagement --project=$PROJECT

        echo ""
        echo "=== Enabling Service Mesh ==="
        gcloud container hub features enable mesh --project=$PROJECT

        echo ""
        echo "=== Fleet Setup Complete ==="
        echo "Registered clusters:"
        gcloud container hub memberships list --project=$PROJECT
        """
    }

    /// Generate Config Management YAML
    public func configManagementYAML(
        gitRepo: String,
        branch: String = "main",
        policyDir: String = "/"
    ) -> String {
        """
        # Anthos Config Management configuration
        # Apply with: gcloud container hub config-management apply --membership=MEMBERSHIP --config=config.yaml

        applySpecVersion: 1
        spec:
          configSync:
            enabled: true
            sourceFormat: unstructured
            git:
              syncRepo: \(gitRepo)
              syncBranch: \(branch)
              policyDir: \(policyDir)
              secretType: none
            preventDrift: true
          policyController:
            enabled: true
            templateLibraryInstalled: true
            referentialRulesEnabled: true
            logDeniesEnabled: true
          hierarchyController:
            enabled: false
        """
    }

    /// Generate multi-cluster ingress setup script
    public func multiClusterIngressSetupScript(
        configCluster: String,
        region: String
    ) -> String {
        """
        #!/bin/bash
        # Anthos Multi-Cluster Ingress Setup
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"
        CONFIG_CLUSTER="\(configCluster)"
        REGION="\(region)"

        echo "=== Enabling Multi-Cluster Ingress ==="
        gcloud container hub features enable multiclusteringress \\
            --config-membership=$CONFIG_CLUSTER \\
            --project=$PROJECT

        echo ""
        echo "=== Enabling Multi-Cluster Service Discovery ==="
        gcloud container hub features enable multiclusterservicediscovery \\
            --project=$PROJECT

        echo ""
        echo "=== Verifying Setup ==="
        gcloud container hub features describe multiclusteringress --project=$PROJECT

        echo ""
        echo "=== Multi-Cluster Ingress Ready ==="
        echo "Config cluster: $CONFIG_CLUSTER"
        echo ""
        echo "Next steps:"
        echo "1. Deploy MultiClusterIngress resources to $CONFIG_CLUSTER"
        echo "2. Deploy MultiClusterService resources to specify backend services"
        """
    }
}
