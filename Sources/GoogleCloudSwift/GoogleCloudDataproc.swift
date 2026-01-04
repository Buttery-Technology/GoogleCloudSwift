import Foundation

// MARK: - Dataproc Cluster

/// Represents a Cloud Dataproc cluster
public struct GoogleCloudDataprocCluster: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let clusterConfig: ClusterConfig?
    public let labels: [String: String]?
    public let status: ClusterStatus?

    public struct ClusterConfig: Codable, Sendable, Equatable {
        public let masterConfig: InstanceGroupConfig?
        public let workerConfig: InstanceGroupConfig?
        public let secondaryWorkerConfig: InstanceGroupConfig?
        public let softwareConfig: SoftwareConfig?
        public let initializationActions: [InitializationAction]?
        public let gceClusterConfig: GceClusterConfig?

        public init(
            masterConfig: InstanceGroupConfig? = nil,
            workerConfig: InstanceGroupConfig? = nil,
            secondaryWorkerConfig: InstanceGroupConfig? = nil,
            softwareConfig: SoftwareConfig? = nil,
            initializationActions: [InitializationAction]? = nil,
            gceClusterConfig: GceClusterConfig? = nil
        ) {
            self.masterConfig = masterConfig
            self.workerConfig = workerConfig
            self.secondaryWorkerConfig = secondaryWorkerConfig
            self.softwareConfig = softwareConfig
            self.initializationActions = initializationActions
            self.gceClusterConfig = gceClusterConfig
        }
    }

    public struct InstanceGroupConfig: Codable, Sendable, Equatable {
        public let numInstances: Int
        public let machineType: String
        public let diskConfig: DiskConfig?
        public let preemptibility: Preemptibility?

        public enum Preemptibility: String, Codable, Sendable, Equatable {
            case nonPreemptible = "NON_PREEMPTIBLE"
            case preemptible = "PREEMPTIBLE"
            case spot = "SPOT"
        }

        public struct DiskConfig: Codable, Sendable, Equatable {
            public let bootDiskType: String
            public let bootDiskSizeGb: Int
            public let numLocalSsds: Int?

            public init(bootDiskType: String = "pd-standard", bootDiskSizeGb: Int = 500, numLocalSsds: Int? = nil) {
                self.bootDiskType = bootDiskType
                self.bootDiskSizeGb = bootDiskSizeGb
                self.numLocalSsds = numLocalSsds
            }
        }

        public init(
            numInstances: Int,
            machineType: String = "n1-standard-4",
            diskConfig: DiskConfig? = nil,
            preemptibility: Preemptibility? = nil
        ) {
            self.numInstances = numInstances
            self.machineType = machineType
            self.diskConfig = diskConfig
            self.preemptibility = preemptibility
        }
    }

    public struct SoftwareConfig: Codable, Sendable, Equatable {
        public let imageVersion: String?
        public let properties: [String: String]?
        public let optionalComponents: [Component]?

        public enum Component: String, Codable, Sendable, Equatable {
            case anaconda = "ANACONDA"
            case docker = "DOCKER"
            case druid = "DRUID"
            case flink = "FLINK"
            case hbase = "HBASE"
            case hiveWebhcat = "HIVE_WEBHCAT"
            case jupyter = "JUPYTER"
            case presto = "PRESTO"
            case ranger = "RANGER"
            case solr = "SOLR"
            case zeppelin = "ZEPPELIN"
            case zookeeper = "ZOOKEEPER"
        }

        public init(
            imageVersion: String? = nil,
            properties: [String: String]? = nil,
            optionalComponents: [Component]? = nil
        ) {
            self.imageVersion = imageVersion
            self.properties = properties
            self.optionalComponents = optionalComponents
        }
    }

    public struct InitializationAction: Codable, Sendable, Equatable {
        public let executableFile: String
        public let executionTimeout: String?

        public init(executableFile: String, executionTimeout: String? = nil) {
            self.executableFile = executableFile
            self.executionTimeout = executionTimeout
        }
    }

    public struct GceClusterConfig: Codable, Sendable, Equatable {
        public let zone: String?
        public let network: String?
        public let subnetwork: String?
        public let internalIPOnly: Bool?
        public let serviceAccount: String?
        public let tags: [String]?

        public init(
            zone: String? = nil,
            network: String? = nil,
            subnetwork: String? = nil,
            internalIPOnly: Bool? = nil,
            serviceAccount: String? = nil,
            tags: [String]? = nil
        ) {
            self.zone = zone
            self.network = network
            self.subnetwork = subnetwork
            self.internalIPOnly = internalIPOnly
            self.serviceAccount = serviceAccount
            self.tags = tags
        }
    }

    public enum ClusterStatus: String, Codable, Sendable, Equatable {
        case unknown = "UNKNOWN"
        case creating = "CREATING"
        case running = "RUNNING"
        case error = "ERROR"
        case deleting = "DELETING"
        case updating = "UPDATING"
        case stopping = "STOPPING"
        case stopped = "STOPPED"
        case starting = "STARTING"
    }

    public init(
        name: String,
        projectID: String,
        region: String,
        clusterConfig: ClusterConfig? = nil,
        labels: [String: String]? = nil,
        status: ClusterStatus? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.clusterConfig = clusterConfig
        self.labels = labels
        self.status = status
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/clusters/\(name)"
    }

    /// Command to create the cluster
    public var createCommand: String {
        var cmd = "gcloud dataproc clusters create \(name) --region=\(region) --project=\(projectID)"

        if let config = clusterConfig {
            if let master = config.masterConfig {
                cmd += " --master-machine-type=\(master.machineType)"
                cmd += " --num-masters=\(master.numInstances)"
                if let disk = master.diskConfig {
                    cmd += " --master-boot-disk-size=\(disk.bootDiskSizeGb)GB"
                    cmd += " --master-boot-disk-type=\(disk.bootDiskType)"
                }
            }

            if let worker = config.workerConfig {
                cmd += " --worker-machine-type=\(worker.machineType)"
                cmd += " --num-workers=\(worker.numInstances)"
                if let disk = worker.diskConfig {
                    cmd += " --worker-boot-disk-size=\(disk.bootDiskSizeGb)GB"
                    cmd += " --worker-boot-disk-type=\(disk.bootDiskType)"
                }
            }

            if let secondary = config.secondaryWorkerConfig {
                cmd += " --num-secondary-workers=\(secondary.numInstances)"
                if let preempt = secondary.preemptibility {
                    cmd += " --secondary-worker-type=\(preempt.rawValue)"
                }
            }

            if let software = config.softwareConfig {
                if let version = software.imageVersion {
                    cmd += " --image-version=\(version)"
                }
                if let components = software.optionalComponents, !components.isEmpty {
                    cmd += " --optional-components=\(components.map { $0.rawValue }.joined(separator: ","))"
                }
            }

            if let gce = config.gceClusterConfig {
                if let zone = gce.zone {
                    cmd += " --zone=\(zone)"
                }
                if let subnet = gce.subnetwork {
                    cmd += " --subnet=\(subnet)"
                }
                if gce.internalIPOnly == true {
                    cmd += " --no-address"
                }
                if let sa = gce.serviceAccount {
                    cmd += " --service-account=\(sa)"
                }
            }

            if let actions = config.initializationActions {
                for action in actions {
                    cmd += " --initialization-actions=\(action.executableFile)"
                }
            }
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to describe the cluster
    public var describeCommand: String {
        "gcloud dataproc clusters describe \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to delete the cluster
    public var deleteCommand: String {
        "gcloud dataproc clusters delete \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to update the cluster (scale workers)
    public func updateCommand(numWorkers: Int) -> String {
        "gcloud dataproc clusters update \(name) --region=\(region) --num-workers=\(numWorkers) --project=\(projectID)"
    }

    /// Command to stop the cluster
    public var stopCommand: String {
        "gcloud dataproc clusters stop \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to start the cluster
    public var startCommand: String {
        "gcloud dataproc clusters start \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to list clusters
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud dataproc clusters list --region=\(region) --project=\(projectID)"
    }
}

// MARK: - Dataproc Job

/// Represents a Cloud Dataproc job
public struct GoogleCloudDataprocJob: Codable, Sendable, Equatable {
    public let projectID: String
    public let region: String
    public let clusterName: String
    public let jobType: JobType
    public let jobID: String?
    public let mainClass: String?
    public let mainFile: String?
    public let jarFiles: [String]?
    public let pyFiles: [String]?
    public let args: [String]?
    public let properties: [String: String]?
    public let labels: [String: String]?
    public let status: JobStatus?

    public enum JobType: String, Codable, Sendable, Equatable {
        case spark = "SPARK"
        case pyspark = "PYSPARK"
        case sparkR = "SPARK_R"
        case sparkSql = "SPARK_SQL"
        case hive = "HIVE"
        case pig = "PIG"
        case hadoop = "HADOOP"
        case presto = "PRESTO"
    }

    public enum JobStatus: String, Codable, Sendable, Equatable {
        case pending = "PENDING"
        case setupDone = "SETUP_DONE"
        case running = "RUNNING"
        case cancelPending = "CANCEL_PENDING"
        case cancelStarted = "CANCEL_STARTED"
        case cancelled = "CANCELLED"
        case done = "DONE"
        case error = "ERROR"
        case attemptFailure = "ATTEMPT_FAILURE"
    }

    public init(
        projectID: String,
        region: String,
        clusterName: String,
        jobType: JobType,
        jobID: String? = nil,
        mainClass: String? = nil,
        mainFile: String? = nil,
        jarFiles: [String]? = nil,
        pyFiles: [String]? = nil,
        args: [String]? = nil,
        properties: [String: String]? = nil,
        labels: [String: String]? = nil,
        status: JobStatus? = nil
    ) {
        self.projectID = projectID
        self.region = region
        self.clusterName = clusterName
        self.jobType = jobType
        self.jobID = jobID
        self.mainClass = mainClass
        self.mainFile = mainFile
        self.jarFiles = jarFiles
        self.pyFiles = pyFiles
        self.args = args
        self.properties = properties
        self.labels = labels
        self.status = status
    }

    /// Command to submit the job
    public var submitCommand: String {
        var cmd: String

        switch jobType {
        case .spark:
            cmd = "gcloud dataproc jobs submit spark --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainClass = mainClass {
                cmd += " --class=\(mainClass)"
            }
            if let jars = jarFiles, !jars.isEmpty {
                cmd += " --jars=\(jars.joined(separator: ","))"
            }

        case .pyspark:
            cmd = "gcloud dataproc jobs submit pyspark --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " \(mainFile)"
            }
            if let pyFiles = pyFiles, !pyFiles.isEmpty {
                cmd += " --py-files=\(pyFiles.joined(separator: ","))"
            }

        case .hive:
            cmd = "gcloud dataproc jobs submit hive --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " --file=\(mainFile)"
            }

        case .pig:
            cmd = "gcloud dataproc jobs submit pig --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " --file=\(mainFile)"
            }

        case .hadoop:
            cmd = "gcloud dataproc jobs submit hadoop --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainClass = mainClass {
                cmd += " --class=\(mainClass)"
            }
            if let jars = jarFiles, !jars.isEmpty {
                cmd += " --jars=\(jars.joined(separator: ","))"
            }

        case .sparkSql:
            cmd = "gcloud dataproc jobs submit spark-sql --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " --file=\(mainFile)"
            }

        case .sparkR:
            cmd = "gcloud dataproc jobs submit spark-r --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " \(mainFile)"
            }

        case .presto:
            cmd = "gcloud dataproc jobs submit presto --cluster=\(clusterName) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " --file=\(mainFile)"
            }
        }

        if let args = args, !args.isEmpty {
            cmd += " -- \(args.joined(separator: " "))"
        }

        if let props = properties, !props.isEmpty {
            let propStr = props.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --properties=\(propStr)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to describe a job
    public static func describeCommand(projectID: String, region: String, jobID: String) -> String {
        "gcloud dataproc jobs describe \(jobID) --region=\(region) --project=\(projectID)"
    }

    /// Command to cancel a job
    public static func cancelCommand(projectID: String, region: String, jobID: String) -> String {
        "gcloud dataproc jobs kill \(jobID) --region=\(region) --project=\(projectID)"
    }

    /// Command to list jobs
    public static func listCommand(projectID: String, region: String, clusterName: String? = nil) -> String {
        var cmd = "gcloud dataproc jobs list --region=\(region) --project=\(projectID)"
        if let cluster = clusterName {
            cmd += " --cluster=\(cluster)"
        }
        return cmd
    }
}

// MARK: - Dataproc Batch (Serverless)

/// Represents a Dataproc Serverless batch workload
public struct GoogleCloudDataprocBatch: Codable, Sendable, Equatable {
    public let batchID: String
    public let projectID: String
    public let region: String
    public let batchType: BatchType
    public let mainFile: String?
    public let mainClass: String?
    public let jarFiles: [String]?
    public let pyFiles: [String]?
    public let args: [String]?
    public let properties: [String: String]?
    public let labels: [String: String]?
    public let runtimeConfig: RuntimeConfig?
    public let state: BatchState?

    public enum BatchType: String, Codable, Sendable, Equatable {
        case spark = "SPARK"
        case pyspark = "PYSPARK"
        case sparkR = "SPARK_R"
        case sparkSql = "SPARK_SQL"
    }

    public enum BatchState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case pending = "PENDING"
        case running = "RUNNING"
        case cancelling = "CANCELLING"
        case cancelled = "CANCELLED"
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
    }

    public struct RuntimeConfig: Codable, Sendable, Equatable {
        public let version: String?
        public let containerImage: String?

        public init(version: String? = nil, containerImage: String? = nil) {
            self.version = version
            self.containerImage = containerImage
        }
    }

    public init(
        batchID: String,
        projectID: String,
        region: String,
        batchType: BatchType,
        mainFile: String? = nil,
        mainClass: String? = nil,
        jarFiles: [String]? = nil,
        pyFiles: [String]? = nil,
        args: [String]? = nil,
        properties: [String: String]? = nil,
        labels: [String: String]? = nil,
        runtimeConfig: RuntimeConfig? = nil,
        state: BatchState? = nil
    ) {
        self.batchID = batchID
        self.projectID = projectID
        self.region = region
        self.batchType = batchType
        self.mainFile = mainFile
        self.mainClass = mainClass
        self.jarFiles = jarFiles
        self.pyFiles = pyFiles
        self.args = args
        self.properties = properties
        self.labels = labels
        self.runtimeConfig = runtimeConfig
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/batches/\(batchID)"
    }

    /// Command to submit the batch
    public var submitCommand: String {
        var cmd: String

        switch batchType {
        case .spark:
            cmd = "gcloud dataproc batches submit spark --batch=\(batchID) --region=\(region) --project=\(projectID)"
            if let mainClass = mainClass {
                cmd += " --class=\(mainClass)"
            }
            if let jars = jarFiles, !jars.isEmpty {
                cmd += " --jars=\(jars.joined(separator: ","))"
            }

        case .pyspark:
            cmd = "gcloud dataproc batches submit pyspark --batch=\(batchID) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " \(mainFile)"
            }
            if let pyFiles = pyFiles, !pyFiles.isEmpty {
                cmd += " --py-files=\(pyFiles.joined(separator: ","))"
            }

        case .sparkR:
            cmd = "gcloud dataproc batches submit spark-r --batch=\(batchID) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " \(mainFile)"
            }

        case .sparkSql:
            cmd = "gcloud dataproc batches submit spark-sql --batch=\(batchID) --region=\(region) --project=\(projectID)"
            if let mainFile = mainFile {
                cmd += " --file=\(mainFile)"
            }
        }

        if let args = args, !args.isEmpty {
            cmd += " -- \(args.joined(separator: " "))"
        }

        if let props = properties, !props.isEmpty {
            let propStr = props.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --properties=\(propStr)"
        }

        if let runtime = runtimeConfig {
            if let version = runtime.version {
                cmd += " --version=\(version)"
            }
            if let image = runtime.containerImage {
                cmd += " --container-image=\(image)"
            }
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to describe the batch
    public var describeCommand: String {
        "gcloud dataproc batches describe \(batchID) --region=\(region) --project=\(projectID)"
    }

    /// Command to cancel the batch
    public var cancelCommand: String {
        "gcloud dataproc batches cancel \(batchID) --region=\(region) --project=\(projectID)"
    }

    /// Command to delete the batch
    public var deleteCommand: String {
        "gcloud dataproc batches delete \(batchID) --region=\(region) --project=\(projectID)"
    }

    /// Command to list batches
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud dataproc batches list --region=\(region) --project=\(projectID)"
    }
}

// MARK: - Dataproc Workflow Template

/// Represents a Dataproc workflow template
public struct GoogleCloudDataprocWorkflowTemplate: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let version: Int?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        region: String,
        version: Int? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.version = version
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/workflowTemplates/\(name)"
    }

    /// Command to create a workflow template from file
    public func createFromFileCommand(filePath: String) -> String {
        "gcloud dataproc workflow-templates import \(name) --source=\(filePath) --region=\(region) --project=\(projectID)"
    }

    /// Command to describe the workflow template
    public var describeCommand: String {
        "gcloud dataproc workflow-templates describe \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to delete the workflow template
    public var deleteCommand: String {
        "gcloud dataproc workflow-templates delete \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to instantiate (run) the workflow template
    public var instantiateCommand: String {
        "gcloud dataproc workflow-templates instantiate \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to list workflow templates
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud dataproc workflow-templates list --region=\(region) --project=\(projectID)"
    }

    /// Command to export the workflow template
    public func exportCommand(destination: String) -> String {
        "gcloud dataproc workflow-templates export \(name) --destination=\(destination) --region=\(region) --project=\(projectID)"
    }
}

// MARK: - Dataproc Autoscaling Policy

/// Represents a Dataproc autoscaling policy
public struct GoogleCloudDataprocAutoscalingPolicy: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let workerConfig: InstanceGroupAutoscalingConfig?
    public let secondaryWorkerConfig: InstanceGroupAutoscalingConfig?
    public let cooldownPeriod: String?

    public struct InstanceGroupAutoscalingConfig: Codable, Sendable, Equatable {
        public let minInstances: Int
        public let maxInstances: Int
        public let weight: Int?

        public init(minInstances: Int, maxInstances: Int, weight: Int? = nil) {
            self.minInstances = minInstances
            self.maxInstances = maxInstances
            self.weight = weight
        }
    }

    public init(
        name: String,
        projectID: String,
        region: String,
        workerConfig: InstanceGroupAutoscalingConfig? = nil,
        secondaryWorkerConfig: InstanceGroupAutoscalingConfig? = nil,
        cooldownPeriod: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.workerConfig = workerConfig
        self.secondaryWorkerConfig = secondaryWorkerConfig
        self.cooldownPeriod = cooldownPeriod
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/regions/\(region)/autoscalingPolicies/\(name)"
    }

    /// Command to create an autoscaling policy from file
    public func createFromFileCommand(filePath: String) -> String {
        "gcloud dataproc autoscaling-policies import \(name) --source=\(filePath) --region=\(region) --project=\(projectID)"
    }

    /// Command to describe the autoscaling policy
    public var describeCommand: String {
        "gcloud dataproc autoscaling-policies describe \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to delete the autoscaling policy
    public var deleteCommand: String {
        "gcloud dataproc autoscaling-policies delete \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to list autoscaling policies
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud dataproc autoscaling-policies list --region=\(region) --project=\(projectID)"
    }
}

// MARK: - Dataproc Operations

/// Helper operations for Cloud Dataproc
public struct DataprocOperations: Sendable {

    /// Command to enable Cloud Dataproc API
    public static var enableAPICommand: String {
        "gcloud services enable dataproc.googleapis.com"
    }

    /// IAM roles for Dataproc
    public struct Roles {
        public static let admin = "roles/dataproc.admin"
        public static let editor = "roles/dataproc.editor"
        public static let viewer = "roles/dataproc.viewer"
        public static let worker = "roles/dataproc.worker"
    }

    /// Command to add Dataproc admin role
    public static func addAdminRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=roles/dataproc.admin"
    }

    /// Command to add Dataproc editor role
    public static func addEditorRoleCommand(projectID: String, serviceAccount: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=serviceAccount:\(serviceAccount) --role=roles/dataproc.editor"
    }

    /// Common image versions
    public struct ImageVersions {
        public static let latest = "2.1-debian11"
        public static let spark33 = "2.1-debian11"
        public static let spark32 = "2.0-debian10"
        public static let spark31 = "1.5-debian10"
    }

    /// SSH to cluster master
    public static func sshCommand(projectID: String, region: String, clusterName: String, zone: String) -> String {
        "gcloud compute ssh \(clusterName)-m --zone=\(zone) --project=\(projectID)"
    }

    /// Create a port-forwarding tunnel to Jupyter
    public static func jupyterTunnelCommand(projectID: String, zone: String, clusterName: String) -> String {
        "gcloud compute ssh \(clusterName)-m --zone=\(zone) --project=\(projectID) -- -D 1080 -N"
    }

    /// View job output
    public static func viewJobOutputCommand(projectID: String, region: String, jobID: String) -> String {
        "gcloud dataproc jobs wait \(jobID) --region=\(region) --project=\(projectID)"
    }

    /// Diagnose cluster
    public static func diagnoseCommand(projectID: String, region: String, clusterName: String) -> String {
        "gcloud dataproc clusters diagnose \(clusterName) --region=\(region) --project=\(projectID)"
    }
}

// MARK: - DAIS Dataproc Template

/// Production-ready Dataproc templates for DAIS systems
public struct DAISDataprocTemplate: Sendable {
    public let projectID: String
    public let region: String
    public let clusterName: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        region: String = "us-central1",
        clusterName: String = "dais-dataproc",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.region = region
        self.clusterName = clusterName
        self.serviceAccount = serviceAccount
    }

    /// Standard analytics cluster
    public var analyticsCluster: GoogleCloudDataprocCluster {
        GoogleCloudDataprocCluster(
            name: clusterName,
            projectID: projectID,
            region: region,
            clusterConfig: GoogleCloudDataprocCluster.ClusterConfig(
                masterConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 1,
                    machineType: "n1-standard-4",
                    diskConfig: GoogleCloudDataprocCluster.InstanceGroupConfig.DiskConfig(
                        bootDiskType: "pd-ssd",
                        bootDiskSizeGb: 500
                    )
                ),
                workerConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 2,
                    machineType: "n1-standard-4",
                    diskConfig: GoogleCloudDataprocCluster.InstanceGroupConfig.DiskConfig(
                        bootDiskType: "pd-standard",
                        bootDiskSizeGb: 500
                    )
                ),
                softwareConfig: GoogleCloudDataprocCluster.SoftwareConfig(
                    imageVersion: DataprocOperations.ImageVersions.latest,
                    optionalComponents: [.jupyter, .zeppelin]
                ),
                gceClusterConfig: serviceAccount.map {
                    GoogleCloudDataprocCluster.GceClusterConfig(serviceAccount: $0)
                }
            ),
            labels: ["env": "production", "managed-by": "dais"]
        )
    }

    /// Spot cluster for batch processing
    public var batchProcessingCluster: GoogleCloudDataprocCluster {
        GoogleCloudDataprocCluster(
            name: "\(clusterName)-batch",
            projectID: projectID,
            region: region,
            clusterConfig: GoogleCloudDataprocCluster.ClusterConfig(
                masterConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 1,
                    machineType: "n1-standard-2"
                ),
                workerConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 2,
                    machineType: "n1-standard-4"
                ),
                secondaryWorkerConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 10,
                    machineType: "n1-standard-4",
                    preemptibility: .spot
                ),
                softwareConfig: GoogleCloudDataprocCluster.SoftwareConfig(
                    imageVersion: DataprocOperations.ImageVersions.latest
                )
            ),
            labels: ["env": "production", "type": "batch", "managed-by": "dais"]
        )
    }

    /// High-memory cluster for large datasets
    public var highMemoryCluster: GoogleCloudDataprocCluster {
        GoogleCloudDataprocCluster(
            name: "\(clusterName)-highmem",
            projectID: projectID,
            region: region,
            clusterConfig: GoogleCloudDataprocCluster.ClusterConfig(
                masterConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 1,
                    machineType: "n1-highmem-8",
                    diskConfig: GoogleCloudDataprocCluster.InstanceGroupConfig.DiskConfig(
                        bootDiskType: "pd-ssd",
                        bootDiskSizeGb: 1000
                    )
                ),
                workerConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
                    numInstances: 4,
                    machineType: "n1-highmem-8",
                    diskConfig: GoogleCloudDataprocCluster.InstanceGroupConfig.DiskConfig(
                        bootDiskType: "pd-ssd",
                        bootDiskSizeGb: 1000
                    )
                ),
                softwareConfig: GoogleCloudDataprocCluster.SoftwareConfig(
                    imageVersion: DataprocOperations.ImageVersions.latest,
                    properties: [
                        "spark:spark.executor.memory": "24g",
                        "spark:spark.driver.memory": "8g"
                    ]
                )
            ),
            labels: ["env": "production", "type": "highmem", "managed-by": "dais"]
        )
    }

    /// Sample PySpark job
    public var samplePySparkJob: GoogleCloudDataprocJob {
        GoogleCloudDataprocJob(
            projectID: projectID,
            region: region,
            clusterName: clusterName,
            jobType: .pyspark,
            mainFile: "gs://\(projectID)-dataproc/scripts/etl_job.py",
            args: ["--input", "gs://\(projectID)-dataproc/input", "--output", "gs://\(projectID)-dataproc/output"],
            labels: ["managed-by": "dais"]
        )
    }

    /// Sample Spark job
    public var sampleSparkJob: GoogleCloudDataprocJob {
        GoogleCloudDataprocJob(
            projectID: projectID,
            region: region,
            clusterName: clusterName,
            jobType: .spark,
            mainClass: "com.dais.analytics.MainJob",
            jarFiles: ["gs://\(projectID)-dataproc/jars/analytics.jar"],
            properties: [
                "spark.executor.memory": "4g",
                "spark.driver.memory": "2g"
            ],
            labels: ["managed-by": "dais"]
        )
    }

    /// Sample serverless PySpark batch
    public var serverlessBatch: GoogleCloudDataprocBatch {
        GoogleCloudDataprocBatch(
            batchID: "dais-batch-\(Int(Date().timeIntervalSince1970))",
            projectID: projectID,
            region: region,
            batchType: .pyspark,
            mainFile: "gs://\(projectID)-dataproc/scripts/batch_job.py",
            labels: ["managed-by": "dais"],
            runtimeConfig: GoogleCloudDataprocBatch.RuntimeConfig(
                version: "2.0"
            )
        )
    }

    /// Autoscaling policy
    public var autoscalingPolicy: GoogleCloudDataprocAutoscalingPolicy {
        GoogleCloudDataprocAutoscalingPolicy(
            name: "\(clusterName)-autoscaling",
            projectID: projectID,
            region: region,
            workerConfig: GoogleCloudDataprocAutoscalingPolicy.InstanceGroupAutoscalingConfig(
                minInstances: 2,
                maxInstances: 10
            ),
            secondaryWorkerConfig: GoogleCloudDataprocAutoscalingPolicy.InstanceGroupAutoscalingConfig(
                minInstances: 0,
                maxInstances: 20
            ),
            cooldownPeriod: "120s"
        )
    }

    /// Setup script
    public var setupScript: String {
        var script = """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        REGION="\(region)"
        CLUSTER_NAME="\(clusterName)"

        echo "Enabling Cloud Dataproc API..."
        \(DataprocOperations.enableAPICommand)

        echo ""
        echo "Creating GCS bucket for Dataproc assets..."
        gsutil mb -p $PROJECT_ID -l $REGION gs://$PROJECT_ID-dataproc || true

        """

        if let sa = serviceAccount {
            script += """
            echo ""
            echo "Granting Dataproc editor role..."
            \(DataprocOperations.addEditorRoleCommand(projectID: projectID, serviceAccount: sa))

            """
        }

        script += """
        echo ""
        echo "Creating Dataproc cluster..."
        \(analyticsCluster.createCommand)

        echo ""
        echo "DAIS Dataproc setup complete!"
        echo ""
        echo "Cluster: $CLUSTER_NAME"
        echo "Region: $REGION"
        echo ""
        echo "Access Jupyter:"
        echo "  \(DataprocOperations.jupyterTunnelCommand(projectID: projectID, zone: "\(region)-a", clusterName: clusterName))"
        """

        return script
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        REGION="\(region)"
        CLUSTER_NAME="\(clusterName)"

        echo "Deleting Dataproc cluster..."
        \(analyticsCluster.deleteCommand) --quiet || true

        echo ""
        echo "Deleting batch cluster..."
        \(batchProcessingCluster.deleteCommand) --quiet || true

        echo ""
        echo "Dataproc teardown complete!"
        """
    }
}
