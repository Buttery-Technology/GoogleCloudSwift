// GoogleCloudEventarc.swift
// Eventarc - Event-Driven Architecture
//
// Eventarc enables event-driven architectures by routing events from
// Google Cloud services, SaaS, and custom sources to event handlers.

import Foundation

// MARK: - Eventarc Trigger

/// Represents an Eventarc trigger
public struct GoogleCloudEventarcTrigger: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let destination: Destination
    public let eventFilters: [EventFilter]
    public let serviceAccount: String?
    public let channel: String?
    public let transport: Transport?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        location: String,
        destination: Destination,
        eventFilters: [EventFilter],
        serviceAccount: String? = nil,
        channel: String? = nil,
        transport: Transport? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.destination = destination
        self.eventFilters = eventFilters
        self.serviceAccount = serviceAccount
        self.channel = channel
        self.transport = transport
        self.labels = labels
    }

    /// Trigger destination
    public enum Destination: Codable, Sendable, Equatable {
        case cloudRun(service: String, path: String?, region: String?)
        case cloudFunction(name: String, region: String?)
        case gke(service: String, namespace: String, path: String?)
        case workflow(name: String, region: String?)

        public var gcloudFlag: String {
            switch self {
            case .cloudRun(let service, let path, let region):
                var flag = "--destination-run-service=\(service)"
                if let path = path { flag += " --destination-run-path=\(path)" }
                if let region = region { flag += " --destination-run-region=\(region)" }
                return flag
            case .cloudFunction(let name, let region):
                var flag = "--destination-function=\(name)"
                if let region = region { flag += " --destination-function-region=\(region)" }
                return flag
            case .gke(let service, let namespace, let path):
                var flag = "--destination-gke-service=\(service) --destination-gke-namespace=\(namespace)"
                if let path = path { flag += " --destination-gke-path=\(path)" }
                return flag
            case .workflow(let name, let region):
                var flag = "--destination-workflow=\(name)"
                if let region = region { flag += " --destination-workflow-location=\(region)" }
                return flag
            }
        }
    }

    /// Event filter
    public struct EventFilter: Codable, Sendable, Equatable {
        public let attribute: String
        public let value: String
        public let `operator`: FilterOperator?

        public init(attribute: String, value: String, operator: FilterOperator? = nil) {
            self.attribute = attribute
            self.value = value
            self.operator = `operator`
        }

        public enum FilterOperator: String, Codable, Sendable, Equatable {
            case equal = "="
            case pathPattern = "match-path-pattern"
        }

        public var gcloudFlag: String {
            if let op = self.operator, op == .pathPattern {
                return "--event-filters-path-pattern=\"\(attribute)=\(value)\""
            }
            return "--event-filters=\"\(attribute)=\(value)\""
        }
    }

    /// Transport configuration
    public struct Transport: Codable, Sendable, Equatable {
        public let pubsubTopic: String?

        public init(pubsubTopic: String? = nil) {
            self.pubsubTopic = pubsubTopic
        }
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/triggers/\(name)"
    }

    /// Command to create trigger
    public var createCommand: String {
        var cmd = "gcloud eventarc triggers create \(name)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"
        cmd += " \(destination.gcloudFlag)"

        for filter in eventFilters {
            cmd += " \(filter.gcloudFlag)"
        }

        if let serviceAccount = serviceAccount {
            cmd += " --service-account=\(serviceAccount)"
        }

        if let channel = channel {
            cmd += " --channel=\(channel)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to update trigger
    public var updateCommand: String {
        "gcloud eventarc triggers update \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to delete trigger
    public var deleteCommand: String {
        "gcloud eventarc triggers delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// Command to describe trigger
    public var describeCommand: String {
        "gcloud eventarc triggers describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to list triggers
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud eventarc triggers list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Eventarc Channel

/// Represents an Eventarc channel for custom events
public struct GoogleCloudEventarcChannel: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let cryptoKeyName: String?

    public init(
        name: String,
        projectID: String,
        location: String,
        cryptoKeyName: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.cryptoKeyName = cryptoKeyName
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/channels/\(name)"
    }

    /// Command to create channel
    public var createCommand: String {
        var cmd = "gcloud eventarc channels create \(name)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"

        if let cryptoKeyName = cryptoKeyName {
            cmd += " --crypto-key=\(cryptoKeyName)"
        }

        return cmd
    }

    /// Command to delete channel
    public var deleteCommand: String {
        "gcloud eventarc channels delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// Command to describe channel
    public var describeCommand: String {
        "gcloud eventarc channels describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to list channels
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud eventarc channels list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Event Types

/// Common Google Cloud event types for Eventarc
public enum GoogleCloudEventType: String, Codable, Sendable, Equatable {
    // Cloud Storage events
    case storageObjectFinalize = "google.cloud.storage.object.v1.finalized"
    case storageObjectDelete = "google.cloud.storage.object.v1.deleted"
    case storageObjectArchive = "google.cloud.storage.object.v1.archived"
    case storageObjectMetadataUpdate = "google.cloud.storage.object.v1.metadataUpdated"

    // Pub/Sub events
    case pubsubMessagePublish = "google.cloud.pubsub.topic.v1.messagePublished"

    // Cloud Build events
    case cloudBuildComplete = "google.cloud.cloudbuild.build.v1.statusChanged"

    // Firestore events
    case firestoreDocumentCreate = "google.cloud.firestore.document.v1.created"
    case firestoreDocumentUpdate = "google.cloud.firestore.document.v1.updated"
    case firestoreDocumentDelete = "google.cloud.firestore.document.v1.deleted"
    case firestoreDocumentWrite = "google.cloud.firestore.document.v1.written"

    // BigQuery events
    case bigQueryJobComplete = "google.cloud.bigquery.job.v1.completed"

    // Cloud Audit Log events
    case auditLogActivity = "google.cloud.audit.log.v1.written"

    // Workflows events
    case workflowExecutionComplete = "google.cloud.workflows.execution.v1.completed"

    public var description: String {
        switch self {
        case .storageObjectFinalize:
            return "Object created/overwritten in Cloud Storage"
        case .storageObjectDelete:
            return "Object deleted from Cloud Storage"
        case .storageObjectArchive:
            return "Object archived in Cloud Storage"
        case .storageObjectMetadataUpdate:
            return "Object metadata updated in Cloud Storage"
        case .pubsubMessagePublish:
            return "Message published to Pub/Sub topic"
        case .cloudBuildComplete:
            return "Cloud Build status changed"
        case .firestoreDocumentCreate:
            return "Firestore document created"
        case .firestoreDocumentUpdate:
            return "Firestore document updated"
        case .firestoreDocumentDelete:
            return "Firestore document deleted"
        case .firestoreDocumentWrite:
            return "Firestore document written"
        case .bigQueryJobComplete:
            return "BigQuery job completed"
        case .auditLogActivity:
            return "Audit log entry written"
        case .workflowExecutionComplete:
            return "Workflow execution completed"
        }
    }
}

// MARK: - Eventarc Operations

/// Common Eventarc operations
public enum EventarcOperations {

    /// List available event providers
    public static func listProvidersCommand(projectID: String, location: String) -> String {
        "gcloud eventarc providers list --location=\(location) --project=\(projectID)"
    }

    /// Describe an event provider
    public static func describeProviderCommand(provider: String, projectID: String, location: String) -> String {
        "gcloud eventarc providers describe \(provider) --location=\(location) --project=\(projectID)"
    }

    /// List available event types for a provider
    public static func listEventTypesCommand(provider: String, projectID: String, location: String) -> String {
        "gcloud eventarc providers describe \(provider) --location=\(location) --project=\(projectID) --format=\"value(eventTypes)\""
    }

    /// Create Cloud Storage trigger
    public static func createStorageTrigger(
        name: String,
        projectID: String,
        location: String,
        bucket: String,
        eventType: GoogleCloudEventType,
        destinationService: String,
        serviceAccount: String
    ) -> String {
        """
        gcloud eventarc triggers create \(name) \\
            --location=\(location) \\
            --project=\(projectID) \\
            --destination-run-service=\(destinationService) \\
            --destination-run-region=\(location) \\
            --event-filters="type=\(eventType.rawValue)" \\
            --event-filters="bucket=\(bucket)" \\
            --service-account=\(serviceAccount)
        """
    }

    /// Create Pub/Sub trigger
    public static func createPubSubTrigger(
        name: String,
        projectID: String,
        location: String,
        topic: String,
        destinationService: String,
        serviceAccount: String
    ) -> String {
        """
        gcloud eventarc triggers create \(name) \\
            --location=\(location) \\
            --project=\(projectID) \\
            --destination-run-service=\(destinationService) \\
            --destination-run-region=\(location) \\
            --event-filters="type=\(GoogleCloudEventType.pubsubMessagePublish.rawValue)" \\
            --transport-topic=\(topic) \\
            --service-account=\(serviceAccount)
        """
    }

    /// Create Audit Log trigger
    public static func createAuditLogTrigger(
        name: String,
        projectID: String,
        location: String,
        serviceName: String,
        methodName: String,
        destinationService: String,
        serviceAccount: String
    ) -> String {
        """
        gcloud eventarc triggers create \(name) \\
            --location=\(location) \\
            --project=\(projectID) \\
            --destination-run-service=\(destinationService) \\
            --destination-run-region=\(location) \\
            --event-filters="type=\(GoogleCloudEventType.auditLogActivity.rawValue)" \\
            --event-filters="serviceName=\(serviceName)" \\
            --event-filters="methodName=\(methodName)" \\
            --service-account=\(serviceAccount)
        """
    }
}

// MARK: - DAIS Eventarc Templates

/// DAIS-specific Eventarc configurations
public enum DAISEventarcTemplate {

    /// Storage upload trigger
    public static func storageUploadTrigger(
        projectID: String,
        location: String,
        deploymentName: String,
        bucket: String,
        destinationService: String,
        serviceAccountEmail: String
    ) -> GoogleCloudEventarcTrigger {
        GoogleCloudEventarcTrigger(
            name: "\(deploymentName)-storage-upload",
            projectID: projectID,
            location: location,
            destination: .cloudRun(service: destinationService, path: "/events/storage", region: location),
            eventFilters: [
                EventFilter(attribute: "type", value: GoogleCloudEventType.storageObjectFinalize.rawValue),
                EventFilter(attribute: "bucket", value: bucket)
            ],
            serviceAccount: serviceAccountEmail,
            labels: ["environment": "production", "purpose": "storage-events"]
        )
    }

    /// Pub/Sub message trigger
    public static func pubsubMessageTrigger(
        projectID: String,
        location: String,
        deploymentName: String,
        destinationService: String,
        serviceAccountEmail: String
    ) -> GoogleCloudEventarcTrigger {
        GoogleCloudEventarcTrigger(
            name: "\(deploymentName)-pubsub-events",
            projectID: projectID,
            location: location,
            destination: .cloudRun(service: destinationService, path: "/events/pubsub", region: location),
            eventFilters: [
                EventFilter(attribute: "type", value: GoogleCloudEventType.pubsubMessagePublish.rawValue)
            ],
            serviceAccount: serviceAccountEmail,
            labels: ["environment": "production", "purpose": "pubsub-events"]
        )
    }

    /// Build completion trigger
    public static func buildCompleteTrigger(
        projectID: String,
        location: String,
        deploymentName: String,
        destinationService: String,
        serviceAccountEmail: String
    ) -> GoogleCloudEventarcTrigger {
        GoogleCloudEventarcTrigger(
            name: "\(deploymentName)-build-events",
            projectID: projectID,
            location: location,
            destination: .cloudRun(service: destinationService, path: "/events/build", region: location),
            eventFilters: [
                EventFilter(attribute: "type", value: GoogleCloudEventType.cloudBuildComplete.rawValue)
            ],
            serviceAccount: serviceAccountEmail,
            labels: ["environment": "production", "purpose": "build-events"]
        )
    }

    /// Firestore document trigger
    public static func firestoreDocumentTrigger(
        projectID: String,
        location: String,
        deploymentName: String,
        database: String,
        documentPath: String,
        destinationService: String,
        serviceAccountEmail: String
    ) -> GoogleCloudEventarcTrigger {
        GoogleCloudEventarcTrigger(
            name: "\(deploymentName)-firestore-events",
            projectID: projectID,
            location: location,
            destination: .cloudRun(service: destinationService, path: "/events/firestore", region: location),
            eventFilters: [
                EventFilter(attribute: "type", value: GoogleCloudEventType.firestoreDocumentWrite.rawValue),
                EventFilter(attribute: "database", value: database),
                EventFilter(attribute: "document", value: documentPath, operator: .pathPattern)
            ],
            serviceAccount: serviceAccountEmail,
            labels: ["environment": "production", "purpose": "firestore-events"]
        )
    }

    /// Custom event channel
    public static func customEventChannel(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudEventarcChannel {
        GoogleCloudEventarcChannel(
            name: "\(deploymentName)-custom-events",
            projectID: projectID,
            location: location
        )
    }

    /// Setup script for DAIS Eventarc
    public static func setupScript(
        projectID: String,
        location: String,
        deploymentName: String,
        serviceAccountEmail: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Eventarc Setup Script
        set -e

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        DEPLOYMENT_NAME="\(deploymentName)"
        SERVICE_ACCOUNT="\(serviceAccountEmail)"

        echo "Enabling Eventarc API..."
        gcloud services enable eventarc.googleapis.com --project=${PROJECT_ID}

        echo "Granting Eventarc permissions to service account..."
        gcloud projects add-iam-policy-binding ${PROJECT_ID} \\
            --member="serviceAccount:${SERVICE_ACCOUNT}" \\
            --role="roles/eventarc.eventReceiver"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} \\
            --member="serviceAccount:${SERVICE_ACCOUNT}" \\
            --role="roles/run.invoker"

        echo "Eventarc setup complete!"
        """
    }

    /// Teardown script
    public static func teardownScript(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Eventarc Teardown Script
        set -e

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        DEPLOYMENT_NAME="\(deploymentName)"

        echo "Deleting Eventarc triggers..."
        for trigger in $(gcloud eventarc triggers list --location=${LOCATION} --project=${PROJECT_ID} --filter="name~${DEPLOYMENT_NAME}" --format="value(name)"); do
            echo "Deleting trigger: ${trigger}"
            gcloud eventarc triggers delete ${trigger} --location=${LOCATION} --project=${PROJECT_ID} --quiet || true
        done

        echo "Eventarc teardown complete!"
        """
    }
}

// Type alias for EventFilter
public typealias EventFilter = GoogleCloudEventarcTrigger.EventFilter
