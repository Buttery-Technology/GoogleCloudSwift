import Foundation

// MARK: - Spanner Instance

/// Represents a Cloud Spanner instance
public struct GoogleCloudSpannerInstance: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let displayName: String?
    public let config: String
    public let nodeCount: Int?
    public let processingUnits: Int?
    public let labels: [String: String]?
    public let state: InstanceState?
    public let createTime: Date?
    public let updateTime: Date?

    public enum InstanceState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case ready = "READY"
    }

    public init(
        name: String,
        projectID: String,
        displayName: String? = nil,
        config: String = "regional-us-central1",
        nodeCount: Int? = nil,
        processingUnits: Int? = nil,
        labels: [String: String]? = nil,
        state: InstanceState? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.displayName = displayName
        self.config = config
        self.nodeCount = nodeCount
        self.processingUnits = processingUnits
        self.labels = labels
        self.state = state
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(name)"
    }

    /// Command to create the instance
    public var createCommand: String {
        var cmd = "gcloud spanner instances create \(name) --project=\(projectID) --config=\(config)"

        if let displayName = displayName {
            cmd += " --description='\(displayName)'"
        }

        if let nodeCount = nodeCount {
            cmd += " --nodes=\(nodeCount)"
        } else if let processingUnits = processingUnits {
            cmd += " --processing-units=\(processingUnits)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to delete the instance
    public var deleteCommand: String {
        "gcloud spanner instances delete \(name) --project=\(projectID) --quiet"
    }

    /// Command to describe the instance
    public var describeCommand: String {
        "gcloud spanner instances describe \(name) --project=\(projectID)"
    }

    /// Command to update the instance
    public func updateCommand(nodeCount: Int? = nil, processingUnits: Int? = nil, displayName: String? = nil) -> String {
        var cmd = "gcloud spanner instances update \(name) --project=\(projectID)"

        if let nodeCount = nodeCount {
            cmd += " --nodes=\(nodeCount)"
        } else if let processingUnits = processingUnits {
            cmd += " --processing-units=\(processingUnits)"
        }

        if let displayName = displayName {
            cmd += " --description='\(displayName)'"
        }

        return cmd
    }

    /// Command to list instances
    public static func listCommand(projectID: String) -> String {
        "gcloud spanner instances list --project=\(projectID)"
    }
}

// MARK: - Spanner Database

/// Represents a Cloud Spanner database
public struct GoogleCloudSpannerDatabase: Codable, Sendable, Equatable {
    public let name: String
    public let instanceName: String
    public let projectID: String
    public let ddl: [String]?
    public let versionRetentionPeriod: String?
    public let enableDropProtection: Bool?
    public let databaseDialect: DatabaseDialect?
    public let state: DatabaseState?
    public let createTime: Date?

    public enum DatabaseDialect: String, Codable, Sendable, Equatable {
        case databaseDialectUnspecified = "DATABASE_DIALECT_UNSPECIFIED"
        case googleStandardSql = "GOOGLE_STANDARD_SQL"
        case postgresql = "POSTGRESQL"
    }

    public enum DatabaseState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case ready = "READY"
        case readyOptimizing = "READY_OPTIMIZING"
    }

    public init(
        name: String,
        instanceName: String,
        projectID: String,
        ddl: [String]? = nil,
        versionRetentionPeriod: String? = nil,
        enableDropProtection: Bool? = nil,
        databaseDialect: DatabaseDialect? = nil,
        state: DatabaseState? = nil,
        createTime: Date? = nil
    ) {
        self.name = name
        self.instanceName = instanceName
        self.projectID = projectID
        self.ddl = ddl
        self.versionRetentionPeriod = versionRetentionPeriod
        self.enableDropProtection = enableDropProtection
        self.databaseDialect = databaseDialect
        self.state = state
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(instanceName)/databases/\(name)"
    }

    /// Command to create the database
    public var createCommand: String {
        var cmd = "gcloud spanner databases create \(name) --instance=\(instanceName) --project=\(projectID)"

        if let dialect = databaseDialect, dialect == .postgresql {
            cmd += " --database-dialect=POSTGRESQL"
        }

        if let ddl = ddl, !ddl.isEmpty {
            let ddlStr = ddl.joined(separator: ";")
            cmd += " --ddl='\(ddlStr)'"
        }

        if enableDropProtection == true {
            cmd += " --enable-drop-protection"
        }

        return cmd
    }

    /// Command to delete the database
    public var deleteCommand: String {
        "gcloud spanner databases delete \(name) --instance=\(instanceName) --project=\(projectID) --quiet"
    }

    /// Command to describe the database
    public var describeCommand: String {
        "gcloud spanner databases describe \(name) --instance=\(instanceName) --project=\(projectID)"
    }

    /// Command to update DDL
    public func updateDdlCommand(statements: [String]) -> String {
        let ddlStr = statements.joined(separator: ";")
        return "gcloud spanner databases ddl update \(name) --instance=\(instanceName) --project=\(projectID) --ddl='\(ddlStr)'"
    }

    /// Command to list databases in an instance
    public static func listCommand(instanceName: String, projectID: String) -> String {
        "gcloud spanner databases list --instance=\(instanceName) --project=\(projectID)"
    }

    /// Command to execute SQL
    public func executeSqlCommand(sql: String) -> String {
        "gcloud spanner databases execute-sql \(name) --instance=\(instanceName) --project=\(projectID) --sql='\(sql)'"
    }
}

// MARK: - Spanner Backup

/// Represents a Cloud Spanner backup
public struct GoogleCloudSpannerBackup: Codable, Sendable, Equatable {
    public let name: String
    public let instanceName: String
    public let projectID: String
    public let databaseName: String
    public let expireTime: Date?
    public let versionTime: Date?
    public let state: BackupState?
    public let sizeBytes: Int64?
    public let createTime: Date?

    public enum BackupState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case ready = "READY"
    }

    public init(
        name: String,
        instanceName: String,
        projectID: String,
        databaseName: String,
        expireTime: Date? = nil,
        versionTime: Date? = nil,
        state: BackupState? = nil,
        sizeBytes: Int64? = nil,
        createTime: Date? = nil
    ) {
        self.name = name
        self.instanceName = instanceName
        self.projectID = projectID
        self.databaseName = databaseName
        self.expireTime = expireTime
        self.versionTime = versionTime
        self.state = state
        self.sizeBytes = sizeBytes
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(instanceName)/backups/\(name)"
    }

    /// Command to create the backup
    public func createCommand(expirationDate: String) -> String {
        "gcloud spanner backups create \(name) --instance=\(instanceName) --project=\(projectID) --database=\(databaseName) --expiration-date=\(expirationDate)"
    }

    /// Command with retention period
    public func createCommandWithRetention(retentionPeriod: String) -> String {
        "gcloud spanner backups create \(name) --instance=\(instanceName) --project=\(projectID) --database=\(databaseName) --retention-period=\(retentionPeriod)"
    }

    /// Command to delete the backup
    public var deleteCommand: String {
        "gcloud spanner backups delete \(name) --instance=\(instanceName) --project=\(projectID) --quiet"
    }

    /// Command to describe the backup
    public var describeCommand: String {
        "gcloud spanner backups describe \(name) --instance=\(instanceName) --project=\(projectID)"
    }

    /// Command to restore from backup
    public func restoreCommand(newDatabaseName: String) -> String {
        "gcloud spanner databases restore --source-backup=\(name) --source-instance=\(instanceName) --destination-database=\(newDatabaseName) --destination-instance=\(instanceName) --project=\(projectID)"
    }

    /// Command to list backups
    public static func listCommand(instanceName: String, projectID: String) -> String {
        "gcloud spanner backups list --instance=\(instanceName) --project=\(projectID)"
    }
}

// MARK: - Spanner Instance Config

/// Represents a Spanner instance configuration (region)
public struct GoogleCloudSpannerInstanceConfig: Codable, Sendable, Equatable {
    public let name: String
    public let displayName: String?
    public let configType: ConfigType?
    public let replicas: [ReplicaInfo]?
    public let leaderOptions: [String]?

    public enum ConfigType: String, Codable, Sendable, Equatable {
        case typeUnspecified = "TYPE_UNSPECIFIED"
        case googleManaged = "GOOGLE_MANAGED"
        case userManaged = "USER_MANAGED"
    }

    public struct ReplicaInfo: Codable, Sendable, Equatable {
        public let location: String
        public let type: ReplicaType
        public let defaultLeaderLocation: Bool?

        public enum ReplicaType: String, Codable, Sendable, Equatable {
            case typeUnspecified = "TYPE_UNSPECIFIED"
            case readWrite = "READ_WRITE"
            case readOnly = "READ_ONLY"
            case witness = "WITNESS"
        }

        public init(location: String, type: ReplicaType, defaultLeaderLocation: Bool? = nil) {
            self.location = location
            self.type = type
            self.defaultLeaderLocation = defaultLeaderLocation
        }
    }

    public init(
        name: String,
        displayName: String? = nil,
        configType: ConfigType? = nil,
        replicas: [ReplicaInfo]? = nil,
        leaderOptions: [String]? = nil
    ) {
        self.name = name
        self.displayName = displayName
        self.configType = configType
        self.replicas = replicas
        self.leaderOptions = leaderOptions
    }

    /// Common regional configurations
    public static let regionalUSCentral1 = "regional-us-central1"
    public static let regionalUSEast1 = "regional-us-east1"
    public static let regionalUSWest1 = "regional-us-west1"
    public static let regionalEuropeWest1 = "regional-europe-west1"
    public static let regionalAsiaEast1 = "regional-asia-east1"

    /// Multi-region configurations
    public static let nam3 = "nam3"  // North America (Iowa, Virginia, Oregon)
    public static let nam6 = "nam6"  // North America (6 regions)
    public static let nam12 = "nam12"  // North America (12 regions)
    public static let eur3 = "eur3"  // Europe (Belgium, London, Finland)
    public static let eur6 = "eur6"  // Europe (6 regions)

    /// Command to list instance configs
    public static func listCommand(projectID: String) -> String {
        "gcloud spanner instance-configs list --project=\(projectID)"
    }

    /// Command to describe an instance config
    public static func describeCommand(configName: String, projectID: String) -> String {
        "gcloud spanner instance-configs describe \(configName) --project=\(projectID)"
    }
}

// MARK: - Spanner Operations

/// Helper operations for Spanner
public struct SpannerOperations: Sendable {

    /// Command to enable Spanner API
    public static var enableAPICommand: String {
        "gcloud services enable spanner.googleapis.com"
    }

    /// Command to execute a query
    public static func queryCommand(database: String, instance: String, projectID: String, sql: String) -> String {
        "gcloud spanner databases execute-sql \(database) --instance=\(instance) --project=\(projectID) --sql='\(sql)'"
    }

    /// Command to run a DML statement
    public static func dmlCommand(database: String, instance: String, projectID: String, dml: String) -> String {
        "gcloud spanner databases execute-sql \(database) --instance=\(instance) --project=\(projectID) --sql='\(dml)'"
    }

    /// Command to get database DDL
    public static func getDdlCommand(database: String, instance: String, projectID: String) -> String {
        "gcloud spanner databases ddl describe \(database) --instance=\(instance) --project=\(projectID)"
    }

    /// Command to list operations on an instance
    public static func listOperationsCommand(instance: String, projectID: String) -> String {
        "gcloud spanner operations list --instance=\(instance) --project=\(projectID)"
    }

    /// Command to list sessions on a database
    public static func listSessionsCommand(database: String, instance: String, projectID: String) -> String {
        "gcloud spanner databases sessions list --database=\(database) --instance=\(instance) --project=\(projectID)"
    }

    /// Command to set IAM policy on instance
    public static func setIAMPolicyCommand(instance: String, projectID: String, member: String, role: String) -> String {
        "gcloud spanner instances add-iam-policy-binding \(instance) --project=\(projectID) --member=\(member) --role=\(role)"
    }
}

// MARK: - DAIS Spanner Template

/// Production-ready Spanner templates for DAIS systems
public struct DAISSpannerTemplate: Sendable {
    public let projectID: String
    public let instanceName: String
    public let databaseName: String
    public let config: String

    public init(
        projectID: String,
        instanceName: String = "dais-spanner",
        databaseName: String = "dais-db",
        config: String = GoogleCloudSpannerInstanceConfig.regionalUSCentral1
    ) {
        self.projectID = projectID
        self.instanceName = instanceName
        self.databaseName = databaseName
        self.config = config
    }

    /// Development instance (minimal resources)
    public var developmentInstance: GoogleCloudSpannerInstance {
        GoogleCloudSpannerInstance(
            name: instanceName,
            projectID: projectID,
            displayName: "DAIS Development Instance",
            config: config,
            processingUnits: 100,  // Minimum for development
            labels: ["environment": "development", "app": "dais"]
        )
    }

    /// Production instance (multi-region)
    public var productionInstance: GoogleCloudSpannerInstance {
        GoogleCloudSpannerInstance(
            name: "\(instanceName)-prod",
            projectID: projectID,
            displayName: "DAIS Production Instance",
            config: GoogleCloudSpannerInstanceConfig.nam3,  // Multi-region for HA
            nodeCount: 3,
            labels: ["environment": "production", "app": "dais"]
        )
    }

    /// Main DAIS database with schema
    public var mainDatabase: GoogleCloudSpannerDatabase {
        GoogleCloudSpannerDatabase(
            name: databaseName,
            instanceName: instanceName,
            projectID: projectID,
            ddl: daisSchema,
            enableDropProtection: true
        )
    }

    /// PostgreSQL-compatible database
    public var postgresDatabase: GoogleCloudSpannerDatabase {
        GoogleCloudSpannerDatabase(
            name: "\(databaseName)-pg",
            instanceName: instanceName,
            projectID: projectID,
            enableDropProtection: true,
            databaseDialect: .postgresql
        )
    }

    /// Default DAIS schema for Spanner
    public var daisSchema: [String] {
        [
            """
            CREATE TABLE agents (
                agent_id STRING(36) NOT NULL,
                name STRING(255) NOT NULL,
                type STRING(50) NOT NULL,
                status STRING(20) NOT NULL,
                config JSON,
                created_at TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
                updated_at TIMESTAMP OPTIONS (allow_commit_timestamp=true)
            ) PRIMARY KEY (agent_id)
            """,
            """
            CREATE TABLE tasks (
                task_id STRING(36) NOT NULL,
                agent_id STRING(36) NOT NULL,
                type STRING(50) NOT NULL,
                status STRING(20) NOT NULL,
                priority INT64 NOT NULL DEFAULT (0),
                payload JSON,
                result JSON,
                created_at TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
                started_at TIMESTAMP,
                completed_at TIMESTAMP,
                CONSTRAINT fk_agent FOREIGN KEY (agent_id) REFERENCES agents (agent_id)
            ) PRIMARY KEY (task_id)
            """,
            """
            CREATE INDEX tasks_by_agent ON tasks (agent_id, status)
            """,
            """
            CREATE INDEX tasks_by_status ON tasks (status, priority DESC)
            """,
            """
            CREATE TABLE events (
                event_id STRING(36) NOT NULL,
                agent_id STRING(36) NOT NULL,
                event_type STRING(50) NOT NULL,
                payload JSON,
                timestamp TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
            ) PRIMARY KEY (agent_id, timestamp DESC, event_id),
            INTERLEAVE IN PARENT agents ON DELETE CASCADE
            """,
            """
            CREATE TABLE agent_metrics (
                agent_id STRING(36) NOT NULL,
                metric_name STRING(100) NOT NULL,
                metric_value FLOAT64 NOT NULL,
                timestamp TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
            ) PRIMARY KEY (agent_id, metric_name, timestamp DESC),
            INTERLEAVE IN PARENT agents ON DELETE CASCADE
            """
        ]
    }

    /// Backup configuration
    public func dailyBackup() -> GoogleCloudSpannerBackup {
        let formatter = ISO8601DateFormatter()
        let dateStr = String(formatter.string(from: Date()).prefix(10))

        return GoogleCloudSpannerBackup(
            name: "dais-backup-\(dateStr)",
            instanceName: instanceName,
            projectID: projectID,
            databaseName: databaseName
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        INSTANCE_NAME="\(instanceName)"
        DATABASE_NAME="\(databaseName)"

        echo "Enabling Spanner API..."
        gcloud services enable spanner.googleapis.com --project=$PROJECT_ID

        echo "Creating Spanner instance..."
        \(developmentInstance.createCommand)

        echo "Waiting for instance to be ready..."
        sleep 30

        echo "Creating database with schema..."
        \(mainDatabase.createCommand)

        echo ""
        echo "DAIS Spanner setup complete!"
        echo ""
        echo "Instance: $INSTANCE_NAME"
        echo "Database: $DATABASE_NAME"
        echo ""
        echo "Connect using:"
        echo "  gcloud spanner databases execute-sql $DATABASE_NAME --instance=$INSTANCE_NAME --project=$PROJECT_ID --sql='SELECT 1'"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        INSTANCE_NAME="\(instanceName)"

        echo "Deleting Spanner instance (this will delete all databases)..."
        gcloud spanner instances delete $INSTANCE_NAME --project=$PROJECT_ID --quiet

        echo "Spanner teardown complete!"
        """
    }
}
