//
//  GoogleCloudDeploymentManager.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

/// Models for Google Cloud Deployment Manager API.
///
/// ⚠️ **DEPRECATION NOTICE**: Cloud Deployment Manager will reach end of support
/// on March 31, 2026. Consider using `GoogleCloudInfrastructureManager` instead,
/// which is based on Terraform.
///
/// Deployment Manager allows you to deploy Google Cloud resources defined in
/// YAML, Python, or Jinja2 templates.
///
/// ## Example Usage
/// ```swift
/// let deployment = GoogleCloudDeployment(
///     name: "my-deployment",
///     projectID: "my-project",
///     description: "Production infrastructure"
/// )
/// print(deployment.createCommand)
/// ```
@available(*, deprecated, message: "Cloud Deployment Manager reaches end of support on March 31, 2026. Use GoogleCloudInfrastructureManager (Terraform-based) instead.")
public struct GoogleCloudDeployment: Codable, Sendable, Equatable {
    /// Name of the deployment
    public let name: String

    /// Project ID
    public let projectID: String

    /// Description of the deployment
    public let description: String?

    /// Labels for organization
    public let labels: [String: String]

    /// Path to the configuration file (YAML)
    public let configPath: String?

    /// Path to the template file (Jinja2 or Python)
    public let templatePath: String?

    /// Properties to pass to the template
    public let properties: [String: String]

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        labels: [String: String] = [:],
        configPath: String? = nil,
        templatePath: String? = nil,
        properties: [String: String] = [:]
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.labels = labels
        self.configPath = configPath
        self.templatePath = templatePath
        self.properties = properties
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/deployments/\(name)"
    }

    /// gcloud command to create this deployment
    public var createCommand: String {
        var cmd = "gcloud deployment-manager deployments create \(name)"
        cmd += " --project=\(projectID)"
        if let configPath = configPath {
            cmd += " --config=\(configPath)"
        }
        if let templatePath = templatePath {
            cmd += " --template=\(templatePath)"
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }
        if !properties.isEmpty {
            let propPairs = properties.map { "\($0.key):\($0.value)" }.joined(separator: ",")
            cmd += " --properties=\(propPairs)"
        }
        return cmd
    }

    /// gcloud command to update this deployment
    public var updateCommand: String {
        var cmd = "gcloud deployment-manager deployments update \(name)"
        cmd += " --project=\(projectID)"
        if let configPath = configPath {
            cmd += " --config=\(configPath)"
        }
        if let templatePath = templatePath {
            cmd += " --template=\(templatePath)"
        }
        return cmd
    }

    /// gcloud command to delete this deployment
    public var deleteCommand: String {
        "gcloud deployment-manager deployments delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this deployment
    public var describeCommand: String {
        "gcloud deployment-manager deployments describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list resources in this deployment
    public var listResourcesCommand: String {
        "gcloud deployment-manager resources list --deployment=\(name) --project=\(projectID)"
    }

    /// gcloud command to preview changes (dry-run)
    public var previewCommand: String {
        var cmd = "gcloud deployment-manager deployments update \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --preview"
        if let configPath = configPath {
            cmd += " --config=\(configPath)"
        }
        return cmd
    }

    /// gcloud command to cancel a preview
    public var cancelPreviewCommand: String {
        "gcloud deployment-manager deployments cancel-preview \(name) --project=\(projectID)"
    }
}

// MARK: - Deployment State

extension GoogleCloudDeployment {
    /// State of a deployment
    public enum DeploymentState: String, Codable, Sendable {
        /// Deployment is being created
        case pending = "PENDING"
        /// Deployment is running
        case running = "RUNNING"
        /// Deployment completed successfully
        case done = "DONE"
        /// Deployment failed
        case failed = "FAILED"
        /// Deployment was cancelled
        case cancelled = "CANCELLED"
    }
}

// MARK: - Deployment Manifest

/// Represents a deployment manifest (configuration snapshot)
@available(*, deprecated, message: "Cloud Deployment Manager reaches end of support on March 31, 2026. Use GoogleCloudInfrastructureManager (Terraform-based) instead.")
public struct GoogleCloudDeploymentManifest: Codable, Sendable, Equatable {
    /// Deployment name
    public let deploymentName: String

    /// Project ID
    public let projectID: String

    /// Manifest ID
    public let manifestID: String

    public init(
        deploymentName: String,
        projectID: String,
        manifestID: String
    ) {
        self.deploymentName = deploymentName
        self.projectID = projectID
        self.manifestID = manifestID
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/deployments/\(deploymentName)/manifests/\(manifestID)"
    }

    /// gcloud command to get this manifest
    public var describeCommand: String {
        "gcloud deployment-manager manifests describe \(manifestID) --deployment=\(deploymentName) --project=\(projectID)"
    }

    /// gcloud command to list all manifests for the deployment
    public static func listCommand(deploymentName: String, projectID: String) -> String {
        "gcloud deployment-manager manifests list --deployment=\(deploymentName) --project=\(projectID)"
    }
}

// MARK: - Deployment Resource

/// Represents a resource within a deployment
@available(*, deprecated, message: "Cloud Deployment Manager reaches end of support on March 31, 2026. Use GoogleCloudInfrastructureManager (Terraform-based) instead.")
public struct GoogleCloudDeploymentResource: Codable, Sendable, Equatable {
    /// Resource name
    public let name: String

    /// Resource type (e.g., "compute.v1.instance")
    public let type: String

    /// Deployment name
    public let deploymentName: String

    /// Project ID
    public let projectID: String

    public init(
        name: String,
        type: String,
        deploymentName: String,
        projectID: String
    ) {
        self.name = name
        self.type = type
        self.deploymentName = deploymentName
        self.projectID = projectID
    }

    /// gcloud command to describe this resource
    public var describeCommand: String {
        "gcloud deployment-manager resources describe \(name) --deployment=\(deploymentName) --project=\(projectID)"
    }
}

// MARK: - Deployment Types

/// Common Deployment Manager resource types
@available(*, deprecated, message: "Cloud Deployment Manager reaches end of support on March 31, 2026. Use GoogleCloudInfrastructureManager (Terraform-based) instead.")
public enum GoogleCloudDeploymentType: String, Codable, Sendable, CaseIterable {
    // Compute
    case instance = "compute.v1.instance"
    case disk = "compute.v1.disk"
    case network = "compute.v1.network"
    case subnetwork = "compute.v1.subnetwork"
    case firewall = "compute.v1.firewall"
    case address = "compute.v1.address"
    case instanceGroup = "compute.v1.instanceGroup"
    case instanceTemplate = "compute.v1.instanceTemplate"
    case healthCheck = "compute.v1.healthCheck"

    // Storage
    case bucket = "storage.v1.bucket"

    // IAM
    case serviceAccount = "iam.v1.serviceAccount"

    // Pub/Sub
    case topic = "pubsub.v1.topic"
    case subscription = "pubsub.v1.subscription"

    // SQL
    case sqlInstance = "sqladmin.v1beta4.instance"
    case sqlDatabase = "sqladmin.v1beta4.database"

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .instance: return "Compute Instance"
        case .disk: return "Persistent Disk"
        case .network: return "VPC Network"
        case .subnetwork: return "Subnetwork"
        case .firewall: return "Firewall Rule"
        case .address: return "Static IP Address"
        case .instanceGroup: return "Instance Group"
        case .instanceTemplate: return "Instance Template"
        case .healthCheck: return "Health Check"
        case .bucket: return "Storage Bucket"
        case .serviceAccount: return "Service Account"
        case .topic: return "Pub/Sub Topic"
        case .subscription: return "Pub/Sub Subscription"
        case .sqlInstance: return "Cloud SQL Instance"
        case .sqlDatabase: return "Cloud SQL Database"
        }
    }
}

// MARK: - DAIS Deployment Templates

/// Predefined Deployment Manager configurations for DAIS
@available(*, deprecated, message: "Cloud Deployment Manager reaches end of support on March 31, 2026. Use GoogleCloudInfrastructureManager (Terraform-based) instead.")
public enum DAISDeploymentManagerTemplate {
    /// Generate a YAML configuration for a DAIS compute instance
    public static func instanceConfig(
        name: String,
        machineType: GoogleCloudMachineType,
        zone: String,
        networkTags: [String] = ["dais-node"]
    ) -> String {
        """
        resources:
        - name: \(name)
          type: compute.v1.instance
          properties:
            zone: \(zone)
            machineType: zones/\(zone)/machineTypes/\(machineType.rawValue)
            disks:
            - deviceName: boot
              type: PERSISTENT
              boot: true
              autoDelete: true
              initializeParams:
                sourceImage: projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts
            networkInterfaces:
            - network: global/networks/default
              accessConfigs:
              - name: External NAT
                type: ONE_TO_ONE_NAT
            tags:
              items:
              \(networkTags.map { "- \($0)" }.joined(separator: "\n          "))
        """
    }

    /// Generate a complete DAIS deployment configuration
    public static func completeDeploymentConfig(
        deploymentName: String,
        nodeCount: Int,
        machineType: GoogleCloudMachineType,
        zone: String,
        grpcPort: Int = 9090,
        httpPort: Int = 8080
    ) -> String {
        var resources: [String] = []

        // Add firewall rules
        resources.append("""
        - name: \(deploymentName)-allow-grpc
          type: compute.v1.firewall
          properties:
            network: global/networks/default
            allowed:
            - IPProtocol: TCP
              ports:
              - "\(grpcPort)"
            sourceRanges:
            - "0.0.0.0/0"
            targetTags:
            - \(deploymentName)-dais
        """)

        resources.append("""
        - name: \(deploymentName)-allow-http
          type: compute.v1.firewall
          properties:
            network: global/networks/default
            allowed:
            - IPProtocol: TCP
              ports:
              - "\(httpPort)"
            sourceRanges:
            - "0.0.0.0/0"
            targetTags:
            - \(deploymentName)-dais
        """)

        // Add instances
        for i in 1...nodeCount {
            resources.append("""
        - name: \(deploymentName)-node-\(i)
          type: compute.v1.instance
          properties:
            zone: \(zone)
            machineType: zones/\(zone)/machineTypes/\(machineType.rawValue)
            disks:
            - deviceName: boot
              type: PERSISTENT
              boot: true
              autoDelete: true
              initializeParams:
                sourceImage: projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts
                diskSizeGb: 20
            networkInterfaces:
            - network: global/networks/default
              accessConfigs:
              - name: External NAT
                type: ONE_TO_ONE_NAT
            tags:
              items:
              - \(deploymentName)-dais
            metadata:
              items:
              - key: startup-script
                value: |
                  #!/bin/bash
                  apt-get update
                  apt-get install -y curl wget
                  mkdir -p /opt/dais
                  mkdir -p /var/butteryai/certificates
                  echo "DAIS node \(i) ready"
        """)
        }

        return """
        resources:
        \(resources.joined(separator: "\n"))
        """
    }
}
