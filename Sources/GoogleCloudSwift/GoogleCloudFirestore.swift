import Foundation

// MARK: - Firestore Database

/// Represents a Firestore database
public struct GoogleCloudFirestoreDatabase: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let locationID: String
    public let type: DatabaseType
    public let concurrencyMode: ConcurrencyMode?
    public let appEngineIntegrationMode: AppEngineIntegrationMode?
    public let pointInTimeRecoveryEnablement: PointInTimeRecoveryEnablement?
    public let deleteProtectionState: DeleteProtectionState?
    public let uid: String?
    public let createTime: Date?
    public let updateTime: Date?

    public enum DatabaseType: String, Codable, Sendable, Equatable {
        case databaseTypeUnspecified = "DATABASE_TYPE_UNSPECIFIED"
        case firestoreNative = "FIRESTORE_NATIVE"
        case datastoreMode = "DATASTORE_MODE"
    }

    public enum ConcurrencyMode: String, Codable, Sendable, Equatable {
        case concurrencyModeUnspecified = "CONCURRENCY_MODE_UNSPECIFIED"
        case optimistic = "OPTIMISTIC"
        case pessimistic = "PESSIMISTIC"
        case optimisticWithEntityGroups = "OPTIMISTIC_WITH_ENTITY_GROUPS"
    }

    public enum AppEngineIntegrationMode: String, Codable, Sendable, Equatable {
        case appEngineIntegrationModeUnspecified = "APP_ENGINE_INTEGRATION_MODE_UNSPECIFIED"
        case enabled = "ENABLED"
        case disabled = "DISABLED"
    }

    public enum PointInTimeRecoveryEnablement: String, Codable, Sendable, Equatable {
        case pointInTimeRecoveryEnablementUnspecified = "POINT_IN_TIME_RECOVERY_ENABLEMENT_UNSPECIFIED"
        case pointInTimeRecoveryEnabled = "POINT_IN_TIME_RECOVERY_ENABLED"
        case pointInTimeRecoveryDisabled = "POINT_IN_TIME_RECOVERY_DISABLED"
    }

    public enum DeleteProtectionState: String, Codable, Sendable, Equatable {
        case deleteProtectionStateUnspecified = "DELETE_PROTECTION_STATE_UNSPECIFIED"
        case deleteProtectionDisabled = "DELETE_PROTECTION_DISABLED"
        case deleteProtectionEnabled = "DELETE_PROTECTION_ENABLED"
    }

    public init(
        name: String = "(default)",
        projectID: String,
        locationID: String = "nam5",
        type: DatabaseType = .firestoreNative,
        concurrencyMode: ConcurrencyMode? = nil,
        appEngineIntegrationMode: AppEngineIntegrationMode? = nil,
        pointInTimeRecoveryEnablement: PointInTimeRecoveryEnablement? = nil,
        deleteProtectionState: DeleteProtectionState? = nil,
        uid: String? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.locationID = locationID
        self.type = type
        self.concurrencyMode = concurrencyMode
        self.appEngineIntegrationMode = appEngineIntegrationMode
        self.pointInTimeRecoveryEnablement = pointInTimeRecoveryEnablement
        self.deleteProtectionState = deleteProtectionState
        self.uid = uid
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/databases/\(name)"
    }

    /// Command to create the database
    public var createCommand: String {
        var cmd = "gcloud firestore databases create --project=\(projectID) --location=\(locationID)"

        if name != "(default)" {
            cmd += " --database=\(name)"
        }

        if type == .datastoreMode {
            cmd += " --type=datastore-mode"
        }

        if deleteProtectionState == .deleteProtectionEnabled {
            cmd += " --delete-protection"
        }

        if pointInTimeRecoveryEnablement == .pointInTimeRecoveryEnabled {
            cmd += " --enable-pitr"
        }

        return cmd
    }

    /// Command to delete the database
    public var deleteCommand: String {
        var cmd = "gcloud firestore databases delete --project=\(projectID)"
        if name != "(default)" {
            cmd += " --database=\(name)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// Command to describe the database
    public var describeCommand: String {
        var cmd = "gcloud firestore databases describe --project=\(projectID)"
        if name != "(default)" {
            cmd += " --database=\(name)"
        }
        return cmd
    }

    /// Command to update the database
    public func updateCommand(deleteProtection: Bool? = nil, pitrEnabled: Bool? = nil) -> String {
        var cmd = "gcloud firestore databases update --project=\(projectID)"
        if name != "(default)" {
            cmd += " --database=\(name)"
        }
        if let deleteProtection = deleteProtection {
            cmd += deleteProtection ? " --delete-protection" : " --no-delete-protection"
        }
        if let pitrEnabled = pitrEnabled {
            cmd += pitrEnabled ? " --enable-pitr" : " --no-enable-pitr"
        }
        return cmd
    }

    /// Command to list databases
    public static func listCommand(projectID: String) -> String {
        "gcloud firestore databases list --project=\(projectID)"
    }
}

// MARK: - Firestore Index

/// Represents a Firestore composite index
public struct GoogleCloudFirestoreIndex: Codable, Sendable, Equatable {
    public let collectionGroup: String
    public let projectID: String
    public let databaseID: String
    public let queryScope: QueryScope
    public let fields: [IndexField]
    public let state: IndexState?

    public enum QueryScope: String, Codable, Sendable, Equatable {
        case queryScopeUnspecified = "QUERY_SCOPE_UNSPECIFIED"
        case collection = "COLLECTION"
        case collectionGroup = "COLLECTION_GROUP"
        case collectionRecursive = "COLLECTION_RECURSIVE"
    }

    public struct IndexField: Codable, Sendable, Equatable {
        public let fieldPath: String
        public let order: Order?
        public let arrayConfig: ArrayConfig?
        public let vectorConfig: VectorConfig?

        public enum Order: String, Codable, Sendable, Equatable {
            case orderUnspecified = "ORDER_UNSPECIFIED"
            case ascending = "ASCENDING"
            case descending = "DESCENDING"
        }

        public enum ArrayConfig: String, Codable, Sendable, Equatable {
            case arrayConfigUnspecified = "ARRAY_CONFIG_UNSPECIFIED"
            case contains = "CONTAINS"
        }

        public struct VectorConfig: Codable, Sendable, Equatable {
            public let dimension: Int
            public let flat: Flat?

            public struct Flat: Codable, Sendable, Equatable {
                public init() {}
            }

            public init(dimension: Int, flat: Flat? = Flat()) {
                self.dimension = dimension
                self.flat = flat
            }
        }

        public init(fieldPath: String, order: Order? = nil, arrayConfig: ArrayConfig? = nil, vectorConfig: VectorConfig? = nil) {
            self.fieldPath = fieldPath
            self.order = order
            self.arrayConfig = arrayConfig
            self.vectorConfig = vectorConfig
        }
    }

    public enum IndexState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case ready = "READY"
        case needsRepair = "NEEDS_REPAIR"
    }

    public init(
        collectionGroup: String,
        projectID: String,
        databaseID: String = "(default)",
        queryScope: QueryScope = .collection,
        fields: [IndexField],
        state: IndexState? = nil
    ) {
        self.collectionGroup = collectionGroup
        self.projectID = projectID
        self.databaseID = databaseID
        self.queryScope = queryScope
        self.fields = fields
        self.state = state
    }

    /// Command to create the index
    public var createCommand: String {
        var cmd = "gcloud firestore indexes composite create --project=\(projectID) --collection-group=\(collectionGroup)"

        if databaseID != "(default)" {
            cmd += " --database=\(databaseID)"
        }

        let fieldConfigs = fields.map { field -> String in
            var config = "field-path=\(field.fieldPath)"
            if let order = field.order {
                config += ",order=\(order.rawValue)"
            }
            if field.arrayConfig == .contains {
                config += ",array-config=CONTAINS"
            }
            return config
        }

        cmd += " --field-config=\(fieldConfigs.joined(separator: ";"))"

        return cmd
    }

    /// Command to list indexes
    public static func listCommand(projectID: String, databaseID: String = "(default)") -> String {
        var cmd = "gcloud firestore indexes composite list --project=\(projectID)"
        if databaseID != "(default)" {
            cmd += " --database=\(databaseID)"
        }
        return cmd
    }
}

// MARK: - Firestore Export/Import

/// Represents a Firestore export operation
public struct GoogleCloudFirestoreExport: Codable, Sendable, Equatable {
    public let projectID: String
    public let databaseID: String
    public let outputUriPrefix: String
    public let collectionIds: [String]?
    public let namespaceIds: [String]?
    public let snapshotTime: Date?

    public init(
        projectID: String,
        databaseID: String = "(default)",
        outputUriPrefix: String,
        collectionIds: [String]? = nil,
        namespaceIds: [String]? = nil,
        snapshotTime: Date? = nil
    ) {
        self.projectID = projectID
        self.databaseID = databaseID
        self.outputUriPrefix = outputUriPrefix
        self.collectionIds = collectionIds
        self.namespaceIds = namespaceIds
        self.snapshotTime = snapshotTime
    }

    /// Command to export data
    public var exportCommand: String {
        var cmd = "gcloud firestore export \(outputUriPrefix) --project=\(projectID)"

        if databaseID != "(default)" {
            cmd += " --database=\(databaseID)"
        }

        if let collectionIds = collectionIds, !collectionIds.isEmpty {
            cmd += " --collection-ids=\(collectionIds.joined(separator: ","))"
        }

        if let namespaceIds = namespaceIds, !namespaceIds.isEmpty {
            cmd += " --namespace-ids=\(namespaceIds.joined(separator: ","))"
        }

        return cmd
    }
}

/// Represents a Firestore import operation
public struct GoogleCloudFirestoreImport: Codable, Sendable, Equatable {
    public let projectID: String
    public let databaseID: String
    public let inputUriPrefix: String
    public let collectionIds: [String]?
    public let namespaceIds: [String]?

    public init(
        projectID: String,
        databaseID: String = "(default)",
        inputUriPrefix: String,
        collectionIds: [String]? = nil,
        namespaceIds: [String]? = nil
    ) {
        self.projectID = projectID
        self.databaseID = databaseID
        self.inputUriPrefix = inputUriPrefix
        self.collectionIds = collectionIds
        self.namespaceIds = namespaceIds
    }

    /// Command to import data
    public var importCommand: String {
        var cmd = "gcloud firestore import \(inputUriPrefix) --project=\(projectID)"

        if databaseID != "(default)" {
            cmd += " --database=\(databaseID)"
        }

        if let collectionIds = collectionIds, !collectionIds.isEmpty {
            cmd += " --collection-ids=\(collectionIds.joined(separator: ","))"
        }

        if let namespaceIds = namespaceIds, !namespaceIds.isEmpty {
            cmd += " --namespace-ids=\(namespaceIds.joined(separator: ","))"
        }

        return cmd
    }
}

// MARK: - Firestore Operations

/// Helper operations for Firestore
public struct FirestoreOperations: Sendable {

    /// Command to enable Firestore API
    public static var enableAPICommand: String {
        "gcloud services enable firestore.googleapis.com"
    }

    /// Command to list operations
    public static func listOperationsCommand(projectID: String, databaseID: String = "(default)") -> String {
        var cmd = "gcloud firestore operations list --project=\(projectID)"
        if databaseID != "(default)" {
            cmd += " --database=\(databaseID)"
        }
        return cmd
    }

    /// Command to describe an operation
    public static func describeOperationCommand(operationName: String, projectID: String) -> String {
        "gcloud firestore operations describe \(operationName) --project=\(projectID)"
    }

    /// Command to cancel an operation
    public static func cancelOperationCommand(operationName: String, projectID: String) -> String {
        "gcloud firestore operations cancel \(operationName) --project=\(projectID)"
    }

    /// Command to list field indexes
    public static func listFieldsCommand(projectID: String, collectionGroup: String, databaseID: String = "(default)") -> String {
        var cmd = "gcloud firestore indexes fields list --project=\(projectID) --collection-group=\(collectionGroup)"
        if databaseID != "(default)" {
            cmd += " --database=\(databaseID)"
        }
        return cmd
    }

    /// Firestore emulator command
    public static func startEmulatorCommand(port: Int = 8080, projectID: String = "demo-project") -> String {
        "gcloud emulators firestore start --host-port=localhost:\(port) --project=\(projectID)"
    }
}

// MARK: - Firestore Location

/// Common Firestore locations
public struct FirestoreLocation: Sendable {
    /// Multi-region locations
    public static let nam5 = "nam5"  // United States
    public static let eur3 = "eur3"  // Europe

    /// Regional locations
    public static let usEast1 = "us-east1"
    public static let usEast4 = "us-east4"
    public static let usCentral = "us-central"
    public static let usWest1 = "us-west1"
    public static let usWest2 = "us-west2"
    public static let europeWest1 = "europe-west1"
    public static let europeWest2 = "europe-west2"
    public static let europeWest3 = "europe-west3"
    public static let asiaEast1 = "asia-east1"
    public static let asiaEast2 = "asia-east2"
    public static let asiaNortheast1 = "asia-northeast1"
    public static let asiaSoutheast1 = "asia-southeast1"
    public static let australiaSoutheast1 = "australia-southeast1"
}

// MARK: - DAIS Firestore Template

/// Production-ready Firestore templates for DAIS systems
public struct DAISFirestoreTemplate: Sendable {
    public let projectID: String
    public let databaseID: String
    public let location: String

    public init(
        projectID: String,
        databaseID: String = "(default)",
        location: String = FirestoreLocation.nam5
    ) {
        self.projectID = projectID
        self.databaseID = databaseID
        self.location = location
    }

    /// Main DAIS database configuration
    public var mainDatabase: GoogleCloudFirestoreDatabase {
        GoogleCloudFirestoreDatabase(
            name: databaseID,
            projectID: projectID,
            locationID: location,
            type: .firestoreNative,
            pointInTimeRecoveryEnablement: .pointInTimeRecoveryEnabled,
            deleteProtectionState: .deleteProtectionEnabled
        )
    }

    /// Analytics database (separate database for analytics data)
    public var analyticsDatabase: GoogleCloudFirestoreDatabase {
        GoogleCloudFirestoreDatabase(
            name: "dais-analytics",
            projectID: projectID,
            locationID: location,
            type: .firestoreNative,
            pointInTimeRecoveryEnablement: .pointInTimeRecoveryDisabled,
            deleteProtectionState: .deleteProtectionDisabled
        )
    }

    /// Datastore mode database for legacy compatibility
    public var datastoreModeDatabase: GoogleCloudFirestoreDatabase {
        GoogleCloudFirestoreDatabase(
            name: "dais-datastore",
            projectID: projectID,
            locationID: location,
            type: .datastoreMode
        )
    }

    /// Index for agents by status
    public var agentsByStatusIndex: GoogleCloudFirestoreIndex {
        GoogleCloudFirestoreIndex(
            collectionGroup: "agents",
            projectID: projectID,
            databaseID: databaseID,
            queryScope: .collection,
            fields: [
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "status", order: .ascending),
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "updatedAt", order: .descending)
            ]
        )
    }

    /// Index for tasks by agent and status
    public var tasksByAgentIndex: GoogleCloudFirestoreIndex {
        GoogleCloudFirestoreIndex(
            collectionGroup: "tasks",
            projectID: projectID,
            databaseID: databaseID,
            queryScope: .collection,
            fields: [
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "agentId", order: .ascending),
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "status", order: .ascending),
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "createdAt", order: .descending)
            ]
        )
    }

    /// Index for events collection group query
    public var eventsCollectionGroupIndex: GoogleCloudFirestoreIndex {
        GoogleCloudFirestoreIndex(
            collectionGroup: "events",
            projectID: projectID,
            databaseID: databaseID,
            queryScope: .collectionGroup,
            fields: [
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "eventType", order: .ascending),
                GoogleCloudFirestoreIndex.IndexField(fieldPath: "timestamp", order: .descending)
            ]
        )
    }

    /// Export configuration for daily backups
    public func dailyExport(bucketName: String) -> GoogleCloudFirestoreExport {
        let formatter = ISO8601DateFormatter()
        let dateStr = String(formatter.string(from: Date()).prefix(10))

        return GoogleCloudFirestoreExport(
            projectID: projectID,
            databaseID: databaseID,
            outputUriPrefix: "gs://\(bucketName)/firestore-exports/\(dateStr)"
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        DATABASE_ID="\(databaseID)"
        LOCATION="\(location)"

        echo "Enabling Firestore API..."
        gcloud services enable firestore.googleapis.com --project=$PROJECT_ID

        echo "Creating Firestore database..."
        \(mainDatabase.createCommand)

        echo "Waiting for database to be ready..."
        sleep 30

        echo "Creating indexes..."
        \(agentsByStatusIndex.createCommand)
        \(tasksByAgentIndex.createCommand)

        echo ""
        echo "DAIS Firestore setup complete!"
        echo ""
        echo "Database: $DATABASE_ID"
        echo "Location: $LOCATION"
        echo ""
        echo "Test connection with:"
        echo "  gcloud firestore databases describe --project=$PROJECT_ID"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        DATABASE_ID="\(databaseID)"

        echo "Deleting Firestore database..."
        \(mainDatabase.deleteCommand)

        echo "Firestore teardown complete!"
        """
    }
}
