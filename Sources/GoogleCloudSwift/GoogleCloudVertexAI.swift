import Foundation

// MARK: - Vertex AI Dataset

/// Represents a Vertex AI dataset
public struct GoogleCloudVertexAIDataset: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String
    public let metadataSchemaUri: String?
    public let description: String?
    public let labels: [String: String]?
    public let createTime: Date?
    public let updateTime: Date?

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        displayName: String,
        metadataSchemaUri: String? = nil,
        description: String? = nil,
        labels: [String: String]? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.metadataSchemaUri = metadataSchemaUri
        self.description = description
        self.labels = labels
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/datasets/\(name)"
    }

    /// Command to create the dataset
    public var createCommand: String {
        var cmd = "gcloud ai datasets create --project=\(projectID) --region=\(location) --display-name='\(displayName)'"

        if let schema = metadataSchemaUri {
            cmd += " --metadata-schema-uri=\(schema)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to delete the dataset
    public var deleteCommand: String {
        "gcloud ai datasets delete \(name) --project=\(projectID) --region=\(location) --quiet"
    }

    /// Command to describe the dataset
    public var describeCommand: String {
        "gcloud ai datasets describe \(name) --project=\(projectID) --region=\(location)"
    }

    /// Command to list datasets
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ai datasets list --project=\(projectID) --region=\(location)"
    }
}

// MARK: - Vertex AI Model

/// Represents a Vertex AI model
public struct GoogleCloudVertexAIModel: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String
    public let description: String?
    public let artifactUri: String?
    public let containerSpec: ContainerSpec?
    public let labels: [String: String]?
    public let versionId: String?
    public let createTime: Date?
    public let updateTime: Date?

    public struct ContainerSpec: Codable, Sendable, Equatable {
        public let imageUri: String
        public let command: [String]?
        public let args: [String]?
        public let env: [EnvVar]?
        public let ports: [Port]?
        public let predictRoute: String?
        public let healthRoute: String?

        public struct EnvVar: Codable, Sendable, Equatable {
            public let name: String
            public let value: String

            public init(name: String, value: String) {
                self.name = name
                self.value = value
            }
        }

        public struct Port: Codable, Sendable, Equatable {
            public let containerPort: Int

            public init(containerPort: Int) {
                self.containerPort = containerPort
            }
        }

        public init(
            imageUri: String,
            command: [String]? = nil,
            args: [String]? = nil,
            env: [EnvVar]? = nil,
            ports: [Port]? = nil,
            predictRoute: String? = nil,
            healthRoute: String? = nil
        ) {
            self.imageUri = imageUri
            self.command = command
            self.args = args
            self.env = env
            self.ports = ports
            self.predictRoute = predictRoute
            self.healthRoute = healthRoute
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        displayName: String,
        description: String? = nil,
        artifactUri: String? = nil,
        containerSpec: ContainerSpec? = nil,
        labels: [String: String]? = nil,
        versionId: String? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.description = description
        self.artifactUri = artifactUri
        self.containerSpec = containerSpec
        self.labels = labels
        self.versionId = versionId
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/models/\(name)"
    }

    /// Command to upload a model
    public var uploadCommand: String {
        var cmd = "gcloud ai models upload --project=\(projectID) --region=\(location) --display-name='\(displayName)'"

        if let artifactUri = artifactUri {
            cmd += " --artifact-uri=\(artifactUri)"
        }

        if let containerSpec = containerSpec {
            cmd += " --container-image-uri=\(containerSpec.imageUri)"
            if let predictRoute = containerSpec.predictRoute {
                cmd += " --container-predict-route=\(predictRoute)"
            }
            if let healthRoute = containerSpec.healthRoute {
                cmd += " --container-health-route=\(healthRoute)"
            }
        }

        return cmd
    }

    /// Command to delete the model
    public var deleteCommand: String {
        "gcloud ai models delete \(name) --project=\(projectID) --region=\(location) --quiet"
    }

    /// Command to describe the model
    public var describeCommand: String {
        "gcloud ai models describe \(name) --project=\(projectID) --region=\(location)"
    }

    /// Command to list models
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ai models list --project=\(projectID) --region=\(location)"
    }
}

// MARK: - Vertex AI Endpoint

/// Represents a Vertex AI endpoint for serving predictions
public struct GoogleCloudVertexAIEndpoint: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String
    public let description: String?
    public let network: String?
    public let enablePrivateServiceConnect: Bool?
    public let labels: [String: String]?
    public let createTime: Date?

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        displayName: String,
        description: String? = nil,
        network: String? = nil,
        enablePrivateServiceConnect: Bool? = nil,
        labels: [String: String]? = nil,
        createTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.description = description
        self.network = network
        self.enablePrivateServiceConnect = enablePrivateServiceConnect
        self.labels = labels
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/endpoints/\(name)"
    }

    /// Command to create the endpoint
    public var createCommand: String {
        var cmd = "gcloud ai endpoints create --project=\(projectID) --region=\(location) --display-name='\(displayName)'"

        if let network = network {
            cmd += " --network=\(network)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to deploy a model to the endpoint
    public func deployModelCommand(modelID: String, machineType: String = "n1-standard-4", minReplicaCount: Int = 1, maxReplicaCount: Int = 1, trafficSplit: Int = 100) -> String {
        "gcloud ai endpoints deploy-model \(name) --project=\(projectID) --region=\(location) --model=\(modelID) --display-name=deployed-model --machine-type=\(machineType) --min-replica-count=\(minReplicaCount) --max-replica-count=\(maxReplicaCount) --traffic-split=0=\(trafficSplit)"
    }

    /// Command to undeploy a model
    public func undeployModelCommand(deployedModelID: String) -> String {
        "gcloud ai endpoints undeploy-model \(name) --project=\(projectID) --region=\(location) --deployed-model-id=\(deployedModelID)"
    }

    /// Command to delete the endpoint
    public var deleteCommand: String {
        "gcloud ai endpoints delete \(name) --project=\(projectID) --region=\(location) --quiet"
    }

    /// Command to describe the endpoint
    public var describeCommand: String {
        "gcloud ai endpoints describe \(name) --project=\(projectID) --region=\(location)"
    }

    /// Command to predict
    public func predictCommand(jsonRequest: String) -> String {
        "gcloud ai endpoints predict \(name) --project=\(projectID) --region=\(location) --json-request='\(jsonRequest)'"
    }

    /// Command to list endpoints
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ai endpoints list --project=\(projectID) --region=\(location)"
    }
}

// MARK: - Vertex AI Custom Job

/// Represents a Vertex AI custom training job
public struct GoogleCloudVertexAICustomJob: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String
    public let workerPoolSpecs: [WorkerPoolSpec]
    public let serviceAccount: String?
    public let network: String?
    public let labels: [String: String]?
    public let state: JobState?

    public struct WorkerPoolSpec: Codable, Sendable, Equatable {
        public let machineSpec: MachineSpec
        public let replicaCount: Int
        public let containerSpec: ContainerSpec?
        public let pythonPackageSpec: PythonPackageSpec?
        public let diskSpec: DiskSpec?

        public struct MachineSpec: Codable, Sendable, Equatable {
            public let machineType: String
            public let acceleratorType: String?
            public let acceleratorCount: Int?

            public init(machineType: String, acceleratorType: String? = nil, acceleratorCount: Int? = nil) {
                self.machineType = machineType
                self.acceleratorType = acceleratorType
                self.acceleratorCount = acceleratorCount
            }
        }

        public struct ContainerSpec: Codable, Sendable, Equatable {
            public let imageUri: String
            public let command: [String]?
            public let args: [String]?

            public init(imageUri: String, command: [String]? = nil, args: [String]? = nil) {
                self.imageUri = imageUri
                self.command = command
                self.args = args
            }
        }

        public struct PythonPackageSpec: Codable, Sendable, Equatable {
            public let executorImageUri: String
            public let packageUris: [String]
            public let pythonModule: String
            public let args: [String]?

            public init(executorImageUri: String, packageUris: [String], pythonModule: String, args: [String]? = nil) {
                self.executorImageUri = executorImageUri
                self.packageUris = packageUris
                self.pythonModule = pythonModule
                self.args = args
            }
        }

        public struct DiskSpec: Codable, Sendable, Equatable {
            public let bootDiskType: String
            public let bootDiskSizeGb: Int

            public init(bootDiskType: String = "pd-ssd", bootDiskSizeGb: Int = 100) {
                self.bootDiskType = bootDiskType
                self.bootDiskSizeGb = bootDiskSizeGb
            }
        }

        public init(
            machineSpec: MachineSpec,
            replicaCount: Int = 1,
            containerSpec: ContainerSpec? = nil,
            pythonPackageSpec: PythonPackageSpec? = nil,
            diskSpec: DiskSpec? = nil
        ) {
            self.machineSpec = machineSpec
            self.replicaCount = replicaCount
            self.containerSpec = containerSpec
            self.pythonPackageSpec = pythonPackageSpec
            self.diskSpec = diskSpec
        }
    }

    public enum JobState: String, Codable, Sendable, Equatable {
        case jobStateUnspecified = "JOB_STATE_UNSPECIFIED"
        case jobStateQueued = "JOB_STATE_QUEUED"
        case jobStatePending = "JOB_STATE_PENDING"
        case jobStateRunning = "JOB_STATE_RUNNING"
        case jobStateSucceeded = "JOB_STATE_SUCCEEDED"
        case jobStateFailed = "JOB_STATE_FAILED"
        case jobStateCancelling = "JOB_STATE_CANCELLING"
        case jobStateCancelled = "JOB_STATE_CANCELLED"
        case jobStatePaused = "JOB_STATE_PAUSED"
        case jobStateExpired = "JOB_STATE_EXPIRED"
    }

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        displayName: String,
        workerPoolSpecs: [WorkerPoolSpec],
        serviceAccount: String? = nil,
        network: String? = nil,
        labels: [String: String]? = nil,
        state: JobState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.workerPoolSpecs = workerPoolSpecs
        self.serviceAccount = serviceAccount
        self.network = network
        self.labels = labels
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/customJobs/\(name)"
    }

    /// Command to run a custom job with a container
    public func runContainerCommand(imageUri: String, machineType: String = "n1-standard-4", args: [String]? = nil) -> String {
        var cmd = "gcloud ai custom-jobs create --project=\(projectID) --region=\(location) --display-name='\(displayName)' --worker-pool-spec=machine-type=\(machineType),replica-count=1,container-image-uri=\(imageUri)"

        if let args = args, !args.isEmpty {
            cmd += ",args='\(args.joined(separator: ","))'"
        }

        if let serviceAccount = serviceAccount {
            cmd += " --service-account=\(serviceAccount)"
        }

        return cmd
    }

    /// Command to run a custom job with Python package
    public func runPythonCommand(executorImage: String, packageUri: String, module: String, machineType: String = "n1-standard-4") -> String {
        var cmd = "gcloud ai custom-jobs create --project=\(projectID) --region=\(location) --display-name='\(displayName)' --worker-pool-spec=machine-type=\(machineType),replica-count=1,executor-image-uri=\(executorImage),python-module=\(module)"

        cmd += " --python-package-uris=\(packageUri)"

        if let serviceAccount = serviceAccount {
            cmd += " --service-account=\(serviceAccount)"
        }

        return cmd
    }

    /// Command to list custom jobs
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ai custom-jobs list --project=\(projectID) --region=\(location)"
    }

    /// Command to describe a custom job
    public var describeCommand: String {
        "gcloud ai custom-jobs describe \(name) --project=\(projectID) --region=\(location)"
    }

    /// Command to cancel a custom job
    public var cancelCommand: String {
        "gcloud ai custom-jobs cancel \(name) --project=\(projectID) --region=\(location)"
    }
}

// MARK: - Vertex AI Operations

/// Helper operations for Vertex AI
public struct VertexAIOperations: Sendable {

    /// Command to enable Vertex AI API
    public static var enableAPICommand: String {
        "gcloud services enable aiplatform.googleapis.com"
    }

    /// Common pre-built container images for training
    public struct TrainingContainers {
        public static let pytorchGpu = "us-docker.pkg.dev/vertex-ai/training/pytorch-gpu.1-13.py310:latest"
        public static let pytorchCpu = "us-docker.pkg.dev/vertex-ai/training/pytorch-cpu.1-13.py310:latest"
        public static let tensorflowGpu = "us-docker.pkg.dev/vertex-ai/training/tf-gpu.2-12.py310:latest"
        public static let tensorflowCpu = "us-docker.pkg.dev/vertex-ai/training/tf-cpu.2-12.py310:latest"
        public static let scikitLearn = "us-docker.pkg.dev/vertex-ai/training/sklearn-cpu.1-2.py310:latest"
        public static let xgboost = "us-docker.pkg.dev/vertex-ai/training/xgboost-cpu.1-7.py310:latest"
    }

    /// Common pre-built container images for prediction
    public struct PredictionContainers {
        public static let pytorchGpu = "us-docker.pkg.dev/vertex-ai/prediction/pytorch-gpu.1-13:latest"
        public static let pytorchCpu = "us-docker.pkg.dev/vertex-ai/prediction/pytorch-cpu.1-13:latest"
        public static let tensorflowGpu = "us-docker.pkg.dev/vertex-ai/prediction/tf-gpu.2-12:latest"
        public static let tensorflowCpu = "us-docker.pkg.dev/vertex-ai/prediction/tf-cpu.2-12:latest"
        public static let scikitLearn = "us-docker.pkg.dev/vertex-ai/prediction/sklearn-cpu.1-2:latest"
        public static let xgboost = "us-docker.pkg.dev/vertex-ai/prediction/xgboost-cpu.1-7:latest"
    }

    /// Common machine types for training
    public struct MachineTypes {
        public static let n1Standard4 = "n1-standard-4"
        public static let n1Standard8 = "n1-standard-8"
        public static let n1Standard16 = "n1-standard-16"
        public static let n1Highmem8 = "n1-highmem-8"
        public static let n1Highmem16 = "n1-highmem-16"
        public static let a2Highgpu1g = "a2-highgpu-1g"  // 1x A100 GPU
        public static let a2Highgpu2g = "a2-highgpu-2g"  // 2x A100 GPU
        public static let a2Highgpu4g = "a2-highgpu-4g"  // 4x A100 GPU
    }

    /// Common accelerator types
    public struct AcceleratorTypes {
        public static let nvidiaT4 = "NVIDIA_TESLA_T4"
        public static let nvidiaV100 = "NVIDIA_TESLA_V100"
        public static let nvidiaP100 = "NVIDIA_TESLA_P100"
        public static let nvidiaA100 = "NVIDIA_TESLA_A100"
        public static let nvidiaL4 = "NVIDIA_L4"
    }

    /// Command to list operations
    public static func listOperationsCommand(projectID: String, location: String) -> String {
        "gcloud ai operations list --project=\(projectID) --region=\(location)"
    }

    /// Command to describe an operation
    public static func describeOperationCommand(operationID: String, projectID: String, location: String) -> String {
        "gcloud ai operations describe \(operationID) --project=\(projectID) --region=\(location)"
    }
}

// MARK: - DAIS Vertex AI Template

/// Production-ready Vertex AI templates for DAIS systems
public struct DAISVertexAITemplate: Sendable {
    public let projectID: String
    public let location: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        location: String = "us-central1",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.serviceAccount = serviceAccount
    }

    /// Training dataset for DAIS models
    public var trainingDataset: GoogleCloudVertexAIDataset {
        GoogleCloudVertexAIDataset(
            name: "dais-training-dataset",
            projectID: projectID,
            location: location,
            displayName: "DAIS Training Dataset",
            labels: ["app": "dais", "type": "training"]
        )
    }

    /// Prediction endpoint
    public var predictionEndpoint: GoogleCloudVertexAIEndpoint {
        GoogleCloudVertexAIEndpoint(
            name: "dais-prediction",
            projectID: projectID,
            location: location,
            displayName: "DAIS Prediction Endpoint",
            labels: ["app": "dais", "type": "prediction"]
        )
    }

    /// Custom training job template
    public var customTrainingJob: GoogleCloudVertexAICustomJob {
        GoogleCloudVertexAICustomJob(
            name: "dais-training",
            projectID: projectID,
            location: location,
            displayName: "DAIS Custom Training Job",
            workerPoolSpecs: [
                GoogleCloudVertexAICustomJob.WorkerPoolSpec(
                    machineSpec: GoogleCloudVertexAICustomJob.WorkerPoolSpec.MachineSpec(
                        machineType: "n1-standard-8",
                        acceleratorType: "NVIDIA_TESLA_T4",
                        acceleratorCount: 1
                    ),
                    replicaCount: 1,
                    diskSpec: GoogleCloudVertexAICustomJob.WorkerPoolSpec.DiskSpec(
                        bootDiskType: "pd-ssd",
                        bootDiskSizeGb: 100
                    )
                )
            ],
            serviceAccount: serviceAccount,
            labels: ["app": "dais"]
        )
    }

    /// Model configuration for DAIS
    public func daisModel(artifactUri: String) -> GoogleCloudVertexAIModel {
        GoogleCloudVertexAIModel(
            name: "dais-model",
            projectID: projectID,
            location: location,
            displayName: "DAIS Model",
            artifactUri: artifactUri,
            containerSpec: GoogleCloudVertexAIModel.ContainerSpec(
                imageUri: VertexAIOperations.PredictionContainers.pytorchCpu,
                predictRoute: "/predict",
                healthRoute: "/health"
            ),
            labels: ["app": "dais"]
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"

        echo "Enabling Vertex AI API..."
        gcloud services enable aiplatform.googleapis.com --project=$PROJECT_ID

        echo "Creating prediction endpoint..."
        \(predictionEndpoint.createCommand)

        echo ""
        echo "DAIS Vertex AI setup complete!"
        echo ""
        echo "Endpoint: dais-prediction"
        echo "Location: $LOCATION"
        echo ""
        echo "To upload a model:"
        echo "  gcloud ai models upload --project=$PROJECT_ID --region=$LOCATION --display-name=my-model --artifact-uri=gs://bucket/model"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"

        echo "Deleting Vertex AI endpoint..."
        \(predictionEndpoint.deleteCommand)

        echo "Vertex AI teardown complete!"
        """
    }
}
