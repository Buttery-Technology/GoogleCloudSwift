// GoogleCloudInterconnect.swift
// Cloud Interconnect - Dedicated and partner connections
// Service #56

import Foundation

// MARK: - Interconnect

/// A dedicated or partner interconnect connection
public struct GoogleCloudInterconnect: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let location: String
    public let interconnectType: InterconnectType
    public let linkType: LinkType?
    public let requestedLinkCount: Int?
    public let adminEnabled: Bool?
    public let nocContactEmail: String?
    public let customerName: String?
    public let operationalStatus: OperationalStatus?
    public let provisionedLinkCount: Int?
    public let state: State?
    public let googleReferenceId: String?
    public let labels: [String: String]?
    public let createTime: String?

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        location: String,
        interconnectType: InterconnectType,
        linkType: LinkType? = nil,
        requestedLinkCount: Int? = nil,
        adminEnabled: Bool? = nil,
        nocContactEmail: String? = nil,
        customerName: String? = nil,
        operationalStatus: OperationalStatus? = nil,
        provisionedLinkCount: Int? = nil,
        state: State? = nil,
        googleReferenceId: String? = nil,
        labels: [String: String]? = nil,
        createTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.location = location
        self.interconnectType = interconnectType
        self.linkType = linkType
        self.requestedLinkCount = requestedLinkCount
        self.adminEnabled = adminEnabled
        self.nocContactEmail = nocContactEmail
        self.customerName = customerName
        self.operationalStatus = operationalStatus
        self.provisionedLinkCount = provisionedLinkCount
        self.state = state
        self.googleReferenceId = googleReferenceId
        self.labels = labels
        self.createTime = createTime
    }

    /// Interconnect type
    public enum InterconnectType: String, Codable, Sendable {
        case itPrivate = "IT_PRIVATE"
        case dedicated = "DEDICATED"
        case partner = "PARTNER"
    }

    /// Link type for dedicated interconnect
    public enum LinkType: String, Codable, Sendable {
        case linkTypeUnspecified = "LINK_TYPE_UNSPECIFIED"
        case linkTypeEthernet10gLr = "LINK_TYPE_ETHERNET_10G_LR"
        case linkTypeEthernet100gLr = "LINK_TYPE_ETHERNET_100G_LR"
    }

    /// Operational status
    public enum OperationalStatus: String, Codable, Sendable {
        case osActive = "OS_ACTIVE"
        case osUnprovisioned = "OS_UNPROVISIONED"
    }

    /// Interconnect state
    public enum State: String, Codable, Sendable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case deprecated = "DEPRECATED"
        case obsolete = "OBSOLETE"
        case deleted = "DELETED"
        case active = "ACTIVE"
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/global/interconnects/\(name)"
    }

    /// Create interconnect command
    public var createCommand: String {
        var cmd = "gcloud compute interconnects create \(name) --project=\(projectID)"
        cmd += " --interconnect-type=\(interconnectType.rawValue)"
        cmd += " --location=\(location)"
        if let linkType = linkType {
            cmd += " --link-type=\(linkType.rawValue)"
        }
        if let count = requestedLinkCount {
            cmd += " --requested-link-count=\(count)"
        }
        if let email = nocContactEmail {
            cmd += " --noc-contact-email=\(email)"
        }
        if let customer = customerName {
            cmd += " --customer-name=\"\(customer)\""
        }
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        if adminEnabled == true {
            cmd += " --admin-enabled"
        }
        return cmd
    }

    /// Describe interconnect command
    public var describeCommand: String {
        "gcloud compute interconnects describe \(name) --project=\(projectID)"
    }

    /// Delete interconnect command
    public var deleteCommand: String {
        "gcloud compute interconnects delete \(name) --project=\(projectID)"
    }

    /// Update interconnect command
    public var updateCommand: String {
        var cmd = "gcloud compute interconnects update \(name) --project=\(projectID)"
        if adminEnabled == true {
            cmd += " --admin-enabled"
        } else if adminEnabled == false {
            cmd += " --no-admin-enabled"
        }
        return cmd
    }
}

// MARK: - Interconnect Attachment

/// An attachment connecting a VLAN to Cloud Router
public struct GoogleCloudInterconnectAttachment: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let description: String?
    public let interconnect: String?
    public let router: String
    public let attachmentType: AttachmentType?
    public let edgeAvailabilityDomain: EdgeAvailabilityDomain?
    public let bandwidth: Bandwidth?
    public let vlanTag8021q: Int?
    public let candidateSubnets: [String]?
    public let mtu: Int?
    public let encryption: Encryption?
    public let ipsecInternalAddresses: [String]?
    public let adminEnabled: Bool?
    public let state: State?
    public let googleReferenceId: String?
    public let pairingKey: String?
    public let partnerMetadata: PartnerMetadata?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        region: String,
        description: String? = nil,
        interconnect: String? = nil,
        router: String,
        attachmentType: AttachmentType? = nil,
        edgeAvailabilityDomain: EdgeAvailabilityDomain? = nil,
        bandwidth: Bandwidth? = nil,
        vlanTag8021q: Int? = nil,
        candidateSubnets: [String]? = nil,
        mtu: Int? = nil,
        encryption: Encryption? = nil,
        ipsecInternalAddresses: [String]? = nil,
        adminEnabled: Bool? = nil,
        state: State? = nil,
        googleReferenceId: String? = nil,
        pairingKey: String? = nil,
        partnerMetadata: PartnerMetadata? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.description = description
        self.interconnect = interconnect
        self.router = router
        self.attachmentType = attachmentType
        self.edgeAvailabilityDomain = edgeAvailabilityDomain
        self.bandwidth = bandwidth
        self.vlanTag8021q = vlanTag8021q
        self.candidateSubnets = candidateSubnets
        self.mtu = mtu
        self.encryption = encryption
        self.ipsecInternalAddresses = ipsecInternalAddresses
        self.adminEnabled = adminEnabled
        self.state = state
        self.googleReferenceId = googleReferenceId
        self.pairingKey = pairingKey
        self.partnerMetadata = partnerMetadata
        self.labels = labels
    }

    /// Attachment type
    public enum AttachmentType: String, Codable, Sendable {
        case dedicated = "DEDICATED"
        case partner = "PARTNER"
        case partnerProvider = "PARTNER_PROVIDER"
    }

    /// Edge availability domain
    public enum EdgeAvailabilityDomain: String, Codable, Sendable {
        case availabilityDomain1 = "AVAILABILITY_DOMAIN_1"
        case availabilityDomain2 = "AVAILABILITY_DOMAIN_2"
        case availabilityDomainAny = "AVAILABILITY_DOMAIN_ANY"
    }

    /// Bandwidth options
    public enum Bandwidth: String, Codable, Sendable {
        case bps50m = "BPS_50M"
        case bps100m = "BPS_100M"
        case bps200m = "BPS_200M"
        case bps300m = "BPS_300M"
        case bps400m = "BPS_400M"
        case bps500m = "BPS_500M"
        case bps1g = "BPS_1G"
        case bps2g = "BPS_2G"
        case bps5g = "BPS_5G"
        case bps10g = "BPS_10G"
        case bps20g = "BPS_20G"
        case bps50g = "BPS_50G"
    }

    /// Encryption mode
    public enum Encryption: String, Codable, Sendable {
        case none = "NONE"
        case ipsec = "IPSEC"
    }

    /// Attachment state
    public enum State: String, Codable, Sendable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case active = "ACTIVE"
        case unprovisioned = "UNPROVISIONED"
        case pendingPartner = "PENDING_PARTNER"
        case partnerRequestReceived = "PARTNER_REQUEST_RECEIVED"
        case pendingCustomer = "PENDING_CUSTOMER"
        case defunct = "DEFUNCT"
    }

    /// Partner metadata
    public struct PartnerMetadata: Codable, Sendable, Equatable {
        public let partnerName: String?
        public let interconnectName: String?
        public let portalUrl: String?

        public init(
            partnerName: String? = nil,
            interconnectName: String? = nil,
            portalUrl: String? = nil
        ) {
            self.partnerName = partnerName
            self.interconnectName = interconnectName
            self.portalUrl = portalUrl
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/interconnectAttachments/\(name)"
    }

    /// Create dedicated attachment command
    public var createDedicatedCommand: String {
        var cmd = "gcloud compute interconnects attachments dedicated create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --router=\(router)"
        if let ic = interconnect {
            cmd += " --interconnect=\(ic)"
        }
        if let bw = bandwidth {
            cmd += " --bandwidth=\(bw.rawValue)"
        }
        if let vlan = vlanTag8021q {
            cmd += " --vlan=\(vlan)"
        }
        if let subnets = candidateSubnets, !subnets.isEmpty {
            cmd += " --candidate-subnets=\(subnets.joined(separator: ","))"
        }
        if let mtuVal = mtu {
            cmd += " --mtu=\(mtuVal)"
        }
        if let edge = edgeAvailabilityDomain {
            cmd += " --edge-availability-domain=\(edge.rawValue)"
        }
        if adminEnabled == true {
            cmd += " --admin-enabled"
        }
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        return cmd
    }

    /// Create partner attachment command
    public var createPartnerCommand: String {
        var cmd = "gcloud compute interconnects attachments partner create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --router=\(router)"
        if let edge = edgeAvailabilityDomain {
            cmd += " --edge-availability-domain=\(edge.rawValue)"
        }
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        if adminEnabled == true {
            cmd += " --admin-enabled"
        }
        return cmd
    }

    /// Describe attachment command
    public var describeCommand: String {
        "gcloud compute interconnects attachments describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// Delete attachment command
    public var deleteCommand: String {
        "gcloud compute interconnects attachments delete \(name) --project=\(projectID) --region=\(region)"
    }
}

// MARK: - Interconnect Location

/// A location where interconnects can be provisioned
public struct GoogleCloudInterconnectLocation: Codable, Sendable, Equatable {
    public let name: String
    public let description: String?
    public let city: String?
    public let continent: Continent?
    public let facilityProvider: String?
    public let facilityProviderFacilityId: String?
    public let address: String?
    public let availabilityZone: String?
    public let peeringdbFacilityId: String?
    public let status: Status?
    public let regionInfos: [RegionInfo]?

    public init(
        name: String,
        description: String? = nil,
        city: String? = nil,
        continent: Continent? = nil,
        facilityProvider: String? = nil,
        facilityProviderFacilityId: String? = nil,
        address: String? = nil,
        availabilityZone: String? = nil,
        peeringdbFacilityId: String? = nil,
        status: Status? = nil,
        regionInfos: [RegionInfo]? = nil
    ) {
        self.name = name
        self.description = description
        self.city = city
        self.continent = continent
        self.facilityProvider = facilityProvider
        self.facilityProviderFacilityId = facilityProviderFacilityId
        self.address = address
        self.availabilityZone = availabilityZone
        self.peeringdbFacilityId = peeringdbFacilityId
        self.status = status
        self.regionInfos = regionInfos
    }

    /// Continent
    public enum Continent: String, Codable, Sendable {
        case continentUnspecified = "CONTINENT_UNSPECIFIED"
        case africa = "AFRICA"
        case asiaPac = "ASIA_PAC"
        case cSouthAmerica = "C_SOUTH_AMERICA"
        case europe = "EUROPE"
        case northAmerica = "NORTH_AMERICA"
        case southAmerica = "SOUTH_AMERICA"
    }

    /// Status
    public enum Status: String, Codable, Sendable {
        case statusUnspecified = "STATUS_UNSPECIFIED"
        case available = "AVAILABLE"
        case closed = "CLOSED"
    }

    /// Region information
    public struct RegionInfo: Codable, Sendable, Equatable {
        public let region: String?
        public let expectedRttMs: Int64?

        public init(region: String? = nil, expectedRttMs: Int64? = nil) {
            self.region = region
            self.expectedRttMs = expectedRttMs
        }
    }
}

// MARK: - Cross-Cloud Interconnect

/// Cross-cloud interconnect for connecting to other cloud providers
public struct GoogleCloudCrossCloudInterconnect: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let location: String
    public let remoteCloudProvider: RemoteCloudProvider
    public let remoteCloud: RemoteCloudInfo
    public let requestedLinkCount: Int
    public let adminEnabled: Bool?
    public let state: State?
    public let googleReferenceId: String?

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        location: String,
        remoteCloudProvider: RemoteCloudProvider,
        remoteCloud: RemoteCloudInfo,
        requestedLinkCount: Int = 1,
        adminEnabled: Bool? = nil,
        state: State? = nil,
        googleReferenceId: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.location = location
        self.remoteCloudProvider = remoteCloudProvider
        self.remoteCloud = remoteCloud
        self.requestedLinkCount = requestedLinkCount
        self.adminEnabled = adminEnabled
        self.state = state
        self.googleReferenceId = googleReferenceId
    }

    /// Remote cloud provider
    public enum RemoteCloudProvider: String, Codable, Sendable {
        case aws = "AWS"
        case azure = "AZURE"
        case alibaba = "ALIBABA"
        case oracle = "ORACLE"
    }

    /// State
    public enum State: String, Codable, Sendable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case active = "ACTIVE"
        case unprovisioned = "UNPROVISIONED"
    }

    /// Remote cloud information
    public struct RemoteCloudInfo: Codable, Sendable, Equatable {
        public let remoteService: String?
        public let remoteLocation: String?
        public let remoteAccountId: String?

        public init(
            remoteService: String? = nil,
            remoteLocation: String? = nil,
            remoteAccountId: String? = nil
        ) {
            self.remoteService = remoteService
            self.remoteLocation = remoteLocation
            self.remoteAccountId = remoteAccountId
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/global/interconnects/\(name)"
    }

    /// Create cross-cloud interconnect command
    public var createCommand: String {
        var cmd = "gcloud compute interconnects create \(name) --project=\(projectID)"
        cmd += " --interconnect-type=DEDICATED"
        cmd += " --location=\(location)"
        cmd += " --link-type=LINK_TYPE_ETHERNET_10G_LR"
        cmd += " --requested-link-count=\(requestedLinkCount)"
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        if adminEnabled == true {
            cmd += " --admin-enabled"
        }
        return cmd
    }
}

// MARK: - Cloud Router for Interconnect

/// Cloud Router configuration for interconnect
public struct GoogleCloudRouterForInterconnect: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let network: String
    public let asn: Int?
    public let bgpKeepaliveInterval: Int?
    public let advertisedRoutePriority: Int?
    public let advertisedGroups: [AdvertisedGroup]?
    public let advertisedIpRanges: [AdvertisedIpRange]?

    public init(
        name: String,
        projectID: String,
        region: String,
        network: String,
        asn: Int? = nil,
        bgpKeepaliveInterval: Int? = nil,
        advertisedRoutePriority: Int? = nil,
        advertisedGroups: [AdvertisedGroup]? = nil,
        advertisedIpRanges: [AdvertisedIpRange]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.network = network
        self.asn = asn
        self.bgpKeepaliveInterval = bgpKeepaliveInterval
        self.advertisedRoutePriority = advertisedRoutePriority
        self.advertisedGroups = advertisedGroups
        self.advertisedIpRanges = advertisedIpRanges
    }

    /// Advertised group
    public enum AdvertisedGroup: String, Codable, Sendable {
        case allSubnets = "ALL_SUBNETS"
    }

    /// Advertised IP range
    public struct AdvertisedIpRange: Codable, Sendable, Equatable {
        public let range: String
        public let description: String?

        public init(range: String, description: String? = nil) {
            self.range = range
            self.description = description
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/routers/\(name)"
    }

    /// Create router command
    public var createCommand: String {
        var cmd = "gcloud compute routers create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --network=\(network)"
        if let asn = asn {
            cmd += " --asn=\(asn)"
        }
        if let keepalive = bgpKeepaliveInterval {
            cmd += " --bgp-keepalive-interval=\(keepalive)"
        }
        return cmd
    }

    /// Add BGP peer command
    public func addBgpPeerCommand(
        peerName: String,
        peerAsn: Int,
        interface: String,
        peerIpAddress: String
    ) -> String {
        var cmd = "gcloud compute routers add-bgp-peer \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --peer-name=\(peerName)"
        cmd += " --peer-asn=\(peerAsn)"
        cmd += " --interface=\(interface)"
        cmd += " --peer-ip-address=\(peerIpAddress)"
        return cmd
    }

    /// Add interface command
    public func addInterfaceCommand(
        interfaceName: String,
        interconnectAttachment: String,
        ipRange: String? = nil
    ) -> String {
        var cmd = "gcloud compute routers add-interface \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --interface-name=\(interfaceName)"
        cmd += " --interconnect-attachment=\(interconnectAttachment)"
        if let range = ipRange {
            cmd += " --ip-range=\(range)"
        }
        return cmd
    }

    /// Describe router command
    public var describeCommand: String {
        "gcloud compute routers describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// Get status command
    public var getStatusCommand: String {
        "gcloud compute routers get-status \(name) --project=\(projectID) --region=\(region)"
    }
}

// MARK: - Interconnect Operations

/// Operations for Cloud Interconnect
public struct InterconnectOperations: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Enable Compute API
    public var enableAPICommand: String {
        "gcloud services enable compute.googleapis.com --project=\(projectID)"
    }

    /// List interconnects
    public var listInterconnectsCommand: String {
        "gcloud compute interconnects list --project=\(projectID)"
    }

    /// List interconnect attachments
    public func listAttachmentsCommand(region: String? = nil) -> String {
        var cmd = "gcloud compute interconnects attachments list --project=\(projectID)"
        if let r = region {
            cmd += " --filter=\"region:\(r)\""
        }
        return cmd
    }

    /// List interconnect locations
    public var listLocationsCommand: String {
        "gcloud compute interconnects locations list"
    }

    /// Describe location
    public func describeLocationCommand(location: String) -> String {
        "gcloud compute interconnects locations describe \(location)"
    }

    /// Get diagnostics for interconnect
    public func getDiagnosticsCommand(interconnect: String) -> String {
        "gcloud compute interconnects get-diagnostics \(interconnect) --project=\(projectID)"
    }

    /// List Cloud Routers
    public func listRoutersCommand(region: String? = nil) -> String {
        var cmd = "gcloud compute routers list --project=\(projectID)"
        if let r = region {
            cmd += " --filter=\"region:\(r)\""
        }
        return cmd
    }

    /// IAM roles for Interconnect
    public enum InterconnectRole: String, Sendable {
        case computeNetworkAdmin = "roles/compute.networkAdmin"
        case computeNetworkViewer = "roles/compute.networkViewer"
    }

    /// Add IAM binding
    public func addIAMBindingCommand(member: String, role: InterconnectRole) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=\(role.rawValue)"
    }
}

// MARK: - DAIS Interconnect Template

/// DAIS template for Interconnect configurations
public struct DAISInterconnectTemplate: Sendable {
    public let projectID: String
    public let region: String

    public init(projectID: String, region: String = "us-central1") {
        self.projectID = projectID
        self.region = region
    }

    /// Create a dedicated interconnect
    public func dedicatedInterconnect(
        name: String,
        location: String,
        linkType: GoogleCloudInterconnect.LinkType = .linkTypeEthernet10gLr,
        linkCount: Int = 1,
        nocEmail: String,
        customerName: String
    ) -> GoogleCloudInterconnect {
        GoogleCloudInterconnect(
            name: name,
            projectID: projectID,
            description: "Dedicated Interconnect for \(customerName)",
            location: location,
            interconnectType: .dedicated,
            linkType: linkType,
            requestedLinkCount: linkCount,
            adminEnabled: true,
            nocContactEmail: nocEmail,
            customerName: customerName
        )
    }

    /// Create a Cloud Router for interconnect
    public func interconnectRouter(
        name: String,
        network: String,
        asn: Int = 16550
    ) -> GoogleCloudRouterForInterconnect {
        GoogleCloudRouterForInterconnect(
            name: name,
            projectID: projectID,
            region: region,
            network: network,
            asn: asn,
            bgpKeepaliveInterval: 20,
            advertisedGroups: [.allSubnets]
        )
    }

    /// Create a dedicated attachment for zone A
    public func dedicatedAttachmentZoneA(
        name: String,
        interconnect: String,
        router: String,
        vlanTag: Int,
        bandwidth: GoogleCloudInterconnectAttachment.Bandwidth = .bps10g
    ) -> GoogleCloudInterconnectAttachment {
        GoogleCloudInterconnectAttachment(
            name: name,
            projectID: projectID,
            region: region,
            description: "Zone A attachment",
            interconnect: interconnect,
            router: router,
            attachmentType: .dedicated,
            edgeAvailabilityDomain: .availabilityDomain1,
            bandwidth: bandwidth,
            vlanTag8021q: vlanTag,
            adminEnabled: true
        )
    }

    /// Create a dedicated attachment for zone B
    public func dedicatedAttachmentZoneB(
        name: String,
        interconnect: String,
        router: String,
        vlanTag: Int,
        bandwidth: GoogleCloudInterconnectAttachment.Bandwidth = .bps10g
    ) -> GoogleCloudInterconnectAttachment {
        GoogleCloudInterconnectAttachment(
            name: name,
            projectID: projectID,
            region: region,
            description: "Zone B attachment",
            interconnect: interconnect,
            router: router,
            attachmentType: .dedicated,
            edgeAvailabilityDomain: .availabilityDomain2,
            bandwidth: bandwidth,
            vlanTag8021q: vlanTag,
            adminEnabled: true
        )
    }

    /// Create a partner attachment
    public func partnerAttachment(
        name: String,
        router: String,
        edgeDomain: GoogleCloudInterconnectAttachment.EdgeAvailabilityDomain = .availabilityDomainAny
    ) -> GoogleCloudInterconnectAttachment {
        GoogleCloudInterconnectAttachment(
            name: name,
            projectID: projectID,
            region: region,
            description: "Partner Interconnect attachment",
            router: router,
            attachmentType: .partner,
            edgeAvailabilityDomain: edgeDomain,
            adminEnabled: true
        )
    }

    /// Operations helper
    public var operations: InterconnectOperations {
        InterconnectOperations(projectID: projectID)
    }

    /// Generate HA dedicated interconnect setup script
    public func haInterconnectSetupScript(
        interconnect1: String,
        interconnect2: String,
        location1: String,
        location2: String,
        network: String,
        nocEmail: String,
        customerName: String
    ) -> String {
        """
        #!/bin/bash
        # High Availability Dedicated Interconnect Setup
        # Project: \(projectID)
        # Region: \(region)

        set -e

        PROJECT="\(projectID)"
        REGION="\(region)"

        echo "=== Enabling APIs ==="
        gcloud services enable compute.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Creating Cloud Routers ==="
        # Router for metro 1
        gcloud compute routers create router-\(interconnect1) \\
            --project=$PROJECT \\
            --region=$REGION \\
            --network=\(network) \\
            --asn=16550

        # Router for metro 2
        gcloud compute routers create router-\(interconnect2) \\
            --project=$PROJECT \\
            --region=$REGION \\
            --network=\(network) \\
            --asn=16550

        echo ""
        echo "=== Creating Dedicated Interconnects ==="
        # Interconnect in metro 1
        gcloud compute interconnects create \(interconnect1) \\
            --project=$PROJECT \\
            --location=\(location1) \\
            --interconnect-type=DEDICATED \\
            --link-type=LINK_TYPE_ETHERNET_10G_LR \\
            --requested-link-count=1 \\
            --noc-contact-email=\(nocEmail) \\
            --customer-name="\(customerName)" \\
            --admin-enabled

        # Interconnect in metro 2
        gcloud compute interconnects create \(interconnect2) \\
            --project=$PROJECT \\
            --location=\(location2) \\
            --interconnect-type=DEDICATED \\
            --link-type=LINK_TYPE_ETHERNET_10G_LR \\
            --requested-link-count=1 \\
            --noc-contact-email=\(nocEmail) \\
            --customer-name="\(customerName)" \\
            --admin-enabled

        echo ""
        echo "=== Next Steps ==="
        echo "1. Submit LOA-CFA to your colocation provider"
        echo "2. Wait for physical cross-connect to be established"
        echo "3. Create VLAN attachments when interconnects are provisioned"
        echo ""
        echo "Check status with:"
        echo "gcloud compute interconnects describe \(interconnect1) --project=$PROJECT"
        echo "gcloud compute interconnects describe \(interconnect2) --project=$PROJECT"
        """
    }

    /// Generate partner interconnect setup script
    public func partnerInterconnectSetupScript(
        network: String,
        attachmentName: String
    ) -> String {
        """
        #!/bin/bash
        # Partner Interconnect Setup
        # Project: \(projectID)
        # Region: \(region)

        set -e

        PROJECT="\(projectID)"
        REGION="\(region)"

        echo "=== Enabling APIs ==="
        gcloud services enable compute.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Creating Cloud Router ==="
        gcloud compute routers create partner-router \\
            --project=$PROJECT \\
            --region=$REGION \\
            --network=\(network) \\
            --asn=16550

        echo ""
        echo "=== Creating Partner Attachment ==="
        gcloud compute interconnects attachments partner create \(attachmentName) \\
            --project=$PROJECT \\
            --region=$REGION \\
            --router=partner-router \\
            --edge-availability-domain=AVAILABILITY_DOMAIN_ANY

        echo ""
        echo "=== Getting Pairing Key ==="
        PAIRING_KEY=$(gcloud compute interconnects attachments describe \(attachmentName) \\
            --project=$PROJECT \\
            --region=$REGION \\
            --format="value(pairingKey)")

        echo "Pairing Key: $PAIRING_KEY"
        echo ""
        echo "=== Next Steps ==="
        echo "1. Provide the pairing key to your connectivity partner"
        echo "2. Wait for the partner to configure their side"
        echo "3. Once ready, the attachment status will show as ACTIVE"
        echo ""
        echo "Monitor status with:"
        echo "gcloud compute interconnects attachments describe \(attachmentName) --project=$PROJECT --region=$REGION"
        """
    }
}
