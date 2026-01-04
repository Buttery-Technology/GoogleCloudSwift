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

GoogleCloudSwift provides models for 29 Google Cloud services:

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
