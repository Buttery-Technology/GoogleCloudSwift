// GoogleCloudBatch.swift
// Cloud Batch for containerized batch processing

import Foundation

// MARK: - Batch Job

/// A batch processing job
public struct GoogleCloudBatchJob: Codable, Sendable, Equatable {
    /// Job name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Task groups
    public let taskGroups: [TaskGroup]

    /// Allocation policy
    public let allocationPolicy: AllocationPolicy?

    /// Labels
    public let labels: [String: String]?

    /// Logs policy
    public let logsPolicy: LogsPolicy?

    /// Job status
    public let status: JobStatus?

    /// Create time
    public let createTime: String?

    /// Update time
    public let updateTime: String?

    public init(
        name: String,
        projectID: String,
        location: String,
        taskGroups: [TaskGroup],
        allocationPolicy: AllocationPolicy? = nil,
        labels: [String: String]? = nil,
        logsPolicy: LogsPolicy? = nil,
        status: JobStatus? = nil,
        createTime: String? = nil,
        updateTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.taskGroups = taskGroups
        self.allocationPolicy = allocationPolicy
        self.labels = labels
        self.logsPolicy = logsPolicy
        self.status = status
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/jobs/\(name)"
    }

    /// Submit job command
    public var submitCommand: String {
        "gcloud batch jobs submit \(name) --location=\(location) --config=job.json --project=\(projectID)"
    }

    /// Describe job command
    public var describeCommand: String {
        "gcloud batch jobs describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Delete job command
    public var deleteCommand: String {
        "gcloud batch jobs delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// List tasks command
    public var listTasksCommand: String {
        "gcloud batch tasks list --job=\(name) --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Task Group

/// A group of tasks in a batch job
public struct TaskGroup: Codable, Sendable, Equatable {
    /// Task group name
    public let name: String?

    /// Task spec
    public let taskSpec: TaskSpec

    /// Task count
    public let taskCount: Int

    /// Parallelism (max concurrent tasks)
    public let parallelism: Int?

    /// Task environments
    public let taskEnvironments: [Environment]?

    /// Task count per node
    public let taskCountPerNode: Int?

    /// Require hosts file
    public let requireHostsFile: Bool?

    /// Permissive SSH
    public let permissiveSsh: Bool?

    public init(
        name: String? = nil,
        taskSpec: TaskSpec,
        taskCount: Int,
        parallelism: Int? = nil,
        taskEnvironments: [Environment]? = nil,
        taskCountPerNode: Int? = nil,
        requireHostsFile: Bool? = nil,
        permissiveSsh: Bool? = nil
    ) {
        self.name = name
        self.taskSpec = taskSpec
        self.taskCount = taskCount
        self.parallelism = parallelism
        self.taskEnvironments = taskEnvironments
        self.taskCountPerNode = taskCountPerNode
        self.requireHostsFile = requireHostsFile
        self.permissiveSsh = permissiveSsh
    }
}

// MARK: - Task Spec

/// Specification for a task
public struct TaskSpec: Codable, Sendable, Equatable {
    /// Runnables (containers or scripts)
    public let runnables: [Runnable]

    /// Compute resource requirements
    public let computeResource: ComputeResource?

    /// Max run duration
    public let maxRunDuration: String?

    /// Max retry count
    public let maxRetryCount: Int?

    /// Lifecycle policies
    public let lifecyclePolicies: [LifecyclePolicy]?

    /// Environment variables
    public let environment: Environment?

    /// Volumes
    public let volumes: [Volume]?

    public init(
        runnables: [Runnable],
        computeResource: ComputeResource? = nil,
        maxRunDuration: String? = nil,
        maxRetryCount: Int? = nil,
        lifecyclePolicies: [LifecyclePolicy]? = nil,
        environment: Environment? = nil,
        volumes: [Volume]? = nil
    ) {
        self.runnables = runnables
        self.computeResource = computeResource
        self.maxRunDuration = maxRunDuration
        self.maxRetryCount = maxRetryCount
        self.lifecyclePolicies = lifecyclePolicies
        self.environment = environment
        self.volumes = volumes
    }
}

// MARK: - Runnable

/// A runnable task (container or script)
public struct Runnable: Codable, Sendable, Equatable {
    /// Container to run
    public let container: Container?

    /// Script to run
    public let script: Script?

    /// Barrier synchronization
    public let barrier: Barrier?

    /// Ignore exit status
    public let ignoreExitStatus: Bool?

    /// Run in background
    public let background: Bool?

    /// Always run (even if previous runnable failed)
    public let alwaysRun: Bool?

    /// Timeout
    public let timeout: String?

    /// Container configuration
    public struct Container: Codable, Sendable, Equatable {
        /// Image URI
        public let imageUri: String

        /// Commands
        public let commands: [String]?

        /// Entrypoint
        public let entrypoint: String?

        /// Volumes to mount
        public let volumes: [String]?

        /// Options
        public let options: String?

        /// Block external network
        public let blockExternalNetwork: Bool?

        /// Username
        public let username: String?

        /// Password
        public let password: String?

        public init(
            imageUri: String,
            commands: [String]? = nil,
            entrypoint: String? = nil,
            volumes: [String]? = nil,
            options: String? = nil,
            blockExternalNetwork: Bool? = nil,
            username: String? = nil,
            password: String? = nil
        ) {
            self.imageUri = imageUri
            self.commands = commands
            self.entrypoint = entrypoint
            self.volumes = volumes
            self.options = options
            self.blockExternalNetwork = blockExternalNetwork
            self.username = username
            self.password = password
        }
    }

    /// Script configuration
    public struct Script: Codable, Sendable, Equatable {
        /// Script text
        public let text: String?

        /// Script path
        public let path: String?

        public init(text: String? = nil, path: String? = nil) {
            self.text = text
            self.path = path
        }
    }

    /// Barrier for synchronization
    public struct Barrier: Codable, Sendable, Equatable {
        /// Barrier name
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public init(
        container: Container? = nil,
        script: Script? = nil,
        barrier: Barrier? = nil,
        ignoreExitStatus: Bool? = nil,
        background: Bool? = nil,
        alwaysRun: Bool? = nil,
        timeout: String? = nil
    ) {
        self.container = container
        self.script = script
        self.barrier = barrier
        self.ignoreExitStatus = ignoreExitStatus
        self.background = background
        self.alwaysRun = alwaysRun
        self.timeout = timeout
    }

    /// Create a container runnable
    public static func container(_ imageUri: String, commands: [String]? = nil) -> Runnable {
        Runnable(container: Container(imageUri: imageUri, commands: commands))
    }

    /// Create a script runnable
    public static func script(_ text: String) -> Runnable {
        Runnable(script: Script(text: text))
    }

    /// Create a barrier for synchronization
    public static func barrier(_ name: String) -> Runnable {
        Runnable(barrier: Barrier(name: name))
    }
}

// MARK: - Compute Resource

/// Compute resource requirements
public struct ComputeResource: Codable, Sendable, Equatable {
    /// CPU in milli-CPU units (1000 = 1 vCPU)
    public let cpuMilli: Int?

    /// Memory in MiB
    public let memoryMib: Int?

    /// Boot disk size in MiB
    public let bootDiskMib: Int?

    public init(cpuMilli: Int? = nil, memoryMib: Int? = nil, bootDiskMib: Int? = nil) {
        self.cpuMilli = cpuMilli
        self.memoryMib = memoryMib
        self.bootDiskMib = bootDiskMib
    }

    /// Standard compute (2 vCPUs, 8GB RAM)
    public static let standard = ComputeResource(cpuMilli: 2000, memoryMib: 8192)

    /// High memory (4 vCPUs, 32GB RAM)
    public static let highMemory = ComputeResource(cpuMilli: 4000, memoryMib: 32768)

    /// High CPU (8 vCPUs, 8GB RAM)
    public static let highCPU = ComputeResource(cpuMilli: 8000, memoryMib: 8192)

    /// Minimal (1 vCPU, 2GB RAM)
    public static let minimal = ComputeResource(cpuMilli: 1000, memoryMib: 2048)
}

// MARK: - Environment

/// Environment variables
public struct Environment: Codable, Sendable, Equatable {
    /// Variables
    public let variables: [String: String]?

    /// Secret variables
    public let secretVariables: [String: String]?

    /// Encrypted variables
    public let encryptedVariables: EncryptedVariables?

    /// Encrypted variables using KMS
    public struct EncryptedVariables: Codable, Sendable, Equatable {
        /// KMS key name
        public let keyName: String

        /// Ciphertext
        public let cipherText: String

        public init(keyName: String, cipherText: String) {
            self.keyName = keyName
            self.cipherText = cipherText
        }
    }

    public init(
        variables: [String: String]? = nil,
        secretVariables: [String: String]? = nil,
        encryptedVariables: EncryptedVariables? = nil
    ) {
        self.variables = variables
        self.secretVariables = secretVariables
        self.encryptedVariables = encryptedVariables
    }
}

// MARK: - Volume

/// Volume configuration
public struct Volume: Codable, Sendable, Equatable {
    /// GCS volume
    public let gcs: GCSVolume?

    /// NFS volume
    public let nfs: NFSVolume?

    /// Persistent disk
    public let pd: PersistentDisk?

    /// Device name
    public let deviceName: String?

    /// Mount path
    public let mountPath: String?

    /// Mount options
    public let mountOptions: [String]?

    /// GCS volume
    public struct GCSVolume: Codable, Sendable, Equatable {
        /// Remote path
        public let remotePath: String

        public init(remotePath: String) {
            self.remotePath = remotePath
        }
    }

    /// NFS volume
    public struct NFSVolume: Codable, Sendable, Equatable {
        /// NFS server
        public let server: String

        /// Remote path
        public let remotePath: String

        public init(server: String, remotePath: String) {
            self.server = server
            self.remotePath = remotePath
        }
    }

    /// Persistent disk
    public struct PersistentDisk: Codable, Sendable, Equatable {
        /// Disk type
        public let disk: String?

        /// Size in GB
        public let sizeGb: Int?

        /// Existing disk
        public let existing: Bool?

        public init(disk: String? = nil, sizeGb: Int? = nil, existing: Bool? = nil) {
            self.disk = disk
            self.sizeGb = sizeGb
            self.existing = existing
        }
    }

    public init(
        gcs: GCSVolume? = nil,
        nfs: NFSVolume? = nil,
        pd: PersistentDisk? = nil,
        deviceName: String? = nil,
        mountPath: String? = nil,
        mountOptions: [String]? = nil
    ) {
        self.gcs = gcs
        self.nfs = nfs
        self.pd = pd
        self.deviceName = deviceName
        self.mountPath = mountPath
        self.mountOptions = mountOptions
    }

    /// Mount GCS bucket
    public static func gcs(_ bucket: String, mountPath: String) -> Volume {
        Volume(gcs: GCSVolume(remotePath: bucket), mountPath: mountPath)
    }

    /// Mount NFS share
    public static func nfs(server: String, path: String, mountPath: String) -> Volume {
        Volume(nfs: NFSVolume(server: server, remotePath: path), mountPath: mountPath)
    }
}

// MARK: - Lifecycle Policy

/// Lifecycle policy for task failure handling
public struct LifecyclePolicy: Codable, Sendable, Equatable {
    /// Action to take
    public let action: Action

    /// Action trigger condition
    public let actionCondition: ActionCondition?

    /// Actions
    public enum Action: String, Codable, Sendable {
        case unspecified = "ACTION_UNSPECIFIED"
        case retryTask = "RETRY_TASK"
        case failTask = "FAIL_TASK"
    }

    /// Action condition
    public struct ActionCondition: Codable, Sendable, Equatable {
        /// Exit codes that trigger this action
        public let exitCodes: [Int]

        public init(exitCodes: [Int]) {
            self.exitCodes = exitCodes
        }
    }

    public init(action: Action, actionCondition: ActionCondition? = nil) {
        self.action = action
        self.actionCondition = actionCondition
    }

    /// Retry on specific exit codes
    public static func retryOn(_ exitCodes: [Int]) -> LifecyclePolicy {
        LifecyclePolicy(action: .retryTask, actionCondition: ActionCondition(exitCodes: exitCodes))
    }

    /// Fail on specific exit codes
    public static func failOn(_ exitCodes: [Int]) -> LifecyclePolicy {
        LifecyclePolicy(action: .failTask, actionCondition: ActionCondition(exitCodes: exitCodes))
    }
}

// MARK: - Allocation Policy

/// Resource allocation policy
public struct AllocationPolicy: Codable, Sendable, Equatable {
    /// Location policy
    public let location: LocationPolicy?

    /// Instance policy
    public let instances: [InstancePolicyOrTemplate]?

    /// Network policy
    public let network: NetworkPolicy?

    /// Service account
    public let serviceAccount: ServiceAccount?

    /// Labels
    public let labels: [String: String]?

    /// Location policy
    public struct LocationPolicy: Codable, Sendable, Equatable {
        /// Allowed locations
        public let allowedLocations: [String]

        public init(allowedLocations: [String]) {
            self.allowedLocations = allowedLocations
        }
    }

    /// Instance policy or template
    public struct InstancePolicyOrTemplate: Codable, Sendable, Equatable {
        /// Instance policy
        public let policy: InstancePolicy?

        /// Instance template
        public let instanceTemplate: String?

        /// Install GPU drivers
        public let installGpuDrivers: Bool?

        public init(policy: InstancePolicy? = nil, instanceTemplate: String? = nil, installGpuDrivers: Bool? = nil) {
            self.policy = policy
            self.instanceTemplate = instanceTemplate
            self.installGpuDrivers = installGpuDrivers
        }
    }

    /// Instance policy
    public struct InstancePolicy: Codable, Sendable, Equatable {
        /// Machine type
        public let machineType: String?

        /// Minimum CPU platform
        public let minCpuPlatform: String?

        /// Provisioning model
        public let provisioningModel: ProvisioningModel?

        /// Accelerators (GPUs)
        public let accelerators: [Accelerator]?

        /// Boot disk
        public let bootDisk: BootDisk?

        /// Disks
        public let disks: [AttachedDisk]?

        /// Provisioning model options
        public enum ProvisioningModel: String, Codable, Sendable {
            case unspecified = "PROVISIONING_MODEL_UNSPECIFIED"
            case standard = "STANDARD"
            case spot = "SPOT"
            case preemptible = "PREEMPTIBLE"
        }

        public init(
            machineType: String? = nil,
            minCpuPlatform: String? = nil,
            provisioningModel: ProvisioningModel? = nil,
            accelerators: [Accelerator]? = nil,
            bootDisk: BootDisk? = nil,
            disks: [AttachedDisk]? = nil
        ) {
            self.machineType = machineType
            self.minCpuPlatform = minCpuPlatform
            self.provisioningModel = provisioningModel
            self.accelerators = accelerators
            self.bootDisk = bootDisk
            self.disks = disks
        }
    }

    /// GPU accelerator
    public struct Accelerator: Codable, Sendable, Equatable {
        /// GPU type
        public let type: String

        /// Count
        public let count: Int

        public init(type: String, count: Int) {
            self.type = type
            self.count = count
        }

        /// NVIDIA T4 GPU
        public static func t4(_ count: Int = 1) -> Accelerator {
            Accelerator(type: "nvidia-tesla-t4", count: count)
        }

        /// NVIDIA V100 GPU
        public static func v100(_ count: Int = 1) -> Accelerator {
            Accelerator(type: "nvidia-tesla-v100", count: count)
        }

        /// NVIDIA A100 GPU
        public static func a100(_ count: Int = 1) -> Accelerator {
            Accelerator(type: "nvidia-a100-80gb", count: count)
        }

        /// NVIDIA L4 GPU
        public static func l4(_ count: Int = 1) -> Accelerator {
            Accelerator(type: "nvidia-l4", count: count)
        }
    }

    /// Boot disk configuration
    public struct BootDisk: Codable, Sendable, Equatable {
        /// Disk type
        public let type: String?

        /// Size in GB
        public let sizeGb: Int?

        /// Image
        public let image: String?

        public init(type: String? = nil, sizeGb: Int? = nil, image: String? = nil) {
            self.type = type
            self.sizeGb = sizeGb
            self.image = image
        }
    }

    /// Attached disk
    public struct AttachedDisk: Codable, Sendable, Equatable {
        /// New disk
        public let newDisk: Disk?

        /// Existing disk
        public let existingDisk: String?

        /// Device name
        public let deviceName: String?

        /// Disk configuration
        public struct Disk: Codable, Sendable, Equatable {
            /// Disk type
            public let type: String?

            /// Size in GB
            public let sizeGb: Int?

            /// Disk interface
            public let diskInterface: String?

            public init(type: String? = nil, sizeGb: Int? = nil, diskInterface: String? = nil) {
                self.type = type
                self.sizeGb = sizeGb
                self.diskInterface = diskInterface
            }
        }

        public init(newDisk: Disk? = nil, existingDisk: String? = nil, deviceName: String? = nil) {
            self.newDisk = newDisk
            self.existingDisk = existingDisk
            self.deviceName = deviceName
        }
    }

    /// Network policy
    public struct NetworkPolicy: Codable, Sendable, Equatable {
        /// Network interfaces
        public let networkInterfaces: [NetworkInterface]

        public init(networkInterfaces: [NetworkInterface]) {
            self.networkInterfaces = networkInterfaces
        }
    }

    /// Network interface
    public struct NetworkInterface: Codable, Sendable, Equatable {
        /// Network
        public let network: String?

        /// Subnetwork
        public let subnetwork: String?

        /// No external IP
        public let noExternalIpAddress: Bool?

        public init(network: String? = nil, subnetwork: String? = nil, noExternalIpAddress: Bool? = nil) {
            self.network = network
            self.subnetwork = subnetwork
            self.noExternalIpAddress = noExternalIpAddress
        }
    }

    /// Service account
    public struct ServiceAccount: Codable, Sendable, Equatable {
        /// Email
        public let email: String?

        /// Scopes
        public let scopes: [String]?

        public init(email: String? = nil, scopes: [String]? = nil) {
            self.email = email
            self.scopes = scopes
        }
    }

    public init(
        location: LocationPolicy? = nil,
        instances: [InstancePolicyOrTemplate]? = nil,
        network: NetworkPolicy? = nil,
        serviceAccount: ServiceAccount? = nil,
        labels: [String: String]? = nil
    ) {
        self.location = location
        self.instances = instances
        self.network = network
        self.serviceAccount = serviceAccount
        self.labels = labels
    }
}

// MARK: - Logs Policy

/// Logging policy
public struct LogsPolicy: Codable, Sendable, Equatable {
    /// Destination
    public let destination: Destination?

    /// Logs path
    public let logsPath: String?

    /// Destination options
    public enum Destination: String, Codable, Sendable {
        case unspecified = "DESTINATION_UNSPECIFIED"
        case cloudLogging = "CLOUD_LOGGING"
        case path = "PATH"
    }

    public init(destination: Destination? = nil, logsPath: String? = nil) {
        self.destination = destination
        self.logsPath = logsPath
    }

    /// Log to Cloud Logging
    public static let cloudLogging = LogsPolicy(destination: .cloudLogging)

    /// Log to path
    public static func toPath(_ path: String) -> LogsPolicy {
        LogsPolicy(destination: .path, logsPath: path)
    }
}

// MARK: - Job Status

/// Job status
public struct JobStatus: Codable, Sendable, Equatable {
    /// State
    public let state: State

    /// Status events
    public let statusEvents: [StatusEvent]?

    /// Task groups
    public let taskGroups: [String: TaskGroupStatus]?

    /// Run duration
    public let runDuration: String?

    /// State options
    public enum State: String, Codable, Sendable {
        case unspecified = "STATE_UNSPECIFIED"
        case queued = "QUEUED"
        case scheduled = "SCHEDULED"
        case running = "RUNNING"
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
        case deletionInProgress = "DELETION_IN_PROGRESS"
    }

    /// Status event
    public struct StatusEvent: Codable, Sendable, Equatable {
        /// Type
        public let type: String

        /// Description
        public let description: String

        /// Event time
        public let eventTime: String?

        public init(type: String, description: String, eventTime: String? = nil) {
            self.type = type
            self.description = description
            self.eventTime = eventTime
        }
    }

    /// Task group status
    public struct TaskGroupStatus: Codable, Sendable, Equatable {
        /// Counts by state
        public let counts: [String: Int]?

        public init(counts: [String: Int]? = nil) {
            self.counts = counts
        }
    }

    public init(
        state: State,
        statusEvents: [StatusEvent]? = nil,
        taskGroups: [String: TaskGroupStatus]? = nil,
        runDuration: String? = nil
    ) {
        self.state = state
        self.statusEvents = statusEvents
        self.taskGroups = taskGroups
        self.runDuration = runDuration
    }
}

// MARK: - Operations

/// Batch operations helper
public struct GoogleCloudBatchOperations: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "us-central1") {
        self.projectID = projectID
        self.location = location
    }

    /// List jobs
    public var listJobsCommand: String {
        "gcloud batch jobs list --location=\(location) --project=\(projectID)"
    }

    /// Describe job
    public func describeJob(_ name: String) -> String {
        "gcloud batch jobs describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Delete job
    public func deleteJob(_ name: String) -> String {
        "gcloud batch jobs delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// List tasks
    public func listTasks(job: String, taskGroup: String = "group0") -> String {
        "gcloud batch tasks list --job=\(job) --location=\(location) --project=\(projectID)"
    }

    /// Describe task
    public func describeTask(job: String, taskGroup: String, task: String) -> String {
        "gcloud batch tasks describe \(task) --job=\(job) --task-group=\(taskGroup) --location=\(location) --project=\(projectID)"
    }

    /// Enable Batch API
    public var enableAPICommand: String {
        "gcloud services enable batch.googleapis.com --project=\(projectID)"
    }

    /// IAM roles for Batch
    public static let roles: [String: String] = [
        "roles/batch.jobsViewer": "View batch jobs",
        "roles/batch.jobsEditor": "Edit batch jobs",
        "roles/batch.agentReporter": "Batch agent reporter",
        "roles/batch.serviceAgent": "Batch service agent"
    ]
}

// MARK: - DAIS Template

/// DAIS template for Cloud Batch
public struct DAISBatchTemplate: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Service account
    public let serviceAccount: String

    /// Default machine type
    public let defaultMachineType: String

    /// GCS bucket for data
    public let dataBucket: String

    public init(
        projectID: String,
        location: String = "us-central1",
        serviceAccount: String = "batch-service",
        defaultMachineType: String = "e2-standard-4",
        dataBucket: String = "batch-data"
    ) {
        self.projectID = projectID
        self.location = location
        self.serviceAccount = serviceAccount
        self.defaultMachineType = defaultMachineType
        self.dataBucket = dataBucket
    }

    /// Create a simple container job
    public func containerJob(
        name: String,
        imageUri: String,
        commands: [String]? = nil,
        taskCount: Int = 1,
        parallelism: Int? = nil
    ) -> GoogleCloudBatchJob {
        GoogleCloudBatchJob(
            name: name,
            projectID: projectID,
            location: location,
            taskGroups: [
                TaskGroup(
                    taskSpec: TaskSpec(
                        runnables: [.container(imageUri, commands: commands)],
                        computeResource: .standard
                    ),
                    taskCount: taskCount,
                    parallelism: parallelism ?? min(taskCount, 10)
                )
            ],
            allocationPolicy: AllocationPolicy(
                instances: [
                    AllocationPolicy.InstancePolicyOrTemplate(
                        policy: AllocationPolicy.InstancePolicy(
                            machineType: defaultMachineType
                        )
                    )
                ]
            ),
            logsPolicy: .cloudLogging
        )
    }

    /// Create a script job
    public func scriptJob(
        name: String,
        script: String,
        taskCount: Int = 1
    ) -> GoogleCloudBatchJob {
        GoogleCloudBatchJob(
            name: name,
            projectID: projectID,
            location: location,
            taskGroups: [
                TaskGroup(
                    taskSpec: TaskSpec(
                        runnables: [.script(script)],
                        computeResource: .minimal
                    ),
                    taskCount: taskCount
                )
            ],
            logsPolicy: .cloudLogging
        )
    }

    /// Create a GPU job
    public func gpuJob(
        name: String,
        imageUri: String,
        gpu: AllocationPolicy.Accelerator,
        taskCount: Int = 1
    ) -> GoogleCloudBatchJob {
        GoogleCloudBatchJob(
            name: name,
            projectID: projectID,
            location: location,
            taskGroups: [
                TaskGroup(
                    taskSpec: TaskSpec(
                        runnables: [.container(imageUri)],
                        computeResource: .highMemory
                    ),
                    taskCount: taskCount
                )
            ],
            allocationPolicy: AllocationPolicy(
                instances: [
                    AllocationPolicy.InstancePolicyOrTemplate(
                        policy: AllocationPolicy.InstancePolicy(
                            machineType: "n1-standard-8",
                            accelerators: [gpu]
                        ),
                        installGpuDrivers: true
                    )
                ]
            ),
            logsPolicy: .cloudLogging
        )
    }

    /// Create a spot instance job for cost savings
    public func spotJob(
        name: String,
        imageUri: String,
        taskCount: Int = 1
    ) -> GoogleCloudBatchJob {
        GoogleCloudBatchJob(
            name: name,
            projectID: projectID,
            location: location,
            taskGroups: [
                TaskGroup(
                    taskSpec: TaskSpec(
                        runnables: [.container(imageUri)],
                        computeResource: .standard,
                        maxRetryCount: 3
                    ),
                    taskCount: taskCount
                )
            ],
            allocationPolicy: AllocationPolicy(
                instances: [
                    AllocationPolicy.InstancePolicyOrTemplate(
                        policy: AllocationPolicy.InstancePolicy(
                            machineType: defaultMachineType,
                            provisioningModel: .spot
                        )
                    )
                ]
            ),
            logsPolicy: .cloudLogging
        )
    }

    /// Create job with GCS data access
    public func dataProcessingJob(
        name: String,
        imageUri: String,
        inputPath: String,
        outputPath: String,
        taskCount: Int = 1
    ) -> GoogleCloudBatchJob {
        GoogleCloudBatchJob(
            name: name,
            projectID: projectID,
            location: location,
            taskGroups: [
                TaskGroup(
                    taskSpec: TaskSpec(
                        runnables: [.container(imageUri)],
                        computeResource: .standard,
                        environment: Environment(
                            variables: [
                                "INPUT_PATH": inputPath,
                                "OUTPUT_PATH": outputPath,
                                "BATCH_TASK_INDEX": "${BATCH_TASK_INDEX}"
                            ]
                        ),
                        volumes: [
                            .gcs("gs://\(dataBucket)", mountPath: "/mnt/data")
                        ]
                    ),
                    taskCount: taskCount
                )
            ],
            allocationPolicy: AllocationPolicy(
                serviceAccount: AllocationPolicy.ServiceAccount(
                    email: "\(serviceAccount)@\(projectID).iam.gserviceaccount.com"
                )
            ),
            logsPolicy: .cloudLogging
        )
    }

    /// ML training job with GPU
    public func mlTrainingJob(
        name: String,
        imageUri: String,
        modelPath: String,
        epochs: Int = 10
    ) -> GoogleCloudBatchJob {
        GoogleCloudBatchJob(
            name: name,
            projectID: projectID,
            location: location,
            taskGroups: [
                TaskGroup(
                    taskSpec: TaskSpec(
                        runnables: [
                            .container(imageUri, commands: [
                                "--model-dir", "/mnt/models",
                                "--epochs", String(epochs)
                            ])
                        ],
                        computeResource: ComputeResource(cpuMilli: 8000, memoryMib: 32768),
                        maxRunDuration: "86400s",  // 24 hours
                        environment: Environment(
                            variables: [
                                "MODEL_PATH": modelPath
                            ]
                        ),
                        volumes: [
                            .gcs("gs://\(dataBucket)/models", mountPath: "/mnt/models")
                        ]
                    ),
                    taskCount: 1
                )
            ],
            allocationPolicy: AllocationPolicy(
                instances: [
                    AllocationPolicy.InstancePolicyOrTemplate(
                        policy: AllocationPolicy.InstancePolicy(
                            machineType: "n1-standard-8",
                            accelerators: [.t4(1)]
                        ),
                        installGpuDrivers: true
                    )
                ]
            ),
            logsPolicy: .cloudLogging
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        # DAIS Batch Setup

        PROJECT_ID="\(projectID)"

        # Enable Batch API
        gcloud services enable batch.googleapis.com --project=$PROJECT_ID

        # Create service account
        gcloud iam service-accounts create \(serviceAccount) \\
            --display-name="Batch Service Account" \\
            --project=$PROJECT_ID

        # Grant Batch editor role
        gcloud projects add-iam-policy-binding $PROJECT_ID \\
            --member="serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com" \\
            --role="roles/batch.jobsEditor"

        # Grant log writer role
        gcloud projects add-iam-policy-binding $PROJECT_ID \\
            --member="serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com" \\
            --role="roles/logging.logWriter"

        # Create data bucket
        gsutil mb -p $PROJECT_ID -l \(location) gs://\(dataBucket)

        # Grant storage access
        gsutil iam ch serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com:objectAdmin gs://\(dataBucket)

        echo "Batch setup complete!"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        # DAIS Batch Teardown

        PROJECT_ID="\(projectID)"

        # Delete all jobs
        for job in $(gcloud batch jobs list --location=\(location) --project=$PROJECT_ID --format="value(name)"); do
            gcloud batch jobs delete $job --location=\(location) --project=$PROJECT_ID --quiet || true
        done

        # Delete data bucket
        gsutil rm -r gs://\(dataBucket) || true

        # Delete service account
        gcloud iam service-accounts delete \(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com \\
            --quiet --project=$PROJECT_ID || true

        echo "Batch resources cleaned up!"
        """
    }

    /// Sample job JSON
    public var sampleJobJSON: String {
        """
        {
          "taskGroups": [
            {
              "taskSpec": {
                "runnables": [
                  {
                    "container": {
                      "imageUri": "gcr.io/\(projectID)/my-batch-image:latest",
                      "commands": ["--input", "/mnt/data/input", "--output", "/mnt/data/output"]
                    }
                  }
                ],
                "computeResource": {
                  "cpuMilli": 2000,
                  "memoryMib": 8192
                },
                "volumes": [
                  {
                    "gcs": {
                      "remotePath": "\(dataBucket)"
                    },
                    "mountPath": "/mnt/data"
                  }
                ]
              },
              "taskCount": 10,
              "parallelism": 5
            }
          ],
          "allocationPolicy": {
            "instances": [
              {
                "policy": {
                  "machineType": "\(defaultMachineType)"
                }
              }
            ]
          },
          "logsPolicy": {
            "destination": "CLOUD_LOGGING"
          }
        }
        """
    }
}
