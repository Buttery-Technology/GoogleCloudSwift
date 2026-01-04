// GoogleCloudMemorystore.swift
// Cloud Memorystore - Managed Redis and Memcached
//
// Memorystore provides fully managed in-memory data stores for
// caching, session management, and real-time analytics.

import Foundation

// MARK: - Memorystore Redis Instance

/// Represents a Memorystore for Redis instance
public struct GoogleCloudRedisInstance: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let tier: Tier
    public let memorySizeGB: Int
    public let redisVersion: RedisVersion
    public let displayName: String?
    public let redisConfigs: [String: String]?
    public let labels: [String: String]?
    public let authorizedNetwork: String?
    public let connectMode: ConnectMode?
    public let transitEncryptionMode: TransitEncryptionMode?
    public let authEnabled: Bool?
    public let replicaCount: Int?
    public let readReplicasMode: ReadReplicasMode?

    public init(
        name: String,
        projectID: String,
        region: String,
        tier: Tier = .basic,
        memorySizeGB: Int = 1,
        redisVersion: RedisVersion = .redis7_0,
        displayName: String? = nil,
        redisConfigs: [String: String]? = nil,
        labels: [String: String]? = nil,
        authorizedNetwork: String? = nil,
        connectMode: ConnectMode? = nil,
        transitEncryptionMode: TransitEncryptionMode? = nil,
        authEnabled: Bool? = nil,
        replicaCount: Int? = nil,
        readReplicasMode: ReadReplicasMode? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.tier = tier
        self.memorySizeGB = memorySizeGB
        self.redisVersion = redisVersion
        self.displayName = displayName
        self.redisConfigs = redisConfigs
        self.labels = labels
        self.authorizedNetwork = authorizedNetwork
        self.connectMode = connectMode
        self.transitEncryptionMode = transitEncryptionMode
        self.authEnabled = authEnabled
        self.replicaCount = replicaCount
        self.readReplicasMode = readReplicasMode
    }

    /// Instance tier
    public enum Tier: String, Codable, Sendable, Equatable {
        case basic = "basic"
        case standardHa = "standard"

        public var description: String {
            switch self {
            case .basic:
                return "Basic tier (no replication)"
            case .standardHa:
                return "Standard HA (automatic failover)"
            }
        }
    }

    /// Redis version
    public enum RedisVersion: String, Codable, Sendable, Equatable {
        case redis7_0 = "REDIS_7_0"
        case redis6_x = "REDIS_6_X"
        case redis5_0 = "REDIS_5_0"
        case redis4_0 = "REDIS_4_0"

        public var versionString: String {
            switch self {
            case .redis7_0: return "7.0"
            case .redis6_x: return "6.x"
            case .redis5_0: return "5.0"
            case .redis4_0: return "4.0"
            }
        }
    }

    /// Connect mode
    public enum ConnectMode: String, Codable, Sendable, Equatable {
        case directPeering = "DIRECT_PEERING"
        case privateServiceAccess = "PRIVATE_SERVICE_ACCESS"
    }

    /// Transit encryption mode
    public enum TransitEncryptionMode: String, Codable, Sendable, Equatable {
        case disabled = "DISABLED"
        case serverAuthentication = "SERVER_AUTHENTICATION"
    }

    /// Read replicas mode
    public enum ReadReplicasMode: String, Codable, Sendable, Equatable {
        case readReplicasDisabled = "READ_REPLICAS_DISABLED"
        case readReplicasEnabled = "READ_REPLICAS_ENABLED"
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/instances/\(name)"
    }

    /// Command to create instance
    public var createCommand: String {
        var cmd = "gcloud redis instances create \(name)"
        cmd += " --region=\(region)"
        cmd += " --project=\(projectID)"
        cmd += " --tier=\(tier.rawValue)"
        cmd += " --size=\(memorySizeGB)"
        cmd += " --redis-version=\(redisVersion.rawValue)"

        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }

        if let network = authorizedNetwork {
            cmd += " --network=\(network)"
        }

        if let connectMode = connectMode {
            cmd += " --connect-mode=\(connectMode.rawValue)"
        }

        if let transitEncryption = transitEncryptionMode {
            cmd += " --transit-encryption-mode=\(transitEncryption.rawValue)"
        }

        if let authEnabled = authEnabled, authEnabled {
            cmd += " --enable-auth"
        }

        if let replicaCount = replicaCount {
            cmd += " --replica-count=\(replicaCount)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to update instance
    public var updateCommand: String {
        "gcloud redis instances update \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to delete instance
    public var deleteCommand: String {
        "gcloud redis instances delete \(name) --region=\(region) --project=\(projectID) --quiet"
    }

    /// Command to describe instance
    public var describeCommand: String {
        "gcloud redis instances describe \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to list instances
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud redis instances list --region=\(region) --project=\(projectID)"
    }

    /// Command to failover (Standard tier only)
    public var failoverCommand: String {
        "gcloud redis instances failover \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to upgrade Redis version
    public func upgradeCommand(toVersion: RedisVersion) -> String {
        "gcloud redis instances upgrade \(name) --region=\(region) --project=\(projectID) --redis-version=\(toVersion.rawValue)"
    }

    /// Command to export RDB
    public func exportCommand(gcsUri: String) -> String {
        "gcloud redis instances export \(gcsUri) --instance=\(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to import RDB
    public func importCommand(gcsUri: String) -> String {
        "gcloud redis instances import \(gcsUri) --instance=\(name) --region=\(region) --project=\(projectID)"
    }
}

// MARK: - Memorystore Memcached Instance

/// Represents a Memorystore for Memcached instance
public struct GoogleCloudMemcachedInstance: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let nodeCount: Int
    public let nodeCPUs: Int
    public let nodeMemoryMB: Int
    public let memcachedVersion: MemcachedVersion
    public let displayName: String?
    public let labels: [String: String]?
    public let authorizedNetwork: String?
    public let zones: [String]?

    public init(
        name: String,
        projectID: String,
        region: String,
        nodeCount: Int = 1,
        nodeCPUs: Int = 1,
        nodeMemoryMB: Int = 1024,
        memcachedVersion: MemcachedVersion = .memcached1_6,
        displayName: String? = nil,
        labels: [String: String]? = nil,
        authorizedNetwork: String? = nil,
        zones: [String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.nodeCount = nodeCount
        self.nodeCPUs = nodeCPUs
        self.nodeMemoryMB = nodeMemoryMB
        self.memcachedVersion = memcachedVersion
        self.displayName = displayName
        self.labels = labels
        self.authorizedNetwork = authorizedNetwork
        self.zones = zones
    }

    /// Memcached version
    public enum MemcachedVersion: String, Codable, Sendable, Equatable {
        case memcached1_6 = "MEMCACHE_1_6_15"
        case memcached1_5 = "MEMCACHE_1_5"
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/instances/\(name)"
    }

    /// Command to create instance
    public var createCommand: String {
        var cmd = "gcloud memcache instances create \(name)"
        cmd += " --region=\(region)"
        cmd += " --project=\(projectID)"
        cmd += " --node-count=\(nodeCount)"
        cmd += " --node-cpu=\(nodeCPUs)"
        cmd += " --node-memory=\(nodeMemoryMB)MB"
        cmd += " --memcached-version=\(memcachedVersion.rawValue)"

        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }

        if let network = authorizedNetwork {
            cmd += " --authorized-network=\(network)"
        }

        if let zones = zones, !zones.isEmpty {
            cmd += " --zones=\(zones.joined(separator: ","))"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to update instance
    public var updateCommand: String {
        "gcloud memcache instances update \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to delete instance
    public var deleteCommand: String {
        "gcloud memcache instances delete \(name) --region=\(region) --project=\(projectID) --quiet"
    }

    /// Command to describe instance
    public var describeCommand: String {
        "gcloud memcache instances describe \(name) --region=\(region) --project=\(projectID)"
    }

    /// Command to list instances
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud memcache instances list --region=\(region) --project=\(projectID)"
    }

    /// Command to apply parameters
    public var applyParametersCommand: String {
        "gcloud memcache instances apply-parameters \(name) --region=\(region) --project=\(projectID) --apply-all"
    }
}

// MARK: - Memorystore Operations

/// Common Memorystore operations
public enum MemorystoreOperations {

    /// Get Redis connection info
    public static func getRedisConnectionCommand(
        instanceName: String,
        region: String,
        projectID: String
    ) -> String {
        "gcloud redis instances describe \(instanceName) --region=\(region) --project=\(projectID) --format=\"value(host,port)\""
    }

    /// Get Redis auth string (if AUTH enabled)
    public static func getRedisAuthStringCommand(
        instanceName: String,
        region: String,
        projectID: String
    ) -> String {
        "gcloud redis instances get-auth-string \(instanceName) --region=\(region) --project=\(projectID)"
    }

    /// Scale Redis instance size
    public static func scaleRedisCommand(
        instanceName: String,
        region: String,
        projectID: String,
        newSizeGB: Int
    ) -> String {
        "gcloud redis instances update \(instanceName) --region=\(region) --project=\(projectID) --size=\(newSizeGB)"
    }

    /// Scale Memcached node count
    public static func scaleMemcachedCommand(
        instanceName: String,
        region: String,
        projectID: String,
        nodeCount: Int
    ) -> String {
        "gcloud memcache instances update \(instanceName) --region=\(region) --project=\(projectID) --node-count=\(nodeCount)"
    }

    /// Reschedule maintenance window
    public static func rescheduleMaintenanceCommand(
        instanceName: String,
        region: String,
        projectID: String,
        rescheduleType: String = "NEXT_AVAILABLE_WINDOW"
    ) -> String {
        "gcloud redis instances reschedule-maintenance \(instanceName) --region=\(region) --project=\(projectID) --reschedule-type=\(rescheduleType)"
    }
}

// MARK: - DAIS Memorystore Templates

/// DAIS-specific Memorystore configurations
public enum DAISMemorystoreTemplate {

    /// Cache Redis instance (Basic tier)
    public static func cacheInstance(
        projectID: String,
        region: String,
        deploymentName: String,
        memorySizeGB: Int = 1
    ) -> GoogleCloudRedisInstance {
        GoogleCloudRedisInstance(
            name: "\(deploymentName)-cache",
            projectID: projectID,
            region: region,
            tier: .basic,
            memorySizeGB: memorySizeGB,
            redisVersion: .redis7_0,
            displayName: "DAIS Cache",
            redisConfigs: [
                "maxmemory-policy": "allkeys-lru"
            ],
            labels: ["environment": "production", "purpose": "cache"]
        )
    }

    /// Session store Redis instance (Standard HA)
    public static func sessionStoreInstance(
        projectID: String,
        region: String,
        deploymentName: String,
        memorySizeGB: Int = 2
    ) -> GoogleCloudRedisInstance {
        GoogleCloudRedisInstance(
            name: "\(deploymentName)-sessions",
            projectID: projectID,
            region: region,
            tier: .standardHa,
            memorySizeGB: memorySizeGB,
            redisVersion: .redis7_0,
            displayName: "DAIS Session Store",
            redisConfigs: [
                "maxmemory-policy": "volatile-lru",
                "notify-keyspace-events": "Ex"
            ],
            labels: ["environment": "production", "purpose": "sessions"],
            transitEncryptionMode: .serverAuthentication,
            authEnabled: true
        )
    }

    /// High-availability Redis cluster
    public static func haClusterInstance(
        projectID: String,
        region: String,
        deploymentName: String,
        memorySizeGB: Int = 5,
        replicaCount: Int = 2
    ) -> GoogleCloudRedisInstance {
        GoogleCloudRedisInstance(
            name: "\(deploymentName)-ha-redis",
            projectID: projectID,
            region: region,
            tier: .standardHa,
            memorySizeGB: memorySizeGB,
            redisVersion: .redis7_0,
            displayName: "DAIS HA Redis",
            labels: ["environment": "production", "purpose": "ha-cache"],
            transitEncryptionMode: .serverAuthentication,
            authEnabled: true,
            replicaCount: replicaCount,
            readReplicasMode: .readReplicasEnabled
        )
    }

    /// Memcached for distributed caching
    public static func memcachedCluster(
        projectID: String,
        region: String,
        deploymentName: String,
        nodeCount: Int = 3
    ) -> GoogleCloudMemcachedInstance {
        GoogleCloudMemcachedInstance(
            name: "\(deploymentName)-memcached",
            projectID: projectID,
            region: region,
            nodeCount: nodeCount,
            nodeCPUs: 1,
            nodeMemoryMB: 1024,
            memcachedVersion: .memcached1_6,
            displayName: "DAIS Memcached Cluster",
            labels: ["environment": "production", "purpose": "distributed-cache"]
        )
    }

    /// Setup script for DAIS Memorystore
    public static func setupScript(
        projectID: String,
        region: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Memorystore Setup Script
        set -e

        PROJECT_ID="\(projectID)"
        REGION="\(region)"
        DEPLOYMENT_NAME="\(deploymentName)"

        echo "Enabling Memorystore APIs..."
        gcloud services enable redis.googleapis.com --project=${PROJECT_ID}
        gcloud services enable memcache.googleapis.com --project=${PROJECT_ID}

        echo "Creating Redis cache instance..."
        gcloud redis instances create ${DEPLOYMENT_NAME}-cache \\
            --region=${REGION} \\
            --project=${PROJECT_ID} \\
            --tier=basic \\
            --size=1 \\
            --redis-version=REDIS_7_0 \\
            --display-name="DAIS Cache" || true

        echo "Memorystore setup complete!"
        echo "Redis host: $(gcloud redis instances describe ${DEPLOYMENT_NAME}-cache --region=${REGION} --project=${PROJECT_ID} --format='value(host)')"
        """
    }

    /// Teardown script
    public static func teardownScript(
        projectID: String,
        region: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Memorystore Teardown Script
        set -e

        PROJECT_ID="\(projectID)"
        REGION="\(region)"
        DEPLOYMENT_NAME="\(deploymentName)"

        echo "Deleting Redis instances..."
        gcloud redis instances delete ${DEPLOYMENT_NAME}-cache \\
            --region=${REGION} --project=${PROJECT_ID} --quiet || true
        gcloud redis instances delete ${DEPLOYMENT_NAME}-sessions \\
            --region=${REGION} --project=${PROJECT_ID} --quiet || true

        echo "Deleting Memcached instances..."
        gcloud memcache instances delete ${DEPLOYMENT_NAME}-memcached \\
            --region=${REGION} --project=${PROJECT_ID} --quiet || true

        echo "Memorystore teardown complete!"
        """
    }

    /// Redis connection string format
    public static func redisConnectionString(host: String, port: Int = 6379) -> String {
        "redis://\(host):\(port)"
    }

    /// Redis connection string with auth
    public static func redisConnectionStringWithAuth(host: String, port: Int = 6379, authString: String) -> String {
        "redis://:\(authString)@\(host):\(port)"
    }
}
