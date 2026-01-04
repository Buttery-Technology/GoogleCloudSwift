//
//  GoogleCloudDAISDeployment.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 12/9/25.
//

import Foundation

/// Complete deployment configuration for running DAIS on Google Cloud Platform.
///
/// This struct combines all Google Cloud resources needed for a DAIS deployment:
/// - Compute Engine instances for running DAIS nodes
/// - Secret Manager for secure credential storage
/// - Cloud Storage for backups and artifacts
/// - Firewall rules for gRPC communication
///
/// ## Example Usage
/// ```swift
/// let deployment = GoogleCloudDAISDeployment(
///     name: "production",
///     provider: GoogleCloudProvider(
///         projectID: "my-butteryai-project",
///         region: .usWest1
///     ),
///     nodeCount: 3,
///     machineType: .n2Standard2
/// )
///
/// // Generate setup script
/// print(deployment.setupScript)
/// ```
public struct GoogleCloudDAISDeployment: Codable, Sendable, Equatable {
    /// Deployment name (used as prefix for resources)
    public let name: String

    /// Google Cloud provider configuration
    public let provider: GoogleCloudProvider

    /// Number of DAIS nodes to deploy
    public let nodeCount: Int

    /// Machine type for nodes
    public let machineType: GoogleCloudMachineType

    /// Compute instance configuration
    public let instanceConfig: GoogleCloudComputeInstance

    /// Secret Manager configuration for certificate key
    public let certificateSecret: GoogleCloudSecret

    /// Storage bucket for backups
    public let backupBucket: GoogleCloudStorageBucket

    /// gRPC port for DAIS communication
    public let grpcPort: Int

    /// HTTP port for API
    public let httpPort: Int

    /// Whether to use spot instances (cost savings)
    public let useSpotInstances: Bool

    public init(
        name: String,
        provider: GoogleCloudProvider,
        nodeCount: Int = 1,
        machineType: GoogleCloudMachineType = .e2Medium,
        grpcPort: Int = 9090,
        httpPort: Int = 8080,
        useSpotInstances: Bool = false
    ) {
        self.name = name
        self.provider = provider
        self.nodeCount = nodeCount
        self.machineType = machineType
        self.grpcPort = grpcPort
        self.httpPort = httpPort
        self.useSpotInstances = useSpotInstances

        // Generate instance configuration
        self.instanceConfig = GoogleCloudComputeInstance(
            name: "\(name)-dais-node",
            machineType: machineType,
            zone: provider.zone ?? provider.region.defaultZone,
            bootDisk: .init(
                image: .ubuntuLTS,
                sizeGB: 20,
                diskType: .pdBalanced
            ),
            networkTags: ["\(name)-dais", "allow-grpc", "allow-http"],
            labels: [
                "app": "butteryai",
                "deployment": name,
                "component": "dais-node"
            ],
            scheduling: useSpotInstances ? .spot : .standard
        )

        // Generate secret configuration
        self.certificateSecret = DAISSecretTemplate.certificateMasterKey(projectID: provider.projectID)

        // Generate backup bucket (use project ID as suffix for uniqueness)
        let bucketSuffix = provider.projectID.prefix(20).lowercased().replacingOccurrences(of: "_", with: "-")
        self.backupBucket = DAISBucketTemplate.certificateBackups(
            projectID: provider.projectID,
            bucketSuffix: bucketSuffix
        )
    }

    /// Estimated monthly cost in USD
    public var estimatedMonthlyCostUSD: Double {
        let instanceCost = machineType.approximateMonthlyCostUSD * Double(nodeCount)
        let spotDiscount = useSpotInstances ? 0.3 : 1.0 // ~70% discount for spot
        let storageCost = 5.0 // Estimate for minimal storage
        return (instanceCost * spotDiscount) + storageCost
    }
}

// MARK: - Firewall Rules

extension GoogleCloudDAISDeployment {
    /// Firewall rule configuration
    public struct FirewallRule: Codable, Sendable, Equatable {
        public let name: String
        public let network: String
        public let direction: String
        public let priority: Int
        public let targetTags: [String]
        public let sourceTags: [String]?
        public let sourceRanges: [String]?
        public let allowedPorts: [String]
        public let protocol_: String

        public var createCommand: String {
            var cmd = "gcloud compute firewall-rules create \(name)"
            cmd += " --network=\(network)"
            cmd += " --direction=\(direction)"
            cmd += " --priority=\(priority)"
            cmd += " --action=ALLOW"
            cmd += " --rules=\(protocol_):\(allowedPorts.joined(separator: ","))"
            cmd += " --target-tags=\(targetTags.joined(separator: ","))"
            if let sourceRanges = sourceRanges {
                cmd += " --source-ranges=\(sourceRanges.joined(separator: ","))"
            }
            if let sourceTags = sourceTags {
                cmd += " --source-tags=\(sourceTags.joined(separator: ","))"
            }
            return cmd
        }
    }

    /// Firewall rules for DAIS deployment
    public var firewallRules: [FirewallRule] {
        [
            // Allow gRPC between DAIS nodes
            FirewallRule(
                name: "\(name)-allow-grpc-internal",
                network: "default",
                direction: "INGRESS",
                priority: 1000,
                targetTags: ["\(name)-dais"],
                sourceTags: ["\(name)-dais"],
                sourceRanges: nil,
                allowedPorts: ["\(grpcPort)"],
                protocol_: "tcp"
            ),
            // Allow HTTP API access
            FirewallRule(
                name: "\(name)-allow-http",
                network: "default",
                direction: "INGRESS",
                priority: 1000,
                targetTags: ["allow-http"],
                sourceTags: nil,
                sourceRanges: ["0.0.0.0/0"],
                allowedPorts: ["\(httpPort)"],
                protocol_: "tcp"
            ),
            // Allow gRPC from external (if needed)
            FirewallRule(
                name: "\(name)-allow-grpc-external",
                network: "default",
                direction: "INGRESS",
                priority: 1000,
                targetTags: ["allow-grpc"],
                sourceTags: nil,
                sourceRanges: ["0.0.0.0/0"],
                allowedPorts: ["\(grpcPort)"],
                protocol_: "tcp"
            )
        ]
    }
}

// MARK: - Setup Script Generation

extension GoogleCloudDAISDeployment {
    /// Service account flags for gcloud command
    private var serviceAccountFlags: String {
        guard let sa = instanceConfig.serviceAccount else {
            return "--scopes=cloud-platform"
        }
        let scopes = sa.scopes.joined(separator: ",")
        return "--service-account=\(sa.email) --scopes=\(scopes)"
    }

    /// Scheduling flags for gcloud command
    private var schedulingFlags: String {
        var flags: [String] = []

        if instanceConfig.scheduling.spot {
            flags.append("--provisioning-model=SPOT")
            flags.append("--instance-termination-action=STOP")
        } else if instanceConfig.scheduling.preemptible {
            flags.append("--preemptible")
        }

        if !instanceConfig.scheduling.automaticRestart {
            flags.append("--no-restart-on-failure")
        }

        flags.append("--maintenance-policy=\(instanceConfig.scheduling.onHostMaintenance.rawValue)")

        return flags.joined(separator: " \\\n                    ")
    }

    /// Labels flag for gcloud command
    private var labelsFlag: String {
        guard !instanceConfig.labels.isEmpty else { return "" }
        let labelPairs = instanceConfig.labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
        return "--labels=\(labelPairs)"
    }

    /// Generate a complete setup script for this deployment
    public var setupScript: String {
        """
        #!/bin/bash
        # DAIS Deployment Setup Script for Google Cloud Platform
        # Deployment: \(name)
        # Project: \(provider.projectID)
        # Region: \(provider.region.rawValue)
        # Generated: \(ISO8601DateFormatter().string(from: Date()))

        set -e

        echo "========================================"
        echo "DAIS Google Cloud Deployment Setup"
        echo "========================================"

        # Configuration
        PROJECT_ID="\(provider.projectID)"
        REGION="\(provider.region.rawValue)"
        ZONE="\(provider.zone ?? provider.region.defaultZone)"
        DEPLOYMENT_NAME="\(name)"

        # Set project
        echo "Setting project to $PROJECT_ID..."
        gcloud config set project $PROJECT_ID

        # Enable required APIs
        echo "Enabling required APIs..."
        gcloud services enable compute.googleapis.com
        gcloud services enable secretmanager.googleapis.com
        gcloud services enable storage.googleapis.com

        # Create Secret Manager secret for certificate key
        echo "Creating certificate master key secret..."
        if ! gcloud secrets describe \(certificateSecret.name) --project=$PROJECT_ID 2>/dev/null; then
            openssl rand -hex 32 | gcloud secrets create \(certificateSecret.name) \\
                --project=$PROJECT_ID \\
                --replication-policy=automatic \\
                --data-file=-
            echo "Secret created. IMPORTANT: Back up this key!"
        else
            echo "Secret already exists, skipping..."
        fi

        # Create backup bucket
        echo "Creating backup storage bucket..."
        if ! gsutil ls \(backupBucket.gsutilURI) 2>/dev/null; then
            \(backupBucket.setupCommands)
            echo "Bucket created: \(backupBucket.gsutilURI)"
        else
            echo "Bucket already exists, skipping..."
        fi

        # Create firewall rules
        echo "Creating firewall rules..."
        \(firewallRules.map { rule in
            """
            if ! gcloud compute firewall-rules describe \(rule.name) 2>/dev/null; then
                \(rule.createCommand)
            else
                echo "Firewall rule \(rule.name) already exists, skipping..."
            fi
            """
        }.joined(separator: "\n"))

        # Create compute instances
        echo "Creating DAIS node instances..."
        for i in $(seq 1 \(nodeCount)); do
            INSTANCE_NAME="${DEPLOYMENT_NAME}-dais-node-${i}"

            if ! gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE 2>/dev/null; then
                gcloud compute instances create $INSTANCE_NAME \\
                    --project=$PROJECT_ID \\
                    --zone=$ZONE \\
                    --machine-type=\(machineType.rawValue) \\
                    --image-family=\(instanceConfig.bootDisk.image.imageFamily) \\
                    --image-project=\(instanceConfig.bootDisk.image.imageProject) \\
                    --boot-disk-size=\(instanceConfig.bootDisk.sizeGB)GB \\
                    --boot-disk-type=\(instanceConfig.bootDisk.diskType.rawValue) \\
                    \(instanceConfig.bootDisk.autoDelete ? "--boot-disk-auto-delete" : "--no-boot-disk-auto-delete") \\
                    --tags=\(instanceConfig.networkTags.joined(separator: ",")) \\
                    --network=\(instanceConfig.network.network) \\
                    \(instanceConfig.network.subnetwork.map { "--subnet=\($0)" } ?? "") \\
                    \(instanceConfig.network.assignExternalIP ? "" : "--no-address") \\
                    \(instanceConfig.network.assignExternalIP ? "--network-tier=\(instanceConfig.network.networkTier.rawValue)" : "") \\
                    \(serviceAccountFlags) \\
                    \(schedulingFlags) \\
                    \(instanceConfig.deletionProtection ? "--deletion-protection" : "") \\
                    \(labelsFlag) \\
                    --metadata=startup-script='#!/bin/bash
        # Install dependencies
        apt-get update
        apt-get install -y curl wget

        # Create DAIS directory
        mkdir -p /opt/dais
        mkdir -p /var/butteryai/certificates

        # Set up environment
        cat > /etc/profile.d/dais.sh << EOF
        export CERTIFICATE_MASTER_KEY=\\$(gcloud secrets versions access latest --secret=\(certificateSecret.name))
        export CERTIFICATE_STORAGE_PATH=/var/butteryai/certificates
        export GRPC_PORT=\(grpcPort)
        export HTTP_PORT=\(httpPort)
        EOF

        echo "DAIS node setup complete. Deploy your DAIS executable to /opt/dais/"
        '
                echo "Created instance: $INSTANCE_NAME"
            else
                echo "Instance $INSTANCE_NAME already exists, skipping..."
            fi
        done

        echo ""
        echo "========================================"
        echo "Deployment Complete!"
        echo "========================================"
        echo ""
        echo "Next steps:"
        echo "1. Upload your DAIS executable to each instance:"
        echo "   gcloud compute scp ./dais-executable ${DEPLOYMENT_NAME}-dais-node-1:/opt/dais/ --zone=$ZONE"
        echo ""
        echo "2. SSH to an instance and run DAIS:"
        echo "   gcloud compute ssh ${DEPLOYMENT_NAME}-dais-node-1 --zone=$ZONE"
        echo "   source /etc/profile.d/dais.sh"
        echo "   /opt/dais/dais-executable"
        echo ""
        echo "3. Access Secret Manager key:"
        echo "   \(certificateSecret.accessCommand)"
        echo ""
        echo "Estimated monthly cost: $\(String(format: "%.2f", estimatedMonthlyCostUSD)) USD"
        """
    }

    /// Generate a teardown script to remove all resources
    public var teardownScript: String {
        """
        #!/bin/bash
        # DAIS Deployment Teardown Script
        # Deployment: \(name)
        # WARNING: This will delete all resources!

        set -e

        PROJECT_ID="\(provider.projectID)"
        ZONE="\(provider.zone ?? provider.region.defaultZone)"
        DEPLOYMENT_NAME="\(name)"

        echo "WARNING: This will delete all DAIS deployment resources!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Aborted."
            exit 1
        fi

        # Delete instances
        echo "Deleting compute instances..."
        for i in $(seq 1 \(nodeCount)); do
            INSTANCE_NAME="${DEPLOYMENT_NAME}-dais-node-${i}"
            gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE --quiet || true
        done

        # Delete firewall rules
        echo "Deleting firewall rules..."
        \(firewallRules.map { "gcloud compute firewall-rules delete \($0.name) --quiet || true" }.joined(separator: "\n"))

        # Note: Secrets and buckets are NOT deleted automatically for safety
        echo ""
        echo "Instances and firewall rules deleted."
        echo ""
        echo "The following resources were NOT deleted (manual cleanup required):"
        echo "- Secret: \(certificateSecret.name)"
        echo "- Bucket: \(backupBucket.gsutilURI)"
        echo ""
        echo "To delete secrets (WARNING: unrecoverable):"
        echo "  gcloud secrets delete \(certificateSecret.name)"
        echo ""
        echo "To delete bucket (WARNING: deletes all backups):"
        echo "  gsutil rm -r \(backupBucket.gsutilURI)"
        """
    }
}

// MARK: - Instance Startup Script

extension GoogleCloudDAISDeployment {
    /// Generate a startup script for DAIS instances
    public func startupScript(
        daisExecutablePath: String = "/opt/dais/dais-executable",
        configPath: String = "/etc/dais/config.json"
    ) -> String {
        """
        #!/bin/bash
        # DAIS Node Startup Script
        # Auto-generated for deployment: \(name)

        set -e

        # Load environment variables
        source /etc/profile.d/dais.sh

        # Fetch certificate master key from Secret Manager
        export CERTIFICATE_MASTER_KEY=$(gcloud secrets versions access latest --secret=\(certificateSecret.name))

        # Set up paths
        export CERTIFICATE_STORAGE_PATH=/var/butteryai/certificates
        export DAIS_CONFIG_PATH=\(configPath)

        # Ensure directories exist
        mkdir -p /var/butteryai/certificates
        mkdir -p /var/log/dais

        # Log startup
        echo "$(date): Starting DAIS node..." >> /var/log/dais/startup.log

        # Run DAIS executable
        cd /opt/dais
        if [ -f "\(daisExecutablePath)" ]; then
            chmod +x \(daisExecutablePath)
            \(daisExecutablePath) \\
                --grpc-port \(grpcPort) \\
                --http-port \(httpPort) \\
                >> /var/log/dais/dais.log 2>&1
        else
            echo "ERROR: DAIS executable not found at \(daisExecutablePath)" >> /var/log/dais/startup.log
            exit 1
        fi
        """
    }
}
