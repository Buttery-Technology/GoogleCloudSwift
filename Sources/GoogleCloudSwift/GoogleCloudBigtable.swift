import Foundation

// MARK: - Bigtable Instance

/// Represents a Cloud Bigtable instance
public struct GoogleCloudBigtableInstance: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let displayName: String
    public let instanceType: InstanceType
    public let labels: [String: String]?
    public let state: InstanceState?

    public enum InstanceType: String, Codable, Sendable, Equatable {
        case production = "PRODUCTION"
        case development = "DEVELOPMENT"
    }

    public enum InstanceState: String, Codable, Sendable, Equatable {
        case stateNotKnown = "STATE_NOT_KNOWN"
        case ready = "READY"
        case creating = "CREATING"
    }

    public init(
        name: String,
        projectID: String,
        displayName: String,
        instanceType: InstanceType = .production,
        labels: [String: String]? = nil,
        state: InstanceState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.displayName = displayName
        self.instanceType = instanceType
        self.labels = labels
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(name)"
    }

    /// Command to create the instance
    public func createCommand(clusterID: String, zone: String, numNodes: Int = 1) -> String {
        var cmd = "gcloud bigtable instances create \(name) --display-name=\"\(displayName)\" --project=\(projectID)"

        if instanceType == .development {
            cmd += " --instance-type=DEVELOPMENT"
        }

        cmd += " --cluster=\(clusterID) --cluster-zone=\(zone)"

        if instanceType == .production {
            cmd += " --cluster-num-nodes=\(numNodes)"
        }

        return cmd
    }

    /// Command to describe the instance
    public var describeCommand: String {
        "gcloud bigtable instances describe \(name) --project=\(projectID)"
    }

    /// Command to delete the instance
    public var deleteCommand: String {
        "gcloud bigtable instances delete \(name) --project=\(projectID)"
    }

    /// Command to list instances
    public static func listCommand(projectID: String) -> String {
        "gcloud bigtable instances list --project=\(projectID)"
    }
}

// MARK: - Bigtable Cluster

/// Represents a Cloud Bigtable cluster
public struct GoogleCloudBigtableCluster: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let instanceID: String
    public let zone: String
    public let serveNodes: Int?
    public let storageType: StorageType
    public let state: ClusterState?

    public enum StorageType: String, Codable, Sendable, Equatable {
        case ssd = "SSD"
        case hdd = "HDD"
    }

    public enum ClusterState: String, Codable, Sendable, Equatable {
        case stateNotKnown = "STATE_NOT_KNOWN"
        case ready = "READY"
        case creating = "CREATING"
        case resizing = "RESIZING"
        case disabled = "DISABLED"
    }

    public init(
        name: String,
        projectID: String,
        instanceID: String,
        zone: String,
        serveNodes: Int? = nil,
        storageType: StorageType = .ssd,
        state: ClusterState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.instanceID = instanceID
        self.zone = zone
        self.serveNodes = serveNodes
        self.storageType = storageType
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(instanceID)/clusters/\(name)"
    }

    /// Command to create the cluster
    public func createCommand(numNodes: Int = 3) -> String {
        "gcloud bigtable clusters create \(name) --instance=\(instanceID) --zone=\(zone) --num-nodes=\(numNodes) --storage-type=\(storageType.rawValue) --project=\(projectID)"
    }

    /// Command to describe the cluster
    public var describeCommand: String {
        "gcloud bigtable clusters describe \(name) --instance=\(instanceID) --project=\(projectID)"
    }

    /// Command to update the cluster (scale nodes)
    public func updateCommand(numNodes: Int) -> String {
        "gcloud bigtable clusters update \(name) --instance=\(instanceID) --num-nodes=\(numNodes) --project=\(projectID)"
    }

    /// Command to delete the cluster
    public var deleteCommand: String {
        "gcloud bigtable clusters delete \(name) --instance=\(instanceID) --project=\(projectID)"
    }

    /// Command to list clusters
    public static func listCommand(projectID: String, instanceID: String) -> String {
        "gcloud bigtable clusters list --instances=\(instanceID) --project=\(projectID)"
    }
}

// MARK: - Bigtable Table

/// Represents a Cloud Bigtable table
public struct GoogleCloudBigtableTable: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let instanceID: String
    public let columnFamilies: [String]?
    public let granularity: Granularity?

    public enum Granularity: String, Codable, Sendable, Equatable {
        case timestampGranularityUnspecified = "TIMESTAMP_GRANULARITY_UNSPECIFIED"
        case millis = "MILLIS"
    }

    public init(
        name: String,
        projectID: String,
        instanceID: String,
        columnFamilies: [String]? = nil,
        granularity: Granularity? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.instanceID = instanceID
        self.columnFamilies = columnFamilies
        self.granularity = granularity
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(instanceID)/tables/\(name)"
    }

    /// Command to create the table
    public var createCommand: String {
        var cmd = "cbt -project=\(projectID) -instance=\(instanceID) createtable \(name)"

        if let families = columnFamilies, !families.isEmpty {
            cmd += " \"families=\(families.joined(separator: ","))\""
        }

        return cmd
    }

    /// Command to describe the table
    public var describeCommand: String {
        "cbt -project=\(projectID) -instance=\(instanceID) ls \(name)"
    }

    /// Command to delete the table
    public var deleteCommand: String {
        "cbt -project=\(projectID) -instance=\(instanceID) deletetable \(name)"
    }

    /// Command to list tables
    public static func listCommand(projectID: String, instanceID: String) -> String {
        "cbt -project=\(projectID) -instance=\(instanceID) ls"
    }

    /// Command to add a column family
    public func addColumnFamilyCommand(family: String, maxVersions: Int? = nil) -> String {
        var cmd = "cbt -project=\(projectID) -instance=\(instanceID) createfamily \(name) \(family)"

        if let versions = maxVersions {
            cmd += " maxversions:\(versions)"
        }

        return cmd
    }

    /// Command to read rows
    public func readCommand(prefix: String? = nil, limit: Int? = nil) -> String {
        var cmd = "cbt -project=\(projectID) -instance=\(instanceID) read \(name)"

        if let prefix = prefix {
            cmd += " prefix=\(prefix)"
        }

        if let limit = limit {
            cmd += " count=\(limit)"
        }

        return cmd
    }
}

// MARK: - Bigtable Backup

/// Represents a Cloud Bigtable backup
public struct GoogleCloudBigtableBackup: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let instanceID: String
    public let clusterID: String
    public let sourceTable: String
    public let expireTime: Date?
    public let state: BackupState?

    public enum BackupState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case ready = "READY"
    }

    public init(
        name: String,
        projectID: String,
        instanceID: String,
        clusterID: String,
        sourceTable: String,
        expireTime: Date? = nil,
        state: BackupState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.instanceID = instanceID
        self.clusterID = clusterID
        self.sourceTable = sourceTable
        self.expireTime = expireTime
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(instanceID)/clusters/\(clusterID)/backups/\(name)"
    }

    /// Command to create the backup
    public func createCommand(expireDays: Int = 30) -> String {
        "gcloud bigtable backups create \(name) --instance=\(instanceID) --cluster=\(clusterID) --table=\(sourceTable) --expiration-date=$(date -d '+\(expireDays) days' --iso-8601) --project=\(projectID)"
    }

    /// Command to describe the backup
    public var describeCommand: String {
        "gcloud bigtable backups describe \(name) --instance=\(instanceID) --cluster=\(clusterID) --project=\(projectID)"
    }

    /// Command to delete the backup
    public var deleteCommand: String {
        "gcloud bigtable backups delete \(name) --instance=\(instanceID) --cluster=\(clusterID) --project=\(projectID)"
    }

    /// Command to restore from backup
    public func restoreCommand(targetTable: String) -> String {
        "gcloud bigtable instances tables restore --source-backup=\(name) --source-instance=\(instanceID) --source-cluster=\(clusterID) --destination-table=\(targetTable) --destination-instance=\(instanceID) --project=\(projectID)"
    }

    /// Command to list backups
    public static func listCommand(projectID: String, instanceID: String, clusterID: String) -> String {
        "gcloud bigtable backups list --instance=\(instanceID) --cluster=\(clusterID) --project=\(projectID)"
    }
}

// MARK: - Bigtable Operations

/// Helper operations for Cloud Bigtable
public struct BigtableOperations: Sendable {

    /// Command to enable Cloud Bigtable API
    public static var enableAPICommand: String {
        "gcloud services enable bigtable.googleapis.com bigtableadmin.googleapis.com"
    }

    /// Command to install cbt CLI
    public static var installCBTCommand: String {
        "gcloud components install cbt"
    }

    /// IAM roles for Bigtable
    public struct Roles {
        public static let admin = "roles/bigtable.admin"
        public static let user = "roles/bigtable.user"
        public static let reader = "roles/bigtable.reader"
        public static let viewer = "roles/bigtable.viewer"
    }

    /// Command to add Bigtable admin role
    public static func addAdminRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=roles/bigtable.admin"
    }

    /// Command to add Bigtable user role
    public static func addUserRoleCommand(projectID: String, serviceAccount: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=serviceAccount:\(serviceAccount) --role=roles/bigtable.user"
    }

    /// Bigtable zones
    public struct Zones {
        public static let usCentral1A = "us-central1-a"
        public static let usCentral1B = "us-central1-b"
        public static let usCentral1C = "us-central1-c"
        public static let usEast1B = "us-east1-b"
        public static let usEast1C = "us-east1-c"
        public static let usEast4A = "us-east4-a"
        public static let europeWest1B = "europe-west1-b"
        public static let asiaEast1A = "asia-east1-a"
    }
}

// MARK: - Bigtable App Profile

/// Represents a Bigtable app profile
public struct GoogleCloudBigtableAppProfile: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let instanceID: String
    public let description: String?
    public let routingPolicy: RoutingPolicy

    public enum RoutingPolicy: Codable, Sendable, Equatable {
        case multiClusterRouting
        case singleClusterRouting(clusterID: String, allowTransactionalWrites: Bool)

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.multiCluster) {
                self = .multiClusterRouting
            } else {
                let clusterID = try container.decode(String.self, forKey: .clusterID)
                let allowWrites = try container.decodeIfPresent(Bool.self, forKey: .allowWrites) ?? false
                self = .singleClusterRouting(clusterID: clusterID, allowTransactionalWrites: allowWrites)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .multiClusterRouting:
                try container.encode(true, forKey: .multiCluster)
            case .singleClusterRouting(let clusterID, let allowWrites):
                try container.encode(clusterID, forKey: .clusterID)
                try container.encode(allowWrites, forKey: .allowWrites)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case multiCluster, clusterID, allowWrites
        }
    }

    public init(
        name: String,
        projectID: String,
        instanceID: String,
        description: String? = nil,
        routingPolicy: RoutingPolicy = .multiClusterRouting
    ) {
        self.name = name
        self.projectID = projectID
        self.instanceID = instanceID
        self.description = description
        self.routingPolicy = routingPolicy
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(instanceID)/appProfiles/\(name)"
    }

    /// Command to create the app profile
    public var createCommand: String {
        var cmd = "gcloud bigtable app-profiles create \(name) --instance=\(instanceID) --project=\(projectID)"

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        switch routingPolicy {
        case .multiClusterRouting:
            cmd += " --route-any"
        case .singleClusterRouting(let clusterID, let allowWrites):
            cmd += " --route-to=\(clusterID)"
            if allowWrites {
                cmd += " --transactional-writes"
            }
        }

        return cmd
    }

    /// Command to delete the app profile
    public var deleteCommand: String {
        "gcloud bigtable app-profiles delete \(name) --instance=\(instanceID) --project=\(projectID)"
    }

    /// Command to list app profiles
    public static func listCommand(projectID: String, instanceID: String) -> String {
        "gcloud bigtable app-profiles list --instance=\(instanceID) --project=\(projectID)"
    }
}

// MARK: - DAIS Bigtable Template

/// Production-ready Cloud Bigtable templates for DAIS systems
public struct DAISBigtableTemplate: Sendable {
    public let projectID: String
    public let instanceName: String
    public let zone: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        instanceName: String = "dais-bigtable",
        zone: String = "us-central1-a",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.instanceName = instanceName
        self.zone = zone
        self.serviceAccount = serviceAccount
    }

    /// Production instance
    public var productionInstance: GoogleCloudBigtableInstance {
        GoogleCloudBigtableInstance(
            name: instanceName,
            projectID: projectID,
            displayName: "DAIS Production Instance",
            instanceType: .production,
            labels: ["env": "production", "managed-by": "dais"]
        )
    }

    /// Development instance
    public var developmentInstance: GoogleCloudBigtableInstance {
        GoogleCloudBigtableInstance(
            name: "\(instanceName)-dev",
            projectID: projectID,
            displayName: "DAIS Development Instance",
            instanceType: .development,
            labels: ["env": "development", "managed-by": "dais"]
        )
    }

    /// Primary cluster
    public var primaryCluster: GoogleCloudBigtableCluster {
        GoogleCloudBigtableCluster(
            name: "\(instanceName)-c1",
            projectID: projectID,
            instanceID: instanceName,
            zone: zone,
            serveNodes: 3,
            storageType: .ssd
        )
    }

    /// Time series table for metrics/events
    public var timeSeriesTable: GoogleCloudBigtableTable {
        GoogleCloudBigtableTable(
            name: "time_series",
            projectID: projectID,
            instanceID: instanceName,
            columnFamilies: ["metrics", "events", "metadata"]
        )
    }

    /// Entities table for user/session data
    public var entitiesTable: GoogleCloudBigtableTable {
        GoogleCloudBigtableTable(
            name: "entities",
            projectID: projectID,
            instanceID: instanceName,
            columnFamilies: ["profile", "activity", "preferences"]
        )
    }

    /// Default app profile with multi-cluster routing
    public var defaultAppProfile: GoogleCloudBigtableAppProfile {
        GoogleCloudBigtableAppProfile(
            name: "default-profile",
            projectID: projectID,
            instanceID: instanceName,
            description: "Default multi-cluster routing profile",
            routingPolicy: .multiClusterRouting
        )
    }

    /// Transactional app profile
    public func transactionalAppProfile(clusterID: String) -> GoogleCloudBigtableAppProfile {
        GoogleCloudBigtableAppProfile(
            name: "transactional-profile",
            projectID: projectID,
            instanceID: instanceName,
            description: "Profile for transactional writes",
            routingPolicy: .singleClusterRouting(clusterID: clusterID, allowTransactionalWrites: true)
        )
    }

    /// Daily backup
    public var dailyBackup: GoogleCloudBigtableBackup {
        GoogleCloudBigtableBackup(
            name: "daily-backup",
            projectID: projectID,
            instanceID: instanceName,
            clusterID: "\(instanceName)-c1",
            sourceTable: "time_series"
        )
    }

    /// Setup script
    public var setupScript: String {
        var script = """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        INSTANCE_NAME="\(instanceName)"
        ZONE="\(zone)"

        echo "Enabling Cloud Bigtable APIs..."
        \(BigtableOperations.enableAPICommand)

        echo ""
        echo "Installing cbt CLI..."
        \(BigtableOperations.installCBTCommand)

        echo ""
        echo "Creating Bigtable instance..."
        \(productionInstance.createCommand(clusterID: "\(instanceName)-c1", zone: zone, numNodes: 3))

        """

        if let sa = serviceAccount {
            script += """
            echo ""
            echo "Granting Bigtable user role..."
            \(BigtableOperations.addUserRoleCommand(projectID: projectID, serviceAccount: sa))

            """
        }

        script += """
        echo ""
        echo "Creating tables..."
        \(timeSeriesTable.createCommand)
        \(entitiesTable.createCommand)

        echo ""
        echo "DAIS Bigtable setup complete!"
        echo ""
        echo "Instance: $INSTANCE_NAME"
        echo "Zone: $ZONE"
        echo "Tables: time_series, entities"
        """

        return script
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        INSTANCE_NAME="\(instanceName)"

        echo "Deleting Bigtable instance..."
        echo "WARNING: This will delete all data!"
        read -p "Continue? (y/n) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            \(productionInstance.deleteCommand)
            echo "Instance deleted."
        else
            echo "Aborted."
        fi
        """
    }
}
