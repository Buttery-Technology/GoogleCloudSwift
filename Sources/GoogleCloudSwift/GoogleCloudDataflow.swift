// GoogleCloudDataflow.swift
// Dataflow API for batch and streaming data processing

import Foundation

// MARK: - Dataflow Job

/// Represents a Dataflow job
public struct GoogleCloudDataflowJob: Codable, Sendable, Equatable {
    public let jobID: String?
    public let name: String
    public let projectID: String
    public let region: String
    public let type: JobType
    public let state: JobState?
    public let templatePath: String?
    public let containerSpecGcsPath: String?
    public let parameters: [String: String]?
    public let environment: EnvironmentConfig?
    public let labels: [String: String]?

    /// Job type
    public enum JobType: String, Codable, Sendable, Equatable {
        case batch = "JOB_TYPE_BATCH"
        case streaming = "JOB_TYPE_STREAMING"
    }

    /// Job state
    public enum JobState: String, Codable, Sendable, Equatable {
        case unknown = "JOB_STATE_UNKNOWN"
        case stopped = "JOB_STATE_STOPPED"
        case running = "JOB_STATE_RUNNING"
        case done = "JOB_STATE_DONE"
        case failed = "JOB_STATE_FAILED"
        case cancelled = "JOB_STATE_CANCELLED"
        case updated = "JOB_STATE_UPDATED"
        case draining = "JOB_STATE_DRAINING"
        case drained = "JOB_STATE_DRAINED"
        case pending = "JOB_STATE_PENDING"
        case cancelling = "JOB_STATE_CANCELLING"
        case queued = "JOB_STATE_QUEUED"
    }

    /// Environment configuration
    public struct EnvironmentConfig: Codable, Sendable, Equatable {
        public let tempLocation: String?
        public let zone: String?
        public let region: String?
        public let machineType: String?
        public let numWorkers: Int?
        public let maxWorkers: Int?
        public let network: String?
        public let subnetwork: String?
        public let serviceAccountEmail: String?
        public let enableStreamingEngine: Bool?
        public let workerDiskType: DiskType?
        public let diskSizeGb: Int?
        public let additionalExperiments: [String]?
        public let additionalUserLabels: [String: String]?

        public enum DiskType: String, Codable, Sendable, Equatable {
            case pd = "compute.googleapis.com/projects/PROJECT/zones/ZONE/diskTypes/pd-standard"
            case pdSsd = "pd-ssd"
            case pdStandard = "pd-standard"
            case pdBalanced = "pd-balanced"
        }

        public init(
            tempLocation: String? = nil,
            zone: String? = nil,
            region: String? = nil,
            machineType: String? = nil,
            numWorkers: Int? = nil,
            maxWorkers: Int? = nil,
            network: String? = nil,
            subnetwork: String? = nil,
            serviceAccountEmail: String? = nil,
            enableStreamingEngine: Bool? = nil,
            workerDiskType: DiskType? = nil,
            diskSizeGb: Int? = nil,
            additionalExperiments: [String]? = nil,
            additionalUserLabels: [String: String]? = nil
        ) {
            self.tempLocation = tempLocation
            self.zone = zone
            self.region = region
            self.machineType = machineType
            self.numWorkers = numWorkers
            self.maxWorkers = maxWorkers
            self.network = network
            self.subnetwork = subnetwork
            self.serviceAccountEmail = serviceAccountEmail
            self.enableStreamingEngine = enableStreamingEngine
            self.workerDiskType = workerDiskType
            self.diskSizeGb = diskSizeGb
            self.additionalExperiments = additionalExperiments
            self.additionalUserLabels = additionalUserLabels
        }
    }

    public init(
        jobID: String? = nil,
        name: String,
        projectID: String,
        region: String,
        type: JobType = .batch,
        state: JobState? = nil,
        templatePath: String? = nil,
        containerSpecGcsPath: String? = nil,
        parameters: [String: String]? = nil,
        environment: EnvironmentConfig? = nil,
        labels: [String: String]? = nil
    ) {
        self.jobID = jobID
        self.name = name
        self.projectID = projectID
        self.region = region
        self.type = type
        self.state = state
        self.templatePath = templatePath
        self.containerSpecGcsPath = containerSpecGcsPath
        self.parameters = parameters
        self.environment = environment
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        if let jobID = jobID {
            return "projects/\(projectID)/locations/\(region)/jobs/\(jobID)"
        }
        return "projects/\(projectID)/locations/\(region)/jobs/\(name)"
    }

    /// Run classic template command
    public var runClassicTemplateCommand: String {
        var cmd = "gcloud dataflow jobs run \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if let templatePath = templatePath {
            cmd += " --gcs-location=\(templatePath)"
        }
        if let parameters = parameters, !parameters.isEmpty {
            let paramsString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --parameters=\(paramsString)"
        }
        if let env = environment {
            if let tempLocation = env.tempLocation {
                cmd += " --staging-location=\(tempLocation)"
            }
            if let zone = env.zone {
                cmd += " --zone=\(zone)"
            }
            if let machineType = env.machineType {
                cmd += " --worker-machine-type=\(machineType)"
            }
            if let numWorkers = env.numWorkers {
                cmd += " --num-workers=\(numWorkers)"
            }
            if let maxWorkers = env.maxWorkers {
                cmd += " --max-workers=\(maxWorkers)"
            }
            if let network = env.network {
                cmd += " --network=\(network)"
            }
            if let subnetwork = env.subnetwork {
                cmd += " --subnetwork=\(subnetwork)"
            }
            if let serviceAccount = env.serviceAccountEmail {
                cmd += " --service-account-email=\(serviceAccount)"
            }
            if env.enableStreamingEngine == true {
                cmd += " --enable-streaming-engine"
            }
        }
        if let labels = labels, !labels.isEmpty {
            for (key, value) in labels {
                cmd += " --additional-user-labels=\(key)=\(value)"
            }
        }
        return cmd
    }

    /// Run flex template command
    public var runFlexTemplateCommand: String {
        var cmd = "gcloud dataflow flex-template run \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if let containerSpec = containerSpecGcsPath {
            cmd += " --template-file-gcs-location=\(containerSpec)"
        }
        if let parameters = parameters, !parameters.isEmpty {
            let paramsString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --parameters=\(paramsString)"
        }
        if let env = environment {
            if let tempLocation = env.tempLocation {
                cmd += " --staging-location=\(tempLocation)"
            }
            if let machineType = env.machineType {
                cmd += " --worker-machine-type=\(machineType)"
            }
            if let numWorkers = env.numWorkers {
                cmd += " --num-workers=\(numWorkers)"
            }
            if let maxWorkers = env.maxWorkers {
                cmd += " --max-workers=\(maxWorkers)"
            }
            if let network = env.network {
                cmd += " --network=\(network)"
            }
            if let subnetwork = env.subnetwork {
                cmd += " --subnetwork=\(subnetwork)"
            }
            if let serviceAccount = env.serviceAccountEmail {
                cmd += " --service-account-email=\(serviceAccount)"
            }
            if env.enableStreamingEngine == true {
                cmd += " --enable-streaming-engine"
            }
        }
        if let labels = labels, !labels.isEmpty {
            for (key, value) in labels {
                cmd += " --additional-user-labels=\(key)=\(value)"
            }
        }
        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        guard let jobID = jobID else { return "" }
        return "gcloud dataflow jobs describe \(jobID) --project=\(projectID) --region=\(region)"
    }

    /// Cancel command
    public var cancelCommand: String {
        guard let jobID = jobID else { return "" }
        return "gcloud dataflow jobs cancel \(jobID) --project=\(projectID) --region=\(region)"
    }

    /// Drain command (for streaming jobs)
    public var drainCommand: String {
        guard let jobID = jobID else { return "" }
        return "gcloud dataflow jobs drain \(jobID) --project=\(projectID) --region=\(region)"
    }

    /// List jobs command
    public static func listCommand(projectID: String, region: String, status: JobState? = nil) -> String {
        var cmd = "gcloud dataflow jobs list --project=\(projectID) --region=\(region)"
        if let status = status {
            let statusStr = status.rawValue.replacingOccurrences(of: "JOB_STATE_", with: "").lowercased()
            cmd += " --status=\(statusStr)"
        }
        return cmd
    }
}

// MARK: - Flex Template

/// Represents a Dataflow Flex Template
public struct GoogleCloudDataflowFlexTemplate: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let templatePath: String
    public let containerImage: String
    public let metadata: TemplateMetadata?
    public let sdkInfo: SDKInfo?

    /// Template metadata
    public struct TemplateMetadata: Codable, Sendable, Equatable {
        public let name: String?
        public let description: String?
        public let parameters: [ParameterMetadata]?

        public struct ParameterMetadata: Codable, Sendable, Equatable {
            public let name: String
            public let label: String?
            public let helpText: String?
            public let isOptional: Bool?
            public let regexes: [String]?

            public init(
                name: String,
                label: String? = nil,
                helpText: String? = nil,
                isOptional: Bool? = nil,
                regexes: [String]? = nil
            ) {
                self.name = name
                self.label = label
                self.helpText = helpText
                self.isOptional = isOptional
                self.regexes = regexes
            }
        }

        public init(
            name: String? = nil,
            description: String? = nil,
            parameters: [ParameterMetadata]? = nil
        ) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }

    /// SDK information
    public struct SDKInfo: Codable, Sendable, Equatable {
        public let language: Language
        public let version: String?

        public enum Language: String, Codable, Sendable, Equatable {
            case java = "JAVA"
            case python = "PYTHON"
            case go = "GO"
        }

        public init(language: Language, version: String? = nil) {
            self.language = language
            self.version = version
        }
    }

    public init(
        name: String,
        projectID: String,
        templatePath: String,
        containerImage: String,
        metadata: TemplateMetadata? = nil,
        sdkInfo: SDKInfo? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.templatePath = templatePath
        self.containerImage = containerImage
        self.metadata = metadata
        self.sdkInfo = sdkInfo
    }

    /// Build template command
    public func buildTemplateCommand(
        jarPath: String? = nil,
        pythonPath: String? = nil,
        tempLocation: String
    ) -> String {
        var cmd = "gcloud dataflow flex-template build \(templatePath)"
        cmd += " --project=\(projectID)"
        cmd += " --image=\(containerImage)"
        if let jar = jarPath {
            cmd += " --jar=\(jar)"
        }
        if let python = pythonPath {
            cmd += " --py-path=\(python)"
        }
        cmd += " --temp-location=\(tempLocation)"
        if let metadata = metadata {
            if let name = metadata.name {
                cmd += " --metadata-file=\(name)"
            }
        }
        return cmd
    }
}

// MARK: - Dataflow SQL

/// Represents a Dataflow SQL query
public struct GoogleCloudDataflowSQL: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let query: String
    public let bigqueryDataset: String?
    public let bigqueryTable: String?
    public let pubsubTopic: String?
    public let dryRun: Bool?

    public init(
        name: String,
        projectID: String,
        region: String,
        query: String,
        bigqueryDataset: String? = nil,
        bigqueryTable: String? = nil,
        pubsubTopic: String? = nil,
        dryRun: Bool? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.query = query
        self.bigqueryDataset = bigqueryDataset
        self.bigqueryTable = bigqueryTable
        self.pubsubTopic = pubsubTopic
        self.dryRun = dryRun
    }

    /// Run SQL command
    public var runCommand: String {
        var cmd = "gcloud dataflow sql query"
        cmd += " '\(query.replacingOccurrences(of: "'", with: "'\\''"))'"
        cmd += " --job-name=\(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if let dataset = bigqueryDataset {
            cmd += " --bigquery-dataset=\(dataset)"
        }
        if let table = bigqueryTable {
            cmd += " --bigquery-table=\(table)"
        }
        if let topic = pubsubTopic {
            cmd += " --pubsub-topic=\(topic)"
        }
        if dryRun == true {
            cmd += " --dry-run"
        }
        return cmd
    }
}

// MARK: - Dataflow Snapshot

/// Represents a Dataflow job snapshot
public struct GoogleCloudDataflowSnapshot: Codable, Sendable, Equatable {
    public let snapshotID: String?
    public let projectID: String
    public let region: String
    public let sourceJobID: String
    public let description: String?
    public let ttl: String?

    public init(
        snapshotID: String? = nil,
        projectID: String,
        region: String,
        sourceJobID: String,
        description: String? = nil,
        ttl: String? = nil
    ) {
        self.snapshotID = snapshotID
        self.projectID = projectID
        self.region = region
        self.sourceJobID = sourceJobID
        self.description = description
        self.ttl = ttl
    }

    /// Create snapshot command
    public var createCommand: String {
        var cmd = "gcloud dataflow snapshots create"
        cmd += " --job-id=\(sourceJobID)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if let description = description {
            cmd += " --snapshot-description=\"\(description)\""
        }
        if let ttl = ttl {
            cmd += " --snapshot-ttl=\(ttl)"
        }
        return cmd
    }

    /// Delete snapshot command
    public var deleteCommand: String {
        guard let snapshotID = snapshotID else { return "" }
        return "gcloud dataflow snapshots delete \(snapshotID) --project=\(projectID) --region=\(region)"
    }

    /// Describe snapshot command
    public var describeCommand: String {
        guard let snapshotID = snapshotID else { return "" }
        return "gcloud dataflow snapshots describe \(snapshotID) --project=\(projectID) --region=\(region)"
    }

    /// List snapshots command
    public static func listCommand(projectID: String, region: String, jobID: String? = nil) -> String {
        var cmd = "gcloud dataflow snapshots list --project=\(projectID) --region=\(region)"
        if let jobID = jobID {
            cmd += " --job-id=\(jobID)"
        }
        return cmd
    }
}

// MARK: - Dataflow Operations

/// Operations helper for Dataflow
public struct DataflowOperations {

    /// Enable Dataflow API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable dataflow.googleapis.com --project=\(projectID)"
    }

    /// Get metrics for a job
    public static func metricsCommand(jobID: String, projectID: String, region: String) -> String {
        "gcloud dataflow metrics list \(jobID) --project=\(projectID) --region=\(region)"
    }

    /// Get logs for a job
    public static func logsCommand(jobID: String, projectID: String, region: String) -> String {
        "gcloud dataflow logs list \(jobID) --project=\(projectID) --region=\(region)"
    }

    /// Update streaming job
    public static func updateJobCommand(
        jobID: String,
        projectID: String,
        region: String,
        templatePath: String? = nil,
        parameters: [String: String]? = nil
    ) -> String {
        var cmd = "gcloud dataflow jobs update-options"
        cmd += " --job-id=\(jobID)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        if let templatePath = templatePath {
            cmd += " --template-gcs-path=\(templatePath)"
        }
        if let parameters = parameters, !parameters.isEmpty {
            let paramsString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --transform-name-mappings=\(paramsString)"
        }
        return cmd
    }

    /// List available templates
    public static func listTemplatesCommand(projectID: String, region: String) -> String {
        "gcloud dataflow flex-template list --project=\(projectID) --region=\(region)"
    }
}

// MARK: - Google-Provided Templates

/// Common Google-provided Dataflow templates
public struct GoogleDataflowTemplates {

    /// Word count template (classic)
    public static let wordCount = "gs://dataflow-templates/latest/Word_Count"

    /// Text to BigQuery template
    public static let textToBigQuery = "gs://dataflow-templates/latest/GCS_Text_to_BigQuery"

    /// BigQuery to GCS template
    public static let bigQueryToGCS = "gs://dataflow-templates/latest/BigQuery_to_GCS_Export"

    /// Pub/Sub to BigQuery template
    public static let pubSubToBigQuery = "gs://dataflow-templates/latest/PubSub_to_BigQuery"

    /// Pub/Sub to GCS text template
    public static let pubSubToGCSText = "gs://dataflow-templates/latest/Cloud_PubSub_to_GCS_Text"

    /// GCS to Pub/Sub template
    public static let gcsToPubSub = "gs://dataflow-templates/latest/GCS_Text_to_Cloud_PubSub"

    /// Pub/Sub to Pub/Sub template
    public static let pubSubToPubSub = "gs://dataflow-templates/latest/Cloud_PubSub_to_Cloud_PubSub"

    /// BigQuery to Cloud Storage Parquet
    public static let bigQueryToParquet = "gs://dataflow-templates/latest/BigQuery_to_Parquet"

    /// Spanner to GCS Avro
    public static let spannerToGCSAvro = "gs://dataflow-templates/latest/Cloud_Spanner_to_GCS_Avro"

    /// GCS Avro to Spanner
    public static let gcsAvroToSpanner = "gs://dataflow-templates/latest/GCS_Avro_to_Cloud_Spanner"

    /// Datastore to GCS Text
    public static let datastoreToGCSText = "gs://dataflow-templates/latest/Datastore_to_GCS_Text"

    /// GCS Text to Datastore
    public static let gcsTextToDatastore = "gs://dataflow-templates/latest/GCS_Text_to_Datastore"

    /// Bulk Compress GCS Files
    public static let bulkCompressFiles = "gs://dataflow-templates/latest/Bulk_Compress_GCS_Files"

    /// Bulk Decompress GCS Files
    public static let bulkDecompressFiles = "gs://dataflow-templates/latest/Bulk_Decompress_GCS_Files"

    /// JDBC to BigQuery
    public static let jdbcToBigQuery = "gs://dataflow-templates/latest/Jdbc_to_BigQuery"

    /// Kafka to BigQuery
    public static let kafkaToBigQuery = "gs://dataflow-templates/latest/Kafka_to_BigQuery"

    /// MongoDB to BigQuery
    public static let mongoDBToBigQuery = "gs://dataflow-templates/latest/MongoDB_to_BigQuery"

    /// Create a job for Word Count template
    public static func wordCountJob(
        name: String,
        projectID: String,
        region: String,
        inputFile: String,
        outputLocation: String,
        tempLocation: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: name,
            projectID: projectID,
            region: region,
            type: .batch,
            templatePath: wordCount,
            parameters: [
                "inputFile": inputFile,
                "output": outputLocation
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: tempLocation
            )
        )
    }

    /// Create a job for Pub/Sub to BigQuery streaming
    public static func pubSubToBigQueryJob(
        name: String,
        projectID: String,
        region: String,
        inputTopic: String,
        outputTable: String,
        tempLocation: String,
        enableStreamingEngine: Bool = true
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: name,
            projectID: projectID,
            region: region,
            type: .streaming,
            templatePath: pubSubToBigQuery,
            parameters: [
                "inputTopic": inputTopic,
                "outputTableSpec": outputTable
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: tempLocation,
                enableStreamingEngine: enableStreamingEngine
            )
        )
    }

    /// Create a job for Text to BigQuery
    public static func textToBigQueryJob(
        name: String,
        projectID: String,
        region: String,
        inputFilePattern: String,
        jsonSchemaPath: String,
        outputTable: String,
        bigQueryLoadingTemporaryDirectory: String,
        tempLocation: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: name,
            projectID: projectID,
            region: region,
            type: .batch,
            templatePath: textToBigQuery,
            parameters: [
                "inputFilePattern": inputFilePattern,
                "JSONPath": jsonSchemaPath,
                "outputTable": outputTable,
                "bigQueryLoadingTemporaryDirectory": bigQueryLoadingTemporaryDirectory
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: tempLocation
            )
        )
    }

    /// Create a job for BigQuery to GCS export
    public static func bigQueryToGCSJob(
        name: String,
        projectID: String,
        region: String,
        inputTable: String,
        outputDirectory: String,
        tempLocation: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: name,
            projectID: projectID,
            region: region,
            type: .batch,
            templatePath: bigQueryToGCS,
            parameters: [
                "inputTableId": inputTable,
                "outputDirectory": outputDirectory
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: tempLocation
            )
        )
    }
}

// MARK: - DAIS Dataflow Template

/// Dataflow templates for DAIS deployments
public struct DAISDataflowTemplate {

    /// Create streaming ETL job from Pub/Sub to BigQuery
    public static func streamingETLJob(
        projectID: String,
        region: String,
        deploymentName: String,
        inputTopic: String,
        outputTable: String,
        tempBucket: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: "\(deploymentName)-streaming-etl",
            projectID: projectID,
            region: region,
            type: .streaming,
            templatePath: GoogleDataflowTemplates.pubSubToBigQuery,
            parameters: [
                "inputTopic": inputTopic,
                "outputTableSpec": outputTable
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: "gs://\(tempBucket)/dataflow/temp",
                machineType: "n1-standard-2",
                numWorkers: 1,
                maxWorkers: 10,
                enableStreamingEngine: true,
                additionalUserLabels: [
                    "deployment": deploymentName,
                    "purpose": "streaming-etl"
                ]
            ),
            labels: [
                "deployment": deploymentName,
                "managed-by": "dais"
            ]
        )
    }

    /// Create batch export job from BigQuery to GCS
    public static func batchExportJob(
        projectID: String,
        region: String,
        deploymentName: String,
        sourceTable: String,
        destinationBucket: String,
        tempBucket: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: "\(deploymentName)-batch-export",
            projectID: projectID,
            region: region,
            type: .batch,
            templatePath: GoogleDataflowTemplates.bigQueryToGCS,
            parameters: [
                "inputTableId": sourceTable,
                "outputDirectory": "gs://\(destinationBucket)/exports"
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: "gs://\(tempBucket)/dataflow/temp",
                machineType: "n1-standard-4",
                numWorkers: 2,
                maxWorkers: 20,
                additionalUserLabels: [
                    "deployment": deploymentName,
                    "purpose": "batch-export"
                ]
            ),
            labels: [
                "deployment": deploymentName,
                "managed-by": "dais"
            ]
        )
    }

    /// Create log processing job
    public static func logProcessingJob(
        projectID: String,
        region: String,
        deploymentName: String,
        logsTopic: String,
        outputDataset: String,
        tempBucket: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: "\(deploymentName)-log-processor",
            projectID: projectID,
            region: region,
            type: .streaming,
            templatePath: GoogleDataflowTemplates.pubSubToBigQuery,
            parameters: [
                "inputTopic": logsTopic,
                "outputTableSpec": "\(projectID):\(outputDataset).logs"
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: "gs://\(tempBucket)/dataflow/temp",
                machineType: "n1-standard-2",
                numWorkers: 1,
                maxWorkers: 5,
                enableStreamingEngine: true,
                additionalExperiments: [
                    "enable_windmill_service",
                    "enable_streaming_engine"
                ],
                additionalUserLabels: [
                    "deployment": deploymentName,
                    "purpose": "log-processing"
                ]
            ),
            labels: [
                "deployment": deploymentName,
                "managed-by": "dais"
            ]
        )
    }

    /// Create data archive job
    public static func dataArchiveJob(
        projectID: String,
        region: String,
        deploymentName: String,
        sourceTable: String,
        archiveBucket: String,
        tempBucket: String
    ) -> GoogleCloudDataflowJob {
        GoogleCloudDataflowJob(
            name: "\(deploymentName)-data-archive",
            projectID: projectID,
            region: region,
            type: .batch,
            templatePath: GoogleDataflowTemplates.bigQueryToParquet,
            parameters: [
                "tableRef": sourceTable,
                "bucket": archiveBucket,
                "numShards": "10"
            ],
            environment: GoogleCloudDataflowJob.EnvironmentConfig(
                tempLocation: "gs://\(tempBucket)/dataflow/temp",
                machineType: "n1-standard-4",
                numWorkers: 4,
                maxWorkers: 50,
                diskSizeGb: 100,
                additionalUserLabels: [
                    "deployment": deploymentName,
                    "purpose": "data-archive"
                ]
            ),
            labels: [
                "deployment": deploymentName,
                "managed-by": "dais"
            ]
        )
    }

    /// Setup script for DAIS Dataflow infrastructure
    public static func setupScript(
        projectID: String,
        region: String,
        deploymentName: String,
        tempBucket: String,
        serviceAccountEmail: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # Dataflow Setup for \(deploymentName)
        # Project: \(projectID)
        # Region: \(region)

        echo "Enabling Dataflow API..."
        gcloud services enable dataflow.googleapis.com --project=\(projectID)

        echo "Creating temp bucket for Dataflow..."
        gsutil mb -p \(projectID) -l \(region) gs://\(tempBucket) || true

        echo "Setting up service account permissions..."
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccountEmail)" \\
            --role="roles/dataflow.admin"

        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccountEmail)" \\
            --role="roles/dataflow.worker"

        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccountEmail)" \\
            --role="roles/storage.objectAdmin"

        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccountEmail)" \\
            --role="roles/bigquery.dataEditor"

        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccountEmail)" \\
            --role="roles/pubsub.subscriber"

        echo "Creating staging directories..."
        gsutil cp /dev/null gs://\(tempBucket)/dataflow/temp/.keep || true
        gsutil cp /dev/null gs://\(tempBucket)/dataflow/staging/.keep || true

        echo "Dataflow setup complete!"
        echo "Temp Bucket: gs://\(tempBucket)"
        echo "Service Account: \(serviceAccountEmail)"
        """
    }

    /// Teardown script
    public static func teardownScript(
        projectID: String,
        region: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # Dataflow Teardown for \(deploymentName)

        echo "Cancelling all running Dataflow jobs..."
        for job_id in $(gcloud dataflow jobs list --project=\(projectID) --region=\(region) \\
            --filter="name:\(deploymentName) AND state=Running" --format="value(JOB_ID)"); do
            echo "Cancelling job: $job_id"
            gcloud dataflow jobs cancel $job_id --project=\(projectID) --region=\(region) || true
        done

        echo "Draining streaming jobs..."
        for job_id in $(gcloud dataflow jobs list --project=\(projectID) --region=\(region) \\
            --filter="name:\(deploymentName) AND type=Streaming" --format="value(JOB_ID)"); do
            echo "Draining job: $job_id"
            gcloud dataflow jobs drain $job_id --project=\(projectID) --region=\(region) || true
        done

        echo "Dataflow teardown complete!"
        """
    }
}
