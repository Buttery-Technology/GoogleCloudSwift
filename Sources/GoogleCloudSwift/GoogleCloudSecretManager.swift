//
//  GoogleCloudSecretManager.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 12/9/25.
//

import Foundation

/// Models for interacting with Google Cloud Secret Manager.
///
/// Secret Manager is recommended for storing sensitive DAIS configuration:
/// - Certificate master encryption keys
/// - API keys and tokens
/// - Database credentials
///
/// ## Pricing (as of 2024)
/// - **Free tier**: 6 active secret versions, 10,000 access operations/month
/// - **Beyond free tier**: $0.06 per secret version per month
///
/// ## Example Usage
/// ```swift
/// let secret = GoogleCloudSecret(
///     name: "butteryai-certificate-master-key",
///     projectID: "my-project"
/// )
///
/// // Reference in environment
/// let envVar = secret.asEnvironmentVariable(variableName: "CERTIFICATE_MASTER_KEY")
/// ```
public struct GoogleCloudSecret: Codable, Sendable, Equatable {
    /// The secret name (not including project/location path)
    public let name: String

    /// The Google Cloud project ID
    public let projectID: String

    /// Optional specific version (default: "latest")
    public let version: String

    /// Replication policy for the secret
    public let replication: ReplicationPolicy

    /// Labels for organization
    public let labels: [String: String]

    public init(
        name: String,
        projectID: String,
        version: String = "latest",
        replication: ReplicationPolicy = .automatic,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.projectID = projectID
        self.version = version
        self.replication = replication
        self.labels = labels
    }

    /// Full resource name for the secret
    public var resourceName: String {
        "projects/\(projectID)/secrets/\(name)"
    }

    /// Full resource name for a specific version
    public var versionResourceName: String {
        "\(resourceName)/versions/\(version)"
    }

    /// gcloud CLI command to create this secret
    public var createCommand: String {
        var cmd = "gcloud secrets create \(name) --project=\(projectID) --replication-policy=\(replication.rawValue)"
        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }
        return cmd
    }

    /// gcloud CLI command to access this secret
    public var accessCommand: String {
        "gcloud secrets versions access \(version) --secret=\(name) --project=\(projectID)"
    }

    /// Generate a shell command to set an environment variable from this secret
    public func asEnvironmentVariable(variableName: String) -> String {
        "export \(variableName)=$(\(accessCommand))"
    }
}

// MARK: - Replication Policy

extension GoogleCloudSecret {
    /// Replication policy for secrets
    public enum ReplicationPolicy: String, Codable, Sendable {
        /// Automatic replication (recommended)
        case automatic = "automatic"

        /// User-managed replication to specific regions
        case userManaged = "user-managed"
    }
}

// MARK: - Secret Version

/// Represents a specific version of a secret
public struct GoogleCloudSecretVersion: Codable, Sendable, Equatable {
    /// The parent secret name
    public let secretName: String

    /// The project ID
    public let projectID: String

    /// Version number or "latest"
    public let version: String

    /// State of this version
    public let state: VersionState

    /// When this version was created
    public let createTime: Date?

    public init(
        secretName: String,
        projectID: String,
        version: String,
        state: VersionState = .enabled,
        createTime: Date? = nil
    ) {
        self.secretName = secretName
        self.projectID = projectID
        self.version = version
        self.state = state
        self.createTime = createTime
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/secrets/\(secretName)/versions/\(version)"
    }

    /// Version states
    public enum VersionState: String, Codable, Sendable {
        /// Version is active and can be accessed
        case enabled = "ENABLED"

        /// Version is disabled but can be re-enabled
        case disabled = "DISABLED"

        /// Version is scheduled for destruction
        case destroyed = "DESTROYED"
    }
}

// MARK: - Common DAIS Secrets

/// Predefined secret configurations for common DAIS use cases
public enum DAISSecretTemplate {
    /// Certificate master encryption key
    public static func certificateMasterKey(projectID: String) -> GoogleCloudSecret {
        GoogleCloudSecret(
            name: "butteryai-certificate-master-key",
            projectID: projectID,
            labels: [
                "app": "butteryai",
                "component": "certificates",
                "sensitivity": "critical"
            ]
        )
    }

    /// Database connection string
    public static func databaseURL(projectID: String) -> GoogleCloudSecret {
        GoogleCloudSecret(
            name: "butteryai-database-url",
            projectID: projectID,
            labels: [
                "app": "butteryai",
                "component": "database",
                "sensitivity": "high"
            ]
        )
    }

    /// API authentication token
    public static func apiToken(projectID: String) -> GoogleCloudSecret {
        GoogleCloudSecret(
            name: "butteryai-api-token",
            projectID: projectID,
            labels: [
                "app": "butteryai",
                "component": "api",
                "sensitivity": "high"
            ]
        )
    }

    /// gRPC TLS certificate (PEM)
    public static func grpcCertificate(projectID: String) -> GoogleCloudSecret {
        GoogleCloudSecret(
            name: "butteryai-grpc-certificate",
            projectID: projectID,
            labels: [
                "app": "butteryai",
                "component": "grpc",
                "sensitivity": "medium"
            ]
        )
    }

    /// gRPC TLS private key (PEM)
    public static func grpcPrivateKey(projectID: String) -> GoogleCloudSecret {
        GoogleCloudSecret(
            name: "butteryai-grpc-private-key",
            projectID: projectID,
            labels: [
                "app": "butteryai",
                "component": "grpc",
                "sensitivity": "critical"
            ]
        )
    }
}

// MARK: - IAM Bindings

/// IAM role bindings for Secret Manager
public struct SecretManagerIAMBinding: Codable, Sendable, Equatable {
    /// The secret name
    public let secretName: String

    /// The project ID
    public let projectID: String

    /// The IAM role to grant
    public let role: SecretManagerRole

    /// The member to grant the role to
    public let member: String

    public init(
        secretName: String,
        projectID: String,
        role: SecretManagerRole,
        member: String
    ) {
        self.secretName = secretName
        self.projectID = projectID
        self.role = role
        self.member = member
    }

    /// Convenience initializer from a GoogleCloudSecret
    public init(
        secret: GoogleCloudSecret,
        role: SecretManagerRole,
        member: String
    ) {
        self.secretName = secret.name
        self.projectID = secret.projectID
        self.role = role
        self.member = member
    }

    /// Full resource name for the secret
    public var secretResourceName: String {
        "projects/\(projectID)/secrets/\(secretName)"
    }

    /// gcloud command to add this IAM binding
    public var addBindingCommand: String {
        "gcloud secrets add-iam-policy-binding \(secretName) --project=\(projectID) --member=\(member) --role=\(role.rawValue)"
    }

    /// Secret Manager IAM roles
    public enum SecretManagerRole: String, Codable, Sendable {
        /// Can read secret versions
        case secretAccessor = "roles/secretmanager.secretAccessor"

        /// Can read secret metadata (not values)
        case secretViewer = "roles/secretmanager.viewer"

        /// Can create and manage secrets
        case secretAdmin = "roles/secretmanager.admin"

        /// Can add new versions to existing secrets
        case secretVersionAdder = "roles/secretmanager.secretVersionAdder"

        /// Can manage versions (enable/disable/destroy)
        case secretVersionManager = "roles/secretmanager.secretVersionManager"
    }
}
