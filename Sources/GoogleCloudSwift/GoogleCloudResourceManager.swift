//
//  GoogleCloudResourceManager.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/3/26.
//

import Foundation

/// Models for Google Cloud Resource Manager API.
///
/// The Resource Manager API enables you to programmatically manage resources
/// in the Google Cloud resource hierarchy (organizations, folders, and projects).
///
/// ## Resource Hierarchy
/// ```
/// Organization
/// └── Folders
///     └── Projects
///         └── Resources (VMs, buckets, etc.)
/// ```
///
/// ## Example Usage
/// ```swift
/// let project = GoogleCloudProject(
///     projectID: "my-dais-project",
///     name: "My DAIS Project",
///     labels: ["environment": "production"]
/// )
/// print(project.createCommand)
/// ```
public struct GoogleCloudProject: Codable, Sendable, Equatable {
    /// Unique project identifier (immutable after creation)
    public let projectID: String

    /// Human-readable project name
    public let name: String

    /// Parent resource (folder or organization)
    public let parent: ProjectParent?

    /// Labels for organization and filtering
    public let labels: [String: String]

    /// Current state of the project
    public let state: ProjectState

    public init(
        projectID: String,
        name: String,
        parent: ProjectParent? = nil,
        labels: [String: String] = [:],
        state: ProjectState = .active
    ) {
        self.projectID = projectID
        self.name = name
        self.parent = parent
        self.labels = labels
        self.state = state
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)"
    }

    /// gcloud command to create this project
    public var createCommand: String {
        var cmd = "gcloud projects create \(projectID)"
        cmd += " --name=\"\(name)\""
        if let parent = parent {
            switch parent {
            case .folder(let folderID):
                cmd += " --folder=\(folderID)"
            case .organization(let orgID):
                cmd += " --organization=\(orgID)"
            }
        }
        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }
        return cmd
    }

    /// gcloud command to delete this project
    public var deleteCommand: String {
        "gcloud projects delete \(projectID) --quiet"
    }

    /// gcloud command to describe this project
    public var describeCommand: String {
        "gcloud projects describe \(projectID)"
    }

    /// gcloud command to update labels
    public func updateLabelsCommand(labels: [String: String]) -> String {
        let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
        return "gcloud projects update \(projectID) --update-labels=\(labelPairs)"
    }

    /// gcloud command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud projects get-iam-policy \(projectID) --format=yaml"
    }
}

// MARK: - Project Parent

extension GoogleCloudProject {
    /// Parent resource for a project
    public enum ProjectParent: Codable, Sendable, Equatable {
        /// Project is under a folder
        case folder(id: String)
        /// Project is directly under an organization
        case organization(id: String)

        public var displayString: String {
            switch self {
            case .folder(let id): return "folders/\(id)"
            case .organization(let id): return "organizations/\(id)"
            }
        }
    }
}

// MARK: - Project State

extension GoogleCloudProject {
    /// Lifecycle state of a project
    public enum ProjectState: String, Codable, Sendable {
        /// Project is active and usable
        case active = "ACTIVE"
        /// Project is pending deletion
        case deleteRequested = "DELETE_REQUESTED"
        /// Project is pending creation
        case pending = "PENDING"
        /// State is unknown
        case unknown = "STATE_UNSPECIFIED"
    }
}

// MARK: - Organization

/// Represents a Google Cloud Organization
public struct GoogleCloudOrganization: Codable, Sendable, Equatable {
    /// Organization ID
    public let organizationID: String

    /// Display name
    public let displayName: String

    /// Organization domain (e.g., "example.com")
    public let domain: String?

    public init(
        organizationID: String,
        displayName: String,
        domain: String? = nil
    ) {
        self.organizationID = organizationID
        self.displayName = displayName
        self.domain = domain
    }

    /// Full resource name
    public var resourceName: String {
        "organizations/\(organizationID)"
    }

    /// gcloud command to describe this organization
    public var describeCommand: String {
        "gcloud organizations describe \(organizationID)"
    }

    /// gcloud command to list organizations
    public static var listCommand: String {
        "gcloud organizations list --format=\"table(name,displayName,owner.directoryCustomerId)\""
    }

    /// gcloud command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud organizations get-iam-policy \(organizationID) --format=yaml"
    }
}

// MARK: - Folder

/// Represents a Google Cloud Folder
public struct GoogleCloudFolder: Codable, Sendable, Equatable {
    /// Folder ID
    public let folderID: String

    /// Display name
    public let displayName: String

    /// Parent resource (organization or another folder)
    public let parent: FolderParent

    /// Current state of the folder
    public let state: FolderState

    public init(
        folderID: String,
        displayName: String,
        parent: FolderParent,
        state: FolderState = .active
    ) {
        self.folderID = folderID
        self.displayName = displayName
        self.parent = parent
        self.state = state
    }

    /// Full resource name
    public var resourceName: String {
        "folders/\(folderID)"
    }

    /// gcloud command to create this folder
    public var createCommand: String {
        var cmd = "gcloud resource-manager folders create"
        cmd += " --display-name=\"\(displayName)\""
        switch parent {
        case .folder(let parentFolderID):
            cmd += " --folder=\(parentFolderID)"
        case .organization(let orgID):
            cmd += " --organization=\(orgID)"
        }
        return cmd
    }

    /// gcloud command to delete this folder
    public var deleteCommand: String {
        "gcloud resource-manager folders delete \(folderID) --quiet"
    }

    /// gcloud command to describe this folder
    public var describeCommand: String {
        "gcloud resource-manager folders describe \(folderID)"
    }

    /// gcloud command to list child folders
    public var listChildFoldersCommand: String {
        "gcloud resource-manager folders list --folder=\(folderID)"
    }

    /// gcloud command to list projects in this folder
    public var listProjectsCommand: String {
        "gcloud projects list --filter=\"parent.id=\(folderID) AND parent.type=folder\""
    }
}

// MARK: - Folder Parent

extension GoogleCloudFolder {
    /// Parent resource for a folder
    public enum FolderParent: Codable, Sendable, Equatable {
        /// Folder is under another folder
        case folder(id: String)
        /// Folder is directly under an organization
        case organization(id: String)

        public var displayString: String {
            switch self {
            case .folder(let id): return "folders/\(id)"
            case .organization(let id): return "organizations/\(id)"
            }
        }
    }
}

// MARK: - Folder State

extension GoogleCloudFolder {
    /// Lifecycle state of a folder
    public enum FolderState: String, Codable, Sendable {
        /// Folder is active
        case active = "ACTIVE"
        /// Folder is pending deletion
        case deleteRequested = "DELETE_REQUESTED"
        /// State is unknown
        case unknown = "STATE_UNSPECIFIED"
    }
}

// MARK: - Resource Tags

/// Represents a tag key for resource organization
public struct GoogleCloudTagKey: Codable, Sendable, Equatable {
    /// Short name of the tag key
    public let shortName: String

    /// Parent resource (organization or project)
    public let parent: String

    /// Description of the tag key
    public let description: String?

    public init(
        shortName: String,
        parent: String,
        description: String? = nil
    ) {
        self.shortName = shortName
        self.parent = parent
        self.description = description
    }

    /// gcloud command to create this tag key
    public var createCommand: String {
        var cmd = "gcloud resource-manager tags keys create \(shortName)"
        cmd += " --parent=\(parent)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }
}

/// Represents a tag value
public struct GoogleCloudTagValue: Codable, Sendable, Equatable {
    /// Short name of the tag value
    public let shortName: String

    /// Parent tag key
    public let parentTagKey: String

    /// Description of the tag value
    public let description: String?

    public init(
        shortName: String,
        parentTagKey: String,
        description: String? = nil
    ) {
        self.shortName = shortName
        self.parentTagKey = parentTagKey
        self.description = description
    }

    /// gcloud command to create this tag value
    public var createCommand: String {
        var cmd = "gcloud resource-manager tags values create \(shortName)"
        cmd += " --parent=\(parentTagKey)"
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }
}

// MARK: - Liens

/// Represents a lien that prevents project deletion
public struct GoogleCloudLien: Codable, Sendable, Equatable {
    /// The project to protect
    public let projectID: String

    /// Reason for the lien
    public let reason: String

    /// Origin of the lien (e.g., "dais-deployment")
    public let origin: String

    /// Restrictions this lien enforces
    public let restrictions: [String]

    public init(
        projectID: String,
        reason: String,
        origin: String,
        restrictions: [String] = ["resourcemanager.projects.delete"]
    ) {
        self.projectID = projectID
        self.reason = reason
        self.origin = origin
        self.restrictions = restrictions
    }

    /// gcloud command to create this lien
    public var createCommand: String {
        let restrictionList = restrictions.joined(separator: ",")
        return """
        gcloud resource-manager liens create \\
            --project=\(projectID) \\
            --reason="\(reason)" \\
            --origin=\(origin) \\
            --restrictions=\(restrictionList)
        """
    }

    /// gcloud command to list liens on a project
    public static func listCommand(projectID: String) -> String {
        "gcloud resource-manager liens list --project=\(projectID)"
    }
}

// MARK: - DAIS Project Templates

/// Predefined project configurations for DAIS
public enum DAISProjectTemplate {
    /// Create a development project configuration
    public static func development(
        projectID: String,
        name: String,
        parent: GoogleCloudProject.ProjectParent? = nil
    ) -> GoogleCloudProject {
        GoogleCloudProject(
            projectID: projectID,
            name: name,
            parent: parent,
            labels: [
                "environment": "development",
                "app": "butteryai",
                "managed-by": "dais"
            ]
        )
    }

    /// Create a production project configuration
    public static func production(
        projectID: String,
        name: String,
        parent: GoogleCloudProject.ProjectParent? = nil
    ) -> GoogleCloudProject {
        GoogleCloudProject(
            projectID: projectID,
            name: name,
            parent: parent,
            labels: [
                "environment": "production",
                "app": "butteryai",
                "managed-by": "dais",
                "criticality": "high"
            ]
        )
    }

    /// Standard folder structure for DAIS deployments
    public static func folderStructure(organizationID: String) -> [String] {
        [
            "DAIS",
            "DAIS/Development",
            "DAIS/Staging",
            "DAIS/Production"
        ]
    }

    /// Generate a complete project setup script
    public static func setupScript(project: GoogleCloudProject, enableAPIs: [GoogleCloudAPI]) -> String {
        """
        #!/bin/bash
        # DAIS Project Setup Script
        # Project: \(project.projectID)

        set -e

        # Create project
        echo "Creating project: \(project.name)..."
        if ! gcloud projects describe \(project.projectID) 2>/dev/null; then
            \(project.createCommand)
            echo "Project created."
        else
            echo "Project already exists, skipping..."
        fi

        # Set as active project
        gcloud config set project \(project.projectID)

        # Enable required APIs
        echo "Enabling required APIs..."
        \(DAISServiceTemplate.enableCommand(for: enableAPIs, projectID: project.projectID))

        # Verify project
        echo "Project setup complete."
        gcloud projects describe \(project.projectID)
        """
    }
}
