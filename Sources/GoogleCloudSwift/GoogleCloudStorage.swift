//
//  GoogleCloudStorage.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 12/9/25.
//

import Foundation

/// Models for Google Cloud Storage configuration.
///
/// Cloud Storage is used for DAIS to store:
/// - Certificate backups
/// - Log archives
/// - Model artifacts
/// - Configuration snapshots
///
/// ## Pricing (as of 2024)
/// - **Free tier**: 5 GB-months Standard storage in us-east1, us-west1, us-central1
/// - **Standard**: $0.020/GB/month
/// - **Nearline**: $0.010/GB/month (min 30-day storage)
/// - **Coldline**: $0.004/GB/month (min 90-day storage)
/// - **Archive**: $0.0012/GB/month (min 365-day storage)
public struct GoogleCloudStorageBucket: Codable, Sendable, Equatable {
    /// Bucket name (globally unique)
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location for the bucket
    public let location: BucketLocation

    /// Storage class
    public let storageClass: StorageClass

    /// Whether to enable versioning
    public let versioning: Bool

    /// Lifecycle rules for automatic management
    public let lifecycleRules: [LifecycleRule]

    /// Labels for organization
    public let labels: [String: String]

    /// Whether uniform bucket-level access is enabled
    public let uniformBucketLevelAccess: Bool

    public init(
        name: String,
        projectID: String,
        location: BucketLocation = .usWest1,
        storageClass: StorageClass = .standard,
        versioning: Bool = true,
        lifecycleRules: [LifecycleRule] = [],
        labels: [String: String] = [:],
        uniformBucketLevelAccess: Bool = true
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.storageClass = storageClass
        self.versioning = versioning
        self.lifecycleRules = lifecycleRules
        self.labels = labels
        self.uniformBucketLevelAccess = uniformBucketLevelAccess
    }

    /// gsutil URI for this bucket
    public var gsutilURI: String {
        "gs://\(name)"
    }

    /// gcloud command to create this bucket
    public var createCommand: String {
        var cmd = "gcloud storage buckets create \(gsutilURI)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location.rawValue)"
        cmd += " --default-storage-class=\(storageClass.rawValue)"
        if uniformBucketLevelAccess {
            cmd += " --uniform-bucket-level-access"
        }
        return cmd
    }
}

// MARK: - Bucket Location

extension GoogleCloudStorageBucket {
    /// Storage bucket locations
    public enum BucketLocation: String, Codable, Sendable, CaseIterable {
        // Single Regions (lower latency, lower cost)
        case usWest1 = "us-west1"
        case usCentral1 = "us-central1"
        case usEast1 = "us-east1"
        case europeWest1 = "europe-west1"
        case asiaNortheast1 = "asia-northeast1"

        // Multi-Regions (higher availability)
        case us = "us"
        case eu = "eu"
        case asia = "asia"

        // Dual-Regions
        case nam4 = "nam4"  // Iowa and South Carolina
        case eur4 = "eur4"  // Finland and Netherlands

        public var isMultiRegion: Bool {
            switch self {
            case .us, .eu, .asia: return true
            default: return false
            }
        }

        public var displayName: String {
            switch self {
            case .usWest1: return "Oregon (us-west1)"
            case .usCentral1: return "Iowa (us-central1)"
            case .usEast1: return "South Carolina (us-east1)"
            case .europeWest1: return "Belgium (europe-west1)"
            case .asiaNortheast1: return "Tokyo (asia-northeast1)"
            case .us: return "United States (multi-region)"
            case .eu: return "European Union (multi-region)"
            case .asia: return "Asia (multi-region)"
            case .nam4: return "NAM4 (Iowa + South Carolina)"
            case .eur4: return "EUR4 (Finland + Netherlands)"
            }
        }
    }
}

// MARK: - Storage Class

extension GoogleCloudStorageBucket {
    /// Storage classes with different price/access tradeoffs
    public enum StorageClass: String, Codable, Sendable, CaseIterable {
        /// Frequently accessed data
        case standard = "STANDARD"

        /// Data accessed less than once per month
        case nearline = "NEARLINE"

        /// Data accessed less than once per quarter
        case coldline = "COLDLINE"

        /// Data accessed less than once per year
        case archive = "ARCHIVE"

        public var displayName: String {
            switch self {
            case .standard: return "Standard"
            case .nearline: return "Nearline (30-day min)"
            case .coldline: return "Coldline (90-day min)"
            case .archive: return "Archive (365-day min)"
            }
        }

        /// Approximate cost per GB per month in USD
        public var approximateCostPerGBMonth: Double {
            switch self {
            case .standard: return 0.020
            case .nearline: return 0.010
            case .coldline: return 0.004
            case .archive: return 0.0012
            }
        }
    }
}

// MARK: - Lifecycle Rules

extension GoogleCloudStorageBucket {
    /// Lifecycle rule for automatic object management
    public struct LifecycleRule: Codable, Sendable, Equatable {
        /// Action to take
        public let action: LifecycleAction

        /// Condition that triggers the action
        public let condition: LifecycleCondition

        public init(action: LifecycleAction, condition: LifecycleCondition) {
            self.action = action
            self.condition = condition
        }

        /// Move to nearline after 30 days
        public static let moveToNearlineAfter30Days = LifecycleRule(
            action: .setStorageClass(.nearline),
            condition: .init(ageDays: 30)
        )

        /// Move to coldline after 90 days
        public static let moveToColdlineAfter90Days = LifecycleRule(
            action: .setStorageClass(.coldline),
            condition: .init(ageDays: 90)
        )

        /// Move to archive after 365 days
        public static let moveToArchiveAfter365Days = LifecycleRule(
            action: .setStorageClass(.archive),
            condition: .init(ageDays: 365)
        )

        /// Delete old versions after 30 days
        public static let deleteOldVersionsAfter30Days = LifecycleRule(
            action: .delete,
            condition: .init(ageDays: 30, isLive: false)
        )

        /// Delete objects after 7 years (compliance)
        public static let deleteAfter7Years = LifecycleRule(
            action: .delete,
            condition: .init(ageDays: 2555)
        )
    }

    /// Lifecycle actions
    public enum LifecycleAction: Codable, Sendable, Equatable {
        /// Delete the object
        case delete

        /// Change storage class
        case setStorageClass(StorageClass)

        /// Abort incomplete multipart uploads
        case abortIncompleteMultipartUpload
    }

    /// Lifecycle condition
    public struct LifecycleCondition: Codable, Sendable, Equatable {
        /// Object age in days
        public let ageDays: Int?

        /// Created before date
        public let createdBefore: Date?

        /// Whether object is live (current version)
        public let isLive: Bool?

        /// Number of newer versions
        public let numNewerVersions: Int?

        /// Matches storage class
        public let matchesStorageClass: [StorageClass]?

        public init(
            ageDays: Int? = nil,
            createdBefore: Date? = nil,
            isLive: Bool? = nil,
            numNewerVersions: Int? = nil,
            matchesStorageClass: [StorageClass]? = nil
        ) {
            self.ageDays = ageDays
            self.createdBefore = createdBefore
            self.isLive = isLive
            self.numNewerVersions = numNewerVersions
            self.matchesStorageClass = matchesStorageClass
        }
    }
}

// MARK: - DAIS Bucket Templates

/// Predefined bucket configurations for DAIS
public enum DAISBucketTemplate {
    /// Bucket for certificate backups
    public static func certificateBackups(projectID: String, bucketSuffix: String) -> GoogleCloudStorageBucket {
        GoogleCloudStorageBucket(
            name: "butteryai-cert-backups-\(bucketSuffix)",
            projectID: projectID,
            location: .usWest1,
            storageClass: .standard,
            versioning: true,
            lifecycleRules: [
                .moveToColdlineAfter90Days,
                .moveToArchiveAfter365Days
            ],
            labels: [
                "app": "butteryai",
                "component": "certificates",
                "purpose": "backups"
            ]
        )
    }

    /// Bucket for log archives
    public static func logArchives(projectID: String, bucketSuffix: String) -> GoogleCloudStorageBucket {
        GoogleCloudStorageBucket(
            name: "butteryai-logs-\(bucketSuffix)",
            projectID: projectID,
            location: .usWest1,
            storageClass: .nearline,
            versioning: false,
            lifecycleRules: [
                .moveToColdlineAfter90Days,
                .deleteAfter7Years
            ],
            labels: [
                "app": "butteryai",
                "component": "logging",
                "purpose": "archives"
            ]
        )
    }

    /// Bucket for DAIS artifacts (executables, configs)
    public static func artifacts(projectID: String, bucketSuffix: String) -> GoogleCloudStorageBucket {
        GoogleCloudStorageBucket(
            name: "butteryai-artifacts-\(bucketSuffix)",
            projectID: projectID,
            location: .usWest1,
            storageClass: .standard,
            versioning: true,
            lifecycleRules: [
                .deleteOldVersionsAfter30Days
            ],
            labels: [
                "app": "butteryai",
                "component": "deployment",
                "purpose": "artifacts"
            ]
        )
    }
}
