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

- [Google Cloud Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Pricing Calculator](https://cloud.google.com/products/calculator)
- [Free Tier Details](https://cloud.google.com/free)
