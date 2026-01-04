// GoogleCloudBigQuery.swift
// BigQuery API for data warehouse and analytics

import Foundation

// MARK: - Dataset

/// Represents a BigQuery dataset
public struct GoogleCloudBigQueryDataset: Codable, Sendable, Equatable {
    public let datasetID: String
    public let projectID: String
    public let location: String?
    public let description: String?
    public let defaultTableExpirationMs: Int64?
    public let defaultPartitionExpirationMs: Int64?
    public let labels: [String: String]?
    public let access: [AccessEntry]?

    /// Access entry for dataset permissions
    public struct AccessEntry: Codable, Sendable, Equatable {
        public let role: Role
        public let userByEmail: String?
        public let groupByEmail: String?
        public let specialGroup: SpecialGroup?

        public enum Role: String, Codable, Sendable, Equatable {
            case reader = "READER"
            case writer = "WRITER"
            case owner = "OWNER"
        }

        public enum SpecialGroup: String, Codable, Sendable, Equatable {
            case projectOwners = "projectOwners"
            case projectReaders = "projectReaders"
            case projectWriters = "projectWriters"
            case allAuthenticatedUsers = "allAuthenticatedUsers"
        }

        public init(
            role: Role,
            userByEmail: String? = nil,
            groupByEmail: String? = nil,
            specialGroup: SpecialGroup? = nil
        ) {
            self.role = role
            self.userByEmail = userByEmail
            self.groupByEmail = groupByEmail
            self.specialGroup = specialGroup
        }
    }

    public init(
        datasetID: String,
        projectID: String,
        location: String? = nil,
        description: String? = nil,
        defaultTableExpirationMs: Int64? = nil,
        defaultPartitionExpirationMs: Int64? = nil,
        labels: [String: String]? = nil,
        access: [AccessEntry]? = nil
    ) {
        self.datasetID = datasetID
        self.projectID = projectID
        self.location = location
        self.description = description
        self.defaultTableExpirationMs = defaultTableExpirationMs
        self.defaultPartitionExpirationMs = defaultPartitionExpirationMs
        self.labels = labels
        self.access = access
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/datasets/\(datasetID)"
    }

    /// Create command
    public var createCommand: String {
        var cmd = "bq mk --dataset"
        if let location = location {
            cmd += " --location=\(location)"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let defaultExp = defaultTableExpirationMs {
            cmd += " --default_table_expiration=\(defaultExp / 1000)"
        }
        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key):\($0.value)" }.joined(separator: ",")
            cmd += " --label=\(labelString)"
        }
        cmd += " \(projectID):\(datasetID)"
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "bq show --format=prettyjson \(projectID):\(datasetID)"
    }

    /// Delete command
    public var deleteCommand: String {
        "bq rm -r -f -d \(projectID):\(datasetID)"
    }

    /// Update command
    public func updateCommand(description: String? = nil, expirationMs: Int64? = nil) -> String {
        var cmd = "bq update"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let exp = expirationMs {
            cmd += " --default_table_expiration=\(exp / 1000)"
        }
        cmd += " \(projectID):\(datasetID)"
        return cmd
    }

    /// List datasets command
    public static func listCommand(projectID: String) -> String {
        "bq ls --format=prettyjson --project_id=\(projectID)"
    }
}

// MARK: - Table

/// Represents a BigQuery table
public struct GoogleCloudBigQueryTable: Codable, Sendable, Equatable {
    public let tableID: String
    public let datasetID: String
    public let projectID: String
    public let schema: Schema?
    public let description: String?
    public let expirationTime: Int64?
    public let partitioning: Partitioning?
    public let clustering: Clustering?
    public let labels: [String: String]?

    /// Schema definition
    public struct Schema: Codable, Sendable, Equatable {
        public let fields: [Field]

        public struct Field: Codable, Sendable, Equatable {
            public let name: String
            public let type: FieldType
            public let mode: Mode?
            public let description: String?
            public let fields: [Field]?

            public enum FieldType: String, Codable, Sendable, Equatable {
                case string = "STRING"
                case bytes = "BYTES"
                case integer = "INTEGER"
                case int64 = "INT64"
                case float = "FLOAT"
                case float64 = "FLOAT64"
                case numeric = "NUMERIC"
                case bignumeric = "BIGNUMERIC"
                case boolean = "BOOLEAN"
                case bool = "BOOL"
                case timestamp = "TIMESTAMP"
                case date = "DATE"
                case time = "TIME"
                case datetime = "DATETIME"
                case geography = "GEOGRAPHY"
                case record = "RECORD"
                case struct_ = "STRUCT"
                case json = "JSON"
            }

            public enum Mode: String, Codable, Sendable, Equatable {
                case nullable = "NULLABLE"
                case required = "REQUIRED"
                case repeated = "REPEATED"
            }

            public init(
                name: String,
                type: FieldType,
                mode: Mode? = nil,
                description: String? = nil,
                fields: [Field]? = nil
            ) {
                self.name = name
                self.type = type
                self.mode = mode
                self.description = description
                self.fields = fields
            }
        }

        public init(fields: [Field]) {
            self.fields = fields
        }
    }

    /// Time-based partitioning configuration
    public struct Partitioning: Codable, Sendable, Equatable {
        public let type: PartitionType
        public let field: String?
        public let expirationMs: Int64?

        public enum PartitionType: String, Codable, Sendable, Equatable {
            case day = "DAY"
            case hour = "HOUR"
            case month = "MONTH"
            case year = "YEAR"
        }

        public init(type: PartitionType, field: String? = nil, expirationMs: Int64? = nil) {
            self.type = type
            self.field = field
            self.expirationMs = expirationMs
        }
    }

    /// Clustering configuration
    public struct Clustering: Codable, Sendable, Equatable {
        public let fields: [String]

        public init(fields: [String]) {
            self.fields = fields
        }
    }

    public init(
        tableID: String,
        datasetID: String,
        projectID: String,
        schema: Schema? = nil,
        description: String? = nil,
        expirationTime: Int64? = nil,
        partitioning: Partitioning? = nil,
        clustering: Clustering? = nil,
        labels: [String: String]? = nil
    ) {
        self.tableID = tableID
        self.datasetID = datasetID
        self.projectID = projectID
        self.schema = schema
        self.description = description
        self.expirationTime = expirationTime
        self.partitioning = partitioning
        self.clustering = clustering
        self.labels = labels
    }

    /// Full table reference
    public var tableReference: String {
        "\(projectID):\(datasetID).\(tableID)"
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/datasets/\(datasetID)/tables/\(tableID)"
    }

    /// Create command with schema file
    public func createCommand(schemaFile: String) -> String {
        var cmd = "bq mk --table"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let partitioning = partitioning {
            if let field = partitioning.field {
                cmd += " --time_partitioning_field=\(field)"
            }
            cmd += " --time_partitioning_type=\(partitioning.type.rawValue)"
            if let exp = partitioning.expirationMs {
                cmd += " --time_partitioning_expiration=\(exp / 1000)"
            }
        }
        if let clustering = clustering, !clustering.fields.isEmpty {
            cmd += " --clustering_fields=\(clustering.fields.joined(separator: ","))"
        }
        cmd += " \(tableReference) \(schemaFile)"
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "bq show --format=prettyjson \(tableReference)"
    }

    /// Delete command
    public var deleteCommand: String {
        "bq rm -f -t \(tableReference)"
    }

    /// Get schema command
    public var getSchemaCommand: String {
        "bq show --schema --format=prettyjson \(tableReference)"
    }

    /// List tables command
    public static func listCommand(projectID: String, datasetID: String) -> String {
        "bq ls --format=prettyjson \(projectID):\(datasetID)"
    }
}

// MARK: - Query Job

/// Represents a BigQuery query job
public struct GoogleCloudBigQueryJob: Codable, Sendable, Equatable {
    public let jobID: String?
    public let projectID: String
    public let location: String?
    public let query: String
    public let destinationTable: String?
    public let writeDisposition: WriteDisposition?
    public let createDisposition: CreateDisposition?
    public let useLegacySql: Bool?
    public let maximumBytesBilled: Int64?
    public let labels: [String: String]?

    /// Write disposition for destination table
    public enum WriteDisposition: String, Codable, Sendable, Equatable {
        case writeEmpty = "WRITE_EMPTY"
        case writeAppend = "WRITE_APPEND"
        case writeTruncate = "WRITE_TRUNCATE"
    }

    /// Create disposition for destination table
    public enum CreateDisposition: String, Codable, Sendable, Equatable {
        case createIfNeeded = "CREATE_IF_NEEDED"
        case createNever = "CREATE_NEVER"
    }

    public init(
        jobID: String? = nil,
        projectID: String,
        location: String? = nil,
        query: String,
        destinationTable: String? = nil,
        writeDisposition: WriteDisposition? = nil,
        createDisposition: CreateDisposition? = nil,
        useLegacySql: Bool? = false,
        maximumBytesBilled: Int64? = nil,
        labels: [String: String]? = nil
    ) {
        self.jobID = jobID
        self.projectID = projectID
        self.location = location
        self.query = query
        self.destinationTable = destinationTable
        self.writeDisposition = writeDisposition
        self.createDisposition = createDisposition
        self.useLegacySql = useLegacySql
        self.maximumBytesBilled = maximumBytesBilled
        self.labels = labels
    }

    /// Run query command (interactive)
    public var queryCommand: String {
        var cmd = "bq query"
        if let location = location {
            cmd += " --location=\(location)"
        }
        if useLegacySql != true {
            cmd += " --use_legacy_sql=false"
        }
        if let dest = destinationTable {
            cmd += " --destination_table=\(dest)"
        }
        if let writeDisp = writeDisposition {
            cmd += " --replace" // For WRITE_TRUNCATE
            if writeDisp == .writeAppend {
                cmd += " --append_table"
            }
        }
        if let maxBytes = maximumBytesBilled {
            cmd += " --maximum_bytes_billed=\(maxBytes)"
        }
        cmd += " --format=prettyjson"
        cmd += " '\(query.replacingOccurrences(of: "'", with: "'\\''"))'"
        return cmd
    }

    /// Get job info command
    public var infoCommand: String {
        guard let jobID = jobID else { return "" }
        var cmd = "bq show --format=prettyjson --job=true"
        if let location = location {
            cmd += " --location=\(location)"
        }
        cmd += " \(projectID):\(jobID)"
        return cmd
    }

    /// Cancel job command
    public var cancelCommand: String {
        guard let jobID = jobID else { return "" }
        var cmd = "bq cancel"
        if let location = location {
            cmd += " --location=\(location)"
        }
        cmd += " \(projectID):\(jobID)"
        return cmd
    }

    /// List jobs command
    public static func listCommand(projectID: String, allUsers: Bool = false) -> String {
        var cmd = "bq ls --jobs=true --format=prettyjson --project_id=\(projectID)"
        if allUsers {
            cmd += " --all"
        }
        return cmd
    }
}

// MARK: - View

/// Represents a BigQuery view
public struct GoogleCloudBigQueryView: Codable, Sendable, Equatable {
    public let viewID: String
    public let datasetID: String
    public let projectID: String
    public let query: String
    public let description: String?
    public let useLegacySql: Bool?

    public init(
        viewID: String,
        datasetID: String,
        projectID: String,
        query: String,
        description: String? = nil,
        useLegacySql: Bool? = false
    ) {
        self.viewID = viewID
        self.datasetID = datasetID
        self.projectID = projectID
        self.query = query
        self.description = description
        self.useLegacySql = useLegacySql
    }

    /// View reference
    public var viewReference: String {
        "\(projectID):\(datasetID).\(viewID)"
    }

    /// Create view command
    public var createCommand: String {
        var cmd = "bq mk --view"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if useLegacySql != true {
            cmd += " --use_legacy_sql=false"
        }
        cmd += " '\(query.replacingOccurrences(of: "'", with: "'\\''"))'"
        cmd += " \(viewReference)"
        return cmd
    }

    /// Update view command
    public var updateCommand: String {
        var cmd = "bq update --view"
        if useLegacySql != true {
            cmd += " --use_legacy_sql=false"
        }
        cmd += " '\(query.replacingOccurrences(of: "'", with: "'\\''"))'"
        cmd += " \(viewReference)"
        return cmd
    }

    /// Delete view command
    public var deleteCommand: String {
        "bq rm -f -t \(viewReference)"
    }
}

// MARK: - BigQuery Operations

/// Operations helper for BigQuery
public struct BigQueryOperations {

    /// Enable BigQuery API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable bigquery.googleapis.com --project=\(projectID)"
    }

    /// Load data from GCS
    public static func loadFromGCSCommand(
        sourceURI: String,
        destinationTable: String,
        sourceFormat: SourceFormat = .csv,
        writeDisposition: GoogleCloudBigQueryJob.WriteDisposition = .writeTruncate,
        autodetect: Bool = true
    ) -> String {
        var cmd = "bq load"
        cmd += " --source_format=\(sourceFormat.rawValue)"
        if writeDisposition == .writeTruncate {
            cmd += " --replace"
        } else if writeDisposition == .writeAppend {
            cmd += " --append_table"
        }
        if autodetect {
            cmd += " --autodetect"
        }
        cmd += " \(destinationTable) \(sourceURI)"
        return cmd
    }

    /// Source format for data loading
    public enum SourceFormat: String {
        case csv = "CSV"
        case json = "NEWLINE_DELIMITED_JSON"
        case avro = "AVRO"
        case parquet = "PARQUET"
        case orc = "ORC"
    }

    /// Export table to GCS
    public static func exportToGCSCommand(
        sourceTable: String,
        destinationURI: String,
        format: ExportFormat = .csv
    ) -> String {
        var cmd = "bq extract"
        cmd += " --destination_format=\(format.rawValue)"
        cmd += " \(sourceTable) \(destinationURI)"
        return cmd
    }

    /// Export format
    public enum ExportFormat: String {
        case csv = "CSV"
        case json = "NEWLINE_DELIMITED_JSON"
        case avro = "AVRO"
    }

    /// Copy table
    public static func copyTableCommand(
        source: String,
        destination: String,
        writeDisposition: GoogleCloudBigQueryJob.WriteDisposition = .writeTruncate
    ) -> String {
        var cmd = "bq cp"
        if writeDisposition == .writeAppend {
            cmd += " --append_table"
        }
        cmd += " \(source) \(destination)"
        return cmd
    }

    /// Get table preview
    public static func previewCommand(table: String, maxRows: Int = 10) -> String {
        "bq head -n \(maxRows) \(table)"
    }

    /// Dry run query (estimate cost)
    public static func dryRunCommand(query: String) -> String {
        "bq query --dry_run --use_legacy_sql=false '\(query.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}

// MARK: - DAIS BigQuery Template

/// BigQuery templates for DAIS deployments
public struct DAISBigQueryTemplate {

    /// Create analytics dataset
    public static func analyticsDataset(
        projectID: String,
        deploymentName: String,
        location: String = "US"
    ) -> GoogleCloudBigQueryDataset {
        GoogleCloudBigQueryDataset(
            datasetID: "\(deploymentName.replacingOccurrences(of: "-", with: "_"))_analytics",
            projectID: projectID,
            location: location,
            description: "Analytics data for \(deploymentName)",
            defaultTableExpirationMs: nil,
            labels: [
                "deployment": deploymentName,
                "purpose": "analytics"
            ]
        )
    }

    /// Create logs dataset with expiration
    public static func logsDataset(
        projectID: String,
        deploymentName: String,
        location: String = "US",
        expirationDays: Int = 90
    ) -> GoogleCloudBigQueryDataset {
        GoogleCloudBigQueryDataset(
            datasetID: "\(deploymentName.replacingOccurrences(of: "-", with: "_"))_logs",
            projectID: projectID,
            location: location,
            description: "Logs sink for \(deploymentName)",
            defaultTableExpirationMs: Int64(expirationDays) * 24 * 60 * 60 * 1000,
            labels: [
                "deployment": deploymentName,
                "purpose": "logs"
            ]
        )
    }

    /// Common events table schema
    public static func eventsTableSchema() -> GoogleCloudBigQueryTable.Schema {
        GoogleCloudBigQueryTable.Schema(fields: [
            GoogleCloudBigQueryTable.Schema.Field(name: "event_id", type: .string, mode: .required),
            GoogleCloudBigQueryTable.Schema.Field(name: "event_type", type: .string, mode: .required),
            GoogleCloudBigQueryTable.Schema.Field(name: "event_timestamp", type: .timestamp, mode: .required),
            GoogleCloudBigQueryTable.Schema.Field(name: "user_id", type: .string, mode: .nullable),
            GoogleCloudBigQueryTable.Schema.Field(name: "session_id", type: .string, mode: .nullable),
            GoogleCloudBigQueryTable.Schema.Field(name: "properties", type: .json, mode: .nullable),
            GoogleCloudBigQueryTable.Schema.Field(name: "created_at", type: .timestamp, mode: .required)
        ])
    }

    /// Create events table with partitioning
    public static func eventsTable(
        projectID: String,
        datasetID: String,
        deploymentName: String
    ) -> GoogleCloudBigQueryTable {
        GoogleCloudBigQueryTable(
            tableID: "events",
            datasetID: datasetID,
            projectID: projectID,
            schema: eventsTableSchema(),
            description: "Event tracking table for \(deploymentName)",
            partitioning: GoogleCloudBigQueryTable.Partitioning(
                type: .day,
                field: "event_timestamp",
                expirationMs: 365 * 24 * 60 * 60 * 1000
            ),
            clustering: GoogleCloudBigQueryTable.Clustering(
                fields: ["event_type", "user_id"]
            ),
            labels: [
                "deployment": deploymentName,
                "table_type": "events"
            ]
        )
    }

    /// Daily aggregation view
    public static func dailyAggregationView(
        projectID: String,
        datasetID: String,
        deploymentName: String
    ) -> GoogleCloudBigQueryView {
        GoogleCloudBigQueryView(
            viewID: "daily_event_counts",
            datasetID: datasetID,
            projectID: projectID,
            query: """
            SELECT
                DATE(event_timestamp) as event_date,
                event_type,
                COUNT(*) as event_count,
                COUNT(DISTINCT user_id) as unique_users
            FROM `\(projectID).\(datasetID).events`
            GROUP BY event_date, event_type
            ORDER BY event_date DESC
            """,
            description: "Daily event count aggregation for \(deploymentName)"
        )
    }

    /// Setup script
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        location: String = "US"
    ) -> String {
        let datasetID = deploymentName.replacingOccurrences(of: "-", with: "_") + "_analytics"
        return """
        #!/bin/bash
        set -e

        # BigQuery Setup for \(deploymentName)
        # Project: \(projectID)
        # Location: \(location)

        echo "Enabling BigQuery API..."
        gcloud services enable bigquery.googleapis.com --project=\(projectID)

        echo "Creating analytics dataset..."
        bq mk --dataset \\
            --location=\(location) \\
            --description="Analytics data for \(deploymentName)" \\
            --label=deployment:\(deploymentName) \\
            \(projectID):\(datasetID)

        echo "Creating events table..."
        bq mk --table \\
            --time_partitioning_field=event_timestamp \\
            --time_partitioning_type=DAY \\
            --clustering_fields=event_type,user_id \\
            --description="Event tracking table" \\
            \(projectID):\(datasetID).events \\
            event_id:STRING,event_type:STRING,event_timestamp:TIMESTAMP,user_id:STRING,session_id:STRING,properties:JSON,created_at:TIMESTAMP

        echo "Creating daily aggregation view..."
        bq mk --view \\
            --use_legacy_sql=false \\
            --description="Daily event aggregation" \\
            "SELECT DATE(event_timestamp) as event_date, event_type, COUNT(*) as event_count, COUNT(DISTINCT user_id) as unique_users FROM \\`\(projectID).\(datasetID).events\\` GROUP BY event_date, event_type ORDER BY event_date DESC" \\
            \(projectID):\(datasetID).daily_event_counts

        echo "BigQuery setup complete!"
        echo "Dataset: \(datasetID)"
        """
    }

    /// Teardown script
    public static func teardownScript(
        projectID: String,
        deploymentName: String
    ) -> String {
        let datasetID = deploymentName.replacingOccurrences(of: "-", with: "_") + "_analytics"
        return """
        #!/bin/bash
        set -e

        # BigQuery Teardown for \(deploymentName)

        echo "Deleting analytics dataset and all tables..."
        bq rm -r -f -d \(projectID):\(datasetID) || true

        echo "Deleting logs dataset if exists..."
        bq rm -r -f -d \(projectID):\(deploymentName.replacingOccurrences(of: "-", with: "_"))_logs || true

        echo "BigQuery teardown complete!"
        """
    }
}
