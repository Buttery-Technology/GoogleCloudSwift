// GoogleCloudVPN.swift
// Cloud VPN API for secure network connectivity

import Foundation

// MARK: - VPN Gateway

/// Represents a Cloud VPN Gateway (HA VPN)
public struct GoogleCloudVPNGateway: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let network: String
    public let stackType: StackType?
    public let description: String?
    public let labels: [String: String]?

    /// Stack type for the VPN gateway
    public enum StackType: String, Codable, Sendable, Equatable {
        case ipv4Only = "IPV4_ONLY"
        case ipv4Ipv6 = "IPV4_IPV6"
    }

    public init(
        name: String,
        projectID: String,
        region: String,
        network: String,
        stackType: StackType? = nil,
        description: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.network = network
        self.stackType = stackType
        self.description = description
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/vpnGateways/\(name)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "gcloud compute vpn-gateways create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --network=\(network)"
        if let stackType = stackType {
            cmd += " --stack-type=\(stackType.rawValue)"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud compute vpn-gateways describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud compute vpn-gateways delete \(name) --project=\(projectID) --region=\(region)"
    }

    /// List gateways command
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud compute vpn-gateways list --project=\(projectID)"
        if let region = region {
            cmd += " --filter=\"region:\(region)\""
        }
        return cmd
    }

    /// Get interfaces command (returns external IPs)
    public var getInterfacesCommand: String {
        "gcloud compute vpn-gateways describe \(name) --project=\(projectID) --region=\(region) --format=\"table(vpnInterfaces[].ipAddress)\""
    }
}

// MARK: - External VPN Gateway

/// Represents an External VPN Gateway (peer gateway)
public struct GoogleCloudExternalVPNGateway: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let interfaces: [Interface]
    public let redundancyType: RedundancyType
    public let description: String?

    /// External gateway interface
    public struct Interface: Codable, Sendable, Equatable {
        public let id: Int
        public let ipAddress: String

        public init(id: Int, ipAddress: String) {
            self.id = id
            self.ipAddress = ipAddress
        }
    }

    /// Redundancy type
    public enum RedundancyType: String, Codable, Sendable, Equatable {
        case singleIPInternally = "SINGLE_IP_INTERNALLY_REDUNDANT"
        case twoIPs = "TWO_IPS_REDUNDANCY"
        case fourIPs = "FOUR_IPS_REDUNDANCY"
    }

    public init(
        name: String,
        projectID: String,
        interfaces: [Interface],
        redundancyType: RedundancyType,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.interfaces = interfaces
        self.redundancyType = redundancyType
        self.description = description
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/global/externalVpnGateways/\(name)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "gcloud compute external-vpn-gateways create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --redundancy-type=\(redundancyType.rawValue)"

        let interfaceStrings = interfaces.map { "\($0.id)=\($0.ipAddress)" }
        cmd += " --interfaces=\(interfaceStrings.joined(separator: ","))"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud compute external-vpn-gateways describe \(name) --project=\(projectID)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud compute external-vpn-gateways delete \(name) --project=\(projectID)"
    }

    /// List command
    public static func listCommand(projectID: String) -> String {
        "gcloud compute external-vpn-gateways list --project=\(projectID)"
    }
}

// MARK: - VPN Tunnel

/// Represents a Cloud VPN Tunnel
public struct GoogleCloudVPNTunnel: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let vpnGateway: String
    public let vpnGatewayInterface: Int
    public let peerExternalGateway: String?
    public let peerExternalGatewayInterface: Int?
    public let peerGCPGateway: String?
    public let sharedSecret: String
    public let router: String
    public let ikeVersion: IKEVersion?
    public let description: String?
    public let labels: [String: String]?

    /// IKE version
    public enum IKEVersion: Int, Codable, Sendable, Equatable {
        case v1 = 1
        case v2 = 2
    }

    public init(
        name: String,
        projectID: String,
        region: String,
        vpnGateway: String,
        vpnGatewayInterface: Int,
        peerExternalGateway: String? = nil,
        peerExternalGatewayInterface: Int? = nil,
        peerGCPGateway: String? = nil,
        sharedSecret: String,
        router: String,
        ikeVersion: IKEVersion? = .v2,
        description: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.vpnGateway = vpnGateway
        self.vpnGatewayInterface = vpnGatewayInterface
        self.peerExternalGateway = peerExternalGateway
        self.peerExternalGatewayInterface = peerExternalGatewayInterface
        self.peerGCPGateway = peerGCPGateway
        self.sharedSecret = sharedSecret
        self.router = router
        self.ikeVersion = ikeVersion
        self.description = description
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/vpnTunnels/\(name)"
    }

    /// Create command for external peer
    public var createCommand: String {
        var cmd = "gcloud compute vpn-tunnels create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --vpn-gateway=\(vpnGateway)"
        cmd += " --vpn-gateway-region=\(region)"
        cmd += " --interface=\(vpnGatewayInterface)"

        if let peerExternal = peerExternalGateway {
            cmd += " --peer-external-gateway=\(peerExternal)"
            if let peerInterface = peerExternalGatewayInterface {
                cmd += " --peer-external-gateway-interface=\(peerInterface)"
            }
        }

        if let peerGCP = peerGCPGateway {
            cmd += " --peer-gcp-gateway=\(peerGCP)"
        }

        cmd += " --shared-secret=\"\(sharedSecret)\""
        cmd += " --router=\(router)"

        if let ikeVersion = ikeVersion {
            cmd += " --ike-version=\(ikeVersion.rawValue)"
        }

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud compute vpn-tunnels describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud compute vpn-tunnels delete \(name) --project=\(projectID) --region=\(region)"
    }

    /// List tunnels command
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud compute vpn-tunnels list --project=\(projectID)"
        if let region = region {
            cmd += " --filter=\"region:\(region)\""
        }
        return cmd
    }

    /// Get status command
    public var statusCommand: String {
        "gcloud compute vpn-tunnels describe \(name) --project=\(projectID) --region=\(region) --format=\"value(status)\""
    }
}

// MARK: - Classic VPN Gateway

/// Represents a Classic VPN Gateway (for backward compatibility)
public struct GoogleCloudClassicVPNGateway: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let network: String
    public let description: String?

    public init(
        name: String,
        projectID: String,
        region: String,
        network: String,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.network = network
        self.description = description
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/targetVpnGateways/\(name)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "gcloud compute target-vpn-gateways create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --network=\(network)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud compute target-vpn-gateways describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud compute target-vpn-gateways delete \(name) --project=\(projectID) --region=\(region)"
    }

    /// List command
    public static func listCommand(projectID: String) -> String {
        "gcloud compute target-vpn-gateways list --project=\(projectID)"
    }
}

// MARK: - VPN Operations

/// Operations helper for VPN
public struct VPNOperations {

    /// Generate a random shared secret
    public static func generateSharedSecretCommand(length: Int = 32) -> String {
        "openssl rand -base64 \(length)"
    }

    /// Check VPN tunnel status
    public static func checkTunnelStatusCommand(tunnelName: String, projectID: String, region: String) -> String {
        "gcloud compute vpn-tunnels describe \(tunnelName) --project=\(projectID) --region=\(region) --format=\"table(status,detailedStatus)\""
    }

    /// List all VPN resources
    public static func listAllCommand(projectID: String) -> String {
        """
        echo "=== VPN Gateways ===" && \
        gcloud compute vpn-gateways list --project=\(projectID) && \
        echo "=== External VPN Gateways ===" && \
        gcloud compute external-vpn-gateways list --project=\(projectID) && \
        echo "=== VPN Tunnels ===" && \
        gcloud compute vpn-tunnels list --project=\(projectID)
        """
    }

    /// Get BGP session status
    public static func getBGPStatusCommand(routerName: String, projectID: String, region: String) -> String {
        "gcloud compute routers get-status \(routerName) --project=\(projectID) --region=\(region)"
    }

    /// Create forwarding rules for classic VPN (ESP, UDP 500, UDP 4500)
    public static func createClassicForwardingRulesCommands(
        gatewayName: String,
        projectID: String,
        region: String,
        staticIP: String
    ) -> [String] {
        [
            "gcloud compute forwarding-rules create \(gatewayName)-esp --project=\(projectID) --region=\(region) --ip-protocol=ESP --address=\(staticIP) --target-vpn-gateway=\(gatewayName)",
            "gcloud compute forwarding-rules create \(gatewayName)-udp500 --project=\(projectID) --region=\(region) --ip-protocol=UDP --ports=500 --address=\(staticIP) --target-vpn-gateway=\(gatewayName)",
            "gcloud compute forwarding-rules create \(gatewayName)-udp4500 --project=\(projectID) --region=\(region) --ip-protocol=UDP --ports=4500 --address=\(staticIP) --target-vpn-gateway=\(gatewayName)"
        ]
    }
}

// MARK: - DAIS VPN Template

/// VPN templates for DAIS deployments
public struct DAISVPNTemplate {

    /// Create an HA VPN gateway
    public static func haVPNGateway(
        projectID: String,
        region: String,
        deploymentName: String,
        network: String
    ) -> GoogleCloudVPNGateway {
        GoogleCloudVPNGateway(
            name: "\(deploymentName)-vpn-gw",
            projectID: projectID,
            region: region,
            network: network,
            stackType: .ipv4Only,
            description: "HA VPN Gateway for \(deploymentName)",
            labels: [
                "deployment": deploymentName,
                "purpose": "site-to-site-vpn"
            ]
        )
    }

    /// Create an external VPN gateway for on-premises connection
    public static func externalGateway(
        projectID: String,
        deploymentName: String,
        peerIPs: [String]
    ) -> GoogleCloudExternalVPNGateway {
        let redundancyType: GoogleCloudExternalVPNGateway.RedundancyType
        let interfaces: [GoogleCloudExternalVPNGateway.Interface]

        switch peerIPs.count {
        case 1:
            redundancyType = .singleIPInternally
            interfaces = [GoogleCloudExternalVPNGateway.Interface(id: 0, ipAddress: peerIPs[0])]
        case 2:
            redundancyType = .twoIPs
            interfaces = peerIPs.enumerated().map { GoogleCloudExternalVPNGateway.Interface(id: $0.offset, ipAddress: $0.element) }
        default:
            redundancyType = .fourIPs
            interfaces = peerIPs.prefix(4).enumerated().map { GoogleCloudExternalVPNGateway.Interface(id: $0.offset, ipAddress: $0.element) }
        }

        return GoogleCloudExternalVPNGateway(
            name: "\(deploymentName)-peer-gw",
            projectID: projectID,
            interfaces: interfaces,
            redundancyType: redundancyType,
            description: "External peer gateway for \(deploymentName)"
        )
    }

    /// Create VPN tunnel
    public static func vpnTunnel(
        projectID: String,
        region: String,
        deploymentName: String,
        interfaceNum: Int,
        peerInterfaceNum: Int,
        sharedSecret: String,
        routerName: String
    ) -> GoogleCloudVPNTunnel {
        GoogleCloudVPNTunnel(
            name: "\(deploymentName)-tunnel-\(interfaceNum)",
            projectID: projectID,
            region: region,
            vpnGateway: "\(deploymentName)-vpn-gw",
            vpnGatewayInterface: interfaceNum,
            peerExternalGateway: "\(deploymentName)-peer-gw",
            peerExternalGatewayInterface: peerInterfaceNum,
            sharedSecret: sharedSecret,
            router: routerName,
            ikeVersion: .v2,
            description: "VPN tunnel \(interfaceNum) for \(deploymentName)",
            labels: [
                "deployment": deploymentName,
                "interface": "\(interfaceNum)"
            ]
        )
    }

    /// Create Cloud Router BGP peer for VPN
    public static func bgpPeerCommand(
        routerName: String,
        peerName: String,
        peerASN: Int,
        peerIPAddress: String,
        interfaceName: String,
        projectID: String,
        region: String
    ) -> String {
        var cmd = "gcloud compute routers add-bgp-peer \(routerName)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --peer-name=\(peerName)"
        cmd += " --peer-asn=\(peerASN)"
        cmd += " --peer-ip-address=\(peerIPAddress)"
        cmd += " --interface=\(interfaceName)"
        cmd += " --advertised-route-priority=100"
        return cmd
    }

    /// Create router interface for VPN tunnel
    public static func routerInterfaceCommand(
        routerName: String,
        interfaceName: String,
        vpnTunnelName: String,
        ipRange: String,
        projectID: String,
        region: String
    ) -> String {
        var cmd = "gcloud compute routers add-interface \(routerName)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --interface-name=\(interfaceName)"
        cmd += " --vpn-tunnel=\(vpnTunnelName)"
        cmd += " --ip-address=\(ipRange)"
        cmd += " --mask-length=30"
        return cmd
    }

    /// Generate setup script for HA VPN with BGP
    public static func setupScript(
        projectID: String,
        region: String,
        deploymentName: String,
        network: String,
        peerASN: Int,
        peerIPs: [String],
        localASN: Int = 65000
    ) -> String {
        """
        #!/bin/bash
        set -e

        # HA VPN Setup for \(deploymentName)
        # Project: \(projectID)
        # Region: \(region)

        # Generate shared secrets
        SECRET_0=$(openssl rand -base64 24)
        SECRET_1=$(openssl rand -base64 24)

        echo "Creating Cloud Router..."
        gcloud compute routers create \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --network=\(network) \\
            --asn=\(localASN)

        echo "Creating HA VPN Gateway..."
        gcloud compute vpn-gateways create \(deploymentName)-vpn-gw \\
            --project=\(projectID) \\
            --region=\(region) \\
            --network=\(network)

        echo "Creating External VPN Gateway..."
        gcloud compute external-vpn-gateways create \(deploymentName)-peer-gw \\
            --project=\(projectID) \\
            --interfaces=0=\(peerIPs.first ?? "PEER_IP_0")\(peerIPs.count > 1 ? ",1=\(peerIPs[1])" : "") \\
            --redundancy-type=\(peerIPs.count == 1 ? "SINGLE_IP_INTERNALLY_REDUNDANT" : "TWO_IPS_REDUNDANCY")

        echo "Creating VPN Tunnel 0..."
        gcloud compute vpn-tunnels create \(deploymentName)-tunnel-0 \\
            --project=\(projectID) \\
            --region=\(region) \\
            --vpn-gateway=\(deploymentName)-vpn-gw \\
            --interface=0 \\
            --peer-external-gateway=\(deploymentName)-peer-gw \\
            --peer-external-gateway-interface=0 \\
            --shared-secret="$SECRET_0" \\
            --router=\(deploymentName)-router \\
            --ike-version=2

        echo "Creating VPN Tunnel 1..."
        gcloud compute vpn-tunnels create \(deploymentName)-tunnel-1 \\
            --project=\(projectID) \\
            --region=\(region) \\
            --vpn-gateway=\(deploymentName)-vpn-gw \\
            --interface=1 \\
            --peer-external-gateway=\(deploymentName)-peer-gw \\
            --peer-external-gateway-interface=\(peerIPs.count == 1 ? "0" : "1") \\
            --shared-secret="$SECRET_1" \\
            --router=\(deploymentName)-router \\
            --ike-version=2

        echo "Adding Router Interfaces..."
        gcloud compute routers add-interface \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --interface-name=if-tunnel-0 \\
            --vpn-tunnel=\(deploymentName)-tunnel-0 \\
            --ip-address=169.254.0.1 \\
            --mask-length=30

        gcloud compute routers add-interface \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --interface-name=if-tunnel-1 \\
            --vpn-tunnel=\(deploymentName)-tunnel-1 \\
            --ip-address=169.254.1.1 \\
            --mask-length=30

        echo "Adding BGP Peers..."
        gcloud compute routers add-bgp-peer \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --peer-name=bgp-peer-0 \\
            --peer-asn=\(peerASN) \\
            --peer-ip-address=169.254.0.2 \\
            --interface=if-tunnel-0

        gcloud compute routers add-bgp-peer \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --peer-name=bgp-peer-1 \\
            --peer-asn=\(peerASN) \\
            --peer-ip-address=169.254.1.2 \\
            --interface=if-tunnel-1

        echo ""
        echo "HA VPN Setup Complete!"
        echo "========================"
        echo "Shared Secret 0: $SECRET_0"
        echo "Shared Secret 1: $SECRET_1"
        echo ""
        echo "Configure your on-premises VPN device with:"
        echo "  - Peer ASN: \(localASN)"
        echo "  - BGP IP for tunnel 0: 169.254.0.2/30 (peer: 169.254.0.1)"
        echo "  - BGP IP for tunnel 1: 169.254.1.2/30 (peer: 169.254.1.1)"
        """
    }

    /// Generate teardown script
    public static func teardownScript(
        projectID: String,
        region: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # VPN Teardown for \(deploymentName)

        echo "Removing BGP peers..."
        gcloud compute routers remove-bgp-peer \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --peer-name=bgp-peer-0 --quiet || true

        gcloud compute routers remove-bgp-peer \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --peer-name=bgp-peer-1 --quiet || true

        echo "Removing router interfaces..."
        gcloud compute routers remove-interface \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --interface-name=if-tunnel-0 --quiet || true

        gcloud compute routers remove-interface \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) \\
            --interface-name=if-tunnel-1 --quiet || true

        echo "Deleting VPN tunnels..."
        gcloud compute vpn-tunnels delete \(deploymentName)-tunnel-0 \\
            --project=\(projectID) \\
            --region=\(region) --quiet || true

        gcloud compute vpn-tunnels delete \(deploymentName)-tunnel-1 \\
            --project=\(projectID) \\
            --region=\(region) --quiet || true

        echo "Deleting VPN gateways..."
        gcloud compute vpn-gateways delete \(deploymentName)-vpn-gw \\
            --project=\(projectID) \\
            --region=\(region) --quiet || true

        gcloud compute external-vpn-gateways delete \(deploymentName)-peer-gw \\
            --project=\(projectID) --quiet || true

        echo "Deleting router..."
        gcloud compute routers delete \(deploymentName)-router \\
            --project=\(projectID) \\
            --region=\(region) --quiet || true

        echo "VPN teardown complete!"
        """
    }
}
