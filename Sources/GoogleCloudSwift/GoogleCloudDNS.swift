//
//  GoogleCloudDNS.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

// MARK: - Managed Zone

/// Represents a Cloud DNS managed zone.
///
/// A managed zone is a container for DNS records of the same DNS name suffix.
///
/// ## Example Usage
/// ```swift
/// let zone = GoogleCloudManagedZone(
///     name: "example-zone",
///     dnsName: "example.com.",
///     projectID: "my-project",
///     visibility: .public
/// )
/// print(zone.createCommand)
/// ```
public struct GoogleCloudManagedZone: Codable, Sendable, Equatable {
    /// Name of the managed zone (must be unique within project)
    public let name: String

    /// DNS name for this zone (must end with a dot)
    public let dnsName: String

    /// Project ID
    public let projectID: String

    /// Description of the zone
    public let description: String?

    /// Visibility of the zone
    public let visibility: Visibility

    /// Networks for private zones
    public let networks: [String]

    /// DNSSEC configuration
    public let dnssecConfig: DNSSECConfig?

    /// Forwarding configuration for private zones
    public let forwardingConfig: ForwardingConfig?

    /// Peering configuration
    public let peeringConfig: PeeringConfig?

    /// Cloud Logging configuration
    public let cloudLoggingConfig: CloudLoggingConfig?

    /// Labels for the zone
    public let labels: [String: String]

    public init(
        name: String,
        dnsName: String,
        projectID: String,
        description: String? = nil,
        visibility: Visibility = .public,
        networks: [String] = [],
        dnssecConfig: DNSSECConfig? = nil,
        forwardingConfig: ForwardingConfig? = nil,
        peeringConfig: PeeringConfig? = nil,
        cloudLoggingConfig: CloudLoggingConfig? = nil,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.dnsName = dnsName.hasSuffix(".") ? dnsName : "\(dnsName)."
        self.projectID = projectID
        self.description = description
        self.visibility = visibility
        self.networks = networks
        self.dnssecConfig = dnssecConfig
        self.forwardingConfig = forwardingConfig
        self.peeringConfig = peeringConfig
        self.cloudLoggingConfig = cloudLoggingConfig
        self.labels = labels
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/managedZones/\(name)"
    }

    /// gcloud command to create this zone
    public var createCommand: String {
        var cmd = "gcloud dns managed-zones create \(name)"
        cmd += " --dns-name=\(dnsName)"
        cmd += " --project=\(projectID)"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        switch visibility {
        case .public:
            cmd += " --visibility=public"
        case .private:
            cmd += " --visibility=private"
            if !networks.isEmpty {
                cmd += " --networks=\(networks.joined(separator: ","))"
            }
        }

        if let dnssec = dnssecConfig, dnssec.state == .on {
            cmd += " --dnssec-state=on"
        }

        if let forwarding = forwardingConfig, !forwarding.targetNameServers.isEmpty {
            let targets = forwarding.targetNameServers.map { $0.ipv4Address }.joined(separator: ",")
            cmd += " --forwarding-targets=\(targets)"
        }

        if !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// gcloud command to delete this zone
    public var deleteCommand: String {
        "gcloud dns managed-zones delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this zone
    public var describeCommand: String {
        "gcloud dns managed-zones describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list zones
    public static func listCommand(projectID: String) -> String {
        "gcloud dns managed-zones list --project=\(projectID)"
    }

    /// gcloud command to update this zone
    public func updateCommand(newDescription: String? = nil) -> String {
        var cmd = "gcloud dns managed-zones update \(name)"
        cmd += " --project=\(projectID)"
        if let desc = newDescription {
            cmd += " --description=\"\(desc)\""
        }
        return cmd
    }

    /// Zone visibility
    public enum Visibility: String, Codable, Sendable {
        case `public` = "public"
        case `private` = "private"
    }

    /// DNSSEC configuration
    public struct DNSSECConfig: Codable, Sendable, Equatable {
        public let state: State
        public let nonExistence: NonExistence?

        public init(state: State, nonExistence: NonExistence? = nil) {
            self.state = state
            self.nonExistence = nonExistence
        }

        public enum State: String, Codable, Sendable {
            case on = "on"
            case off = "off"
            case transfer = "transfer"
        }

        public enum NonExistence: String, Codable, Sendable {
            case nsec = "nsec"
            case nsec3 = "nsec3"
        }
    }

    /// Forwarding configuration
    public struct ForwardingConfig: Codable, Sendable, Equatable {
        public let targetNameServers: [NameServerTarget]

        public init(targetNameServers: [NameServerTarget]) {
            self.targetNameServers = targetNameServers
        }

        public struct NameServerTarget: Codable, Sendable, Equatable {
            public let ipv4Address: String
            public let forwardingPath: ForwardingPath?

            public init(ipv4Address: String, forwardingPath: ForwardingPath? = nil) {
                self.ipv4Address = ipv4Address
                self.forwardingPath = forwardingPath
            }

            public enum ForwardingPath: String, Codable, Sendable {
                case `default` = "default"
                case `private` = "private"
            }
        }
    }

    /// Peering configuration
    public struct PeeringConfig: Codable, Sendable, Equatable {
        public let targetNetwork: String

        public init(targetNetwork: String) {
            self.targetNetwork = targetNetwork
        }
    }

    /// Cloud Logging configuration
    public struct CloudLoggingConfig: Codable, Sendable, Equatable {
        public let enableLogging: Bool

        public init(enableLogging: Bool) {
            self.enableLogging = enableLogging
        }
    }
}

// MARK: - Resource Record Set

/// Represents a DNS resource record set.
///
/// A record set is a collection of DNS records of the same type and name.
///
/// ## Example Usage
/// ```swift
/// let record = GoogleCloudDNSRecord(
///     name: "www.example.com.",
///     type: .a,
///     ttl: 300,
///     rrdatas: ["192.0.2.1"]
/// )
/// ```
public struct GoogleCloudDNSRecord: Codable, Sendable, Equatable {
    /// Fully qualified domain name (must end with a dot)
    public let name: String

    /// Record type
    public let type: RecordType

    /// Time to live in seconds
    public let ttl: Int

    /// Record data (format depends on type)
    public let rrdatas: [String]

    /// Routing policy (for weighted/geo routing)
    public let routingPolicy: RoutingPolicy?

    public init(
        name: String,
        type: RecordType,
        ttl: Int = 300,
        rrdatas: [String],
        routingPolicy: RoutingPolicy? = nil
    ) {
        self.name = name.hasSuffix(".") ? name : "\(name)."
        self.type = type
        self.ttl = ttl
        self.rrdatas = rrdatas
        self.routingPolicy = routingPolicy
    }

    /// DNS record types
    public enum RecordType: String, Codable, Sendable {
        case a = "A"
        case aaaa = "AAAA"
        case cname = "CNAME"
        case mx = "MX"
        case txt = "TXT"
        case ns = "NS"
        case soa = "SOA"
        case srv = "SRV"
        case caa = "CAA"
        case ptr = "PTR"
        case spf = "SPF"
        case naptr = "NAPTR"
        case ds = "DS"
        case dnskey = "DNSKEY"
        case ipseckey = "IPSECKEY"
        case sshfp = "SSHFP"
        case tlsa = "TLSA"
    }

    /// Routing policy for advanced DNS routing
    public struct RoutingPolicy: Codable, Sendable, Equatable {
        public let wrr: WRRPolicy?
        public let geo: GeoPolicy?

        public init(wrr: WRRPolicy? = nil, geo: GeoPolicy? = nil) {
            self.wrr = wrr
            self.geo = geo
        }

        /// Weighted round-robin policy
        public struct WRRPolicy: Codable, Sendable, Equatable {
            public let items: [WRRItem]

            public init(items: [WRRItem]) {
                self.items = items
            }

            public struct WRRItem: Codable, Sendable, Equatable {
                public let weight: Double
                public let rrdatas: [String]

                public init(weight: Double, rrdatas: [String]) {
                    self.weight = weight
                    self.rrdatas = rrdatas
                }
            }
        }

        /// Geolocation-based policy
        public struct GeoPolicy: Codable, Sendable, Equatable {
            public let items: [GeoItem]

            public init(items: [GeoItem]) {
                self.items = items
            }

            public struct GeoItem: Codable, Sendable, Equatable {
                public let location: String
                public let rrdatas: [String]

                public init(location: String, rrdatas: [String]) {
                    self.location = location
                    self.rrdatas = rrdatas
                }
            }
        }
    }
}

// MARK: - Record Set Transaction

/// Manages atomic changes to DNS record sets.
///
/// Allows adding and removing multiple records in a single transaction.
public struct GoogleCloudDNSTransaction: Sendable {
    /// Zone name
    public let zoneName: String

    /// Project ID
    public let projectID: String

    /// Records to add
    public var additions: [GoogleCloudDNSRecord]

    /// Records to remove
    public var deletions: [GoogleCloudDNSRecord]

    public init(
        zoneName: String,
        projectID: String,
        additions: [GoogleCloudDNSRecord] = [],
        deletions: [GoogleCloudDNSRecord] = []
    ) {
        self.zoneName = zoneName
        self.projectID = projectID
        self.additions = additions
        self.deletions = deletions
    }

    /// gcloud command to start a transaction
    public var startCommand: String {
        "gcloud dns record-sets transaction start --zone=\(zoneName) --project=\(projectID)"
    }

    /// gcloud command to execute the transaction
    public var executeCommand: String {
        "gcloud dns record-sets transaction execute --zone=\(zoneName) --project=\(projectID)"
    }

    /// gcloud command to abort the transaction
    public var abortCommand: String {
        "gcloud dns record-sets transaction abort --zone=\(zoneName) --project=\(projectID)"
    }

    /// gcloud command to describe the transaction
    public var describeCommand: String {
        "gcloud dns record-sets transaction describe --zone=\(zoneName) --project=\(projectID)"
    }

    /// Generate add commands for all additions
    public var addCommands: [String] {
        additions.map { record in
            var cmd = "gcloud dns record-sets transaction add"
            cmd += " --zone=\(zoneName)"
            cmd += " --project=\(projectID)"
            cmd += " --name=\(record.name)"
            cmd += " --type=\(record.type.rawValue)"
            cmd += " --ttl=\(record.ttl)"
            cmd += " \(record.rrdatas.joined(separator: " "))"
            return cmd
        }
    }

    /// Generate remove commands for all deletions
    public var removeCommands: [String] {
        deletions.map { record in
            var cmd = "gcloud dns record-sets transaction remove"
            cmd += " --zone=\(zoneName)"
            cmd += " --project=\(projectID)"
            cmd += " --name=\(record.name)"
            cmd += " --type=\(record.type.rawValue)"
            cmd += " --ttl=\(record.ttl)"
            cmd += " \(record.rrdatas.joined(separator: " "))"
            return cmd
        }
    }

    /// Generate a complete transaction script
    public var transactionScript: String {
        var script = """
        #!/bin/bash
        # DNS Transaction Script
        # Zone: \(zoneName)
        # Project: \(projectID)

        set -e

        echo "Starting DNS transaction..."
        \(startCommand)

        """

        if !deletions.isEmpty {
            script += "\necho \"Removing records...\"\n"
            script += removeCommands.joined(separator: "\n")
            script += "\n"
        }

        if !additions.isEmpty {
            script += "\necho \"Adding records...\"\n"
            script += addCommands.joined(separator: "\n")
            script += "\n"
        }

        script += """

        echo "Executing transaction..."
        \(executeCommand)

        echo "Transaction complete!"
        """

        return script
    }
}

// MARK: - DNS Record Commands

/// Helper for managing individual DNS records.
public enum GoogleCloudDNSRecordCommands {
    /// Create or update a record set
    public static func createCommand(
        zoneName: String,
        projectID: String,
        record: GoogleCloudDNSRecord
    ) -> String {
        var cmd = "gcloud dns record-sets create \(record.name)"
        cmd += " --zone=\(zoneName)"
        cmd += " --project=\(projectID)"
        cmd += " --type=\(record.type.rawValue)"
        cmd += " --ttl=\(record.ttl)"
        cmd += " --rrdatas=\(record.rrdatas.joined(separator: ","))"
        return cmd
    }

    /// Update an existing record set
    public static func updateCommand(
        zoneName: String,
        projectID: String,
        record: GoogleCloudDNSRecord
    ) -> String {
        var cmd = "gcloud dns record-sets update \(record.name)"
        cmd += " --zone=\(zoneName)"
        cmd += " --project=\(projectID)"
        cmd += " --type=\(record.type.rawValue)"
        cmd += " --ttl=\(record.ttl)"
        cmd += " --rrdatas=\(record.rrdatas.joined(separator: ","))"
        return cmd
    }

    /// Delete a record set
    public static func deleteCommand(
        zoneName: String,
        projectID: String,
        name: String,
        type: GoogleCloudDNSRecord.RecordType
    ) -> String {
        "gcloud dns record-sets delete \(name) --zone=\(zoneName) --project=\(projectID) --type=\(type.rawValue) --quiet"
    }

    /// Describe a record set
    public static func describeCommand(
        zoneName: String,
        projectID: String,
        name: String,
        type: GoogleCloudDNSRecord.RecordType
    ) -> String {
        "gcloud dns record-sets describe \(name) --zone=\(zoneName) --project=\(projectID) --type=\(type.rawValue)"
    }

    /// List all record sets in a zone
    public static func listCommand(zoneName: String, projectID: String) -> String {
        "gcloud dns record-sets list --zone=\(zoneName) --project=\(projectID)"
    }

    /// List record sets with filter
    public static func listCommand(
        zoneName: String,
        projectID: String,
        filter: String
    ) -> String {
        "gcloud dns record-sets list --zone=\(zoneName) --project=\(projectID) --filter=\"\(filter)\""
    }
}

// MARK: - DNS Policy

/// Represents a DNS policy for private zones.
///
/// DNS policies define how DNS queries are handled within a VPC network.
public struct GoogleCloudDNSPolicy: Codable, Sendable, Equatable {
    /// Name of the policy
    public let name: String

    /// Project ID
    public let projectID: String

    /// Description
    public let description: String?

    /// Enable inbound forwarding
    public let enableInboundForwarding: Bool

    /// Enable logging
    public let enableLogging: Bool

    /// Networks this policy applies to
    public let networks: [String]

    /// Alternative name server configuration
    public let alternativeNameServerConfig: AlternativeNameServerConfig?

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        enableInboundForwarding: Bool = false,
        enableLogging: Bool = false,
        networks: [String] = [],
        alternativeNameServerConfig: AlternativeNameServerConfig? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.enableInboundForwarding = enableInboundForwarding
        self.enableLogging = enableLogging
        self.networks = networks
        self.alternativeNameServerConfig = alternativeNameServerConfig
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/policies/\(name)"
    }

    /// gcloud command to create this policy
    public var createCommand: String {
        var cmd = "gcloud dns policies create \(name)"
        cmd += " --project=\(projectID)"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if enableInboundForwarding {
            cmd += " --enable-inbound-forwarding"
        }

        if enableLogging {
            cmd += " --enable-logging"
        }

        if !networks.isEmpty {
            cmd += " --networks=\(networks.joined(separator: ","))"
        }

        if let altNS = alternativeNameServerConfig, !altNS.targetNameServers.isEmpty {
            let servers = altNS.targetNameServers.joined(separator: ",")
            cmd += " --alternative-name-servers=\(servers)"
        }

        return cmd
    }

    /// gcloud command to delete this policy
    public var deleteCommand: String {
        "gcloud dns policies delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this policy
    public var describeCommand: String {
        "gcloud dns policies describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list policies
    public static func listCommand(projectID: String) -> String {
        "gcloud dns policies list --project=\(projectID)"
    }

    /// gcloud command to update this policy
    public var updateCommand: String {
        var cmd = "gcloud dns policies update \(name)"
        cmd += " --project=\(projectID)"
        if enableLogging {
            cmd += " --enable-logging"
        } else {
            cmd += " --no-enable-logging"
        }
        return cmd
    }

    /// Alternative name server configuration
    public struct AlternativeNameServerConfig: Codable, Sendable, Equatable {
        public let targetNameServers: [String]

        public init(targetNameServers: [String]) {
            self.targetNameServers = targetNameServers
        }
    }
}

// MARK: - Response Policy

/// Represents a DNS response policy for DNS firewall.
///
/// Response policies allow you to modify DNS responses for specific queries.
public struct GoogleCloudDNSResponsePolicy: Codable, Sendable, Equatable {
    /// Name of the response policy
    public let name: String

    /// Project ID
    public let projectID: String

    /// Description
    public let description: String?

    /// Networks this policy applies to
    public let networks: [String]

    /// GKE clusters this policy applies to
    public let gkeClusters: [String]

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        networks: [String] = [],
        gkeClusters: [String] = []
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.networks = networks
        self.gkeClusters = gkeClusters
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/responsePolicies/\(name)"
    }

    /// gcloud command to create this response policy
    public var createCommand: String {
        var cmd = "gcloud dns response-policies create \(name)"
        cmd += " --project=\(projectID)"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if !networks.isEmpty {
            cmd += " --networks=\(networks.joined(separator: ","))"
        }

        if !gkeClusters.isEmpty {
            cmd += " --gke-clusters=\(gkeClusters.joined(separator: ","))"
        }

        return cmd
    }

    /// gcloud command to delete this response policy
    public var deleteCommand: String {
        "gcloud dns response-policies delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this response policy
    public var describeCommand: String {
        "gcloud dns response-policies describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list response policies
    public static func listCommand(projectID: String) -> String {
        "gcloud dns response-policies list --project=\(projectID)"
    }
}

// MARK: - Response Policy Rule

/// Represents a rule in a DNS response policy.
public struct GoogleCloudDNSResponsePolicyRule: Codable, Sendable, Equatable {
    /// Name of the rule
    public let name: String

    /// Response policy name
    public let responsePolicyName: String

    /// Project ID
    public let projectID: String

    /// DNS name to match
    public let dnsName: String

    /// Behavior when matched
    public let behavior: Behavior

    /// Local data for passthrough or override
    public let localData: LocalData?

    public init(
        name: String,
        responsePolicyName: String,
        projectID: String,
        dnsName: String,
        behavior: Behavior,
        localData: LocalData? = nil
    ) {
        self.name = name
        self.responsePolicyName = responsePolicyName
        self.projectID = projectID
        self.dnsName = dnsName.hasSuffix(".") ? dnsName : "\(dnsName)."
        self.behavior = behavior
        self.localData = localData
    }

    /// gcloud command to create this rule
    public var createCommand: String {
        var cmd = "gcloud dns response-policies rules create \(name)"
        cmd += " --response-policy=\(responsePolicyName)"
        cmd += " --project=\(projectID)"
        cmd += " --dns-name=\(dnsName)"

        switch behavior {
        case .bypassResponsePolicy:
            cmd += " --behavior=bypassResponsePolicy"
        case .localData:
            if let data = localData, !data.localDatas.isEmpty {
                let rrdata = data.localDatas.map { "\($0.type.rawValue):\($0.ttl):\($0.rrdatas.joined(separator: ","))" }.joined(separator: ";")
                cmd += " --local-data=\(rrdata)"
            }
        }

        return cmd
    }

    /// gcloud command to delete this rule
    public var deleteCommand: String {
        "gcloud dns response-policies rules delete \(name) --response-policy=\(responsePolicyName) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this rule
    public var describeCommand: String {
        "gcloud dns response-policies rules describe \(name) --response-policy=\(responsePolicyName) --project=\(projectID)"
    }

    /// gcloud command to list rules
    public static func listCommand(responsePolicyName: String, projectID: String) -> String {
        "gcloud dns response-policies rules list --response-policy=\(responsePolicyName) --project=\(projectID)"
    }

    /// Rule behavior
    public enum Behavior: String, Codable, Sendable {
        case bypassResponsePolicy = "bypassResponsePolicy"
        case localData = "localData"
    }

    /// Local data for DNS responses
    public struct LocalData: Codable, Sendable, Equatable {
        public let localDatas: [LocalDataEntry]

        public init(localDatas: [LocalDataEntry]) {
            self.localDatas = localDatas
        }

        public struct LocalDataEntry: Codable, Sendable, Equatable {
            public let name: String
            public let type: GoogleCloudDNSRecord.RecordType
            public let ttl: Int
            public let rrdatas: [String]

            public init(name: String, type: GoogleCloudDNSRecord.RecordType, ttl: Int, rrdatas: [String]) {
                self.name = name
                self.type = type
                self.ttl = ttl
                self.rrdatas = rrdatas
            }
        }
    }
}

// MARK: - Common DNS Records

/// Factory for creating common DNS record configurations.
public enum CommonDNSRecords {
    /// Create an A record
    public static func aRecord(name: String, ipAddresses: [String], ttl: Int = 300) -> GoogleCloudDNSRecord {
        GoogleCloudDNSRecord(name: name, type: .a, ttl: ttl, rrdatas: ipAddresses)
    }

    /// Create an AAAA record (IPv6)
    public static func aaaaRecord(name: String, ipv6Addresses: [String], ttl: Int = 300) -> GoogleCloudDNSRecord {
        GoogleCloudDNSRecord(name: name, type: .aaaa, ttl: ttl, rrdatas: ipv6Addresses)
    }

    /// Create a CNAME record
    public static func cnameRecord(name: String, target: String, ttl: Int = 300) -> GoogleCloudDNSRecord {
        let canonicalTarget = target.hasSuffix(".") ? target : "\(target)."
        return GoogleCloudDNSRecord(name: name, type: .cname, ttl: ttl, rrdatas: [canonicalTarget])
    }

    /// Create an MX record
    public static func mxRecord(name: String, mailServers: [(priority: Int, server: String)], ttl: Int = 3600) -> GoogleCloudDNSRecord {
        let rrdatas = mailServers.map { "\($0.priority) \($0.server.hasSuffix(".") ? $0.server : "\($0.server).")" }
        return GoogleCloudDNSRecord(name: name, type: .mx, ttl: ttl, rrdatas: rrdatas)
    }

    /// Create a TXT record
    public static func txtRecord(name: String, values: [String], ttl: Int = 300) -> GoogleCloudDNSRecord {
        let rrdatas = values.map { "\"\($0)\"" }
        return GoogleCloudDNSRecord(name: name, type: .txt, ttl: ttl, rrdatas: rrdatas)
    }

    /// Create an NS record
    public static func nsRecord(name: String, nameServers: [String], ttl: Int = 21600) -> GoogleCloudDNSRecord {
        let rrdatas = nameServers.map { $0.hasSuffix(".") ? $0 : "\($0)." }
        return GoogleCloudDNSRecord(name: name, type: .ns, ttl: ttl, rrdatas: rrdatas)
    }

    /// Create an SRV record
    public static func srvRecord(
        name: String,
        services: [(priority: Int, weight: Int, port: Int, target: String)],
        ttl: Int = 300
    ) -> GoogleCloudDNSRecord {
        let rrdatas = services.map { "\($0.priority) \($0.weight) \($0.port) \($0.target.hasSuffix(".") ? $0.target : "\($0.target).")" }
        return GoogleCloudDNSRecord(name: name, type: .srv, ttl: ttl, rrdatas: rrdatas)
    }

    /// Create a CAA record
    public static func caaRecord(
        name: String,
        entries: [(flags: Int, tag: String, value: String)],
        ttl: Int = 3600
    ) -> GoogleCloudDNSRecord {
        let rrdatas = entries.map { "\($0.flags) \($0.tag) \"\($0.value)\"" }
        return GoogleCloudDNSRecord(name: name, type: .caa, ttl: ttl, rrdatas: rrdatas)
    }

    /// Create a PTR record (reverse DNS)
    public static func ptrRecord(name: String, hostname: String, ttl: Int = 300) -> GoogleCloudDNSRecord {
        let canonicalHostname = hostname.hasSuffix(".") ? hostname : "\(hostname)."
        return GoogleCloudDNSRecord(name: name, type: .ptr, ttl: ttl, rrdatas: [canonicalHostname])
    }

    /// Create SPF record (as TXT)
    public static func spfRecord(name: String, spfValue: String, ttl: Int = 3600) -> GoogleCloudDNSRecord {
        return txtRecord(name: name, values: [spfValue], ttl: ttl)
    }

    /// Create DKIM record (as TXT)
    public static func dkimRecord(selector: String, domain: String, publicKey: String, ttl: Int = 3600) -> GoogleCloudDNSRecord {
        let name = "\(selector)._domainkey.\(domain)"
        let value = "v=DKIM1; k=rsa; p=\(publicKey)"
        return txtRecord(name: name, values: [value], ttl: ttl)
    }

    /// Create DMARC record (as TXT)
    public static func dmarcRecord(
        domain: String,
        policy: String = "none",
        rua: String? = nil,
        ruf: String? = nil,
        pct: Int = 100,
        ttl: Int = 3600
    ) -> GoogleCloudDNSRecord {
        var value = "v=DMARC1; p=\(policy); pct=\(pct)"
        if let rua = rua {
            value += "; rua=mailto:\(rua)"
        }
        if let ruf = ruf {
            value += "; ruf=mailto:\(ruf)"
        }
        return txtRecord(name: "_dmarc.\(domain)", values: [value], ttl: ttl)
    }

    /// Google Workspace MX records
    public static func googleWorkspaceMX(domain: String, ttl: Int = 3600) -> GoogleCloudDNSRecord {
        return mxRecord(name: domain, mailServers: [
            (1, "aspmx.l.google.com"),
            (5, "alt1.aspmx.l.google.com"),
            (5, "alt2.aspmx.l.google.com"),
            (10, "alt3.aspmx.l.google.com"),
            (10, "alt4.aspmx.l.google.com")
        ], ttl: ttl)
    }

    /// Google site verification TXT record
    public static func googleSiteVerification(domain: String, verificationCode: String, ttl: Int = 300) -> GoogleCloudDNSRecord {
        return txtRecord(name: domain, values: ["google-site-verification=\(verificationCode)"], ttl: ttl)
    }
}

// MARK: - DAIS DNS Templates

/// Predefined DNS configurations for DAIS deployments.
public enum DAISDNSTemplate {
    /// Create a managed zone for DAIS
    public static func managedZone(
        projectID: String,
        deploymentName: String,
        domain: String,
        visibility: GoogleCloudManagedZone.Visibility = .public
    ) -> GoogleCloudManagedZone {
        GoogleCloudManagedZone(
            name: "\(deploymentName)-zone",
            dnsName: domain,
            projectID: projectID,
            description: "DNS zone for DAIS deployment \(deploymentName)",
            visibility: visibility,
            dnssecConfig: visibility == .public ? .init(state: .on) : nil
        )
    }

    /// Create a private zone for internal services
    public static func privateZone(
        projectID: String,
        deploymentName: String,
        domain: String,
        networks: [String]
    ) -> GoogleCloudManagedZone {
        GoogleCloudManagedZone(
            name: "\(deploymentName)-internal",
            dnsName: domain,
            projectID: projectID,
            description: "Internal DNS zone for DAIS deployment",
            visibility: .private,
            networks: networks
        )
    }

    /// Create API endpoint A record
    public static func apiRecord(
        domain: String,
        ipAddress: String,
        ttl: Int = 300
    ) -> GoogleCloudDNSRecord {
        CommonDNSRecords.aRecord(name: "api.\(domain)", ipAddresses: [ipAddress], ttl: ttl)
    }

    /// Create gRPC endpoint A record
    public static func grpcRecord(
        domain: String,
        ipAddress: String,
        ttl: Int = 300
    ) -> GoogleCloudDNSRecord {
        CommonDNSRecords.aRecord(name: "grpc.\(domain)", ipAddresses: [ipAddress], ttl: ttl)
    }

    /// Create wildcard CNAME for services
    public static func wildcardCname(
        domain: String,
        target: String,
        ttl: Int = 300
    ) -> GoogleCloudDNSRecord {
        CommonDNSRecords.cnameRecord(name: "*.\(domain)", target: target, ttl: ttl)
    }

    /// Create gRPC SRV record for service discovery
    public static func grpcSrvRecord(
        domain: String,
        serviceName: String,
        targets: [(priority: Int, weight: Int, port: Int, target: String)],
        ttl: Int = 300
    ) -> GoogleCloudDNSRecord {
        CommonDNSRecords.srvRecord(
            name: "_grpc._tcp.\(serviceName).\(domain)",
            services: targets,
            ttl: ttl
        )
    }

    /// Create health check endpoint CNAME
    public static func healthCheckRecord(
        domain: String,
        target: String,
        ttl: Int = 60
    ) -> GoogleCloudDNSRecord {
        CommonDNSRecords.cnameRecord(name: "health.\(domain)", target: target, ttl: ttl)
    }

    /// Create DNS policy for private resolution
    public static func internalPolicy(
        projectID: String,
        deploymentName: String,
        networks: [String]
    ) -> GoogleCloudDNSPolicy {
        GoogleCloudDNSPolicy(
            name: "\(deploymentName)-internal-policy",
            projectID: projectID,
            description: "DNS policy for DAIS internal services",
            enableInboundForwarding: true,
            enableLogging: true,
            networks: networks
        )
    }

    /// Generate a complete DNS setup script
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        domain: String,
        apiIP: String,
        grpcIP: String
    ) -> String {
        let zone = managedZone(projectID: projectID, deploymentName: deploymentName, domain: domain)
        let apiRecord = apiRecord(domain: domain, ipAddress: apiIP)
        let grpcRecord = grpcRecord(domain: domain, ipAddress: grpcIP)

        return """
        #!/bin/bash
        # DAIS DNS Setup Script
        # Deployment: \(deploymentName)
        # Domain: \(domain)

        set -e

        echo "========================================"
        echo "DAIS DNS Configuration"
        echo "========================================"

        # Create managed zone
        echo "Creating managed zone..."
        \(zone.createCommand)

        # Start DNS transaction
        echo "Starting DNS transaction..."
        gcloud dns record-sets transaction start --zone=\(zone.name) --project=\(projectID)

        # Add API record
        echo "Adding API record..."
        gcloud dns record-sets transaction add \\
            --zone=\(zone.name) \\
            --project=\(projectID) \\
            --name=\(apiRecord.name) \\
            --type=\(apiRecord.type.rawValue) \\
            --ttl=\(apiRecord.ttl) \\
            \(apiRecord.rrdatas.joined(separator: " "))

        # Add gRPC record
        echo "Adding gRPC record..."
        gcloud dns record-sets transaction add \\
            --zone=\(zone.name) \\
            --project=\(projectID) \\
            --name=\(grpcRecord.name) \\
            --type=\(grpcRecord.type.rawValue) \\
            --ttl=\(grpcRecord.ttl) \\
            \(grpcRecord.rrdatas.joined(separator: " "))

        # Execute transaction
        echo "Executing transaction..."
        gcloud dns record-sets transaction execute --zone=\(zone.name) --project=\(projectID)

        echo ""
        echo "DNS setup complete!"
        echo ""
        echo "Zone: \(zone.name)"
        echo "Domain: \(domain)"
        echo "API: api.\(domain) -> \(apiIP)"
        echo "gRPC: grpc.\(domain) -> \(grpcIP)"
        echo ""
        echo "Name servers:"
        gcloud dns managed-zones describe \(zone.name) --project=\(projectID) --format="value(nameServers)"
        """
    }

    /// Generate a teardown script
    public static func teardownScript(
        projectID: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS DNS Teardown Script
        # WARNING: This will delete all DNS records and zones!

        set -e

        ZONE_NAME="\(deploymentName)-zone"

        echo "Deleting all record sets (except NS and SOA)..."
        gcloud dns record-sets list --zone=$ZONE_NAME --project=\(projectID) \\
            --filter="type != NS AND type != SOA" \\
            --format="csv[no-heading](name,type,ttl,rrdatas)" | \\
        while IFS=',' read -r name type ttl rrdatas; do
            if [ -n "$name" ]; then
                echo "Deleting $type record for $name..."
                gcloud dns record-sets delete "$name" \\
                    --zone=$ZONE_NAME \\
                    --project=\(projectID) \\
                    --type="$type" \\
                    --quiet || true
            fi
        done

        echo "Deleting managed zone..."
        gcloud dns managed-zones delete $ZONE_NAME --project=\(projectID) --quiet || true

        # Delete internal zone if exists
        gcloud dns managed-zones delete \(deploymentName)-internal --project=\(projectID) --quiet || true

        # Delete DNS policy if exists
        gcloud dns policies delete \(deploymentName)-internal-policy --project=\(projectID) --quiet || true

        echo "DNS teardown complete!"
        """
    }
}

// MARK: - DNSSEC Operations

/// DNSSEC management operations.
public enum DNSSECOperations {
    /// Get DNSSEC DS records for domain registrar
    public static func getDSRecordsCommand(zoneName: String, projectID: String) -> String {
        "gcloud dns dnskeys list --zone=\(zoneName) --project=\(projectID) --filter=\"type=keySigning\" --format=\"table(dsRecord)\""
    }

    /// Enable DNSSEC for a zone
    public static func enableCommand(zoneName: String, projectID: String) -> String {
        "gcloud dns managed-zones update \(zoneName) --project=\(projectID) --dnssec-state=on"
    }

    /// Disable DNSSEC for a zone
    public static func disableCommand(zoneName: String, projectID: String) -> String {
        "gcloud dns managed-zones update \(zoneName) --project=\(projectID) --dnssec-state=off"
    }

    /// List DNSKEY records
    public static func listKeysCommand(zoneName: String, projectID: String) -> String {
        "gcloud dns dnskeys list --zone=\(zoneName) --project=\(projectID)"
    }
}

// MARK: - DNS Operations

/// Common DNS operations.
public enum DNSOperations {
    /// Export zone to BIND format
    public static func exportCommand(zoneName: String, projectID: String, outputFile: String) -> String {
        "gcloud dns record-sets export \(outputFile) --zone=\(zoneName) --project=\(projectID) --zone-file-format"
    }

    /// Import zone from BIND format
    public static func importCommand(zoneName: String, projectID: String, inputFile: String) -> String {
        "gcloud dns record-sets import \(inputFile) --zone=\(zoneName) --project=\(projectID) --zone-file-format"
    }

    /// Get name servers for a zone
    public static func getNameServersCommand(zoneName: String, projectID: String) -> String {
        "gcloud dns managed-zones describe \(zoneName) --project=\(projectID) --format=\"value(nameServers)\""
    }

    /// Check DNS propagation
    public static func checkPropagationCommand(domain: String, recordType: String = "A") -> String {
        "dig @8.8.8.8 \(domain) \(recordType) +short"
    }

    /// Flush DNS cache (local)
    public static let flushLocalCacheCommand = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
}
