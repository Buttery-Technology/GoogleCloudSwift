//
//  GoogleCloudSQL.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

/// Models for Google Cloud SQL API.
///
/// Cloud SQL is a fully managed relational database service for MySQL,
/// PostgreSQL, and SQL Server. It handles replication, patch management,
/// and database management to ensure availability and performance.
///
/// ## Supported Databases
/// - PostgreSQL (9.6 through 17)
/// - MySQL (5.6, 5.7, 8.0)
/// - SQL Server (2017, 2019, 2022)
///
/// ## Example Usage
/// ```swift
/// let instance = GoogleCloudSQLInstance(
///     name: "my-postgres-db",
///     projectID: "my-project",
///     region: "us-central1",
///     databaseVersion: .postgres16,
///     tier: .dbCustom(cpus: 2, memoryMB: 7680)
/// )
/// print(instance.createCommand)
/// ```
public struct GoogleCloudSQLInstance: Codable, Sendable, Equatable {
    /// Instance name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Region for the instance
    public let region: String

    /// Database version (e.g., POSTGRES_16, MYSQL_8_0)
    public let databaseVersion: DatabaseVersion

    /// Machine tier configuration
    public let tier: MachineTier

    /// Edition (Enterprise or Enterprise Plus)
    public let edition: SQLEdition

    /// Storage type (SSD or HDD)
    public let storageType: StorageType

    /// Storage size in GB
    public let storageSizeGB: Int

    /// Enable automatic storage increase
    public let storageAutoResize: Bool

    /// Maximum storage size in GB for auto-resize
    public let storageAutoResizeLimit: Int?

    /// Availability type (zonal or regional for HA)
    public let availabilityType: AvailabilityType

    /// Enable backups
    public let backupEnabled: Bool

    /// Backup start time (HH:MM format, UTC)
    public let backupStartTime: String?

    /// Enable point-in-time recovery
    public let pointInTimeRecoveryEnabled: Bool

    /// Retained backups count
    public let retainedBackupsCount: Int

    /// Retained transaction log days
    public let transactionLogRetentionDays: Int

    /// Enable deletion protection
    public let deletionProtection: Bool

    /// Root password (for initial setup)
    public let rootPassword: String?

    /// Database flags (PostgreSQL/MySQL configuration)
    public let databaseFlags: [String: String]

    /// Private network for private IP
    public let privateNetwork: String?

    /// Enable public IP
    public let publicIPEnabled: Bool

    /// Authorized networks for public IP
    public let authorizedNetworks: [AuthorizedNetwork]

    /// Maintenance window
    public let maintenanceWindow: MaintenanceWindow?

    /// Labels for organization
    public let labels: [String: String]

    public init(
        name: String,
        projectID: String,
        region: String,
        databaseVersion: DatabaseVersion,
        tier: MachineTier = .dbF1Micro,
        edition: SQLEdition = .enterprise,
        storageType: StorageType = .ssd,
        storageSizeGB: Int = 10,
        storageAutoResize: Bool = true,
        storageAutoResizeLimit: Int? = nil,
        availabilityType: AvailabilityType = .zonal,
        backupEnabled: Bool = true,
        backupStartTime: String? = nil,
        pointInTimeRecoveryEnabled: Bool = false,
        retainedBackupsCount: Int = 7,
        transactionLogRetentionDays: Int = 7,
        deletionProtection: Bool = false,
        rootPassword: String? = nil,
        databaseFlags: [String: String] = [:],
        privateNetwork: String? = nil,
        publicIPEnabled: Bool = true,
        authorizedNetworks: [AuthorizedNetwork] = [],
        maintenanceWindow: MaintenanceWindow? = nil,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.databaseVersion = databaseVersion
        self.tier = tier
        self.edition = edition
        self.storageType = storageType
        self.storageSizeGB = storageSizeGB
        self.storageAutoResize = storageAutoResize
        self.storageAutoResizeLimit = storageAutoResizeLimit
        self.availabilityType = availabilityType
        self.backupEnabled = backupEnabled
        self.backupStartTime = backupStartTime
        self.pointInTimeRecoveryEnabled = pointInTimeRecoveryEnabled
        self.retainedBackupsCount = retainedBackupsCount
        self.transactionLogRetentionDays = transactionLogRetentionDays
        self.deletionProtection = deletionProtection
        self.rootPassword = rootPassword
        self.databaseFlags = databaseFlags
        self.privateNetwork = privateNetwork
        self.publicIPEnabled = publicIPEnabled
        self.authorizedNetworks = authorizedNetworks
        self.maintenanceWindow = maintenanceWindow
        self.labels = labels
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/instances/\(name)"
    }

    /// Connection name for connecting to the instance
    public var connectionName: String {
        "\(projectID):\(region):\(name)"
    }

    /// gcloud command to create this instance
    public var createCommand: String {
        var cmd = "gcloud sql instances create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --database-version=\(databaseVersion.rawValue)"
        cmd += " --edition=\(edition.rawValue)"

        switch tier {
        case .dbF1Micro, .dbG1Small:
            cmd += " --tier=\(tier.tierName)"
        case .dbCustom(let cpus, let memoryMB):
            cmd += " --cpu=\(cpus)"
            cmd += " --memory=\(memoryMB)MB"
        case .dbStandard(let name):
            cmd += " --tier=\(name)"
        }

        cmd += " --storage-type=\(storageType.rawValue)"
        cmd += " --storage-size=\(storageSizeGB)GB"

        if storageAutoResize {
            cmd += " --storage-auto-increase"
            if let limit = storageAutoResizeLimit {
                cmd += " --storage-auto-increase-limit=\(limit)GB"
            }
        }

        cmd += " --availability-type=\(availabilityType.rawValue)"

        if backupEnabled {
            cmd += " --backup"
            if let startTime = backupStartTime {
                cmd += " --backup-start-time=\(startTime)"
            }
            cmd += " --retained-backups-count=\(retainedBackupsCount)"
            cmd += " --retained-transaction-log-days=\(transactionLogRetentionDays)"
        } else {
            cmd += " --no-backup"
        }

        if pointInTimeRecoveryEnabled {
            cmd += " --enable-point-in-time-recovery"
        }

        if deletionProtection {
            cmd += " --deletion-protection"
        }

        if let password = rootPassword {
            cmd += " --root-password=\(password)"
        }

        if !databaseFlags.isEmpty {
            let flags = databaseFlags.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --database-flags=\(flags)"
        }

        if let network = privateNetwork {
            cmd += " --network=\(network)"
            if !publicIPEnabled {
                cmd += " --no-assign-ip"
            }
        }

        for network in authorizedNetworks {
            cmd += " --authorized-networks=\(network.cidr)"
        }

        if let window = maintenanceWindow {
            cmd += " --maintenance-window-day=\(window.day.rawValue)"
            cmd += " --maintenance-window-hour=\(window.hour)"
        }

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        return cmd
    }

    /// gcloud command to delete this instance
    public var deleteCommand: String {
        "gcloud sql instances delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this instance
    public var describeCommand: String {
        "gcloud sql instances describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list all instances
    public static func listCommand(projectID: String) -> String {
        "gcloud sql instances list --project=\(projectID)"
    }

    /// gcloud command to restart this instance
    public var restartCommand: String {
        "gcloud sql instances restart \(name) --project=\(projectID)"
    }

    /// gcloud command to start this instance
    public var startCommand: String {
        "gcloud sql instances patch \(name) --project=\(projectID) --activation-policy=ALWAYS"
    }

    /// gcloud command to stop this instance
    public var stopCommand: String {
        "gcloud sql instances patch \(name) --project=\(projectID) --activation-policy=NEVER"
    }

    /// gcloud command to create a backup
    public var createBackupCommand: String {
        "gcloud sql backups create --instance=\(name) --project=\(projectID)"
    }

    /// gcloud command to list backups
    public var listBackupsCommand: String {
        "gcloud sql backups list --instance=\(name) --project=\(projectID)"
    }

    /// gcloud command to clone this instance
    public func cloneCommand(newInstanceName: String) -> String {
        "gcloud sql instances clone \(name) \(newInstanceName) --project=\(projectID)"
    }

    /// gcloud command to promote a read replica
    public var promoteReplicaCommand: String {
        "gcloud sql instances promote-replica \(name) --project=\(projectID)"
    }

    /// gcloud command to failover (for HA instances)
    public var failoverCommand: String {
        "gcloud sql instances failover \(name) --project=\(projectID)"
    }
}

// MARK: - Database Version

extension GoogleCloudSQLInstance {
    /// Supported database versions
    public enum DatabaseVersion: String, Codable, Sendable, CaseIterable {
        // PostgreSQL versions
        case postgres17 = "POSTGRES_17"
        case postgres16 = "POSTGRES_16"
        case postgres15 = "POSTGRES_15"
        case postgres14 = "POSTGRES_14"
        case postgres13 = "POSTGRES_13"
        case postgres12 = "POSTGRES_12"
        case postgres11 = "POSTGRES_11"
        case postgres96 = "POSTGRES_9_6"

        // MySQL versions
        case mysql80 = "MYSQL_8_0"
        case mysql57 = "MYSQL_5_7"
        case mysql56 = "MYSQL_5_6"

        // SQL Server versions
        case sqlserver2022Standard = "SQLSERVER_2022_STANDARD"
        case sqlserver2022Enterprise = "SQLSERVER_2022_ENTERPRISE"
        case sqlserver2022Express = "SQLSERVER_2022_EXPRESS"
        case sqlserver2022Web = "SQLSERVER_2022_WEB"
        case sqlserver2019Standard = "SQLSERVER_2019_STANDARD"
        case sqlserver2019Enterprise = "SQLSERVER_2019_ENTERPRISE"
        case sqlserver2019Express = "SQLSERVER_2019_EXPRESS"
        case sqlserver2019Web = "SQLSERVER_2019_WEB"
        case sqlserver2017Standard = "SQLSERVER_2017_STANDARD"
        case sqlserver2017Enterprise = "SQLSERVER_2017_ENTERPRISE"
        case sqlserver2017Express = "SQLSERVER_2017_EXPRESS"
        case sqlserver2017Web = "SQLSERVER_2017_WEB"

        /// Database engine type
        public var engine: DatabaseEngine {
            switch self {
            case .postgres17, .postgres16, .postgres15, .postgres14, .postgres13, .postgres12, .postgres11, .postgres96:
                return .postgresql
            case .mysql80, .mysql57, .mysql56:
                return .mysql
            default:
                return .sqlserver
            }
        }

        /// Human-readable display name
        public var displayName: String {
            switch self {
            case .postgres17: return "PostgreSQL 17"
            case .postgres16: return "PostgreSQL 16"
            case .postgres15: return "PostgreSQL 15"
            case .postgres14: return "PostgreSQL 14"
            case .postgres13: return "PostgreSQL 13"
            case .postgres12: return "PostgreSQL 12"
            case .postgres11: return "PostgreSQL 11"
            case .postgres96: return "PostgreSQL 9.6"
            case .mysql80: return "MySQL 8.0"
            case .mysql57: return "MySQL 5.7"
            case .mysql56: return "MySQL 5.6"
            case .sqlserver2022Standard: return "SQL Server 2022 Standard"
            case .sqlserver2022Enterprise: return "SQL Server 2022 Enterprise"
            case .sqlserver2022Express: return "SQL Server 2022 Express"
            case .sqlserver2022Web: return "SQL Server 2022 Web"
            case .sqlserver2019Standard: return "SQL Server 2019 Standard"
            case .sqlserver2019Enterprise: return "SQL Server 2019 Enterprise"
            case .sqlserver2019Express: return "SQL Server 2019 Express"
            case .sqlserver2019Web: return "SQL Server 2019 Web"
            case .sqlserver2017Standard: return "SQL Server 2017 Standard"
            case .sqlserver2017Enterprise: return "SQL Server 2017 Enterprise"
            case .sqlserver2017Express: return "SQL Server 2017 Express"
            case .sqlserver2017Web: return "SQL Server 2017 Web"
            }
        }

        /// Default port for this database engine
        public var defaultPort: Int {
            switch engine {
            case .postgresql: return 5432
            case .mysql: return 3306
            case .sqlserver: return 1433
            }
        }
    }

    /// Database engine type
    public enum DatabaseEngine: String, Codable, Sendable {
        case postgresql = "POSTGRESQL"
        case mysql = "MYSQL"
        case sqlserver = "SQLSERVER"
    }
}

// MARK: - Machine Tier

extension GoogleCloudSQLInstance {
    /// Machine tier configuration
    public enum MachineTier: Codable, Sendable, Equatable {
        /// Shared-core micro instance (for development)
        case dbF1Micro
        /// Shared-core small instance
        case dbG1Small
        /// Custom configuration with specific CPU and memory
        case dbCustom(cpus: Int, memoryMB: Int)
        /// Standard predefined tier
        case dbStandard(name: String)

        /// Tier name for gcloud command
        public var tierName: String {
            switch self {
            case .dbF1Micro: return "db-f1-micro"
            case .dbG1Small: return "db-g1-small"
            case .dbCustom(let cpus, let memoryMB): return "db-custom-\(cpus)-\(memoryMB)"
            case .dbStandard(let name): return name
            }
        }

        /// Approximate monthly cost in USD
        public var approximateMonthlyCostUSD: Double {
            switch self {
            case .dbF1Micro: return 8
            case .dbG1Small: return 26
            case .dbCustom(let cpus, _):
                // Rough estimate: ~$30 per vCPU/month
                return Double(cpus) * 30
            case .dbStandard: return 50
            }
        }

        /// Recommended tier for development
        public static var developmentRecommended: MachineTier {
            .dbF1Micro
        }

        /// Recommended tier for production
        public static var productionRecommended: MachineTier {
            .dbCustom(cpus: 2, memoryMB: 7680)
        }
    }
}

// MARK: - SQL Edition

extension GoogleCloudSQLInstance {
    /// Cloud SQL edition
    public enum SQLEdition: String, Codable, Sendable {
        /// Standard edition with essential features
        case enterprise = "ENTERPRISE"
        /// Enhanced edition with additional performance and availability
        case enterprisePlus = "ENTERPRISE_PLUS"
    }
}

// MARK: - Storage Type

extension GoogleCloudSQLInstance {
    /// Storage type for the instance
    public enum StorageType: String, Codable, Sendable {
        /// SSD storage (recommended for production)
        case ssd = "SSD"
        /// HDD storage (lower cost, lower performance)
        case hdd = "HDD"
    }
}

// MARK: - Availability Type

extension GoogleCloudSQLInstance {
    /// Availability configuration
    public enum AvailabilityType: String, Codable, Sendable {
        /// Single zone (no high availability)
        case zonal = "ZONAL"
        /// Multi-zone high availability
        case regional = "REGIONAL"
    }
}

// MARK: - Instance State

extension GoogleCloudSQLInstance {
    /// State of a Cloud SQL instance
    public enum InstanceState: String, Codable, Sendable {
        /// Instance is running
        case runnable = "RUNNABLE"
        /// Instance is suspended
        case suspended = "SUSPENDED"
        /// Instance is pending creation
        case pendingCreate = "PENDING_CREATE"
        /// Instance is under maintenance
        case maintenance = "MAINTENANCE"
        /// Instance creation failed
        case failed = "FAILED"
        /// Unknown state
        case unknown = "UNKNOWN"
    }
}

// MARK: - Authorized Network

extension GoogleCloudSQLInstance {
    /// Authorized network for public IP access
    public struct AuthorizedNetwork: Codable, Sendable, Equatable {
        /// Name for this network entry
        public let name: String
        /// CIDR notation (e.g., "10.0.0.0/8" or "0.0.0.0/0" for all)
        public let cidr: String
        /// Expiration time (optional)
        public let expirationTime: String?

        public init(name: String, cidr: String, expirationTime: String? = nil) {
            self.name = name
            self.cidr = cidr
            self.expirationTime = expirationTime
        }

        /// Allow access from anywhere (use with caution!)
        public static var allowAll: AuthorizedNetwork {
            AuthorizedNetwork(name: "allow-all", cidr: "0.0.0.0/0")
        }
    }
}

// MARK: - Maintenance Window

extension GoogleCloudSQLInstance {
    /// Maintenance window configuration
    public struct MaintenanceWindow: Codable, Sendable, Equatable {
        /// Day of the week
        public let day: DayOfWeek
        /// Hour (0-23, UTC)
        public let hour: Int

        public init(day: DayOfWeek, hour: Int) {
            self.day = day
            self.hour = max(0, min(23, hour))
        }

        /// Day of the week
        public enum DayOfWeek: String, Codable, Sendable {
            case sunday = "SUN"
            case monday = "MON"
            case tuesday = "TUE"
            case wednesday = "WED"
            case thursday = "THU"
            case friday = "FRI"
            case saturday = "SAT"
        }
    }
}

// MARK: - Cloud SQL Database

/// Represents a database within a Cloud SQL instance
public struct GoogleCloudSQLDatabase: Codable, Sendable, Equatable {
    /// Database name
    public let name: String

    /// Instance name
    public let instanceName: String

    /// Project ID
    public let projectID: String

    /// Character set (default: UTF8)
    public let charset: String

    /// Collation (default: en_US.UTF8 for PostgreSQL)
    public let collation: String?

    public init(
        name: String,
        instanceName: String,
        projectID: String,
        charset: String = "UTF8",
        collation: String? = nil
    ) {
        self.name = name
        self.instanceName = instanceName
        self.projectID = projectID
        self.charset = charset
        self.collation = collation
    }

    /// gcloud command to create this database
    public var createCommand: String {
        var cmd = "gcloud sql databases create \(name)"
        cmd += " --instance=\(instanceName)"
        cmd += " --project=\(projectID)"
        cmd += " --charset=\(charset)"
        if let collation = collation {
            cmd += " --collation=\(collation)"
        }
        return cmd
    }

    /// gcloud command to delete this database
    public var deleteCommand: String {
        "gcloud sql databases delete \(name) --instance=\(instanceName) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this database
    public var describeCommand: String {
        "gcloud sql databases describe \(name) --instance=\(instanceName) --project=\(projectID)"
    }

    /// gcloud command to list all databases in the instance
    public static func listCommand(instanceName: String, projectID: String) -> String {
        "gcloud sql databases list --instance=\(instanceName) --project=\(projectID)"
    }
}

// MARK: - Cloud SQL User

/// Represents a user in a Cloud SQL instance
public struct GoogleCloudSQLUser: Codable, Sendable, Equatable {
    /// Username
    public let name: String

    /// Instance name
    public let instanceName: String

    /// Project ID
    public let projectID: String

    /// Password (for creation)
    public let password: String?

    /// Host (for MySQL, use % for any host)
    public let host: String?

    /// User type
    public let type: UserType

    public init(
        name: String,
        instanceName: String,
        projectID: String,
        password: String? = nil,
        host: String? = nil,
        type: UserType = .builtIn
    ) {
        self.name = name
        self.instanceName = instanceName
        self.projectID = projectID
        self.password = password
        self.host = host
        self.type = type
    }

    /// User type
    public enum UserType: String, Codable, Sendable {
        /// Built-in database user
        case builtIn = "BUILT_IN"
        /// Cloud IAM user
        case cloudIAMUser = "CLOUD_IAM_USER"
        /// Cloud IAM service account
        case cloudIAMServiceAccount = "CLOUD_IAM_SERVICE_ACCOUNT"
    }

    /// gcloud command to create this user
    public var createCommand: String {
        var cmd = "gcloud sql users create \(name)"
        cmd += " --instance=\(instanceName)"
        cmd += " --project=\(projectID)"
        if let password = password {
            cmd += " --password=\(password)"
        }
        if let host = host {
            cmd += " --host=\(host)"
        }
        if type != .builtIn {
            cmd += " --type=\(type.rawValue)"
        }
        return cmd
    }

    /// gcloud command to delete this user
    public var deleteCommand: String {
        var cmd = "gcloud sql users delete \(name)"
        cmd += " --instance=\(instanceName)"
        cmd += " --project=\(projectID)"
        if let host = host {
            cmd += " --host=\(host)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to set password
    public func setPasswordCommand(newPassword: String) -> String {
        var cmd = "gcloud sql users set-password \(name)"
        cmd += " --instance=\(instanceName)"
        cmd += " --project=\(projectID)"
        cmd += " --password=\(newPassword)"
        if let host = host {
            cmd += " --host=\(host)"
        }
        return cmd
    }

    /// gcloud command to list all users in the instance
    public static func listCommand(instanceName: String, projectID: String) -> String {
        "gcloud sql users list --instance=\(instanceName) --project=\(projectID)"
    }
}

// MARK: - Cloud SQL SSL Certificate

/// Represents an SSL certificate for a Cloud SQL instance
public struct GoogleCloudSQLSSLCert: Codable, Sendable, Equatable {
    /// Certificate common name
    public let commonName: String

    /// Instance name
    public let instanceName: String

    /// Project ID
    public let projectID: String

    public init(commonName: String, instanceName: String, projectID: String) {
        self.commonName = commonName
        self.instanceName = instanceName
        self.projectID = projectID
    }

    /// gcloud command to create this SSL certificate
    public var createCommand: String {
        "gcloud sql ssl client-certs create \(commonName) client-key.pem --instance=\(instanceName) --project=\(projectID)"
    }

    /// gcloud command to delete this SSL certificate
    public var deleteCommand: String {
        "gcloud sql ssl client-certs delete \(commonName) --instance=\(instanceName) --project=\(projectID) --quiet"
    }

    /// gcloud command to list SSL certificates
    public static func listCommand(instanceName: String, projectID: String) -> String {
        "gcloud sql ssl client-certs list --instance=\(instanceName) --project=\(projectID)"
    }
}

// MARK: - Cloud SQL Replica

extension GoogleCloudSQLInstance {
    /// Create a read replica configuration
    public func readReplicaConfig(
        replicaName: String,
        replicaRegion: String? = nil
    ) -> GoogleCloudSQLInstance {
        GoogleCloudSQLInstance(
            name: replicaName,
            projectID: projectID,
            region: replicaRegion ?? region,
            databaseVersion: databaseVersion,
            tier: tier,
            edition: edition,
            storageType: storageType,
            storageSizeGB: storageSizeGB,
            storageAutoResize: storageAutoResize,
            availabilityType: .zonal, // Replicas are always zonal
            backupEnabled: false, // Replicas don't need backups
            deletionProtection: false,
            labels: labels
        )
    }

    /// gcloud command to create a read replica
    public func createReplicaCommand(replicaName: String, replicaRegion: String? = nil) -> String {
        var cmd = "gcloud sql instances create \(replicaName)"
        cmd += " --master-instance-name=\(name)"
        cmd += " --project=\(projectID)"
        if let region = replicaRegion {
            cmd += " --region=\(region)"
        }
        return cmd
    }
}

// MARK: - DAIS SQL Templates

/// Predefined Cloud SQL configurations for DAIS
public enum DAISSQLTemplate {
    /// Create a PostgreSQL instance for DAIS
    public static func postgresInstance(
        name: String,
        projectID: String,
        region: String,
        tier: GoogleCloudSQLInstance.MachineTier = .productionRecommended,
        highAvailability: Bool = false
    ) -> GoogleCloudSQLInstance {
        GoogleCloudSQLInstance(
            name: name,
            projectID: projectID,
            region: region,
            databaseVersion: .postgres16,
            tier: tier,
            edition: .enterprise,
            storageType: .ssd,
            storageSizeGB: 20,
            storageAutoResize: true,
            availabilityType: highAvailability ? .regional : .zonal,
            backupEnabled: true,
            pointInTimeRecoveryEnabled: true,
            deletionProtection: highAvailability,
            databaseFlags: [
                "max_connections": "200",
                "log_min_duration_statement": "1000"
            ],
            labels: [
                "app": "butteryai",
                "managed-by": "dais",
                "database": "postgresql"
            ]
        )
    }

    /// Create a database for DAIS
    public static func daisDatabase(
        instanceName: String,
        projectID: String
    ) -> GoogleCloudSQLDatabase {
        GoogleCloudSQLDatabase(
            name: "dais",
            instanceName: instanceName,
            projectID: projectID,
            charset: "UTF8",
            collation: "en_US.UTF8"
        )
    }

    /// Create an application user for DAIS
    public static func daisUser(
        instanceName: String,
        projectID: String,
        password: String
    ) -> GoogleCloudSQLUser {
        GoogleCloudSQLUser(
            name: "dais_app",
            instanceName: instanceName,
            projectID: projectID,
            password: password
        )
    }

    /// Generate a setup script for DAIS PostgreSQL
    public static func setupScript(
        instance: GoogleCloudSQLInstance,
        database: GoogleCloudSQLDatabase,
        appUser: GoogleCloudSQLUser
    ) -> String {
        """
        #!/bin/bash
        # DAIS Cloud SQL PostgreSQL Setup Script
        # Instance: \(instance.name)
        # Project: \(instance.projectID)

        set -e

        echo "========================================"
        echo "DAIS Cloud SQL PostgreSQL Setup"
        echo "========================================"

        # Enable Cloud SQL Admin API
        echo "Enabling Cloud SQL Admin API..."
        gcloud services enable sqladmin.googleapis.com --project=\(instance.projectID)

        # Create the instance
        echo "Creating Cloud SQL instance..."
        \(instance.createCommand)

        # Wait for instance to be ready
        echo "Waiting for instance to be ready..."
        gcloud sql instances describe \(instance.name) --project=\(instance.projectID) --format="value(state)"

        # Create the database
        echo "Creating database..."
        \(database.createCommand)

        # Create the application user
        echo "Creating application user..."
        \(appUser.createCommand)

        # Get connection info
        echo ""
        echo "Setup complete!"
        echo ""
        echo "Connection Information:"
        echo "  Instance: \(instance.connectionName)"
        echo "  Database: \(database.name)"
        echo "  User: \(appUser.name)"
        echo ""
        echo "Connect using Cloud SQL Proxy:"
        echo "  cloud_sql_proxy -instances=\(instance.connectionName)=tcp:5432"
        echo ""
        echo "Or connect directly (if public IP enabled):"
        IP=$(gcloud sql instances describe \(instance.name) --project=\(instance.projectID) --format="value(ipAddresses[0].ipAddress)")
        echo "  psql -h $IP -U \(appUser.name) -d \(database.name)"
        """
    }

    /// Connection string template for DAIS
    public static func connectionString(
        instance: GoogleCloudSQLInstance,
        database: GoogleCloudSQLDatabase,
        user: GoogleCloudSQLUser,
        useProxy: Bool = true
    ) -> String {
        if useProxy {
            return "postgresql://\(user.name)@localhost:5432/\(database.name)?host=/cloudsql/\(instance.connectionName)"
        } else {
            return "postgresql://\(user.name)@<INSTANCE_IP>:5432/\(database.name)"
        }
    }
}
