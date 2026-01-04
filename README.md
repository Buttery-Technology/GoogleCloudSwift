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

GoogleCloudSwift provides models for 11 Google Cloud services:

| Module | Purpose | Key Types |
|--------|---------|-----------|
| **Provider** | Project & region configuration | `GoogleCloudProvider`, `GoogleCloudRegion` |
| **Compute Engine** | VM instances | `GoogleCloudComputeInstance`, `GoogleCloudMachineType` |
| **Secret Manager** | Secure credentials | `GoogleCloudSecret`, `SecretManagerIAMBinding` |
| **Cloud Storage** | Object storage | `GoogleCloudStorageBucket`, `LifecycleRule` |
| **Cloud SQL** | Managed databases (PostgreSQL, MySQL, SQL Server) | `GoogleCloudSQLInstance`, `GoogleCloudSQLDatabase` |
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
