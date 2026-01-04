//
//  GoogleCloudIAM.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/3/26.
//

import Foundation

/// Models for Google Cloud Identity and Access Management (IAM) API.
///
/// Cloud IAM lets you manage access control by defining who (identity) has what access (role)
/// for which resource.
///
/// ## Key Concepts
/// - **Service Account**: An identity for applications to authenticate to Google Cloud
/// - **Role**: A collection of permissions
/// - **Policy**: Binds members to roles for a resource
///
/// ## Example Usage
/// ```swift
/// let serviceAccount = GoogleCloudServiceAccount(
///     name: "dais-node",
///     projectID: "my-project",
///     displayName: "DAIS Node Service Account"
/// )
/// print(serviceAccount.createCommand)
/// ```
public struct GoogleCloudServiceAccount: Codable, Sendable, Equatable {
    /// The service account name (without @project.iam.gserviceaccount.com)
    public let name: String

    /// The project ID
    public let projectID: String

    /// Human-readable display name
    public let displayName: String

    /// Description of the service account's purpose
    public let description: String?

    /// Whether the service account is disabled
    public let disabled: Bool

    public init(
        name: String,
        projectID: String,
        displayName: String,
        description: String? = nil,
        disabled: Bool = false
    ) {
        self.name = name
        self.projectID = projectID
        self.displayName = displayName
        self.description = description
        self.disabled = disabled
    }

    /// The full email address of the service account
    public var email: String {
        "\(name)@\(projectID).iam.gserviceaccount.com"
    }

    /// The full resource name
    public var resourceName: String {
        "projects/\(projectID)/serviceAccounts/\(email)"
    }

    /// The member string for IAM policies
    public var memberString: String {
        "serviceAccount:\(email)"
    }

    /// gcloud command to create this service account
    public var createCommand: String {
        var cmd = "gcloud iam service-accounts create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --display-name=\"\(displayName)\""
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// gcloud command to delete this service account
    public var deleteCommand: String {
        "gcloud iam service-accounts delete \(email) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this service account
    public var describeCommand: String {
        "gcloud iam service-accounts describe \(email) --project=\(projectID)"
    }

    /// gcloud command to create a key for this service account
    public func createKeyCommand(outputPath: String) -> String {
        "gcloud iam service-accounts keys create \(outputPath) --iam-account=\(email) --project=\(projectID)"
    }

    /// gcloud command to list keys for this service account
    public var listKeysCommand: String {
        "gcloud iam service-accounts keys list --iam-account=\(email) --project=\(projectID)"
    }
}

// MARK: - IAM Role

/// Represents an IAM role
public struct GoogleCloudIAMRole: Codable, Sendable, Equatable {
    /// The role ID (e.g., "roles/compute.admin" or custom role name)
    public let roleID: String

    /// Whether this is a predefined or custom role
    public let type: RoleType

    /// Title of the role
    public let title: String?

    /// Description of the role
    public let description: String?

    /// Permissions included in this role (for custom roles)
    public let permissions: [String]?

    public init(
        roleID: String,
        type: RoleType = .predefined,
        title: String? = nil,
        description: String? = nil,
        permissions: [String]? = nil
    ) {
        self.roleID = roleID
        self.type = type
        self.title = title
        self.description = description
        self.permissions = permissions
    }

    /// Role types
    public enum RoleType: String, Codable, Sendable {
        /// Predefined Google Cloud role
        case predefined
        /// Custom role created for the project/organization
        case custom
    }
}

// MARK: - Predefined Roles

/// Common predefined IAM roles
public enum GoogleCloudPredefinedRole: String, Codable, Sendable, CaseIterable {
    // Basic Roles
    /// Full access to all resources
    case owner = "roles/owner"
    /// Edit access to all resources
    case editor = "roles/editor"
    /// Read access to all resources
    case viewer = "roles/viewer"

    // Compute Roles
    /// Full control of Compute Engine resources
    case computeAdmin = "roles/compute.admin"
    /// Read-only access to Compute Engine
    case computeViewer = "roles/compute.viewer"
    /// Create and manage instances
    case computeInstanceAdmin = "roles/compute.instanceAdmin.v1"

    // Storage Roles
    /// Full control of Cloud Storage
    case storageAdmin = "roles/storage.admin"
    /// Create and manage objects
    case storageObjectAdmin = "roles/storage.objectAdmin"
    /// Read objects
    case storageObjectViewer = "roles/storage.objectViewer"
    /// Create objects
    case storageObjectCreator = "roles/storage.objectCreator"

    // Secret Manager Roles
    /// Full control of secrets
    case secretManagerAdmin = "roles/secretmanager.admin"
    /// Read secret values
    case secretManagerAccessor = "roles/secretmanager.secretAccessor"
    /// Read secret metadata (not values)
    case secretManagerViewer = "roles/secretmanager.viewer"

    // IAM Roles
    /// Manage service accounts
    case iamServiceAccountAdmin = "roles/iam.serviceAccountAdmin"
    /// Use service accounts
    case iamServiceAccountUser = "roles/iam.serviceAccountUser"
    /// Create service account tokens
    case iamServiceAccountTokenCreator = "roles/iam.serviceAccountTokenCreator"
    /// Create and manage workload identities
    case iamWorkloadIdentityUser = "roles/iam.workloadIdentityUser"

    // Logging & Monitoring Roles
    /// Write logs
    case loggingLogWriter = "roles/logging.logWriter"
    /// Read logs
    case loggingViewer = "roles/logging.viewer"
    /// Write monitoring data
    case monitoringMetricWriter = "roles/monitoring.metricWriter"
    /// Read monitoring data
    case monitoringViewer = "roles/monitoring.viewer"

    // Project Roles
    /// Browser access to project
    case browser = "roles/browser"
    /// Manage project IAM policies
    case iamSecurityAdmin = "roles/iam.securityAdmin"

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .owner: return "Owner"
        case .editor: return "Editor"
        case .viewer: return "Viewer"
        case .computeAdmin: return "Compute Admin"
        case .computeViewer: return "Compute Viewer"
        case .computeInstanceAdmin: return "Compute Instance Admin"
        case .storageAdmin: return "Storage Admin"
        case .storageObjectAdmin: return "Storage Object Admin"
        case .storageObjectViewer: return "Storage Object Viewer"
        case .storageObjectCreator: return "Storage Object Creator"
        case .secretManagerAdmin: return "Secret Manager Admin"
        case .secretManagerAccessor: return "Secret Manager Accessor"
        case .secretManagerViewer: return "Secret Manager Viewer"
        case .iamServiceAccountAdmin: return "Service Account Admin"
        case .iamServiceAccountUser: return "Service Account User"
        case .iamServiceAccountTokenCreator: return "Service Account Token Creator"
        case .iamWorkloadIdentityUser: return "Workload Identity User"
        case .loggingLogWriter: return "Logs Writer"
        case .loggingViewer: return "Logs Viewer"
        case .monitoringMetricWriter: return "Monitoring Metric Writer"
        case .monitoringViewer: return "Monitoring Viewer"
        case .browser: return "Browser"
        case .iamSecurityAdmin: return "Security Admin"
        }
    }
}

// MARK: - IAM Policy Binding

/// Represents an IAM policy binding (member + role)
public struct GoogleCloudIAMBinding: Codable, Sendable, Equatable {
    /// The resource to bind to (project, bucket, secret, etc.)
    public let resource: String

    /// The resource type for gcloud command
    public let resourceType: ResourceType

    /// The role to grant
    public let role: String

    /// The member to grant the role to
    public let member: String

    /// Optional condition for the binding
    public let condition: IAMCondition?

    public init(
        resource: String,
        resourceType: ResourceType,
        role: String,
        member: String,
        condition: IAMCondition? = nil
    ) {
        self.resource = resource
        self.resourceType = resourceType
        self.role = role
        self.member = member
        self.condition = condition
    }

    /// Convenience initializer for project-level bindings
    public init(
        projectID: String,
        role: GoogleCloudPredefinedRole,
        serviceAccount: GoogleCloudServiceAccount
    ) {
        self.resource = projectID
        self.resourceType = .project
        self.role = role.rawValue
        self.member = serviceAccount.memberString
        self.condition = nil
    }

    /// Resource types for IAM bindings
    public enum ResourceType: String, Codable, Sendable {
        case project = "projects"
        case bucket = "storage buckets"
        case secret = "secrets"
        case serviceAccount = "service-accounts"
        case computeInstance = "compute instances"
        case folder = "folders"
        case organization = "organizations"
    }

    /// gcloud command to add this IAM binding
    public var addBindingCommand: String {
        var cmd: String
        switch resourceType {
        case .project:
            cmd = "gcloud projects add-iam-policy-binding \(resource)"
        case .bucket:
            cmd = "gcloud storage buckets add-iam-policy-binding gs://\(resource)"
        case .secret:
            cmd = "gcloud secrets add-iam-policy-binding \(resource)"
        case .serviceAccount:
            cmd = "gcloud iam service-accounts add-iam-policy-binding \(resource)"
        case .computeInstance:
            cmd = "gcloud compute instances add-iam-policy-binding \(resource)"
        case .folder:
            cmd = "gcloud resource-manager folders add-iam-policy-binding \(resource)"
        case .organization:
            cmd = "gcloud organizations add-iam-policy-binding \(resource)"
        }
        cmd += " --member=\(member) --role=\(role)"
        if let condition = condition {
            cmd += " --condition=\"\(condition.asString)\""
        }
        return cmd
    }

    /// gcloud command to remove this IAM binding
    public var removeBindingCommand: String {
        var cmd: String
        switch resourceType {
        case .project:
            cmd = "gcloud projects remove-iam-policy-binding \(resource)"
        case .bucket:
            cmd = "gcloud storage buckets remove-iam-policy-binding gs://\(resource)"
        case .secret:
            cmd = "gcloud secrets remove-iam-policy-binding \(resource)"
        case .serviceAccount:
            cmd = "gcloud iam service-accounts remove-iam-policy-binding \(resource)"
        case .computeInstance:
            cmd = "gcloud compute instances remove-iam-policy-binding \(resource)"
        case .folder:
            cmd = "gcloud resource-manager folders remove-iam-policy-binding \(resource)"
        case .organization:
            cmd = "gcloud organizations remove-iam-policy-binding \(resource)"
        }
        cmd += " --member=\(member) --role=\(role)"
        return cmd
    }
}

// MARK: - IAM Condition

/// Represents a condition for conditional IAM bindings
public struct IAMCondition: Codable, Sendable, Equatable {
    /// Title of the condition
    public let title: String

    /// Description of the condition
    public let description: String?

    /// CEL expression for the condition
    public let expression: String

    public init(title: String, description: String? = nil, expression: String) {
        self.title = title
        self.description = description
        self.expression = expression
    }

    /// Format as gcloud condition string
    public var asString: String {
        var result = "title=\(title),expression=\(expression)"
        if let description = description {
            result += ",description=\(description)"
        }
        return result
    }

    /// Common condition: expire after date
    public static func expiresAfter(date: Date, title: String = "Expires") -> IAMCondition {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        return IAMCondition(
            title: title,
            expression: "request.time < timestamp('\(dateString)')"
        )
    }

    /// Common condition: only during business hours
    public static let businessHoursOnly = IAMCondition(
        title: "Business Hours",
        description: "Only allow access during business hours",
        expression: "request.time.getHours('America/Los_Angeles') >= 9 && request.time.getHours('America/Los_Angeles') <= 17"
    )
}

// MARK: - DAIS Service Account Templates

/// Predefined service account configurations for DAIS
public enum DAISServiceAccountTemplate {
    /// Service account for DAIS compute nodes
    public static func nodeServiceAccount(projectID: String, deploymentName: String) -> GoogleCloudServiceAccount {
        GoogleCloudServiceAccount(
            name: "\(deploymentName)-dais-node",
            projectID: projectID,
            displayName: "DAIS Node Service Account",
            description: "Service account for DAIS compute node instances"
        )
    }

    /// Service account for DAIS deployment automation
    public static func deploymentServiceAccount(projectID: String) -> GoogleCloudServiceAccount {
        GoogleCloudServiceAccount(
            name: "dais-deployment",
            projectID: projectID,
            displayName: "DAIS Deployment Service Account",
            description: "Service account for DAIS deployment automation"
        )
    }

    /// Roles required for a DAIS node service account
    public static let nodeRoles: [GoogleCloudPredefinedRole] = [
        .secretManagerAccessor,
        .storageObjectViewer,
        .loggingLogWriter,
        .monitoringMetricWriter
    ]

    /// Roles required for deployment automation
    public static let deploymentRoles: [GoogleCloudPredefinedRole] = [
        .computeAdmin,
        .storageAdmin,
        .secretManagerAdmin,
        .iamServiceAccountAdmin
    ]

    /// Generate IAM bindings for a DAIS node service account
    public static func nodeBindings(
        projectID: String,
        serviceAccount: GoogleCloudServiceAccount
    ) -> [GoogleCloudIAMBinding] {
        nodeRoles.map { role in
            GoogleCloudIAMBinding(
                projectID: projectID,
                role: role,
                serviceAccount: serviceAccount
            )
        }
    }

    /// Generate a setup script for creating a DAIS service account with roles
    public static func setupScript(
        projectID: String,
        serviceAccount: GoogleCloudServiceAccount,
        roles: [GoogleCloudPredefinedRole]
    ) -> String {
        let bindings = roles.map { role in
            GoogleCloudIAMBinding(
                projectID: projectID,
                role: role,
                serviceAccount: serviceAccount
            )
        }

        return """
        #!/bin/bash
        # Create DAIS Service Account and Assign Roles
        # Project: \(projectID)

        set -e

        # Create service account
        echo "Creating service account: \(serviceAccount.name)..."
        if ! gcloud iam service-accounts describe \(serviceAccount.email) --project=\(projectID) 2>/dev/null; then
            \(serviceAccount.createCommand)
            echo "Service account created."
        else
            echo "Service account already exists, skipping..."
        fi

        # Assign roles
        echo "Assigning IAM roles..."
        \(bindings.map { $0.addBindingCommand }.joined(separator: "\n"))

        echo "Service account setup complete."
        echo "Email: \(serviceAccount.email)"
        """
    }
}
