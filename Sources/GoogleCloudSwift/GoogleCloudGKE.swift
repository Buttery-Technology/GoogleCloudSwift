import Foundation

// MARK: - GKE Cluster

/// Represents a Google Kubernetes Engine cluster
public struct GoogleCloudGKECluster: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let initialNodeCount: Int?
    public let nodeConfig: NodeConfig?
    public let masterAuth: MasterAuth?
    public let networkConfig: NetworkConfig?
    public let addonsConfig: AddonsConfig?
    public let releaseChannel: ReleaseChannel?
    public let autopilot: Autopilot?
    public let privateClusterConfig: PrivateClusterConfig?
    public let workloadIdentityConfig: WorkloadIdentityConfig?
    public let labels: [String: String]?
    public let status: ClusterStatus?
    public let endpoint: String?
    public let clusterIpv4Cidr: String?
    public let servicesIpv4Cidr: String?
    public let createTime: Date?

    public struct NodeConfig: Codable, Sendable, Equatable {
        public let machineType: String?
        public let diskSizeGb: Int?
        public let diskType: DiskType?
        public let imageType: String?
        public let preemptible: Bool?
        public let spot: Bool?
        public let oauthScopes: [String]?
        public let serviceAccount: String?
        public let labels: [String: String]?
        public let tags: [String]?
        public let taints: [Taint]?
        public let accelerators: [Accelerator]?

        public enum DiskType: String, Codable, Sendable, Equatable {
            case pdStandard = "pd-standard"
            case pdSsd = "pd-ssd"
            case pdBalanced = "pd-balanced"
        }

        public struct Taint: Codable, Sendable, Equatable {
            public let key: String
            public let value: String
            public let effect: TaintEffect

            public enum TaintEffect: String, Codable, Sendable, Equatable {
                case noSchedule = "NO_SCHEDULE"
                case preferNoSchedule = "PREFER_NO_SCHEDULE"
                case noExecute = "NO_EXECUTE"
            }

            public init(key: String, value: String, effect: TaintEffect) {
                self.key = key
                self.value = value
                self.effect = effect
            }
        }

        public struct Accelerator: Codable, Sendable, Equatable {
            public let acceleratorCount: Int
            public let acceleratorType: String
            public let gpuPartitionSize: String?

            public init(acceleratorCount: Int, acceleratorType: String, gpuPartitionSize: String? = nil) {
                self.acceleratorCount = acceleratorCount
                self.acceleratorType = acceleratorType
                self.gpuPartitionSize = gpuPartitionSize
            }
        }

        public init(
            machineType: String? = nil,
            diskSizeGb: Int? = nil,
            diskType: DiskType? = nil,
            imageType: String? = nil,
            preemptible: Bool? = nil,
            spot: Bool? = nil,
            oauthScopes: [String]? = nil,
            serviceAccount: String? = nil,
            labels: [String: String]? = nil,
            tags: [String]? = nil,
            taints: [Taint]? = nil,
            accelerators: [Accelerator]? = nil
        ) {
            self.machineType = machineType
            self.diskSizeGb = diskSizeGb
            self.diskType = diskType
            self.imageType = imageType
            self.preemptible = preemptible
            self.spot = spot
            self.oauthScopes = oauthScopes
            self.serviceAccount = serviceAccount
            self.labels = labels
            self.tags = tags
            self.taints = taints
            self.accelerators = accelerators
        }
    }

    public struct MasterAuth: Codable, Sendable, Equatable {
        public let clusterCaCertificate: String?
        public let clientCertificate: String?
        public let clientKey: String?

        public init(
            clusterCaCertificate: String? = nil,
            clientCertificate: String? = nil,
            clientKey: String? = nil
        ) {
            self.clusterCaCertificate = clusterCaCertificate
            self.clientCertificate = clientCertificate
            self.clientKey = clientKey
        }
    }

    public struct NetworkConfig: Codable, Sendable, Equatable {
        public let network: String?
        public let subnetwork: String?
        public let enableIntraNodeVisibility: Bool?
        public let datapathProvider: DatapathProvider?

        public enum DatapathProvider: String, Codable, Sendable, Equatable {
            case datapathProviderUnspecified = "DATAPATH_PROVIDER_UNSPECIFIED"
            case legacyDatapath = "LEGACY_DATAPATH"
            case advancedDatapath = "ADVANCED_DATAPATH"
        }

        public init(
            network: String? = nil,
            subnetwork: String? = nil,
            enableIntraNodeVisibility: Bool? = nil,
            datapathProvider: DatapathProvider? = nil
        ) {
            self.network = network
            self.subnetwork = subnetwork
            self.enableIntraNodeVisibility = enableIntraNodeVisibility
            self.datapathProvider = datapathProvider
        }
    }

    public struct AddonsConfig: Codable, Sendable, Equatable {
        public let httpLoadBalancing: HttpLoadBalancing?
        public let horizontalPodAutoscaling: HorizontalPodAutoscaling?
        public let networkPolicyConfig: NetworkPolicyConfig?
        public let gcePersistentDiskCsiDriverConfig: GcePersistentDiskCsiDriverConfig?

        public struct HttpLoadBalancing: Codable, Sendable, Equatable {
            public let disabled: Bool?
            public init(disabled: Bool? = nil) { self.disabled = disabled }
        }

        public struct HorizontalPodAutoscaling: Codable, Sendable, Equatable {
            public let disabled: Bool?
            public init(disabled: Bool? = nil) { self.disabled = disabled }
        }

        public struct NetworkPolicyConfig: Codable, Sendable, Equatable {
            public let disabled: Bool?
            public init(disabled: Bool? = nil) { self.disabled = disabled }
        }

        public struct GcePersistentDiskCsiDriverConfig: Codable, Sendable, Equatable {
            public let enabled: Bool?
            public init(enabled: Bool? = nil) { self.enabled = enabled }
        }

        public init(
            httpLoadBalancing: HttpLoadBalancing? = nil,
            horizontalPodAutoscaling: HorizontalPodAutoscaling? = nil,
            networkPolicyConfig: NetworkPolicyConfig? = nil,
            gcePersistentDiskCsiDriverConfig: GcePersistentDiskCsiDriverConfig? = nil
        ) {
            self.httpLoadBalancing = httpLoadBalancing
            self.horizontalPodAutoscaling = horizontalPodAutoscaling
            self.networkPolicyConfig = networkPolicyConfig
            self.gcePersistentDiskCsiDriverConfig = gcePersistentDiskCsiDriverConfig
        }
    }

    public struct ReleaseChannel: Codable, Sendable, Equatable {
        public let channel: Channel

        public enum Channel: String, Codable, Sendable, Equatable {
            case unspecified = "UNSPECIFIED"
            case rapid = "RAPID"
            case regular = "REGULAR"
            case stable = "STABLE"
        }

        public init(channel: Channel) {
            self.channel = channel
        }
    }

    public struct Autopilot: Codable, Sendable, Equatable {
        public let enabled: Bool

        public init(enabled: Bool) {
            self.enabled = enabled
        }
    }

    public struct PrivateClusterConfig: Codable, Sendable, Equatable {
        public let enablePrivateNodes: Bool?
        public let enablePrivateEndpoint: Bool?
        public let masterIpv4CidrBlock: String?
        public let masterGlobalAccessConfig: MasterGlobalAccessConfig?

        public struct MasterGlobalAccessConfig: Codable, Sendable, Equatable {
            public let enabled: Bool?
            public init(enabled: Bool? = nil) { self.enabled = enabled }
        }

        public init(
            enablePrivateNodes: Bool? = nil,
            enablePrivateEndpoint: Bool? = nil,
            masterIpv4CidrBlock: String? = nil,
            masterGlobalAccessConfig: MasterGlobalAccessConfig? = nil
        ) {
            self.enablePrivateNodes = enablePrivateNodes
            self.enablePrivateEndpoint = enablePrivateEndpoint
            self.masterIpv4CidrBlock = masterIpv4CidrBlock
            self.masterGlobalAccessConfig = masterGlobalAccessConfig
        }
    }

    public struct WorkloadIdentityConfig: Codable, Sendable, Equatable {
        public let workloadPool: String?

        public init(workloadPool: String? = nil) {
            self.workloadPool = workloadPool
        }
    }

    public enum ClusterStatus: String, Codable, Sendable, Equatable {
        case statusUnspecified = "STATUS_UNSPECIFIED"
        case provisioning = "PROVISIONING"
        case running = "RUNNING"
        case reconciling = "RECONCILING"
        case stopping = "STOPPING"
        case error = "ERROR"
        case degraded = "DEGRADED"
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        description: String? = nil,
        initialNodeCount: Int? = nil,
        nodeConfig: NodeConfig? = nil,
        masterAuth: MasterAuth? = nil,
        networkConfig: NetworkConfig? = nil,
        addonsConfig: AddonsConfig? = nil,
        releaseChannel: ReleaseChannel? = nil,
        autopilot: Autopilot? = nil,
        privateClusterConfig: PrivateClusterConfig? = nil,
        workloadIdentityConfig: WorkloadIdentityConfig? = nil,
        labels: [String: String]? = nil,
        status: ClusterStatus? = nil,
        endpoint: String? = nil,
        clusterIpv4Cidr: String? = nil,
        servicesIpv4Cidr: String? = nil,
        createTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.initialNodeCount = initialNodeCount
        self.nodeConfig = nodeConfig
        self.masterAuth = masterAuth
        self.networkConfig = networkConfig
        self.addonsConfig = addonsConfig
        self.releaseChannel = releaseChannel
        self.autopilot = autopilot
        self.privateClusterConfig = privateClusterConfig
        self.workloadIdentityConfig = workloadIdentityConfig
        self.labels = labels
        self.status = status
        self.endpoint = endpoint
        self.clusterIpv4Cidr = clusterIpv4Cidr
        self.servicesIpv4Cidr = servicesIpv4Cidr
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/clusters/\(name)"
    }

    /// Whether this is a regional cluster (regions like us-central1 vs zones like us-central1-a)
    public var isRegional: Bool {
        // Zones end with a single letter suffix like -a, -b, -c, etc.
        // Regions don't have this suffix
        let components = location.split(separator: "-")
        guard let lastComponent = components.last else { return true }
        // If the last component is a single letter, it's a zone
        return lastComponent.count != 1 || !lastComponent.first!.isLetter
    }

    /// Command to create the cluster
    public var createCommand: String {
        var cmd = "gcloud container clusters create \(name) --project=\(projectID)"

        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }

        if let autopilot = autopilot, autopilot.enabled {
            cmd += " --enable-autopilot"
        } else {
            if let nodeCount = initialNodeCount {
                cmd += " --num-nodes=\(nodeCount)"
            }
            if let nodeConfig = nodeConfig {
                if let machineType = nodeConfig.machineType {
                    cmd += " --machine-type=\(machineType)"
                }
                if let diskSize = nodeConfig.diskSizeGb {
                    cmd += " --disk-size=\(diskSize)"
                }
                if let diskType = nodeConfig.diskType {
                    cmd += " --disk-type=\(diskType.rawValue)"
                }
                if nodeConfig.preemptible == true {
                    cmd += " --preemptible"
                }
                if nodeConfig.spot == true {
                    cmd += " --spot"
                }
            }
        }

        if let releaseChannel = releaseChannel {
            cmd += " --release-channel=\(releaseChannel.channel.rawValue.lowercased())"
        }

        if let networkConfig = networkConfig {
            if let network = networkConfig.network {
                cmd += " --network=\(network)"
            }
            if let subnetwork = networkConfig.subnetwork {
                cmd += " --subnetwork=\(subnetwork)"
            }
        }

        if let privateConfig = privateClusterConfig {
            if privateConfig.enablePrivateNodes == true {
                cmd += " --enable-private-nodes"
            }
            if privateConfig.enablePrivateEndpoint == true {
                cmd += " --enable-private-endpoint"
            }
            if let masterCidr = privateConfig.masterIpv4CidrBlock {
                cmd += " --master-ipv4-cidr=\(masterCidr)"
            }
        }

        if let workloadIdentity = workloadIdentityConfig, let pool = workloadIdentity.workloadPool {
            cmd += " --workload-pool=\(pool)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to delete the cluster
    public var deleteCommand: String {
        var cmd = "gcloud container clusters delete \(name) --project=\(projectID) --quiet"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to describe the cluster
    public var describeCommand: String {
        var cmd = "gcloud container clusters describe \(name) --project=\(projectID)"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to get credentials for kubectl
    public var getCredentialsCommand: String {
        var cmd = "gcloud container clusters get-credentials \(name) --project=\(projectID)"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to resize the cluster
    public func resizeCommand(nodeCount: Int, nodePool: String = "default-pool") -> String {
        var cmd = "gcloud container clusters resize \(name) --node-pool=\(nodePool) --num-nodes=\(nodeCount) --project=\(projectID) --quiet"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to upgrade the cluster
    public func upgradeCommand(version: String? = nil, nodePool: String? = nil) -> String {
        var cmd = "gcloud container clusters upgrade \(name) --project=\(projectID) --quiet"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        if let version = version {
            cmd += " --cluster-version=\(version)"
        }
        if let nodePool = nodePool {
            cmd += " --node-pool=\(nodePool)"
        } else {
            cmd += " --master"
        }
        return cmd
    }
}

// MARK: - GKE Node Pool

/// Represents a GKE node pool
public struct GoogleCloudGKENodePool: Codable, Sendable, Equatable {
    public let name: String
    public let clusterName: String
    public let projectID: String
    public let location: String
    public let initialNodeCount: Int?
    public let config: GoogleCloudGKECluster.NodeConfig?
    public let autoscaling: Autoscaling?
    public let management: NodeManagement?
    public let upgradeSettings: UpgradeSettings?
    public let locations: [String]?
    public let status: NodePoolStatus?

    public struct Autoscaling: Codable, Sendable, Equatable {
        public let enabled: Bool
        public let minNodeCount: Int?
        public let maxNodeCount: Int?
        public let totalMinNodeCount: Int?
        public let totalMaxNodeCount: Int?
        public let locationPolicy: LocationPolicy?

        public enum LocationPolicy: String, Codable, Sendable, Equatable {
            case balanced = "BALANCED"
            case any = "ANY"
        }

        public init(
            enabled: Bool,
            minNodeCount: Int? = nil,
            maxNodeCount: Int? = nil,
            totalMinNodeCount: Int? = nil,
            totalMaxNodeCount: Int? = nil,
            locationPolicy: LocationPolicy? = nil
        ) {
            self.enabled = enabled
            self.minNodeCount = minNodeCount
            self.maxNodeCount = maxNodeCount
            self.totalMinNodeCount = totalMinNodeCount
            self.totalMaxNodeCount = totalMaxNodeCount
            self.locationPolicy = locationPolicy
        }
    }

    public struct NodeManagement: Codable, Sendable, Equatable {
        public let autoUpgrade: Bool?
        public let autoRepair: Bool?

        public init(autoUpgrade: Bool? = nil, autoRepair: Bool? = nil) {
            self.autoUpgrade = autoUpgrade
            self.autoRepair = autoRepair
        }
    }

    public struct UpgradeSettings: Codable, Sendable, Equatable {
        public let maxSurge: Int?
        public let maxUnavailable: Int?
        public let strategy: Strategy?

        public enum Strategy: String, Codable, Sendable, Equatable {
            case nodePoolUpdateStrategyUnspecified = "NODE_POOL_UPDATE_STRATEGY_UNSPECIFIED"
            case blueGreen = "BLUE_GREEN"
            case surge = "SURGE"
        }

        public init(maxSurge: Int? = nil, maxUnavailable: Int? = nil, strategy: Strategy? = nil) {
            self.maxSurge = maxSurge
            self.maxUnavailable = maxUnavailable
            self.strategy = strategy
        }
    }

    public enum NodePoolStatus: String, Codable, Sendable, Equatable {
        case statusUnspecified = "STATUS_UNSPECIFIED"
        case provisioning = "PROVISIONING"
        case running = "RUNNING"
        case runningWithError = "RUNNING_WITH_ERROR"
        case reconciling = "RECONCILING"
        case stopping = "STOPPING"
        case error = "ERROR"
    }

    public init(
        name: String,
        clusterName: String,
        projectID: String,
        location: String,
        initialNodeCount: Int? = nil,
        config: GoogleCloudGKECluster.NodeConfig? = nil,
        autoscaling: Autoscaling? = nil,
        management: NodeManagement? = nil,
        upgradeSettings: UpgradeSettings? = nil,
        locations: [String]? = nil,
        status: NodePoolStatus? = nil
    ) {
        self.name = name
        self.clusterName = clusterName
        self.projectID = projectID
        self.location = location
        self.initialNodeCount = initialNodeCount
        self.config = config
        self.autoscaling = autoscaling
        self.management = management
        self.upgradeSettings = upgradeSettings
        self.locations = locations
        self.status = status
    }

    /// Whether the cluster is regional (regions like us-central1 vs zones like us-central1-a)
    public var isRegional: Bool {
        let components = location.split(separator: "-")
        guard let lastComponent = components.last else { return true }
        return lastComponent.count != 1 || !lastComponent.first!.isLetter
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/clusters/\(clusterName)/nodePools/\(name)"
    }

    /// Command to create the node pool
    public var createCommand: String {
        var cmd = "gcloud container node-pools create \(name) --cluster=\(clusterName) --project=\(projectID)"

        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }

        if let nodeCount = initialNodeCount {
            cmd += " --num-nodes=\(nodeCount)"
        }

        if let config = config {
            if let machineType = config.machineType {
                cmd += " --machine-type=\(machineType)"
            }
            if let diskSize = config.diskSizeGb {
                cmd += " --disk-size=\(diskSize)"
            }
            if let diskType = config.diskType {
                cmd += " --disk-type=\(diskType.rawValue)"
            }
            if config.preemptible == true {
                cmd += " --preemptible"
            }
            if config.spot == true {
                cmd += " --spot"
            }
        }

        if let autoscaling = autoscaling, autoscaling.enabled {
            cmd += " --enable-autoscaling"
            if let min = autoscaling.minNodeCount {
                cmd += " --min-nodes=\(min)"
            }
            if let max = autoscaling.maxNodeCount {
                cmd += " --max-nodes=\(max)"
            }
        }

        if let management = management {
            if management.autoUpgrade == true {
                cmd += " --enable-autoupgrade"
            } else if management.autoUpgrade == false {
                cmd += " --no-enable-autoupgrade"
            }
            if management.autoRepair == true {
                cmd += " --enable-autorepair"
            } else if management.autoRepair == false {
                cmd += " --no-enable-autorepair"
            }
        }

        return cmd
    }

    /// Command to delete the node pool
    public var deleteCommand: String {
        var cmd = "gcloud container node-pools delete \(name) --cluster=\(clusterName) --project=\(projectID) --quiet"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to describe the node pool
    public var describeCommand: String {
        var cmd = "gcloud container node-pools describe \(name) --cluster=\(clusterName) --project=\(projectID)"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to resize the node pool
    public func resizeCommand(nodeCount: Int) -> String {
        var cmd = "gcloud container clusters resize \(clusterName) --node-pool=\(name) --num-nodes=\(nodeCount) --project=\(projectID) --quiet"
        if isRegional {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }
}

// MARK: - GKE Operations

/// Helper operations for GKE
public struct GKEOperations: Sendable {

    /// Check if a location is a region (vs a zone)
    /// Regions like us-central1 vs zones like us-central1-a
    private static func isRegion(_ location: String) -> Bool {
        let components = location.split(separator: "-")
        guard let lastComponent = components.last else { return true }
        return lastComponent.count != 1 || !lastComponent.first!.isLetter
    }

    /// Command to list clusters
    public static func listClustersCommand(projectID: String, location: String? = nil) -> String {
        var cmd = "gcloud container clusters list --project=\(projectID)"
        if let location = location {
            if isRegion(location) {
                cmd += " --region=\(location)"
            } else {
                cmd += " --zone=\(location)"
            }
        }
        return cmd
    }

    /// Command to list node pools
    public static func listNodePoolsCommand(cluster: String, projectID: String, location: String) -> String {
        var cmd = "gcloud container node-pools list --cluster=\(cluster) --project=\(projectID)"
        if isRegion(location) {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to get server config (available versions)
    public static func getServerConfigCommand(projectID: String, location: String) -> String {
        var cmd = "gcloud container get-server-config --project=\(projectID)"
        if isRegion(location) {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }

    /// Command to enable GKE API
    public static var enableAPICommand: String {
        "gcloud services enable container.googleapis.com"
    }

    /// Command to list operations
    public static func listOperationsCommand(projectID: String, location: String) -> String {
        "gcloud container operations list --project=\(projectID) --location=\(location)"
    }

    /// Command to get kubeconfig entry
    public static func getKubeconfigCommand(cluster: String, projectID: String, location: String) -> String {
        var cmd = "gcloud container clusters get-credentials \(cluster) --project=\(projectID)"
        if isRegion(location) {
            cmd += " --region=\(location)"
        } else {
            cmd += " --zone=\(location)"
        }
        return cmd
    }
}

// MARK: - DAIS GKE Template

/// Production-ready GKE templates for DAIS systems
public struct DAISGKETemplate: Sendable {
    public let projectID: String
    public let location: String
    public let clusterName: String
    public let network: String?
    public let subnetwork: String?

    public init(
        projectID: String,
        location: String = "us-central1",
        clusterName: String = "dais-cluster",
        network: String? = nil,
        subnetwork: String? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.clusterName = clusterName
        self.network = network
        self.subnetwork = subnetwork
    }

    /// Standard GKE cluster for DAIS workloads
    public var standardCluster: GoogleCloudGKECluster {
        GoogleCloudGKECluster(
            name: clusterName,
            projectID: projectID,
            location: location,
            description: "DAIS GKE cluster for distributed AI workloads",
            initialNodeCount: 3,
            nodeConfig: GoogleCloudGKECluster.NodeConfig(
                machineType: "e2-standard-4",
                diskSizeGb: 100,
                diskType: .pdSsd,
                oauthScopes: [
                    "https://www.googleapis.com/auth/cloud-platform"
                ]
            ),
            networkConfig: GoogleCloudGKECluster.NetworkConfig(
                network: network,
                subnetwork: subnetwork,
                datapathProvider: .advancedDatapath
            ),
            addonsConfig: GoogleCloudGKECluster.AddonsConfig(
                httpLoadBalancing: GoogleCloudGKECluster.AddonsConfig.HttpLoadBalancing(disabled: false),
                horizontalPodAutoscaling: GoogleCloudGKECluster.AddonsConfig.HorizontalPodAutoscaling(disabled: false),
                gcePersistentDiskCsiDriverConfig: GoogleCloudGKECluster.AddonsConfig.GcePersistentDiskCsiDriverConfig(enabled: true)
            ),
            releaseChannel: GoogleCloudGKECluster.ReleaseChannel(channel: .regular),
            workloadIdentityConfig: GoogleCloudGKECluster.WorkloadIdentityConfig(
                workloadPool: "\(projectID).svc.id.goog"
            ),
            labels: ["app": "dais", "managed-by": "googlecloudswift"]
        )
    }

    /// Autopilot cluster for hands-off management
    public var autopilotCluster: GoogleCloudGKECluster {
        GoogleCloudGKECluster(
            name: "\(clusterName)-autopilot",
            projectID: projectID,
            location: location,
            description: "DAIS Autopilot GKE cluster",
            networkConfig: GoogleCloudGKECluster.NetworkConfig(
                network: network,
                subnetwork: subnetwork
            ),
            releaseChannel: GoogleCloudGKECluster.ReleaseChannel(channel: .regular),
            autopilot: GoogleCloudGKECluster.Autopilot(enabled: true),
            workloadIdentityConfig: GoogleCloudGKECluster.WorkloadIdentityConfig(
                workloadPool: "\(projectID).svc.id.goog"
            ),
            labels: ["app": "dais", "type": "autopilot"]
        )
    }

    /// Private cluster for enhanced security
    public var privateCluster: GoogleCloudGKECluster {
        GoogleCloudGKECluster(
            name: "\(clusterName)-private",
            projectID: projectID,
            location: location,
            description: "DAIS private GKE cluster",
            initialNodeCount: 3,
            nodeConfig: GoogleCloudGKECluster.NodeConfig(
                machineType: "e2-standard-4",
                diskSizeGb: 100,
                diskType: .pdSsd
            ),
            networkConfig: GoogleCloudGKECluster.NetworkConfig(
                network: network,
                subnetwork: subnetwork
            ),
            releaseChannel: GoogleCloudGKECluster.ReleaseChannel(channel: .stable),
            privateClusterConfig: GoogleCloudGKECluster.PrivateClusterConfig(
                enablePrivateNodes: true,
                enablePrivateEndpoint: false,
                masterIpv4CidrBlock: "172.16.0.0/28",
                masterGlobalAccessConfig: GoogleCloudGKECluster.PrivateClusterConfig.MasterGlobalAccessConfig(enabled: true)
            ),
            workloadIdentityConfig: GoogleCloudGKECluster.WorkloadIdentityConfig(
                workloadPool: "\(projectID).svc.id.goog"
            ),
            labels: ["app": "dais", "type": "private"]
        )
    }

    /// GPU node pool for ML workloads
    public var gpuNodePool: GoogleCloudGKENodePool {
        GoogleCloudGKENodePool(
            name: "gpu-pool",
            clusterName: clusterName,
            projectID: projectID,
            location: location,
            initialNodeCount: 1,
            config: GoogleCloudGKECluster.NodeConfig(
                machineType: "n1-standard-4",
                diskSizeGb: 100,
                diskType: .pdSsd,
                taints: [
                    GoogleCloudGKECluster.NodeConfig.Taint(
                        key: "nvidia.com/gpu",
                        value: "present",
                        effect: .noSchedule
                    )
                ],
                accelerators: [
                    GoogleCloudGKECluster.NodeConfig.Accelerator(
                        acceleratorCount: 1,
                        acceleratorType: "nvidia-tesla-t4"
                    )
                ]
            ),
            autoscaling: GoogleCloudGKENodePool.Autoscaling(
                enabled: true,
                minNodeCount: 0,
                maxNodeCount: 5
            ),
            management: GoogleCloudGKENodePool.NodeManagement(
                autoUpgrade: true,
                autoRepair: true
            )
        )
    }

    /// Spot/preemptible node pool for cost savings
    public var spotNodePool: GoogleCloudGKENodePool {
        GoogleCloudGKENodePool(
            name: "spot-pool",
            clusterName: clusterName,
            projectID: projectID,
            location: location,
            initialNodeCount: 0,
            config: GoogleCloudGKECluster.NodeConfig(
                machineType: "e2-standard-4",
                diskSizeGb: 50,
                diskType: .pdBalanced,
                spot: true,
                labels: ["workload-type": "batch"]
            ),
            autoscaling: GoogleCloudGKENodePool.Autoscaling(
                enabled: true,
                minNodeCount: 0,
                maxNodeCount: 10
            ),
            management: GoogleCloudGKENodePool.NodeManagement(
                autoUpgrade: true,
                autoRepair: true
            )
        )
    }

    /// Setup script to deploy DAIS GKE infrastructure
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        CLUSTER_NAME="\(clusterName)"

        echo "Enabling GKE API..."
        gcloud services enable container.googleapis.com --project=$PROJECT_ID

        echo "Creating DAIS GKE cluster..."
        \(standardCluster.createCommand)

        echo "Waiting for cluster to be ready..."
        gcloud container clusters describe $CLUSTER_NAME --region=$LOCATION --project=$PROJECT_ID --format='value(status)'

        echo "Getting cluster credentials..."
        \(standardCluster.getCredentialsCommand)

        echo "Creating spot node pool for batch workloads..."
        \(spotNodePool.createCommand)

        echo ""
        echo "DAIS GKE setup complete!"
        echo ""
        echo "Cluster endpoint:"
        gcloud container clusters describe $CLUSTER_NAME --region=$LOCATION --project=$PROJECT_ID --format='value(endpoint)'
        echo ""
        echo "To connect to the cluster:"
        echo "  \(standardCluster.getCredentialsCommand)"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        CLUSTER_NAME="\(clusterName)"

        echo "Deleting DAIS GKE cluster..."
        \(standardCluster.deleteCommand)

        echo "GKE teardown complete!"
        """
    }
}
