// GoogleCloudNetworkIntelligence.swift
// Network Intelligence Center - Network monitoring and diagnostics
// Service #55

import Foundation

// MARK: - Connectivity Test

/// A connectivity test for network path analysis
public struct GoogleCloudConnectivityTest: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let source: Endpoint
    public let destination: Endpoint
    public let networkProtocol: NetworkProtocol?
    public let relatedProjects: [String]?
    public let labels: [String: String]?
    public let createTime: String?
    public let updateTime: String?
    public let reachabilityDetails: ReachabilityDetails?

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        source: Endpoint,
        destination: Endpoint,
        networkProtocol: NetworkProtocol? = nil,
        relatedProjects: [String]? = nil,
        labels: [String: String]? = nil,
        createTime: String? = nil,
        updateTime: String? = nil,
        reachabilityDetails: ReachabilityDetails? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.source = source
        self.destination = destination
        self.networkProtocol = networkProtocol
        self.relatedProjects = relatedProjects
        self.labels = labels
        self.createTime = createTime
        self.updateTime = updateTime
        self.reachabilityDetails = reachabilityDetails
    }

    /// Network protocol
    public enum NetworkProtocol: String, Codable, Sendable {
        case protocolUnspecified = "PROTOCOL_UNSPECIFIED"
        case tcp = "TCP"
        case udp = "UDP"
        case icmp = "ICMP"
        case gre = "GRE"
        case esp = "ESP"
    }

    /// Reachability details
    public struct ReachabilityDetails: Codable, Sendable, Equatable {
        public let result: Result?
        public let verifyTime: String?
        public let error: StatusMessage?
        public let traces: [Trace]?

        public init(
            result: Result? = nil,
            verifyTime: String? = nil,
            error: StatusMessage? = nil,
            traces: [Trace]? = nil
        ) {
            self.result = result
            self.verifyTime = verifyTime
            self.error = error
            self.traces = traces
        }

        public enum Result: String, Codable, Sendable {
            case resultUnspecified = "RESULT_UNSPECIFIED"
            case reachable = "REACHABLE"
            case unreachable = "UNREACHABLE"
            case ambiguous = "AMBIGUOUS"
            case undetermined = "UNDETERMINED"
        }

        public struct StatusMessage: Codable, Sendable, Equatable {
            public let code: Int?
            public let message: String?

            public init(code: Int? = nil, message: String? = nil) {
                self.code = code
                self.message = message
            }
        }
    }

    /// Network trace
    public struct Trace: Codable, Sendable, Equatable {
        public let endpointInfo: EndpointInfo?
        public let steps: [Step]?

        public init(endpointInfo: EndpointInfo? = nil, steps: [Step]? = nil) {
            self.endpointInfo = endpointInfo
            self.steps = steps
        }

        public struct EndpointInfo: Codable, Sendable, Equatable {
            public let sourceIp: String?
            public let destinationIp: String?
            public let sourcePort: Int?
            public let destinationPort: Int?
            public let sourceNetworkUri: String?
            public let destinationNetworkUri: String?

            public init(
                sourceIp: String? = nil,
                destinationIp: String? = nil,
                sourcePort: Int? = nil,
                destinationPort: Int? = nil,
                sourceNetworkUri: String? = nil,
                destinationNetworkUri: String? = nil
            ) {
                self.sourceIp = sourceIp
                self.destinationIp = destinationIp
                self.sourcePort = sourcePort
                self.destinationPort = destinationPort
                self.sourceNetworkUri = sourceNetworkUri
                self.destinationNetworkUri = destinationNetworkUri
            }
        }

        public struct Step: Codable, Sendable, Equatable {
            public let description: String?
            public let state: State?
            public let causeDrop: Bool?
            public let causeAbort: Bool?
            public let projectId: String?
            public let instance: InstanceInfo?
            public let firewall: FirewallInfo?
            public let route: RouteInfo?
            public let endpoint: EndpointInfo?
            public let forwardingRule: ForwardingRuleInfo?
            public let vpnGateway: VpnGatewayInfo?
            public let vpnTunnel: VpnTunnelInfo?
            public let cloudSqlInstance: CloudSqlInstanceInfo?
            public let gkeMaster: GkeMasterInfo?
            public let cloudFunction: CloudFunctionInfo?
            public let cloudRunRevision: CloudRunRevisionInfo?

            public init(
                description: String? = nil,
                state: State? = nil,
                causeDrop: Bool? = nil,
                causeAbort: Bool? = nil,
                projectId: String? = nil,
                instance: InstanceInfo? = nil,
                firewall: FirewallInfo? = nil,
                route: RouteInfo? = nil,
                endpoint: EndpointInfo? = nil,
                forwardingRule: ForwardingRuleInfo? = nil,
                vpnGateway: VpnGatewayInfo? = nil,
                vpnTunnel: VpnTunnelInfo? = nil,
                cloudSqlInstance: CloudSqlInstanceInfo? = nil,
                gkeMaster: GkeMasterInfo? = nil,
                cloudFunction: CloudFunctionInfo? = nil,
                cloudRunRevision: CloudRunRevisionInfo? = nil
            ) {
                self.description = description
                self.state = state
                self.causeDrop = causeDrop
                self.causeAbort = causeAbort
                self.projectId = projectId
                self.instance = instance
                self.firewall = firewall
                self.route = route
                self.endpoint = endpoint
                self.forwardingRule = forwardingRule
                self.vpnGateway = vpnGateway
                self.vpnTunnel = vpnTunnel
                self.cloudSqlInstance = cloudSqlInstance
                self.gkeMaster = gkeMaster
                self.cloudFunction = cloudFunction
                self.cloudRunRevision = cloudRunRevision
            }

            public enum State: String, Codable, Sendable {
                case stateUnspecified = "STATE_UNSPECIFIED"
                case startFromInstance = "START_FROM_INSTANCE"
                case startFromInternet = "START_FROM_INTERNET"
                case startFromPrivateNetwork = "START_FROM_PRIVATE_NETWORK"
                case startFromGkeMaster = "START_FROM_GKE_MASTER"
                case startFromCloudSqlInstance = "START_FROM_CLOUD_SQL_INSTANCE"
                case startFromCloudFunction = "START_FROM_CLOUD_FUNCTION"
                case startFromCloudRunRevision = "START_FROM_CLOUD_RUN_REVISION"
                case applyIngressFirewallRule = "APPLY_INGRESS_FIREWALL_RULE"
                case applyEgressFirewallRule = "APPLY_EGRESS_FIREWALL_RULE"
                case applyRoute = "APPLY_ROUTE"
                case applyForwardingRule = "APPLY_FORWARDING_RULE"
                case spoofingApproved = "SPOOFING_APPROVED"
                case arriveAtInstance = "ARRIVE_AT_INSTANCE"
                case arriveAtInternalLoadBalancer = "ARRIVE_AT_INTERNAL_LOAD_BALANCER"
                case arriveAtExternalLoadBalancer = "ARRIVE_AT_EXTERNAL_LOAD_BALANCER"
                case arriveAtVpnGateway = "ARRIVE_AT_VPN_GATEWAY"
                case arriveAtVpnTunnel = "ARRIVE_AT_VPN_TUNNEL"
                case arriveAtVpcConnector = "ARRIVE_AT_VPC_CONNECTOR"
                case nat = "NAT"
                case proxyConnection = "PROXY_CONNECTION"
                case deliver = "DELIVER"
                case drop = "DROP"
                case forward = "FORWARD"
                case abort = "ABORT"
                case viewerPermissionMissing = "VIEWER_PERMISSION_MISSING"
            }
        }

        public struct InstanceInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let interface: String?
            public let networkUri: String?
            public let internalIp: String?
            public let externalIp: String?
            public let networkTags: [String]?
            public let serviceAccount: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                interface: String? = nil,
                networkUri: String? = nil,
                internalIp: String? = nil,
                externalIp: String? = nil,
                networkTags: [String]? = nil,
                serviceAccount: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.interface = interface
                self.networkUri = networkUri
                self.internalIp = internalIp
                self.externalIp = externalIp
                self.networkTags = networkTags
                self.serviceAccount = serviceAccount
            }
        }

        public struct FirewallInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let direction: String?
            public let action: String?
            public let priority: Int?
            public let networkUri: String?
            public let targetTags: [String]?
            public let targetServiceAccounts: [String]?
            public let policy: String?
            public let firewallRuleType: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                direction: String? = nil,
                action: String? = nil,
                priority: Int? = nil,
                networkUri: String? = nil,
                targetTags: [String]? = nil,
                targetServiceAccounts: [String]? = nil,
                policy: String? = nil,
                firewallRuleType: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.direction = direction
                self.action = action
                self.priority = priority
                self.networkUri = networkUri
                self.targetTags = targetTags
                self.targetServiceAccounts = targetServiceAccounts
                self.policy = policy
                self.firewallRuleType = firewallRuleType
            }
        }

        public struct RouteInfo: Codable, Sendable, Equatable {
            public let routeType: String?
            public let nextHopType: String?
            public let displayName: String?
            public let uri: String?
            public let destIpRange: String?
            public let nextHop: String?
            public let networkUri: String?
            public let priority: Int?
            public let instanceTags: [String]?

            public init(
                routeType: String? = nil,
                nextHopType: String? = nil,
                displayName: String? = nil,
                uri: String? = nil,
                destIpRange: String? = nil,
                nextHop: String? = nil,
                networkUri: String? = nil,
                priority: Int? = nil,
                instanceTags: [String]? = nil
            ) {
                self.routeType = routeType
                self.nextHopType = nextHopType
                self.displayName = displayName
                self.uri = uri
                self.destIpRange = destIpRange
                self.nextHop = nextHop
                self.networkUri = networkUri
                self.priority = priority
                self.instanceTags = instanceTags
            }
        }

        public struct ForwardingRuleInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let matchedProtocol: String?
            public let matchedPortRange: String?
            public let vip: String?
            public let target: String?
            public let networkUri: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                matchedProtocol: String? = nil,
                matchedPortRange: String? = nil,
                vip: String? = nil,
                target: String? = nil,
                networkUri: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.matchedProtocol = matchedProtocol
                self.matchedPortRange = matchedPortRange
                self.vip = vip
                self.target = target
                self.networkUri = networkUri
            }
        }

        public struct VpnGatewayInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let networkUri: String?
            public let ipAddress: String?
            public let vpnTunnelUri: String?
            public let region: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                networkUri: String? = nil,
                ipAddress: String? = nil,
                vpnTunnelUri: String? = nil,
                region: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.networkUri = networkUri
                self.ipAddress = ipAddress
                self.vpnTunnelUri = vpnTunnelUri
                self.region = region
            }
        }

        public struct VpnTunnelInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let sourceGateway: String?
            public let remoteGateway: String?
            public let remoteGatewayIp: String?
            public let sourceGatewayIp: String?
            public let networkUri: String?
            public let region: String?
            public let routingType: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                sourceGateway: String? = nil,
                remoteGateway: String? = nil,
                remoteGatewayIp: String? = nil,
                sourceGatewayIp: String? = nil,
                networkUri: String? = nil,
                region: String? = nil,
                routingType: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.sourceGateway = sourceGateway
                self.remoteGateway = remoteGateway
                self.remoteGatewayIp = remoteGatewayIp
                self.sourceGatewayIp = sourceGatewayIp
                self.networkUri = networkUri
                self.region = region
                self.routingType = routingType
            }
        }

        public struct CloudSqlInstanceInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let networkUri: String?
            public let internalIp: String?
            public let externalIp: String?
            public let region: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                networkUri: String? = nil,
                internalIp: String? = nil,
                externalIp: String? = nil,
                region: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.networkUri = networkUri
                self.internalIp = internalIp
                self.externalIp = externalIp
                self.region = region
            }
        }

        public struct GkeMasterInfo: Codable, Sendable, Equatable {
            public let clusterUri: String?
            public let clusterNetworkUri: String?
            public let internalIp: String?
            public let externalIp: String?

            public init(
                clusterUri: String? = nil,
                clusterNetworkUri: String? = nil,
                internalIp: String? = nil,
                externalIp: String? = nil
            ) {
                self.clusterUri = clusterUri
                self.clusterNetworkUri = clusterNetworkUri
                self.internalIp = internalIp
                self.externalIp = externalIp
            }
        }

        public struct CloudFunctionInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let location: String?
            public let versionId: Int64?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                location: String? = nil,
                versionId: Int64? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.location = location
                self.versionId = versionId
            }
        }

        public struct CloudRunRevisionInfo: Codable, Sendable, Equatable {
            public let displayName: String?
            public let uri: String?
            public let location: String?
            public let serviceUri: String?

            public init(
                displayName: String? = nil,
                uri: String? = nil,
                location: String? = nil,
                serviceUri: String? = nil
            ) {
                self.displayName = displayName
                self.uri = uri
                self.location = location
                self.serviceUri = serviceUri
            }
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/global/connectivityTests/\(name)"
    }

    /// Create connectivity test command
    public var createCommand: String {
        var cmd = "gcloud network-management connectivity-tests create \(name) --project=\(projectID)"
        cmd += " --source-\(source.typeString)=\(source.resourceUri ?? source.ipAddress ?? "")"
        cmd += " --destination-\(destination.typeString)=\(destination.resourceUri ?? destination.ipAddress ?? "")"
        if let proto = self.networkProtocol {
            cmd += " --protocol=\(proto.rawValue)"
        }
        if let port = destination.port {
            cmd += " --destination-port=\(port)"
        }
        return cmd
    }

    /// Delete connectivity test command
    public var deleteCommand: String {
        "gcloud network-management connectivity-tests delete \(name) --project=\(projectID)"
    }

    /// Describe connectivity test command
    public var describeCommand: String {
        "gcloud network-management connectivity-tests describe \(name) --project=\(projectID)"
    }

    /// Rerun connectivity test command
    public var rerunCommand: String {
        "gcloud network-management connectivity-tests rerun \(name) --project=\(projectID)"
    }
}

// MARK: - Endpoint

/// An endpoint for connectivity testing
public struct Endpoint: Codable, Sendable, Equatable {
    public let ipAddress: String?
    public let port: Int?
    public let instance: String?
    public let gkeMasterCluster: String?
    public let cloudSqlInstance: String?
    public let cloudFunction: CloudFunctionEndpoint?
    public let cloudRunRevision: CloudRunRevisionEndpoint?
    public let network: String?
    public let networkType: NetworkType?
    public let projectId: String?

    public init(
        ipAddress: String? = nil,
        port: Int? = nil,
        instance: String? = nil,
        gkeMasterCluster: String? = nil,
        cloudSqlInstance: String? = nil,
        cloudFunction: CloudFunctionEndpoint? = nil,
        cloudRunRevision: CloudRunRevisionEndpoint? = nil,
        network: String? = nil,
        networkType: NetworkType? = nil,
        projectId: String? = nil
    ) {
        self.ipAddress = ipAddress
        self.port = port
        self.instance = instance
        self.gkeMasterCluster = gkeMasterCluster
        self.cloudSqlInstance = cloudSqlInstance
        self.cloudFunction = cloudFunction
        self.cloudRunRevision = cloudRunRevision
        self.network = network
        self.networkType = networkType
        self.projectId = projectId
    }

    /// Network type
    public enum NetworkType: String, Codable, Sendable {
        case networkTypeUnspecified = "NETWORK_TYPE_UNSPECIFIED"
        case gcpNetwork = "GCP_NETWORK"
        case nonGcpNetwork = "NON_GCP_NETWORK"
    }

    /// Cloud Function endpoint
    public struct CloudFunctionEndpoint: Codable, Sendable, Equatable {
        public let uri: String

        public init(uri: String) {
            self.uri = uri
        }
    }

    /// Cloud Run revision endpoint
    public struct CloudRunRevisionEndpoint: Codable, Sendable, Equatable {
        public let uri: String

        public init(uri: String) {
            self.uri = uri
        }
    }

    /// Create an instance endpoint
    public static func instance(_ uri: String, network: String? = nil) -> Endpoint {
        Endpoint(instance: uri, network: network)
    }

    /// Create an IP address endpoint
    public static func ip(_ address: String, port: Int? = nil, network: String? = nil) -> Endpoint {
        Endpoint(ipAddress: address, port: port, network: network)
    }

    /// Create a GKE master endpoint
    public static func gkeMaster(_ clusterUri: String) -> Endpoint {
        Endpoint(gkeMasterCluster: clusterUri)
    }

    /// Create a Cloud SQL endpoint
    public static func cloudSql(_ instanceUri: String) -> Endpoint {
        Endpoint(cloudSqlInstance: instanceUri)
    }

    /// Create a Cloud Function endpoint
    public static func cloudFunction(uri: String) -> Endpoint {
        Endpoint(cloudFunction: CloudFunctionEndpoint(uri: uri))
    }

    /// Create a Cloud Run endpoint
    public static func cloudRun(uri: String) -> Endpoint {
        Endpoint(cloudRunRevision: CloudRunRevisionEndpoint(uri: uri))
    }

    /// Resource URI for the endpoint
    public var resourceUri: String? {
        instance ?? gkeMasterCluster ?? cloudSqlInstance ?? cloudFunction?.uri ?? cloudRunRevision?.uri
    }

    /// Type string for gcloud command
    public var typeString: String {
        if instance != nil { return "instance" }
        if gkeMasterCluster != nil { return "gke-master-cluster" }
        if cloudSqlInstance != nil { return "cloud-sql-instance" }
        if cloudFunction != nil { return "cloud-function" }
        if cloudRunRevision != nil { return "cloud-run-revision" }
        return "ip-address"
    }
}

// MARK: - Network Topology

/// Network topology representation
public struct GoogleCloudNetworkTopology: Codable, Sendable, Equatable {
    public let projectID: String
    public let resources: [TopologyResource]?
    public let locations: [String]?

    public init(
        projectID: String,
        resources: [TopologyResource]? = nil,
        locations: [String]? = nil
    ) {
        self.projectID = projectID
        self.resources = resources
        self.locations = locations
    }

    /// Topology resource
    public struct TopologyResource: Codable, Sendable, Equatable {
        public let name: String
        public let resourceType: ResourceType
        public let location: String?
        public let connections: [Connection]?

        public init(
            name: String,
            resourceType: ResourceType,
            location: String? = nil,
            connections: [Connection]? = nil
        ) {
            self.name = name
            self.resourceType = resourceType
            self.location = location
            self.connections = connections
        }

        public enum ResourceType: String, Codable, Sendable {
            case resourceTypeUnspecified = "RESOURCE_TYPE_UNSPECIFIED"
            case network = "NETWORK"
            case subnetwork = "SUBNETWORK"
            case instance = "INSTANCE"
            case router = "ROUTER"
            case vpnGateway = "VPN_GATEWAY"
            case vpnTunnel = "VPN_TUNNEL"
            case interconnectAttachment = "INTERCONNECT_ATTACHMENT"
            case loadBalancer = "LOAD_BALANCER"
            case nat = "NAT"
        }

        public struct Connection: Codable, Sendable, Equatable {
            public let targetResource: String
            public let connectionType: String?

            public init(targetResource: String, connectionType: String? = nil) {
                self.targetResource = targetResource
                self.connectionType = connectionType
            }
        }
    }
}

// MARK: - Performance Dashboard

/// Network performance monitoring configuration
public struct GoogleCloudNetworkPerformanceConfig: Codable, Sendable, Equatable {
    public let projectID: String
    public let enabledFeatures: [Feature]?
    public let samplePeriod: String?

    public init(
        projectID: String,
        enabledFeatures: [Feature]? = nil,
        samplePeriod: String? = nil
    ) {
        self.projectID = projectID
        self.enabledFeatures = enabledFeatures
        self.samplePeriod = samplePeriod
    }

    /// Network performance feature
    public enum Feature: String, Codable, Sendable {
        case latencyMonitoring = "LATENCY_MONITORING"
        case packetLoss = "PACKET_LOSS"
        case bandwidth = "BANDWIDTH"
        case jitter = "JITTER"
    }
}

// MARK: - Firewall Insights

/// Firewall insights and recommendations
public struct GoogleCloudFirewallInsight: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let insightType: InsightType
    public let severity: Severity?
    public let firewallRules: [FirewallRuleReference]?
    public let recommendation: String?
    public let description: String?
    public let lastRefreshTime: String?

    public init(
        name: String,
        projectID: String,
        insightType: InsightType,
        severity: Severity? = nil,
        firewallRules: [FirewallRuleReference]? = nil,
        recommendation: String? = nil,
        description: String? = nil,
        lastRefreshTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.insightType = insightType
        self.severity = severity
        self.firewallRules = firewallRules
        self.recommendation = recommendation
        self.description = description
        self.lastRefreshTime = lastRefreshTime
    }

    /// Insight type
    public enum InsightType: String, Codable, Sendable {
        case insightTypeUnspecified = "INSIGHT_TYPE_UNSPECIFIED"
        case shadowedRule = "SHADOWED_RULE"
        case overlyShadowed = "OVERLY_SHADOWED"
        case redundantRule = "REDUNDANT_RULE"
        case tooPermissive = "TOO_PERMISSIVE"
        case unusedRule = "UNUSED_RULE"
    }

    /// Severity level
    public enum Severity: String, Codable, Sendable {
        case severityUnspecified = "SEVERITY_UNSPECIFIED"
        case low = "LOW"
        case medium = "MEDIUM"
        case high = "HIGH"
        case critical = "CRITICAL"
    }

    /// Firewall rule reference
    public struct FirewallRuleReference: Codable, Sendable, Equatable {
        public let firewallRuleName: String
        public let firewallRuleUri: String?
        public let network: String?

        public init(
            firewallRuleName: String,
            firewallRuleUri: String? = nil,
            network: String? = nil
        ) {
            self.firewallRuleName = firewallRuleName
            self.firewallRuleUri = firewallRuleUri
            self.network = network
        }
    }
}

// MARK: - Network Intelligence Operations

/// Operations for Network Intelligence Center
public struct NetworkIntelligenceOperations: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Enable Network Intelligence Center API
    public var enableAPICommand: String {
        "gcloud services enable networkmanagement.googleapis.com --project=\(projectID)"
    }

    /// Enable Recommender API for insights
    public var enableRecommenderAPICommand: String {
        "gcloud services enable recommender.googleapis.com --project=\(projectID)"
    }

    /// List connectivity tests
    public var listTestsCommand: String {
        "gcloud network-management connectivity-tests list --project=\(projectID)"
    }

    /// Create connectivity test between VMs
    public func createVMToVMTestCommand(
        name: String,
        sourceInstance: String,
        sourceNetwork: String,
        destinationInstance: String,
        destinationNetwork: String,
        networkProtocol: GoogleCloudConnectivityTest.NetworkProtocol = .tcp,
        port: Int = 80
    ) -> String {
        """
        gcloud network-management connectivity-tests create \(name) \\
            --project=\(projectID) \\
            --source-instance=\(sourceInstance) \\
            --source-network=\(sourceNetwork) \\
            --destination-instance=\(destinationInstance) \\
            --destination-network=\(destinationNetwork) \\
            --protocol=\(networkProtocol.rawValue) \\
            --destination-port=\(port)
        """
    }

    /// Create connectivity test to external IP
    public func createExternalIPTestCommand(
        name: String,
        sourceInstance: String,
        sourceNetwork: String,
        destinationIP: String,
        port: Int = 443
    ) -> String {
        """
        gcloud network-management connectivity-tests create \(name) \\
            --project=\(projectID) \\
            --source-instance=\(sourceInstance) \\
            --source-network=\(sourceNetwork) \\
            --destination-ip-address=\(destinationIP) \\
            --protocol=TCP \\
            --destination-port=\(port)
        """
    }

    /// List firewall insights
    public var listFirewallInsightsCommand: String {
        "gcloud recommender insights list --project=\(projectID) --location=global --insight-type=google.compute.firewall.Insight"
    }

    /// Describe firewall insight
    public func describeFirewallInsightCommand(insightName: String) -> String {
        "gcloud recommender insights describe \(insightName) --project=\(projectID) --location=global --insight-type=google.compute.firewall.Insight"
    }

    /// List network topology
    public var networkTopologyCommand: String {
        "gcloud compute networks list --project=\(projectID) --format='table(name,x_gcloud_subnet_mode,x_gcloud_bgp_routing_mode)'"
    }

    /// Show routes
    public var listRoutesCommand: String {
        "gcloud compute routes list --project=\(projectID)"
    }

    /// IAM roles for Network Intelligence
    public enum NetworkIntelligenceRole: String, Sendable {
        case networkManagementAdmin = "roles/networkmanagement.admin"
        case networkManagementViewer = "roles/networkmanagement.viewer"
        case computeNetworkViewer = "roles/compute.networkViewer"
    }

    /// Add IAM binding
    public func addIAMBindingCommand(member: String, role: NetworkIntelligenceRole) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=\(role.rawValue)"
    }
}

// MARK: - DAIS Network Intelligence Template

/// DAIS template for Network Intelligence configurations
public struct DAISNetworkIntelligenceTemplate: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Create a VM to VM connectivity test
    public func vmToVMTest(
        name: String,
        sourceInstance: String,
        destinationInstance: String,
        port: Int = 80
    ) -> GoogleCloudConnectivityTest {
        GoogleCloudConnectivityTest(
            name: name,
            projectID: projectID,
            description: "Test connectivity from \(sourceInstance) to \(destinationInstance)",
            source: .instance(sourceInstance),
            destination: .instance(destinationInstance),
            networkProtocol: .tcp
        )
    }

    /// Create a VM to internet connectivity test
    public func vmToInternetTest(
        name: String,
        sourceInstance: String,
        destinationIP: String,
        port: Int = 443
    ) -> GoogleCloudConnectivityTest {
        GoogleCloudConnectivityTest(
            name: name,
            projectID: projectID,
            description: "Test connectivity from \(sourceInstance) to \(destinationIP)",
            source: .instance(sourceInstance),
            destination: .ip(destinationIP, port: port),
            networkProtocol: .tcp
        )
    }

    /// Create a GKE connectivity test
    public func gkeConnectivityTest(
        name: String,
        clusterUri: String,
        destinationIP: String,
        port: Int = 443
    ) -> GoogleCloudConnectivityTest {
        GoogleCloudConnectivityTest(
            name: name,
            projectID: projectID,
            description: "Test GKE cluster connectivity to \(destinationIP)",
            source: .gkeMaster(clusterUri),
            destination: .ip(destinationIP, port: port),
            networkProtocol: .tcp
        )
    }

    /// Create a Cloud SQL connectivity test
    public func cloudSqlConnectivityTest(
        name: String,
        sourceInstance: String,
        sqlInstanceUri: String,
        port: Int = 5432
    ) -> GoogleCloudConnectivityTest {
        GoogleCloudConnectivityTest(
            name: name,
            projectID: projectID,
            description: "Test connectivity to Cloud SQL",
            source: .instance(sourceInstance),
            destination: .cloudSql(sqlInstanceUri),
            networkProtocol: .tcp
        )
    }

    /// Operations helper
    public var operations: NetworkIntelligenceOperations {
        NetworkIntelligenceOperations(projectID: projectID)
    }

    /// Generate connectivity testing script
    public var connectivityTestingScript: String {
        """
        #!/bin/bash
        # Network Connectivity Testing Script
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"

        echo "=== Enabling APIs ==="
        gcloud services enable networkmanagement.googleapis.com --project=$PROJECT
        gcloud services enable recommender.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Listing Existing Connectivity Tests ==="
        gcloud network-management connectivity-tests list --project=$PROJECT

        echo ""
        echo "=== Creating Sample Connectivity Test ==="
        # Uncomment and customize:
        # gcloud network-management connectivity-tests create sample-test \\
        #     --project=$PROJECT \\
        #     --source-instance=projects/$PROJECT/zones/us-central1-a/instances/source-vm \\
        #     --source-network=projects/$PROJECT/global/networks/default \\
        #     --destination-ip-address=8.8.8.8 \\
        #     --protocol=TCP \\
        #     --destination-port=443

        echo ""
        echo "=== Firewall Insights ==="
        gcloud recommender insights list \\
            --project=$PROJECT \\
            --location=global \\
            --insight-type=google.compute.firewall.Insight \\
            --format='table(name,insightSubtype,severity,stateInfo.state)' || true

        echo ""
        echo "=== Network Topology ==="
        echo "Networks:"
        gcloud compute networks list --project=$PROJECT
        echo ""
        echo "Subnets:"
        gcloud compute networks subnets list --project=$PROJECT
        echo ""
        echo "Routes:"
        gcloud compute routes list --project=$PROJECT --limit=10

        echo ""
        echo "=== Script Complete ==="
        """
    }

    /// Generate firewall analysis script
    public var firewallAnalysisScript: String {
        """
        #!/bin/bash
        # Firewall Analysis Script
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"

        echo "=== Firewall Rules ==="
        gcloud compute firewall-rules list --project=$PROJECT \\
            --format='table(name,network,direction,priority,allowed[].map().firewall_rule().flat().list():label=ALLOW,denied[].map().firewall_rule().flat().list():label=DENY,sourceRanges.list():label=SRC_RANGES,targetTags.list():label=TARGET_TAGS)'

        echo ""
        echo "=== Firewall Insights ==="
        gcloud recommender insights list \\
            --project=$PROJECT \\
            --location=global \\
            --insight-type=google.compute.firewall.Insight \\
            --format='yaml'

        echo ""
        echo "=== Recommendations ==="
        gcloud recommender recommendations list \\
            --project=$PROJECT \\
            --location=global \\
            --recommender=google.compute.firewall.Recommender \\
            --format='yaml' || echo "No recommendations available"
        """
    }
}
