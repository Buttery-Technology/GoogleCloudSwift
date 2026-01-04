//
//  GoogleCloudVPC.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

// MARK: - VPC Network

/// Represents a VPC network in Google Cloud.
///
/// VPC networks provide networking functionality for Compute Engine,
/// GKE, and other Google Cloud services.
///
/// ## Example Usage
/// ```swift
/// let network = GoogleCloudVPCNetwork(
///     name: "my-vpc",
///     projectID: "my-project",
///     autoCreateSubnetworks: false,
///     routingMode: .global
/// )
/// print(network.createCommand)
/// ```
public struct GoogleCloudVPCNetwork: Codable, Sendable, Equatable {
    /// Name of the VPC network
    public let name: String

    /// Project ID
    public let projectID: String

    /// Auto-create subnets in each region
    public let autoCreateSubnetworks: Bool

    /// Routing mode for the network
    public let routingMode: RoutingMode

    /// Description of the network
    public let description: String?

    /// Maximum Transmission Unit (MTU)
    public let mtu: Int?

    public init(
        name: String,
        projectID: String,
        autoCreateSubnetworks: Bool = false,
        routingMode: RoutingMode = .regional,
        description: String? = nil,
        mtu: Int? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.autoCreateSubnetworks = autoCreateSubnetworks
        self.routingMode = routingMode
        self.description = description
        self.mtu = mtu
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/networks/\(name)"
    }

    /// Self-link URL
    public var selfLink: String {
        "https://www.googleapis.com/compute/v1/\(resourceName)"
    }

    /// gcloud command to create this network
    public var createCommand: String {
        var cmd = "gcloud compute networks create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --subnet-mode=\(autoCreateSubnetworks ? "auto" : "custom")"
        cmd += " --bgp-routing-mode=\(routingMode.rawValue)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let mtu = mtu {
            cmd += " --mtu=\(mtu)"
        }
        return cmd
    }

    /// gcloud command to delete this network
    public var deleteCommand: String {
        "gcloud compute networks delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this network
    public var describeCommand: String {
        "gcloud compute networks describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list networks
    public static func listCommand(projectID: String) -> String {
        "gcloud compute networks list --project=\(projectID)"
    }

    /// gcloud command to update the network
    public var updateCommand: String {
        "gcloud compute networks update \(name) --project=\(projectID) --bgp-routing-mode=\(routingMode.rawValue)"
    }

    /// gcloud command to list subnets in this network
    public var listSubnetsCommand: String {
        "gcloud compute networks subnets list --network=\(name) --project=\(projectID)"
    }

    /// Routing mode for the VPC
    public enum RoutingMode: String, Codable, Sendable {
        /// Regional routing (default)
        case regional = "regional"
        /// Global routing
        case global = "global"
    }
}

// MARK: - Subnet

/// Represents a subnet in a VPC network.
///
/// Subnets are regional resources that define IP address ranges
/// for VM instances and other resources.
///
/// ## Example Usage
/// ```swift
/// let subnet = GoogleCloudSubnet(
///     name: "my-subnet",
///     networkName: "my-vpc",
///     projectID: "my-project",
///     region: "us-central1",
///     ipCidrRange: "10.0.0.0/24"
/// )
/// print(subnet.createCommand)
/// ```
public struct GoogleCloudSubnet: Codable, Sendable, Equatable {
    /// Name of the subnet
    public let name: String

    /// Name of the parent network
    public let networkName: String

    /// Project ID
    public let projectID: String

    /// Region for the subnet
    public let region: String

    /// Primary IP CIDR range
    public let ipCidrRange: String

    /// Description of the subnet
    public let description: String?

    /// Enable private Google access
    public let privateIpGoogleAccess: Bool

    /// Enable flow logs
    public let enableFlowLogs: Bool

    /// Flow log aggregation interval
    public let flowLogAggregationInterval: FlowLogInterval?

    /// Secondary IP ranges
    public let secondaryIpRanges: [SecondaryIPRange]

    /// Purpose of the subnet
    public let purpose: SubnetPurpose?

    /// Role for proxy-only subnets
    public let role: SubnetRole?

    /// Stack type (IPv4 only or dual-stack)
    public let stackType: StackType

    public init(
        name: String,
        networkName: String,
        projectID: String,
        region: String,
        ipCidrRange: String,
        description: String? = nil,
        privateIpGoogleAccess: Bool = true,
        enableFlowLogs: Bool = false,
        flowLogAggregationInterval: FlowLogInterval? = nil,
        secondaryIpRanges: [SecondaryIPRange] = [],
        purpose: SubnetPurpose? = nil,
        role: SubnetRole? = nil,
        stackType: StackType = .ipv4Only
    ) {
        self.name = name
        self.networkName = networkName
        self.projectID = projectID
        self.region = region
        self.ipCidrRange = ipCidrRange
        self.description = description
        self.privateIpGoogleAccess = privateIpGoogleAccess
        self.enableFlowLogs = enableFlowLogs
        self.flowLogAggregationInterval = flowLogAggregationInterval
        self.secondaryIpRanges = secondaryIpRanges
        self.purpose = purpose
        self.role = role
        self.stackType = stackType
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/subnetworks/\(name)"
    }

    /// gcloud command to create this subnet
    public var createCommand: String {
        var cmd = "gcloud compute networks subnets create \(name)"
        cmd += " --network=\(networkName)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --range=\(ipCidrRange)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if privateIpGoogleAccess {
            cmd += " --enable-private-ip-google-access"
        }
        if enableFlowLogs {
            cmd += " --enable-flow-logs"
            if let interval = flowLogAggregationInterval {
                cmd += " --logging-aggregation-interval=\(interval.rawValue)"
            }
        }
        for range in secondaryIpRanges {
            cmd += " --secondary-range=\(range.rangeName)=\(range.ipCidrRange)"
        }
        if let purpose = purpose {
            cmd += " --purpose=\(purpose.rawValue)"
        }
        if let role = role {
            cmd += " --role=\(role.rawValue)"
        }
        if stackType == .ipv4Ipv6 {
            cmd += " --stack-type=IPV4_IPV6"
        }
        return cmd
    }

    /// gcloud command to delete this subnet
    public var deleteCommand: String {
        "gcloud compute networks subnets delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this subnet
    public var describeCommand: String {
        "gcloud compute networks subnets describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list subnets
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud compute networks subnets list --project=\(projectID)"
        if let region = region {
            cmd += " --regions=\(region)"
        }
        return cmd
    }

    /// gcloud command to expand IP range
    public func expandIpRangeCommand(newRange: String) -> String {
        "gcloud compute networks subnets expand-ip-range \(name) --project=\(projectID) --region=\(region) --prefix-length=\(newRange)"
    }

    /// Secondary IP range configuration
    public struct SecondaryIPRange: Codable, Sendable, Equatable {
        public let rangeName: String
        public let ipCidrRange: String

        public init(rangeName: String, ipCidrRange: String) {
            self.rangeName = rangeName
            self.ipCidrRange = ipCidrRange
        }
    }

    /// Flow log aggregation intervals
    public enum FlowLogInterval: String, Codable, Sendable {
        case interval5Sec = "INTERVAL_5_SEC"
        case interval30Sec = "INTERVAL_30_SEC"
        case interval1Min = "INTERVAL_1_MIN"
        case interval5Min = "INTERVAL_5_MIN"
        case interval10Min = "INTERVAL_10_MIN"
        case interval15Min = "INTERVAL_15_MIN"
    }

    /// Subnet purposes
    public enum SubnetPurpose: String, Codable, Sendable {
        /// Regular subnet for VM instances
        case privateDefault = "PRIVATE"
        /// Regional internal HTTP(S) load balancer
        case regionalManagedProxy = "REGIONAL_MANAGED_PROXY"
        /// Global internal HTTP(S) load balancer
        case globalManagedProxy = "GLOBAL_MANAGED_PROXY"
        /// Private Service Connect
        case privateServiceConnect = "PRIVATE_SERVICE_CONNECT"
    }

    /// Subnet roles for proxy-only subnets
    public enum SubnetRole: String, Codable, Sendable {
        case active = "ACTIVE"
        case backup = "BACKUP"
    }

    /// Stack type for IP addressing
    public enum StackType: String, Codable, Sendable {
        case ipv4Only = "IPV4_ONLY"
        case ipv4Ipv6 = "IPV4_IPV6"
    }
}

// MARK: - Firewall Rule

/// Represents a firewall rule in Google Cloud.
///
/// Firewall rules control ingress and egress traffic for VM instances.
///
/// ## Example Usage
/// ```swift
/// let rule = GoogleCloudFirewallRule(
///     name: "allow-http",
///     networkName: "my-vpc",
///     projectID: "my-project",
///     direction: .ingress,
///     allowed: [.init(protocol: .tcp, ports: ["80", "443"])],
///     sourceRanges: ["0.0.0.0/0"],
///     targetTags: ["web-server"]
/// )
/// print(rule.createCommand)
/// ```
public struct GoogleCloudFirewallRule: Codable, Sendable, Equatable {
    /// Name of the firewall rule
    public let name: String

    /// Name of the network
    public let networkName: String

    /// Project ID
    public let projectID: String

    /// Direction of traffic
    public let direction: Direction

    /// Allowed traffic specifications
    public let allowed: [TrafficSpec]

    /// Denied traffic specifications
    public let denied: [TrafficSpec]

    /// Priority (0-65535, lower = higher priority)
    public let priority: Int

    /// Source IP ranges (for ingress)
    public let sourceRanges: [String]

    /// Destination IP ranges (for egress)
    public let destinationRanges: [String]

    /// Source tags (for ingress)
    public let sourceTags: [String]

    /// Target tags
    public let targetTags: [String]

    /// Source service accounts (for ingress)
    public let sourceServiceAccounts: [String]

    /// Target service accounts
    public let targetServiceAccounts: [String]

    /// Description
    public let description: String?

    /// Whether the rule is disabled
    public let disabled: Bool

    /// Enable logging
    public let enableLogging: Bool

    public init(
        name: String,
        networkName: String,
        projectID: String,
        direction: Direction = .ingress,
        allowed: [TrafficSpec] = [],
        denied: [TrafficSpec] = [],
        priority: Int = 1000,
        sourceRanges: [String] = [],
        destinationRanges: [String] = [],
        sourceTags: [String] = [],
        targetTags: [String] = [],
        sourceServiceAccounts: [String] = [],
        targetServiceAccounts: [String] = [],
        description: String? = nil,
        disabled: Bool = false,
        enableLogging: Bool = false
    ) {
        self.name = name
        self.networkName = networkName
        self.projectID = projectID
        self.direction = direction
        self.allowed = allowed
        self.denied = denied
        self.priority = priority
        self.sourceRanges = sourceRanges
        self.destinationRanges = destinationRanges
        self.sourceTags = sourceTags
        self.targetTags = targetTags
        self.sourceServiceAccounts = sourceServiceAccounts
        self.targetServiceAccounts = targetServiceAccounts
        self.description = description
        self.disabled = disabled
        self.enableLogging = enableLogging
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/firewalls/\(name)"
    }

    /// gcloud command to create this firewall rule
    public var createCommand: String {
        var cmd = "gcloud compute firewall-rules create \(name)"
        cmd += " --network=\(networkName)"
        cmd += " --project=\(projectID)"
        cmd += " --direction=\(direction.rawValue)"
        cmd += " --priority=\(priority)"

        if !allowed.isEmpty {
            let allowRules = allowed.map { spec -> String in
                if let ports = spec.ports, !ports.isEmpty {
                    return "\(spec.ipProtocol.rawValue):\(ports.joined(separator: ","))"
                }
                return spec.ipProtocol.rawValue
            }
            cmd += " --allow=\(allowRules.joined(separator: ","))"
        }

        if !denied.isEmpty {
            let denyRules = denied.map { spec -> String in
                if let ports = spec.ports, !ports.isEmpty {
                    return "\(spec.ipProtocol.rawValue):\(ports.joined(separator: ","))"
                }
                return spec.ipProtocol.rawValue
            }
            cmd += " --rules=\(denyRules.joined(separator: ","))"
            cmd += " --action=DENY"
        }

        if !sourceRanges.isEmpty {
            cmd += " --source-ranges=\(sourceRanges.joined(separator: ","))"
        }
        if !destinationRanges.isEmpty {
            cmd += " --destination-ranges=\(destinationRanges.joined(separator: ","))"
        }
        if !sourceTags.isEmpty {
            cmd += " --source-tags=\(sourceTags.joined(separator: ","))"
        }
        if !targetTags.isEmpty {
            cmd += " --target-tags=\(targetTags.joined(separator: ","))"
        }
        if !sourceServiceAccounts.isEmpty {
            cmd += " --source-service-accounts=\(sourceServiceAccounts.joined(separator: ","))"
        }
        if !targetServiceAccounts.isEmpty {
            cmd += " --target-service-accounts=\(targetServiceAccounts.joined(separator: ","))"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if disabled {
            cmd += " --disabled"
        }
        if enableLogging {
            cmd += " --enable-logging"
        }

        return cmd
    }

    /// gcloud command to delete this firewall rule
    public var deleteCommand: String {
        "gcloud compute firewall-rules delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this firewall rule
    public var describeCommand: String {
        "gcloud compute firewall-rules describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list firewall rules
    public static func listCommand(projectID: String) -> String {
        "gcloud compute firewall-rules list --project=\(projectID)"
    }

    /// gcloud command to update this firewall rule
    public var updateCommand: String {
        var cmd = "gcloud compute firewall-rules update \(name)"
        cmd += " --project=\(projectID)"
        if disabled {
            cmd += " --disabled"
        } else {
            cmd += " --no-disabled"
        }
        return cmd
    }

    /// Traffic direction
    public enum Direction: String, Codable, Sendable {
        case ingress = "INGRESS"
        case egress = "EGRESS"
    }

    /// Traffic specification
    public struct TrafficSpec: Codable, Sendable, Equatable {
        public let ipProtocol: IPProtocol
        public let ports: [String]?

        public init(protocol ipProtocol: IPProtocol, ports: [String]? = nil) {
            self.ipProtocol = ipProtocol
            self.ports = ports
        }

        /// IP protocols
        public enum IPProtocol: String, Codable, Sendable {
            case tcp = "tcp"
            case udp = "udp"
            case icmp = "icmp"
            case esp = "esp"
            case ah = "ah"
            case sctp = "sctp"
            case all = "all"
        }
    }
}

// MARK: - Route

/// Represents a route in a VPC network.
///
/// Routes define paths for network traffic from VM instances.
public struct GoogleCloudRoute: Codable, Sendable, Equatable {
    /// Name of the route
    public let name: String

    /// Network name
    public let networkName: String

    /// Project ID
    public let projectID: String

    /// Destination IP range
    public let destRange: String

    /// Next hop type
    public let nextHop: NextHop

    /// Priority (0-65535)
    public let priority: Int

    /// Tags for route applicability
    public let tags: [String]

    /// Description
    public let description: String?

    public init(
        name: String,
        networkName: String,
        projectID: String,
        destRange: String,
        nextHop: NextHop,
        priority: Int = 1000,
        tags: [String] = [],
        description: String? = nil
    ) {
        self.name = name
        self.networkName = networkName
        self.projectID = projectID
        self.destRange = destRange
        self.nextHop = nextHop
        self.priority = priority
        self.tags = tags
        self.description = description
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/routes/\(name)"
    }

    /// gcloud command to create this route
    public var createCommand: String {
        var cmd = "gcloud compute routes create \(name)"
        cmd += " --network=\(networkName)"
        cmd += " --project=\(projectID)"
        cmd += " --destination-range=\(destRange)"
        cmd += " --priority=\(priority)"

        switch nextHop {
        case .gateway(let gateway):
            cmd += " --next-hop-gateway=\(gateway)"
        case .instance(let instance, let zone):
            cmd += " --next-hop-instance=\(instance)"
            cmd += " --next-hop-instance-zone=\(zone)"
        case .ip(let address):
            cmd += " --next-hop-address=\(address)"
        case .vpnTunnel(let tunnel, let region):
            cmd += " --next-hop-vpn-tunnel=\(tunnel)"
            cmd += " --next-hop-vpn-tunnel-region=\(region)"
        case .ilb(let forwardingRule, let region):
            cmd += " --next-hop-ilb=\(forwardingRule)"
            cmd += " --next-hop-ilb-region=\(region)"
        }

        if !tags.isEmpty {
            cmd += " --tags=\(tags.joined(separator: ","))"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// gcloud command to delete this route
    public var deleteCommand: String {
        "gcloud compute routes delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this route
    public var describeCommand: String {
        "gcloud compute routes describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list routes
    public static func listCommand(projectID: String) -> String {
        "gcloud compute routes list --project=\(projectID)"
    }

    /// Next hop types
    public enum NextHop: Codable, Sendable, Equatable {
        /// Default internet gateway
        case gateway(String)
        /// VM instance
        case instance(name: String, zone: String)
        /// IP address
        case ip(address: String)
        /// VPN tunnel
        case vpnTunnel(name: String, region: String)
        /// Internal load balancer
        case ilb(forwardingRule: String, region: String)
    }
}

// MARK: - VPC Peering

/// Represents a VPC network peering connection.
///
/// VPC peering allows private connectivity between VPC networks.
public struct GoogleCloudVPCPeering: Codable, Sendable, Equatable {
    /// Name of the peering connection
    public let name: String

    /// Local network name
    public let networkName: String

    /// Project ID
    public let projectID: String

    /// Peer network (full resource name)
    public let peerNetwork: String

    /// Export custom routes
    public let exportCustomRoutes: Bool

    /// Import custom routes
    public let importCustomRoutes: Bool

    /// Export subnet routes with public IP
    public let exportSubnetRoutesWithPublicIp: Bool

    /// Import subnet routes with public IP
    public let importSubnetRoutesWithPublicIp: Bool

    public init(
        name: String,
        networkName: String,
        projectID: String,
        peerNetwork: String,
        exportCustomRoutes: Bool = false,
        importCustomRoutes: Bool = false,
        exportSubnetRoutesWithPublicIp: Bool = true,
        importSubnetRoutesWithPublicIp: Bool = false
    ) {
        self.name = name
        self.networkName = networkName
        self.projectID = projectID
        self.peerNetwork = peerNetwork
        self.exportCustomRoutes = exportCustomRoutes
        self.importCustomRoutes = importCustomRoutes
        self.exportSubnetRoutesWithPublicIp = exportSubnetRoutesWithPublicIp
        self.importSubnetRoutesWithPublicIp = importSubnetRoutesWithPublicIp
    }

    /// gcloud command to create this peering
    public var createCommand: String {
        var cmd = "gcloud compute networks peerings create \(name)"
        cmd += " --network=\(networkName)"
        cmd += " --peer-network=\(peerNetwork)"
        cmd += " --project=\(projectID)"
        if exportCustomRoutes {
            cmd += " --export-custom-routes"
        }
        if importCustomRoutes {
            cmd += " --import-custom-routes"
        }
        if !exportSubnetRoutesWithPublicIp {
            cmd += " --no-export-subnet-routes-with-public-ip"
        }
        if importSubnetRoutesWithPublicIp {
            cmd += " --import-subnet-routes-with-public-ip"
        }
        return cmd
    }

    /// gcloud command to delete this peering
    public var deleteCommand: String {
        "gcloud compute networks peerings delete \(name) --network=\(networkName) --project=\(projectID) --quiet"
    }

    /// gcloud command to list peerings
    public static func listCommand(networkName: String, projectID: String) -> String {
        "gcloud compute networks peerings list --network=\(networkName) --project=\(projectID)"
    }

    /// gcloud command to update peering
    public var updateCommand: String {
        var cmd = "gcloud compute networks peerings update \(name)"
        cmd += " --network=\(networkName)"
        cmd += " --project=\(projectID)"
        if exportCustomRoutes {
            cmd += " --export-custom-routes"
        } else {
            cmd += " --no-export-custom-routes"
        }
        if importCustomRoutes {
            cmd += " --import-custom-routes"
        } else {
            cmd += " --no-import-custom-routes"
        }
        return cmd
    }
}

// MARK: - Cloud Router

/// Represents a Cloud Router for dynamic routing.
///
/// Cloud Routers enable dynamic route exchange with on-premises networks
/// and other cloud providers using BGP.
public struct GoogleCloudRouter: Codable, Sendable, Equatable {
    /// Name of the router
    public let name: String

    /// Network name
    public let networkName: String

    /// Project ID
    public let projectID: String

    /// Region
    public let region: String

    /// BGP ASN (Autonomous System Number)
    public let bgpAsn: Int

    /// Description
    public let description: String?

    /// Advertised IP ranges
    public let advertisedIpRanges: [String]

    /// Advertise mode
    public let advertiseMode: AdvertiseMode

    public init(
        name: String,
        networkName: String,
        projectID: String,
        region: String,
        bgpAsn: Int = 64512,
        description: String? = nil,
        advertisedIpRanges: [String] = [],
        advertiseMode: AdvertiseMode = .default
    ) {
        self.name = name
        self.networkName = networkName
        self.projectID = projectID
        self.region = region
        self.bgpAsn = bgpAsn
        self.description = description
        self.advertisedIpRanges = advertisedIpRanges
        self.advertiseMode = advertiseMode
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/routers/\(name)"
    }

    /// gcloud command to create this router
    public var createCommand: String {
        var cmd = "gcloud compute routers create \(name)"
        cmd += " --network=\(networkName)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --asn=\(bgpAsn)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if advertiseMode == .custom && !advertisedIpRanges.isEmpty {
            cmd += " --advertisement-mode=CUSTOM"
            cmd += " --set-advertisement-ranges=\(advertisedIpRanges.joined(separator: ","))"
        }
        return cmd
    }

    /// gcloud command to delete this router
    public var deleteCommand: String {
        "gcloud compute routers delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this router
    public var describeCommand: String {
        "gcloud compute routers describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list routers
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud compute routers list --project=\(projectID)"
        if let region = region {
            cmd += " --regions=\(region)"
        }
        return cmd
    }

    /// Advertise mode
    public enum AdvertiseMode: String, Codable, Sendable {
        case `default` = "DEFAULT"
        case custom = "CUSTOM"
    }
}

// MARK: - Cloud NAT

/// Represents a Cloud NAT gateway.
///
/// Cloud NAT provides outbound internet connectivity for instances
/// without external IP addresses.
public struct GoogleCloudNATGateway: Codable, Sendable, Equatable {
    /// Name of the NAT gateway
    public let name: String

    /// Router name
    public let routerName: String

    /// Project ID
    public let projectID: String

    /// Region
    public let region: String

    /// NAT IP allocation option
    public let natIpAllocateOption: NATIPAllocateOption

    /// Source subnetwork IP ranges to NAT
    public let sourceSubnetworkIpRangesToNat: SourceSubnetworkOption

    /// Specific subnets to NAT (for PRIMARY_IP_RANGE)
    public let subnetworks: [SubnetNATConfig]

    /// Minimum ports per VM
    public let minPortsPerVm: Int?

    /// Enable endpoint-independent mapping
    public let enableEndpointIndependentMapping: Bool

    /// Enable dynamic port allocation
    public let enableDynamicPortAllocation: Bool

    /// Log config
    public let logFilter: LogFilter?

    public init(
        name: String,
        routerName: String,
        projectID: String,
        region: String,
        natIpAllocateOption: NATIPAllocateOption = .autoOnly,
        sourceSubnetworkIpRangesToNat: SourceSubnetworkOption = .allSubnetworksAllIpRanges,
        subnetworks: [SubnetNATConfig] = [],
        minPortsPerVm: Int? = nil,
        enableEndpointIndependentMapping: Bool = true,
        enableDynamicPortAllocation: Bool = false,
        logFilter: LogFilter? = nil
    ) {
        self.name = name
        self.routerName = routerName
        self.projectID = projectID
        self.region = region
        self.natIpAllocateOption = natIpAllocateOption
        self.sourceSubnetworkIpRangesToNat = sourceSubnetworkIpRangesToNat
        self.subnetworks = subnetworks
        self.minPortsPerVm = minPortsPerVm
        self.enableEndpointIndependentMapping = enableEndpointIndependentMapping
        self.enableDynamicPortAllocation = enableDynamicPortAllocation
        self.logFilter = logFilter
    }

    /// gcloud command to create this NAT gateway
    public var createCommand: String {
        var cmd = "gcloud compute routers nats create \(name)"
        cmd += " --router=\(routerName)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --nat-all-subnet-ip-ranges"
        cmd += " --auto-allocate-nat-external-ips"
        if let minPorts = minPortsPerVm {
            cmd += " --min-ports-per-vm=\(minPorts)"
        }
        if enableDynamicPortAllocation {
            cmd += " --enable-dynamic-port-allocation"
        }
        if let logFilter = logFilter {
            cmd += " --enable-logging"
            cmd += " --log-filter=\(logFilter.rawValue)"
        }
        return cmd
    }

    /// gcloud command to delete this NAT gateway
    public var deleteCommand: String {
        "gcloud compute routers nats delete \(name) --router=\(routerName) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe this NAT gateway
    public var describeCommand: String {
        "gcloud compute routers nats describe \(name) --router=\(routerName) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list NAT gateways
    public static func listCommand(routerName: String, projectID: String, region: String) -> String {
        "gcloud compute routers nats list --router=\(routerName) --project=\(projectID) --region=\(region)"
    }

    /// NAT IP allocation options
    public enum NATIPAllocateOption: String, Codable, Sendable {
        case autoOnly = "AUTO_ONLY"
        case manualOnly = "MANUAL_ONLY"
    }

    /// Source subnetwork options
    public enum SourceSubnetworkOption: String, Codable, Sendable {
        case allSubnetworksAllIpRanges = "ALL_SUBNETWORKS_ALL_IP_RANGES"
        case allSubnetworksAllPrimaryIpRanges = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
        case listOfSubnetworks = "LIST_OF_SUBNETWORKS"
    }

    /// Subnet NAT configuration
    public struct SubnetNATConfig: Codable, Sendable, Equatable {
        public let subnetName: String
        public let sourceIpRangesToNat: [String]

        public init(subnetName: String, sourceIpRangesToNat: [String] = ["ALL_IP_RANGES"]) {
            self.subnetName = subnetName
            self.sourceIpRangesToNat = sourceIpRangesToNat
        }
    }

    /// Log filter options
    public enum LogFilter: String, Codable, Sendable {
        case all = "ALL"
        case errorsOnly = "ERRORS_ONLY"
        case translationsOnly = "TRANSLATIONS_ONLY"
    }
}

// MARK: - Reserved IP Address

/// Represents a reserved IP address.
public struct GoogleCloudReservedAddress: Codable, Sendable, Equatable {
    /// Name of the address
    public let name: String

    /// Project ID
    public let projectID: String

    /// Region (nil for global)
    public let region: String?

    /// Address type
    public let addressType: AddressType

    /// IP version
    public let ipVersion: IPVersion

    /// Network tier
    public let networkTier: NetworkTier

    /// Purpose
    public let purpose: AddressPurpose?

    /// Subnetwork (for internal addresses)
    public let subnetwork: String?

    /// Description
    public let description: String?

    public init(
        name: String,
        projectID: String,
        region: String? = nil,
        addressType: AddressType = .external,
        ipVersion: IPVersion = .ipv4,
        networkTier: NetworkTier = .premium,
        purpose: AddressPurpose? = nil,
        subnetwork: String? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.addressType = addressType
        self.ipVersion = ipVersion
        self.networkTier = networkTier
        self.purpose = purpose
        self.subnetwork = subnetwork
        self.description = description
    }

    /// gcloud command to reserve this address
    public var createCommand: String {
        var cmd: String
        if let region = region {
            cmd = "gcloud compute addresses create \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --region=\(region)"
        } else {
            cmd = "gcloud compute addresses create \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --global"
        }

        if addressType == .internal {
            cmd += " --address-type=INTERNAL"
            if let subnet = subnetwork {
                cmd += " --subnet=\(subnet)"
            }
        }

        cmd += " --ip-version=\(ipVersion.rawValue)"
        cmd += " --network-tier=\(networkTier.rawValue)"

        if let purpose = purpose {
            cmd += " --purpose=\(purpose.rawValue)"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// gcloud command to delete this address
    public var deleteCommand: String {
        if let region = region {
            return "gcloud compute addresses delete \(name) --project=\(projectID) --region=\(region) --quiet"
        }
        return "gcloud compute addresses delete \(name) --project=\(projectID) --global --quiet"
    }

    /// gcloud command to describe this address
    public var describeCommand: String {
        if let region = region {
            return "gcloud compute addresses describe \(name) --project=\(projectID) --region=\(region)"
        }
        return "gcloud compute addresses describe \(name) --project=\(projectID) --global"
    }

    /// gcloud command to list addresses
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud compute addresses list --project=\(projectID)"
        if let region = region {
            cmd += " --regions=\(region)"
        }
        return cmd
    }

    /// Address types
    public enum AddressType: String, Codable, Sendable {
        case external = "EXTERNAL"
        case `internal` = "INTERNAL"
    }

    /// IP versions
    public enum IPVersion: String, Codable, Sendable {
        case ipv4 = "IPV4"
        case ipv6 = "IPV6"
    }

    /// Network tiers
    public enum NetworkTier: String, Codable, Sendable {
        case premium = "PREMIUM"
        case standard = "STANDARD"
    }

    /// Address purposes
    public enum AddressPurpose: String, Codable, Sendable {
        case gceEndpoint = "GCE_ENDPOINT"
        case sharedLoadbalancerVip = "SHARED_LOADBALANCER_VIP"
        case vpcPeering = "VPC_PEERING"
        case ipsecInterconnect = "IPSEC_INTERCONNECT"
        case privateServiceConnect = "PRIVATE_SERVICE_CONNECT"
    }
}

// MARK: - Predefined CIDR Ranges

/// Common CIDR ranges for VPC configuration.
public enum PredefinedCIDRRange {
    /// RFC 1918 private ranges
    public static let private10 = "10.0.0.0/8"
    public static let private172 = "172.16.0.0/12"
    public static let private192 = "192.168.0.0/16"

    /// Common subnet sizes
    public static let subnet24 = "/24"  // 254 hosts
    public static let subnet23 = "/23"  // 510 hosts
    public static let subnet22 = "/22"  // 1022 hosts
    public static let subnet20 = "/20"  // 4094 hosts
    public static let subnet16 = "/16"  // 65534 hosts

    /// GKE recommended ranges
    public static let gkePods = "10.4.0.0/14"       // Pods
    public static let gkeServices = "10.0.32.0/20" // Services
    public static let gkeMaster = "172.16.0.0/28"  // Control plane

    /// Private Google Access
    public static let privateGoogleAccess = "199.36.153.8/30"
    public static let restrictedGoogleAccess = "199.36.153.4/30"
}

// MARK: - DAIS VPC Templates

/// Predefined VPC configurations for DAIS deployments.
public enum DAISVPCTemplate {
    /// Create a VPC network for DAIS
    public static func network(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudVPCNetwork {
        GoogleCloudVPCNetwork(
            name: "\(deploymentName)-vpc",
            projectID: projectID,
            autoCreateSubnetworks: false,
            routingMode: .global,
            description: "VPC network for DAIS deployment \(deploymentName)"
        )
    }

    /// Create a subnet for DAIS nodes
    public static func nodeSubnet(
        projectID: String,
        deploymentName: String,
        region: String,
        cidrRange: String = "10.0.0.0/24"
    ) -> GoogleCloudSubnet {
        GoogleCloudSubnet(
            name: "\(deploymentName)-nodes",
            networkName: "\(deploymentName)-vpc",
            projectID: projectID,
            region: region,
            ipCidrRange: cidrRange,
            description: "Subnet for DAIS nodes",
            privateIpGoogleAccess: true,
            enableFlowLogs: true,
            flowLogAggregationInterval: .interval5Min
        )
    }

    /// Create firewall rule to allow gRPC traffic
    public static func grpcFirewallRule(
        projectID: String,
        deploymentName: String,
        port: Int = 9090
    ) -> GoogleCloudFirewallRule {
        GoogleCloudFirewallRule(
            name: "\(deploymentName)-allow-grpc",
            networkName: "\(deploymentName)-vpc",
            projectID: projectID,
            direction: .ingress,
            allowed: [.init(protocol: .tcp, ports: ["\(port)"])],
            sourceRanges: ["10.0.0.0/8"],
            targetTags: ["\(deploymentName)-node"],
            description: "Allow gRPC traffic between DAIS nodes"
        )
    }

    /// Create firewall rule to allow HTTP health checks
    public static func healthCheckFirewallRule(
        projectID: String,
        deploymentName: String,
        port: Int = 8080
    ) -> GoogleCloudFirewallRule {
        GoogleCloudFirewallRule(
            name: "\(deploymentName)-allow-health-check",
            networkName: "\(deploymentName)-vpc",
            projectID: projectID,
            direction: .ingress,
            allowed: [.init(protocol: .tcp, ports: ["\(port)"])],
            sourceRanges: ["35.191.0.0/16", "130.211.0.0/22"],
            targetTags: ["\(deploymentName)-node"],
            description: "Allow health check traffic from Google"
        )
    }

    /// Create firewall rule to allow SSH
    public static func sshFirewallRule(
        projectID: String,
        deploymentName: String,
        sourceRanges: [String] = ["35.235.240.0/20"]
    ) -> GoogleCloudFirewallRule {
        GoogleCloudFirewallRule(
            name: "\(deploymentName)-allow-ssh",
            networkName: "\(deploymentName)-vpc",
            projectID: projectID,
            direction: .ingress,
            allowed: [.init(protocol: .tcp, ports: ["22"])],
            sourceRanges: sourceRanges,
            targetTags: ["\(deploymentName)-node"],
            description: "Allow SSH from IAP"
        )
    }

    /// Create firewall rule to allow internal traffic
    public static func internalFirewallRule(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudFirewallRule {
        GoogleCloudFirewallRule(
            name: "\(deploymentName)-allow-internal",
            networkName: "\(deploymentName)-vpc",
            projectID: projectID,
            direction: .ingress,
            allowed: [
                .init(protocol: .tcp, ports: nil),
                .init(protocol: .udp, ports: nil),
                .init(protocol: .icmp, ports: nil)
            ],
            sourceTags: ["\(deploymentName)-node"],
            targetTags: ["\(deploymentName)-node"],
            description: "Allow all internal traffic between DAIS nodes"
        )
    }

    /// Create a Cloud Router for the VPC
    public static func router(
        projectID: String,
        deploymentName: String,
        region: String
    ) -> GoogleCloudRouter {
        GoogleCloudRouter(
            name: "\(deploymentName)-router",
            networkName: "\(deploymentName)-vpc",
            projectID: projectID,
            region: region,
            description: "Cloud Router for DAIS deployment"
        )
    }

    /// Create a Cloud NAT for outbound internet access
    public static func natGateway(
        projectID: String,
        deploymentName: String,
        region: String
    ) -> GoogleCloudNATGateway {
        GoogleCloudNATGateway(
            name: "\(deploymentName)-nat",
            routerName: "\(deploymentName)-router",
            projectID: projectID,
            region: region,
            enableDynamicPortAllocation: true,
            logFilter: .errorsOnly
        )
    }

    /// Generate a complete VPC setup script
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        region: String,
        nodeSubnetCidr: String = "10.0.0.0/24"
    ) -> String {
        let network = network(projectID: projectID, deploymentName: deploymentName)
        let subnet = nodeSubnet(projectID: projectID, deploymentName: deploymentName, region: region, cidrRange: nodeSubnetCidr)
        let grpcRule = grpcFirewallRule(projectID: projectID, deploymentName: deploymentName)
        let healthRule = healthCheckFirewallRule(projectID: projectID, deploymentName: deploymentName)
        let sshRule = sshFirewallRule(projectID: projectID, deploymentName: deploymentName)
        let internalRule = internalFirewallRule(projectID: projectID, deploymentName: deploymentName)
        let router = router(projectID: projectID, deploymentName: deploymentName, region: region)
        let nat = natGateway(projectID: projectID, deploymentName: deploymentName, region: region)

        return """
        #!/bin/bash
        # DAIS VPC Network Setup Script
        # Deployment: \(deploymentName)
        # Project: \(projectID)
        # Region: \(region)

        set -e

        echo "========================================"
        echo "DAIS VPC Network Configuration"
        echo "========================================"

        # Create VPC network
        echo "Creating VPC network..."
        \(network.createCommand)

        # Create subnet
        echo "Creating subnet..."
        \(subnet.createCommand)

        # Create firewall rules
        echo "Creating firewall rules..."
        \(grpcRule.createCommand)
        \(healthRule.createCommand)
        \(sshRule.createCommand)
        \(internalRule.createCommand)

        # Create Cloud Router
        echo "Creating Cloud Router..."
        \(router.createCommand)

        # Create Cloud NAT
        echo "Creating Cloud NAT..."
        \(nat.createCommand)

        echo ""
        echo "VPC setup complete!"
        echo ""
        echo "Network: \(network.name)"
        echo "Subnet: \(subnet.name) (\(nodeSubnetCidr))"
        echo "Region: \(region)"
        """
    }

    /// Generate a teardown script
    public static func teardownScript(
        projectID: String,
        deploymentName: String,
        region: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS VPC Network Teardown Script
        # WARNING: This will delete all VPC resources!

        set -e

        echo "Deleting Cloud NAT..."
        gcloud compute routers nats delete \(deploymentName)-nat \\
            --router=\(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --quiet || true

        echo "Deleting Cloud Router..."
        gcloud compute routers delete \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --quiet || true

        echo "Deleting firewall rules..."
        gcloud compute firewall-rules delete \(deploymentName)-allow-grpc --project=\(projectID) --quiet || true
        gcloud compute firewall-rules delete \(deploymentName)-allow-health-check --project=\(projectID) --quiet || true
        gcloud compute firewall-rules delete \(deploymentName)-allow-ssh --project=\(projectID) --quiet || true
        gcloud compute firewall-rules delete \(deploymentName)-allow-internal --project=\(projectID) --quiet || true

        echo "Deleting subnet..."
        gcloud compute networks subnets delete \(deploymentName)-nodes \\
            --project=\(projectID) \\
            --region=\(region) \\
            --quiet || true

        echo "Deleting VPC network..."
        gcloud compute networks delete \(deploymentName)-vpc \\
            --project=\(projectID) \\
            --quiet || true

        echo "VPC teardown complete!"
        """
    }
}
