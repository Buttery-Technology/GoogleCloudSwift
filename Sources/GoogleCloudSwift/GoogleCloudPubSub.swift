//
//  GoogleCloudPubSub.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

/// Models for Google Cloud Pub/Sub API.
///
/// Pub/Sub is a fully managed, real-time messaging service that allows you to
/// send and receive messages between independent applications. It provides
/// reliable, many-to-many, asynchronous messaging.
///
/// ## Key Concepts
/// - **Topics**: Named resources to which publishers send messages
/// - **Subscriptions**: Named resources representing the stream of messages
/// - **Messages**: Data (payload) plus optional attributes
/// - **Publisher**: Application that creates and sends messages
/// - **Subscriber**: Application that receives messages
///
/// ## Example Usage
/// ```swift
/// let topic = GoogleCloudPubSubTopic(
///     name: "my-events",
///     projectID: "my-project"
/// )
/// print(topic.createCommand)
///
/// let subscription = GoogleCloudPubSubSubscription(
///     name: "my-events-sub",
///     topicName: "my-events",
///     projectID: "my-project"
/// )
/// print(subscription.createCommand)
/// ```
public struct GoogleCloudPubSubTopic: Codable, Sendable, Equatable {
    /// Topic name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Message retention duration (e.g., "7d" for 7 days)
    public let messageRetentionDuration: String?

    /// Schema settings for message validation
    public let schemaSettings: SchemaSettings?

    /// Customer-managed encryption key
    public let kmsKeyName: String?

    /// Labels for organization
    public let labels: [String: String]

    /// Message storage policy (allowed regions)
    public let messageStoragePolicy: MessageStoragePolicy?

    public init(
        name: String,
        projectID: String,
        messageRetentionDuration: String? = nil,
        schemaSettings: SchemaSettings? = nil,
        kmsKeyName: String? = nil,
        labels: [String: String] = [:],
        messageStoragePolicy: MessageStoragePolicy? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.messageRetentionDuration = messageRetentionDuration
        self.schemaSettings = schemaSettings
        self.kmsKeyName = kmsKeyName
        self.labels = labels
        self.messageStoragePolicy = messageStoragePolicy
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/topics/\(name)"
    }

    /// gcloud command to create this topic
    public var createCommand: String {
        var cmd = "gcloud pubsub topics create \(name)"
        cmd += " --project=\(projectID)"

        if let retention = messageRetentionDuration {
            cmd += " --message-retention-duration=\(retention)"
        }

        if let kmsKey = kmsKeyName {
            cmd += " --topic-encryption-key=\(kmsKey)"
        }

        if let schema = schemaSettings {
            cmd += " --schema=\(schema.schemaName)"
            if let encoding = schema.encoding {
                cmd += " --message-encoding=\(encoding.rawValue)"
            }
        }

        if let policy = messageStoragePolicy {
            let regions = policy.allowedPersistenceRegions.joined(separator: ",")
            cmd += " --message-storage-policy-allowed-regions=\(regions)"
        }

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        return cmd
    }

    /// gcloud command to delete this topic
    public var deleteCommand: String {
        "gcloud pubsub topics delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this topic
    public var describeCommand: String {
        "gcloud pubsub topics describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list all topics
    public static func listCommand(projectID: String) -> String {
        "gcloud pubsub topics list --project=\(projectID)"
    }

    /// gcloud command to list subscriptions for this topic
    public var listSubscriptionsCommand: String {
        "gcloud pubsub topics list-subscriptions \(name) --project=\(projectID)"
    }

    /// gcloud command to publish a message
    public func publishCommand(message: String, attributes: [String: String] = [:]) -> String {
        var cmd = "gcloud pubsub topics publish \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --message=\"\(message)\""

        if !attributes.isEmpty {
            let attrPairs = attributes.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --attribute=\(attrPairs)"
        }

        return cmd
    }

    /// gcloud command to update this topic
    public func updateCommand(
        messageRetentionDuration: String? = nil,
        labels: [String: String]? = nil
    ) -> String {
        var cmd = "gcloud pubsub topics update \(name)"
        cmd += " --project=\(projectID)"

        if let retention = messageRetentionDuration {
            cmd += " --message-retention-duration=\(retention)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --update-labels=\(labelPairs)"
        }

        return cmd
    }
}

// MARK: - Schema Settings

extension GoogleCloudPubSubTopic {
    /// Schema settings for message validation
    public struct SchemaSettings: Codable, Sendable, Equatable {
        /// Schema name
        public let schemaName: String

        /// Message encoding
        public let encoding: Encoding?

        /// First revision ID to use
        public let firstRevisionID: String?

        /// Last revision ID to use
        public let lastRevisionID: String?

        public init(
            schemaName: String,
            encoding: Encoding? = nil,
            firstRevisionID: String? = nil,
            lastRevisionID: String? = nil
        ) {
            self.schemaName = schemaName
            self.encoding = encoding
            self.firstRevisionID = firstRevisionID
            self.lastRevisionID = lastRevisionID
        }

        /// Message encoding format
        public enum Encoding: String, Codable, Sendable {
            case json = "JSON"
            case binary = "BINARY"
        }
    }
}

// MARK: - Message Storage Policy

extension GoogleCloudPubSubTopic {
    /// Message storage policy for regional restrictions
    public struct MessageStoragePolicy: Codable, Sendable, Equatable {
        /// Allowed persistence regions
        public let allowedPersistenceRegions: [String]

        public init(allowedPersistenceRegions: [String]) {
            self.allowedPersistenceRegions = allowedPersistenceRegions
        }
    }
}

// MARK: - Subscription

/// Represents a Pub/Sub subscription
public struct GoogleCloudPubSubSubscription: Codable, Sendable, Equatable {
    /// Subscription name
    public let name: String

    /// Topic name to subscribe to
    public let topicName: String

    /// Project ID
    public let projectID: String

    /// Subscription type (pull or push)
    public let type: SubscriptionType

    /// Acknowledgement deadline in seconds (10-600)
    public let ackDeadlineSeconds: Int

    /// Message retention duration (e.g., "7d")
    public let messageRetentionDuration: String

    /// Retain acknowledged messages
    public let retainAckedMessages: Bool

    /// Expiration policy (TTL for inactive subscriptions)
    public let expirationTTL: String?

    /// Filter expression for message filtering
    public let filter: String?

    /// Dead letter policy
    public let deadLetterPolicy: DeadLetterPolicy?

    /// Retry policy
    public let retryPolicy: RetryPolicy?

    /// Enable exactly-once delivery
    public let enableExactlyOnceDelivery: Bool

    /// Enable message ordering
    public let enableMessageOrdering: Bool

    /// Labels for organization
    public let labels: [String: String]

    public init(
        name: String,
        topicName: String,
        projectID: String,
        type: SubscriptionType = .pull,
        ackDeadlineSeconds: Int = 10,
        messageRetentionDuration: String = "7d",
        retainAckedMessages: Bool = false,
        expirationTTL: String? = nil,
        filter: String? = nil,
        deadLetterPolicy: DeadLetterPolicy? = nil,
        retryPolicy: RetryPolicy? = nil,
        enableExactlyOnceDelivery: Bool = false,
        enableMessageOrdering: Bool = false,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.topicName = topicName
        self.projectID = projectID
        self.type = type
        self.ackDeadlineSeconds = max(10, min(600, ackDeadlineSeconds))
        self.messageRetentionDuration = messageRetentionDuration
        self.retainAckedMessages = retainAckedMessages
        self.expirationTTL = expirationTTL
        self.filter = filter
        self.deadLetterPolicy = deadLetterPolicy
        self.retryPolicy = retryPolicy
        self.enableExactlyOnceDelivery = enableExactlyOnceDelivery
        self.enableMessageOrdering = enableMessageOrdering
        self.labels = labels
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/subscriptions/\(name)"
    }

    /// Full topic resource name
    public var topicResourceName: String {
        "projects/\(projectID)/topics/\(topicName)"
    }

    /// gcloud command to create this subscription
    public var createCommand: String {
        var cmd = "gcloud pubsub subscriptions create \(name)"
        cmd += " --topic=\(topicName)"
        cmd += " --project=\(projectID)"

        cmd += " --ack-deadline=\(ackDeadlineSeconds)"
        cmd += " --message-retention-duration=\(messageRetentionDuration)"

        if retainAckedMessages {
            cmd += " --retain-acked-messages"
        }

        if let ttl = expirationTTL {
            cmd += " --expiration-period=\(ttl)"
        } else {
            cmd += " --no-expiration"
        }

        if let filter = filter {
            cmd += " --message-filter=\"\(filter)\""
        }

        if let deadLetter = deadLetterPolicy {
            cmd += " --dead-letter-topic=\(deadLetter.deadLetterTopic)"
            cmd += " --max-delivery-attempts=\(deadLetter.maxDeliveryAttempts)"
        }

        if let retry = retryPolicy {
            cmd += " --min-retry-delay=\(retry.minimumBackoff)"
            cmd += " --max-retry-delay=\(retry.maximumBackoff)"
        }

        if enableExactlyOnceDelivery {
            cmd += " --enable-exactly-once-delivery"
        }

        if enableMessageOrdering {
            cmd += " --enable-message-ordering"
        }

        if case .push(let endpoint, let attributes) = type {
            cmd += " --push-endpoint=\(endpoint)"
            if !attributes.isEmpty {
                let attrPairs = attributes.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
                cmd += " --push-auth-service-account=\(attrPairs)"
            }
        }

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        return cmd
    }

    /// gcloud command to delete this subscription
    public var deleteCommand: String {
        "gcloud pubsub subscriptions delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this subscription
    public var describeCommand: String {
        "gcloud pubsub subscriptions describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list all subscriptions
    public static func listCommand(projectID: String) -> String {
        "gcloud pubsub subscriptions list --project=\(projectID)"
    }

    /// gcloud command to pull messages
    public func pullCommand(maxMessages: Int = 10, autoAck: Bool = false) -> String {
        var cmd = "gcloud pubsub subscriptions pull \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --limit=\(maxMessages)"
        if autoAck {
            cmd += " --auto-ack"
        }
        return cmd
    }

    /// gcloud command to acknowledge a message
    public func ackCommand(ackIDs: [String]) -> String {
        let ids = ackIDs.joined(separator: ",")
        return "gcloud pubsub subscriptions ack \(name) --project=\(projectID) --ack-ids=\(ids)"
    }

    /// gcloud command to modify ack deadline
    public func modifyAckDeadlineCommand(ackIDs: [String], seconds: Int) -> String {
        let ids = ackIDs.joined(separator: ",")
        return "gcloud pubsub subscriptions modify-ack-deadline \(name) --project=\(projectID) --ack-ids=\(ids) --ack-deadline=\(seconds)"
    }

    /// gcloud command to seek to a timestamp
    public func seekToTimeCommand(timestamp: String) -> String {
        "gcloud pubsub subscriptions seek \(name) --project=\(projectID) --time=\(timestamp)"
    }

    /// gcloud command to seek to a snapshot
    public func seekToSnapshotCommand(snapshotName: String) -> String {
        "gcloud pubsub subscriptions seek \(name) --project=\(projectID) --snapshot=\(snapshotName)"
    }
}

// MARK: - Subscription Type

extension GoogleCloudPubSubSubscription {
    /// Subscription delivery type
    public enum SubscriptionType: Codable, Sendable, Equatable {
        /// Pull subscription (subscriber pulls messages)
        case pull
        /// Push subscription (Pub/Sub pushes to endpoint)
        case push(endpoint: String, attributes: [String: String])

        public var isPush: Bool {
            if case .push = self { return true }
            return false
        }
    }
}

// MARK: - Dead Letter Policy

extension GoogleCloudPubSubSubscription {
    /// Dead letter policy for failed message handling
    public struct DeadLetterPolicy: Codable, Sendable, Equatable {
        /// Dead letter topic name
        public let deadLetterTopic: String

        /// Maximum delivery attempts before sending to dead letter
        public let maxDeliveryAttempts: Int

        public init(deadLetterTopic: String, maxDeliveryAttempts: Int = 5) {
            self.deadLetterTopic = deadLetterTopic
            self.maxDeliveryAttempts = max(5, min(100, maxDeliveryAttempts))
        }
    }
}

// MARK: - Retry Policy

extension GoogleCloudPubSubSubscription {
    /// Retry policy for message delivery
    public struct RetryPolicy: Codable, Sendable, Equatable {
        /// Minimum backoff duration (e.g., "10s")
        public let minimumBackoff: String

        /// Maximum backoff duration (e.g., "600s")
        public let maximumBackoff: String

        public init(minimumBackoff: String = "10s", maximumBackoff: String = "600s") {
            self.minimumBackoff = minimumBackoff
            self.maximumBackoff = maximumBackoff
        }
    }
}

// MARK: - Snapshot

/// Represents a Pub/Sub snapshot
public struct GoogleCloudPubSubSnapshot: Codable, Sendable, Equatable {
    /// Snapshot name
    public let name: String

    /// Subscription name
    public let subscriptionName: String

    /// Project ID
    public let projectID: String

    /// Labels for organization
    public let labels: [String: String]

    public init(
        name: String,
        subscriptionName: String,
        projectID: String,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.subscriptionName = subscriptionName
        self.projectID = projectID
        self.labels = labels
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/snapshots/\(name)"
    }

    /// gcloud command to create this snapshot
    public var createCommand: String {
        var cmd = "gcloud pubsub snapshots create \(name)"
        cmd += " --subscription=\(subscriptionName)"
        cmd += " --project=\(projectID)"

        if !labels.isEmpty {
            let labelPairs = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelPairs)"
        }

        return cmd
    }

    /// gcloud command to delete this snapshot
    public var deleteCommand: String {
        "gcloud pubsub snapshots delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this snapshot
    public var describeCommand: String {
        "gcloud pubsub snapshots describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list all snapshots
    public static func listCommand(projectID: String) -> String {
        "gcloud pubsub snapshots list --project=\(projectID)"
    }
}

// MARK: - Schema

/// Represents a Pub/Sub schema for message validation
public struct GoogleCloudPubSubSchema: Codable, Sendable, Equatable {
    /// Schema name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Schema type
    public let type: SchemaType

    /// Schema definition
    public let definition: String

    public init(
        name: String,
        projectID: String,
        type: SchemaType,
        definition: String
    ) {
        self.name = name
        self.projectID = projectID
        self.type = type
        self.definition = definition
    }

    /// Schema type
    public enum SchemaType: String, Codable, Sendable {
        case protocolBuffer = "PROTOCOL_BUFFER"
        case avro = "AVRO"
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/schemas/\(name)"
    }

    /// gcloud command to create this schema
    public var createCommand: String {
        "gcloud pubsub schemas create \(name) --project=\(projectID) --type=\(type.rawValue) --definition=\"\(definition)\""
    }

    /// gcloud command to create from a file
    public func createFromFileCommand(filePath: String) -> String {
        "gcloud pubsub schemas create \(name) --project=\(projectID) --type=\(type.rawValue) --definition-file=\(filePath)"
    }

    /// gcloud command to delete this schema
    public var deleteCommand: String {
        "gcloud pubsub schemas delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this schema
    public var describeCommand: String {
        "gcloud pubsub schemas describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list all schemas
    public static func listCommand(projectID: String) -> String {
        "gcloud pubsub schemas list --project=\(projectID)"
    }

    /// gcloud command to validate a message against this schema
    public func validateMessageCommand(message: String, encoding: GoogleCloudPubSubTopic.SchemaSettings.Encoding) -> String {
        "gcloud pubsub schemas validate-message --project=\(projectID) --schema-name=\(name) --message-encoding=\(encoding.rawValue) --message=\"\(message)\""
    }
}

// MARK: - Message

/// Represents a Pub/Sub message (for documentation/modeling purposes)
public struct GoogleCloudPubSubMessage: Codable, Sendable, Equatable {
    /// Message data (base64 encoded when sent)
    public let data: String

    /// Message attributes
    public let attributes: [String: String]

    /// Ordering key for message ordering
    public let orderingKey: String?

    public init(
        data: String,
        attributes: [String: String] = [:],
        orderingKey: String? = nil
    ) {
        self.data = data
        self.attributes = attributes
        self.orderingKey = orderingKey
    }
}

// MARK: - IAM Bindings

extension GoogleCloudPubSubTopic {
    /// gcloud command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud pubsub topics get-iam-policy \(name) --project=\(projectID)"
    }

    /// gcloud command to add IAM binding
    public func addIAMBindingCommand(member: String, role: String) -> String {
        "gcloud pubsub topics add-iam-policy-binding \(name) --project=\(projectID) --member=\(member) --role=\(role)"
    }

    /// gcloud command to remove IAM binding
    public func removeIAMBindingCommand(member: String, role: String) -> String {
        "gcloud pubsub topics remove-iam-policy-binding \(name) --project=\(projectID) --member=\(member) --role=\(role)"
    }
}

extension GoogleCloudPubSubSubscription {
    /// gcloud command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud pubsub subscriptions get-iam-policy \(name) --project=\(projectID)"
    }

    /// gcloud command to add IAM binding
    public func addIAMBindingCommand(member: String, role: String) -> String {
        "gcloud pubsub subscriptions add-iam-policy-binding \(name) --project=\(projectID) --member=\(member) --role=\(role)"
    }
}

// MARK: - Pub/Sub Roles

/// Common Pub/Sub IAM roles
public enum PubSubRole: String, Codable, Sendable, CaseIterable {
    /// Full access to topics and subscriptions
    case admin = "roles/pubsub.admin"
    /// Publish messages to topics
    case publisher = "roles/pubsub.publisher"
    /// Consume messages from subscriptions
    case subscriber = "roles/pubsub.subscriber"
    /// View topics and subscriptions
    case viewer = "roles/pubsub.viewer"
    /// Edit topics and subscriptions
    case editor = "roles/pubsub.editor"

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .admin: return "Pub/Sub Admin"
        case .publisher: return "Pub/Sub Publisher"
        case .subscriber: return "Pub/Sub Subscriber"
        case .viewer: return "Pub/Sub Viewer"
        case .editor: return "Pub/Sub Editor"
        }
    }
}

// MARK: - DAIS Pub/Sub Templates

/// Predefined Pub/Sub configurations for DAIS
public enum DAISPubSubTemplate {
    /// Create a topic for DAIS events
    public static func eventsTopic(
        name: String,
        projectID: String,
        messageRetention: String = "7d"
    ) -> GoogleCloudPubSubTopic {
        GoogleCloudPubSubTopic(
            name: name,
            projectID: projectID,
            messageRetentionDuration: messageRetention,
            labels: [
                "app": "butteryai",
                "managed-by": "dais",
                "type": "events"
            ]
        )
    }

    /// Create a topic for DAIS commands
    public static func commandsTopic(
        name: String,
        projectID: String
    ) -> GoogleCloudPubSubTopic {
        GoogleCloudPubSubTopic(
            name: name,
            projectID: projectID,
            messageRetentionDuration: "1d",
            labels: [
                "app": "butteryai",
                "managed-by": "dais",
                "type": "commands"
            ]
        )
    }

    /// Create a subscription for a DAIS node
    public static func nodeSubscription(
        nodeName: String,
        topicName: String,
        projectID: String,
        enableOrdering: Bool = true
    ) -> GoogleCloudPubSubSubscription {
        GoogleCloudPubSubSubscription(
            name: "\(nodeName)-sub",
            topicName: topicName,
            projectID: projectID,
            type: .pull,
            ackDeadlineSeconds: 30,
            messageRetentionDuration: "1d",
            enableExactlyOnceDelivery: true,
            enableMessageOrdering: enableOrdering,
            labels: [
                "app": "butteryai",
                "managed-by": "dais",
                "node": nodeName
            ]
        )
    }

    /// Create a dead letter topic for failed messages
    public static func deadLetterTopic(
        baseName: String,
        projectID: String
    ) -> GoogleCloudPubSubTopic {
        GoogleCloudPubSubTopic(
            name: "\(baseName)-dead-letter",
            projectID: projectID,
            messageRetentionDuration: "14d",
            labels: [
                "app": "butteryai",
                "managed-by": "dais",
                "type": "dead-letter"
            ]
        )
    }

    /// Create a subscription with dead letter handling
    public static func subscriptionWithDeadLetter(
        name: String,
        topicName: String,
        deadLetterTopicName: String,
        projectID: String,
        maxDeliveryAttempts: Int = 10
    ) -> GoogleCloudPubSubSubscription {
        GoogleCloudPubSubSubscription(
            name: name,
            topicName: topicName,
            projectID: projectID,
            type: .pull,
            ackDeadlineSeconds: 60,
            messageRetentionDuration: "7d",
            deadLetterPolicy: GoogleCloudPubSubSubscription.DeadLetterPolicy(
                deadLetterTopic: deadLetterTopicName,
                maxDeliveryAttempts: maxDeliveryAttempts
            ),
            retryPolicy: GoogleCloudPubSubSubscription.RetryPolicy(
                minimumBackoff: "10s",
                maximumBackoff: "600s"
            ),
            labels: [
                "app": "butteryai",
                "managed-by": "dais"
            ]
        )
    }

    /// Generate a setup script for DAIS Pub/Sub infrastructure
    public static func setupScript(
        deploymentName: String,
        projectID: String,
        nodeCount: Int
    ) -> String {
        let eventsTopic = eventsTopic(name: "\(deploymentName)-events", projectID: projectID)
        let commandsTopic = commandsTopic(name: "\(deploymentName)-commands", projectID: projectID)
        let deadLetterTopic = deadLetterTopic(baseName: deploymentName, projectID: projectID)

        var script = """
        #!/bin/bash
        # DAIS Pub/Sub Setup Script
        # Deployment: \(deploymentName)
        # Project: \(projectID)

        set -e

        echo "========================================"
        echo "DAIS Pub/Sub Infrastructure Setup"
        echo "========================================"

        # Enable Pub/Sub API
        echo "Enabling Pub/Sub API..."
        gcloud services enable pubsub.googleapis.com --project=\(projectID)

        # Create topics
        echo "Creating topics..."
        \(eventsTopic.createCommand)
        \(commandsTopic.createCommand)
        \(deadLetterTopic.createCommand)

        # Create subscriptions for each node
        echo "Creating subscriptions..."

        """

        for i in 1...nodeCount {
            let nodeName = "\(deploymentName)-node-\(i)"
            let eventsSub = nodeSubscription(nodeName: nodeName, topicName: eventsTopic.name, projectID: projectID)
            let commandsSub = subscriptionWithDeadLetter(
                name: "\(nodeName)-commands-sub",
                topicName: commandsTopic.name,
                deadLetterTopicName: deadLetterTopic.name,
                projectID: projectID
            )
            script += """
            # Node \(i)
            \(eventsSub.createCommand)
            \(commandsSub.createCommand)


            """
        }

        script += """
        echo ""
        echo "Pub/Sub setup complete!"
        echo ""
        echo "Topics:"
        gcloud pubsub topics list --project=\(projectID) --filter="labels.managed-by=dais"
        echo ""
        echo "Subscriptions:"
        gcloud pubsub subscriptions list --project=\(projectID) --filter="labels.managed-by=dais"
        """

        return script
    }
}
