//
//  GoogleCloudServiceUsage.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/3/26.
//

import Foundation

/// Models for Google Cloud Service Usage API.
///
/// The Service Usage API enables services that consumers want to use on Google Cloud Platform,
/// lists available or enabled services, and disables services that are no longer needed.
///
/// ## Common APIs for DAIS Deployment
/// - `compute.googleapis.com` - Compute Engine
/// - `storage.googleapis.com` - Cloud Storage
/// - `secretmanager.googleapis.com` - Secret Manager
/// - `logging.googleapis.com` - Cloud Logging
/// - `monitoring.googleapis.com` - Cloud Monitoring
///
/// ## Example Usage
/// ```swift
/// let service = GoogleCloudService(
///     name: "compute.googleapis.com",
///     projectID: "my-project"
/// )
/// print(service.enableCommand)
/// ```
public struct GoogleCloudService: Codable, Sendable, Equatable {
    /// The service name (e.g., "compute.googleapis.com")
    public let name: String

    /// The project ID where the service is enabled
    public let projectID: String

    /// Current state of the service
    public let state: ServiceState

    public init(
        name: String,
        projectID: String,
        state: ServiceState = .disabled
    ) {
        self.name = name
        self.projectID = projectID
        self.state = state
    }

    /// Full resource name for the service
    public var resourceName: String {
        "projects/\(projectID)/services/\(name)"
    }

    /// gcloud command to enable this service
    public var enableCommand: String {
        "gcloud services enable \(name) --project=\(projectID)"
    }

    /// gcloud command to disable this service
    public var disableCommand: String {
        "gcloud services disable \(name) --project=\(projectID)"
    }

    /// gcloud command to check if this service is enabled
    public var checkCommand: String {
        "gcloud services list --project=\(projectID) --filter=\"name:\(name)\" --format=\"value(state)\""
    }
}

// MARK: - Service State

extension GoogleCloudService {
    /// State of a Google Cloud service
    public enum ServiceState: String, Codable, Sendable {
        /// Service is enabled and can be used
        case enabled = "ENABLED"

        /// Service is disabled
        case disabled = "DISABLED"

        /// Service state is unknown
        case unknown = "STATE_UNSPECIFIED"
    }
}

// MARK: - Batch Service Operations

/// Represents a batch operation to enable/disable multiple services
public struct GoogleCloudServiceBatch: Codable, Sendable, Equatable {
    /// The project ID
    public let projectID: String

    /// Services to operate on
    public let services: [String]

    public init(projectID: String, services: [String]) {
        self.projectID = projectID
        self.services = services
    }

    /// gcloud command to enable all services in batch
    public var batchEnableCommand: String {
        let serviceList = services.joined(separator: " ")
        return "gcloud services enable \(serviceList) --project=\(projectID)"
    }

    /// gcloud command to disable all services in batch
    public var batchDisableCommand: String {
        let serviceList = services.joined(separator: " ")
        return "gcloud services disable \(serviceList) --project=\(projectID)"
    }

    /// gcloud command to list all enabled services
    public var listEnabledCommand: String {
        "gcloud services list --project=\(projectID) --enabled --format=\"value(name)\""
    }

    /// gcloud command to list all available services
    public var listAvailableCommand: String {
        "gcloud services list --project=\(projectID) --available --format=\"value(name)\""
    }
}

// MARK: - Common Google Cloud APIs

/// Predefined Google Cloud API service names
public enum GoogleCloudAPI: String, Codable, Sendable, CaseIterable {
    // Compute & Infrastructure
    /// Compute Engine API
    case compute = "compute.googleapis.com"
    /// Kubernetes Engine API
    case container = "container.googleapis.com"
    /// Cloud Run API
    case run = "run.googleapis.com"
    /// Cloud Functions API
    case cloudFunctions = "cloudfunctions.googleapis.com"
    /// App Engine Admin API
    case appEngine = "appengine.googleapis.com"

    // Storage & Databases
    /// Cloud Storage API
    case storage = "storage.googleapis.com"
    /// Cloud SQL Admin API
    case sqlAdmin = "sqladmin.googleapis.com"
    /// Cloud Firestore API
    case firestore = "firestore.googleapis.com"
    /// Cloud Spanner API
    case spanner = "spanner.googleapis.com"
    /// Cloud Bigtable Admin API
    case bigtableAdmin = "bigtableadmin.googleapis.com"

    // Security & Identity
    /// Secret Manager API
    case secretManager = "secretmanager.googleapis.com"
    /// Identity and Access Management API
    case iam = "iam.googleapis.com"
    /// IAM Credentials API
    case iamCredentials = "iamcredentials.googleapis.com"
    /// Cloud Key Management Service API
    case cloudKMS = "cloudkms.googleapis.com"
    /// Security Token Service API
    case sts = "sts.googleapis.com"

    // Operations & Monitoring
    /// Cloud Logging API
    case logging = "logging.googleapis.com"
    /// Cloud Monitoring API
    case monitoring = "monitoring.googleapis.com"
    /// Cloud Trace API
    case cloudTrace = "cloudtrace.googleapis.com"
    /// Error Reporting API
    case cloudErrorReporting = "clouderrorreporting.googleapis.com"
    /// Cloud Profiler API
    case cloudProfiler = "cloudprofiler.googleapis.com"

    // Networking
    /// Cloud DNS API
    case dns = "dns.googleapis.com"
    /// Service Networking API
    case serviceNetworking = "servicenetworking.googleapis.com"
    /// Serverless VPC Access API
    case vpcAccess = "vpcaccess.googleapis.com"

    // Management
    /// Cloud Resource Manager API
    case cloudResourceManager = "cloudresourcemanager.googleapis.com"
    /// Service Usage API
    case serviceUsage = "serviceusage.googleapis.com"
    /// Cloud Billing API
    case cloudBilling = "cloudbilling.googleapis.com"
    /// Deployment Manager API
    case deploymentManager = "deploymentmanager.googleapis.com"

    // AI & ML
    /// Vertex AI API
    case aiPlatform = "aiplatform.googleapis.com"
    /// Cloud Vision API
    case vision = "vision.googleapis.com"
    /// Cloud Natural Language API
    case language = "language.googleapis.com"
    /// Cloud Translation API
    case translate = "translate.googleapis.com"

    // Messaging & Events
    /// Cloud Pub/Sub API
    case pubsub = "pubsub.googleapis.com"
    /// Eventarc API
    case eventarc = "eventarc.googleapis.com"
    /// Cloud Tasks API
    case cloudTasks = "cloudtasks.googleapis.com"
    /// Cloud Scheduler API
    case cloudScheduler = "cloudscheduler.googleapis.com"

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .compute: return "Compute Engine"
        case .container: return "Kubernetes Engine"
        case .run: return "Cloud Run"
        case .cloudFunctions: return "Cloud Functions"
        case .appEngine: return "App Engine"
        case .storage: return "Cloud Storage"
        case .sqlAdmin: return "Cloud SQL"
        case .firestore: return "Firestore"
        case .spanner: return "Cloud Spanner"
        case .bigtableAdmin: return "Bigtable"
        case .secretManager: return "Secret Manager"
        case .iam: return "IAM"
        case .iamCredentials: return "IAM Credentials"
        case .cloudKMS: return "Cloud KMS"
        case .sts: return "Security Token Service"
        case .logging: return "Cloud Logging"
        case .monitoring: return "Cloud Monitoring"
        case .cloudTrace: return "Cloud Trace"
        case .cloudErrorReporting: return "Error Reporting"
        case .cloudProfiler: return "Cloud Profiler"
        case .dns: return "Cloud DNS"
        case .serviceNetworking: return "Service Networking"
        case .vpcAccess: return "VPC Access"
        case .cloudResourceManager: return "Resource Manager"
        case .serviceUsage: return "Service Usage"
        case .cloudBilling: return "Cloud Billing"
        case .deploymentManager: return "Deployment Manager"
        case .aiPlatform: return "Vertex AI"
        case .vision: return "Cloud Vision"
        case .language: return "Natural Language"
        case .translate: return "Cloud Translation"
        case .pubsub: return "Pub/Sub"
        case .eventarc: return "Eventarc"
        case .cloudTasks: return "Cloud Tasks"
        case .cloudScheduler: return "Cloud Scheduler"
        }
    }

    /// Create a GoogleCloudService instance for this API
    public func service(projectID: String) -> GoogleCloudService {
        GoogleCloudService(name: rawValue, projectID: projectID)
    }
}

// MARK: - DAIS Required Services

/// Predefined service sets for common use cases
public enum DAISServiceTemplate {
    /// Minimum required services for DAIS deployment
    public static let required: [GoogleCloudAPI] = [
        .compute,
        .storage,
        .secretManager,
        .iam,
        .cloudResourceManager,
        .serviceUsage
    ]

    /// Additional services for production deployments
    public static let production: [GoogleCloudAPI] = [
        .compute,
        .storage,
        .secretManager,
        .iam,
        .cloudResourceManager,
        .serviceUsage,
        .logging,
        .monitoring,
        .cloudTrace,
        .cloudKMS
    ]

    /// Services for Kubernetes-based deployments
    public static let kubernetes: [GoogleCloudAPI] = [
        .container,
        .storage,
        .secretManager,
        .iam,
        .cloudResourceManager,
        .serviceUsage,
        .logging,
        .monitoring
    ]

    /// Create a batch enable command for a service set
    public static func enableCommand(for services: [GoogleCloudAPI], projectID: String) -> String {
        let batch = GoogleCloudServiceBatch(
            projectID: projectID,
            services: services.map { $0.rawValue }
        )
        return batch.batchEnableCommand
    }

    /// Generate a complete setup script for enabling required services
    public static func setupScript(for services: [GoogleCloudAPI], projectID: String) -> String {
        """
        #!/bin/bash
        # Enable required Google Cloud APIs
        # Project: \(projectID)

        set -e

        echo "Enabling required APIs..."
        \(enableCommand(for: services, projectID: projectID))

        echo "Verifying enabled APIs..."
        gcloud services list --project=\(projectID) --enabled --format="table(name,title)"

        echo "All required APIs enabled successfully."
        """
    }
}
