//
//  GoogleCloudInfrastructureManager.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

/// Models for Google Cloud Infrastructure Manager API.
///
/// Infrastructure Manager is the recommended replacement for Deployment Manager.
/// It uses Terraform to create and manage Google Cloud resources.
///
/// ## Key Benefits
/// - Uses standard Terraform configurations
/// - State management and drift detection
/// - Preview changes before applying
/// - Integration with Cloud Build and Cloud Source Repositories
///
/// ## Example Usage
/// ```swift
/// let deployment = InfrastructureManagerDeployment(
///     name: "my-infra",
///     projectID: "my-project",
///     location: "us-central1",
///     serviceAccount: "infra@my-project.iam.gserviceaccount.com"
/// )
/// print(deployment.createCommand)
/// ```
public struct InfrastructureManagerDeployment: Codable, Sendable, Equatable {
    /// Name of the deployment
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location (region) for the deployment
    public let location: String

    /// Service account for executing Terraform
    public let serviceAccount: String?

    /// Labels for organization
    public let labels: [String: String]

    /// Terraform blueprint source
    public let blueprint: TerraformBlueprint?

    public init(
        name: String,
        projectID: String,
        location: String,
        serviceAccount: String? = nil,
        labels: [String: String] = [:],
        blueprint: TerraformBlueprint? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.serviceAccount = serviceAccount
        self.labels = labels
        self.blueprint = blueprint
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/deployments/\(name)"
    }

    /// gcloud command to create this deployment
    public var createCommand: String {
        var cmd = "gcloud infra-manager deployments apply \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        if let serviceAccount = serviceAccount {
            cmd += " --service-account=\(serviceAccount)"
        }
        if let blueprint = blueprint {
            switch blueprint.source {
            case .git(let repo, let directory, let ref):
                cmd += " --git-source-repo=\(repo)"
                if let dir = directory {
                    cmd += " --git-source-directory=\(dir)"
                }
                if let ref = ref {
                    cmd += " --git-source-ref=\(ref)"
                }
            case .gcs(let bucket, let object):
                cmd += " --gcs-source=gs://\(bucket)/\(object)"
            case .local(let path):
                cmd += " --local-source=\(path)"
            }
        }
        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }
        return cmd
    }

    /// gcloud command to delete this deployment
    public var deleteCommand: String {
        "gcloud infra-manager deployments delete \(name) --project=\(projectID) --location=\(location) --quiet"
    }

    /// gcloud command to describe this deployment
    public var describeCommand: String {
        "gcloud infra-manager deployments describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to list all deployments
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud infra-manager deployments list --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to export Terraform state
    public var exportStateCommand: String {
        "gcloud infra-manager deployments export-state \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to lock the deployment
    public var lockCommand: String {
        "gcloud infra-manager deployments lock \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to unlock the deployment
    public var unlockCommand: String {
        "gcloud infra-manager deployments unlock \(name) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Deployment State

extension InfrastructureManagerDeployment {
    /// State of an Infrastructure Manager deployment
    public enum DeploymentState: String, Codable, Sendable {
        /// Deployment is being created
        case creating = "CREATING"
        /// Deployment is active
        case active = "ACTIVE"
        /// Deployment is being updated
        case updating = "UPDATING"
        /// Deployment is being deleted
        case deleting = "DELETING"
        /// Deployment failed
        case failed = "FAILED"
        /// Deployment is suspended
        case suspended = "SUSPENDED"
        /// Deployment is deleted
        case deleted = "DELETED"
    }

    /// Lock state of a deployment
    public enum LockState: String, Codable, Sendable {
        /// Deployment is unlocked
        case unlocked = "UNLOCKED"
        /// Deployment is locked
        case locked = "LOCKED"
        /// Lock is being acquired
        case locking = "LOCKING"
        /// Lock is being released
        case unlocking = "UNLOCKING"
    }
}

// MARK: - Terraform Blueprint

/// Represents a Terraform blueprint source
public struct TerraformBlueprint: Codable, Sendable, Equatable {
    /// Source of the Terraform configuration
    public let source: BlueprintSource

    /// Input variables for Terraform
    public let inputValues: [String: String]

    public init(
        source: BlueprintSource,
        inputValues: [String: String] = [:]
    ) {
        self.source = source
        self.inputValues = inputValues
    }

    /// Blueprint source types
    public enum BlueprintSource: Codable, Sendable, Equatable {
        /// Git repository source
        case git(repo: String, directory: String?, ref: String?)
        /// Google Cloud Storage source
        case gcs(bucket: String, object: String)
        /// Local directory source
        case local(path: String)
    }
}

// MARK: - Revision

/// Represents a deployment revision
public struct InfrastructureManagerRevision: Codable, Sendable, Equatable {
    /// Revision name
    public let name: String

    /// Deployment name
    public let deploymentName: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// State of the revision
    public let state: RevisionState

    public init(
        name: String,
        deploymentName: String,
        projectID: String,
        location: String,
        state: RevisionState = .applying
    ) {
        self.name = name
        self.deploymentName = deploymentName
        self.projectID = projectID
        self.location = location
        self.state = state
    }

    /// Revision states
    public enum RevisionState: String, Codable, Sendable {
        /// Revision is being applied
        case applying = "APPLYING"
        /// Revision was applied successfully
        case applied = "APPLIED"
        /// Revision failed to apply
        case failed = "FAILED"
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/deployments/\(deploymentName)/revisions/\(name)"
    }

    /// gcloud command to describe this revision
    public var describeCommand: String {
        "gcloud infra-manager revisions describe \(name) --deployment=\(deploymentName) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to list revisions
    public static func listCommand(deploymentName: String, projectID: String, location: String) -> String {
        "gcloud infra-manager revisions list --deployment=\(deploymentName) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Preview

/// Represents a deployment preview (dry-run)
public struct InfrastructureManagerPreview: Codable, Sendable, Equatable {
    /// Preview name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Deployment to preview (optional, for updates)
    public let deploymentName: String?

    /// Service account for executing preview
    public let serviceAccount: String?

    /// Terraform blueprint source
    public let blueprint: TerraformBlueprint?

    public init(
        name: String,
        projectID: String,
        location: String,
        deploymentName: String? = nil,
        serviceAccount: String? = nil,
        blueprint: TerraformBlueprint? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.deploymentName = deploymentName
        self.serviceAccount = serviceAccount
        self.blueprint = blueprint
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/previews/\(name)"
    }

    /// gcloud command to create a preview
    public var createCommand: String {
        var cmd = "gcloud infra-manager previews create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        if let deploymentName = deploymentName {
            cmd += " --deployment=\(deploymentName)"
        }
        if let serviceAccount = serviceAccount {
            cmd += " --service-account=\(serviceAccount)"
        }
        if let blueprint = blueprint {
            switch blueprint.source {
            case .git(let repo, let directory, let ref):
                cmd += " --git-source-repo=\(repo)"
                if let dir = directory {
                    cmd += " --git-source-directory=\(dir)"
                }
                if let ref = ref {
                    cmd += " --git-source-ref=\(ref)"
                }
            case .gcs(let bucket, let object):
                cmd += " --gcs-source=gs://\(bucket)/\(object)"
            case .local(let path):
                cmd += " --local-source=\(path)"
            }
        }
        return cmd
    }

    /// gcloud command to delete this preview
    public var deleteCommand: String {
        "gcloud infra-manager previews delete \(name) --project=\(projectID) --location=\(location) --quiet"
    }

    /// gcloud command to describe this preview
    public var describeCommand: String {
        "gcloud infra-manager previews describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to export preview results
    public var exportCommand: String {
        "gcloud infra-manager previews export \(name) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Preview State

extension InfrastructureManagerPreview {
    /// State of a preview
    public enum PreviewState: String, Codable, Sendable {
        /// Preview is being created
        case creating = "CREATING"
        /// Preview succeeded
        case succeeded = "SUCCEEDED"
        /// Preview is stale
        case stale = "STALE"
        /// Preview failed
        case failed = "FAILED"
        /// Preview is being deleted
        case deleting = "DELETING"
        /// Preview is deleted
        case deleted = "DELETED"
    }
}

// MARK: - DAIS Infrastructure Templates

/// Predefined Infrastructure Manager configurations for DAIS
public enum DAISInfrastructureTemplate {
    /// Generate Terraform configuration for DAIS deployment
    public static func terraformConfig(
        deploymentName: String,
        projectID: String,
        region: String,
        zone: String,
        nodeCount: Int,
        machineType: GoogleCloudMachineType,
        grpcPort: Int = 9090,
        httpPort: Int = 8080
    ) -> String {
        """
        # DAIS Infrastructure - Terraform Configuration
        # Generated by GoogleCloudSwift

        terraform {
          required_providers {
            google = {
              source  = "hashicorp/google"
              version = "~> 5.0"
            }
          }
        }

        provider "google" {
          project = "\(projectID)"
          region  = "\(region)"
        }

        # Firewall rule for gRPC
        resource "google_compute_firewall" "\(deploymentName)_grpc" {
          name    = "\(deploymentName)-allow-grpc"
          network = "default"

          allow {
            protocol = "tcp"
            ports    = ["\(grpcPort)"]
          }

          source_ranges = ["0.0.0.0/0"]
          target_tags   = ["\(deploymentName)-dais"]
        }

        # Firewall rule for HTTP
        resource "google_compute_firewall" "\(deploymentName)_http" {
          name    = "\(deploymentName)-allow-http"
          network = "default"

          allow {
            protocol = "tcp"
            ports    = ["\(httpPort)"]
          }

          source_ranges = ["0.0.0.0/0"]
          target_tags   = ["\(deploymentName)-dais"]
        }

        # DAIS Node Instances
        resource "google_compute_instance" "\(deploymentName)_node" {
          count        = \(nodeCount)
          name         = "\(deploymentName)-node-${count.index + 1}"
          machine_type = "\(machineType.rawValue)"
          zone         = "\(zone)"

          boot_disk {
            initialize_params {
              image = "ubuntu-os-cloud/ubuntu-2204-lts"
              size  = 20
            }
          }

          network_interface {
            network = "default"
            access_config {}
          }

          tags = ["\(deploymentName)-dais"]

          metadata_startup_script = <<-EOF
            #!/bin/bash
            apt-get update
            apt-get install -y curl wget
            mkdir -p /opt/dais
            mkdir -p /var/butteryai/certificates
            echo "DAIS node ${count.index + 1} ready"
          EOF

          labels = {
            app         = "butteryai"
            deployment  = "\(deploymentName)"
            component   = "dais-node"
          }
        }

        # Outputs
        output "instance_ips" {
          value = google_compute_instance.\(deploymentName)_node[*].network_interface[0].access_config[0].nat_ip
        }

        output "instance_names" {
          value = google_compute_instance.\(deploymentName)_node[*].name
        }
        """
    }

    /// Create deployment configuration for Infrastructure Manager
    public static func deployment(
        name: String,
        projectID: String,
        location: String,
        gitRepo: String,
        gitRef: String = "main",
        serviceAccountEmail: String? = nil
    ) -> InfrastructureManagerDeployment {
        InfrastructureManagerDeployment(
            name: name,
            projectID: projectID,
            location: location,
            serviceAccount: serviceAccountEmail,
            labels: [
                "app": "butteryai",
                "managed-by": "dais"
            ],
            blueprint: TerraformBlueprint(
                source: .git(repo: gitRepo, directory: nil, ref: gitRef)
            )
        )
    }

    /// Generate a setup script for Infrastructure Manager deployment
    public static func setupScript(
        deployment: InfrastructureManagerDeployment,
        terraformConfig: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Infrastructure Manager Setup Script
        # Deployment: \(deployment.name)
        # Project: \(deployment.projectID)

        set -e

        echo "========================================"
        echo "DAIS Infrastructure Manager Deployment"
        echo "========================================"

        # Enable required APIs
        echo "Enabling Infrastructure Manager API..."
        gcloud services enable config.googleapis.com --project=\(deployment.projectID)

        # Create Terraform configuration
        echo "Creating Terraform configuration..."
        mkdir -p /tmp/dais-terraform
        cat > /tmp/dais-terraform/main.tf << 'TERRAFORM_EOF'
        \(terraformConfig)
        TERRAFORM_EOF

        # Create the deployment
        echo "Creating Infrastructure Manager deployment..."
        \(deployment.createCommand) --local-source=/tmp/dais-terraform

        # Wait for deployment
        echo "Waiting for deployment to complete..."
        gcloud infra-manager deployments describe \(deployment.name) \\
            --project=\(deployment.projectID) \\
            --location=\(deployment.location) \\
            --format="value(state)"

        echo ""
        echo "Deployment complete!"
        echo "View deployment: \(deployment.describeCommand)"
        """
    }
}
