# GoogleCloudSwift

Swift models for deploying and running DAIS (Distributed AI Systems) on Google Cloud Platform.

## Why Google Cloud?

Google Cloud offers several advantages for DAIS deployments:

| Feature | Benefit |
|---------|---------|
| **Free Tier** | e2-micro instance (1/month), 5GB storage, 6 secret versions |
| **Secret Manager** | Secure credential storage with free tier |
| **Global Network** | Low-latency gRPC communication |
| **Spot VMs** | Up to 70% cost savings |
| **Simple Pricing** | Predictable, per-second billing |

## Installation

Add GoogleCloudSwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jonnyholland/GoogleCloudSwift.git", from: "1.0.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["GoogleCloudSwift"]
)
```

## Quick Start

### 1. Prerequisites

```bash
# Install Google Cloud CLI
brew install google-cloud-sdk

# Authenticate
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 2. Using GoogleCloudSwift Models

```swift
import GoogleCloudSwift

// Configure Google Cloud provider
let provider = GoogleCloudProvider(
    projectID: "my-butteryai-project",
    region: .usWest1,
    credentials: .applicationDefault
)

// Create a deployment configuration
let deployment = GoogleCloudDAISDeployment(
    name: "production",
    provider: provider,
    nodeCount: 3,
    machineType: .n2Standard2
)

// Generate setup script
print(deployment.setupScript)

// Estimated cost
print("Monthly cost: $\(deployment.estimatedMonthlyCostUSD)")
```

### 3. Deploy DAIS

```bash
# Generate and run the setup script
swift run GenerateDeploymentScript > setup-dais.sh
chmod +x setup-dais.sh
./setup-dais.sh
```

## Models Overview

GoogleCloudSwift provides models for 57 Google Cloud services:

| Module | Purpose | Key Types |
|--------|---------|-----------|
| **Provider** | Project & region configuration | `GoogleCloudProvider`, `GoogleCloudRegion` |
| **Compute Engine** | VM instances | `GoogleCloudComputeInstance`, `GoogleCloudMachineType` |
| **Secret Manager** | Secure credentials | `GoogleCloudSecret`, `SecretManagerIAMBinding` |
| **Cloud Storage** | Object storage | `GoogleCloudStorageBucket`, `LifecycleRule` |
| **Cloud SQL** | Managed databases (PostgreSQL, MySQL, SQL Server) | `GoogleCloudSQLInstance`, `GoogleCloudSQLDatabase` |
| **Cloud Pub/Sub** | Messaging and event streaming | `GoogleCloudPubSubTopic`, `GoogleCloudPubSubSubscription` |
| **Cloud Functions** | Serverless compute | `GoogleCloudFunction`, `CloudFunctionRuntime` |
| **Cloud Run** | Containerized services | `GoogleCloudRunService`, `GoogleCloudRunJob` |
| **GKE** | Kubernetes Engine clusters | `GoogleCloudGKECluster`, `GoogleCloudGKENodePool`, `GKEOperations`, `DAISGKETemplate` |
| **Cloud Logging** | Log management and analysis | `GoogleCloudLogEntry`, `GoogleCloudLogSink` |
| **Cloud Monitoring** | Metrics, alerts, and uptime checks | `GoogleCloudAlertPolicy`, `GoogleCloudUptimeCheck` |
| **VPC Networks** | Virtual Private Cloud networking | `GoogleCloudVPCNetwork`, `GoogleCloudSubnet`, `GoogleCloudFirewallRule` |
| **Cloud DNS** | Domain name system management | `GoogleCloudManagedZone`, `GoogleCloudDNSRecord`, `GoogleCloudDNSPolicy` |
| **Cloud Load Balancing** | Global and regional load balancing | `GoogleCloudHealthCheck`, `GoogleCloudBackendService`, `GoogleCloudURLMap` |
| **Artifact Registry** | Container and package management | `GoogleCloudArtifactRegistryRepository`, `GoogleCloudDockerImage` |
| **Cloud Build** | CI/CD pipelines | `GoogleCloudBuild`, `GoogleCloudBuildTrigger`, `GoogleCloudBuildWorkerPool` |
| **Cloud Armor** | WAF & DDoS protection | `GoogleCloudSecurityPolicy`, `SecurityPolicyRule`, `WAFRule` |
| **Cloud CDN** | Content delivery network | `CDNCachePolicy`, `CDNBackendBucket`, `CDNCacheInvalidation` |
| **Cloud Tasks** | Distributed task queues | `GoogleCloudTaskQueue`, `GoogleCloudHTTPTask`, `GoogleCloudAppEngineTask` |
| **Cloud KMS** | Key management service | `GoogleCloudKeyRing`, `GoogleCloudCryptoKey`, `GoogleCloudCryptoKeyVersion` |
| **Eventarc** | Event-driven architecture | `GoogleCloudEventarcTrigger`, `GoogleCloudEventarcChannel`, `GoogleCloudEventType` |
| **Memorystore** | Managed Redis & Memcached | `GoogleCloudRedisInstance`, `GoogleCloudMemcachedInstance` |
| **VPC Service Controls** | Data exfiltration prevention | `GoogleCloudAccessPolicy`, `GoogleCloudServicePerimeter`, `GoogleCloudAccessLevel` |
| **Cloud Filestore** | Managed NFS file shares | `GoogleCloudFilestoreInstance`, `GoogleCloudFilestoreBackup`, `GoogleCloudFilestoreSnapshot` |
| **Cloud VPN** | Secure network connectivity | `GoogleCloudVPNGateway`, `GoogleCloudVPNTunnel`, `GoogleCloudExternalVPNGateway` |
| **BigQuery** | Data warehouse and analytics | `GoogleCloudBigQueryDataset`, `GoogleCloudBigQueryTable`, `GoogleCloudBigQueryJob`, `GoogleCloudBigQueryView` |
| **Cloud Spanner** | Globally distributed relational database | `GoogleCloudSpannerInstance`, `GoogleCloudSpannerDatabase`, `GoogleCloudSpannerBackup`, `DAISSpannerTemplate` |
| **Firestore** | NoSQL document database | `GoogleCloudFirestoreDatabase`, `GoogleCloudFirestoreIndex`, `GoogleCloudFirestoreExport`, `DAISFirestoreTemplate` |
| **Vertex AI** | Machine learning platform | `GoogleCloudVertexAIModel`, `GoogleCloudVertexAIEndpoint`, `GoogleCloudVertexAICustomJob`, `DAISVertexAITemplate` |
| **Cloud Trace** | Distributed tracing | `GoogleCloudTraceSpan`, `GoogleCloudTraceSink`, `TraceOperations`, `DAISTraceTemplate` |
| **Cloud Profiler** | Continuous profiling | `GoogleCloudProfilerProfile`, `GoogleCloudProfilerAgentConfig`, `ProfilerOperations`, `DAISProfilerTemplate` |
| **Error Reporting** | Error collection and analysis | `GoogleCloudErrorEvent`, `GoogleCloudErrorGroup`, `ErrorReportingOperations`, `DAISErrorReportingTemplate` |
| **Cloud Bigtable** | Wide-column NoSQL database | `GoogleCloudBigtableInstance`, `GoogleCloudBigtableCluster`, `GoogleCloudBigtableTable`, `DAISBigtableTemplate` |
| **Dataproc** | Managed Spark and Hadoop | `GoogleCloudDataprocCluster`, `GoogleCloudDataprocJob`, `GoogleCloudDataprocBatch`, `DAISDataprocTemplate` |
| **Cloud Composer** | Managed Apache Airflow | `GoogleCloudComposerEnvironment`, `GoogleCloudComposerDAG`, `ComposerOperations`, `DAISComposerTemplate` |
| **Document AI** | Intelligent document processing | `GoogleCloudDocumentAIProcessor`, `GoogleCloudDocument`, `DocumentAIOperations`, `DAISDocumentAITemplate` |
| **Vision AI** | Image analysis and understanding | `GoogleCloudVisionRequest`, `GoogleCloudVisionResponse`, `VisionOperations`, `DAISVisionAITemplate` |
| **Speech-to-Text** | Audio transcription | `GoogleCloudSpeechRecognitionRequest`, `GoogleCloudSpeechRecognizer`, `SpeechToTextOperations`, `DAISSpeechToTextTemplate` |
| **Text-to-Speech** | Speech synthesis | `GoogleCloudTextToSpeechRequest`, `GoogleCloudTextToSpeechVoice`, `SSMLBuilder`, `DAISTextToSpeechTemplate` |
| **Translation AI** | Text translation | `GoogleCloudTranslationRequest`, `GoogleCloudGlossary`, `LanguageCode`, `DAISTranslationTemplate` |
| **Cloud Batch** | Containerized batch processing | `GoogleCloudBatchJob`, `TaskGroup`, `AllocationPolicy`, `DAISBatchTemplate` |
| **Binary Authorization** | Container image security | `GoogleCloudBinaryAuthorizationPolicy`, `GoogleCloudAttestor`, `AdmissionRule`, `DAISBinaryAuthorizationTemplate` |
| **Certificate Authority Service** | Private CA management | `GoogleCloudCaPool`, `GoogleCloudCertificateAuthority`, `GoogleCloudCertificate`, `DAISCertificateAuthorityTemplate` |
| **Network Intelligence Center** | Network monitoring and diagnostics | `GoogleCloudConnectivityTest`, `Endpoint`, `GoogleCloudNetworkTopology`, `DAISNetworkIntelligenceTemplate` |
| **Cloud Interconnect** | Dedicated and partner network connections | `GoogleCloudInterconnect`, `GoogleCloudInterconnectAttachment`, `GoogleCloudRouterForInterconnect`, `DAISInterconnectTemplate` |
| **Cloud Healthcare API** | Healthcare data storage (FHIR, HL7v2, DICOM) | `GoogleCloudHealthcareDataset`, `GoogleCloudFHIRStore`, `GoogleCloudDICOMStore`, `DAISHealthcareTemplate` |
| **Dataflow** | Batch and streaming data processing | `GoogleCloudDataflowJob`, `GoogleCloudDataflowFlexTemplate`, `GoogleCloudDataflowSQL`, `GoogleCloudDataflowSnapshot` |
| **Cloud Deploy** | Continuous delivery to GKE/Cloud Run | `GoogleCloudDeliveryPipeline`, `GoogleCloudDeployTarget`, `GoogleCloudDeployRelease`, `GoogleCloudDeployRollout` |
| **Cloud Workflows** | Serverless workflow orchestration | `GoogleCloudWorkflow`, `GoogleCloudWorkflowExecution`, `WorkflowStep`, `WorkflowConnectors` |
| **API Gateway** | Serverless API management | `GoogleCloudAPIGatewayAPI`, `GoogleCloudAPIGatewayConfig`, `GoogleCloudAPIGatewayGateway`, `OpenAPISpecBuilder` |
| **Cloud DLP** | Sensitive data discovery & protection | `GoogleCloudDLPInfoType`, `GoogleCloudDLPInspectConfig`, `GoogleCloudDLPDeidentifyConfig`, `GoogleCloudDLPJobTrigger` |
| **Service Usage** | API management | `GoogleCloudService`, `GoogleCloudAPI` |
| **Cloud IAM** | Identity & access | `GoogleCloudServiceAccount`, `GoogleCloudIAMBinding` |
| **Resource Manager** | Projects & folders | `GoogleCloudProject`, `GoogleCloudFolder` |
| **Deployment Manager** | YAML/Jinja2 deployments (deprecated) | `GoogleCloudDeployment`, `GoogleCloudDeploymentType` |
| **Infrastructure Manager** | Terraform-based deployments | `InfrastructureManagerDeployment`, `TerraformBlueprint` |
| **DAIS Deployment** | Complete orchestration | `GoogleCloudDAISDeployment` |

### GoogleCloudProvider

The main configuration for your Google Cloud environment:

```swift
let provider = GoogleCloudProvider(
    projectID: "my-project",
    region: .usWest1,
    zone: "us-west1-a",  // Optional, defaults to region-a
    credentials: .applicationDefault,
    serviceAccountEmail: "dais@my-project.iam.gserviceaccount.com",
    defaultLabels: ["environment": "production"]
)
```

### GoogleCloudComputeInstance

Configure Compute Engine VMs for DAIS nodes:

```swift
let instance = GoogleCloudComputeInstance(
    name: "dais-node-1",
    machineType: .e2Medium,
    zone: "us-west1-a",
    bootDisk: .init(
        image: .ubuntuLTS,
        sizeGB: 20,
        diskType: .pdBalanced
    ),
    networkTags: ["dais-node", "allow-grpc"],
    scheduling: .spot  // Use spot pricing for cost savings
)
```

### GoogleCloudSecret

Store sensitive data in Secret Manager:

```swift
// Create a secret reference
let secret = GoogleCloudSecret(
    name: "butteryai-certificate-master-key",
    projectID: "my-project"
)

// Use predefined templates
let certKey = DAISSecretTemplate.certificateMasterKey(projectID: "my-project")
let dbURL = DAISSecretTemplate.databaseURL(projectID: "my-project")

// Get CLI commands
print(secret.createCommand)
// Output: gcloud secrets create butteryai-certificate-master-key --project=my-project --replication-policy=automatic

print(secret.accessCommand)
// Output: gcloud secrets versions access latest --secret=butteryai-certificate-master-key --project=my-project
```

### GoogleCloudStorageBucket

Configure Cloud Storage for backups:

```swift
// Use predefined templates
let backupBucket = DAISBucketTemplate.certificateBackups(
    projectID: "my-project",
    bucketSuffix: "prod-123"
)

// Custom configuration
let logBucket = GoogleCloudStorageBucket(
    name: "my-dais-logs",
    projectID: "my-project",
    location: .usWest1,
    storageClass: .nearline,
    versioning: false,
    lifecycleRules: [
        .moveToColdlineAfter90Days,
        .deleteAfter7Years
    ]
)
```

### GoogleCloudSQLInstance (Cloud SQL API)

Cloud SQL is a fully managed relational database service supporting PostgreSQL, MySQL, and SQL Server:

```swift
// Create a PostgreSQL instance
let instance = GoogleCloudSQLInstance(
    name: "my-postgres-db",
    projectID: "my-project",
    region: "us-central1",
    databaseVersion: .postgres16,
    tier: .dbCustom(cpus: 2, memoryMB: 7680),
    storageSizeGB: 50,
    storageAutoResize: true,
    availabilityType: .regional,  // High availability
    backupEnabled: true,
    pointInTimeRecoveryEnabled: true
)

print(instance.createCommand)
print(instance.connectionName)  // my-project:us-central1:my-postgres-db
```

**Creating Databases and Users:**

```swift
// Create a database
let database = GoogleCloudSQLDatabase(
    name: "myapp",
    instanceName: "my-postgres-db",
    projectID: "my-project",
    charset: "UTF8",
    collation: "en_US.UTF8"
)
print(database.createCommand)

// Create a user
let user = GoogleCloudSQLUser(
    name: "app_user",
    instanceName: "my-postgres-db",
    projectID: "my-project",
    password: "secure-password"
)
print(user.createCommand)
```

**DAIS PostgreSQL Templates:**

```swift
// Create a production-ready PostgreSQL instance for DAIS
let instance = DAISSQLTemplate.postgresInstance(
    name: "dais-db",
    projectID: "my-project",
    region: "us-central1",
    highAvailability: true
)

let database = DAISSQLTemplate.daisDatabase(instanceName: "dais-db", projectID: "my-project")
let user = DAISSQLTemplate.daisUser(instanceName: "dais-db", projectID: "my-project", password: "pass")

// Generate complete setup script
let script = DAISSQLTemplate.setupScript(instance: instance, database: database, appUser: user)
```

**Supported Database Versions:**

| Engine | Versions |
|--------|----------|
| PostgreSQL | 9.6, 11, 12, 13, 14, 15, 16, 17 |
| MySQL | 5.6, 5.7, 8.0 |
| SQL Server | 2017, 2019, 2022 (Standard, Enterprise, Express, Web) |

**Machine Tiers:**

| Tier | Use Case | Approx. Cost |
|------|----------|--------------|
| `db-f1-micro` | Development | ~$8/month |
| `db-g1-small` | Light workloads | ~$26/month |
| `dbCustom(cpus:memoryMB:)` | Production | Varies |

### GoogleCloudPubSubTopic (Cloud Pub/Sub API)

Cloud Pub/Sub provides reliable, real-time messaging for event-driven systems and streaming analytics:

```swift
// Create a topic
let topic = GoogleCloudPubSubTopic(
    name: "dais-events",
    projectID: "my-project",
    messageRetentionDuration: "604800s",  // 7 days
    labels: ["app": "dais", "environment": "production"]
)

print(topic.createCommand)
print(topic.resourceName)  // projects/my-project/topics/dais-events

// Publish a message
print(topic.publishCommand(message: "Hello, DAIS!"))
```

**Subscriptions (Pull and Push):**

```swift
// Pull subscription (default)
let pullSubscription = GoogleCloudPubSubSubscription(
    name: "dais-events-worker",
    topicName: "dais-events",
    projectID: "my-project",
    ackDeadlineSeconds: 60,
    enableExactlyOnceDelivery: true,
    enableMessageOrdering: true
)

print(pullSubscription.createCommand)
print(pullSubscription.pullCommand(maxMessages: 10))

// Push subscription
let pushSubscription = GoogleCloudPubSubSubscription(
    name: "dais-events-webhook",
    topicName: "dais-events",
    projectID: "my-project",
    type: .push(endpoint: "https://my-app.example.com/webhook"),
    ackDeadlineSeconds: 30
)
```

**Dead Letter Queues and Retry Policies:**

```swift
// Subscription with dead letter queue and retry policy
let subscription = GoogleCloudPubSubSubscription(
    name: "dais-events-reliable",
    topicName: "dais-events",
    projectID: "my-project",
    deadLetterPolicy: GoogleCloudPubSubSubscription.DeadLetterPolicy(
        deadLetterTopic: "projects/my-project/topics/dais-events-dead-letter",
        maxDeliveryAttempts: 5
    ),
    retryPolicy: GoogleCloudPubSubSubscription.RetryPolicy(
        minimumBackoff: "10s",
        maximumBackoff: "600s"
    )
)
```

**Snapshots and Seek:**

```swift
// Create a snapshot for replay
let snapshot = GoogleCloudPubSubSnapshot(
    name: "events-snapshot-20260104",
    subscriptionName: "dais-events-worker",
    projectID: "my-project"
)
print(snapshot.createCommand)

// Seek to a point in time
print(subscription.seekToTimeCommand(timestamp: "2026-01-04T00:00:00Z"))
print(subscription.seekToSnapshotCommand(snapshotName: "events-snapshot-20260104"))
```

**Schemas for Message Validation:**

```swift
// Create an Avro schema
let schema = GoogleCloudPubSubSchema(
    name: "dais-event-schema",
    projectID: "my-project",
    type: .avro,
    definition: """
    {
      "type": "record",
      "name": "DAISEvent",
      "fields": [
        {"name": "eventId", "type": "string"},
        {"name": "timestamp", "type": "long"},
        {"name": "payload", "type": "string"}
      ]
    }
    """
)
print(schema.createCommand)

// Create topic with schema
let validatedTopic = GoogleCloudPubSubTopic(
    name: "validated-events",
    projectID: "my-project",
    schemaSettings: GoogleCloudPubSubTopic.SchemaSettings(
        schemaName: "projects/my-project/schemas/dais-event-schema",
        encoding: .json
    )
)
```

**DAIS Pub/Sub Templates:**

```swift
// Create topics for DAIS inter-node communication
let eventsTopic = DAISPubSubTemplate.eventsTopic(
    projectID: "my-project",
    deploymentName: "production"
)

let commandsTopic = DAISPubSubTemplate.commandsTopic(
    projectID: "my-project",
    deploymentName: "production"
)

// Create node subscription with dead letter handling
let nodeSubscription = DAISPubSubTemplate.nodeSubscription(
    projectID: "my-project",
    deploymentName: "production",
    nodeName: "node-1"
)

// Generate complete setup script
let pubsubScript = DAISPubSubTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "production",
    nodeCount: 3
)
```

**Available Pub/Sub Roles:**

| Role | Description |
|------|-------------|
| `pubsubAdmin` | Full control of topics and subscriptions |
| `pubsubEditor` | Create, update, delete topics and subscriptions |
| `pubsubViewer` | View topics and subscriptions |
| `pubsubPublisher` | Publish messages to topics |
| `pubsubSubscriber` | Consume messages from subscriptions |

### GoogleCloudFunction (Cloud Functions API)

Cloud Functions is a serverless execution environment for building event-driven applications:

```swift
// Create a Cloud Function
let function = GoogleCloudFunction(
    name: "process-events",
    projectID: "my-project",
    region: "us-central1",
    runtime: .python312,
    entryPoint: "main",
    trigger: .http(allowUnauthenticated: false),
    memoryMB: 512,
    timeoutSeconds: 120
)

print(function.deployCommand)
print(function.resourceName)  // projects/my-project/locations/us-central1/functions/process-events
```

**Trigger Types:**

```swift
// HTTP trigger
let httpFunction = GoogleCloudFunction(
    name: "api-handler",
    projectID: "my-project",
    region: "us-central1",
    runtime: .nodejs20,
    entryPoint: "handler",
    trigger: .http(allowUnauthenticated: true)
)

// Pub/Sub trigger
let pubsubFunction = GoogleCloudFunction(
    name: "event-processor",
    projectID: "my-project",
    region: "us-central1",
    runtime: .python312,
    entryPoint: "process_event",
    trigger: .pubsub(topic: "my-events")
)

// Cloud Storage trigger
let storageFunction = GoogleCloudFunction(
    name: "file-processor",
    projectID: "my-project",
    region: "us-central1",
    runtime: .go122,
    entryPoint: "ProcessFile",
    trigger: .storage(bucket: "my-uploads", event: .finalize)
)

// Firestore trigger
let firestoreFunction = GoogleCloudFunction(
    name: "user-handler",
    projectID: "my-project",
    region: "us-central1",
    runtime: .python312,
    entryPoint: "on_user_create",
    trigger: .firestore(document: "users/{userId}", event: .create)
)
```

**Secret Environment Variables:**

```swift
let secureFunction = GoogleCloudFunction(
    name: "secure-api",
    projectID: "my-project",
    region: "us-central1",
    runtime: .python312,
    entryPoint: "main",
    secretEnvironmentVariables: [
        GoogleCloudFunction.SecretEnvVar(variableName: "API_KEY", secretName: "my-api-key"),
        GoogleCloudFunction.SecretEnvVar(variableName: "DB_PASSWORD", secretName: "db-pass", version: "2")
    ]
)
```

**VPC Connector for Private Network Access:**

```swift
let privateFunction = GoogleCloudFunction(
    name: "internal-api",
    projectID: "my-project",
    region: "us-central1",
    runtime: .python312,
    entryPoint: "main",
    vpcConnector: "projects/my-project/locations/us-central1/connectors/my-connector",
    ingressSettings: .internalOnly
)
```

**Cloud Scheduler for Scheduled Functions:**

```swift
let schedulerJob = CloudSchedulerJob(
    name: "daily-cleanup",
    projectID: "my-project",
    location: "us-central1",
    schedule: "0 2 * * *",  // Daily at 2 AM
    timezone: "America/Los_Angeles",
    targetFunction: "https://us-central1-my-project.cloudfunctions.net/cleanup",
    serviceAccountEmail: "scheduler@my-project.iam.gserviceaccount.com"
)

print(schedulerJob.createCommand)
print(schedulerJob.pauseCommand)
print(schedulerJob.runCommand)  // Run immediately
```

**DAIS Function Templates:**

```swift
// Event processor for Pub/Sub messages
let eventProcessor = DAISFunctionTemplate.eventProcessor(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod",
    eventsTopic: "prod-events"
)

// Health check endpoint
let healthCheck = DAISFunctionTemplate.healthCheck(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod"
)

// Scheduled maintenance function
let (maintenanceFunc, scheduler) = DAISFunctionTemplate.scheduledMaintenance(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod",
    schedule: "0 3 * * *",
    timezone: "UTC"
)

// Generate complete setup script
let script = DAISFunctionTemplate.setupScript(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod",
    eventsTopic: "prod-events"
)
```

**Supported Runtimes:**

| Language | Runtimes |
|----------|----------|
| Python | python39, python310, python311, python312 |
| Node.js | nodejs18, nodejs20, nodejs22 |
| Go | go119, go120, go121, go122 |
| Java | java11, java17, java21 |
| .NET | dotnet6, dotnet8 |
| Ruby | ruby30, ruby32, ruby33 |
| PHP | php81, php82, php83 |

**Function Generations:**

| Generation | Description |
|------------|-------------|
| `gen1` | Legacy Cloud Functions (max 9 min timeout) |
| `gen2` | Recommended, uses Cloud Run (max 60 min timeout) |

### GoogleCloudRunService (Cloud Run API)

Cloud Run is a fully managed platform for deploying containerized applications:

```swift
// Create a Cloud Run service
let service = GoogleCloudRunService(
    name: "my-api",
    projectID: "my-project",
    region: "us-central1",
    image: "gcr.io/my-project/my-api:latest",
    port: 8080,
    memoryMB: 1024,
    cpu: "2",
    minInstances: 1,
    maxInstances: 10,
    allowUnauthenticated: true
)

print(service.deployCommand)
print(service.resourceName)  // projects/my-project/locations/us-central1/services/my-api
```

**Services with Secrets:**

```swift
let secureService = GoogleCloudRunService(
    name: "secure-api",
    projectID: "my-project",
    region: "us-central1",
    image: "gcr.io/my-project/secure-api:latest",
    secrets: [
        .envVar(name: "API_KEY", secretName: "my-api-key"),
        .envVar(name: "DB_PASSWORD", secretName: "db-pass", version: "2"),
        .volume(path: "/secrets/config", secretName: "app-config")
    ]
)
```

**VPC and Ingress Configuration:**

```swift
let privateService = GoogleCloudRunService(
    name: "internal-api",
    projectID: "my-project",
    region: "us-central1",
    image: "gcr.io/my-project/internal-api:latest",
    vpcConnector: "projects/my-project/locations/us-central1/connectors/my-connector",
    vpcEgress: .allTraffic,
    ingress: .internal,
    allowUnauthenticated: false
)
```

**Cloud Run Jobs (Batch Processing):**

```swift
// Create a batch processing job
let job = GoogleCloudRunJob(
    name: "data-processor",
    projectID: "my-project",
    region: "us-central1",
    image: "gcr.io/my-project/processor:latest",
    taskCount: 10,
    parallelism: 5,
    taskTimeoutSeconds: 1800,
    memoryMB: 2048,
    cpu: "2"
)

print(job.createCommand)
print(job.executeCommand)
print(job.executeCommand(taskCount: 20, args: ["--verbose"]))
```

**Traffic Splitting:**

```swift
// Canary deployment
let traffic = CloudRunTrafficSplit.canary(
    stableRevision: "my-api-v1",
    canaryRevision: "my-api-v2",
    canaryPercent: 10
)

// Update traffic distribution
print(service.updateTrafficCommand(revisions: ["v1": 90, "v2": 10]))
print(service.routeToLatestCommand)
```

**Domain Mapping:**

```swift
let domainMapping = GoogleCloudRunDomainMapping(
    domain: "api.example.com",
    serviceName: "my-api",
    projectID: "my-project",
    region: "us-central1"
)
print(domainMapping.createCommand)
```

**DAIS Cloud Run Templates:**

```swift
// gRPC service with always-allocated CPU
let grpcService = DAISCloudRunTemplate.grpcService(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod",
    image: "gcr.io/my-project/dais-grpc:latest"
)

// HTTP API with scale-to-zero
let apiService = DAISCloudRunTemplate.httpAPI(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod",
    image: "gcr.io/my-project/dais-api:latest"
)

// Background worker
let worker = DAISCloudRunTemplate.worker(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "prod",
    image: "gcr.io/my-project/dais-worker:latest"
)

// Generate Dockerfile for Swift services
let dockerfile = DAISCloudRunTemplate.dockerfile(
    baseImage: "swift:5.10-jammy",
    executableName: "dais-server",
    port: 8080
)

// Generate Cloud Build config for CI/CD
let cloudbuild = DAISCloudRunTemplate.cloudbuildConfig(
    projectID: "my-project",
    region: "us-central1",
    serviceName: "my-service",
    imageName: "my-image"
)
```

**Container Registries:**

```swift
// Google Container Registry
let gcr = ContainerRegistry.gcr(
    projectID: "my-project",
    imageName: "my-app",
    tag: "v1.0.0"
)
print(gcr.imageURL)  // gcr.io/my-project/my-app:v1.0.0

// Artifact Registry
let ar = ContainerRegistry.artifactRegistry(
    projectID: "my-project",
    location: "us-central1",
    repository: "my-repo",
    imageName: "my-app",
    tag: "latest"
)
print(ar.imageURL)  // us-central1-docker.pkg.dev/my-project/my-repo/my-app:latest
```

**Cloud Run Configuration Options:**

| Option | Description |
|--------|-------------|
| `minInstances` | Minimum instances (0 = scale to zero) |
| `maxInstances` | Maximum instances |
| `concurrency` | Max concurrent requests per instance |
| `cpuAllocationType` | `requestBased` or `alwaysAllocated` |
| `executionEnvironment` | `gen1` or `gen2` |

### GoogleCloudGKECluster (Google Kubernetes Engine)

Google Kubernetes Engine (GKE) is a managed Kubernetes service for deploying containerized applications:

```swift
// Create a standard GKE cluster
let cluster = GoogleCloudGKECluster(
    name: "my-cluster",
    projectID: "my-project",
    location: "us-central1",
    initialNodeCount: 3,
    nodeConfig: GoogleCloudGKECluster.NodeConfig(
        machineType: "e2-standard-4",
        diskSizeGb: 100,
        diskType: .pdSsd
    ),
    releaseChannel: GoogleCloudGKECluster.ReleaseChannel(channel: .regular),
    workloadIdentityConfig: GoogleCloudGKECluster.WorkloadIdentityConfig(
        workloadPool: "my-project.svc.id.goog"
    )
)

print(cluster.createCommand)
print(cluster.resourceName)  // projects/my-project/locations/us-central1/clusters/my-cluster
print(cluster.getCredentialsCommand)  // Get kubectl credentials
```

**Autopilot Clusters:**

```swift
// Create an Autopilot cluster (fully managed)
let autopilotCluster = GoogleCloudGKECluster(
    name: "autopilot-cluster",
    projectID: "my-project",
    location: "us-central1",
    autopilot: GoogleCloudGKECluster.Autopilot(enabled: true),
    releaseChannel: GoogleCloudGKECluster.ReleaseChannel(channel: .regular)
)

print(autopilotCluster.createCommand)  // Includes --enable-autopilot
```

**Private Clusters:**

```swift
// Create a private cluster with no public endpoint
let privateCluster = GoogleCloudGKECluster(
    name: "private-cluster",
    projectID: "my-project",
    location: "us-central1",
    initialNodeCount: 3,
    privateClusterConfig: GoogleCloudGKECluster.PrivateClusterConfig(
        enablePrivateNodes: true,
        enablePrivateEndpoint: false,
        masterIpv4CidrBlock: "172.16.0.0/28",
        masterGlobalAccessConfig: GoogleCloudGKECluster.PrivateClusterConfig.MasterGlobalAccessConfig(enabled: true)
    ),
    networkConfig: GoogleCloudGKECluster.NetworkConfig(
        network: "my-vpc",
        subnetwork: "my-subnet",
        datapathProvider: .advancedDatapath
    )
)
```

**Node Pools:**

```swift
// Create a node pool with autoscaling
let nodePool = GoogleCloudGKENodePool(
    name: "high-memory-pool",
    clusterName: "my-cluster",
    projectID: "my-project",
    location: "us-central1",
    initialNodeCount: 1,
    config: GoogleCloudGKECluster.NodeConfig(
        machineType: "n2-highmem-8",
        diskSizeGb: 200,
        diskType: .pdSsd
    ),
    autoscaling: GoogleCloudGKENodePool.Autoscaling(
        enabled: true,
        minNodeCount: 0,
        maxNodeCount: 10
    ),
    management: GoogleCloudGKENodePool.NodeManagement(
        autoUpgrade: true,
        autoRepair: true
    )
)

print(nodePool.createCommand)
print(nodePool.resourceName)
```

**GPU Node Pool:**

```swift
// Create a GPU node pool for ML workloads
let gpuPool = GoogleCloudGKENodePool(
    name: "gpu-pool",
    clusterName: "my-cluster",
    projectID: "my-project",
    location: "us-central1",
    config: GoogleCloudGKECluster.NodeConfig(
        machineType: "n1-standard-4",
        accelerators: [
            GoogleCloudGKECluster.NodeConfig.Accelerator(
                acceleratorCount: 1,
                acceleratorType: "nvidia-tesla-t4"
            )
        ],
        taints: [
            GoogleCloudGKECluster.NodeConfig.Taint(
                key: "nvidia.com/gpu",
                value: "present",
                effect: .noSchedule
            )
        ]
    ),
    autoscaling: GoogleCloudGKENodePool.Autoscaling(
        enabled: true,
        minNodeCount: 0,
        maxNodeCount: 5
    )
)
```

**Spot/Preemptible Nodes:**

```swift
// Create a spot node pool for cost savings
let spotPool = GoogleCloudGKENodePool(
    name: "spot-pool",
    clusterName: "my-cluster",
    projectID: "my-project",
    location: "us-central1",
    config: GoogleCloudGKECluster.NodeConfig(
        machineType: "e2-standard-4",
        spot: true,
        labels: ["workload-type": "batch"]
    ),
    autoscaling: GoogleCloudGKENodePool.Autoscaling(
        enabled: true,
        minNodeCount: 0,
        maxNodeCount: 20
    )
)
```

**Cluster Operations:**

```swift
// Resize a cluster
print(cluster.resizeCommand(nodeCount: 5, nodePool: "default-pool"))

// Upgrade cluster master
print(cluster.upgradeCommand(version: "1.28.3-gke.1200"))

// Upgrade a node pool
print(cluster.upgradeCommand(version: "1.28.3-gke.1200", nodePool: "default-pool"))

// List clusters
print(GKEOperations.listClustersCommand(projectID: "my-project"))

// List node pools
print(GKEOperations.listNodePoolsCommand(
    cluster: "my-cluster",
    projectID: "my-project",
    location: "us-central1"
))

// Get available versions
print(GKEOperations.getServerConfigCommand(projectID: "my-project", location: "us-central1"))

// Enable GKE API
print(GKEOperations.enableAPICommand)
```

**DAIS GKE Templates:**

```swift
// Production-ready templates for DAIS deployments
let template = DAISGKETemplate(
    projectID: "my-project",
    location: "us-central1",
    clusterName: "dais-cluster",
    network: "dais-vpc",
    subnetwork: "dais-subnet"
)

// Standard cluster with Workload Identity
let standardCluster = template.standardCluster

// Autopilot cluster for hands-off management
let autopilot = template.autopilotCluster

// Private cluster for enhanced security
let privateCluster = template.privateCluster

// GPU node pool for ML workloads
let gpuNodePool = template.gpuNodePool

// Spot node pool for batch workloads
let spotNodePool = template.spotNodePool

// Generate setup script
print(template.setupScript)

// Generate teardown script
print(template.teardownScript)
```

**GKE Configuration Options:**

| Option | Description |
|--------|-------------|
| `autopilot` | Enable Autopilot mode (fully managed) |
| `releaseChannel` | `rapid`, `regular`, or `stable` |
| `privateClusterConfig` | Enable private nodes and endpoint |
| `workloadIdentityConfig` | Enable Workload Identity |
| `networkConfig` | VPC and subnet configuration |
| `addonsConfig` | Enable/disable cluster add-ons |

### GoogleCloudLogEntry (Cloud Logging API)

Cloud Logging is a fully managed service for storing, searching, analyzing, and alerting on log data:

```swift
// Create a log entry
let entry = GoogleCloudLogEntry(
    logName: "my-app",
    projectID: "my-project",
    severity: .error,
    textPayload: "Database connection failed",
    labels: ["component": "db", "environment": "production"]
)

print(entry.writeCommand)
print(entry.resourceName)  // projects/my-project/logs/my-app

// Read logs
print(GoogleCloudLogEntry.readCommand(
    projectID: "my-project",
    logName: "my-app",
    filter: "severity >= ERROR",
    limit: 100
))
```

**Log Sinks (Export Logs):**

```swift
// Export error logs to BigQuery
let bigQuerySink = GoogleCloudLogSink(
    name: "errors-to-bigquery",
    projectID: "my-project",
    destination: .bigQuery(datasetID: "logs_dataset"),
    filter: "severity >= ERROR",
    description: "Export error logs for analysis"
)
print(bigQuerySink.createCommand)

// Export to Cloud Storage for archival
let storageSink = GoogleCloudLogSink(
    name: "audit-logs-archive",
    projectID: "my-project",
    destination: .storage(bucketName: "my-audit-logs"),
    filter: "logName =~ \"audit\""
)

// Export to Pub/Sub for real-time processing
let pubsubSink = GoogleCloudLogSink(
    name: "logs-to-pubsub",
    projectID: "my-project",
    destination: .pubSub(topicName: "log-events")
)
```

**Log Buckets and Views:**

```swift
// Create a log bucket with extended retention
let bucket = GoogleCloudLogBucket(
    name: "long-term-logs",
    projectID: "my-project",
    location: "us-central1",
    retentionDays: 365,
    analyticsEnabled: true
)
print(bucket.createCommand)

// Create a filtered view for errors only
let view = GoogleCloudLogView(
    name: "errors-only",
    bucketName: "_Default",
    projectID: "my-project",
    location: "global",
    filter: "severity >= ERROR",
    description: "View for error logs only"
)
print(view.createCommand)
```

**Log Exclusions (Cost Reduction):**

```swift
// Exclude debug logs to reduce costs
let exclusion = GoogleCloudLogExclusion(
    name: "exclude-debug",
    projectID: "my-project",
    filter: "severity = DEBUG",
    description: "Skip debug logs in production"
)
print(exclusion.createCommand)
```

**Log-Based Metrics:**

```swift
// Create a counter metric for errors
let errorMetric = GoogleCloudLogMetric(
    name: "error-count",
    projectID: "my-project",
    filter: "severity >= ERROR",
    description: "Count of error log entries",
    metricType: .counter,
    labelExtractors: [
        "service": "EXTRACT(labels.service)",
        "method": "EXTRACT(labels.method)"
    ]
)
print(errorMetric.createCommand)
print(errorMetric.monitoringMetricName)  // logging.googleapis.com/user/error-count

// Create a distribution metric for latency
let latencyMetric = GoogleCloudLogMetric(
    name: "request-latency",
    projectID: "my-project",
    filter: "httpRequest.latency > 0",
    metricType: .distribution,
    valueExtractor: "EXTRACT(httpRequest.latency)",
    bucketOptions: GoogleCloudLogMetric.BucketOptions(
        type: .exponential(numBuckets: 20, growthFactor: 2, scale: 1)
    )
)
```

**Log Router Helpers:**

```swift
// Build filters programmatically
let resourceFilter = LogRouter.resourceFilter(
    type: "cloud_run_revision",
    labels: ["service_name": "my-api"]
)

let severityFilter = LogRouter.severityFilter(minSeverity: .warning)

let logNameFilter = LogRouter.logNameFilter(
    projectID: "my-project",
    logNames: ["app", "requests", "errors"]
)
```

**Predefined Log Filters:**

```swift
// Use common filters
let errorsOnly = PredefinedLogFilter.errorsOnly        // "severity >= ERROR"
let http5xx = PredefinedLogFilter.http5xxErrors        // "httpRequest.status >= 500"
let slowRequests = PredefinedLogFilter.slowRequests    // "httpRequest.latency > \"1s\""
let cloudRun = PredefinedLogFilter.cloudRunRequests    // "resource.type = \"cloud_run_revision\""
```

**DAIS Logging Templates:**

```swift
// Create error logs sink for DAIS deployment
let errorSink = DAISLoggingTemplate.errorLogsSink(
    projectID: "my-project",
    deploymentName: "prod",
    datasetID: "dais_errors"
)

// Create log bucket with extended retention
let logBucket = DAISLoggingTemplate.logBucket(
    projectID: "my-project",
    deploymentName: "prod",
    location: "us-central1",
    retentionDays: 90
)

// Create error count metric
let errorMetric = DAISLoggingTemplate.errorCountMetric(
    projectID: "my-project",
    deploymentName: "prod"
)

// Create gRPC latency metric
let latencyMetric = DAISLoggingTemplate.grpcLatencyMetric(
    projectID: "my-project",
    deploymentName: "prod"
)

// Generate complete setup script
let script = DAISLoggingTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "prod",
    location: "us-central1",
    bigQueryDataset: "logs",
    storageBucket: "audit-logs"
)
```

**Log Severity Levels:**

| Severity | Value | Description |
|----------|-------|-------------|
| `default` | 0 | Default level |
| `debug` | 100 | Debug information |
| `info` | 200 | Routine information |
| `notice` | 300 | Normal but significant |
| `warning` | 400 | Warning events |
| `error` | 500 | Error events |
| `critical` | 600 | Critical events |
| `alert` | 700 | Action required |
| `emergency` | 800 | System unusable |

### GoogleCloudAlertPolicy (Cloud Monitoring API)

Cloud Monitoring provides visibility into the performance, availability, and health of your applications:

```swift
// Create an alert policy for high CPU
let policy = GoogleCloudAlertPolicy(
    displayName: "High CPU Usage",
    projectID: "my-project",
    conditions: [
        .threshold(
            displayName: "CPU > 80%",
            filter: "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
            comparison: .greaterThan,
            threshold: 0.8,
            duration: "300s"
        )
    ],
    notificationChannels: ["projects/my-project/notificationChannels/123"],
    documentation: AlertDocumentation(
        content: "CPU usage exceeded 80%. Consider scaling.",
        subject: "High CPU Alert"
    ),
    severity: .warning
)

print(policy.createCommand)
print(GoogleCloudAlertPolicy.listCommand(projectID: "my-project"))
```

**Alert Conditions:**

```swift
// Threshold condition
let thresholdCondition = AlertCondition.threshold(
    displayName: "Error Rate > 1%",
    filter: "metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class!=\"2xx\"",
    comparison: .greaterThan,
    threshold: 0.01,
    duration: "60s",
    aggregation: AlertCondition.Aggregation(
        alignmentPeriod: "60s",
        perSeriesAligner: .alignRate,
        crossSeriesReducer: .reduceSum
    )
)

// Absence condition (no data)
let absenceCondition = AlertCondition.absence(
    displayName: "No Data",
    filter: "metric.type=\"custom.googleapis.com/my_metric\"",
    duration: "600s"
)

// MQL condition
let mqlCondition = AlertCondition.mql(
    displayName: "Custom Query",
    query: "fetch gce_instance | metric cpu/utilization | filter val() > 0.8",
    duration: "300s"
)
```

**Notification Channels:**

```swift
// Email notification
let emailChannel = GoogleCloudNotificationChannel.email(
    displayName: "On-Call Team",
    projectID: "my-project",
    emailAddress: "oncall@example.com"
)
print(emailChannel.createCommand)

// Slack notification
let slackChannel = GoogleCloudNotificationChannel.slack(
    displayName: "Alerts Channel",
    projectID: "my-project",
    channelName: "#alerts",
    authToken: "xoxb-slack-token"
)

// PagerDuty notification
let pagerDutyChannel = GoogleCloudNotificationChannel.pagerDuty(
    displayName: "PagerDuty",
    projectID: "my-project",
    serviceKey: "service-key"
)

// Webhook notification
let webhookChannel = GoogleCloudNotificationChannel.webhook(
    displayName: "Custom Webhook",
    projectID: "my-project",
    url: "https://example.com/webhook"
)

// Pub/Sub notification
let pubsubChannel = GoogleCloudNotificationChannel.pubsub(
    displayName: "Pub/Sub Alerts",
    projectID: "my-project",
    topic: "projects/my-project/topics/alerts"
)
```

**Uptime Checks:**

```swift
// HTTP uptime check
let httpCheck = GoogleCloudUptimeCheck(
    displayName: "API Health Check",
    projectID: "my-project",
    monitoredResource: .uptime(host: "api.example.com"),
    httpCheck: GoogleCloudUptimeCheck.HTTPCheckConfig(
        path: "/health",
        port: 443,
        useSsl: true,
        validateSsl: true,
        requestMethod: .get
    ),
    period: .oneMinute,
    contentMatchers: [
        GoogleCloudUptimeCheck.ContentMatcher(content: "ok", matcher: .contains)
    ]
)
print(httpCheck.createCommand)

// TCP uptime check (for gRPC)
let tcpCheck = GoogleCloudUptimeCheck(
    displayName: "gRPC Health",
    projectID: "my-project",
    monitoredResource: .uptime(host: "grpc.example.com"),
    tcpCheck: GoogleCloudUptimeCheck.TCPCheckConfig(port: 9090),
    period: .oneMinute
)

// Cloud Run uptime check
let cloudRunCheck = GoogleCloudUptimeCheck(
    displayName: "Cloud Run Service",
    projectID: "my-project",
    monitoredResource: .cloudRun(
        projectID: "my-project",
        serviceName: "my-api",
        location: "us-central1"
    ),
    httpCheck: GoogleCloudUptimeCheck.HTTPCheckConfig(path: "/health")
)
```

**Custom Metrics:**

```swift
// Create a custom metric descriptor
let metric = GoogleCloudMetricDescriptor(
    type: "custom.googleapis.com/my_app/request_latency",
    projectID: "my-project",
    metricKind: .gauge,
    valueType: .distribution,
    unit: "ms",
    description: "Request latency in milliseconds",
    displayName: "Request Latency",
    labels: [
        GoogleCloudMetricDescriptor.LabelDescriptor(key: "method", description: "HTTP method"),
        GoogleCloudMetricDescriptor.LabelDescriptor(key: "status", description: "Response status")
    ]
)
print(metric.createCommand)
print(metric.resourceName)
```

**Monitoring Groups:**

```swift
// Create a group for related resources
let group = GoogleCloudMonitoringGroup(
    displayName: "Production Servers",
    projectID: "my-project",
    filter: "resource.metadata.name=starts_with(\"prod\") AND resource.type=\"gce_instance\"",
    isCluster: true
)
print(group.createCommand)
```

**Dashboards:**

```swift
// Create a dashboard
let dashboard = GoogleCloudDashboard(
    displayName: "DAIS Overview",
    projectID: "my-project",
    layout: .grid(columns: 3)
)
print(dashboard.createCommand)
print(GoogleCloudDashboard.listCommand(projectID: "my-project"))
```

**Service Level Objectives (SLOs):**

```swift
// Create an SLO for 99.9% availability
let slo = GoogleCloudSLO(
    displayName: "API Availability",
    serviceName: "my-api",
    projectID: "my-project",
    goal: 0.999,
    rollingPeriod: "30d",
    sli: .requestBased(
        goodTotalRatio: GoogleCloudSLO.ServiceLevelIndicator.GoodTotalRatio(
            goodServiceFilter: "metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"2xx\"",
            totalServiceFilter: "metric.type=\"run.googleapis.com/request_count\""
        ),
        distributionCut: nil
    )
)
```

**MQL Query Builder:**

```swift
// Build Monitoring Query Language queries
let query = MQLQueryBuilder.fetch(
    metricType: "compute.googleapis.com/instance/cpu/utilization",
    resourceType: "gce_instance"
)
let filtered = MQLQueryBuilder.filter(query, condition: "resource.zone = 'us-central1-a'")
let grouped = MQLQueryBuilder.groupBy(filtered, fields: ["resource.zone"], reducer: "mean")
let aligned = MQLQueryBuilder.align(grouped, aligner: "mean", period: "5m")
```

**Predefined Metric Filters:**

```swift
// Common GCP metrics
let cpuFilter = PredefinedMetricFilter.cpuUtilization
let cloudRunRequests = PredefinedMetricFilter.cloudRunRequestCount
let functionExecutions = PredefinedMetricFilter.functionExecutionCount
let sqlConnections = PredefinedMetricFilter.sqlConnections
let pubsubBacklog = PredefinedMetricFilter.pubsubSubscriptionBacklog
```

**DAIS Monitoring Templates:**

```swift
// Create notification channels
let emailChannel = DAISMonitoringTemplate.emailChannel(
    projectID: "my-project",
    deploymentName: "prod",
    email: "alerts@example.com"
)

// Create alert policies
let cpuAlert = DAISMonitoringTemplate.cpuAlertPolicy(
    projectID: "my-project",
    deploymentName: "prod",
    threshold: 0.8
)

let memoryAlert = DAISMonitoringTemplate.memoryAlertPolicy(
    projectID: "my-project",
    deploymentName: "prod",
    threshold: 0.85
)

let errorAlert = DAISMonitoringTemplate.errorRateAlertPolicy(
    projectID: "my-project",
    deploymentName: "prod",
    threshold: 0.01
)

// Create uptime checks
let httpCheck = DAISMonitoringTemplate.httpUptimeCheck(
    projectID: "my-project",
    deploymentName: "prod",
    host: "api.example.com"
)

let grpcCheck = DAISMonitoringTemplate.grpcUptimeCheck(
    projectID: "my-project",
    deploymentName: "prod",
    host: "grpc.example.com"
)

// Create custom metrics
let latencyMetric = DAISMonitoringTemplate.requestLatencyMetric(
    projectID: "my-project",
    deploymentName: "prod"
)

// Generate complete setup script
let script = DAISMonitoringTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "prod",
    alertEmail: "alerts@example.com",
    httpHost: "api.example.com",
    grpcHost: "grpc.example.com"
)
```

**Notification Channel Types:**

| Type | Description |
|------|-------------|
| `email` | Email notifications |
| `sms` | SMS text messages |
| `slack` | Slack channel messages |
| `pagerDuty` | PagerDuty incidents |
| `webhook` | Custom webhook endpoints |
| `pubsub` | Pub/Sub topic messages |

**Uptime Check Periods:**

| Period | Value |
|--------|-------|
| `oneMinute` | 60s |
| `fiveMinutes` | 300s |
| `tenMinutes` | 600s |
| `fifteenMinutes` | 900s |

### GoogleCloudVPCNetwork (VPC Networks API)

VPC Networks provide the foundation for networking in Google Cloud, enabling secure, isolated networks for your resources:

```swift
// Create a custom-mode VPC network
let network = GoogleCloudVPCNetwork(
    name: "my-vpc",
    projectID: "my-project",
    autoCreateSubnetworks: false,
    routingMode: .global,
    description: "Production VPC network",
    mtu: 1460
)
print(network.createCommand)
print(network.resourceName)
print(network.selfLink)
```

**Subnets:**

```swift
// Create a subnet with secondary ranges for GKE
let subnet = GoogleCloudSubnet(
    name: "us-central1-subnet",
    networkName: "my-vpc",
    projectID: "my-project",
    region: "us-central1",
    ipCidrRange: "10.0.0.0/24",
    privateIpGoogleAccess: true,
    enableFlowLogs: true,
    flowLogAggregationInterval: .interval5Min,
    secondaryIpRanges: [
        .init(rangeName: "pods", ipCidrRange: "10.4.0.0/14"),
        .init(rangeName: "services", ipCidrRange: "10.0.32.0/20")
    ]
)
print(subnet.createCommand)
print(subnet.expandIpRangeCommand(newRange: "20"))
```

**Firewall Rules:**

```swift
// Allow HTTP/HTTPS ingress
let httpRule = GoogleCloudFirewallRule(
    name: "allow-http",
    networkName: "my-vpc",
    projectID: "my-project",
    direction: .ingress,
    allowed: [
        .init(protocol: .tcp, ports: ["80", "443"])
    ],
    priority: 1000,
    sourceRanges: ["0.0.0.0/0"],
    targetTags: ["web-server"],
    enableLogging: true
)
print(httpRule.createCommand)

// Allow internal traffic
let internalRule = GoogleCloudFirewallRule(
    name: "allow-internal",
    networkName: "my-vpc",
    projectID: "my-project",
    direction: .ingress,
    allowed: [
        .init(protocol: .tcp),
        .init(protocol: .udp),
        .init(protocol: .icmp)
    ],
    sourceTags: ["internal"],
    targetTags: ["internal"]
)
```

**Routes:**

```swift
// Custom route to internal load balancer
let route = GoogleCloudRoute(
    name: "to-ilb",
    networkName: "my-vpc",
    projectID: "my-project",
    destRange: "10.100.0.0/16",
    nextHop: .ilb(forwardingRule: "my-ilb", region: "us-central1"),
    priority: 900,
    tags: ["needs-ilb"]
)
print(route.createCommand)

// Route through VPN tunnel
let vpnRoute = GoogleCloudRoute(
    name: "to-on-prem",
    networkName: "my-vpc",
    projectID: "my-project",
    destRange: "192.168.0.0/16",
    nextHop: .vpnTunnel(name: "my-vpn", region: "us-central1")
)
```

**VPC Peering:**

```swift
// Peer with another VPC
let peering = GoogleCloudVPCPeering(
    name: "peer-to-shared",
    networkName: "my-vpc",
    projectID: "my-project",
    peerNetwork: "projects/shared-project/global/networks/shared-vpc",
    exportCustomRoutes: true,
    importCustomRoutes: true
)
print(peering.createCommand)
print(peering.updateCommand)
```

**Cloud Router (for BGP):**

```swift
// Create a Cloud Router
let router = GoogleCloudRouter(
    name: "my-router",
    networkName: "my-vpc",
    projectID: "my-project",
    region: "us-central1",
    bgpAsn: 64512,
    advertisedIpRanges: ["10.0.0.0/8"],
    advertiseMode: .custom
)
print(router.createCommand)
print(router.resourceName)
```

**Cloud NAT:**

```swift
// Create Cloud NAT for outbound internet access
let nat = GoogleCloudNATGateway(
    name: "my-nat",
    routerName: "my-router",
    projectID: "my-project",
    region: "us-central1",
    enableDynamicPortAllocation: true,
    minPortsPerVm: 64,
    logFilter: .errorsOnly
)
print(nat.createCommand)
print(nat.describeCommand)
```

**Reserved IP Addresses:**

```swift
// Reserve a regional external IP
let externalIP = GoogleCloudReservedAddress(
    name: "my-external-ip",
    projectID: "my-project",
    region: "us-central1",
    addressType: .external,
    networkTier: .premium
)
print(externalIP.createCommand)

// Reserve a global IP for load balancer
let globalIP = GoogleCloudReservedAddress(
    name: "lb-ip",
    projectID: "my-project",
    region: nil  // Global
)
print(globalIP.createCommand)
```

**Predefined CIDR Ranges:**

```swift
// RFC 1918 private ranges
let range10 = PredefinedCIDRRange.private10    // "10.0.0.0/8"
let range172 = PredefinedCIDRRange.private172  // "172.16.0.0/12"
let range192 = PredefinedCIDRRange.private192  // "192.168.0.0/16"

// GKE recommended ranges
let gkePods = PredefinedCIDRRange.gkePods          // "10.4.0.0/14"
let gkeServices = PredefinedCIDRRange.gkeServices  // "10.0.32.0/20"
let gkeMaster = PredefinedCIDRRange.gkeMaster      // "172.16.0.0/28"

// Private Google Access
let privateAccess = PredefinedCIDRRange.privateGoogleAccess  // "199.36.153.8/30"
```

**DAIS VPC Templates:**

```swift
// Create VPC network
let network = DAISVPCTemplate.network(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

// Create node subnet with flow logs
let subnet = DAISVPCTemplate.nodeSubnet(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1",
    cidrRange: "10.0.0.0/24"
)

// Firewall rules
let grpcRule = DAISVPCTemplate.grpcFirewallRule(
    projectID: "my-project",
    deploymentName: "dais-prod",
    port: 9090
)

let healthCheckRule = DAISVPCTemplate.healthCheckFirewallRule(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

let sshRule = DAISVPCTemplate.sshFirewallRule(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

let internalRule = DAISVPCTemplate.internalFirewallRule(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

// Cloud Router and NAT
let router = DAISVPCTemplate.router(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1"
)

let nat = DAISVPCTemplate.natGateway(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1"
)

// Complete setup and teardown scripts
let setupScript = DAISVPCTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1",
    nodeSubnetCidr: "10.0.0.0/24"
)

let teardownScript = DAISVPCTemplate.teardownScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1"
)
```

**Routing Modes:**

| Mode | Description |
|------|-------------|
| `regional` | Routes are propagated only to subnets in the same region |
| `global` | Routes are propagated to all subnets in the network |

**Firewall Direction:**

| Direction | Description |
|-----------|-------------|
| `ingress` | Incoming traffic to VM instances |
| `egress` | Outgoing traffic from VM instances |

**Subnet Purposes:**

| Purpose | Description |
|---------|-------------|
| `privateDefault` | Standard subnet for VM instances |
| `regionalManagedProxy` | Proxy-only subnet for regional HTTP(S) LB |
| `globalManagedProxy` | Proxy-only subnet for global HTTP(S) LB |
| `privateServiceConnect` | Subnet for Private Service Connect |

### GoogleCloudManagedZone (Cloud DNS API)

Cloud DNS is a scalable, reliable, and managed authoritative Domain Name System (DNS) service:

```swift
// Create a public managed zone with DNSSEC
let zone = GoogleCloudManagedZone(
    name: "example-zone",
    dnsName: "example.com",
    projectID: "my-project",
    description: "Production DNS zone",
    visibility: .public,
    dnssecConfig: .init(state: .on)
)
print(zone.createCommand)
print(zone.resourceName)

// Create a private zone for internal services
let privateZone = GoogleCloudManagedZone(
    name: "internal-zone",
    dnsName: "internal.example.com",
    projectID: "my-project",
    visibility: .private,
    networks: ["my-vpc"]
)
```

**DNS Records:**

```swift
// Create various record types
let aRecord = GoogleCloudDNSRecord(
    name: "www.example.com",
    type: .a,
    ttl: 300,
    rrdatas: ["192.0.2.1", "192.0.2.2"]
)

let cnameRecord = GoogleCloudDNSRecord(
    name: "app.example.com",
    type: .cname,
    ttl: 300,
    rrdatas: ["lb.example.com."]
)

let mxRecord = GoogleCloudDNSRecord(
    name: "example.com",
    type: .mx,
    ttl: 3600,
    rrdatas: ["10 mail.example.com."]
)

// Manage records with commands
print(GoogleCloudDNSRecordCommands.createCommand(
    zoneName: "example-zone",
    projectID: "my-project",
    record: aRecord
))

print(GoogleCloudDNSRecordCommands.listCommand(
    zoneName: "example-zone",
    projectID: "my-project"
))
```

**Common DNS Records Factory:**

```swift
// A record
let webServer = CommonDNSRecords.aRecord(
    name: "www.example.com",
    ipAddresses: ["192.0.2.1"]
)

// MX records for email
let mxRecords = CommonDNSRecords.mxRecord(
    name: "example.com",
    mailServers: [
        (10, "mail1.example.com"),
        (20, "mail2.example.com")
    ]
)

// Google Workspace MX records
let googleMX = CommonDNSRecords.googleWorkspaceMX(domain: "example.com")

// TXT record for SPF
let spf = CommonDNSRecords.spfRecord(
    name: "example.com",
    spfValue: "v=spf1 include:_spf.google.com ~all"
)

// DMARC record
let dmarc = CommonDNSRecords.dmarcRecord(
    domain: "example.com",
    policy: "reject",
    rua: "dmarc@example.com"
)

// CAA record for certificate authority
let caa = CommonDNSRecords.caaRecord(
    name: "example.com",
    entries: [(0, "issue", "letsencrypt.org")]
)

// SRV record for gRPC
let grpcSrv = CommonDNSRecords.srvRecord(
    name: "_grpc._tcp.api.example.com",
    services: [(10, 5, 9090, "grpc.example.com")]
)
```

**DNS Transactions:**

```swift
// Atomic updates using transactions
var transaction = GoogleCloudDNSTransaction(
    zoneName: "example-zone",
    projectID: "my-project"
)

// Add records
transaction.additions = [
    GoogleCloudDNSRecord(name: "new.example.com", type: .a, ttl: 300, rrdatas: ["192.0.2.3"])
]

// Remove records
transaction.deletions = [
    GoogleCloudDNSRecord(name: "old.example.com", type: .a, ttl: 300, rrdatas: ["192.0.2.100"])
]

// Generate transaction script
print(transaction.transactionScript)
```

**DNS Policies:**

```swift
// Create a DNS policy for private resolution
let policy = GoogleCloudDNSPolicy(
    name: "internal-policy",
    projectID: "my-project",
    enableInboundForwarding: true,
    enableLogging: true,
    networks: ["my-vpc"],
    alternativeNameServerConfig: .init(targetNameServers: ["10.0.0.53"])
)
print(policy.createCommand)

// Response policies for DNS firewall
let responsePolicy = GoogleCloudDNSResponsePolicy(
    name: "block-malware",
    projectID: "my-project",
    networks: ["my-vpc"]
)

let rule = GoogleCloudDNSResponsePolicyRule(
    name: "block-badsite",
    responsePolicyName: "block-malware",
    projectID: "my-project",
    dnsName: "malware.com",
    behavior: .localData,
    localData: .init(localDatas: [
        .init(name: "malware.com.", type: .a, ttl: 300, rrdatas: ["0.0.0.0"])
    ])
)
```

**DNSSEC Operations:**

```swift
// Enable DNSSEC
print(DNSSECOperations.enableCommand(zoneName: "example-zone", projectID: "my-project"))

// Get DS records for domain registrar
print(DNSSECOperations.getDSRecordsCommand(zoneName: "example-zone", projectID: "my-project"))

// List DNSKEY records
print(DNSSECOperations.listKeysCommand(zoneName: "example-zone", projectID: "my-project"))
```

**Zone Import/Export:**

```swift
// Export zone to BIND format
print(DNSOperations.exportCommand(
    zoneName: "example-zone",
    projectID: "my-project",
    outputFile: "zone.txt"
))

// Import zone from BIND format
print(DNSOperations.importCommand(
    zoneName: "example-zone",
    projectID: "my-project",
    inputFile: "zone.txt"
))

// Check DNS propagation
print(DNSOperations.checkPropagationCommand(domain: "www.example.com", recordType: "A"))
```

**DAIS DNS Templates:**

```swift
// Create managed zone for DAIS
let zone = DAISDNSTemplate.managedZone(
    projectID: "my-project",
    deploymentName: "dais-prod",
    domain: "example.com"
)

// Private zone for internal services
let privateZone = DAISDNSTemplate.privateZone(
    projectID: "my-project",
    deploymentName: "dais-prod",
    domain: "internal.example.com",
    networks: ["dais-prod-vpc"]
)

// API and gRPC endpoint records
let apiRecord = DAISDNSTemplate.apiRecord(domain: "example.com", ipAddress: "192.0.2.1")
let grpcRecord = DAISDNSTemplate.grpcRecord(domain: "example.com", ipAddress: "192.0.2.2")

// Complete setup script
let setupScript = DAISDNSTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    domain: "example.com",
    apiIP: "192.0.2.1",
    grpcIP: "192.0.2.2"
)

// Teardown script
let teardownScript = DAISDNSTemplate.teardownScript(
    projectID: "my-project",
    deploymentName: "dais-prod"
)
```

**Record Types:**

| Type | Description |
|------|-------------|
| `A` | IPv4 address record |
| `AAAA` | IPv6 address record |
| `CNAME` | Canonical name (alias) |
| `MX` | Mail exchange record |
| `TXT` | Text record (SPF, DKIM, etc.) |
| `NS` | Name server record |
| `SOA` | Start of authority |
| `SRV` | Service location record |
| `CAA` | Certificate authority authorization |
| `PTR` | Pointer record (reverse DNS) |

**Zone Visibility:**

| Visibility | Description |
|------------|-------------|
| `public` | Publicly resolvable zone |
| `private` | Only accessible within VPC networks |

### GoogleCloudHealthCheck (Cloud Load Balancing API)

Cloud Load Balancing provides global and regional load balancing for HTTP(S), TCP, SSL, and gRPC traffic:

```swift
// Create an HTTP health check
let healthCheck = GoogleCloudHealthCheck(
    name: "api-health-check",
    projectID: "my-project",
    type: .http,
    checkIntervalSec: 5,
    timeoutSec: 5,
    healthyThreshold: 2,
    unhealthyThreshold: 3,
    httpHealthCheck: .init(port: 8080, requestPath: "/health")
)
print(healthCheck.createCommand)
print(healthCheck.resourceName)

// gRPC health check
let grpcHealthCheck = GoogleCloudHealthCheck(
    name: "grpc-health-check",
    projectID: "my-project",
    type: .grpc,
    grpcHealthCheck: .init(port: 9090, grpcServiceName: "grpc.health.v1.Health")
)
```

**Backend Services:**

```swift
// Create a backend service with CDN and logging
let backendService = GoogleCloudBackendService(
    name: "api-backend",
    projectID: "my-project",
    protocol: .http,
    portName: "http",
    timeoutSec: 30,
    healthChecks: ["api-health-check"],
    loadBalancingScheme: .externalManaged,
    sessionAffinity: .clientIp,
    enableCDN: true,
    cdnPolicy: .init(cacheMode: .cacheAllStatic, defaultTtl: 3600),
    logConfig: .init(enable: true, sampleRate: 1.0)
)
print(backendService.createCommand)

// Add a backend (instance group or NEG)
let backend = GoogleCloudBackendService.Backend(
    group: .instanceGroup(name: "my-ig", zone: "us-central1-a"),
    balancingMode: .rate,
    maxRatePerInstance: 100.0
)
print(backendService.addBackendCommand(backend: backend))

// Serverless NEG for Cloud Run
let serverlessBackend = GoogleCloudBackendService.Backend(
    group: .serverlessNEG(name: "cloudrun-neg", region: "us-central1")
)
```

**URL Maps and Routing:**

```swift
// Create a URL map with path-based routing
let urlMap = GoogleCloudURLMap(
    name: "api-url-map",
    projectID: "my-project",
    defaultService: "default-backend",
    description: "API routing"
)
print(urlMap.createCommand)

// Add path matcher for versioned APIs
let pathMatcher = GoogleCloudURLMap.PathMatcher(
    name: "api-paths",
    defaultService: "api-backend",
    pathRules: [
        .init(paths: ["/api/v1/*"], service: "api-v1-backend"),
        .init(paths: ["/api/v2/*"], service: "api-v2-backend")
    ]
)
print(urlMap.addPathMatcherCommand(pathMatcher: pathMatcher, hosts: ["api.example.com"]))
```

**Target Proxies:**

```swift
// HTTPS target proxy with SSL certificate
let httpsProxy = GoogleCloudTargetProxy(
    name: "https-proxy",
    projectID: "my-project",
    type: .https,
    urlMap: "api-url-map",
    sslCertificates: ["my-cert"],
    sslPolicy: "modern-ssl-policy"
)
print(httpsProxy.createCommand)

// TCP proxy for non-HTTP traffic
let tcpProxy = GoogleCloudTargetProxy(
    name: "tcp-proxy",
    projectID: "my-project",
    type: .tcp,
    backendService: "tcp-backend"
)

// gRPC proxy
let grpcProxy = GoogleCloudTargetProxy(
    name: "grpc-proxy",
    projectID: "my-project",
    type: .grpc,
    urlMap: "grpc-url-map"
)
```

**Forwarding Rules:**

```swift
// Global HTTPS forwarding rule
let httpsRule = GoogleCloudForwardingRule(
    name: "https-rule",
    projectID: "my-project",
    ipAddress: "34.120.0.1",
    ipProtocol: .tcp,
    portRange: "443",
    target: "https-proxy",
    loadBalancingScheme: .externalManaged,
    networkTier: .premium
)
print(httpsRule.createCommand)

// Regional internal load balancer
let internalRule = GoogleCloudForwardingRule(
    name: "internal-lb",
    projectID: "my-project",
    target: "internal-proxy",
    loadBalancingScheme: .internal,
    network: "my-vpc",
    subnetwork: "my-subnet",
    isGlobal: false,
    region: "us-central1",
    allowGlobalAccess: true
)
```

**SSL Certificates:**

```swift
// Managed SSL certificate (auto-renewed)
let managedCert = GoogleCloudSSLCertificate(
    name: "api-cert",
    projectID: "my-project",
    type: .managed,
    domains: ["api.example.com", "www.api.example.com"]
)
print(managedCert.createCommand)

// Self-managed certificate
let selfManagedCert = GoogleCloudSSLCertificate(
    name: "custom-cert",
    projectID: "my-project",
    type: .selfManaged,
    certificatePath: "/path/to/cert.pem",
    privateKeyPath: "/path/to/key.pem"
)
```

**SSL Policies:**

```swift
// Modern SSL policy with TLS 1.2+
let sslPolicy = GoogleCloudSSLPolicy(
    name: "modern-policy",
    projectID: "my-project",
    minTlsVersion: .tls12,
    profile: .modern
)
print(sslPolicy.createCommand)

// Restricted policy for compliance (TLS 1.3 only)
let restrictedPolicy = GoogleCloudSSLPolicy(
    name: "restricted-policy",
    projectID: "my-project",
    minTlsVersion: .tls13,
    profile: .restricted
)

// Custom cipher suite
let customPolicy = GoogleCloudSSLPolicy(
    name: "custom-policy",
    projectID: "my-project",
    minTlsVersion: .tls12,
    profile: .custom,
    customFeatures: [
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    ]
)
```

**Network Endpoint Groups (NEGs):**

```swift
// Serverless NEG for Cloud Run
let cloudRunNEG = GoogleCloudNetworkEndpointGroup(
    name: "cloudrun-neg",
    projectID: "my-project",
    type: .serverless,
    region: "us-central1",
    cloudRunService: "my-api"
)
print(cloudRunNEG.createCommand)

// Cloud Functions NEG
let functionsNEG = GoogleCloudNetworkEndpointGroup(
    name: "functions-neg",
    projectID: "my-project",
    type: .serverless,
    region: "us-central1",
    cloudFunction: "my-function"
)

// Zonal NEG for VMs
let zonalNEG = GoogleCloudNetworkEndpointGroup(
    name: "vm-neg",
    projectID: "my-project",
    type: .zonalGCE,
    network: "my-vpc",
    subnetwork: "my-subnet",
    defaultPort: 8080,
    zone: "us-central1-a"
)
```

**DAIS Load Balancing Templates:**

```swift
// Complete HTTPS load balancer for DAIS
let healthCheck = DAISLoadBalancingTemplate.httpHealthCheck(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

let backendService = DAISLoadBalancingTemplate.httpBackendService(
    projectID: "my-project",
    deploymentName: "dais-prod",
    healthCheckName: "dais-prod-http-hc"
)

let urlMap = DAISLoadBalancingTemplate.urlMap(
    projectID: "my-project",
    deploymentName: "dais-prod",
    defaultBackendService: "dais-prod-http-backend"
)

let cert = DAISLoadBalancingTemplate.sslCertificate(
    projectID: "my-project",
    deploymentName: "dais-prod",
    domains: ["api.example.com"]
)

let sslPolicy = DAISLoadBalancingTemplate.sslPolicy(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

let proxy = DAISLoadBalancingTemplate.httpsTargetProxy(
    projectID: "my-project",
    deploymentName: "dais-prod",
    urlMapName: "dais-prod-url-map",
    sslCertificateName: "dais-prod-cert",
    sslPolicyName: "dais-prod-ssl-policy"
)

// Serverless NEG for Cloud Run backend
let neg = DAISLoadBalancingTemplate.cloudRunNEG(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1",
    cloudRunServiceName: "dais-api"
)

// Complete setup and teardown scripts
let setupScript = DAISLoadBalancingTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    domains: ["api.example.com"],
    cloudRunServiceName: "dais-api",
    region: "us-central1"
)

let teardownScript = DAISLoadBalancingTemplate.teardownScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    region: "us-central1"
)
```

**Health Check Types:**

| Type | Use Case |
|------|----------|
| `http` | HTTP services |
| `https` | HTTPS services |
| `tcp` | TCP services, databases |
| `ssl` | SSL/TLS services |
| `grpc` | gRPC services |
| `http2` | HTTP/2 services |

**Load Balancing Schemes:**

| Scheme | Description |
|--------|-------------|
| `external` | Internet-facing, classic LB |
| `externalManaged` | Internet-facing, global LB |
| `internal` | Internal traffic only |
| `internalManaged` | Internal regional HTTP(S) LB |

**SSL Policy Profiles:**

| Profile | Description |
|---------|-------------|
| `compatible` | Broad compatibility (TLS 1.0+) |
| `modern` | Modern browsers (TLS 1.2+) |
| `restricted` | Strictest security (TLS 1.3) |
| `custom` | Custom cipher suites |

**Network Endpoint Group Types:**

| Type | Description |
|------|-------------|
| `zonalGCE` | VM instances in a zone |
| `zonalNonGCP` | Non-GCP private IPs |
| `serverless` | Cloud Run, Functions, App Engine |
| `internet` | External FQDN endpoints |
| `privateServiceConnect` | PSC endpoints |

### GoogleCloudArtifactRegistryRepository (Artifact Registry API)

Artifact Registry provides secure, private container image and package management:

```swift
// Create a Docker repository
let dockerRepo = GoogleCloudArtifactRegistryRepository(
    name: "my-docker-repo",
    projectID: "my-project",
    location: "us-central1",
    format: .docker,
    description: "Docker images for production",
    labels: ["env": "production"]
)
print(dockerRepo.createCommand)
print(dockerRepo.dockerHost)        // us-central1-docker.pkg.dev
print(dockerRepo.dockerImagePrefix) // us-central1-docker.pkg.dev/my-project/my-docker-repo

// Create npm, Maven, Python repositories
let npmRepo = GoogleCloudArtifactRegistryRepository(
    name: "npm-packages",
    projectID: "my-project",
    location: "us-central1",
    format: .npm
)
print(npmRepo.npmRegistryURL)

let mavenRepo = GoogleCloudArtifactRegistryRepository(
    name: "maven-artifacts",
    projectID: "my-project",
    location: "us-central1",
    format: .maven
)
print(mavenRepo.mavenRepositoryURL)

let pythonRepo = GoogleCloudArtifactRegistryRepository(
    name: "python-packages",
    projectID: "my-project",
    location: "us-central1",
    format: .python
)
print(pythonRepo.pythonRepositoryURL)
```

**Repository with Cleanup Policies:**

```swift
// Repository with automatic cleanup policies
let repo = GoogleCloudArtifactRegistryRepository(
    name: "docker-repo",
    projectID: "my-project",
    location: "us-central1",
    format: .docker,
    cleanupPolicies: [
        .init(
            id: "delete-untagged",
            action: .delete,
            condition: .init(tagState: .untagged, olderThan: "604800s") // 7 days
        ),
        .init(
            id: "keep-recent",
            action: .keep,
            mostRecentVersions: .init(keepCount: 10)
        )
    ],
    vulnerabilityScanningConfig: .init(enablementConfig: .automatic)
)
```

**Virtual and Remote Repositories:**

```swift
// Virtual repository (aggregates multiple repos)
let virtualRepo = GoogleCloudArtifactRegistryRepository(
    name: "virtual-docker",
    projectID: "my-project",
    location: "us-central1",
    format: .docker,
    mode: .virtualRepository
)

// Remote repository (caches from upstream)
let remoteRepo = GoogleCloudArtifactRegistryRepository(
    name: "dockerhub-cache",
    projectID: "my-project",
    location: "us-central1",
    format: .docker,
    mode: .remoteRepository
)
```

**Docker Image Management:**

```swift
// Reference a Docker image
let image = GoogleCloudDockerImage(
    name: "api-service",
    repositoryName: "docker-repo",
    projectID: "my-project",
    location: "us-central1",
    tag: "v1.0.0"
)
print(image.imageURL)  // us-central1-docker.pkg.dev/my-project/docker-repo/api-service:v1.0.0
print(image.dockerPullCommand)
print(image.dockerPushCommand)

// Tag and push workflow
print(image.dockerTagCommand(sourceImage: "local-build:latest"))
print(image.listTagsCommand)
print(image.addTagCommand(sourceTag: "v1.0.0", newTag: "latest"))
print(image.describeCommand)
```

**Package Management:**

```swift
// npm package
let npmPackage = GoogleCloudPackage(
    name: "@myorg/shared-utils",
    repositoryName: "npm-repo",
    projectID: "my-project",
    location: "us-central1",
    format: .npm
)
print(npmPackage.resourceName)
print(GoogleCloudPackage.listCommand(projectID: "my-project", location: "us-central1", repositoryName: "npm-repo"))

// Package versions
let version = GoogleCloudPackageVersion(
    version: "1.2.3",
    packageName: "@myorg/shared-utils",
    repositoryName: "npm-repo",
    projectID: "my-project",
    location: "us-central1"
)
print(GoogleCloudPackageVersion.listCommand(
    projectID: "my-project",
    location: "us-central1",
    repositoryName: "npm-repo",
    packageName: "@myorg/shared-utils"
))
```

**Docker Authentication:**

```swift
// Configure Docker authentication
let auth = ArtifactRegistryDockerAuth(location: "us-central1")
print(auth.configureDockerCommand)  // gcloud auth configure-docker us-central1-docker.pkg.dev
print(auth.dockerLoginCommand)
print(auth.credentialHelperConfig)  // Docker config.json content
```

**npm Configuration:**

```swift
// Configure npm for Artifact Registry
let npmConfig = ArtifactRegistryNpmConfig(
    projectID: "my-project",
    location: "us-central1",
    repositoryName: "npm-repo",
    scope: "@myorg"
)
print(npmConfig.registryURL)
print(npmConfig.printCredentialsCommand)
print(npmConfig.npmrcConfig)  // .npmrc content
```

**Maven Configuration:**

```swift
// Configure Maven for Artifact Registry
let mavenConfig = ArtifactRegistryMavenConfig(
    projectID: "my-project",
    location: "us-central1",
    repositoryName: "maven-repo"
)
print(mavenConfig.repositoryURL)
print(mavenConfig.printSettingsCommand)
print(mavenConfig.pomRepositoryConfig)      // pom.xml repository section
print(mavenConfig.pomDistributionConfig)    // pom.xml distributionManagement section
```

**Python/pip Configuration:**

```swift
// Configure pip for Artifact Registry
let pythonConfig = ArtifactRegistryPythonConfig(
    projectID: "my-project",
    location: "us-central1",
    repositoryName: "python-repo"
)
print(pythonConfig.repositoryURL)
print(pythonConfig.pipInstallCommand(package: "my-package"))
print(pythonConfig.pipConfig)  // pip.conf content
print(pythonConfig.twineUploadCommand())
```

**Vulnerability Scanning:**

```swift
// Scan Docker images for vulnerabilities
let scan = GoogleCloudVulnerabilityScan(
    imageURL: "us-central1-docker.pkg.dev/my-project/repo/image:latest",
    projectID: "my-project"
)
print(scan.scanCommand)
print(scan.listVulnerabilitiesCommand)
```

**IAM and Permissions:**

```swift
// Grant repository access
let repo = GoogleCloudArtifactRegistryRepository(
    name: "docker-repo",
    projectID: "my-project",
    location: "us-central1",
    format: .docker
)
print(repo.addIAMBindingCommand(
    member: "serviceAccount:my-sa@my-project.iam.gserviceaccount.com",
    role: ArtifactRegistryRole.reader.rawValue
))
print(repo.getIAMPolicyCommand)

// Available roles
print(ArtifactRegistryRole.admin.rawValue)    // roles/artifactregistry.admin
print(ArtifactRegistryRole.writer.rawValue)   // roles/artifactregistry.writer
print(ArtifactRegistryRole.reader.rawValue)   // roles/artifactregistry.reader
```

**DAIS Artifact Registry Templates:**

```swift
// Docker repository with DAIS best practices
let repo = DAISArtifactRegistryTemplate.dockerRepository(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)
// Includes cleanup policies and vulnerability scanning

// Pre-configured service images
let apiImage = DAISArtifactRegistryTemplate.apiServiceImage(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    tag: "v1.0.0"
)

let grpcImage = DAISArtifactRegistryTemplate.grpcServiceImage(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)

let workerImage = DAISArtifactRegistryTemplate.workerServiceImage(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)

// Generate Swift Dockerfile
let dockerfile = DAISArtifactRegistryTemplate.swiftDockerfile(
    executableName: "dais-server",
    port: 8080
)

// Cloud Build configuration for CI/CD
let cloudbuildConfig = DAISArtifactRegistryTemplate.cloudbuildConfig(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    serviceName: "api-service",
    cloudRunRegion: "us-central1"
)

// Complete setup and teardown scripts
let setupScript = DAISArtifactRegistryTemplate.setupScript(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)

let cicdScript = DAISArtifactRegistryTemplate.cicdSetupScript(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    repoOwner: "myorg",
    repoName: "my-repo"
)
```

**Repository Formats:**

| Format | Use Case |
|--------|----------|
| `docker` | Container images |
| `maven` | Java/Kotlin packages |
| `npm` | JavaScript/TypeScript packages |
| `python` | Python packages (pip) |
| `apt` | Debian packages |
| `yum` | RPM packages |
| `go` | Go modules |
| `generic` | Arbitrary files |

**Repository Modes:**

| Mode | Description |
|------|-------------|
| `standardRepository` | Store and serve artifacts directly |
| `virtualRepository` | Aggregate multiple repositories |
| `remoteRepository` | Cache artifacts from upstream sources |

**Cleanup Policy Actions:**

| Action | Description |
|--------|-------------|
| `delete` | Delete matching artifacts |
| `keep` | Keep matching artifacts (exclude from deletion) |

### GoogleCloudBuild (Cloud Build API)

Cloud Build provides serverless CI/CD pipelines for building, testing, and deploying applications:

```swift
// Basic build configuration
let step = GoogleCloudBuild.BuildStep(
    name: "gcr.io/cloud-builders/docker",
    args: ["build", "-t", "us-central1-docker.pkg.dev/my-project/repo/image:$COMMIT_SHA", "."]
)

let build = GoogleCloudBuild(
    projectID: "my-project",
    steps: [step],
    images: ["us-central1-docker.pkg.dev/my-project/repo/image:$COMMIT_SHA"],
    timeout: "1200s"
)

// Submit a build
print(build.submitCommand)
// Output: gcloud builds submit --project=my-project

// List and manage builds
print(GoogleCloudBuild.listCommand(projectID: "my-project", ongoing: true))
print(GoogleCloudBuild.cancelCommand(buildID: "build-123", projectID: "my-project"))
print(GoogleCloudBuild.logCommand(buildID: "build-123", projectID: "my-project", stream: true))
```

**Build Triggers:**

```swift
// GitHub push trigger
let githubTrigger = GoogleCloudBuildTrigger(
    name: "deploy-on-push",
    projectID: "my-project",
    description: "Deploy on push to main",
    triggerSource: .github(
        owner: "myorg",
        name: "myrepo",
        eventConfig: .push(branch: "^main$", tag: nil, invertRegex: false)
    ),
    buildConfig: .filename("cloudbuild.yaml"),
    substitutions: ["DEPLOY_ENV": "production"],
    region: "us-central1"
)
print(githubTrigger.createCommandGitHub!)

// Pull request trigger
let prTrigger = GoogleCloudBuildTrigger(
    name: "pr-preview",
    projectID: "my-project",
    triggerSource: .github(
        owner: "myorg",
        name: "myrepo",
        eventConfig: .pullRequest(
            branch: "^main$",
            commentControl: .commentsEnabledForExternalContributorsOnly,
            invertRegex: false
        )
    ),
    buildConfig: .filename("cloudbuild-preview.yaml")
)

// Pub/Sub trigger
let pubsubTrigger = GoogleCloudBuildTrigger(
    name: "scheduled-build",
    projectID: "my-project",
    triggerSource: .pubsub(
        topic: "projects/my-project/topics/build-trigger",
        serviceAccountEmail: "build-sa@my-project.iam.gserviceaccount.com"
    ),
    buildConfig: .filename("cloudbuild.yaml")
)

// Manual trigger (on-demand deployments)
let manualTrigger = GoogleCloudBuildTrigger(
    name: "manual-deploy",
    projectID: "my-project",
    triggerSource: .manual,
    buildConfig: .filename("cloudbuild.yaml"),
    approvalRequired: true
)

// Trigger operations
print(githubTrigger.describeCommand)
print(githubTrigger.runCommand(branchName: "main"))
print(githubTrigger.deleteCommand)
```

**Worker Pools (Private Builds):**

```swift
let workerPool = GoogleCloudBuildWorkerPool(
    name: "private-pool",
    projectID: "my-project",
    region: "us-central1",
    privatePoolConfig: .init(
        workerConfig: .init(machineType: "e2-highcpu-8", diskSizeGb: 200),
        networkConfig: .init(
            peeredNetwork: "projects/my-project/global/networks/my-vpc",
            egressOption: .noPublicEgress
        )
    )
)

print(workerPool.createCommand)
print(workerPool.updateCommand(machineType: "e2-highcpu-32"))
```

**GitHub/GitLab Connections (2nd Gen):**

```swift
// Create a GitHub connection
let connection = GoogleCloudBuildConnection(
    name: "github-connection",
    projectID: "my-project",
    region: "us-central1",
    connectionType: .github(appInstallationId: nil)
)
print(connection.createCommand!)

// Link a repository
let repo = GoogleCloudBuildRepository(
    name: "my-repo",
    projectID: "my-project",
    region: "us-central1",
    connectionName: "github-connection",
    remoteUri: "https://github.com/myorg/myrepo.git"
)
print(repo.createCommand)
```

**Cloud Build Operations:**

```swift
// Enable Cloud Build API
print(CloudBuildOperations.enableAPICommand(projectID: "my-project"))

// Submit builds with options
print(CloudBuildOperations.submitCommand(
    projectID: "my-project",
    configFile: "cloudbuild.yaml",
    tag: "us-central1-docker.pkg.dev/my-project/repo/image:latest",
    machineType: .e2Highcpu8,
    timeout: "1800s",
    async: true
))

// Grant Cloud Build permissions
print(CloudBuildOperations.grantCloudRunDeployerCommand(projectID: "my-project"))
print(CloudBuildOperations.grantArtifactRegistryWriterCommand(projectID: "my-project"))
print(CloudBuildOperations.grantGKEDeployerCommand(projectID: "my-project"))

// Build approvals
print(CloudBuildOperations.approveCommand(buildID: "build-123", projectID: "my-project"))
print(CloudBuildOperations.rejectCommand(buildID: "build-123", projectID: "my-project", comment: "Needs review"))
```

**cloudbuild.yaml Generators:**

```swift
// Docker build and push
let dockerConfig = CloudBuildConfigGenerator.dockerBuildPush(
    imageName: "us-central1-docker.pkg.dev/my-project/repo/image"
)

// Docker build and deploy to Cloud Run
let cloudRunConfig = CloudBuildConfigGenerator.dockerBuildDeployCloudRun(
    imageName: "us-central1-docker.pkg.dev/my-project/repo/image",
    serviceName: "my-service",
    region: "us-central1",
    envVars: ["ENV": "production"],
    memory: "512Mi",
    minInstances: 1
)

// Swift build and test
let swiftConfig = CloudBuildConfigGenerator.swiftBuildTest()

// Swift full CI/CD pipeline
let swiftCICD = CloudBuildConfigGenerator.swiftDockerCloudRun(
    imageName: "us-central1-docker.pkg.dev/my-project/repo/swift-app",
    serviceName: "swift-service",
    region: "us-central1",
    executableName: "server",
    port: 8080
)

// Multi-service deployment
let multiService = CloudBuildConfigGenerator.multiServiceDeploy(
    services: [
        (name: "api", imageName: "gcr.io/my-project/api", dockerfile: "api/Dockerfile", region: "us-central1"),
        (name: "web", imageName: "gcr.io/my-project/web", dockerfile: "web/Dockerfile", region: "us-central1")
    ]
)
```

**DAIS Cloud Build Templates:**

```swift
// GitHub trigger for DAIS deployment
let trigger = DAISCloudBuildTemplate.githubTrigger(
    projectID: "my-project",
    deploymentName: "dais-prod",
    owner: "myorg",
    repo: "dais-deployment"
)

// PR preview environment trigger
let prPreview = DAISCloudBuildTemplate.prPreviewTrigger(
    projectID: "my-project",
    deploymentName: "dais-prod",
    owner: "myorg",
    repo: "dais-deployment"
)

// Generate complete cloudbuild.yaml for multi-service deployment
let yaml = DAISCloudBuildTemplate.cloudbuildYaml(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    cloudRunRegion: "us-central1",
    services: [
        (name: "api", port: 8080),
        (name: "worker", port: 8081),
        (name: "scheduler", port: 8082)
    ]
)

// Complete CI/CD setup script
let setupScript = DAISCloudBuildTemplate.setupScript(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    githubOwner: "myorg",
    githubRepo: "dais-deployment",
    cloudRunRegion: "us-central1"
)

// Private worker pool for DAIS builds
let workerPool = DAISCloudBuildTemplate.workerPool(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    vpcNetwork: "projects/my-project/global/networks/dais-vpc"
)
```

**Trigger Sources:**

| Source | Description |
|--------|-------------|
| `github` | GitHub repository push/PR events |
| `cloudSourceRepository` | Cloud Source Repositories |
| `pubsub` | Pub/Sub message triggers |
| `webhook` | HTTP webhook triggers |
| `manual` | Manual/on-demand triggers |

**Build Machine Types:**

| Type | vCPUs | Memory | Use Case |
|------|-------|--------|----------|
| `E2_MEDIUM` | 2 | 4 GB | Small builds |
| `E2_HIGHCPU_8` | 8 | 8 GB | Standard builds |
| `E2_HIGHCPU_32` | 32 | 32 GB | Large/parallel builds |
| `N1_HIGHCPU_8` | 8 | 7.2 GB | Legacy workloads |
| `N1_HIGHCPU_32` | 32 | 28.8 GB | Legacy large builds |

### GoogleCloudSecurityPolicy (Cloud Armor API)

Protect your applications with Cloud Armor WAF and DDoS protection:

```swift
// Create a security policy
let policy = GoogleCloudSecurityPolicy(
    name: "dais-waf-policy",
    projectID: "my-project",
    type: .cloudArmor,
    rules: [
        SecurityPolicyRule(
            priority: 1000,
            match: .expression(SecurityExpressions.blockCountries(["CN", "RU", "KP"])),
            action: .deny403,
            description: "Block high-risk countries"
        ),
        SecurityPolicyRule(
            priority: 2000,
            match: .expression(WAFRule.sqli.expression),
            action: .deny403,
            description: "Block SQL injection attacks"
        ),
        SecurityPolicyRule(
            priority: 2147483647,
            match: .ipRanges(["*"]),
            action: .allow,
            description: "Default allow rule"
        )
    ],
    adaptiveProtectionConfig: AdaptiveProtectionConfig(layer7DdosDefenseEnabled: true)
)

print(policy.createCommand)
// Output: gcloud compute security-policies create dais-waf-policy --project=my-project --type=CLOUD_ARMOR

// Add rules to policy
for rule in policy.rules {
    print(rule.addRuleCommand(policyName: "dais-waf-policy", projectID: "my-project"))
}
```

**Rate Limiting:**

```swift
// Create rate limit rule
let rateLimitRule = SecurityPolicyRule(
    priority: 500,
    match: .expression("request.path.matches('/api/.*')"),
    action: .throttle,
    description: "API rate limiting",
    rateLimitOptions: RateLimitOptions(
        rateLimitThreshold: RateLimitThreshold(count: 100, intervalSec: 60),
        conformAction: "allow",
        exceedAction: "deny(429)",
        enforceOnKey: .ip
    )
)

// Or use Cloud Armor Operations helper
let rateLimitCmd = CloudArmorOperations.createRateLimitRule(
    policyName: "dais-waf-policy",
    projectID: "my-project",
    priority: 500,
    requestsPerMinute: 100,
    enforceOnKey: .ip
)
```

**WAF Rules (OWASP ModSecurity Core Rule Set):**

```swift
// Add WAF protection
let wafCmd = CloudArmorOperations.addWAFRule(
    policyName: "dais-waf-policy",
    projectID: "my-project",
    wafRule: .sqli,
    priority: 2000
)

// Available WAF rules
let rules: [WAFRule] = [.sqli, .xss, .lfi, .rfi, .rce, .cve202144228]
for rule in rules {
    print("\(rule.rawValue): \(rule.description)")
}
```

**Attach to Backend Service:**

```swift
// Attach policy to load balancer backend
let attachCmd = CloudArmorOperations.attachToBackendService(
    policyName: "dais-waf-policy",
    backendServiceName: "dais-backend",
    projectID: "my-project"
)
```

**DAIS Templates:**

```swift
// Complete security policy for production
let policy = DAISCloudArmorTemplate.securityPolicy(
    projectID: "my-project",
    deploymentName: "dais-prod"
)

// Pre-configured protection rules
let owaspRule = DAISCloudArmorTemplate.owaspProtectionRule(priority: 1000)
let rceRule = DAISCloudArmorTemplate.rceProtectionRule(priority: 1100)
let log4jRule = DAISCloudArmorTemplate.log4jProtectionRule(priority: 1200)
let rateLimitRule = DAISCloudArmorTemplate.apiRateLimitRule(
    priority: 500,
    pathPattern: "/api/v1/.*",
    requestsPerMinute: 100
)

// Geographic blocking
let geoRule = DAISCloudArmorTemplate.geoBlockRule(
    priority: 100,
    countryCodes: ["CN", "RU", "KP", "IR"]
)

// Complete setup script
let setupScript = DAISCloudArmorTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    backendServiceName: "dais-backend"
)
```

**WAF Rules Reference:**

| Rule | Description | Sensitivity |
|------|-------------|-------------|
| `sqli` | SQL Injection protection | 1-4 |
| `xss` | Cross-site scripting protection | 1-2 |
| `lfi` | Local file inclusion protection | 1-2 |
| `rfi` | Remote file inclusion protection | 1-2 |
| `rce` | Remote code execution protection | 1-3 |
| `cve202144228` | Log4j vulnerability (Log4Shell) | 1-3 |

**Security Expression Helpers:**

| Expression | Description |
|------------|-------------|
| `blockCountries(codes)` | Block requests from specific countries |
| `allowOnlyCountries(codes)` | Allow only requests from specific countries |
| `blockPaths(patterns)` | Block specific URL paths |
| `blockUserAgents(patterns)` | Block specific user agents |
| `matchAPIPaths(version)` | Match API endpoint paths |

### CDNCachePolicy (Cloud CDN)

Accelerate content delivery with Cloud CDN:

```swift
// Create a CDN cache policy
let cachePolicy = CDNCachePolicy(
    cacheMode: .cacheAllStatic,
    defaultTTL: 3600,
    maxTTL: 86400,
    negativeCaching: true,
    negativeCachingPolicy: [
        .init(code: 404, ttl: 60),
        .init(code: 500, ttl: 10)
    ],
    serveWhileStale: 86400
)

// Configure cache key policy
let keyPolicy = CDNCachePolicy.CacheKeyPolicy(
    includeHost: true,
    includeProtocol: false,
    includeQueryString: true,
    queryStringWhitelist: ["page", "limit"]
)
```

**Backend Bucket for Static Assets:**

```swift
// Create CDN-enabled backend bucket
let backendBucket = CDNBackendBucket(
    name: "my-static-assets",
    projectID: "my-project",
    bucketName: "my-storage-bucket",
    enableCDN: true,
    compressionMode: .automatic
)

print(backendBucket.createCommand)
// Output: gcloud compute backend-buckets create my-static-assets --gcs-bucket-name=my-storage-bucket --enable-cdn ...
```

**Signed URLs for Protected Content:**

```swift
// Create signed URL key
let signedKey = CDNSignedURLKey(keyName: "my-key", keyValue: "secret-value")

// Add to backend bucket
print(signedKey.addToBackendBucketCommand(backendBucket: "my-bucket", projectID: "my-project"))

// Generate signed URL
let signCmd = CDNSignedURLGenerator.signURLCommand(
    url: "https://cdn.example.com/video.mp4",
    keyName: "my-key",
    keyFilePath: "/path/to/key",
    expiresIn: "2h"
)
```

**Cache Invalidation:**

```swift
// Invalidate specific path
let invalidation = CDNCacheInvalidation(
    urlMap: "my-url-map",
    projectID: "my-project",
    path: "/images/*"
)
print(invalidation.invalidateCommand)

// Invalidate all cache
print(CDNCacheInvalidation.invalidateAllCommand(urlMap: "my-url-map", projectID: "my-project"))
```

**CDN Operations:**

```swift
// Enable CDN on backend service
let enableCmd = CDNOperations.enableCDNOnBackendService(
    backendService: "my-service",
    projectID: "my-project",
    cacheMode: .forceCacheAll
)

// Set cache TTL
let ttlCmd = CDNOperations.setCacheTTL(
    backendService: "my-service",
    projectID: "my-project",
    defaultTTL: 3600,
    maxTTL: 86400
)
```

**DAIS Templates:**

```swift
// Static assets bucket with CDN
let assetsBucket = DAISCDNTemplate.staticAssetsBucket(
    projectID: "my-project",
    deploymentName: "dais-prod",
    storageBucket: "dais-static"
)

// API cache policy (short TTL)
let apiPolicy = DAISCDNTemplate.apiCachePolicy()

// Media streaming policy (long TTL)
let mediaPolicy = DAISCDNTemplate.mediaCachePolicy()

// Edge security policy
let edgePolicy = DAISCDNTemplate.edgeSecurityPolicy(
    projectID: "my-project",
    deploymentName: "dais-prod"
)
```

**Cache Mode Reference:**

| Mode | Description |
|------|-------------|
| `useOriginHeaders` | Respect Cache-Control headers from origin |
| `forceCacheAll` | Cache all responses regardless of headers |
| `cacheAllStatic` | Automatically cache static content types |

### GoogleCloudTaskQueue (Cloud Tasks)

Manage distributed task queues for async processing:

```swift
// Create a task queue with rate limiting
let queue = GoogleCloudTaskQueue(
    name: "my-processing-queue",
    projectID: "my-project",
    location: "us-central1",
    rateLimits: GoogleCloudTaskQueue.RateLimits(
        maxDispatchesPerSecond: 500,
        maxConcurrentDispatches: 100
    ),
    retryConfig: GoogleCloudTaskQueue.RetryConfig(
        maxAttempts: 5,
        minBackoff: "1s",
        maxBackoff: "60s",
        maxDoublings: 4
    )
)

print(queue.createCommand)
// Output: gcloud tasks queues create my-processing-queue --location=us-central1 ...

// Queue management
print(queue.pauseCommand)   // Pause queue
print(queue.resumeCommand)  // Resume queue
print(queue.purgeCommand)   // Clear all tasks
```

**HTTP Tasks:**

```swift
// Create HTTP task for Cloud Run
let task = GoogleCloudHTTPTask(
    queueName: "my-queue",
    projectID: "my-project",
    location: "us-central1",
    url: "https://my-service.run.app/process",
    httpMethod: .post,
    headers: ["Content-Type": "application/json"],
    body: "{\"data\": \"payload\"}",
    oidcToken: GoogleCloudHTTPTask.OIDCToken(
        serviceAccountEmail: "sa@project.iam.gserviceaccount.com",
        audience: "https://my-service.run.app"
    )
)

print(task.createCommand)
```

**App Engine Tasks:**

```swift
// Create App Engine task
let appTask = GoogleCloudAppEngineTask(
    queueName: "my-queue",
    projectID: "my-project",
    location: "us-central1",
    relativeUri: "/worker/process",
    httpMethod: .post,
    appEngineRouting: GoogleCloudAppEngineTask.AppEngineRouting(
        service: "worker",
        version: "v1"
    )
)

print(appTask.createCommand)
```

**Task Operations:**

```swift
// List tasks in queue
let listCmd = TaskOperations.listTasks(
    queueName: "my-queue",
    location: "us-central1",
    projectID: "my-project"
)

// Run a task immediately
let runCmd = TaskOperations.runTask(
    taskID: "task-123",
    queueName: "my-queue",
    location: "us-central1",
    projectID: "my-project"
)
```

**DAIS Templates:**

```swift
// API processing queue (high throughput)
let apiQueue = DAISTasksTemplate.apiProcessingQueue(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)

// Background jobs queue (with retries)
let bgQueue = DAISTasksTemplate.backgroundJobsQueue(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)

// Create Cloud Run task
let cloudRunTask = DAISTasksTemplate.cloudRunTask(
    queueName: "dais-prod-api-processing",
    projectID: "my-project",
    location: "us-central1",
    cloudRunURL: "https://my-service.run.app",
    endpoint: "/process",
    payload: "{\"job\": \"data\"}",
    serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
)
```

**Queue Roles:**

| Role | Description |
|------|-------------|
| `admin` | Full control of Cloud Tasks resources |
| `enqueuer` | Can create tasks |
| `taskDeleter` | Can delete tasks |
| `taskRunner` | Can run tasks |
| `viewer` | Read-only access |

### GoogleCloudCryptoKey (Cloud KMS)

Manage encryption keys with Cloud Key Management Service:

```swift
// Create a key ring
let keyRing = GoogleCloudKeyRing(
    name: "my-keyring",
    projectID: "my-project",
    location: "us-central1"
)
print(keyRing.createCommand)

// Create an encryption key
let key = GoogleCloudCryptoKey(
    name: "data-encryption-key",
    keyRing: "my-keyring",
    projectID: "my-project",
    location: "us-central1",
    purpose: .encryptDecrypt,
    protectionLevel: .software,
    rotationPeriod: "7776000s" // 90 days
)
print(key.createCommand)
```

**Key Purposes:**

```swift
// Symmetric encryption
let encryptKey = GoogleCloudCryptoKey(
    name: "encrypt-key",
    keyRing: "my-keyring",
    projectID: "my-project",
    location: "us-central1",
    purpose: .encryptDecrypt
)

// Asymmetric signing (for JWT, code signing)
let signKey = GoogleCloudCryptoKey(
    name: "signing-key",
    keyRing: "my-keyring",
    projectID: "my-project",
    location: "us-central1",
    purpose: .asymmetricSign,
    versionTemplate: GoogleCloudCryptoKey.VersionTemplate(
        algorithm: .ecSignP256Sha256
    )
)

// HSM-protected key
let hsmKey = GoogleCloudCryptoKey(
    name: "hsm-key",
    keyRing: "my-keyring",
    projectID: "my-project",
    location: "us-central1",
    protectionLevel: .hsm
)
```

**KMS Operations:**

```swift
// Encrypt data
let encryptCmd = KMSOperations.encryptCommand(
    keyName: "my-key",
    keyRing: "my-keyring",
    location: "us-central1",
    projectID: "my-project",
    plaintextFile: "secret.txt",
    ciphertextFile: "secret.enc"
)

// Decrypt data
let decryptCmd = KMSOperations.decryptCommand(
    keyName: "my-key",
    keyRing: "my-keyring",
    location: "us-central1",
    projectID: "my-project",
    ciphertextFile: "secret.enc",
    plaintextFile: "secret.txt"
)

// Sign with asymmetric key
let signCmd = KMSOperations.asymmetricSignCommand(
    keyName: "signing-key",
    keyRing: "my-keyring",
    location: "us-central1",
    projectID: "my-project",
    version: "1",
    inputFile: "data.txt",
    signatureFile: "signature.bin"
)
```

**Key Versions:**

```swift
let version = GoogleCloudCryptoKeyVersion(
    keyName: "my-key",
    keyRing: "my-keyring",
    projectID: "my-project",
    location: "us-central1",
    version: "1"
)

print(version.enableCommand)   // Enable version
print(version.disableCommand)  // Disable version
print(version.destroyCommand)  // Schedule destruction (24h delay)
print(version.getPublicKeyCommand)  // Get public key (asymmetric)
```

**DAIS Templates:**

```swift
// Key ring for deployment
let keyRing = DAISKMSTemplate.keyRing(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod"
)

// Data encryption key with rotation
let dataKey = DAISKMSTemplate.dataEncryptionKey(
    projectID: "my-project",
    location: "us-central1",
    keyRing: "dais-prod-keyring",
    deploymentName: "dais-prod"
)

// HSM-protected key for sensitive data
let hsmKey = DAISKMSTemplate.hsmEncryptionKey(
    projectID: "my-project",
    location: "us-central1",
    keyRing: "dais-prod-keyring",
    deploymentName: "dais-prod"
)

// Signing key for JWT tokens
let signingKey = DAISKMSTemplate.signingKey(
    projectID: "my-project",
    location: "us-central1",
    keyRing: "dais-prod-keyring",
    deploymentName: "dais-prod"
)
```

**Protection Levels:**

| Level | Description |
|-------|-------------|
| `software` | Software-protected (default) |
| `hsm` | Hardware Security Module protected |
| `external` | Externally managed key |
| `externalVpc` | External key via VPC |

### GoogleCloudEventarcTrigger (Eventarc)

Build event-driven architectures with Eventarc:

```swift
// Create a trigger for Cloud Storage events
let trigger = GoogleCloudEventarcTrigger(
    name: "storage-upload-trigger",
    projectID: "my-project",
    location: "us-central1",
    destination: .cloudRun(service: "my-processor", path: "/events", region: "us-central1"),
    eventFilters: [
        EventFilter(attribute: "type", value: GoogleCloudEventType.storageObjectFinalize.rawValue),
        EventFilter(attribute: "bucket", value: "my-bucket")
    ],
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)
print(trigger.createCommand)
```

**Destinations:**

```swift
// Cloud Run destination
let cloudRunDest = GoogleCloudEventarcTrigger.Destination.cloudRun(
    service: "my-service",
    path: "/webhook",
    region: "us-central1"
)

// Cloud Function destination
let functionDest = GoogleCloudEventarcTrigger.Destination.cloudFunction(
    name: "my-function",
    region: "us-central1"
)

// Workflow destination
let workflowDest = GoogleCloudEventarcTrigger.Destination.workflow(
    name: "my-workflow",
    region: "us-central1"
)
```

**Event Types:**

```swift
// Storage events
let storageEvent = GoogleCloudEventType.storageObjectFinalize

// Pub/Sub events
let pubsubEvent = GoogleCloudEventType.pubsubMessagePublish

// Build events
let buildEvent = GoogleCloudEventType.cloudBuildComplete

// Firestore events
let firestoreEvent = GoogleCloudEventType.firestoreDocumentWrite
```

**Custom Event Channels:**

```swift
let channel = GoogleCloudEventarcChannel(
    name: "custom-events",
    projectID: "my-project",
    location: "us-central1"
)
print(channel.createCommand)
```

**DAIS Templates:**

```swift
// Storage upload trigger
let storageTrigger = DAISEventarcTemplate.storageUploadTrigger(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    bucket: "dais-uploads",
    destinationService: "dais-api",
    serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
)

// Pub/Sub trigger
let pubsubTrigger = DAISEventarcTemplate.pubsubMessageTrigger(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    destinationService: "dais-api",
    serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
)
```

### GoogleCloudRedisInstance (Memorystore)

Deploy and manage Redis instances with Memorystore:

```swift
// Create a basic Redis instance
let redis = GoogleCloudRedisInstance(
    name: "my-cache",
    projectID: "my-project",
    region: "us-central1",
    tier: .basic,
    memorySizeGB: 1,
    redisVersion: .redis7_0
)
print(redis.createCommand)
// Output: gcloud redis instances create my-cache --project=my-project --region=us-central1 --tier=BASIC --size=1 --redis-version=redis_7_0

// Create a high-availability Redis instance
let haRedis = GoogleCloudRedisInstance(
    name: "prod-cache",
    projectID: "my-project",
    region: "us-central1",
    tier: .standard,
    memorySizeGB: 5,
    redisVersion: .redis7_0,
    network: "default",
    connectMode: .privateServiceAccess,
    authEnabled: true,
    transitEncryptionMode: .serverAuthentication
)

// Enable Redis AUTH
print(haRedis.updateCommand(authEnabled: true))

// Get instance details
print(redis.describeCommand)

// Export/Import for backup
print(redis.exportCommand(gcsURI: "gs://my-bucket/redis-backup.rdb"))
print(redis.importCommand(gcsURI: "gs://my-bucket/redis-backup.rdb"))
```

**Memcached Instances:**

```swift
// Create a Memcached instance
let memcached = GoogleCloudMemcachedInstance(
    name: "session-cache",
    projectID: "my-project",
    region: "us-central1",
    nodeCount: 3,
    nodeCPUs: 1,
    nodeMemoryMB: 1024,
    memcachedVersion: .memcache1_5
)
print(memcached.createCommand)

// Update node count
print(memcached.updateCommand(nodeCount: 5))

// Apply parameters
print(memcached.applyParametersCommand(applyAll: true))
```

**DAIS Memorystore Templates:**

```swift
// Create Redis for session caching
let sessionCache = DAISMemorystoreTemplate.sessionCache(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod"
)

// Create Redis for API caching
let apiCache = DAISMemorystoreTemplate.apiCache(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    memorySizeGB: 2
)

// Setup script for all caching infrastructure
let script = DAISMemorystoreTemplate.setupScript(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod"
)
```

### GoogleCloudServicePerimeter (VPC Service Controls)

Prevent data exfiltration with VPC Service Controls:

```swift
// Create an access policy for your organization
let policy = GoogleCloudAccessPolicy(
    name: "my-policy",
    organizationID: "org-123456789",
    title: "Production Security Policy"
)
print(policy.createCommand)

// Create an access level for corporate networks
let accessLevel = GoogleCloudAccessLevel(
    name: "corporate-network",
    policyID: "123456789",
    title: "Corporate Network Access",
    basic: GoogleCloudAccessLevel.BasicLevel(
        conditions: [
            GoogleCloudAccessLevel.BasicLevel.Condition(
                ipSubnetworks: ["10.0.0.0/8", "172.16.0.0/12"]
            )
        ]
    )
)
print(accessLevel.createCommand)

// Create a service perimeter to protect data
let perimeter = GoogleCloudServicePerimeter(
    name: "data-protection",
    policyID: "123456789",
    title: "Data Protection Perimeter",
    resources: ["projects/123456789012"],
    restrictedServices: RestrictedServices.dataStorage,
    accessLevels: ["corporate-network"],
    vpcAccessibleServices: GoogleCloudServicePerimeter.VPCAccessibleServices(
        enableRestriction: true,
        allowedServices: ["RESTRICTED-SERVICES"]
    )
)
print(perimeter.createCommand)

// Create a bridge perimeter for cross-project access
let bridge = GoogleCloudServicePerimeter(
    name: "project-bridge",
    policyID: "123456789",
    title: "Project Bridge",
    perimeterType: .bridge,
    resources: ["projects/123", "projects/456"]
)
```

**Predefined Restricted Services:**

```swift
// Use predefined service lists
let dataServices = RestrictedServices.dataStorage  // Storage, BigQuery, Spanner, etc.
let aiServices = RestrictedServices.aiML           // Vertex AI, Vision, Speech, etc.
let allServices = RestrictedServices.allCommon     // All commonly restricted services
```

**DAIS VPC-SC Templates:**

```swift
// Create comprehensive protection for DAIS
let protectionPerimeter = DAISVPCServiceControlsTemplate.comprehensivePerimeter(
    policyID: "policy-123",
    deploymentName: "dais-prod",
    projectNumbers: ["123456789"],
    allowBigQueryExport: true
)

// Setup script for VPC Service Controls
let script = DAISVPCServiceControlsTemplate.setupScript(
    organizationID: "org-123",
    projectID: "my-project",
    projectNumber: "123456789",
    deploymentName: "dais-prod",
    corporateCIDRs: ["10.0.0.0/8"]
)
```

### GoogleCloudFilestoreInstance (Cloud Filestore)

Deploy managed NFS file shares with Cloud Filestore:

```swift
// Create a basic Filestore instance
let filestore = GoogleCloudFilestoreInstance(
    name: "my-nfs-share",
    projectID: "my-project",
    zone: "us-central1-a",
    tier: .basicSSD,
    fileShares: [
        GoogleCloudFilestoreInstance.FileShare(
            name: "shared",
            capacityGB: 2560
        )
    ],
    networks: [
        GoogleCloudFilestoreInstance.NetworkConfig(
            network: "default"
        )
    ]
)
print(filestore.createCommand)

// Create an enterprise-grade HA instance
let enterprise = GoogleCloudFilestoreInstance(
    name: "enterprise-storage",
    projectID: "my-project",
    zone: "us-central1",  // Region for enterprise tier
    tier: .enterprise,
    fileShares: [
        GoogleCloudFilestoreInstance.FileShare(
            name: "data",
            capacityGB: 4096,
            nfsExportOptions: [
                GoogleCloudFilestoreInstance.FileShare.NFSExportOption(
                    ipRanges: ["10.0.0.0/8"],
                    accessMode: .readWrite,
                    squashMode: .rootSquash
                )
            ]
        )
    ],
    networks: [
        GoogleCloudFilestoreInstance.NetworkConfig(
            network: "prod-vpc",
            connectMode: .privateServiceAccess
        )
    ],
    kmsKeyName: "projects/my-project/locations/us-central1/keyRings/ring/cryptoKeys/key"
)
```

**Filestore Tiers:**

| Tier | Capacity | Use Case |
|------|----------|----------|
| `basic` | 1-63.9 TB | Dev/test, small workloads |
| `basicSSD` | 2.5-63.9 TB | General purpose, low latency |
| `highScaleSSD` | 10-100 TB | High throughput workloads |
| `enterprise` | 1-10 TB | Regional HA, mission critical |

**Backups and Snapshots:**

```swift
// Create a backup
let backup = GoogleCloudFilestoreBackup(
    name: "weekly-backup",
    projectID: "my-project",
    region: "us-central1",
    sourceInstance: "projects/my-project/locations/us-central1-a/instances/my-fs",
    sourceFileShare: "shared"
)
print(backup.createCommand)

// Restore from backup
print(backup.restoreCommand(
    targetInstance: "restored-fs",
    targetZone: "us-central1-a",
    targetFileShare: "restored",
    tier: .basicSSD,
    network: "default"
))
```

**DAIS Filestore Templates:**

```swift
// Create shared storage for applications
let shared = DAISFilestoreTemplate.sharedStorage(
    projectID: "my-project",
    zone: "us-central1-a",
    deploymentName: "dais-prod"
)

// Generate fstab entry for persistent mount
let fstab = DAISFilestoreTemplate.fstabEntry(
    filestoreIP: "10.0.0.2",
    fileShareName: "shared",
    mountPoint: "/mnt/filestore"
)

// Setup script for Filestore infrastructure
let script = DAISFilestoreTemplate.setupScript(
    projectID: "my-project",
    zone: "us-central1-a",
    deploymentName: "dais-prod"
)
```

### GoogleCloudVPNGateway (Cloud VPN)

Create secure site-to-site VPN connections:

```swift
// Create an HA VPN Gateway
let vpnGateway = GoogleCloudVPNGateway(
    name: "my-vpn-gateway",
    projectID: "my-project",
    region: "us-central1",
    network: "my-vpc",
    stackType: .ipv4Only,
    description: "HA VPN for on-premises connection"
)
print(vpnGateway.createCommand)

// Create an External VPN Gateway (peer)
let externalGateway = GoogleCloudExternalVPNGateway(
    name: "on-prem-gateway",
    projectID: "my-project",
    interfaces: [
        GoogleCloudExternalVPNGateway.Interface(id: 0, ipAddress: "203.0.113.1"),
        GoogleCloudExternalVPNGateway.Interface(id: 1, ipAddress: "203.0.113.2")
    ],
    redundancyType: .twoIPs
)
print(externalGateway.createCommand)

// Create VPN Tunnel
let tunnel = GoogleCloudVPNTunnel(
    name: "tunnel-0",
    projectID: "my-project",
    region: "us-central1",
    vpnGateway: "my-vpn-gateway",
    vpnGatewayInterface: 0,
    peerExternalGateway: "on-prem-gateway",
    peerExternalGatewayInterface: 0,
    sharedSecret: "your-shared-secret",
    router: "my-router",
    ikeVersion: .v2
)
print(tunnel.createCommand)
```

**VPN Redundancy Types:**

| Type | Interfaces | Use Case |
|------|------------|----------|
| `singleIPInternally` | 1 | Single active-passive device |
| `twoIPs` | 2 | Two active-active devices |
| `fourIPs` | 4 | Full HA deployment |

**DAIS VPN Templates:**

```swift
// Create HA VPN infrastructure
let haGateway = DAISVPNTemplate.haVPNGateway(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    network: "prod-vpc"
)

// Create external peer gateway
let peerGateway = DAISVPNTemplate.externalGateway(
    projectID: "my-project",
    deploymentName: "dais-prod",
    peerIPs: ["203.0.113.1", "203.0.113.2"]
)

// Generate complete HA VPN setup script with BGP
let script = DAISVPNTemplate.setupScript(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    network: "prod-vpc",
    peerASN: 65001,
    peerIPs: ["203.0.113.1"]
)
```

### GoogleCloudBigQueryDataset (BigQuery API)

BigQuery is Google Cloud's serverless data warehouse for analytics:

```swift
// Create a dataset
let dataset = GoogleCloudBigQueryDataset(
    datasetID: "analytics",
    projectID: "my-project",
    location: "US",
    description: "Analytics data warehouse",
    defaultTableExpirationMs: 7776000000, // 90 days
    labels: ["env": "prod", "team": "data"]
)

print(dataset.createCommand)
// Output: bq mk --dataset --location=US --description="Analytics data warehouse" ...

print(dataset.resourceName)
// Output: projects/my-project/datasets/analytics
```

**Creating Tables with Partitioning and Clustering:**

```swift
// Create a partitioned and clustered table
let eventsTable = GoogleCloudBigQueryTable(
    tableID: "events",
    datasetID: "analytics",
    projectID: "my-project",
    schema: GoogleCloudBigQueryTable.Schema(fields: [
        .init(name: "event_id", type: .string, mode: .required),
        .init(name: "event_type", type: .string, mode: .required),
        .init(name: "event_timestamp", type: .timestamp, mode: .required),
        .init(name: "user_id", type: .string),
        .init(name: "properties", type: .json)
    ]),
    partitioning: GoogleCloudBigQueryTable.Partitioning(
        type: .day,
        field: "event_timestamp",
        expirationMs: 31536000000 // 365 days
    ),
    clustering: GoogleCloudBigQueryTable.Clustering(
        fields: ["event_type", "user_id"]
    )
)

print(eventsTable.createCommand(schemaFile: "schema.json"))
print(eventsTable.tableReference)  // my-project:analytics.events
```

**Running Queries:**

```swift
// Create a query job
let queryJob = GoogleCloudBigQueryJob(
    projectID: "my-project",
    location: "US",
    query: "SELECT event_type, COUNT(*) as count FROM `my-project.analytics.events` GROUP BY event_type",
    maximumBytesBilled: 10737418240 // 10GB limit
)

print(queryJob.queryCommand)

// Query with destination table
let etlJob = GoogleCloudBigQueryJob(
    projectID: "my-project",
    query: "SELECT * FROM source_table WHERE date = CURRENT_DATE()",
    destinationTable: "my-project:analytics.daily_snapshot",
    writeDisposition: .writeTruncate
)
```

**Creating Views:**

```swift
let dailySummary = GoogleCloudBigQueryView(
    viewID: "daily_event_counts",
    datasetID: "analytics",
    projectID: "my-project",
    query: """
    SELECT
        DATE(event_timestamp) as event_date,
        event_type,
        COUNT(*) as event_count,
        COUNT(DISTINCT user_id) as unique_users
    FROM `my-project.analytics.events`
    GROUP BY event_date, event_type
    """,
    description: "Daily event aggregation"
)

print(dailySummary.createCommand)
```

**Data Operations:**

```swift
// Load data from Cloud Storage
let loadCmd = BigQueryOperations.loadFromGCSCommand(
    sourceURI: "gs://my-bucket/data/*.csv",
    destinationTable: "my-project:analytics.raw_events",
    sourceFormat: .csv,
    writeDisposition: .writeAppend,
    autodetect: true
)

// Export table to Cloud Storage
let exportCmd = BigQueryOperations.exportToGCSCommand(
    sourceTable: "my-project:analytics.events",
    destinationURI: "gs://my-bucket/export/*.parquet",
    format: .avro
)

// Dry run to estimate query cost
let dryRunCmd = BigQueryOperations.dryRunCommand(
    query: "SELECT * FROM big_table"
)

// Preview table data
let previewCmd = BigQueryOperations.previewCommand(
    table: "my-project:analytics.events",
    maxRows: 25
)
```

**DAIS BigQuery Templates:**

```swift
// Create analytics dataset with best practices
let analyticsDataset = DAISBigQueryTemplate.analyticsDataset(
    projectID: "my-project",
    deploymentName: "dais-prod",
    location: "US"
)

// Create logs dataset with automatic expiration
let logsDataset = DAISBigQueryTemplate.logsDataset(
    projectID: "my-project",
    deploymentName: "dais-prod",
    expirationDays: 90
)

// Create events table with partitioning and clustering
let eventsTable = DAISBigQueryTemplate.eventsTable(
    projectID: "my-project",
    datasetID: "dais_prod_analytics",
    deploymentName: "dais-prod"
)

// Create aggregation view
let dailyView = DAISBigQueryTemplate.dailyAggregationView(
    projectID: "my-project",
    datasetID: "dais_prod_analytics",
    deploymentName: "dais-prod"
)

// Generate complete setup script
let script = DAISBigQueryTemplate.setupScript(
    projectID: "my-project",
    deploymentName: "dais-prod",
    location: "US"
)
```

**Supported Data Types:**

| Category | Types |
|----------|-------|
| Numeric | `INTEGER`, `INT64`, `FLOAT`, `FLOAT64`, `NUMERIC`, `BIGNUMERIC` |
| String | `STRING`, `BYTES` |
| Boolean | `BOOLEAN`, `BOOL` |
| Date/Time | `DATE`, `TIME`, `DATETIME`, `TIMESTAMP` |
| Complex | `RECORD`, `STRUCT`, `JSON`, `GEOGRAPHY` |

**Partitioning Options:**

| Type | Description |
|------|-------------|
| `DAY` | Daily partitions (default) |
| `HOUR` | Hourly partitions |
| `MONTH` | Monthly partitions |
| `YEAR` | Yearly partitions |

### GoogleCloudSpannerInstance (Cloud Spanner API)

Cloud Spanner is a globally distributed, horizontally scalable relational database:

```swift
// Create a Spanner instance with processing units (for development)
let devInstance = GoogleCloudSpannerInstance(
    name: "my-instance",
    projectID: "my-project",
    displayName: "My Spanner Instance",
    config: "regional-us-central1",
    processingUnits: 100,
    labels: ["environment": "development"]
)

print(devInstance.createCommand)
print(devInstance.resourceName)  // projects/my-project/instances/my-instance
```

**Production Instance with Nodes:**

```swift
// Create a production instance with nodes (1 node = 1000 processing units)
let prodInstance = GoogleCloudSpannerInstance(
    name: "prod-instance",
    projectID: "my-project",
    displayName: "Production Instance",
    config: GoogleCloudSpannerInstanceConfig.nam3,  // Multi-region
    nodeCount: 3,
    labels: ["environment": "production"]
)
```

**Databases:**

```swift
// Create a database with schema
let database = GoogleCloudSpannerDatabase(
    name: "my-db",
    instanceName: "my-instance",
    projectID: "my-project",
    ddl: [
        "CREATE TABLE users (user_id STRING(36) NOT NULL, name STRING(255)) PRIMARY KEY (user_id)",
        "CREATE INDEX users_by_name ON users (name)"
    ],
    enableDropProtection: true
)

print(database.createCommand)
print(database.resourceName)  // projects/my-project/instances/my-instance/databases/my-db

// Execute SQL
print(database.executeSqlCommand(sql: "SELECT * FROM users"))

// Update schema
print(database.updateDdlCommand(statements: ["ALTER TABLE users ADD COLUMN email STRING(255)"]))
```

**PostgreSQL-Compatible Database:**

```swift
let pgDatabase = GoogleCloudSpannerDatabase(
    name: "my-pg-db",
    instanceName: "my-instance",
    projectID: "my-project",
    databaseDialect: .postgresql
)
```

**Backups:**

```swift
// Create a backup with expiration date
let backup = GoogleCloudSpannerBackup(
    name: "daily-backup",
    instanceName: "my-instance",
    projectID: "my-project",
    databaseName: "my-db"
)

print(backup.createCommand(expirationDate: "2024-12-31"))
print(backup.createCommandWithRetention(retentionPeriod: "7d"))

// Restore from backup
print(backup.restoreCommand(newDatabaseName: "restored-db"))
```

**Spanner Operations:**

```swift
// Query execution
print(SpannerOperations.queryCommand(
    database: "my-db",
    instance: "my-instance",
    projectID: "my-project",
    sql: "SELECT * FROM users WHERE status = 'active'"
))

// Get database DDL
print(SpannerOperations.getDdlCommand(
    database: "my-db",
    instance: "my-instance",
    projectID: "my-project"
))

// List instance configs
print(GoogleCloudSpannerInstanceConfig.listCommand(projectID: "my-project"))

// Enable API
print(SpannerOperations.enableAPICommand)
```

**DAIS Spanner Templates:**

```swift
let template = DAISSpannerTemplate(
    projectID: "my-project",
    instanceName: "dais-spanner",
    databaseName: "dais-db"
)

// Development instance (100 processing units)
let devInstance = template.developmentInstance

// Production instance (multi-region, 3 nodes)
let prodInstance = template.productionInstance

// Database with DAIS schema
let mainDb = template.mainDatabase

// PostgreSQL-compatible database
let pgDb = template.postgresDatabase

// Setup script
print(template.setupScript)
```

**Instance Configuration Options:**

| Config | Description |
|--------|-------------|
| `regional-us-central1` | Single region (Iowa) |
| `regional-us-east1` | Single region (S. Carolina) |
| `nam3` | Multi-region (Iowa, Virginia, Oregon) |
| `nam6` | Multi-region (6 US regions) |
| `eur3` | Multi-region (Belgium, London, Finland) |

### GoogleCloudFirestoreDatabase (Firestore API)

Firestore is a flexible, scalable NoSQL cloud database:

```swift
// Create a Firestore database (default)
let database = GoogleCloudFirestoreDatabase(
    projectID: "my-project",
    locationID: "nam5",  // Multi-region United States
    type: .firestoreNative,
    pointInTimeRecoveryEnablement: .pointInTimeRecoveryEnabled,
    deleteProtectionState: .deleteProtectionEnabled
)

print(database.createCommand)
print(database.resourceName)  // projects/my-project/databases/(default)
```

**Named Databases:**

```swift
// Create a named database (for multi-database projects)
let namedDatabase = GoogleCloudFirestoreDatabase(
    name: "analytics-db",
    projectID: "my-project",
    locationID: "us-east1"
)

print(namedDatabase.createCommand)  // Includes --database=analytics-db
```

**Datastore Mode:**

```swift
// Create a database in Datastore mode for legacy compatibility
let datastoreDb = GoogleCloudFirestoreDatabase(
    name: "legacy-db",
    projectID: "my-project",
    locationID: "nam5",
    type: .datastoreMode
)
```

**Composite Indexes:**

```swift
// Create a composite index
let index = GoogleCloudFirestoreIndex(
    collectionGroup: "users",
    projectID: "my-project",
    queryScope: .collection,
    fields: [
        GoogleCloudFirestoreIndex.IndexField(fieldPath: "status", order: .ascending),
        GoogleCloudFirestoreIndex.IndexField(fieldPath: "createdAt", order: .descending)
    ]
)

print(index.createCommand)

// Collection group index for subcollections
let collectionGroupIndex = GoogleCloudFirestoreIndex(
    collectionGroup: "events",
    projectID: "my-project",
    queryScope: .collectionGroup,
    fields: [
        GoogleCloudFirestoreIndex.IndexField(fieldPath: "timestamp", order: .descending)
    ]
)
```

**Export and Import:**

```swift
// Export data to Cloud Storage
let export = GoogleCloudFirestoreExport(
    projectID: "my-project",
    outputUriPrefix: "gs://my-bucket/firestore-exports/2024-01-01",
    collectionIds: ["users", "orders"]  // Optional: specific collections
)

print(export.exportCommand)

// Import data from Cloud Storage
let importOp = GoogleCloudFirestoreImport(
    projectID: "my-project",
    inputUriPrefix: "gs://my-bucket/firestore-exports/2024-01-01",
    collectionIds: ["users"]
)

print(importOp.importCommand)
```

**Firestore Operations:**

```swift
// Enable API
print(FirestoreOperations.enableAPICommand)

// List operations
print(FirestoreOperations.listOperationsCommand(projectID: "my-project"))

// Start local emulator
print(FirestoreOperations.startEmulatorCommand(port: 8080, projectID: "demo-project"))
```

**DAIS Firestore Templates:**

```swift
let template = DAISFirestoreTemplate(
    projectID: "my-project",
    location: FirestoreLocation.nam5
)

// Main database with PITR and delete protection
let mainDb = template.mainDatabase

// Analytics database (no PITR for cost savings)
let analyticsDb = template.analyticsDatabase

// Indexes for common DAIS queries
let agentIndex = template.agentsByStatusIndex
let taskIndex = template.tasksByAgentIndex
let eventIndex = template.eventsCollectionGroupIndex

// Daily export configuration
let backup = template.dailyExport(bucketName: "my-backup-bucket")

// Setup script
print(template.setupScript)
```

**Firestore Locations:**

| Location | Description |
|----------|-------------|
| `nam5` | Multi-region United States |
| `eur3` | Multi-region Europe |
| `us-east1` | South Carolina |
| `europe-west1` | Belgium |
| `asia-northeast1` | Tokyo |

### GoogleCloudVertexAIModel (Vertex AI API)

Vertex AI is Google Cloud's unified machine learning platform:

```swift
// Upload a model with custom container
let model = GoogleCloudVertexAIModel(
    name: "my-model",
    projectID: "my-project",
    location: "us-central1",
    displayName: "My Custom Model",
    artifactUri: "gs://my-bucket/models/v1",
    containerSpec: GoogleCloudVertexAIModel.ContainerSpec(
        imageUri: VertexAIOperations.PredictionContainers.pytorchCpu,
        predictRoute: "/predict",
        healthRoute: "/health"
    )
)

print(model.uploadCommand)
print(model.resourceName)  // projects/my-project/locations/us-central1/models/my-model
```

**Endpoints for Serving:**

```swift
// Create a prediction endpoint
let endpoint = GoogleCloudVertexAIEndpoint(
    name: "prediction-endpoint",
    projectID: "my-project",
    location: "us-central1",
    displayName: "Production Endpoint",
    labels: ["env": "production"]
)

print(endpoint.createCommand)

// Deploy a model to the endpoint
print(endpoint.deployModelCommand(
    modelID: "123456789",
    machineType: "n1-standard-4",
    minReplicaCount: 1,
    maxReplicaCount: 5
))

// Make predictions
print(endpoint.predictCommand(jsonRequest: "{\"instances\": [[1,2,3]]}"))
```

**Custom Training Jobs:**

```swift
// Create a custom training job
let job = GoogleCloudVertexAICustomJob(
    name: "training-job",
    projectID: "my-project",
    location: "us-central1",
    displayName: "Model Training",
    workerPoolSpecs: [
        GoogleCloudVertexAICustomJob.WorkerPoolSpec(
            machineSpec: GoogleCloudVertexAICustomJob.WorkerPoolSpec.MachineSpec(
                machineType: "n1-standard-8",
                acceleratorType: VertexAIOperations.AcceleratorTypes.nvidiaT4,
                acceleratorCount: 1
            ),
            replicaCount: 1
        )
    ],
    serviceAccount: "ml-sa@my-project.iam.gserviceaccount.com"
)

// Run with container
print(job.runContainerCommand(
    imageUri: VertexAIOperations.TrainingContainers.pytorchGpu,
    machineType: "n1-standard-8"
))

// Run with Python package
print(job.runPythonCommand(
    executorImage: VertexAIOperations.TrainingContainers.pytorchGpu,
    packageUri: "gs://my-bucket/packages/trainer-0.1.tar.gz",
    module: "trainer.task"
))
```

**Datasets:**

```swift
// Create a dataset
let dataset = GoogleCloudVertexAIDataset(
    name: "training-data",
    projectID: "my-project",
    location: "us-central1",
    displayName: "Training Dataset",
    labels: ["version": "v1"]
)

print(dataset.createCommand)
print(GoogleCloudVertexAIDataset.listCommand(projectID: "my-project", location: "us-central1"))
```

**Pre-built Containers:**

```swift
// Training containers
VertexAIOperations.TrainingContainers.pytorchGpu    // PyTorch with GPU
VertexAIOperations.TrainingContainers.tensorflowGpu // TensorFlow with GPU
VertexAIOperations.TrainingContainers.scikitLearn   // Scikit-learn
VertexAIOperations.TrainingContainers.xgboost       // XGBoost

// Prediction containers
VertexAIOperations.PredictionContainers.pytorchCpu  // PyTorch serving
VertexAIOperations.PredictionContainers.tensorflowCpu // TensorFlow Serving
```

**DAIS Vertex AI Templates:**

```swift
let template = DAISVertexAITemplate(
    projectID: "my-project",
    location: "us-central1",
    serviceAccount: "ml@my-project.iam.gserviceaccount.com"
)

// Prediction endpoint
let endpoint = template.predictionEndpoint

// Training dataset
let dataset = template.trainingDataset

// Custom training job with GPU
let job = template.customTrainingJob

// Model with artifact
let model = template.daisModel(artifactUri: "gs://bucket/model")

// Setup script
print(template.setupScript)
```

**Machine Types and Accelerators:**

| Machine Type | Description |
|-------------|-------------|
| `n1-standard-4` | 4 vCPUs, 15 GB memory |
| `n1-standard-8` | 8 vCPUs, 30 GB memory |
| `n1-highmem-16` | 16 vCPUs, 104 GB memory |
| `a2-highgpu-1g` | 12 vCPUs, 85 GB, 1x A100 GPU |

| Accelerator | Description |
|-------------|-------------|
| `NVIDIA_TESLA_T4` | Cost-effective GPU |
| `NVIDIA_TESLA_V100` | High-performance GPU |
| `NVIDIA_TESLA_A100` | Latest generation GPU |
| `NVIDIA_L4` | Inference-optimized GPU |

### GoogleCloudTraceSpan (Cloud Trace API)

Cloud Trace is a distributed tracing system for collecting latency data:

```swift
// Create a trace span
let span = GoogleCloudTraceSpan(
    traceID: "abc123def456",
    spanID: "span789",
    projectID: "my-project",
    displayName: "ProcessRequest",
    parentSpanID: "parent123",
    status: GoogleCloudTraceSpan.SpanStatus(code: .ok),
    attributes: ["http.method": "GET", "http.status_code": "200"]
)

print(span.resourceName)  // projects/my-project/traces/abc123def456/spans/span789
print(span.traceResourceName)  // projects/my-project/traces/abc123def456
```

**Querying Traces:**

```swift
// List traces
print(GoogleCloudTraceSpan.listTracesCommand(projectID: "my-project"))

// List with filter
print(GoogleCloudTraceSpan.listTracesCommand(
    projectID: "my-project",
    filter: "latency:>1s",
    limit: 100
))

// Describe a specific trace
print(GoogleCloudTraceSpan.describeTraceCommand(
    traceID: "abc123def456",
    projectID: "my-project"
))
```

**Trace Sinks for Export:**

```swift
// Create a trace sink to export to BigQuery
let sink = GoogleCloudTraceSink(
    name: "analytics-sink",
    projectID: "my-project",
    destination: "bigquery.googleapis.com/projects/my-project/datasets/traces"
)

print(sink.resourceName)
print(sink.createAPICommand)
```

**Trace Analysis Filters:**

```swift
// High latency analysis
let latencyFilter = TraceAnalysis.latencyAnalysisFilter(
    serviceName: "api-server",
    minLatencyMs: 1000
)

// Error trace filter
let errorFilter = TraceAnalysis.errorTraceFilter(serviceName: "api-server")

// HTTP method filter
let httpFilter = TraceAnalysis.httpMethodFilter(method: "POST")

// HTTP status code filter
let statusFilter = TraceAnalysis.httpStatusFilter(statusCode: 500)
```

**Trace Headers:**

```swift
// W3C Trace Context header
let w3cHeader = TraceOperations.w3cTraceContextHeader(
    traceID: "abc123",
    spanID: "span456",
    sampled: true
)
// Output: traceparent: 00-abc123-span456-01

// Google Cloud Trace header
let googleHeader = TraceOperations.googleTraceHeader(
    traceID: "abc123",
    spanID: "span456",
    sampled: true
)
// Output: X-Cloud-Trace-Context: abc123/span456;o=1
```

**OpenTelemetry Integration:**

```swift
let otelConfig = OpenTelemetryTraceConfig(
    projectID: "my-project",
    serviceName: "my-service",
    serviceVersion: "1.0.0",
    environment: "production"
)

// Get environment variables for OpenTelemetry
let envVars = otelConfig.environmentVariables
// OTEL_SERVICE_NAME=my-service
// OTEL_TRACES_EXPORTER=otlp
// GOOGLE_CLOUD_PROJECT=my-project

// Generate docker run command
print(otelConfig.dockerRunCommand(image: "my-image:latest"))
```

**DAIS Trace Templates:**

```swift
let template = DAISTraceTemplate(
    projectID: "my-project",
    serviceName: "dais-api",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)

// OpenTelemetry configuration
let otelConfig = template.openTelemetryConfig

// Trace configuration with recommended settings
let traceConfig = template.traceConfig  // 10% sampling for production

// BigQuery sink for trace analytics
let sink = template.bigQuerySink(datasetID: "trace_analytics")

// Pre-built filters
let highLatencyFilter = template.highLatencyFilter
let errorFilter = template.errorFilter

// Setup script
print(template.setupScript)
```

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/cloudtrace.admin` | Full access to Cloud Trace |
| `roles/cloudtrace.agent` | Write traces |
| `roles/cloudtrace.user` | Read traces |

### GoogleCloudProfilerProfile (Cloud Profiler API)

Cloud Profiler is a continuous profiling tool for analyzing application performance:

```swift
// Create a profiler profile reference
let profile = GoogleCloudProfilerProfile(
    name: "profile-abc123",
    projectID: "my-project",
    profileType: .cpu,
    deployment: GoogleCloudProfilerProfile.Deployment(
        projectID: "my-project",
        target: "api-server",
        labels: ["env": "production"]
    ),
    duration: "60s"
)

print(profile.resourceName)  // projects/my-project/profiles/profile-abc123
```

**Profiler Agent Configuration:**

```swift
// Configure the profiler agent
let config = GoogleCloudProfilerAgentConfig(
    projectID: "my-project",
    service: "my-api",
    serviceVersion: "1.0.0",
    zone: "us-central1-a",
    cpuProfilingEnabled: true,
    heapProfilingEnabled: true,
    allocationProfilingEnabled: false,
    mutexProfilingEnabled: false
)

// Get environment variables
let envVars = config.environmentVariables
// GOOGLE_CLOUD_PROJECT=my-project
// GAE_SERVICE=my-api
// GAE_VERSION=1.0.0

// Docker run with profiler
print(config.dockerRunCommand(image: "my-image:latest"))
```

**Profiler Operations:**

```swift
// Enable API
print(ProfilerOperations.enableAPICommand)

// List profiles
print(ProfilerOperations.listProfilesCommand(projectID: "my-project"))

// Get a specific profile
print(ProfilerOperations.getProfileCommand(projectID: "my-project", profileName: "profile-123"))

// Delete a profile
print(ProfilerOperations.deleteProfileCommand(projectID: "my-project", profileName: "profile-123"))
```

**Language-Specific Configurations:**

```swift
// Go profiler
let goConfig = ProfilerLanguageConfig.Go(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(goConfig.initCode)  // Go initialization code

// Python profiler
let pythonConfig = ProfilerLanguageConfig.Python(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(pythonConfig.initCode)

// Node.js profiler
let nodeConfig = ProfilerLanguageConfig.NodeJS(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(nodeConfig.initCode)

// Java profiler
let javaConfig = ProfilerLanguageConfig.Java(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(javaConfig.jvmArgument)
print(javaConfig.dockerfileSnippet)
```

**Profiler Query:**

```swift
// Query profiles
let query = GoogleCloudProfilerQuery(
    projectID: "my-project",
    profileType: .cpu,
    service: "api-server",
    version: "2.0.0"
)

print(query.queryString)
```

**DAIS Profiler Templates:**

```swift
let template = DAISProfilerTemplate(
    projectID: "my-project",
    service: "dais-api",
    serviceVersion: "1.0.0",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)

// Agent configuration
let agentConfig = template.agentConfig

// Language-specific configs
let goConfig = template.goConfig
let pythonConfig = template.pythonConfig
let nodeConfig = template.nodeJSConfig
let javaConfig = template.javaConfig

// Query for recent profiles
let query = template.recentProfilesQuery

// Setup script
print(template.setupScript)
```

**Profile Types:**

| Type | Description |
|------|-------------|
| `CPU` | CPU time profiling |
| `HEAP` | Heap memory profiling |
| `HEAP_ALLOC` | Heap allocation profiling |
| `THREADS` | Thread profiling |
| `CONTENTION` | Lock contention profiling |
| `PEAK_HEAP` | Peak heap usage |
| `WALL` | Wall-clock time profiling |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/cloudprofiler.agent` | Write profiles |
| `roles/cloudprofiler.user` | View profiles |

### GoogleCloudErrorEvent (Cloud Error Reporting API)

Cloud Error Reporting collects and analyzes errors from your applications:

```swift
// Create an error event
let event = GoogleCloudErrorEvent(
    projectID: "my-project",
    serviceContext: GoogleCloudErrorEvent.ServiceContext(
        service: "api-server",
        version: "1.0.0"
    ),
    message: "NullPointerException: Cannot invoke method on null object",
    context: GoogleCloudErrorEvent.ErrorContext(
        httpRequest: GoogleCloudErrorEvent.ErrorContext.HTTPRequestContext(
            method: "POST",
            url: "/api/users",
            responseStatusCode: 500
        ),
        user: "user123",
        reportLocation: GoogleCloudErrorEvent.ErrorContext.ReportLocation(
            filePath: "src/handlers/users.go",
            lineNumber: 142,
            functionName: "CreateUser"
        )
    )
)

print(event.reportCommand)
```

**Error Groups:**

```swift
// Manage error groups
let group = GoogleCloudErrorGroup(
    name: "error-group-1",
    projectID: "my-project",
    groupID: "abc123",
    resolutionStatus: .open
)

print(group.resourceName)  // projects/my-project/groups/abc123
print(group.getCommand)

// Update resolution status
print(group.updateResolutionCommand(status: .resolved))
```

**Error Reporting Operations:**

```swift
// Enable API
print(ErrorReportingOperations.enableAPICommand)

// List error groups
print(ErrorReportingOperations.listGroupsCommand(projectID: "my-project"))

// List with filters
print(ErrorReportingOperations.listGroupsCommand(
    projectID: "my-project",
    service: "api-server",
    timeRange: ErrorReportingOperations.TimeRanges.period1Day
))

// List events for a group
print(ErrorReportingOperations.listEventsCommand(
    projectID: "my-project",
    groupID: "abc123"
))

// Delete all events
print(ErrorReportingOperations.deleteEventsCommand(projectID: "my-project"))
```

**Language-Specific Configurations:**

```swift
// Go error reporting
let goConfig = ErrorReportingLanguageConfig.Go(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(goConfig.initCode)

// Python error reporting
let pythonConfig = ErrorReportingLanguageConfig.Python(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(pythonConfig.initCode)

// Node.js error reporting
let nodeConfig = ErrorReportingLanguageConfig.NodeJS(
    projectID: "my-project",
    service: "my-service",
    serviceVersion: "1.0.0"
)
print(nodeConfig.initCode)
```

**DAIS Error Reporting Templates:**

```swift
let template = DAISErrorReportingTemplate(
    projectID: "my-project",
    service: "dais-api",
    serviceVersion: "1.0.0",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)

// Create error event
let event = template.errorEvent(message: "Error occurred")

// Language configs
let goConfig = template.goConfig
let pythonConfig = template.pythonConfig

// List errors
print(template.listErrorsCommand)

// Setup script
print(template.setupScript)
```

**Resolution Status:**

| Status | Description |
|--------|-------------|
| `OPEN` | Error is active |
| `ACKNOWLEDGED` | Error has been seen |
| `RESOLVED` | Error has been fixed |
| `MUTED` | Error is suppressed |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/errorreporting.admin` | Full access |
| `roles/errorreporting.user` | View and manage errors |
| `roles/errorreporting.viewer` | View errors |
| `roles/errorreporting.writer` | Write errors |

### GoogleCloudBigtableInstance (Cloud Bigtable API)

Cloud Bigtable is a wide-column NoSQL database for large analytical and operational workloads:

```swift
// Create a production Bigtable instance
let instance = GoogleCloudBigtableInstance(
    name: "my-bigtable",
    projectID: "my-project",
    displayName: "My Bigtable Instance",
    instanceType: .production,
    labels: ["env": "production"]
)

print(instance.resourceName)  // projects/my-project/instances/my-bigtable
print(instance.createCommand(clusterID: "cluster-1", zone: "us-central1-a", numNodes: 3))
```

**Development Instance:**

```swift
// Development instances don't require node count
let devInstance = GoogleCloudBigtableInstance(
    name: "dev-bigtable",
    projectID: "my-project",
    displayName: "Dev Instance",
    instanceType: .development
)

print(devInstance.createCommand(clusterID: "dev-cluster", zone: "us-central1-a"))
```

**Bigtable Clusters:**

```swift
// Create a cluster within an instance
let cluster = GoogleCloudBigtableCluster(
    name: "cluster-1",
    projectID: "my-project",
    instanceID: "my-bigtable",
    zone: "us-central1-a",
    serveNodes: 5,
    storageType: .ssd
)

print(cluster.resourceName)  // projects/my-project/instances/my-bigtable/clusters/cluster-1
print(cluster.createCommand(numNodes: 5))
print(cluster.updateCommand(numNodes: 10))  // Scale up
```

**Bigtable Tables:**

```swift
// Create a table with column families
let table = GoogleCloudBigtableTable(
    name: "events",
    projectID: "my-project",
    instanceID: "my-bigtable",
    columnFamilies: ["metrics", "metadata", "raw"]
)

print(table.resourceName)  // projects/my-project/instances/my-bigtable/tables/events
print(table.createCommand)

// Add column family
print(table.addColumnFamilyCommand(family: "new-cf", maxVersions: 5))

// Read rows with prefix
print(table.readCommand(prefix: "user#", limit: 100))
```

**Bigtable Backups:**

```swift
// Create and restore backups
let backup = GoogleCloudBigtableBackup(
    name: "daily-backup",
    projectID: "my-project",
    instanceID: "my-bigtable",
    clusterID: "cluster-1",
    sourceTable: "events"
)

print(backup.resourceName)
print(backup.createCommand(expireDays: 30))
print(backup.restoreCommand(targetTable: "events-restored"))
```

**App Profiles:**

```swift
// Multi-cluster routing (automatic failover)
let defaultProfile = GoogleCloudBigtableAppProfile(
    name: "default-profile",
    projectID: "my-project",
    instanceID: "my-bigtable",
    routingPolicy: .multiClusterRouting
)

// Single-cluster routing (for transactions)
let transactionalProfile = GoogleCloudBigtableAppProfile(
    name: "transactional-profile",
    projectID: "my-project",
    instanceID: "my-bigtable",
    routingPolicy: .singleClusterRouting(clusterID: "cluster-1", allowTransactionalWrites: true)
)

print(defaultProfile.createCommand)
print(transactionalProfile.createCommand)
```

**Bigtable Operations:**

```swift
// Enable API
print(BigtableOperations.enableAPICommand)

// Install cbt CLI tool
print(BigtableOperations.installCBTCommand)

// Grant roles
print(BigtableOperations.addAdminRoleCommand(projectID: "my-project", member: "user:admin@example.com"))
print(BigtableOperations.addUserRoleCommand(projectID: "my-project", serviceAccount: "sa@my-project.iam.gserviceaccount.com"))
```

**DAIS Bigtable Templates:**

```swift
let template = DAISBigtableTemplate(
    projectID: "my-project",
    instanceName: "dais-bigtable",
    zone: "us-central1-a",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)

// Production and dev instances
let prodInstance = template.productionInstance
let devInstance = template.developmentInstance

// Pre-configured tables
let timeSeriesTable = template.timeSeriesTable  // metrics, events, metadata
let entitiesTable = template.entitiesTable      // profile, activity, preferences

// App profiles
let defaultProfile = template.defaultAppProfile
let txProfile = template.transactionalAppProfile(clusterID: "dais-bigtable-c1")

// Setup and teardown scripts
print(template.setupScript)
print(template.teardownScript)
```

**Instance Types:**

| Type | Description |
|------|-------------|
| `PRODUCTION` | Multi-node for production workloads |
| `DEVELOPMENT` | Single-node for development (no SLA) |

**Storage Types:**

| Type | Description |
|------|-------------|
| `SSD` | Solid-state drive (lower latency) |
| `HDD` | Hard disk drive (lower cost) |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/bigtable.admin` | Full access to instances |
| `roles/bigtable.user` | Read/write to tables |
| `roles/bigtable.reader` | Read-only access |
| `roles/bigtable.viewer` | View metadata only |

### GoogleCloudDataprocCluster (Dataproc API)

Cloud Dataproc is a managed Spark and Hadoop service for batch processing and analytics:

```swift
// Create a Dataproc cluster
let cluster = GoogleCloudDataprocCluster(
    name: "analytics-cluster",
    projectID: "my-project",
    region: "us-central1",
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
            machineType: "n1-standard-4"
        ),
        softwareConfig: GoogleCloudDataprocCluster.SoftwareConfig(
            imageVersion: "2.1-debian11",
            optionalComponents: [.jupyter, .zeppelin]
        )
    ),
    labels: ["env": "production"]
)

print(cluster.resourceName)  // projects/my-project/regions/us-central1/clusters/analytics-cluster
print(cluster.createCommand)
print(cluster.updateCommand(numWorkers: 5))  // Scale workers
```

**Spot/Preemptible Workers:**

```swift
// Add spot workers for cost savings
let batchCluster = GoogleCloudDataprocCluster(
    name: "batch-cluster",
    projectID: "my-project",
    region: "us-central1",
    clusterConfig: GoogleCloudDataprocCluster.ClusterConfig(
        masterConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(numInstances: 1),
        workerConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(numInstances: 2),
        secondaryWorkerConfig: GoogleCloudDataprocCluster.InstanceGroupConfig(
            numInstances: 10,
            machineType: "n1-standard-4",
            preemptibility: .spot
        )
    )
)

print(batchCluster.createCommand)
```

**Dataproc Jobs:**

```swift
// Submit a Spark job
let sparkJob = GoogleCloudDataprocJob(
    projectID: "my-project",
    region: "us-central1",
    clusterName: "analytics-cluster",
    jobType: .spark,
    mainClass: "com.example.analytics.MainJob",
    jarFiles: ["gs://my-bucket/analytics.jar"],
    args: ["--input", "gs://my-bucket/data", "--output", "gs://my-bucket/results"],
    properties: [
        "spark.executor.memory": "4g",
        "spark.driver.memory": "2g"
    ]
)

print(sparkJob.submitCommand)

// Submit a PySpark job
let pysparkJob = GoogleCloudDataprocJob(
    projectID: "my-project",
    region: "us-central1",
    clusterName: "analytics-cluster",
    jobType: .pyspark,
    mainFile: "gs://my-bucket/scripts/etl_job.py",
    pyFiles: ["gs://my-bucket/scripts/utils.py"]
)

print(pysparkJob.submitCommand)

// Job management
print(GoogleCloudDataprocJob.describeCommand(projectID: "my-project", region: "us-central1", jobID: "job-123"))
print(GoogleCloudDataprocJob.cancelCommand(projectID: "my-project", region: "us-central1", jobID: "job-123"))
```

**Serverless Batches:**

```swift
// Submit a serverless batch (no cluster required)
let batch = GoogleCloudDataprocBatch(
    batchID: "etl-batch-001",
    projectID: "my-project",
    region: "us-central1",
    batchType: .pyspark,
    mainFile: "gs://my-bucket/scripts/batch_job.py",
    runtimeConfig: GoogleCloudDataprocBatch.RuntimeConfig(version: "2.0")
)

print(batch.resourceName)
print(batch.submitCommand)
print(batch.describeCommand)
```

**Workflow Templates:**

```swift
// Create workflow template
let workflow = GoogleCloudDataprocWorkflowTemplate(
    name: "daily-etl",
    projectID: "my-project",
    region: "us-central1"
)

print(workflow.createFromFileCommand(filePath: "workflow.yaml"))
print(workflow.instantiateCommand)
```

**Autoscaling Policies:**

```swift
let policy = GoogleCloudDataprocAutoscalingPolicy(
    name: "scale-policy",
    projectID: "my-project",
    region: "us-central1",
    workerConfig: GoogleCloudDataprocAutoscalingPolicy.InstanceGroupAutoscalingConfig(
        minInstances: 2,
        maxInstances: 10
    ),
    secondaryWorkerConfig: GoogleCloudDataprocAutoscalingPolicy.InstanceGroupAutoscalingConfig(
        minInstances: 0,
        maxInstances: 20
    )
)

print(policy.resourceName)
```

**Dataproc Operations:**

```swift
// Enable API
print(DataprocOperations.enableAPICommand)

// Grant roles
print(DataprocOperations.addAdminRoleCommand(projectID: "my-project", member: "user:admin@example.com"))

// SSH to cluster master
print(DataprocOperations.sshCommand(projectID: "my-project", region: "us-central1", clusterName: "my-cluster", zone: "us-central1-a"))

// Diagnose cluster issues
print(DataprocOperations.diagnoseCommand(projectID: "my-project", region: "us-central1", clusterName: "my-cluster"))
```

**DAIS Dataproc Templates:**

```swift
let template = DAISDataprocTemplate(
    projectID: "my-project",
    region: "us-central1",
    clusterName: "dais-dataproc",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)

// Pre-configured clusters
let analyticsCluster = template.analyticsCluster  // Standard analytics cluster
let batchCluster = template.batchProcessingCluster  // Spot workers for batch
let highMemCluster = template.highMemoryCluster  // For large datasets

// Sample jobs
let pysparkJob = template.samplePySparkJob
let sparkJob = template.sampleSparkJob

// Serverless batch
let serverlessBatch = template.serverlessBatch

// Setup and teardown
print(template.setupScript)
print(template.teardownScript)
```

**Job Types:**

| Type | Description |
|------|-------------|
| `SPARK` | Scala/Java Spark jobs |
| `PYSPARK` | Python Spark jobs |
| `SPARK_SQL` | Spark SQL queries |
| `HIVE` | Hive queries |
| `PIG` | Pig scripts |
| `HADOOP` | MapReduce jobs |
| `PRESTO` | Presto queries |

**Optional Components:**

| Component | Description |
|-----------|-------------|
| `JUPYTER` | Jupyter notebooks |
| `ZEPPELIN` | Zeppelin notebooks |
| `PRESTO` | Presto SQL engine |
| `HBASE` | HBase database |
| `FLINK` | Apache Flink |
| `DOCKER` | Docker support |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/dataproc.admin` | Full access |
| `roles/dataproc.editor` | Create and manage |
| `roles/dataproc.viewer` | View only |
| `roles/dataproc.worker` | Worker node access |

### GoogleCloudComposerEnvironment (Cloud Composer API)

Cloud Composer is a fully managed Apache Airflow service for workflow orchestration:

```swift
// Create a Composer environment
let environment = GoogleCloudComposerEnvironment(
    name: "dais-workflows",
    projectID: "my-project",
    location: "us-central1",
    config: GoogleCloudComposerEnvironment.EnvironmentConfig(
        softwareConfig: GoogleCloudComposerEnvironment.SoftwareConfig(
            imageVersion: "composer-2.9.7-airflow-2.9.3",
            airflowConfigOverrides: [
                "core-dags_are_paused_at_creation": "False",
                "webserver-dag_default_view": "graph"
            ],
            pypiPackages: [
                "google-cloud-bigquery": ">=3.0.0",
                "pandas": ">=2.0.0"
            ],
            envVariables: [
                "DAIS_ENV": "production"
            ]
        ),
        nodeConfig: GoogleCloudComposerEnvironment.NodeConfig(
            serviceAccount: "composer-sa@my-project.iam.gserviceaccount.com",
            network: "projects/my-project/global/networks/default",
            subnetwork: "projects/my-project/regions/us-central1/subnetworks/default"
        ),
        workloadsConfig: GoogleCloudComposerEnvironment.WorkloadsConfig(
            scheduler: GoogleCloudComposerEnvironment.WorkloadsConfig.SchedulerResource(
                cpu: 2.0,
                memoryGb: 7.5,
                storageGb: 5.0,
                count: 2
            ),
            webServer: GoogleCloudComposerEnvironment.WorkloadsConfig.WebServerResource(
                cpu: 2.0,
                memoryGb: 7.5,
                storageGb: 5.0
            ),
            worker: GoogleCloudComposerEnvironment.WorkloadsConfig.WorkerResource(
                cpu: 2.0,
                memoryGb: 7.5,
                storageGb: 5.0,
                minCount: 2,
                maxCount: 10
            )
        ),
        privateEnvironmentConfig: GoogleCloudComposerEnvironment.PrivateEnvironmentConfig(
            enablePrivateEnvironment: true,
            enablePrivateBuildsOnly: true
        ),
        environmentSize: .medium
    ),
    labels: ["env": "production", "managed-by": "dais"]
)

print(environment.resourceName)  // projects/my-project/locations/us-central1/environments/dais-workflows
print(environment.createCommand)
print(environment.describeCommand)
```

**Environment Management:**

```swift
// Update environment
print(environment.updateCommand(
    nodeCount: 5,
    pypiPackages: ["new-package": ">=1.0.0"]
))

// Get Airflow web UI URL
print(environment.getWebUICommand)

// List DAG runs
print(environment.listDagRunsCommand(dagID: "my_dag"))

// Trigger a DAG
print(environment.triggerDagCommand(dagID: "my_dag", runID: "manual-run-001"))
```

**DAG Templates:**

```swift
// Create DAGs for Airflow
let etlDag = GoogleCloudComposerDAG(
    dagID: "dais_etl_pipeline",
    schedule: "0 2 * * *",  // Daily at 2 AM
    defaultArgs: GoogleCloudComposerDAG.DAGDefaultArgs(
        owner: "dais-team",
        startDate: "2024-01-01",
        retries: 3,
        retryDelay: 300,
        email: ["alerts@example.com"],
        emailOnFailure: true
    ),
    catchup: false,
    tags: ["etl", "production"]
)

// Generate Python DAG file
print(etlDag.pythonTemplate)
/*
from airflow import DAG
from datetime import datetime, timedelta

default_args = {
    'owner': 'dais-team',
    'start_date': datetime(2024, 1, 1),
    'retries': 3,
    'retry_delay': timedelta(seconds=300),
    'email': ['alerts@example.com'],
    'email_on_failure': True,
}

with DAG(
    'dais_etl_pipeline',
    default_args=default_args,
    schedule_interval='0 2 * * *',
    catchup=False,
    tags=['etl', 'production'],
) as dag:
    pass  # Add tasks here
*/
```

**Composer Operations:**

```swift
// Enable API
print(ComposerOperations.enableAPICommand)

// Grant roles
print(ComposerOperations.addAdminRoleCommand(projectID: "my-project", member: "user:admin@example.com"))

// List environments
print(ComposerOperations.listEnvironmentsCommand(projectID: "my-project", location: "us-central1"))

// Run Airflow CLI command
print(ComposerOperations.airflowCommand(
    projectID: "my-project",
    location: "us-central1",
    environmentName: "dais-workflows",
    command: "dags list"
))
```

**DAIS Composer Templates:**

```swift
let template = DAISComposerTemplate(
    projectID: "my-project",
    location: "us-central1",
    environmentName: "dais-composer",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com"
)

// Pre-configured environments
let standardEnv = template.standardEnvironment
let productionEnv = template.productionEnvironment  // HA with private IP
let developmentEnv = template.developmentEnvironment  // Minimal for testing

// Sample DAGs
let sampleDAG = template.sampleDAG

// Setup and teardown scripts
print(template.setupScript)
print(template.teardownScript)
```

**Environment Sizes:**

| Size | Scheduler | Web Server | Worker | Use Case |
|------|-----------|------------|--------|----------|
| `SMALL` | 0.5 CPU, 2GB | 0.5 CPU, 2GB | 0.5 CPU, 2GB | Development |
| `MEDIUM` | 2 CPU, 7.5GB | 2 CPU, 7.5GB | 2 CPU, 7.5GB | Production |
| `LARGE` | 4 CPU, 15GB | 4 CPU, 15GB | 4 CPU, 15GB | Enterprise |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/composer.admin` | Full access to environments |
| `roles/composer.user` | Trigger DAGs, view environments |
| `roles/composer.worker` | Worker node access |
| `roles/composer.environmentAndStorageObjectAdmin` | Environment and storage access |

### GoogleCloudDocumentAIProcessor (Document AI API)

Document AI is a document understanding platform for extracting text, tables, and entities from documents:

```swift
// Create an OCR processor
let processor = GoogleCloudDocumentAIProcessor(
    name: "invoice-ocr",
    projectID: "my-project",
    location: "us",
    type: .ocrProcessor,
    displayName: "Invoice OCR Processor"
)

print(processor.resourceName)  // projects/my-project/locations/us/processors/invoice-ocr
print(processor.createCommand)
print(processor.describeCommand)

// Available processor types
let formParser = GoogleCloudDocumentAIProcessor(
    name: "form-parser",
    projectID: "my-project",
    location: "us",
    type: .formParser
)

let invoiceParser = GoogleCloudDocumentAIProcessor(
    name: "invoice-parser",
    projectID: "my-project",
    location: "us",
    type: .invoiceParser
)

let expenseParser = GoogleCloudDocumentAIProcessor(
    name: "expense-parser",
    projectID: "my-project",
    location: "us",
    type: .expenseParser
)
```

**Processor Versions:**

```swift
let version = GoogleCloudDocumentAIProcessorVersion(
    name: "pretrained-v1.0",
    processorName: "invoice-ocr",
    projectID: "my-project",
    location: "us",
    displayName: "Version 1.0",
    state: .deployed,
    modelType: .generativeAI
)

print(version.resourceName)
print(version.deployCommand)
print(version.undeployCommand)
```

**Processing Documents:**

```swift
// Process a document from GCS
let document = GoogleCloudDocument.fromGCS(
    uri: "gs://my-bucket/invoices/invoice-001.pdf",
    mimeType: .pdf
)

// Create a process request
let request = GoogleCloudDocumentAIProcessRequest(
    processorName: "invoice-ocr",
    projectID: "my-project",
    location: "us",
    document: document,
    skipHumanReview: true
)

print(request.processCommand(inputFile: "invoice.pdf"))
```

**Batch Processing:**

```swift
// Process multiple documents
let batchRequest = GoogleCloudDocumentAIProcessRequest(
    processorName: "ocr-processor",
    projectID: "my-project",
    location: "us",
    inputGcsUri: "gs://my-bucket/input/",
    outputGcsUri: "gs://my-bucket/output/",
    skipHumanReview: true
)

print(batchRequest.batchProcessCommand())
```

**Processing Results:**

```swift
// Entity extraction result
let entity = GoogleCloudDocumentAIProcessResponse.Entity(
    type: "invoice_total",
    mentionText: "$1,234.56",
    confidence: 0.95,
    normalizedValue: GoogleCloudDocumentAIProcessResponse.NormalizedValue(
        moneyValue: GoogleCloudDocumentAIProcessResponse.MoneyValue(
            currencyCode: "USD",
            units: 1234,
            nanos: 560000000
        )
    )
)

// Date extraction
let dateEntity = GoogleCloudDocumentAIProcessResponse.Entity(
    type: "invoice_date",
    mentionText: "December 15, 2024",
    confidence: 0.98,
    normalizedValue: GoogleCloudDocumentAIProcessResponse.NormalizedValue(
        dateValue: GoogleCloudDocumentAIProcessResponse.DateValue(
            year: 2024,
            month: 12,
            day: 15
        )
    )
)
```

**Document AI Operations:**

```swift
// Enable API
print(DocumentAIOperations.enableAPICommand)

// List processors
print(DocumentAIOperations.listProcessorsCommand(projectID: "my-project", location: "us"))

// List processor types
print(DocumentAIOperations.listProcessorTypesCommand(projectID: "my-project", location: "us"))

// Grant roles
print(DocumentAIOperations.addAdminRoleCommand(projectID: "my-project", member: "user:admin@example.com"))
print(DocumentAIOperations.addEditorRoleCommand(projectID: "my-project", member: "user:editor@example.com"))
```

**DAIS Document AI Template:**

```swift
let template = DAISDocumentAITemplate(
    projectID: "my-project",
    location: "us",
    processorPrefix: "dais",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com",
    documentBucket: "my-project-documents"
)

// Pre-configured processors
let ocrProcessor = template.ocrProcessor
let formParser = template.formParserProcessor
let invoiceParser = template.invoiceProcessor
let qualityChecker = template.qualityProcessor

// Process requests
let ocrRequest = template.ocrRequest(gcsUri: "gs://my-bucket/doc.pdf")
let batchRequest = template.batchProcessRequest(inputPrefix: "input/", outputPrefix: "output/")

// Setup and teardown
print(template.setupScript)
print(template.teardownScript)

// Python processing script
print(template.pythonProcessingScript)
```

**Processor Types:**

| Type | Description |
|------|-------------|
| `OCR_PROCESSOR` | General text extraction |
| `FORM_PARSER_PROCESSOR` | Form field extraction |
| `INVOICE_PROCESSOR` | Invoice parsing |
| `EXPENSE_PROCESSOR` | Expense/receipt parsing |
| `ID_PROOFING_PROCESSOR` | ID document verification |
| `W2_PROCESSOR` | W-2 form parsing |
| `1099_PROCESSOR` | 1099 form parsing |
| `BANK_STATEMENT_PROCESSOR` | Bank statement parsing |
| `CONTRACT_PROCESSOR` | Contract analysis |
| `CUSTOM_EXTRACTION_PROCESSOR` | Custom entity extraction |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/documentai.admin` | Full access to processors |
| `roles/documentai.editor` | Create and manage processors |
| `roles/documentai.viewer` | View processors only |
| `roles/documentai.apiUser` | Use processors via API |

### GoogleCloudVisionRequest (Vision AI API)

Vision AI provides powerful image analysis including object detection, face detection, OCR, and more:

```swift
// Create a label detection request
let request = GoogleCloudVisionRequest(
    projectID: "my-project",
    image: GoogleCloudVisionRequest.ImageSource.fromGCS("gs://my-bucket/image.jpg"),
    features: [
        GoogleCloudVisionRequest.Feature(type: .labelDetection, maxResults: 10),
        GoogleCloudVisionRequest.Feature(type: .faceDetection),
        GoogleCloudVisionRequest.Feature(type: .textDetection)
    ]
)

// With image context
let ocrRequest = GoogleCloudVisionRequest(
    projectID: "my-project",
    image: GoogleCloudVisionRequest.ImageSource.fromGCS("gs://my-bucket/document.jpg"),
    features: [
        GoogleCloudVisionRequest.Feature(type: .documentTextDetection)
    ],
    imageContext: GoogleCloudVisionRequest.ImageContext(
        languageHints: ["en", "es"]
    )
)

print(request.curlCommand(inputFile: "image.jpg"))
```

**Detection Results:**

```swift
// Label detection response
let response = GoogleCloudVisionResponse(
    labelAnnotations: [
        EntityAnnotation(description: "Cat", score: 0.95, topicality: 0.95),
        EntityAnnotation(description: "Animal", score: 0.90)
    ]
)

// Face detection
let faceAnnotation = FaceAnnotation(
    detectionConfidence: 0.98,
    joyLikelihood: .veryLikely,
    sorrowLikelihood: .veryUnlikely,
    angerLikelihood: .unlikely
)

// Safe search detection
let safeSearch = SafeSearchAnnotation(
    adult: .veryUnlikely,
    spoof: .unlikely,
    medical: .possible,
    violence: .veryUnlikely,
    racy: .unlikely
)
```

**Object Localization:**

```swift
let object = LocalizedObjectAnnotation(
    mid: "/m/01yrx",
    name: "Cat",
    score: 0.95,
    boundingPoly: BoundingPoly(
        normalizedVertices: [
            BoundingPoly.NormalizedVertex(x: 0.1, y: 0.1),
            BoundingPoly.NormalizedVertex(x: 0.9, y: 0.9)
        ]
    )
)

print("Object: \(object.name ?? "") at \(object.boundingPoly?.normalizedVertices ?? [])")
```

**Batch Processing:**

```swift
let batch = GoogleCloudVisionBatchRequest(
    projectID: "my-project",
    inputGcsUri: "gs://input-bucket/images/",
    outputGcsUri: "gs://output-bucket/results/",
    features: [
        GoogleCloudVisionRequest.Feature(type: .labelDetection),
        GoogleCloudVisionRequest.Feature(type: .safeSearchDetection)
    ]
)

print(batch.batchAnnotateCommand)
```

**Product Search:**

```swift
// Create product set
let productSet = GoogleCloudVisionProductSet(
    name: "my-products",
    projectID: "my-project",
    location: "us-east1",
    displayName: "My Products"
)

print(productSet.resourceName)
print(productSet.createCommand)

// Create product
let product = GoogleCloudVisionProduct(
    name: "shoes-001",
    projectID: "my-project",
    location: "us-east1",
    displayName: "Running Shoes",
    productCategory: "apparel-v2",
    productLabels: [
        GoogleCloudVisionProduct.KeyValue(key: "style", value: "running")
    ]
)

print(product.createCommand)
```

**Vision Operations:**

```swift
// Enable API
print(VisionOperations.enableAPICommand)

// Detection commands
print(VisionOperations.detectLabelsCommand(imageUri: "gs://bucket/img.jpg", projectID: "my-project"))
print(VisionOperations.detectTextCommand(imageUri: "gs://bucket/img.jpg", projectID: "my-project"))
print(VisionOperations.detectFacesCommand(imageUri: "gs://bucket/img.jpg", projectID: "my-project"))
print(VisionOperations.detectObjectsCommand(imageUri: "gs://bucket/img.jpg", projectID: "my-project"))
print(VisionOperations.safeSearchCommand(imageUri: "gs://bucket/img.jpg", projectID: "my-project"))
```

**DAIS Vision AI Template:**

```swift
let template = DAISVisionAITemplate(
    projectID: "my-project",
    location: "us-central1",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com",
    imageBucket: "my-project-images"
)

// Pre-configured requests
let labelRequest = template.labelDetectionRequest(imageUri: "gs://bucket/img.jpg")
let comprehensiveRequest = template.comprehensiveAnalysisRequest(imageUri: "gs://bucket/img.jpg")
let ocrRequest = template.ocrRequest(imageUri: "gs://bucket/doc.jpg")
let moderationRequest = template.moderationRequest(imageUri: "gs://bucket/img.jpg")

// Setup and teardown
print(template.setupScript)
print(template.teardownScript)
print(template.pythonProcessingScript)
```

**Feature Types:**

| Type | Description |
|------|-------------|
| `FACE_DETECTION` | Detect faces and emotions |
| `LANDMARK_DETECTION` | Detect famous landmarks |
| `LOGO_DETECTION` | Detect company logos |
| `LABEL_DETECTION` | General image labels |
| `TEXT_DETECTION` | OCR for sparse text |
| `DOCUMENT_TEXT_DETECTION` | OCR for dense documents |
| `SAFE_SEARCH_DETECTION` | Content moderation |
| `IMAGE_PROPERTIES` | Dominant colors |
| `CROP_HINTS` | Suggested crop regions |
| `WEB_DETECTION` | Web entity search |
| `OBJECT_LOCALIZATION` | Object detection with bounding boxes |

**IAM Roles:**

| Role | Description |
|------|-------------|
| `roles/ml.developer` | Full access to Vision API |
| `roles/ml.viewer` | Read-only access |

### GoogleCloudSpeechRecognitionRequest (Speech-to-Text API)

Speech-to-Text converts audio to text using powerful neural network models:

```swift
// Create a recognition config
let config = GoogleCloudSpeechRecognitionConfig(
    encoding: .linear16,
    sampleRateHertz: 16000,
    languageCode: "en-US",
    enableAutomaticPunctuation: true,
    enableWordTimeOffsets: true,
    model: .latest_long,
    useEnhanced: true
)

// Create a request
let request = GoogleCloudSpeechRecognitionRequest(
    projectID: "my-project",
    config: config,
    audio: GoogleCloudSpeechRecognitionAudio.fromGCS("gs://my-bucket/audio.flac")
)

print(request.recognizeCommand(audioFile: "audio.wav"))
print(request.longRunningRecognizeCommand(gcsUri: "gs://bucket/audio.flac"))
```

**Recognition Models:**

```swift
// Phone call transcription
let phoneConfig = GoogleCloudSpeechRecognitionConfig(
    encoding: .mulaw,
    sampleRateHertz: 8000,
    languageCode: "en-US",
    model: .phone_call,
    useEnhanced: true
)

// Video transcription
let videoConfig = GoogleCloudSpeechRecognitionConfig(
    encoding: .linear16,
    sampleRateHertz: 16000,
    languageCode: "en-US",
    model: .video
)

// Medical dictation
let medicalConfig = GoogleCloudSpeechRecognitionConfig(
    encoding: .linear16,
    sampleRateHertz: 16000,
    languageCode: "en-US",
    model: .medical_dictation
)
```

**Speech Adaptation:**

```swift
// Boost recognition of specific phrases
let context = GoogleCloudSpeechRecognitionConfig.SpeechContext(
    phrases: ["DAIS", "distributed AI", "agent cluster"],
    boost: 10.0
)

// Create phrase set for V2 API
let phraseSet = GoogleCloudSpeechPhraseSet(
    name: "domain-phrases",
    projectID: "my-project",
    location: "global",
    phrases: [
        GoogleCloudSpeechPhraseSet.Phrase(value: "custom term", boost: 5.0)
    ]
)

print(phraseSet.resourceName)
print(phraseSet.createCommand)
```

**V2 Recognizers:**

```swift
let recognizer = GoogleCloudSpeechRecognizer(
    name: "my-recognizer",
    projectID: "my-project",
    location: "us-central1",
    displayName: "Production Recognizer",
    model: "latest_long",
    languageCodes: ["en-US", "es-ES"]
)

print(recognizer.resourceName)
print(recognizer.createCommand)
print(recognizer.describeCommand)
```

**Speech-to-Text Operations:**

```swift
// Enable API
print(SpeechToTextOperations.enableAPICommand)

// Recognize from local file
print(SpeechToTextOperations.recognizeCommand(
    audioFile: "audio.wav",
    languageCode: "en-US",
    projectID: "my-project"
))

// Long-running recognition from GCS
print(SpeechToTextOperations.recognizeLongRunningCommand(
    gcsUri: "gs://bucket/audio.flac",
    languageCode: "en-US",
    projectID: "my-project"
))
```

**DAIS Speech-to-Text Template:**

```swift
let template = DAISSpeechToTextTemplate(
    projectID: "my-project",
    location: "global",
    serviceAccount: "sa@my-project.iam.gserviceaccount.com",
    audioBucket: "my-project-audio"
)

// Pre-configured recognition configs
let englishConfig = template.englishConfig  // Enhanced English
let phoneConfig = template.phoneCallConfig  // Phone call optimized
let videoConfig = template.videoConfig  // Video transcription
let multiLangConfig = template.multiLanguageConfig  // Multi-language

// Setup and teardown
print(template.setupScript)
print(template.teardownScript)
print(template.pythonProcessingScript)
```

**Audio Encodings:**

| Encoding | Description |
|----------|-------------|
| `LINEAR16` | Uncompressed 16-bit PCM |
| `FLAC` | Free Lossless Audio Codec |
| `MP3` | MP3 audio |
| `OGG_OPUS` | Ogg Opus |
| `MULAW` | μ-law (telephony) |
| `AMR` | Adaptive Multi-Rate |

**Recognition Models:**

| Model | Use Case |
|-------|----------|
| `latest_long` | Long-form content (podcasts, meetings) |
| `latest_short` | Short utterances |
| `phone_call` | Phone conversations |
| `video` | Video transcription |
| `medical_dictation` | Medical dictation |
| `telephony` | Telephony optimized |

### GoogleCloudTextToSpeechRequest (Text-to-Speech API)

Text-to-Speech converts text into natural-sounding speech using powerful neural network models:

```swift
// Create a basic speech synthesis request
let request = GoogleCloudTextToSpeechRequest(
    projectID: "my-project",
    input: .plainText("Hello, welcome to our application!"),
    voice: .wavenet("D"),
    audioConfig: .mp3
)

print(request.synthesizeCommand)
// gcloud ml speech synthesize-text "Hello..." --voice-name=en-US-Wavenet-D --output-file=output.mp3
```

**Voice Types:**

```swift
// Standard voices (basic quality)
let standard = GoogleCloudTextToSpeechVoice.standard("en-US-Standard-A", languageCode: "en-US")

// WaveNet voices (natural sounding)
let wavenet = GoogleCloudTextToSpeechVoice.wavenet("D")  // en-US-Wavenet-D

// Neural2 voices (highest quality)
let neural2 = GoogleCloudTextToSpeechVoice.neural2("A")  // en-US-Neural2-A

// Studio voices (professional narration)
let studio = GoogleCloudTextToSpeechVoice.studio("O")   // en-US-Studio-O

// Select by gender
let female = GoogleCloudTextToSpeechVoice.byGender(.female, languageCode: "en-US")
```

**SSML Builder:**

```swift
// Build SSML for advanced speech control
var builder = SSMLBuilder()
builder.text("Welcome to our service. ")
builder.pause(time: "500ms")
builder.emphasis("Important announcement!", level: .strong)
builder.pause(time: "300ms")
builder.prosody("Please listen carefully.", rate: "slow", pitch: "low")
builder.sayAs("12/25/2024", interpretAs: .date, format: "mdy")

let request = GoogleCloudTextToSpeechRequest(
    projectID: "my-project",
    input: .ssmlBuilder(builder),
    voice: .neural2("A"),
    audioConfig: .mp3
)
```

**Audio Configurations:**

```swift
// Pre-defined configs
let mp3Config = GoogleCloudTextToSpeechAudioConfig.mp3
let wavConfig = GoogleCloudTextToSpeechAudioConfig.wav
let telephonyConfig = GoogleCloudTextToSpeechAudioConfig.telephony  // 8kHz mulaw

// Custom config with speaking rate and pitch
let customConfig = GoogleCloudTextToSpeechAudioConfig(
    audioEncoding: .mp3,
    speakingRate: 1.2,    // 20% faster
    pitch: -2.0,          // Slightly lower pitch
    volumeGainDb: 3.0,    // Slightly louder
    sampleRateHertz: 24000
)

// Add effects profiles for specific playback devices
let podcastConfig = GoogleCloudTextToSpeechAudioConfig.mp3
    .withEffects([.headphoneClassDevice])

let ivrConfig = GoogleCloudTextToSpeechAudioConfig.telephony
    .withEffects([.telephonyClassApplication])
```

**Long Audio Synthesis:**

```swift
// For content longer than 5 minutes
let longRequest = GoogleCloudTextToSpeechLongAudioRequest(
    projectID: "my-project",
    location: "us-central1",
    input: .plainText(longArticleText),
    voice: .neural2("A"),
    audioConfig: .mp3,
    outputGcsUri: "gs://my-bucket/audiobooks/chapter1.mp3"
)
```

**Text-to-Speech Operations:**

```swift
let ops = GoogleCloudTextToSpeechOperations(projectID: "my-project")

// List available voices
print(ops.listVoicesCommand)
// gcloud ml speech list-voices --project=my-project

// List voices for a specific language
print(ops.listVoicesForLanguage("es-ES"))

// Synthesize to file
print(ops.synthesizeToFile(text: "Hello", voice: "en-US-Wavenet-D", output: "output.mp3"))

// Enable API
print(ops.enableAPICommand)
// gcloud services enable texttospeech.googleapis.com --project=my-project
```

**DAIS Text-to-Speech Template:**

```swift
let template = DAISTextToSpeechTemplate(
    projectID: "my-project",
    defaultVoice: .wavenet("D"),
    defaultAudioConfig: .mp3,
    serviceAccount: "tts-service",
    outputBucket: "tts-audio"
)

// Pre-configured voices
let male = template.americanMaleVoice       // en-US-Wavenet-D
let female = template.americanFemaleVoice   // en-US-Wavenet-F
let british = template.britishMaleVoice     // en-GB-Wavenet-B
let hq = template.neural2Voice              // en-US-Neural2-A

// Pre-configured audio for different use cases
let podcast = template.podcastAudioConfig   // MP3 @ 24kHz with headphone profile
let ivr = template.ivrAudioConfig           // mulaw @ 8kHz for phone systems
let speaker = template.smartSpeakerAudioConfig

// Quick synthesis
let request = template.synthesize("Hello world")

// Generate setup script
print(template.setupScript)
```

**Voice Types:**

| Type | Quality | Use Case |
|------|---------|----------|
| `Standard` | Basic | High-volume, cost-sensitive |
| `Wavenet` | Natural | General purpose |
| `Neural2` | Highest | Premium experiences |
| `Studio` | Professional | Narration, audiobooks |
| `Polyglot` | Multi-lingual | Code-switching content |
| `News` | Broadcast | News reading |

**Audio Encodings:**

| Encoding | Format | Use Case |
|----------|--------|----------|
| `LINEAR16` | WAV | High quality, editing |
| `MP3` | MP3 | General purpose |
| `OGG_OPUS` | Ogg | Web streaming |
| `MULAW` | μ-law | Telephony |
| `ALAW` | A-law | European telephony |

### GoogleCloudTranslationRequest (Translation API)

Cloud Translation enables dynamic text translation between over 100 languages:

```swift
// Basic translation request
let request = GoogleCloudTranslationRequest(
    projectID: "my-project",
    contents: ["Hello, how are you?"],
    targetLanguageCode: "es"  // Spanish
)

print(request.translateCommand)
// gcloud translate text "Hello, how are you?" --target-language=es --project=my-project
```

**Translation with Source Language:**

```swift
// Translate with explicit source language
let request = GoogleCloudTranslationRequest(
    projectID: "my-project",
    location: "us-central1",
    contents: ["Good morning"],
    sourceLanguageCode: "en",
    targetLanguageCode: "ja",  // Japanese
    model: .nmt  // Neural Machine Translation
)
```

**Language Detection:**

```swift
// Detect the language of text
let detectRequest = GoogleCloudDetectLanguageRequest(
    projectID: "my-project",
    content: "Bonjour, comment allez-vous?"
)

print(detectRequest.detectCommand)
// gcloud translate detect-language "Bonjour..." --project=my-project
```

**Glossaries for Terminology:**

```swift
// Create a glossary for consistent terminology
let glossary = GoogleCloudGlossary(
    name: "product-terms",
    projectID: "my-project",
    location: "us-central1",
    languagePair: GoogleCloudGlossary.LanguagePair(
        sourceLanguageCode: "en",
        targetLanguageCode: "de"
    ),
    inputConfig: GoogleCloudGlossary.InputConfig(
        gcsSource: GoogleCloudGlossary.InputConfig.GCSSource(
            inputUri: "gs://my-bucket/glossary.tsv"
        )
    )
)

print(glossary.createCommand)

// Use glossary in translation
let requestWithGlossary = GoogleCloudTranslationRequest(
    projectID: "my-project",
    location: "us-central1",
    contents: ["Our product uses machine learning."],
    targetLanguageCode: "de",
    glossaryConfig: GoogleCloudTranslationRequest.GlossaryConfig(
        glossary: glossary.resourceName
    )
)
```

**Batch Translation:**

```swift
// Translate large document sets
let batchJob = GoogleCloudBatchTranslation(
    projectID: "my-project",
    location: "us-central1",
    sourceLanguageCode: "en",
    targetLanguageCodes: ["es", "fr", "de", "ja"],
    inputConfigs: [
        GoogleCloudBatchTranslation.InputConfig(
            mimeType: .plainText,
            gcsSource: GoogleCloudBatchTranslation.InputConfig.GCSSource(
                inputUri: "gs://my-bucket/documents/"
            )
        )
    ],
    outputConfig: GoogleCloudBatchTranslation.OutputConfig(
        gcsDestination: GoogleCloudBatchTranslation.OutputConfig.GCSDestination(
            outputUriPrefix: "gs://my-bucket/translations/"
        )
    )
)
```

**Translation Operations:**

```swift
let ops = GoogleCloudTranslationOperations(projectID: "my-project")

// Translate text
print(ops.translate("Hello", to: "es"))

// With source language
print(ops.translate("Goodbye", from: "en", to: "fr"))

// Detect language
print(ops.detectLanguage("Guten Tag"))

// List languages
print(ops.listLanguagesCommand)
// gcloud translate list-languages --project=my-project

// Enable API
print(ops.enableAPICommand)
```

**DAIS Translation Template:**

```swift
let template = DAISTranslationTemplate(
    projectID: "my-project",
    location: "us-central1",
    defaultSourceLanguage: .english,
    defaultTargetLanguages: [.spanish, .french, .german]
)

// Quick translation
let request = template.translate("Welcome to our platform", to: .spanish)

// Translate to all default languages
let allRequests = template.translateToAll("Hello, world!")
// Creates requests for Spanish, French, and German

// Create terminology glossary
let glossary = template.createGlossary(
    name: "product-terms",
    sourceLanguage: .english,
    targetLanguage: .german,
    glossaryFile: "terms.tsv"
)

// Document translation
let docTranslation = template.translateDocument(
    inputUri: "gs://my-bucket/report.pdf",
    outputUri: "gs://my-bucket/translated/",
    targetLanguage: .japanese
)

// Generate setup script
print(template.setupScript)
```

**Common Language Codes:**

| Language | Code | Language | Code |
|----------|------|----------|------|
| English | `en` | Japanese | `ja` |
| Spanish | `es` | Korean | `ko` |
| French | `fr` | Chinese (Simplified) | `zh-CN` |
| German | `de` | Chinese (Traditional) | `zh-TW` |
| Italian | `it` | Arabic | `ar` |
| Portuguese | `pt` | Hindi | `hi` |
| Russian | `ru` | Dutch | `nl` |

### GoogleCloudBatchJob (Cloud Batch API)

Cloud Batch is a fully managed service for running containerized batch workloads at scale:

```swift
// Create a simple batch job with a script
let scriptJob = GoogleCloudBatchJob(
    name: "data-processing-job",
    projectID: "my-project",
    location: "us-central1",
    taskGroups: [
        TaskGroup(
            taskSpec: TaskSpec(
                runnables: [
                    Runnable.script(
                        text: """
                        #!/bin/bash
                        echo "Processing task $BATCH_TASK_INDEX of $BATCH_TASK_COUNT"
                        python3 /scripts/process.py --input $INPUT_FILE
                        """
                    )
                ],
                maxRunDuration: "3600s",
                maxRetryCount: 2
            ),
            taskCount: 100,
            parallelism: 10
        )
    ]
)

print(scriptJob.createCommand)
// gcloud batch jobs submit data-processing-job --project=my-project --location=us-central1 --config=job.json
```

**Container-Based Jobs:**

```swift
// Run a container image across multiple tasks
let containerJob = GoogleCloudBatchJob(
    name: "ml-batch-inference",
    projectID: "my-project",
    location: "us-central1",
    taskGroups: [
        TaskGroup(
            taskSpec: TaskSpec(
                runnables: [
                    Runnable.container(
                        imageUri: "gcr.io/my-project/inference:latest",
                        commands: ["python", "inference.py"],
                        entrypoint: "/bin/sh"
                    )
                ],
                volumes: [
                    Volume(
                        gcs: GCSVolume(remotePath: "gs://my-bucket/data"),
                        mountPath: "/mnt/data"
                    )
                ],
                environment: EnvironmentConfig(
                    variables: [
                        "MODEL_PATH": "/mnt/data/model",
                        "BATCH_SIZE": "32"
                    ]
                )
            ),
            taskCount: 1000,
            parallelism: 50
        )
    ],
    allocationPolicy: AllocationPolicy(
        instances: [
            InstancePolicyOrTemplate(
                policy: InstancePolicy(
                    machineType: "n1-standard-4",
                    provisioningModel: .spot
                )
            )
        ]
    )
)

print(containerJob.createCommand)
```

**GPU Batch Jobs:**

```swift
// Configure GPU-accelerated batch processing
let gpuJob = GoogleCloudBatchJob(
    name: "gpu-training-job",
    projectID: "my-project",
    location: "us-central1",
    taskGroups: [
        TaskGroup(
            taskSpec: TaskSpec(
                runnables: [
                    Runnable.container(
                        imageUri: "gcr.io/my-project/training:cuda12",
                        commands: ["python", "train.py", "--epochs", "100"]
                    )
                ],
                computeResource: ComputeResource(
                    cpuMilli: 4000,
                    memoryMib: 16384
                )
            ),
            taskCount: 10,
            parallelism: 5
        )
    ],
    allocationPolicy: AllocationPolicy(
        instances: [
            InstancePolicyOrTemplate(
                policy: InstancePolicy(
                    machineType: "n1-standard-8",
                    accelerators: [
                        Accelerator(type: .nvidiaT4, count: 1)
                    ],
                    provisioningModel: .standard
                )
            )
        ],
        location: AllocationPolicy.LocationPolicy(
            allowedLocations: ["zones/us-central1-a", "zones/us-central1-b"]
        )
    )
)

print(gpuJob.toJSON())
```

**Batch Operations:**

```swift
let ops = BatchOperations(projectID: "my-project", location: "us-central1")

// List jobs
print(ops.listJobsCommand)
// gcloud batch jobs list --project=my-project --location=us-central1

// Get job status
print(ops.describeJobCommand(jobName: "ml-batch-inference"))

// Delete completed job
print(ops.deleteJobCommand(jobName: "old-job"))

// List tasks in a job
print(ops.listTasksCommand(jobName: "data-processing-job", taskGroup: "group0"))

// Cancel a running job
print(ops.cancelJobCommand(jobName: "long-running-job"))
```

**DAIS Batch Template:**

```swift
let template = DAISBatchTemplate(
    projectID: "my-project",
    location: "us-central1",
    defaultMachineType: "n1-standard-4"
)

// Quick container job
let job = template.containerJob(
    name: "quick-process",
    image: "gcr.io/my-project/processor:v1",
    taskCount: 100,
    parallelism: 20
)

// GPU job with specific accelerator
let gpuJob = template.gpuJob(
    name: "ml-training",
    image: "gcr.io/my-project/training:cuda",
    gpuType: .nvidiaA100,
    gpuCount: 2,
    taskCount: 10
)

// Generate job monitoring script
print(template.monitoringScript)
```

**GPU Types:**

| GPU Type | Description | Use Case |
|----------|-------------|----------|
| `nvidiaT4` | NVIDIA T4 | Inference, light training |
| `nvidiaV100` | NVIDIA V100 | Training, HPC |
| `nvidiaA100` | NVIDIA A100 | Large-scale training |
| `nvidiaL4` | NVIDIA L4 | Inference, AI workloads |
| `nvidiaH100` | NVIDIA H100 | LLM training |

### GoogleCloudBinaryAuthorizationPolicy (Binary Authorization API)

Binary Authorization provides deploy-time security controls for GKE and Cloud Run:

```swift
// Create a policy that requires attestation for all container images
let policy = GoogleCloudBinaryAuthorizationPolicy(
    projectID: "my-project",
    description: "Require attestation for production deployments",
    globalPolicyEvaluationMode: .enable,
    admissionWhitelistPatterns: [
        .gcr(project: "my-project"),
        .artifactRegistry(project: "my-project", location: "us-central1", repository: "production")
    ],
    defaultAdmissionRule: .requireAttestation(attestors: [
        "projects/my-project/attestors/security-team",
        "projects/my-project/attestors/qa-team"
    ])
)

print(policy.getPolicyCommand)
// gcloud container binauthz policy export --project=my-project
```

**Creating Attestors:**

```swift
// Create an attestor with KMS key
let attestor = GoogleCloudAttestor(
    name: "security-team",
    projectID: "my-project",
    description: "Security team attestor for production deployments",
    userOwnedGrafeasNote: .init(
        noteReference: "projects/my-project/notes/security-team-note"
    )
)

print(attestor.createCommand)
// gcloud container binauthz attestors create security-team --project=my-project ...

// Add a KMS signing key
print(attestor.addKMSKeyCommand(
    kmsKeyVersionResourceID: "projects/my-project/locations/global/keyRings/binauthz/cryptoKeys/attestor-key/cryptoKeyVersions/1"
))
```

**Creating Attestations:**

```swift
// Create an attestation for a container image
let attestation = GoogleCloudAttestation(
    resourceUri: "gcr.io/my-project/my-app@sha256:abc123def456",
    attestorName: "security-team",
    projectID: "my-project"
)

// Create attestation with KMS key
print(attestation.createKMSCommand(
    kmsKeyVersion: "projects/my-project/locations/global/keyRings/binauthz/cryptoKeys/attestor-key/cryptoKeyVersions/1"
))

// Verify attestation
print(attestation.verifyCommand)
// gcloud container binauthz attestations verify --artifact-url=gcr.io/my-project/my-app@sha256:abc123def456 ...
```

**Binary Authorization Operations:**

```swift
let ops = BinaryAuthorizationOperations(projectID: "my-project")

// Enable Binary Authorization
print(ops.enableAPICommand)
print(ops.enableContainerAnalysisAPICommand)

// List attestors
print(ops.listAttestorsCommand)

// Create attestation for an image
print(ops.createAttestationCommand(
    imageUri: "gcr.io/my-project/app@sha256:abc123",
    attestor: "security-team",
    kmsKeyVersion: "projects/my-project/locations/global/keyRings/binauthz/cryptoKeys/key/cryptoKeyVersions/1"
))
```

**DAIS Binary Authorization Template:**

```swift
let template = DAISBinaryAuthorizationTemplate(projectID: "my-project")

// Create a policy that requires attestation
let policy = template.attestationRequiredPolicy(attestorNames: ["security-team", "qa-team"])

// Create a deny-all policy (for maximum security)
let strictPolicy = template.denyAllPolicy

// Create an attestor
let attestor = template.attestor(name: "security-team", description: "Security team attestor")

// Generate setup script
print(template.setupScript)

// Generate CI/CD integration script
print(template.cicdIntegrationScript)

// Generate policy YAML
print(template.requireAttestationPolicyYAML(attestorName: "security-team"))
```

**Policy Types:**

| Policy | Description | Use Case |
|--------|-------------|----------|
| `allowAll` | Allow all images | Development/testing |
| `denyAll` | Deny all images | Lock-down mode |
| `requireAttestation` | Require signed attestations | Production security |

### GoogleCloudCaPool (Certificate Authority Service API)

Certificate Authority Service provides managed private CA infrastructure:

```swift
// Create a CA pool for enterprise use
let pool = GoogleCloudCaPool(
    name: "production-pool",
    projectID: "my-project",
    location: "us-central1",
    tier: .enterprise,
    issuancePolicy: .init(
        allowedKeyTypes: [.rsa2048, .ecdsaP256],
        maximumLifetime: "31536000s" // 1 year
    ),
    publishingOptions: .init(
        publishCaCert: true,
        publishCrl: true
    )
)

print(pool.createCommand)
// gcloud privateca pools create production-pool --project=my-project --location=us-central1 --tier=enterprise
```

**Creating Certificate Authorities:**

```swift
// Create a root CA
let rootCA = GoogleCloudCertificateAuthority(
    name: "root-ca",
    caPoolName: "production-pool",
    projectID: "my-project",
    location: "us-central1",
    type: .selfSigned,
    config: CertificateConfig(
        subjectConfig: .init(
            subject: .init(
                commonName: "Example Inc Root CA",
                organization: "Example Inc",
                countryCode: "US"
            )
        ),
        x509Config: .init(
            keyUsage: .init(baseKeyUsage: .caUsage),
            caOptions: .rootCA
        )
    ),
    lifetime: "315360000s", // 10 years
    keySpec: .init(algorithm: .ecP384Sha384)
)

print(rootCA.createRootCACommand)
print(rootCA.enableCommand)
```

**Issuing Certificates:**

```swift
// Issue a server certificate
let serverCert = GoogleCloudCertificate(
    name: "web-server-cert",
    caPoolName: "production-pool",
    projectID: "my-project",
    location: "us-central1",
    lifetime: "7776000s", // 90 days
    config: CertificateConfig(
        subjectConfig: .init(
            subject: .init(
                commonName: "example.com",
                organization: "Example Inc"
            ),
            subjectAltName: .init(
                dnsNames: ["example.com", "www.example.com", "api.example.com"]
            )
        ),
        x509Config: .init(
            keyUsage: .init(
                baseKeyUsage: .serverAuth,
                extendedKeyUsage: .serverAuth
            ),
            caOptions: .endEntity
        )
    )
)

print(serverCert.createCommand)
print(serverCert.describeCommand)
```

**Certificate Authority Operations:**

```swift
let ops = CertificateAuthorityOperations(projectID: "my-project", location: "us-central1")

// Enable API
print(ops.enableAPICommand)

// List CA pools
print(ops.listPoolsCommand)

// List certificates in a pool
print(ops.listCertificatesCommand(pool: "production-pool"))

// Create CSR using OpenSSL
print(ops.createCSRCommand(keyFile: "key.pem", csrFile: "csr.pem", subject: "CN=example.com,O=Example Inc"))
```

**DAIS Certificate Authority Template:**

```swift
let template = DAISCertificateAuthorityTemplate(
    projectID: "my-project",
    location: "us-central1",
    organization: "Example Inc"
)

// Create enterprise CA pool
let pool = template.enterprisePool(name: "prod-pool")

// Create root CA
let rootCA = template.rootCA(name: "root-ca", pool: "prod-pool")

// Issue server certificate
let cert = template.serverCertificate(
    name: "api-server",
    pool: "prod-pool",
    dnsNames: ["api.example.com", "api-internal.example.com"]
)

// Issue client certificate for mTLS
let clientCert = template.clientCertificate(
    name: "service-client",
    pool: "prod-pool",
    email: "service@example.com"
)

// Generate setup script
print(template.setupScript)

// Generate certificate issuance script
print(template.issueCertificateScript(
    certName: "web-server",
    dnsNames: ["example.com", "www.example.com"]
))
```

**CA Pool Tiers:**

| Tier | Description | Use Case |
|------|-------------|----------|
| `devops` | Basic features | Development, CI/CD |
| `enterprise` | Advanced features with HSM | Production workloads |

### GoogleCloudConnectivityTest (Network Intelligence Center API)

Network Intelligence Center provides network monitoring, diagnostics, and connectivity testing:

```swift
// Create a VM-to-VM connectivity test
let test = GoogleCloudConnectivityTest(
    name: "app-to-db-test",
    projectID: "my-project",
    description: "Test connectivity from app server to database",
    source: .instance("projects/my-project/zones/us-central1-a/instances/app-vm"),
    destination: .instance("projects/my-project/zones/us-central1-a/instances/db-vm"),
    networkProtocol: .tcp
)

print(test.createCommand)
print(test.rerunCommand)
```

**Testing Different Endpoint Types:**

```swift
// Test to an external IP
let externalTest = GoogleCloudConnectivityTest(
    name: "egress-test",
    projectID: "my-project",
    source: .instance("projects/my-project/zones/us-central1-a/instances/vm1"),
    destination: .ip("8.8.8.8", port: 443),
    networkProtocol: .tcp
)

// Test GKE cluster connectivity
let gkeTest = GoogleCloudConnectivityTest(
    name: "gke-egress",
    projectID: "my-project",
    source: .gkeMaster("projects/my-project/locations/us-central1/clusters/my-cluster"),
    destination: .ip("api.example.com", port: 443),
    networkProtocol: .tcp
)

// Test to Cloud SQL
let sqlTest = GoogleCloudConnectivityTest(
    name: "app-to-sql",
    projectID: "my-project",
    source: .instance("projects/my-project/zones/us-central1-a/instances/app-vm"),
    destination: .cloudSql("projects/my-project/instances/my-database"),
    networkProtocol: .tcp
)

// Test to Cloud Function
let fnTest = GoogleCloudConnectivityTest(
    name: "to-function",
    projectID: "my-project",
    source: .instance("projects/my-project/zones/us-central1-a/instances/client-vm"),
    destination: .cloudFunction(uri: "projects/my-project/locations/us-central1/functions/my-function"),
    networkProtocol: .tcp
)
```

**Network Topology:**

```swift
// Define network topology resources
let resource = GoogleCloudNetworkTopology.TopologyResource(
    name: "my-network",
    resourceType: .network,
    location: "global",
    connections: [
        .init(targetResource: "my-subnet", connectionType: "parent")
    ]
)

let topology = GoogleCloudNetworkTopology(
    projectID: "my-project",
    resources: [resource],
    locations: ["us-central1", "us-east1"]
)
```

**Firewall Insights:**

```swift
// Track firewall insights
let insight = GoogleCloudFirewallInsight(
    name: "unused-rule-insight",
    projectID: "my-project",
    insightType: .unusedRule,
    severity: .medium,
    firewallRules: [
        .init(firewallRuleName: "allow-ssh", network: "default")
    ],
    recommendation: "Consider removing unused firewall rule"
)
```

**Network Intelligence Operations:**

```swift
let ops = NetworkIntelligenceOperations(projectID: "my-project")

// Enable APIs
print(ops.enableAPICommand)
print(ops.enableRecommenderAPICommand)

// List connectivity tests
print(ops.listTestsCommand)

// Create VM-to-VM test
print(ops.createVMToVMTestCommand(
    name: "web-to-api",
    sourceInstance: "projects/my-project/zones/us-central1-a/instances/web-vm",
    sourceNetwork: "projects/my-project/global/networks/default",
    destinationInstance: "projects/my-project/zones/us-central1-a/instances/api-vm",
    destinationNetwork: "projects/my-project/global/networks/default",
    networkProtocol: .tcp,
    port: 8080
))

// List firewall insights
print(ops.listFirewallInsightsCommand)

// Add IAM binding
print(ops.addIAMBindingCommand(
    member: "user:admin@example.com",
    role: .networkManagementAdmin
))
```

**DAIS Network Intelligence Template:**

```swift
let template = DAISNetworkIntelligenceTemplate(projectID: "my-project")

// Create VM to VM test
let vmTest = template.vmToVMTest(
    name: "app-to-db",
    sourceInstance: "projects/my-project/zones/us-central1-a/instances/app-vm",
    destinationInstance: "projects/my-project/zones/us-central1-a/instances/db-vm"
)

// Create internet egress test
let egressTest = template.vmToInternetTest(
    name: "internet-access",
    sourceInstance: "projects/my-project/zones/us-central1-a/instances/vm1",
    destinationIP: "8.8.8.8",
    port: 443
)

// Create GKE connectivity test
let gkeConnTest = template.gkeConnectivityTest(
    name: "gke-api-access",
    clusterUri: "projects/my-project/locations/us-central1/clusters/my-cluster",
    destinationIP: "registry.example.com",
    port: 443
)

// Create Cloud SQL connectivity test
let sqlConnTest = template.cloudSqlConnectivityTest(
    name: "app-db-connectivity",
    sourceInstance: "projects/my-project/zones/us-central1-a/instances/app-vm",
    sqlInstanceUri: "projects/my-project/instances/postgres-db",
    port: 5432
)

// Generate connectivity testing script
print(template.connectivityTestingScript)
```

**Supported Endpoint Types:**

| Endpoint | Factory Method | Use Case |
|----------|---------------|----------|
| VM Instance | `.instance(uri)` | Testing between VMs |
| IP Address | `.ip(address, port:)` | External or internal IPs |
| GKE Master | `.gkeMaster(uri)` | GKE cluster connectivity |
| Cloud SQL | `.cloudSql(uri)` | Database connectivity |
| Cloud Function | `.cloudFunction(uri:)` | Function invocations |
| Cloud Run | `.cloudRun(uri:)` | Cloud Run services |

### GoogleCloudInterconnect (Cloud Interconnect API)

Cloud Interconnect provides dedicated and partner network connections between your on-premises network and Google Cloud:

```swift
// Create a dedicated interconnect
let interconnect = GoogleCloudInterconnect(
    name: "dc-interconnect-lax",
    projectID: "my-project",
    description: "Los Angeles datacenter connection",
    location: "lax-loa9-1",
    interconnectType: .dedicated,
    linkType: .linkTypeEthernet10gLr,
    requestedLinkCount: 2,
    adminEnabled: true,
    nocContactEmail: "noc@example.com",
    customerName: "Example Corp"
)

print(interconnect.createCommand)
print(interconnect.describeCommand)
```

**Creating Cloud Router for Interconnect:**

```swift
// Create a Cloud Router for BGP sessions
let router = GoogleCloudRouterForInterconnect(
    name: "ic-router",
    projectID: "my-project",
    region: "us-central1",
    network: "prod-network",
    asn: 16550,
    bgpKeepaliveInterval: 20,
    advertisedGroups: [.allSubnets]
)

print(router.createCommand)

// Add interface for VLAN attachment
print(router.addInterfaceCommand(
    interfaceName: "if-0",
    interconnectAttachment: "vlan-100",
    ipRange: "169.254.1.1/30"
))

// Add BGP peer for on-premises router
print(router.addBgpPeerCommand(
    peerName: "on-prem-peer",
    peerAsn: 65000,
    interface: "if-0",
    peerIpAddress: "169.254.1.2"
))
```

**Dedicated Interconnect Attachments:**

```swift
// Create VLAN attachment for zone A (high availability)
let attachmentA = GoogleCloudInterconnectAttachment(
    name: "vlan-100-a",
    projectID: "my-project",
    region: "us-central1",
    description: "Zone A attachment",
    interconnect: "dc-interconnect-lax",
    router: "ic-router",
    attachmentType: .dedicated,
    edgeAvailabilityDomain: .availabilityDomain1,
    bandwidth: .bps10g,
    vlanTag8021q: 100,
    mtu: 1500,
    adminEnabled: true
)

print(attachmentA.createDedicatedCommand)

// Create matching attachment for zone B
let attachmentB = GoogleCloudInterconnectAttachment(
    name: "vlan-100-b",
    projectID: "my-project",
    region: "us-central1",
    description: "Zone B attachment",
    interconnect: "dc-interconnect-lax-2",
    router: "ic-router",
    attachmentType: .dedicated,
    edgeAvailabilityDomain: .availabilityDomain2,
    bandwidth: .bps10g,
    vlanTag8021q: 100,
    adminEnabled: true
)
```

**Partner Interconnect:**

```swift
// Create partner interconnect attachment
let partnerAttachment = GoogleCloudInterconnectAttachment(
    name: "partner-attachment",
    projectID: "my-project",
    region: "us-central1",
    router: "partner-router",
    attachmentType: .partner,
    edgeAvailabilityDomain: .availabilityDomainAny,
    adminEnabled: true
)

print(partnerAttachment.createPartnerCommand)
// Returns pairing key to share with connectivity partner
print(partnerAttachment.describeCommand)
```

**Cross-Cloud Interconnect:**

```swift
// Connect to AWS
let awsInterconnect = GoogleCloudCrossCloudInterconnect(
    name: "gcp-to-aws",
    projectID: "my-project",
    description: "Connection to AWS us-west-2",
    location: "lax-loa9-1",
    remoteCloudProvider: .aws,
    remoteCloud: .init(
        remoteService: "Direct Connect",
        remoteLocation: "us-west-2",
        remoteAccountId: "123456789012"
    ),
    requestedLinkCount: 1
)

// Connect to Azure
let azureInterconnect = GoogleCloudCrossCloudInterconnect(
    name: "gcp-to-azure",
    projectID: "my-project",
    location: "ord-zone1-1",
    remoteCloudProvider: .azure,
    remoteCloud: .init(
        remoteLocation: "eastus2"
    )
)
```

**Interconnect Operations:**

```swift
let ops = InterconnectOperations(projectID: "my-project")

// Enable API
print(ops.enableAPICommand)

// List interconnects and attachments
print(ops.listInterconnectsCommand)
print(ops.listAttachmentsCommand(region: "us-central1"))

// List available locations
print(ops.listLocationsCommand)
print(ops.describeLocationCommand(location: "lax-loa9-1"))

// Get diagnostics
print(ops.getDiagnosticsCommand(interconnect: "dc-interconnect"))
```

**DAIS Interconnect Template:**

```swift
let template = DAISInterconnectTemplate(projectID: "my-project", region: "us-central1")

// Create dedicated interconnect
let interconnect = template.dedicatedInterconnect(
    name: "dc-interconnect",
    location: "lax-loa9-1",
    linkType: .linkTypeEthernet10gLr,
    linkCount: 2,
    nocEmail: "noc@example.com",
    customerName: "Example Corp"
)

// Create Cloud Router
let router = template.interconnectRouter(
    name: "ic-router",
    network: "prod-network",
    asn: 16550
)

// Create HA attachments
let attachmentA = template.dedicatedAttachmentZoneA(
    name: "vlan-100-a",
    interconnect: "dc-interconnect",
    router: "ic-router",
    vlanTag: 100
)

let attachmentB = template.dedicatedAttachmentZoneB(
    name: "vlan-100-b",
    interconnect: "dc-interconnect-2",
    router: "ic-router",
    vlanTag: 100
)

// Generate HA setup script
print(template.haInterconnectSetupScript(
    interconnect1: "ic-metro1",
    interconnect2: "ic-metro2",
    location1: "lax-loa9-1",
    location2: "sfo-zone1-1",
    network: "prod-network",
    nocEmail: "noc@example.com",
    customerName: "Example Corp"
))

// Generate partner interconnect script
print(template.partnerInterconnectSetupScript(
    network: "prod-network",
    attachmentName: "partner-attachment"
))
```

**Bandwidth Options:**

| Bandwidth | Value | Use Case |
|-----------|-------|----------|
| 50 Mbps | `.bps50m` | Light workloads |
| 100 Mbps | `.bps100m` | Small applications |
| 1 Gbps | `.bps1g` | Standard workloads |
| 10 Gbps | `.bps10g` | High-bandwidth applications |
| 50 Gbps | `.bps50g` | Data-intensive workloads |

### GoogleCloudHealthcareDataset (Cloud Healthcare API)

Cloud Healthcare API provides HIPAA-compliant storage and processing for healthcare data in FHIR, HL7v2, and DICOM formats:

```swift
// Create a healthcare dataset
let dataset = GoogleCloudHealthcareDataset(
    name: "clinical-data",
    projectID: "my-project",
    location: "us-central1",
    timeZone: "America/Los_Angeles"
)

print(dataset.createCommand)
print(dataset.resourceName)
```

**FHIR Store (Fast Healthcare Interoperability Resources):**

```swift
// Create an R4 FHIR store with BigQuery streaming
let fhirStore = GoogleCloudFHIRStore(
    name: "patient-records",
    dataset: "clinical-data",
    projectID: "my-project",
    location: "us-central1",
    version: .r4,
    enableUpdateCreate: true,
    streamConfigs: [
        .init(
            bigQueryDestination: .init(
                datasetUri: "bq://my-project.healthcare_analytics",
                schemaConfig: .init(schemaType: .analyticsV2, recursiveStructureDepth: 3)
            ),
            resourceTypes: ["Patient", "Observation", "Condition"]
        )
    ]
)

print(fhirStore.createCommand)
print(fhirStore.fhirEndpoint)
```

**FHIR Operations:**

```swift
let ops = FHIROperations(store: fhirStore)

// Read a patient resource
print(ops.readCommand(resourceType: .patient, resourceID: "12345"))

// Search for patients by name
print(ops.searchCommand(resourceType: .patient, parameters: ["name": "Smith"]))

// Create a new patient
print(ops.createCommand(resourceType: .patient, dataFile: "patient.json"))

// Bulk export
print(ops.bulkExportCommand)
```

**HL7v2 Store:**

```swift
// Create an HL7v2 store with Pub/Sub notifications
let hl7Store = GoogleCloudHL7v2Store(
    name: "hl7-messages",
    dataset: "clinical-data",
    projectID: "my-project",
    location: "us-central1",
    parserConfig: .init(version: .v3),
    notificationConfigs: [
        .init(pubsubTopic: "projects/my-project/topics/hl7-events")
    ]
)

print(hl7Store.createCommand)
print(hl7Store.resourceName)
```

**DICOM Store (Medical Imaging):**

```swift
// Create a DICOM store for radiology images
let dicomStore = GoogleCloudDICOMStore(
    name: "radiology-images",
    dataset: "imaging-data",
    projectID: "my-project",
    location: "us-central1",
    notificationConfig: .init(
        pubsubTopic: "projects/my-project/topics/dicom-events"
    )
)

print(dicomStore.createCommand)
print(dicomStore.dicomWebEndpoint)
```

**Consent Store:**

```swift
// Create a consent store for patient consent management
let consentStore = GoogleCloudConsentStore(
    name: "patient-consents",
    dataset: "clinical-data",
    projectID: "my-project",
    location: "us-central1",
    enableConsentCreateOnUpdate: true,
    defaultConsentTtl: "31536000s" // 1 year
)

print(consentStore.createCommand)
```

**Healthcare Operations:**

```swift
let healthOps = HealthcareOperations(projectID: "my-project", location: "us-central1")

// Enable API
print(healthOps.enableAPICommand)

// List stores
print(healthOps.listFHIRStoresCommand(dataset: "clinical-data"))
print(healthOps.listDICOMStoresCommand(dataset: "imaging-data"))

// Import/export FHIR data
print(healthOps.importFHIRCommand(
    dataset: "clinical-data",
    fhirStore: "patient-records",
    gcsUri: "gs://my-bucket/fhir-bundles/*",
    contentStructure: "BUNDLE"
))

print(healthOps.exportFHIRCommand(
    dataset: "clinical-data",
    fhirStore: "patient-records",
    gcsUri: "gs://my-bucket/export/"
))

// De-identify dataset
print(healthOps.deidentifyDatasetCommand(
    sourceDataset: "clinical-data",
    destinationDataset: "deidentified-data"
))

// Add IAM binding
print(healthOps.addIAMBindingCommand(
    member: "user:doctor@example.com",
    role: .healthcareFhirResourceReader,
    dataset: "clinical-data"
))
```

**DAIS Healthcare Template:**

```swift
let template = DAISHealthcareTemplate(projectID: "my-project", location: "us-central1")

// Create dataset
let dataset = template.dataset(name: "ehr-data", timeZone: "America/Chicago")

// Create FHIR R4 store with BigQuery streaming
let fhirStore = template.fhirStoreR4(
    name: "patient-records",
    dataset: "ehr-data",
    bigQueryDataset: "healthcare_analytics"
)

// Create HL7v2 store
let hl7Store = template.hl7v2Store(
    name: "hl7-messages",
    dataset: "ehr-data",
    pubsubTopic: "projects/my-project/topics/hl7-events"
)

// Create DICOM store
let dicomStore = template.dicomStore(
    name: "imaging",
    dataset: "ehr-data"
)

// Generate setup script
print(template.setupScript(
    datasetName: "ehr-data",
    fhirStoreName: "patient-records",
    dicomStoreName: "imaging",
    hl7v2StoreName: "hl7-messages"
))

// Generate FHIR bulk import script
print(template.fhirBulkImportScript(
    dataset: "ehr-data",
    fhirStore: "patient-records",
    gcsUri: "gs://my-bucket/synthea-data/*.json"
))
```

**FHIR Resource Types:**

| Resource | Type | Description |
|----------|------|-------------|
| Patient | `.patient` | Patient demographics |
| Observation | `.observation` | Clinical measurements |
| Condition | `.condition` | Diagnoses and problems |
| MedicationRequest | `.medicationRequest` | Prescriptions |
| Procedure | `.procedure` | Clinical procedures |
| Encounter | `.encounter` | Patient visits |
| Immunization | `.immunization` | Vaccination records |
| DiagnosticReport | `.diagnosticReport` | Lab and imaging reports |

### GoogleCloudDataflowJob (Dataflow API)

Dataflow is a fully managed service for batch and streaming data processing:

```swift
// Create a batch job using a Google-provided template
let wordCountJob = GoogleCloudDataflowJob(
    name: "word-count-job",
    projectID: "my-project",
    region: "us-central1",
    type: .batch,
    templatePath: GoogleDataflowTemplates.wordCount,
    parameters: [
        "inputFile": "gs://my-bucket/input.txt",
        "output": "gs://my-bucket/output"
    ],
    environment: GoogleCloudDataflowJob.EnvironmentConfig(
        tempLocation: "gs://my-bucket/temp",
        machineType: "n1-standard-2",
        numWorkers: 2,
        maxWorkers: 10
    )
)

print(wordCountJob.runClassicTemplateCommand)
```

**Streaming Jobs:**

```swift
// Create a streaming ETL job from Pub/Sub to BigQuery
let streamingJob = GoogleDataflowTemplates.pubSubToBigQueryJob(
    name: "events-to-bq",
    projectID: "my-project",
    region: "us-central1",
    inputTopic: "projects/my-project/topics/events",
    outputTable: "my-project:analytics.events",
    tempLocation: "gs://my-bucket/temp",
    enableStreamingEngine: true
)

print(streamingJob.runClassicTemplateCommand)

// Drain a streaming job gracefully
let runningJob = GoogleCloudDataflowJob(
    jobID: "2024-01-15_12_34_56-1234567890",
    name: "events-to-bq",
    projectID: "my-project",
    region: "us-central1",
    type: .streaming
)
print(runningJob.drainCommand)
```

**Flex Templates:**

```swift
// Create a custom Flex Template
let flexTemplate = GoogleCloudDataflowFlexTemplate(
    name: "my-pipeline",
    projectID: "my-project",
    templatePath: "gs://my-bucket/templates/my-pipeline.json",
    containerImage: "gcr.io/my-project/my-pipeline:latest",
    sdkInfo: GoogleCloudDataflowFlexTemplate.SDKInfo(
        language: .java,
        version: "2.45.0"
    )
)

// Build the template
print(flexTemplate.buildTemplateCommand(
    jarPath: "target/my-pipeline.jar",
    tempLocation: "gs://my-bucket/temp"
))

// Run a Flex Template job
let flexJob = GoogleCloudDataflowJob(
    name: "flex-pipeline-job",
    projectID: "my-project",
    region: "us-central1",
    type: .batch,
    containerSpecGcsPath: "gs://my-bucket/templates/my-pipeline.json",
    parameters: ["inputPath": "gs://bucket/input"]
)
print(flexJob.runFlexTemplateCommand)
```

**Dataflow SQL:**

```swift
// Run a streaming SQL query
let sqlJob = GoogleCloudDataflowSQL(
    name: "streaming-analytics",
    projectID: "my-project",
    region: "us-central1",
    query: "SELECT user_id, COUNT(*) as events FROM pubsub.topic.`my-project`.`events` GROUP BY user_id",
    bigqueryDataset: "analytics",
    bigqueryTable: "user_events"
)

print(sqlJob.runCommand)
```

**Job Snapshots:**

```swift
// Create a snapshot of a streaming job
let snapshot = GoogleCloudDataflowSnapshot(
    projectID: "my-project",
    region: "us-central1",
    sourceJobID: "streaming-job-123",
    description: "Before schema migration",
    ttl: "7d"
)

print(snapshot.createCommand)
print(GoogleCloudDataflowSnapshot.listCommand(projectID: "my-project", region: "us-central1"))
```

**DAIS Dataflow Templates:**

```swift
// Create streaming ETL pipeline
let etlJob = DAISDataflowTemplate.streamingETLJob(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    inputTopic: "projects/my-project/topics/events",
    outputTable: "my-project:analytics.events",
    tempBucket: "dais-prod-dataflow"
)

// Create batch export job
let exportJob = DAISDataflowTemplate.batchExportJob(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    sourceTable: "my-project:analytics.events",
    destinationBucket: "dais-prod-exports",
    tempBucket: "dais-prod-dataflow"
)

// Generate setup script with IAM permissions
let script = DAISDataflowTemplate.setupScript(
    projectID: "my-project",
    region: "us-central1",
    deploymentName: "dais-prod",
    tempBucket: "dais-prod-dataflow",
    serviceAccountEmail: "dataflow@my-project.iam.gserviceaccount.com"
)
```

**Google-Provided Templates:**

| Template | Purpose |
|----------|---------|
| `wordCount` | Count words in text files |
| `pubSubToBigQuery` | Stream from Pub/Sub to BigQuery |
| `bigQueryToGCS` | Export BigQuery tables to GCS |
| `textToBigQuery` | Load text files to BigQuery |
| `pubSubToGCSText` | Archive Pub/Sub messages to GCS |
| `gcsToPubSub` | Publish GCS file contents to Pub/Sub |
| `bigQueryToParquet` | Export BigQuery to Parquet format |
| `jdbcToBigQuery` | Load from JDBC databases to BigQuery |
| `kafkaToBigQuery` | Stream from Kafka to BigQuery |

**Job States:**

| State | Description |
|-------|-------------|
| `running` | Job is currently executing |
| `done` | Batch job completed successfully |
| `failed` | Job encountered an error |
| `cancelled` | Job was cancelled by user |
| `draining` | Streaming job is draining |
| `drained` | Streaming job has drained |

### GoogleCloudDeliveryPipeline (Cloud Deploy API)

Cloud Deploy provides continuous delivery to GKE and Cloud Run:

```swift
// Create a delivery pipeline
let pipeline = GoogleCloudDeliveryPipeline(
    name: "app-pipeline",
    projectID: "my-project",
    location: "us-central1",
    description: "Application delivery pipeline",
    serialPipeline: GoogleCloudDeliveryPipeline.SerialPipeline(
        stages: [
            GoogleCloudDeliveryPipeline.SerialPipeline.Stage(
                targetId: "dev",
                profiles: ["dev"]
            ),
            GoogleCloudDeliveryPipeline.SerialPipeline.Stage(
                targetId: "staging",
                profiles: ["staging"]
            ),
            GoogleCloudDeliveryPipeline.SerialPipeline.Stage(
                targetId: "prod",
                profiles: ["prod"]
            )
        ]
    )
)

print(pipeline.createCommand)
print(pipeline.resourceName)
```

**Deployment Targets:**

```swift
// Cloud Run target
let cloudRunTarget = GoogleCloudDeployTarget(
    name: "prod-run",
    projectID: "my-project",
    location: "us-central1",
    targetType: .cloudRun(location: "us-central1"),
    requireApproval: true
)

// GKE target
let gkeTarget = GoogleCloudDeployTarget(
    name: "prod-gke",
    projectID: "my-project",
    location: "us-central1",
    targetType: .gke(
        cluster: "projects/my-project/locations/us-central1/clusters/main",
        internalIP: false
    ),
    requireApproval: true
)

print(cloudRunTarget.createCommand)
print(gkeTarget.createCommand)
```

**Creating and Promoting Releases:**

```swift
// Create a release
let release = GoogleCloudDeployRelease(
    name: "v1.0.0",
    projectID: "my-project",
    location: "us-central1",
    pipelineName: "app-pipeline",
    buildArtifacts: [
        GoogleCloudDeployRelease.BuildArtifact(
            image: "app",
            tag: "gcr.io/my-project/app:v1.0.0"
        )
    ],
    skaffoldConfigUri: "gs://my-bucket/skaffold.yaml"
)

print(release.createCommand)
print(release.promoteCommand(toTarget: "staging"))
```

**Managing Rollouts:**

```swift
let rollout = GoogleCloudDeployRollout(
    name: "rollout-001",
    projectID: "my-project",
    location: "us-central1",
    pipelineName: "app-pipeline",
    releaseName: "v1.0.0",
    targetId: "prod",
    state: .pendingApproval
)

print(rollout.approveCommand)  // Approve the rollout
print(rollout.rejectCommand)   // Reject the rollout
print(rollout.cancelCommand)   // Cancel in-progress rollout
```

**DAIS Cloud Deploy Templates:**

```swift
// Create a multi-stage pipeline
let pipeline = DAISCloudDeployTemplate.cloudRunPipeline(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    stages: [
        (name: "dev", runLocation: "us-central1", requireApproval: false),
        (name: "staging", runLocation: "us-central1", requireApproval: false),
        (name: "prod", runLocation: "us-central1", requireApproval: true)
    ]
)

// Generate setup script
let script = DAISCloudDeployTemplate.setupScript(
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "dais-prod",
    environments: [
        (name: "dev", runLocation: "us-central1", requireApproval: false),
        (name: "prod", runLocation: "us-central1", requireApproval: true)
    ]
)
```

**Rollout States:**

| State | Description |
|-------|-------------|
| `pendingApproval` | Waiting for manual approval |
| `inProgress` | Deployment in progress |
| `succeeded` | Deployment completed successfully |
| `failed` | Deployment failed |
| `cancelled` | Deployment was cancelled |

### GoogleCloudWorkflow (Cloud Workflows API)

Create serverless workflow orchestrations:

```swift
// Create a basic workflow
let workflow = GoogleCloudWorkflow(
    name: "data-processing",
    projectID: "my-project",
    location: "us-central1",
    description: "Process incoming data files",
    serviceAccount: "workflow-sa@my-project.iam.gserviceaccount.com",
    callLogLevel: .logErrorsOnly
)

print(workflow.createCommand)
print(workflow.resourceName)
```

**Workflow Executions:**

```swift
// Execute a workflow with data
let executeCmd = workflow.executeCommand(data: "{\"bucket\": \"my-bucket\", \"file\": \"data.json\"}")

// Track execution
let execution = GoogleCloudWorkflowExecution(
    name: "exec-123",
    workflowName: "data-processing",
    projectID: "my-project",
    location: "us-central1",
    state: .active
)

print(execution.describeCommand)  // Get execution status
print(execution.cancelCommand)    // Cancel if needed
print(execution.waitCommand)      // Wait for completion
```

**Building Workflows with Swift:**

```swift
// Use the YAML builder for workflow definitions
var builder = WorkflowYAMLBuilder()
builder.addStep("init", .assign(variables: [("project", "my-project")]))
builder.addStep("fetchData", .httpGet(url: "https://api.example.com/data", result: "response"))
builder.addStep("logResult", .log(text: "${response.body}", severity: "INFO"))
builder.addStep("returnResult", .return(value: "${response}"))

let workflowYAML = builder.build()
```

**Pre-built Service Connectors:**

```swift
// BigQuery connector
let queryStep = WorkflowConnectors.BigQuery.query(
    query: "SELECT * FROM dataset.table",
    projectID: "my-project"
)

// Cloud Storage connector
let listStep = WorkflowConnectors.Storage.listObjects(bucket: "my-bucket")

// Pub/Sub connector
let publishStep = WorkflowConnectors.PubSub.publish(
    topic: "projects/my-project/topics/my-topic",
    message: "Hello"
)

// Secret Manager connector
let secretStep = WorkflowConnectors.SecretManager.accessSecret(
    secret: "projects/my-project/secrets/api-key"
)
```

**DAIS Workflow Templates:**

```swift
// Create DAIS workflow templates
let template = DAISWorkflowsTemplate(
    projectID: "my-project",
    location: "us-central1",
    serviceAccountEmail: "workflow-sa@my-project.iam.gserviceaccount.com"
)

// Data processing workflow
let dataWorkflow = template.dataProcessingWorkflow

// Batch processing with parallel execution
let batchWorkflow = template.batchProcessingWorkflow

// Retry workflow with exponential backoff
let retryWorkflow = template.retryWorkflow

// Human-in-the-loop approval workflow
let approvalWorkflow = template.approvalWorkflow

// Generate setup script for all workflows
print(template.setupScript)
```

**Workflow Operations:**

```swift
// List workflows
print(WorkflowOperations.listCommand(location: "us-central1"))

// List executions
print(WorkflowOperations.listExecutionsCommand(
    workflow: "data-processing",
    location: "us-central1",
    limit: 10
))

// Enable Workflows API
print(WorkflowOperations.enableAPICommand)
```

**Execution States:**

| State | Description |
|-------|-------------|
| `active` | Execution is currently running |
| `succeeded` | Execution completed successfully |
| `failed` | Execution failed with an error |
| `cancelled` | Execution was cancelled |
| `queued` | Execution is queued to run |

### GoogleCloudAPIGatewayAPI (API Gateway)

Create serverless API management with API Gateway:

```swift
// Create an API definition
let api = GoogleCloudAPIGatewayAPI(
    name: "my-api",
    projectID: "my-project",
    displayName: "My Application API",
    labels: ["app": "myapp"]
)

print(api.createCommand)
print(api.resourceName)
```

**API Configurations:**

```swift
// Create an API config from OpenAPI spec
let config = GoogleCloudAPIGatewayConfig(
    name: "my-api-config-v1",
    apiName: "my-api",
    projectID: "my-project",
    displayName: "API Config v1",
    gatewayServiceAccount: "api-sa@my-project.iam.gserviceaccount.com"
)

print(config.createCommand(openAPISpec: "openapi.yaml"))
print(config.resourceName)
```

**Creating Gateways:**

```swift
// Create a gateway
let gateway = GoogleCloudAPIGatewayGateway(
    name: "my-gateway",
    projectID: "my-project",
    location: "us-central1",
    apiConfig: "projects/my-project/locations/global/apis/my-api/configs/my-api-config-v1",
    displayName: "My API Gateway"
)

print(gateway.createCommand)
print(gateway.publicURL)

// Update to new config version
print(gateway.updateCommand(newApiConfig: "my-api-config-v2"))
```

**Building OpenAPI Specs:**

```swift
// Use the OpenAPI spec builder
var builder = OpenAPISpecBuilder(
    title: "My API",
    description: "API for my application",
    version: "1.0.0"
)

// Add authentication
builder.addJWTAuth(
    name: "firebase",
    issuer: "https://securetoken.google.com/my-project",
    jwksURI: "https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com",
    audiences: ["my-project"]
)

// Or API key auth
builder.addAPIKeyAuth(name: "api_key", header: "x-api-key")

// Add endpoints
builder.addPath("/users", method: "GET", operation: OpenAPISpecBuilder.Operation(
    operationId: "listUsers",
    summary: "List all users",
    security: [["firebase": []]],
    backendAddress: "https://my-backend.run.app/users"
))

builder.addPath("/users/{id}", method: "GET", operation: OpenAPISpecBuilder.Operation(
    operationId: "getUser",
    parameters: [
        OpenAPISpecBuilder.Parameter(name: "id", in: .path, required: true, type: "string")
    ],
    security: [["firebase": []]],
    backendAddress: "https://my-backend.run.app/users/{id}"
))

let spec = builder.build()
```

**DAIS API Gateway Templates:**

```swift
// Create DAIS API Gateway template
let template = DAISAPIGatewayTemplate(
    projectID: "my-project",
    location: "us-central1",
    apiName: "dais-api",
    serviceAccountEmail: "api-sa@my-project.iam.gserviceaccount.com",
    backendURL: "https://dais-backend.run.app"
)

// Get resources
let api = template.api
let config = template.config(version: "v1")
let gateway = template.gateway()

// Get OpenAPI specs
let jwtSpec = template.openAPISpec           // JWT auth
let apiKeySpec = template.openAPISpecWithAPIKey  // API key auth

// Deploy everything
print(template.setupScript)
```

**API Gateway Operations:**

```swift
// List APIs
print(APIGatewayOperations.listAPIsCommand(projectID: "my-project"))

// List gateways
print(APIGatewayOperations.listGatewaysCommand(projectID: "my-project", location: "us-central1"))

// View logs
print(APIGatewayOperations.viewLogsCommand(gateway: "my-gateway", projectID: "my-project"))

// Enable APIs
print(APIGatewayOperations.enableAPIsCommand)
```

**Gateway States:**

| State | Description |
|-------|-------------|
| `creating` | Gateway is being created |
| `active` | Gateway is active and serving traffic |
| `updating` | Gateway configuration is being updated |
| `failed` | Gateway creation or update failed |
| `deleting` | Gateway is being deleted |

### GoogleCloudDLPInfoType (Cloud DLP)

Discover and protect sensitive data with Cloud DLP:

```swift
// Use built-in info types
let creditCard = GoogleCloudDLPInfoType.creditCardNumber
let email = GoogleCloudDLPInfoType.emailAddress
let ssn = GoogleCloudDLPInfoType.usSSN

// Get all common PII types
let allPII = GoogleCloudDLPInfoType.allPII

// Get financial-specific types
let financialTypes = GoogleCloudDLPInfoType.financial

// Create custom info type
let customType = GoogleCloudDLPInfoType(
    name: "EMPLOYEE_ID",
    sensitivityScore: .sensitivityHigh
)
```

**Inspection Configuration:**

```swift
// Configure content inspection
let inspectConfig = GoogleCloudDLPInspectConfig(
    infoTypes: [.emailAddress, .phoneNumber, .creditCardNumber],
    minLikelihood: .likely,
    limits: GoogleCloudDLPInspectConfig.FindingLimits(
        maxFindingsPerItem: 100,
        maxFindingsPerRequest: 1000
    ),
    includeQuote: true
)
```

**De-identification:**

```swift
// Redact all sensitive data
let redactTransform = PrimitiveTransformation.redact

// Replace with placeholder
let replaceTransform = PrimitiveTransformation.replace(with: "[REDACTED]")

// Mask characters (e.g., ****-****-****-1234)
let maskTransform = PrimitiveTransformation.mask(character: "*", numberToMask: 12)

// Replace with info type name (e.g., [EMAIL_ADDRESS])
let infoTypeTransform = PrimitiveTransformation.replaceWithInfoType

// Create de-identification config
let deidentifyConfig = GoogleCloudDLPDeidentifyConfig(
    infoTypeTransformations: GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations(
        transformations: [
            GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                infoTypes: [.creditCardNumber],
                primitiveTransformation: .mask(character: "*", numberToMask: 12)
            ),
            GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                infoTypes: [.emailAddress],
                primitiveTransformation: .replaceWithInfoType
            )
        ]
    )
)
```

**Inspect Templates:**

```swift
// Create reusable inspection template
let template = GoogleCloudDLPInspectTemplate(
    name: "pii-inspect-template",
    projectID: "my-project",
    location: "global",
    displayName: "PII Inspection Template",
    description: "Detects common PII in content",
    inspectConfig: inspectConfig
)

print(template.createCommand)
print(template.resourceName)
```

**Job Triggers:**

```swift
// Create scheduled inspection job
let trigger = GoogleCloudDLPJobTrigger(
    name: "daily-scan",
    projectID: "my-project",
    displayName: "Daily PII Scan",
    triggers: [
        GoogleCloudDLPJobTrigger.Trigger(
            schedule: .days(1)  // Run daily
        )
    ]
)

print(trigger.activateCommand)
print(trigger.pauseCommand)
```

**DAIS DLP Templates:**

```swift
// Create DAIS DLP templates
let template = DAISDLPTemplate(projectID: "my-project")

// Get pre-configured inspection configs
let piiConfig = template.piiInspectConfig
let financialConfig = template.financialInspectConfig
let healthcareConfig = template.healthcareInspectConfig

// Get de-identification configs
let redactionConfig = template.redactionDeidentifyConfig
let maskingConfig = template.maskingDeidentifyConfig

// Get ready-to-use templates
let piiInspectTemplate = template.piiInspectTemplate
let redactionTemplate = template.redactionDeidentifyTemplate

// Deploy
print(template.setupScript)
```

**DLP Operations:**

```swift
// Inspect content
print(DLPOperations.inspectContentCommand(
    projectID: "my-project",
    content: "Contact: john@example.com",
    infoTypes: [.emailAddress, .phoneNumber]
))

// Inspect file
print(DLPOperations.inspectFileCommand(
    projectID: "my-project",
    file: "data.csv",
    infoTypes: GoogleCloudDLPInfoType.allPII
))

// List templates
print(DLPOperations.listInspectTemplatesCommand(projectID: "my-project"))

// Enable API
print(DLPOperations.enableAPICommand)
```

**Info Type Categories:**

| Category | Info Types |
|----------|------------|
| PII | EMAIL_ADDRESS, PHONE_NUMBER, PERSON_NAME, STREET_ADDRESS, DATE_OF_BIRTH |
| Financial | CREDIT_CARD_NUMBER, IBAN_CODE, SWIFT_CODE, CRYPTO_WALLET |
| Identity | US_SOCIAL_SECURITY_NUMBER, US_DRIVERS_LICENSE_NUMBER, US_PASSPORT |
| Healthcare | MEDICAL_RECORD_NUMBER |

### GoogleCloudService (Service Usage API)

Enable and manage Google Cloud APIs:

```swift
// Enable a single service
let computeAPI = GoogleCloudService(
    name: "compute.googleapis.com",
    projectID: "my-project"
)
print(computeAPI.enableCommand)
// Output: gcloud services enable compute.googleapis.com --project=my-project

// Use predefined API enum
let service = GoogleCloudAPI.secretManager.service(projectID: "my-project")

// Batch enable required services
let batch = GoogleCloudServiceBatch(
    projectID: "my-project",
    services: DAISServiceTemplate.required.map { $0.rawValue }
)
print(batch.batchEnableCommand)

// Or use templates directly
let enableCmd = DAISServiceTemplate.enableCommand(
    for: DAISServiceTemplate.production,
    projectID: "my-project"
)
```

**Available API Templates:**

| Template | APIs Included |
|----------|---------------|
| `required` | Compute, Storage, Secret Manager, IAM, Resource Manager, Service Usage |
| `production` | Required + Logging, Monitoring, Cloud Trace, Cloud KMS |
| `kubernetes` | Container, Storage, Secret Manager, IAM, Logging, Monitoring |

### GoogleCloudServiceAccount (IAM API)

Create and manage service accounts:

```swift
// Create a service account
let serviceAccount = GoogleCloudServiceAccount(
    name: "dais-node",
    projectID: "my-project",
    displayName: "DAIS Node Service Account",
    description: "Service account for DAIS compute nodes"
)

print(serviceAccount.email)
// Output: dais-node@my-project.iam.gserviceaccount.com

print(serviceAccount.createCommand)
// Output: gcloud iam service-accounts create dais-node --project=my-project --display-name="DAIS Node Service Account" ...

// Create a key
print(serviceAccount.createKeyCommand(outputPath: "/tmp/key.json"))

// Use predefined templates
let nodeSA = DAISServiceAccountTemplate.nodeServiceAccount(
    projectID: "my-project",
    deploymentName: "prod"
)
```

### GoogleCloudIAMBinding

Manage IAM permissions:

```swift
// Grant a role to a service account
let binding = GoogleCloudIAMBinding(
    projectID: "my-project",
    role: .secretManagerAccessor,
    serviceAccount: serviceAccount
)
print(binding.addBindingCommand)
// Output: gcloud projects add-iam-policy-binding my-project --member=serviceAccount:... --role=roles/secretmanager.secretAccessor

// Bind to different resource types
let bucketBinding = GoogleCloudIAMBinding(
    resource: "my-bucket",
    resourceType: .bucket,
    role: GoogleCloudPredefinedRole.storageObjectViewer.rawValue,
    member: "allUsers"
)

// Conditional access (expires after date)
let tempBinding = GoogleCloudIAMBinding(
    resource: "my-project",
    resourceType: .project,
    role: "roles/viewer",
    member: "user:temp@example.com",
    condition: .expiresAfter(date: Date().addingTimeInterval(86400 * 30), title: "30 Day Access")
)
```

**Available Predefined Roles:**

| Category | Roles |
|----------|-------|
| Basic | `owner`, `editor`, `viewer` |
| Compute | `computeAdmin`, `computeViewer`, `computeInstanceAdmin` |
| Storage | `storageAdmin`, `storageObjectAdmin`, `storageObjectViewer` |
| Secrets | `secretManagerAdmin`, `secretManagerAccessor`, `secretManagerViewer` |
| IAM | `iamServiceAccountAdmin`, `iamServiceAccountUser`, `iamWorkloadIdentityUser` |
| Logging | `loggingLogWriter`, `loggingViewer`, `monitoringMetricWriter` |

### GoogleCloudProject (Resource Manager API)

Manage projects, folders, and organizations:

```swift
// Create a project
let project = GoogleCloudProject(
    projectID: "my-dais-project",
    name: "My DAIS Project",
    parent: .folder(id: "123456789"),
    labels: ["environment": "production", "team": "platform"]
)

print(project.createCommand)
// Output: gcloud projects create my-dais-project --name="My DAIS Project" --folder=123456789 --labels=...

// Use predefined templates
let devProject = DAISProjectTemplate.development(
    projectID: "dais-dev",
    name: "DAIS Development"
)

let prodProject = DAISProjectTemplate.production(
    projectID: "dais-prod",
    name: "DAIS Production"
)

// Create folders
let folder = GoogleCloudFolder(
    folderID: "new-folder",
    displayName: "DAIS Projects",
    parent: .organization(id: "123456789")
)

// Protect production projects from deletion
let lien = GoogleCloudLien(
    projectID: "dais-prod",
    reason: "Production DAIS deployment",
    origin: "dais-deployment"
)
print(lien.createCommand)
```

### GoogleCloudDeployment (Deployment Manager API)

> **DEPRECATION NOTICE**: Cloud Deployment Manager will reach end of support on March 31, 2026. Consider using `InfrastructureManagerDeployment` instead.

Manage infrastructure deployments using YAML or Jinja2 templates:

```swift
// Create a deployment configuration
let deployment = GoogleCloudDeployment(
    name: "my-deployment",
    projectID: "my-project",
    description: "Production infrastructure",
    configPath: "/path/to/config.yaml",
    labels: ["environment": "production"]
)

print(deployment.createCommand)
// Output: gcloud deployment-manager deployments create my-deployment --project=my-project --config=/path/to/config.yaml ...

print(deployment.previewCommand)  // Dry-run
print(deployment.deleteCommand)
print(deployment.describeCommand)
```

**DAIS Deployment Manager Templates:**

```swift
// Generate YAML configuration for DAIS
let config = DAISDeploymentManagerTemplate.completeDeploymentConfig(
    deploymentName: "production-dais",
    nodeCount: 3,
    machineType: .n2Standard2,
    zone: "us-central1-a",
    grpcPort: 9090,
    httpPort: 8080
)
// Returns complete YAML with instances and firewall rules
```

**Available Deployment Types:**

| Type | Description |
|------|-------------|
| `compute.v1.instance` | Compute Engine instance |
| `compute.v1.firewall` | Firewall rule |
| `compute.v1.network` | VPC network |
| `storage.v1.bucket` | Cloud Storage bucket |
| `iam.v1.serviceAccount` | Service account |
| `pubsub.v1.topic` | Pub/Sub topic |

### InfrastructureManagerDeployment (Infrastructure Manager API)

Infrastructure Manager uses Terraform to create and manage Google Cloud resources. It's the recommended replacement for Deployment Manager:

```swift
// Create a Terraform-based deployment
let deployment = InfrastructureManagerDeployment(
    name: "my-infra",
    projectID: "my-project",
    location: "us-central1",
    serviceAccount: "infra@my-project.iam.gserviceaccount.com",
    labels: ["app": "dais", "env": "production"]
)

print(deployment.createCommand)
// Output: gcloud infra-manager deployments apply my-infra --project=my-project --location=us-central1 ...
```

**Using Terraform Blueprints:**

```swift
// Git repository source
let gitBlueprint = TerraformBlueprint(
    source: .git(
        repo: "https://github.com/example/infra",
        directory: "terraform",
        ref: "main"
    ),
    inputValues: ["region": "us-west1", "node_count": "3"]
)

// GCS source
let gcsBlueprint = TerraformBlueprint(
    source: .gcs(bucket: "my-tf-configs", object: "infra.tar.gz")
)

// Local source
let localBlueprint = TerraformBlueprint(
    source: .local(path: "/path/to/terraform")
)

let deployment = InfrastructureManagerDeployment(
    name: "prod-infra",
    projectID: "my-project",
    location: "us-central1",
    blueprint: gitBlueprint
)
```

**Deployment Operations:**

```swift
// Preview changes before applying
let preview = InfrastructureManagerPreview(
    name: "preview-001",
    projectID: "my-project",
    location: "us-central1",
    deploymentName: "my-infra"
)
print(preview.createCommand)

// Lock/unlock deployments
print(deployment.lockCommand)
print(deployment.unlockCommand)

// Export Terraform state
print(deployment.exportStateCommand)
```

**DAIS Infrastructure Manager Templates:**

```swift
// Generate complete Terraform configuration
let terraformConfig = DAISInfrastructureTemplate.terraformConfig(
    deploymentName: "prod-dais",
    projectID: "my-project",
    region: "us-central1",
    zone: "us-central1-a",
    nodeCount: 3,
    machineType: .n2Standard2,
    grpcPort: 9090,
    httpPort: 8080
)

// Create deployment with predefined settings
let daisDeployment = DAISInfrastructureTemplate.deployment(
    name: "prod-infra",
    projectID: "my-project",
    location: "us-central1",
    gitRepo: "https://github.com/example/dais-infra",
    gitRef: "v1.0.0"
)
```

**Key Benefits of Infrastructure Manager:**
- Uses standard Terraform configurations
- State management and drift detection
- Preview changes before applying
- Integration with Cloud Build and Cloud Source Repositories

## Cost Optimization

### Machine Type Selection

| Use Case | Recommended Type | Monthly Cost |
|----------|-----------------|--------------|
| Development | e2-micro | Free (1/month) |
| Testing | e2-small | ~$12 |
| Light Production | e2-medium | ~$24 |
| Production | n2-standard-2 | ~$58 |
| High Performance | n2-standard-4 | ~$116 |

### Spot Instances

Save up to 70% with spot/preemptible instances:

```swift
let deployment = GoogleCloudDAISDeployment(
    name: "dev",
    provider: provider,
    nodeCount: 2,
    machineType: .e2Medium,
    useSpotInstances: true  // ~70% savings
)
```

**Note**: Spot instances can be terminated with 30 seconds notice. Use for:
- Development/testing
- Stateless workloads
- Batch processing

### Storage Optimization

Use lifecycle rules to automatically move data to cheaper storage:

```swift
let bucket = GoogleCloudStorageBucket(
    name: "my-backups",
    projectID: "my-project",
    location: .usWest1,
    storageClass: .standard,
    lifecycleRules: [
        .moveToNearlineAfter30Days,   // $0.010/GB
        .moveToColdlineAfter90Days,    // $0.004/GB
        .moveToArchiveAfter365Days     // $0.0012/GB
    ]
)
```

## Security Best Practices

### 1. Use Secret Manager for Credentials

```bash
# Store the certificate master key
openssl rand -hex 32 | gcloud secrets create butteryai-certificate-master-key --data-file=-

# Access in your application
export CERTIFICATE_MASTER_KEY=$(gcloud secrets versions access latest --secret=butteryai-certificate-master-key)
```

### 2. Use Service Accounts

```bash
# Create a service account for DAIS
gcloud iam service-accounts create dais-node \
    --display-name="DAIS Node Service Account"

# Grant Secret Manager access
gcloud secrets add-iam-policy-binding butteryai-certificate-master-key \
    --member="serviceAccount:dais-node@MY_PROJECT.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

# Grant Storage access
gsutil iam ch serviceAccount:dais-node@MY_PROJECT.iam.gserviceaccount.com:objectViewer gs://my-bucket
```

### 3. Configure Firewall Rules

The deployment automatically creates:
- Internal gRPC communication between DAIS nodes
- External HTTP API access
- External gRPC access (configurable)

```bash
# View firewall rules
gcloud compute firewall-rules list --filter="name~dais"
```

## Deployment Workflow

### Full Deployment

```swift
// 1. Create deployment configuration
let deployment = GoogleCloudDAISDeployment(
    name: "production",
    provider: GoogleCloudProvider(
        projectID: "my-project",
        region: .usWest1
    ),
    nodeCount: 3,
    machineType: .n2Standard2,
    grpcPort: 9090,
    httpPort: 8080
)

// 2. Generate setup script
let script = deployment.setupScript
// Save to file and run

// 3. Upload DAIS executable
// gcloud compute scp ./dais-executable production-dais-node-1:/opt/dais/

// 4. SSH and start DAIS
// gcloud compute ssh production-dais-node-1
// source /etc/profile.d/dais.sh
// /opt/dais/dais-executable
```

### Teardown

```swift
// Generate teardown script (careful - deletes resources!)
let teardown = deployment.teardownScript
```

## Environment Variables

The deployment sets up these environment variables on each instance:

| Variable | Description | Source |
|----------|-------------|--------|
| `CERTIFICATE_MASTER_KEY` | Encryption key for certificates | Secret Manager |
| `CERTIFICATE_STORAGE_PATH` | Path for certificate storage | `/var/butteryai/certificates` |
| `GRPC_PORT` | Port for gRPC service | Configured (default: 9090) |
| `HTTP_PORT` | Port for HTTP API | Configured (default: 8080) |

## Regions

Choose a region based on your needs:

```swift
// List all regions
GoogleCloudRegion.allCases.forEach { region in
    print("\(region.rawValue): \(region.displayName)")
}

// Free tier eligible regions
// - us-west1 (Oregon)
// - us-central1 (Iowa)
// - us-east1 (South Carolina)
```

## Monitoring

### View Instance Logs

```bash
# SSH to instance
gcloud compute ssh my-dais-node-1 --zone=us-west1-a

# View DAIS logs
tail -f /var/log/dais/dais.log

# View startup logs
cat /var/log/dais/startup.log
```

### Cloud Monitoring

```bash
# Enable monitoring
gcloud services enable monitoring.googleapis.com

# View metrics in Cloud Console
# https://console.cloud.google.com/monitoring
```

## Troubleshooting

### Cannot Access Secret

```bash
# Check IAM permissions
gcloud secrets get-iam-policy butteryai-certificate-master-key

# Verify service account
gcloud compute instances describe my-instance --zone=us-west1-a --format="get(serviceAccounts)"
```

### Instance Won't Start

```bash
# Check serial port output
gcloud compute instances get-serial-port-output my-instance --zone=us-west1-a

# Check startup script logs
gcloud compute ssh my-instance --zone=us-west1-a --command="sudo journalctl -u google-startup-scripts"
```

### Network Issues

```bash
# Test connectivity
gcloud compute ssh my-instance --zone=us-west1-a --command="curl -v localhost:8080/health"

# Check firewall rules
gcloud compute firewall-rules list --filter="name~dais"
```

## Example: Complete Production Setup

```swift
import GoogleCloudSwift

// Production deployment with 3 nodes
let production = GoogleCloudDAISDeployment(
    name: "prod",
    provider: GoogleCloudProvider(
        projectID: "butteryai-production",
        region: .usWest1,
        credentials: .applicationDefault,
        defaultLabels: [
            "environment": "production",
            "team": "platform"
        ]
    ),
    nodeCount: 3,
    machineType: .n2Standard2,
    grpcPort: 9090,
    httpPort: 8080,
    useSpotInstances: false  // Use standard instances for production
)

// Generate deployment artifacts
print("Setup Script:")
print(production.setupScript)

print("\nEstimated Monthly Cost: $\(production.estimatedMonthlyCostUSD)")

print("\nFirewall Rules:")
production.firewallRules.forEach { rule in
    print("  - \(rule.name)")
}

print("\nSecrets:")
print("  - \(production.certificateSecret.name)")

print("\nStorage:")
print("  - \(production.backupBucket.gsutilURI)")
```

## Requirements

- Swift 6.1+
- macOS 15+

## License

MIT License

## Additional Resources

### Core Services
- [Google Cloud Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
- [Cloud Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Pub/Sub Ordering and Delivery](https://cloud.google.com/pubsub/docs/ordering)
- [Cloud Functions Documentation](https://cloud.google.com/functions/docs)
- [Cloud Scheduler Documentation](https://cloud.google.com/scheduler/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run Jobs Documentation](https://cloud.google.com/run/docs/create-jobs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [GKE Node Pools](https://cloud.google.com/kubernetes-engine/docs/concepts/node-pools)
- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept)
- [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity)
- [GKE Release Channels](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels)
- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [Log-Based Metrics Documentation](https://cloud.google.com/logging/docs/logs-based-metrics)
- [Cloud Monitoring Documentation](https://cloud.google.com/monitoring/docs)
- [Alerting Policies Documentation](https://cloud.google.com/monitoring/alerts)
- [Uptime Checks Documentation](https://cloud.google.com/monitoring/uptime-checks)
- [VPC Networks Documentation](https://cloud.google.com/vpc/docs)
- [Firewall Rules Documentation](https://cloud.google.com/vpc/docs/firewalls)
- [Cloud Router Documentation](https://cloud.google.com/network-connectivity/docs/router)
- [Cloud NAT Documentation](https://cloud.google.com/nat/docs)
- [Cloud DNS Documentation](https://cloud.google.com/dns/docs)
- [DNSSEC Documentation](https://cloud.google.com/dns/docs/dnssec)
- [DNS Response Policies](https://cloud.google.com/dns/docs/zones/manage-response-policies)
- [Cloud Load Balancing Documentation](https://cloud.google.com/load-balancing/docs)
- [HTTP(S) Load Balancing](https://cloud.google.com/load-balancing/docs/https)
- [TCP/SSL Proxy Load Balancing](https://cloud.google.com/load-balancing/docs/tcp)
- [Network Endpoint Groups](https://cloud.google.com/load-balancing/docs/negs)
- [Serverless NEGs](https://cloud.google.com/load-balancing/docs/negs/serverless-neg-concepts)
- [SSL Certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates)
- [SSL Policies](https://cloud.google.com/load-balancing/docs/ssl-policies-concepts)
- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Docker Repository Quickstart](https://cloud.google.com/artifact-registry/docs/docker/quickstart)
- [npm Repository Setup](https://cloud.google.com/artifact-registry/docs/nodejs)
- [Python Repository Setup](https://cloud.google.com/artifact-registry/docs/python)
- [Maven Repository Setup](https://cloud.google.com/artifact-registry/docs/java)
- [Vulnerability Scanning](https://cloud.google.com/artifact-registry/docs/analysis)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Build Triggers](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers)
- [Cloud Build Worker Pools](https://cloud.google.com/build/docs/private-pools/private-pools-overview)
- [Cloud Build GitHub Integration](https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github)
- [cloudbuild.yaml Reference](https://cloud.google.com/build/docs/build-config-file-schema)
- [Cloud Armor Documentation](https://cloud.google.com/armor/docs)
- [Cloud Armor Security Policies](https://cloud.google.com/armor/docs/security-policy-overview)
- [Cloud Armor WAF Rules](https://cloud.google.com/armor/docs/waf-rules)
- [Cloud Armor Rate Limiting](https://cloud.google.com/armor/docs/rate-limiting-overview)
- [Cloud Armor Adaptive Protection](https://cloud.google.com/armor/docs/adaptive-protection-overview)
- [Cloud CDN Documentation](https://cloud.google.com/cdn/docs)
- [Cloud CDN Caching](https://cloud.google.com/cdn/docs/caching)
- [Cloud CDN Signed URLs](https://cloud.google.com/cdn/docs/signed-urls)
- [Cloud CDN Cache Invalidation](https://cloud.google.com/cdn/docs/invalidating-cached-content)
- [Cloud Tasks Documentation](https://cloud.google.com/tasks/docs)
- [Cloud Tasks Queues](https://cloud.google.com/tasks/docs/creating-queues)
- [Cloud Tasks HTTP Targets](https://cloud.google.com/tasks/docs/creating-http-target-tasks)
- [Cloud KMS Documentation](https://cloud.google.com/kms/docs)
- [Cloud KMS Key Rings](https://cloud.google.com/kms/docs/creating-keys)
- [Cloud KMS Key Rotation](https://cloud.google.com/kms/docs/key-rotation)
- [Cloud KMS Envelope Encryption](https://cloud.google.com/kms/docs/envelope-encryption)
- [Eventarc Documentation](https://cloud.google.com/eventarc/docs)
- [Eventarc Triggers](https://cloud.google.com/eventarc/docs/creating-triggers)
- [Eventarc Event Types](https://cloud.google.com/eventarc/docs/reference/supported-events)

### Caching Services
- [Memorystore for Redis Documentation](https://cloud.google.com/memorystore/docs/redis)
- [Memorystore for Memcached Documentation](https://cloud.google.com/memorystore/docs/memcached)
- [Redis Best Practices](https://cloud.google.com/memorystore/docs/redis/memory-management-best-practices)

### VPC Service Controls
- [VPC Service Controls Overview](https://cloud.google.com/vpc-service-controls/docs/overview)
- [Service Perimeters](https://cloud.google.com/vpc-service-controls/docs/service-perimeters)
- [Access Levels](https://cloud.google.com/vpc-service-controls/docs/access-levels)
- [Ingress and Egress Rules](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules)

### Cloud Filestore
- [Filestore Documentation](https://cloud.google.com/filestore/docs)
- [Filestore Tiers](https://cloud.google.com/filestore/docs/service-tiers)
- [Filestore Backups](https://cloud.google.com/filestore/docs/backups)
- [NFS Client Configuration](https://cloud.google.com/filestore/docs/mounting-fileshares)

### Cloud VPN
- [Cloud VPN Documentation](https://cloud.google.com/network-connectivity/docs/vpn)
- [HA VPN Overview](https://cloud.google.com/network-connectivity/docs/vpn/concepts/overview)
- [VPN Topologies](https://cloud.google.com/network-connectivity/docs/vpn/concepts/topologies)
- [Cloud Router BGP](https://cloud.google.com/network-connectivity/docs/router/concepts/overview)

### BigQuery
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables)
- [Clustered Tables](https://cloud.google.com/bigquery/docs/clustered-tables)
- [Loading Data](https://cloud.google.com/bigquery/docs/loading-data)
- [Exporting Data](https://cloud.google.com/bigquery/docs/exporting-data)
- [bq Command-Line Tool](https://cloud.google.com/bigquery/docs/bq-command-line-tool)

### Cloud Spanner
- [Cloud Spanner Documentation](https://cloud.google.com/spanner/docs)
- [Spanner Instances](https://cloud.google.com/spanner/docs/instances)
- [Spanner Databases](https://cloud.google.com/spanner/docs/databases)
- [Schema Design Best Practices](https://cloud.google.com/spanner/docs/schema-design)
- [Spanner SQL Reference](https://cloud.google.com/spanner/docs/reference/standard-sql/query-syntax)
- [PostgreSQL Interface](https://cloud.google.com/spanner/docs/postgresql-interface)
- [Backup and Restore](https://cloud.google.com/spanner/docs/backup)
- [Multi-Region Configurations](https://cloud.google.com/spanner/docs/instance-configurations)

### Firestore
- [Firestore Documentation](https://cloud.google.com/firestore/docs)
- [Firestore Data Model](https://cloud.google.com/firestore/docs/data-model)
- [Composite Indexes](https://cloud.google.com/firestore/docs/query-data/indexing)
- [Export and Import](https://cloud.google.com/firestore/docs/manage-data/export-import)
- [Firestore Locations](https://cloud.google.com/firestore/docs/locations)
- [Point-in-Time Recovery](https://cloud.google.com/firestore/docs/backups)
- [Firestore Emulator](https://cloud.google.com/firestore/docs/emulator)

### Vertex AI
- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)
- [Model Training](https://cloud.google.com/vertex-ai/docs/training/overview)
- [Custom Training Containers](https://cloud.google.com/vertex-ai/docs/training/containers-overview)
- [Model Deployment](https://cloud.google.com/vertex-ai/docs/predictions/overview)
- [Pre-built Containers](https://cloud.google.com/vertex-ai/docs/predictions/pre-built-containers)
- [Machine Types](https://cloud.google.com/vertex-ai/docs/training/configure-compute)
- [Accelerators (GPUs)](https://cloud.google.com/vertex-ai/docs/training/configure-compute#accelerators)
- [Model Registry](https://cloud.google.com/vertex-ai/docs/model-registry/introduction)

### Cloud Trace
- [Cloud Trace Documentation](https://cloud.google.com/trace/docs)
- [Trace Overview](https://cloud.google.com/trace/docs/overview)
- [OpenTelemetry Integration](https://cloud.google.com/trace/docs/setup/opentelemetry)
- [Trace Analysis](https://cloud.google.com/trace/docs/analysis)
- [Trace Sinks](https://cloud.google.com/trace/docs/trace-sinks-intro)
- [W3C Trace Context](https://cloud.google.com/trace/docs/trace-context)
- [Latency Explorer](https://cloud.google.com/trace/docs/latency-explorer)
- [Trace IAM Roles](https://cloud.google.com/trace/docs/iam)

### Cloud Profiler
- [Cloud Profiler Documentation](https://cloud.google.com/profiler/docs)
- [Profiling Concepts](https://cloud.google.com/profiler/docs/concepts-profiling)
- [Go Profiler](https://cloud.google.com/profiler/docs/profiling-go)
- [Python Profiler](https://cloud.google.com/profiler/docs/profiling-python)
- [Node.js Profiler](https://cloud.google.com/profiler/docs/profiling-nodejs)
- [Java Profiler](https://cloud.google.com/profiler/docs/profiling-java)
- [Using the Interface](https://cloud.google.com/profiler/docs/using-profiler)
- [Profiler IAM Roles](https://cloud.google.com/profiler/docs/iam)

### Error Reporting
- [Error Reporting Documentation](https://cloud.google.com/error-reporting/docs)
- [Reporting Errors](https://cloud.google.com/error-reporting/docs/setup)
- [Viewing Errors](https://cloud.google.com/error-reporting/docs/viewing-errors)
- [Managing Error Groups](https://cloud.google.com/error-reporting/docs/managing-errors)
- [Go Client Library](https://cloud.google.com/error-reporting/docs/setup/go)
- [Python Client Library](https://cloud.google.com/error-reporting/docs/setup/python)
- [Node.js Client Library](https://cloud.google.com/error-reporting/docs/setup/nodejs)
- [Error Reporting IAM Roles](https://cloud.google.com/error-reporting/docs/iam)

### Cloud Bigtable
- [Cloud Bigtable Documentation](https://cloud.google.com/bigtable/docs)
- [Bigtable Overview](https://cloud.google.com/bigtable/docs/overview)
- [Schema Design](https://cloud.google.com/bigtable/docs/schema-design)
- [Creating Instances](https://cloud.google.com/bigtable/docs/creating-instance)
- [Creating Tables](https://cloud.google.com/bigtable/docs/creating-table)
- [cbt CLI Reference](https://cloud.google.com/bigtable/docs/cbt-reference)
- [App Profiles](https://cloud.google.com/bigtable/docs/app-profiles)
- [Replication](https://cloud.google.com/bigtable/docs/replication-overview)
- [Backups](https://cloud.google.com/bigtable/docs/backups)
- [Bigtable IAM Roles](https://cloud.google.com/bigtable/docs/access-control)

### Dataproc
- [Dataproc Documentation](https://cloud.google.com/dataproc/docs)
- [Cluster Management](https://cloud.google.com/dataproc/docs/concepts/configuring-clusters)
- [Submitting Jobs](https://cloud.google.com/dataproc/docs/concepts/jobs/life-of-a-job)
- [Dataproc Serverless](https://cloud.google.com/dataproc-serverless/docs)
- [Workflow Templates](https://cloud.google.com/dataproc/docs/concepts/workflows/overview)
- [Autoscaling](https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/autoscaling)
- [Optional Components](https://cloud.google.com/dataproc/docs/concepts/components/overview)
- [Preemptible/Spot VMs](https://cloud.google.com/dataproc/docs/concepts/compute/preemptible-vms)
- [Dataproc IAM Roles](https://cloud.google.com/dataproc/docs/concepts/iam/iam)

### Cloud Composer
- [Cloud Composer Documentation](https://cloud.google.com/composer/docs)
- [Environment Configuration](https://cloud.google.com/composer/docs/concepts/environment-configuration)
- [Apache Airflow DAGs](https://cloud.google.com/composer/docs/how-to/using/writing-dags)
- [Composer 2 Architecture](https://cloud.google.com/composer/docs/composer-2/composer-2-overview)
- [Workloads Configuration](https://cloud.google.com/composer/docs/composer-2/configure-workloads)
- [Private IP Environments](https://cloud.google.com/composer/docs/how-to/configuring-private-ip)
- [Environment Scaling](https://cloud.google.com/composer/docs/composer-2/scale-environments)
- [Triggering DAGs](https://cloud.google.com/composer/docs/triggering-dags)
- [Composer IAM Roles](https://cloud.google.com/composer/docs/access-control)

### Document AI
- [Document AI Documentation](https://cloud.google.com/document-ai/docs)
- [Processor Types](https://cloud.google.com/document-ai/docs/processors-list)
- [Processing Documents](https://cloud.google.com/document-ai/docs/send-request)
- [Batch Processing](https://cloud.google.com/document-ai/docs/send-batch-request)
- [Custom Processors](https://cloud.google.com/document-ai/docs/workbench/build-custom-processor)
- [Human Review](https://cloud.google.com/document-ai/docs/human-review)
- [Processor Versions](https://cloud.google.com/document-ai/docs/manage-processor-versions)
- [Specialized Processors](https://cloud.google.com/document-ai/docs/specialized-processors)
- [Document AI IAM Roles](https://cloud.google.com/document-ai/docs/access-control)

### Vision AI
- [Cloud Vision Documentation](https://cloud.google.com/vision/docs)
- [Detecting Labels](https://cloud.google.com/vision/docs/labels)
- [Detecting Faces](https://cloud.google.com/vision/docs/detecting-faces)
- [Detecting Text (OCR)](https://cloud.google.com/vision/docs/ocr)
- [Detecting Objects](https://cloud.google.com/vision/docs/object-localizer)
- [Safe Search Detection](https://cloud.google.com/vision/docs/detecting-safe-search)
- [Product Search](https://cloud.google.com/vision/docs/product-search)
- [Batch Processing](https://cloud.google.com/vision/docs/batch)
- [Vision AI Client Libraries](https://cloud.google.com/vision/docs/libraries)

### Speech-to-Text
- [Speech-to-Text Documentation](https://cloud.google.com/speech-to-text/docs)
- [Transcription Models](https://cloud.google.com/speech-to-text/docs/transcription-model)
- [Speech Adaptation](https://cloud.google.com/speech-to-text/docs/adaptation)
- [Long-Running Recognition](https://cloud.google.com/speech-to-text/docs/async-recognize)
- [Streaming Recognition](https://cloud.google.com/speech-to-text/docs/streaming-recognize)
- [Class Tokens](https://cloud.google.com/speech-to-text/docs/class-tokens)
- [Multi-Channel Recognition](https://cloud.google.com/speech-to-text/docs/multi-channel)
- [Speech-to-Text Client Libraries](https://cloud.google.com/speech-to-text/docs/libraries)

### Text-to-Speech
- [Text-to-Speech Documentation](https://cloud.google.com/text-to-speech/docs)
- [Available Voices](https://cloud.google.com/text-to-speech/docs/voices)
- [SSML Reference](https://cloud.google.com/text-to-speech/docs/ssml)
- [Audio Profiles](https://cloud.google.com/text-to-speech/docs/audio-profiles)
- [Custom Voice](https://cloud.google.com/text-to-speech/docs/custom-voice)
- [Long Audio Synthesis](https://cloud.google.com/text-to-speech/docs/create-audio-text-long-audio-synthesis)
- [Pricing](https://cloud.google.com/text-to-speech/pricing)
- [Text-to-Speech Client Libraries](https://cloud.google.com/text-to-speech/docs/libraries)

### Translation AI
- [Cloud Translation Documentation](https://cloud.google.com/translate/docs)
- [Supported Languages](https://cloud.google.com/translate/docs/languages)
- [Glossaries](https://cloud.google.com/translate/docs/advanced/glossary)
- [Batch Translation](https://cloud.google.com/translate/docs/advanced/batch-translation)
- [Document Translation](https://cloud.google.com/translate/docs/advanced/translate-documents)
- [Custom Models](https://cloud.google.com/translate/docs/advanced/automl-overview)
- [Adaptive MT](https://cloud.google.com/translate/docs/advanced/adaptive-mt)
- [Translation Client Libraries](https://cloud.google.com/translate/docs/reference/libraries)

### Cloud Batch
- [Cloud Batch Documentation](https://cloud.google.com/batch/docs)
- [Batch Jobs Overview](https://cloud.google.com/batch/docs/get-started)
- [Creating Jobs](https://cloud.google.com/batch/docs/create-run-job)
- [Container Runnables](https://cloud.google.com/batch/docs/create-run-job-container-image)
- [Script Runnables](https://cloud.google.com/batch/docs/create-run-job-script)
- [Task Groups](https://cloud.google.com/batch/docs/task-groups)
- [GPU Support](https://cloud.google.com/batch/docs/vm-gpus)
- [Environment Variables](https://cloud.google.com/batch/docs/create-run-job-environment-variables)
- [Batch API Reference](https://cloud.google.com/batch/docs/reference/rest)

### Binary Authorization
- [Binary Authorization Documentation](https://cloud.google.com/binary-authorization/docs)
- [Policy Overview](https://cloud.google.com/binary-authorization/docs/policy-yaml-reference)
- [Creating Attestors](https://cloud.google.com/binary-authorization/docs/creating-attestors)
- [Creating Attestations](https://cloud.google.com/binary-authorization/docs/making-attestations)
- [Using Cloud KMS Keys](https://cloud.google.com/binary-authorization/docs/cloud-kms-keys)
- [Continuous Validation](https://cloud.google.com/binary-authorization/docs/continuous-validation)
- [GKE Integration](https://cloud.google.com/binary-authorization/docs/deploy-to-gke)
- [Cloud Run Integration](https://cloud.google.com/binary-authorization/docs/cloud-run)
- [Binary Authorization API](https://cloud.google.com/binary-authorization/docs/reference/rest)

### Certificate Authority Service
- [Certificate Authority Service Documentation](https://cloud.google.com/certificate-authority-service/docs)
- [CA Pools Overview](https://cloud.google.com/certificate-authority-service/docs/ca-pools)
- [Creating Root CAs](https://cloud.google.com/certificate-authority-service/docs/creating-certificate-authorities)
- [Issuing Certificates](https://cloud.google.com/certificate-authority-service/docs/creating-certificates)
- [Certificate Templates](https://cloud.google.com/certificate-authority-service/docs/certificate-templates)
- [Key Algorithms](https://cloud.google.com/certificate-authority-service/docs/key-algorithms)
- [Issuance Policies](https://cloud.google.com/certificate-authority-service/docs/issuance-policies)
- [Certificate Revocation](https://cloud.google.com/certificate-authority-service/docs/revoke-certificates)
- [CAS API Reference](https://cloud.google.com/certificate-authority-service/docs/reference/rest)

### Network Intelligence Center
- [Network Intelligence Center Documentation](https://cloud.google.com/network-intelligence-center/docs)
- [Connectivity Tests Overview](https://cloud.google.com/network-intelligence-center/docs/connectivity-tests/concepts/overview)
- [Creating Connectivity Tests](https://cloud.google.com/network-intelligence-center/docs/connectivity-tests/how-to/creating-connectivity-tests)
- [Analyzing Test Results](https://cloud.google.com/network-intelligence-center/docs/connectivity-tests/concepts/results-analysis)
- [Network Topology](https://cloud.google.com/network-intelligence-center/docs/network-topology/concepts/overview)
- [Firewall Insights](https://cloud.google.com/network-intelligence-center/docs/firewall-insights/concepts/overview)
- [Performance Dashboard](https://cloud.google.com/network-intelligence-center/docs/performance-dashboard/concepts/overview)
- [Network Management API](https://cloud.google.com/network-intelligence-center/docs/connectivity-tests/reference/networkmanagement/rest)

### Cloud Interconnect
- [Cloud Interconnect Documentation](https://cloud.google.com/network-connectivity/docs/interconnect)
- [Dedicated Interconnect Overview](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/dedicated-overview)
- [Partner Interconnect Overview](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-overview)
- [Cross-Cloud Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/cross-cloud-overview)
- [HA VPN and Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/ha-interconnect)
- [Interconnect Locations](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/choosing-colocation-facilities)
- [Cloud Router for Interconnect](https://cloud.google.com/network-connectivity/docs/router/concepts/overview)
- [BGP Sessions](https://cloud.google.com/network-connectivity/docs/router/concepts/overview#bgp-sessions)

### Cloud Healthcare API
- [Cloud Healthcare API Documentation](https://cloud.google.com/healthcare-api/docs)
- [FHIR Overview](https://cloud.google.com/healthcare-api/docs/concepts/fhir)
- [HL7v2 Overview](https://cloud.google.com/healthcare-api/docs/concepts/hl7v2)
- [DICOM Overview](https://cloud.google.com/healthcare-api/docs/concepts/dicom)
- [Consent Management](https://cloud.google.com/healthcare-api/docs/concepts/consent)
- [De-identification](https://cloud.google.com/healthcare-api/docs/how-tos/deidentify)
- [BigQuery Streaming](https://cloud.google.com/healthcare-api/docs/how-tos/fhir-bigquery-streaming)
- [Healthcare API Reference](https://cloud.google.com/healthcare-api/docs/reference/rest)

### Dataflow
- [Dataflow Documentation](https://cloud.google.com/dataflow/docs)
- [Apache Beam Programming Guide](https://beam.apache.org/documentation/programming-guide/)
- [Google-Provided Templates](https://cloud.google.com/dataflow/docs/guides/templates/provided-templates)
- [Flex Templates](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates)
- [Streaming Engine](https://cloud.google.com/dataflow/docs/streaming-engine)
- [Dataflow SQL](https://cloud.google.com/dataflow/docs/guides/sql/dataflow-sql-intro)
- [Job Snapshots](https://cloud.google.com/dataflow/docs/guides/snapshots)

### Cloud Deploy
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- [Delivery Pipelines](https://cloud.google.com/deploy/docs/create-pipeline-targets)
- [Deploy Targets](https://cloud.google.com/deploy/docs/deploy-app-targets)
- [Releases and Rollouts](https://cloud.google.com/deploy/docs/deploying-application)
- [Deployment Strategies](https://cloud.google.com/deploy/docs/deployment-strategies)
- [Canary Deployments](https://cloud.google.com/deploy/docs/deployment-strategies/canary)
- [Rollout Approvals](https://cloud.google.com/deploy/docs/promote-release)
- [Skaffold Configuration](https://cloud.google.com/deploy/docs/using-skaffold)

### Cloud Workflows
- [Cloud Workflows Documentation](https://cloud.google.com/workflows/docs)
- [Workflow Syntax](https://cloud.google.com/workflows/docs/reference/syntax)
- [Standard Library](https://cloud.google.com/workflows/docs/reference/stdlib/overview)
- [Connectors](https://cloud.google.com/workflows/docs/reference/googleapis)
- [Parallel Execution](https://cloud.google.com/workflows/docs/execute-parallel-steps)
- [Error Handling](https://cloud.google.com/workflows/docs/reference/syntax/catching-errors)
- [Callbacks](https://cloud.google.com/workflows/docs/creating-callback-endpoints)

### API Gateway
- [API Gateway Documentation](https://cloud.google.com/api-gateway/docs)
- [OpenAPI Specification](https://cloud.google.com/api-gateway/docs/openapi-overview)
- [Authentication](https://cloud.google.com/api-gateway/docs/authenticate-service-account)
- [API Keys](https://cloud.google.com/api-gateway/docs/using-api-keys)
- [JWT Validation](https://cloud.google.com/api-gateway/docs/authenticating-users-jwt)
- [Backend Configuration](https://cloud.google.com/api-gateway/docs/backends)
- [Monitoring and Logging](https://cloud.google.com/api-gateway/docs/monitoring)

### Cloud DLP
- [Cloud DLP Documentation](https://cloud.google.com/dlp/docs)
- [Info Types Reference](https://cloud.google.com/dlp/docs/infotypes-reference)
- [Inspecting Content](https://cloud.google.com/dlp/docs/inspecting-text)
- [De-identification](https://cloud.google.com/dlp/docs/deidentify-sensitive-data)
- [Masking and Tokenization](https://cloud.google.com/dlp/docs/transformations-reference)
- [Job Triggers](https://cloud.google.com/dlp/docs/creating-job-triggers)
- [Templates](https://cloud.google.com/dlp/docs/creating-templates)
- [Custom Info Types](https://cloud.google.com/dlp/docs/creating-custom-infotypes)

### Management APIs
- [Service Usage API Documentation](https://cloud.google.com/service-usage/docs)
- [Cloud IAM Documentation](https://cloud.google.com/iam/docs)
- [Resource Manager Documentation](https://cloud.google.com/resource-manager/docs)

### Infrastructure Deployment
- [Infrastructure Manager Documentation](https://cloud.google.com/infrastructure-manager/docs)
- [Deployment Manager Documentation](https://cloud.google.com/deployment-manager/docs) (Deprecated - EOL March 2026)

### Cost & Planning
- [Pricing Calculator](https://cloud.google.com/products/calculator)
- [Free Tier Details](https://cloud.google.com/free)
