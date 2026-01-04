//
//  GoogleCloudComputeInstance.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 12/9/25.
//

import Foundation

/// Represents a Google Compute Engine instance configuration for running DAIS nodes.
///
/// This model provides configuration options for deploying DAIS executables
/// on Google Cloud Compute Engine virtual machines.
///
/// ## Cost-Effective Options for DAIS
/// - **e2-micro**: Free tier eligible (1 per month in us-west1, us-central1, us-east1)
/// - **e2-small**: ~$12/month - good for light workloads
/// - **e2-medium**: ~$24/month - balanced performance
/// - **n2-standard-2**: ~$50/month - production workloads
///
/// ## Example Usage
/// ```swift
/// let instance = GoogleCloudComputeInstance(
///     name: "dais-node-1",
///     machineType: .e2Medium,
///     zone: "us-west1-a",
///     bootDisk: .init(
///         image: .ubuntuLTS,
///         sizeGB: 20
///     ),
///     networkTags: ["dais-node", "allow-grpc"],
///     startupScript: "#!/bin/bash\n./dais-executable --config /etc/dais/config.json"
/// )
/// ```
public struct GoogleCloudComputeInstance: Codable, Sendable, Equatable {
    /// Instance name (must be lowercase, max 63 characters)
    public let name: String

    /// Machine type for the instance
    public let machineType: GoogleCloudMachineType

    /// Zone where the instance will be created
    public let zone: String

    /// Boot disk configuration
    public let bootDisk: BootDiskConfig

    /// Network interface configuration
    public let network: NetworkConfig

    /// Network tags for firewall rules
    public let networkTags: [String]

    /// Service account configuration
    public let serviceAccount: ServiceAccountConfig?

    /// Labels for organization and billing
    public let labels: [String: String]

    /// Startup script to run when instance boots
    public let startupScript: String?

    /// Whether to enable deletion protection
    public let deletionProtection: Bool

    /// Scheduling options (preemptibility, etc.)
    public let scheduling: SchedulingConfig

    public init(
        name: String,
        machineType: GoogleCloudMachineType,
        zone: String,
        bootDisk: BootDiskConfig = .init(),
        network: NetworkConfig = .init(),
        networkTags: [String] = [],
        serviceAccount: ServiceAccountConfig? = nil,
        labels: [String: String] = [:],
        startupScript: String? = nil,
        deletionProtection: Bool = false,
        scheduling: SchedulingConfig = .init()
    ) {
        self.name = name
        self.machineType = machineType
        self.zone = zone
        self.bootDisk = bootDisk
        self.network = network
        self.networkTags = networkTags
        self.serviceAccount = serviceAccount
        self.labels = labels
        self.startupScript = startupScript
        self.deletionProtection = deletionProtection
        self.scheduling = scheduling
    }
}

// MARK: - Boot Disk Configuration

extension GoogleCloudComputeInstance {
    /// Configuration for the instance's boot disk
    public struct BootDiskConfig: Codable, Sendable, Equatable {
        /// The OS image to use
        public let image: OSImage

        /// Disk size in GB
        public let sizeGB: Int

        /// Disk type
        public let diskType: DiskType

        /// Whether to auto-delete the disk when instance is deleted
        public let autoDelete: Bool

        public init(
            image: OSImage = .ubuntuLTS,
            sizeGB: Int = 20,
            diskType: DiskType = .pdBalanced,
            autoDelete: Bool = true
        ) {
            self.image = image
            self.sizeGB = sizeGB
            self.diskType = diskType
            self.autoDelete = autoDelete
        }
    }

    /// Available OS images for DAIS deployment
    public enum OSImage: String, Codable, Sendable, CaseIterable {
        /// Ubuntu 22.04 LTS - Recommended for DAIS
        case ubuntuLTS = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"

        /// Ubuntu 24.04 LTS
        case ubuntu2404 = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"

        /// Debian 12 (Bookworm)
        case debian12 = "projects/debian-cloud/global/images/family/debian-12"

        /// Container-Optimized OS (for Docker deployments)
        case containerOptimized = "projects/cos-cloud/global/images/family/cos-stable"

        /// Rocky Linux 9 (RHEL-compatible)
        case rockyLinux9 = "projects/rocky-linux-cloud/global/images/family/rocky-linux-9"

        public var displayName: String {
            switch self {
            case .ubuntuLTS: return "Ubuntu 22.04 LTS"
            case .ubuntu2404: return "Ubuntu 24.04 LTS"
            case .debian12: return "Debian 12 (Bookworm)"
            case .containerOptimized: return "Container-Optimized OS"
            case .rockyLinux9: return "Rocky Linux 9"
            }
        }
    }

    /// Disk types available in Compute Engine
    public enum DiskType: String, Codable, Sendable, CaseIterable {
        /// Standard persistent disk (HDD) - cheapest
        case pdStandard = "pd-standard"

        /// Balanced persistent disk (SSD) - good price/performance
        case pdBalanced = "pd-balanced"

        /// SSD persistent disk - high performance
        case pdSSD = "pd-ssd"

        /// Extreme persistent disk - highest performance
        case pdExtreme = "pd-extreme"

        public var displayName: String {
            switch self {
            case .pdStandard: return "Standard (HDD)"
            case .pdBalanced: return "Balanced (SSD)"
            case .pdSSD: return "SSD"
            case .pdExtreme: return "Extreme (SSD)"
            }
        }
    }
}

// MARK: - Network Configuration

extension GoogleCloudComputeInstance {
    /// Network interface configuration
    public struct NetworkConfig: Codable, Sendable, Equatable {
        /// VPC network name (default is "default")
        public let network: String

        /// Subnetwork name (optional)
        public let subnetwork: String?

        /// Whether to assign an external IP
        public let assignExternalIP: Bool

        /// Specific external IP to use (if assignExternalIP is true)
        public let externalIP: String?

        /// Network tier (PREMIUM or STANDARD)
        public let networkTier: NetworkTier

        public init(
            network: String = "default",
            subnetwork: String? = nil,
            assignExternalIP: Bool = true,
            externalIP: String? = nil,
            networkTier: NetworkTier = .premium
        ) {
            self.network = network
            self.subnetwork = subnetwork
            self.assignExternalIP = assignExternalIP
            self.externalIP = externalIP
            self.networkTier = networkTier
        }
    }

    /// Network tier options
    public enum NetworkTier: String, Codable, Sendable {
        /// Premium tier - Google's high-quality global network
        case premium = "PREMIUM"

        /// Standard tier - cost-optimized, regional routing
        case standard = "STANDARD"
    }
}

// MARK: - Service Account Configuration

extension GoogleCloudComputeInstance {
    /// Service account configuration for the instance
    public struct ServiceAccountConfig: Codable, Sendable, Equatable {
        /// Service account email
        public let email: String

        /// OAuth scopes for the service account
        public let scopes: [String]

        public init(
            email: String,
            scopes: [String] = ServiceAccountConfig.defaultScopes
        ) {
            self.email = email
            self.scopes = scopes
        }

        /// Default scopes for DAIS nodes
        public static let defaultScopes: [String] = [
            "https://www.googleapis.com/auth/cloud-platform",
        ]

        /// Minimal scopes (storage and logging only)
        public static let minimalScopes: [String] = [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring.write",
        ]

        /// Scopes for instances that need Secret Manager access
        public static let secretManagerScopes: [String] = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/secretmanager",
        ]
    }
}

// MARK: - Scheduling Configuration

extension GoogleCloudComputeInstance {
    /// Scheduling options for the instance
    public struct SchedulingConfig: Codable, Sendable, Equatable {
        /// Whether this is a preemptible/spot instance
        public let preemptible: Bool

        /// Whether to use spot pricing (newer, replaces preemptible)
        public let spot: Bool

        /// Automatic restart on failure
        public let automaticRestart: Bool

        /// What to do on host maintenance
        public let onHostMaintenance: MaintenanceAction

        public init(
            preemptible: Bool = false,
            spot: Bool = false,
            automaticRestart: Bool = true,
            onHostMaintenance: MaintenanceAction = .migrate
        ) {
            self.preemptible = preemptible
            self.spot = spot
            self.automaticRestart = automaticRestart
            self.onHostMaintenance = onHostMaintenance
        }

        /// Cost-optimized scheduling (spot instance)
        public static let spot = SchedulingConfig(
            preemptible: false,
            spot: true,
            automaticRestart: false,
            onHostMaintenance: .terminate
        )

        /// Standard scheduling with high availability
        public static let standard = SchedulingConfig()
    }

    /// Actions during host maintenance events
    public enum MaintenanceAction: String, Codable, Sendable {
        /// Live migrate to another host
        case migrate = "MIGRATE"

        /// Terminate the instance
        case terminate = "TERMINATE"
    }
}

// MARK: - Machine Types

/// Google Cloud Compute Engine machine types
public enum GoogleCloudMachineType: String, Codable, Sendable, CaseIterable {
    // E2 Series - Cost-optimized (shared-core)
    /// 2 vCPUs (shared), 1 GB RAM - FREE TIER ELIGIBLE
    case e2Micro = "e2-micro"
    /// 2 vCPUs (shared), 2 GB RAM
    case e2Small = "e2-small"
    /// 2 vCPUs (shared), 4 GB RAM
    case e2Medium = "e2-medium"

    // E2 Standard - Cost-optimized
    /// 2 vCPUs, 8 GB RAM
    case e2Standard2 = "e2-standard-2"
    /// 4 vCPUs, 16 GB RAM
    case e2Standard4 = "e2-standard-4"
    /// 8 vCPUs, 32 GB RAM
    case e2Standard8 = "e2-standard-8"

    // E2 High-Memory
    /// 2 vCPUs, 16 GB RAM
    case e2Highmem2 = "e2-highmem-2"
    /// 4 vCPUs, 32 GB RAM
    case e2Highmem4 = "e2-highmem-4"

    // N2 Series - Balanced (Intel)
    /// 2 vCPUs, 8 GB RAM
    case n2Standard2 = "n2-standard-2"
    /// 4 vCPUs, 16 GB RAM
    case n2Standard4 = "n2-standard-4"
    /// 8 vCPUs, 32 GB RAM
    case n2Standard8 = "n2-standard-8"

    // N2D Series - AMD EPYC
    /// 2 vCPUs, 8 GB RAM
    case n2dStandard2 = "n2d-standard-2"
    /// 4 vCPUs, 16 GB RAM
    case n2dStandard4 = "n2d-standard-4"

    // C3 Series - Compute-optimized (newest)
    /// 4 vCPUs, 8 GB RAM
    case c3Highcpu4 = "c3-highcpu-4"
    /// 8 vCPUs, 16 GB RAM
    case c3Highcpu8 = "c3-highcpu-8"

    /// Human-readable description
    public var displayName: String {
        switch self {
        case .e2Micro: return "E2 Micro (2 shared vCPUs, 1 GB) - Free Tier"
        case .e2Small: return "E2 Small (2 shared vCPUs, 2 GB)"
        case .e2Medium: return "E2 Medium (2 shared vCPUs, 4 GB)"
        case .e2Standard2: return "E2 Standard (2 vCPUs, 8 GB)"
        case .e2Standard4: return "E2 Standard (4 vCPUs, 16 GB)"
        case .e2Standard8: return "E2 Standard (8 vCPUs, 32 GB)"
        case .e2Highmem2: return "E2 High-Memory (2 vCPUs, 16 GB)"
        case .e2Highmem4: return "E2 High-Memory (4 vCPUs, 32 GB)"
        case .n2Standard2: return "N2 Standard (2 vCPUs, 8 GB)"
        case .n2Standard4: return "N2 Standard (4 vCPUs, 16 GB)"
        case .n2Standard8: return "N2 Standard (8 vCPUs, 32 GB)"
        case .n2dStandard2: return "N2D Standard AMD (2 vCPUs, 8 GB)"
        case .n2dStandard4: return "N2D Standard AMD (4 vCPUs, 16 GB)"
        case .c3Highcpu4: return "C3 High-CPU (4 vCPUs, 8 GB)"
        case .c3Highcpu8: return "C3 High-CPU (8 vCPUs, 16 GB)"
        }
    }

    /// Approximate monthly cost in USD (on-demand, us-central1)
    public var approximateMonthlyCostUSD: Double {
        switch self {
        case .e2Micro: return 0      // Free tier
        case .e2Small: return 12
        case .e2Medium: return 24
        case .e2Standard2: return 49
        case .e2Standard4: return 98
        case .e2Standard8: return 196
        case .e2Highmem2: return 65
        case .e2Highmem4: return 130
        case .n2Standard2: return 58
        case .n2Standard4: return 116
        case .n2Standard8: return 232
        case .n2dStandard2: return 51
        case .n2dStandard4: return 102
        case .c3Highcpu4: return 110
        case .c3Highcpu8: return 220
        }
    }

    /// Whether this machine type is eligible for free tier
    public var isFreeTierEligible: Bool {
        self == .e2Micro
    }

    /// Recommended for DAIS development/testing
    public static let developmentRecommended: GoogleCloudMachineType = .e2Small

    /// Recommended for DAIS production
    public static let productionRecommended: GoogleCloudMachineType = .n2Standard2
}
