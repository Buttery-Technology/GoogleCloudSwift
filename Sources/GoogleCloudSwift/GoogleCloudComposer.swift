import Foundation

// MARK: - Composer Environment

/// Represents a Cloud Composer environment
public struct GoogleCloudComposerEnvironment: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let config: EnvironmentConfig?
    public let labels: [String: String]?
    public let state: EnvironmentState?

    public struct EnvironmentConfig: Codable, Sendable, Equatable {
        public let nodeCount: Int?
        public let softwareConfig: SoftwareConfig?
        public let nodeConfig: NodeConfig?
        public let privateEnvironmentConfig: PrivateEnvironmentConfig?
        public let webServerConfig: WebServerConfig?
        public let databaseConfig: DatabaseConfig?
        public let workloadsConfig: WorkloadsConfig?
        public let environmentSize: EnvironmentSize?

        public init(
            nodeCount: Int? = nil,
            softwareConfig: SoftwareConfig? = nil,
            nodeConfig: NodeConfig? = nil,
            privateEnvironmentConfig: PrivateEnvironmentConfig? = nil,
            webServerConfig: WebServerConfig? = nil,
            databaseConfig: DatabaseConfig? = nil,
            workloadsConfig: WorkloadsConfig? = nil,
            environmentSize: EnvironmentSize? = nil
        ) {
            self.nodeCount = nodeCount
            self.softwareConfig = softwareConfig
            self.nodeConfig = nodeConfig
            self.privateEnvironmentConfig = privateEnvironmentConfig
            self.webServerConfig = webServerConfig
            self.databaseConfig = databaseConfig
            self.workloadsConfig = workloadsConfig
            self.environmentSize = environmentSize
        }
    }

    public struct SoftwareConfig: Codable, Sendable, Equatable {
        public let imageVersion: String?
        public let pythonVersion: String?
        public let airflowConfigOverrides: [String: String]?
        public let pypiPackages: [String: String]?
        public let envVariables: [String: String]?

        public init(
            imageVersion: String? = nil,
            pythonVersion: String? = nil,
            airflowConfigOverrides: [String: String]? = nil,
            pypiPackages: [String: String]? = nil,
            envVariables: [String: String]? = nil
        ) {
            self.imageVersion = imageVersion
            self.pythonVersion = pythonVersion
            self.airflowConfigOverrides = airflowConfigOverrides
            self.pypiPackages = pypiPackages
            self.envVariables = envVariables
        }
    }

    public struct NodeConfig: Codable, Sendable, Equatable {
        public let machineType: String?
        public let diskSizeGb: Int?
        public let serviceAccount: String?
        public let network: String?
        public let subnetwork: String?
        public let tags: [String]?

        public init(
            machineType: String? = nil,
            diskSizeGb: Int? = nil,
            serviceAccount: String? = nil,
            network: String? = nil,
            subnetwork: String? = nil,
            tags: [String]? = nil
        ) {
            self.machineType = machineType
            self.diskSizeGb = diskSizeGb
            self.serviceAccount = serviceAccount
            self.network = network
            self.subnetwork = subnetwork
            self.tags = tags
        }
    }

    public struct PrivateEnvironmentConfig: Codable, Sendable, Equatable {
        public let enablePrivateEnvironment: Bool
        public let enablePrivateEndpoint: Bool?
        public let cloudSqlIpv4CidrBlock: String?
        public let webServerIpv4CidrBlock: String?

        public init(
            enablePrivateEnvironment: Bool = true,
            enablePrivateEndpoint: Bool? = nil,
            cloudSqlIpv4CidrBlock: String? = nil,
            webServerIpv4CidrBlock: String? = nil
        ) {
            self.enablePrivateEnvironment = enablePrivateEnvironment
            self.enablePrivateEndpoint = enablePrivateEndpoint
            self.cloudSqlIpv4CidrBlock = cloudSqlIpv4CidrBlock
            self.webServerIpv4CidrBlock = webServerIpv4CidrBlock
        }
    }

    public struct WebServerConfig: Codable, Sendable, Equatable {
        public let machineType: String

        public init(machineType: String = "composer-n1-webserver-2") {
            self.machineType = machineType
        }
    }

    public struct DatabaseConfig: Codable, Sendable, Equatable {
        public let machineType: String

        public init(machineType: String = "db-n1-standard-2") {
            self.machineType = machineType
        }
    }

    public struct WorkloadsConfig: Codable, Sendable, Equatable {
        public let scheduler: SchedulerConfig?
        public let webServer: WebServerResourceConfig?
        public let worker: WorkerConfig?

        public struct SchedulerConfig: Codable, Sendable, Equatable {
            public let cpu: Double?
            public let memoryGb: Double?
            public let storageGb: Double?
            public let count: Int?

            public init(cpu: Double? = nil, memoryGb: Double? = nil, storageGb: Double? = nil, count: Int? = nil) {
                self.cpu = cpu
                self.memoryGb = memoryGb
                self.storageGb = storageGb
                self.count = count
            }
        }

        public struct WebServerResourceConfig: Codable, Sendable, Equatable {
            public let cpu: Double?
            public let memoryGb: Double?
            public let storageGb: Double?

            public init(cpu: Double? = nil, memoryGb: Double? = nil, storageGb: Double? = nil) {
                self.cpu = cpu
                self.memoryGb = memoryGb
                self.storageGb = storageGb
            }
        }

        public struct WorkerConfig: Codable, Sendable, Equatable {
            public let cpu: Double?
            public let memoryGb: Double?
            public let storageGb: Double?
            public let minCount: Int?
            public let maxCount: Int?

            public init(cpu: Double? = nil, memoryGb: Double? = nil, storageGb: Double? = nil, minCount: Int? = nil, maxCount: Int? = nil) {
                self.cpu = cpu
                self.memoryGb = memoryGb
                self.storageGb = storageGb
                self.minCount = minCount
                self.maxCount = maxCount
            }
        }

        public init(scheduler: SchedulerConfig? = nil, webServer: WebServerResourceConfig? = nil, worker: WorkerConfig? = nil) {
            self.scheduler = scheduler
            self.webServer = webServer
            self.worker = worker
        }
    }

    public enum EnvironmentSize: String, Codable, Sendable, Equatable {
        case small = "ENVIRONMENT_SIZE_SMALL"
        case medium = "ENVIRONMENT_SIZE_MEDIUM"
        case large = "ENVIRONMENT_SIZE_LARGE"
    }

    public enum EnvironmentState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case running = "RUNNING"
        case updating = "UPDATING"
        case deleting = "DELETING"
        case error = "ERROR"
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        config: EnvironmentConfig? = nil,
        labels: [String: String]? = nil,
        state: EnvironmentState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.config = config
        self.labels = labels
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/environments/\(name)"
    }

    /// Command to create the environment
    public var createCommand: String {
        var cmd = "gcloud composer environments create \(name) --location=\(location) --project=\(projectID)"

        if let config = config {
            if let nodeCount = config.nodeCount {
                cmd += " --node-count=\(nodeCount)"
            }

            if let software = config.softwareConfig {
                if let version = software.imageVersion {
                    cmd += " --image-version=\(version)"
                }
                if let python = software.pythonVersion {
                    cmd += " --python-version=\(python)"
                }
            }

            if let node = config.nodeConfig {
                if let machine = node.machineType {
                    cmd += " --machine-type=\(machine)"
                }
                if let disk = node.diskSizeGb {
                    cmd += " --disk-size=\(disk)GB"
                }
                if let sa = node.serviceAccount {
                    cmd += " --service-account=\(sa)"
                }
                if let network = node.network {
                    cmd += " --network=\(network)"
                }
                if let subnet = node.subnetwork {
                    cmd += " --subnetwork=\(subnet)"
                }
            }

            if let env = config.environmentSize {
                cmd += " --environment-size=\(env.rawValue)"
            }
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to describe the environment
    public var describeCommand: String {
        "gcloud composer environments describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to delete the environment
    public var deleteCommand: String {
        "gcloud composer environments delete \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to update the environment (scale workers)
    public func updateCommand(nodeCount: Int) -> String {
        "gcloud composer environments update \(name) --location=\(location) --node-count=\(nodeCount) --project=\(projectID)"
    }

    /// Command to update PyPI packages
    public func updatePyPIPackagesCommand(packages: [String: String]) -> String {
        let packageStr = packages.map { "\($0.key)\($0.value.isEmpty ? "" : "==\($0.value)")" }.joined(separator: ",")
        return "gcloud composer environments update \(name) --location=\(location) --update-pypi-package \(packageStr) --project=\(projectID)"
    }

    /// Command to list environments
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud composer environments list --locations=\(location) --project=\(projectID)"
    }

    /// Command to get Airflow web UI URL
    public var getAirflowURLCommand: String {
        "gcloud composer environments describe \(name) --location=\(location) --format='value(config.airflowUri)' --project=\(projectID)"
    }

    /// Command to run Airflow CLI command
    public func airflowCommand(_ cmd: String) -> String {
        "gcloud composer environments run \(name) --location=\(location) --project=\(projectID) -- \(cmd)"
    }

    /// Command to list DAGs
    public var listDAGsCommand: String {
        airflowCommand("dags list")
    }

    /// Command to trigger a DAG
    public func triggerDAGCommand(dagID: String, conf: String? = nil) -> String {
        var cmd = "dags trigger \(dagID)"
        if let conf = conf {
            cmd += " --conf '\(conf)'"
        }
        return airflowCommand(cmd)
    }

    /// Command to pause a DAG
    public func pauseDAGCommand(dagID: String) -> String {
        airflowCommand("dags pause \(dagID)")
    }

    /// Command to unpause a DAG
    public func unpauseDAGCommand(dagID: String) -> String {
        airflowCommand("dags unpause \(dagID)")
    }
}

// MARK: - Composer DAG

/// Represents an Airflow DAG configuration
public struct GoogleCloudComposerDAG: Sendable {
    public let dagID: String
    public let schedule: String?
    public let description: String?
    public let catchup: Bool
    public let tags: [String]?

    public init(
        dagID: String,
        schedule: String? = nil,
        description: String? = nil,
        catchup: Bool = false,
        tags: [String]? = nil
    ) {
        self.dagID = dagID
        self.schedule = schedule
        self.description = description
        self.catchup = catchup
        self.tags = tags
    }

    /// Common schedules
    public struct Schedules {
        public static let hourly = "@hourly"
        public static let daily = "@daily"
        public static let weekly = "@weekly"
        public static let monthly = "@monthly"
        public static let yearly = "@yearly"
        public static let everyMinute = "* * * * *"
        public static let every5Minutes = "*/5 * * * *"
        public static let every15Minutes = "*/15 * * * *"
        public static let every30Minutes = "*/30 * * * *"
    }

    /// Generate Python DAG template
    public var pythonTemplate: String {
        """
        from datetime import datetime, timedelta
        from airflow import DAG
        from airflow.operators.python import PythonOperator
        from airflow.operators.bash import BashOperator

        default_args = {
            'owner': 'airflow',
            'depends_on_past': False,
            'email_on_failure': False,
            'email_on_retry': False,
            'retries': 1,
            'retry_delay': timedelta(minutes=5),
        }

        with DAG(
            '\(dagID)',
            default_args=default_args,
            description='\(description ?? "")',
            schedule_interval=\(schedule.map { "'\($0)'" } ?? "None"),
            start_date=datetime(2024, 1, 1),
            catchup=\(catchup ? "True" : "False"),
            tags=\(tags.map { "[\($0.map { "'\($0)'" }.joined(separator: ", "))]" } ?? "[]"),
        ) as dag:

            # Define your tasks here
            start = BashOperator(
                task_id='start',
                bash_command='echo "Starting DAG"',
            )

            end = BashOperator(
                task_id='end',
                bash_command='echo "DAG completed"',
            )

            start >> end
        """
    }
}

// MARK: - Composer Image Versions

/// Available Composer image versions
public struct ComposerImageVersions: Sendable {
    public static let composer2Latest = "composer-2-airflow-2"
    public static let composer2Airflow2_7 = "composer-2.7.1-airflow-2.7.3"
    public static let composer2Airflow2_6 = "composer-2.6.6-airflow-2.6.3"
    public static let composer2Airflow2_5 = "composer-2.5.4-airflow-2.5.3"
    public static let composer1Latest = "composer-1-airflow-2"
}

// MARK: - Composer Operations

/// Helper operations for Cloud Composer
public struct ComposerOperations: Sendable {

    /// Command to enable Cloud Composer API
    public static var enableAPICommand: String {
        "gcloud services enable composer.googleapis.com"
    }

    /// IAM roles for Composer
    public struct Roles {
        public static let admin = "roles/composer.admin"
        public static let user = "roles/composer.user"
        public static let worker = "roles/composer.worker"
        public static let environmentAndStorageObjectAdmin = "roles/composer.environmentAndStorageObjectAdmin"
        public static let sharedVpcAgent = "roles/composer.sharedVpcAgent"
    }

    /// Command to add Composer admin role
    public static func addAdminRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=roles/composer.admin"
    }

    /// Command to add Composer user role
    public static func addUserRoleCommand(projectID: String, serviceAccount: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=serviceAccount:\(serviceAccount) --role=roles/composer.user"
    }

    /// Command to upload DAG file
    public static func uploadDAGCommand(projectID: String, location: String, envName: String, dagFile: String) -> String {
        "gcloud composer environments storage dags import --environment=\(envName) --location=\(location) --source=\(dagFile) --project=\(projectID)"
    }

    /// Command to delete DAG file
    public static func deleteDAGCommand(projectID: String, location: String, envName: String, dagFile: String) -> String {
        "gcloud composer environments storage dags delete --environment=\(envName) --location=\(location) \(dagFile) --project=\(projectID)"
    }

    /// Command to list DAG files
    public static func listDAGsCommand(projectID: String, location: String, envName: String) -> String {
        "gcloud composer environments storage dags list --environment=\(envName) --location=\(location) --project=\(projectID)"
    }

    /// Command to export DAGs
    public static func exportDAGsCommand(projectID: String, location: String, envName: String, destination: String) -> String {
        "gcloud composer environments storage dags export --environment=\(envName) --location=\(location) --destination=\(destination) --project=\(projectID)"
    }

    /// Command to list operations
    public static func listOperationsCommand(projectID: String, location: String) -> String {
        "gcloud composer operations list --locations=\(location) --project=\(projectID)"
    }

    /// Recommended locations
    public struct Locations {
        public static let usCentral1 = "us-central1"
        public static let usEast1 = "us-east1"
        public static let usWest1 = "us-west1"
        public static let europeWest1 = "europe-west1"
        public static let europeWest2 = "europe-west2"
        public static let asiaNortheast1 = "asia-northeast1"
        public static let asiaSoutheast1 = "asia-southeast1"
    }
}

// MARK: - DAIS Composer Template

/// Production-ready Cloud Composer templates for DAIS systems
public struct DAISComposerTemplate: Sendable {
    public let projectID: String
    public let location: String
    public let environmentName: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        location: String = "us-central1",
        environmentName: String = "dais-composer",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.environmentName = environmentName
        self.serviceAccount = serviceAccount
    }

    /// Small environment for development
    public var developmentEnvironment: GoogleCloudComposerEnvironment {
        GoogleCloudComposerEnvironment(
            name: "\(environmentName)-dev",
            projectID: projectID,
            location: location,
            config: GoogleCloudComposerEnvironment.EnvironmentConfig(
                softwareConfig: GoogleCloudComposerEnvironment.SoftwareConfig(
                    imageVersion: ComposerImageVersions.composer2Latest,
                    pythonVersion: "3"
                ),
                environmentSize: .small
            ),
            labels: ["env": "development", "managed-by": "dais"]
        )
    }

    /// Medium environment for production
    public var productionEnvironment: GoogleCloudComposerEnvironment {
        GoogleCloudComposerEnvironment(
            name: environmentName,
            projectID: projectID,
            location: location,
            config: GoogleCloudComposerEnvironment.EnvironmentConfig(
                nodeCount: 3,
                softwareConfig: GoogleCloudComposerEnvironment.SoftwareConfig(
                    imageVersion: ComposerImageVersions.composer2Latest,
                    pythonVersion: "3",
                    airflowConfigOverrides: [
                        "core-parallelism": "32",
                        "core-dag_concurrency": "16",
                        "celery-worker_concurrency": "8"
                    ]
                ),
                nodeConfig: serviceAccount.map {
                    GoogleCloudComposerEnvironment.NodeConfig(
                        machineType: "n1-standard-2",
                        diskSizeGb: 100,
                        serviceAccount: $0
                    )
                },
                environmentSize: .medium
            ),
            labels: ["env": "production", "managed-by": "dais"]
        )
    }

    /// High-availability environment
    public var highAvailabilityEnvironment: GoogleCloudComposerEnvironment {
        GoogleCloudComposerEnvironment(
            name: "\(environmentName)-ha",
            projectID: projectID,
            location: location,
            config: GoogleCloudComposerEnvironment.EnvironmentConfig(
                softwareConfig: GoogleCloudComposerEnvironment.SoftwareConfig(
                    imageVersion: ComposerImageVersions.composer2Latest,
                    pythonVersion: "3",
                    airflowConfigOverrides: [
                        "core-parallelism": "64",
                        "core-dag_concurrency": "32"
                    ]
                ),
                workloadsConfig: GoogleCloudComposerEnvironment.WorkloadsConfig(
                    scheduler: GoogleCloudComposerEnvironment.WorkloadsConfig.SchedulerConfig(
                        cpu: 2,
                        memoryGb: 4,
                        count: 2
                    ),
                    webServer: GoogleCloudComposerEnvironment.WorkloadsConfig.WebServerResourceConfig(
                        cpu: 2,
                        memoryGb: 4
                    ),
                    worker: GoogleCloudComposerEnvironment.WorkloadsConfig.WorkerConfig(
                        cpu: 2,
                        memoryGb: 4,
                        minCount: 2,
                        maxCount: 10
                    )
                ),
                environmentSize: .large
            ),
            labels: ["env": "production", "ha": "true", "managed-by": "dais"]
        )
    }

    /// Sample ETL DAG
    public var sampleETLDAG: GoogleCloudComposerDAG {
        GoogleCloudComposerDAG(
            dagID: "dais_etl_pipeline",
            schedule: GoogleCloudComposerDAG.Schedules.daily,
            description: "DAIS daily ETL pipeline",
            tags: ["dais", "etl", "production"]
        )
    }

    /// Sample data sync DAG
    public var sampleDataSyncDAG: GoogleCloudComposerDAG {
        GoogleCloudComposerDAG(
            dagID: "dais_data_sync",
            schedule: GoogleCloudComposerDAG.Schedules.hourly,
            description: "DAIS hourly data synchronization",
            tags: ["dais", "sync"]
        )
    }

    /// Setup script
    public var setupScript: String {
        var script = """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        ENV_NAME="\(environmentName)"

        echo "Enabling Cloud Composer API..."
        \(ComposerOperations.enableAPICommand)

        """

        if let sa = serviceAccount {
            script += """
            echo ""
            echo "Granting Composer user role..."
            \(ComposerOperations.addUserRoleCommand(projectID: projectID, serviceAccount: sa))

            """
        }

        script += """
        echo ""
        echo "Creating Composer environment..."
        echo "Note: This may take 20-30 minutes..."
        \(productionEnvironment.createCommand)

        echo ""
        echo "DAIS Composer setup complete!"
        echo ""
        echo "Environment: $ENV_NAME"
        echo "Location: $LOCATION"
        echo ""
        echo "Get Airflow UI URL:"
        echo "  \(productionEnvironment.getAirflowURLCommand)"
        echo ""
        echo "Upload DAGs:"
        echo "  \(ComposerOperations.uploadDAGCommand(projectID: projectID, location: location, envName: environmentName, dagFile: "your_dag.py"))"
        """

        return script
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        ENV_NAME="\(environmentName)"

        echo "Deleting Composer environment..."
        echo "WARNING: This will delete all DAGs and data!"
        \(productionEnvironment.deleteCommand) --quiet || true

        echo ""
        echo "Deleting development environment..."
        \(developmentEnvironment.deleteCommand) --quiet || true

        echo ""
        echo "Composer teardown complete!"
        """
    }
}
