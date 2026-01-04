// GoogleCloudFilestore.swift
// Cloud Filestore API for managed NFS file shares

import Foundation

// MARK: - Filestore Instance

/// Represents a Cloud Filestore instance
public struct GoogleCloudFilestoreInstance: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let zone: String
    public let tier: Tier
    public let fileShares: [FileShare]
    public let networks: [NetworkConfig]
    public let description: String?
    public let labels: [String: String]?
    public let kmsKeyName: String?

    /// Tier of the Filestore instance
    public enum Tier: String, Codable, Sendable, Equatable {
        case basic = "BASIC_HDD"
        case basicSSD = "BASIC_SSD"
        case highScaleSSD = "HIGH_SCALE_SSD"
        case enterprise = "ENTERPRISE"
        case zonal = "ZONAL"
        case regional = "REGIONAL"

        public var description: String {
            switch self {
            case .basic:
                return "Basic HDD (1-63.9 TB)"
            case .basicSSD:
                return "Basic SSD (2.5-63.9 TB)"
            case .highScaleSSD:
                return "High Scale SSD (10-100 TB)"
            case .enterprise:
                return "Enterprise (1-10 TB, regional HA)"
            case .zonal:
                return "Zonal (1-100 TB, single zone)"
            case .regional:
                return "Regional (1-100 TB, regional HA)"
            }
        }

        public var minCapacityTB: Double {
            switch self {
            case .basic: return 1.0
            case .basicSSD: return 2.5
            case .highScaleSSD: return 10.0
            case .enterprise: return 1.0
            case .zonal: return 1.0
            case .regional: return 1.0
            }
        }

        public var maxCapacityTB: Double {
            switch self {
            case .basic: return 63.9
            case .basicSSD: return 63.9
            case .highScaleSSD: return 100.0
            case .enterprise: return 10.0
            case .zonal: return 100.0
            case .regional: return 100.0
            }
        }
    }

    /// File share configuration
    public struct FileShare: Codable, Sendable, Equatable {
        public let name: String
        public let capacityGB: Int
        public let nfsExportOptions: [NFSExportOption]?
        public let sourceBackup: String?

        public struct NFSExportOption: Codable, Sendable, Equatable {
            public let ipRanges: [String]?
            public let accessMode: AccessMode
            public let squashMode: SquashMode
            public let anonUID: Int?
            public let anonGID: Int?

            public enum AccessMode: String, Codable, Sendable, Equatable {
                case readOnly = "READ_ONLY"
                case readWrite = "READ_WRITE"
            }

            public enum SquashMode: String, Codable, Sendable, Equatable {
                case noRootSquash = "NO_ROOT_SQUASH"
                case rootSquash = "ROOT_SQUASH"
            }

            public init(
                ipRanges: [String]? = nil,
                accessMode: AccessMode = .readWrite,
                squashMode: SquashMode = .noRootSquash,
                anonUID: Int? = nil,
                anonGID: Int? = nil
            ) {
                self.ipRanges = ipRanges
                self.accessMode = accessMode
                self.squashMode = squashMode
                self.anonUID = anonUID
                self.anonGID = anonGID
            }
        }

        public init(
            name: String,
            capacityGB: Int,
            nfsExportOptions: [NFSExportOption]? = nil,
            sourceBackup: String? = nil
        ) {
            self.name = name
            self.capacityGB = capacityGB
            self.nfsExportOptions = nfsExportOptions
            self.sourceBackup = sourceBackup
        }
    }

    /// Network configuration for the instance
    public struct NetworkConfig: Codable, Sendable, Equatable {
        public let network: String
        public let modes: [Mode]
        public let reservedIPRange: String?
        public let connectMode: ConnectMode?

        public enum Mode: String, Codable, Sendable, Equatable {
            case modeIPv4 = "MODE_IPV4"
        }

        public enum ConnectMode: String, Codable, Sendable, Equatable {
            case directPeering = "DIRECT_PEERING"
            case privateServiceAccess = "PRIVATE_SERVICE_ACCESS"
        }

        public init(
            network: String,
            modes: [Mode] = [.modeIPv4],
            reservedIPRange: String? = nil,
            connectMode: ConnectMode? = nil
        ) {
            self.network = network
            self.modes = modes
            self.reservedIPRange = reservedIPRange
            self.connectMode = connectMode
        }
    }

    public init(
        name: String,
        projectID: String,
        zone: String,
        tier: Tier,
        fileShares: [FileShare],
        networks: [NetworkConfig],
        description: String? = nil,
        labels: [String: String]? = nil,
        kmsKeyName: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.zone = zone
        self.tier = tier
        self.fileShares = fileShares
        self.networks = networks
        self.description = description
        self.labels = labels
        self.kmsKeyName = kmsKeyName
    }

    /// Resource name for the instance
    public var resourceName: String {
        "projects/\(projectID)/locations/\(zone)/instances/\(name)"
    }

    /// Region derived from zone
    public var region: String {
        let parts = zone.split(separator: "-")
        if parts.count >= 2 {
            return "\(parts[0])-\(parts[1])"
        }
        return zone
    }

    /// Create command for the Filestore instance
    public var createCommand: String {
        var cmd = "gcloud filestore instances create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --zone=\(zone)"
        cmd += " --tier=\(tier.rawValue.lowercased().replacingOccurrences(of: "_", with: "-"))"

        if let firstShare = fileShares.first {
            cmd += " --file-share=name=\(firstShare.name),capacity=\(firstShare.capacityGB)GB"
        }

        if let firstNetwork = networks.first {
            cmd += " --network=name=\(firstNetwork.network)"
            if let reservedIP = firstNetwork.reservedIPRange {
                cmd += ",reserved-ip-range=\(reservedIP)"
            }
            if let connectMode = firstNetwork.connectMode {
                cmd += ",connect-mode=\(connectMode.rawValue.lowercased().replacingOccurrences(of: "_", with: "-"))"
            }
        }

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelString)"
        }

        if let kmsKey = kmsKeyName {
            cmd += " --kms-key=\(kmsKey)"
        }

        return cmd
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud filestore instances describe \(name) --project=\(projectID) --zone=\(zone)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud filestore instances delete \(name) --project=\(projectID) --zone=\(zone)"
    }

    /// Update command for capacity
    public func updateCapacityCommand(fileShareName: String, newCapacityGB: Int) -> String {
        "gcloud filestore instances update \(name) --project=\(projectID) --zone=\(zone) --file-share=name=\(fileShareName),capacity=\(newCapacityGB)GB"
    }

    /// Get NFS mount command
    public func mountCommand(fileShareName: String, mountPoint: String) -> String {
        let ipAddress = "<FILESTORE_IP>"  // Would be filled from instance details
        return "sudo mount -t nfs \(ipAddress):/\(fileShareName) \(mountPoint)"
    }

    /// List instances command
    public static func listCommand(projectID: String, zone: String? = nil) -> String {
        var cmd = "gcloud filestore instances list --project=\(projectID)"
        if let zone = zone {
            cmd += " --zone=\(zone)"
        }
        return cmd
    }
}

// MARK: - Filestore Backup

/// Represents a Filestore backup
public struct GoogleCloudFilestoreBackup: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let sourceInstance: String
    public let sourceFileShare: String
    public let description: String?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        region: String,
        sourceInstance: String,
        sourceFileShare: String,
        description: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.sourceInstance = sourceInstance
        self.sourceFileShare = sourceFileShare
        self.description = description
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/backups/\(name)"
    }

    /// Create backup command
    public var createCommand: String {
        var cmd = "gcloud filestore backups create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --source-instance=\(sourceInstance)"
        cmd += " --source-file-share=\(sourceFileShare)"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelString)"
        }

        return cmd
    }

    /// Describe backup command
    public var describeCommand: String {
        "gcloud filestore backups describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// Delete backup command
    public var deleteCommand: String {
        "gcloud filestore backups delete \(name) --project=\(projectID) --region=\(region)"
    }

    /// Restore backup to new instance command
    public func restoreCommand(
        targetInstance: String,
        targetZone: String,
        targetFileShare: String,
        tier: GoogleCloudFilestoreInstance.Tier,
        network: String
    ) -> String {
        var cmd = "gcloud filestore instances restore \(targetInstance)"
        cmd += " --project=\(projectID)"
        cmd += " --zone=\(targetZone)"
        cmd += " --source-backup=\(resourceName)"
        cmd += " --file-share=name=\(targetFileShare)"
        cmd += " --tier=\(tier.rawValue.lowercased().replacingOccurrences(of: "_", with: "-"))"
        cmd += " --network=name=\(network)"
        return cmd
    }

    /// List backups command
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud filestore backups list --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }
}

// MARK: - Filestore Snapshot

/// Represents a Filestore snapshot
public struct GoogleCloudFilestoreSnapshot: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let zone: String
    public let instanceName: String
    public let description: String?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        zone: String,
        instanceName: String,
        description: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.zone = zone
        self.instanceName = instanceName
        self.description = description
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(zone)/instances/\(instanceName)/snapshots/\(name)"
    }

    /// Create snapshot command
    public var createCommand: String {
        var cmd = "gcloud filestore snapshots create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(zone)"
        cmd += " --instance=\(instanceName)"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if let labels = labels, !labels.isEmpty {
            let labelString = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelString)"
        }

        return cmd
    }

    /// Delete snapshot command
    public var deleteCommand: String {
        "gcloud filestore snapshots delete \(name) --project=\(projectID) --region=\(zone) --instance=\(instanceName)"
    }

    /// List snapshots command
    public static func listCommand(projectID: String, zone: String, instanceName: String) -> String {
        "gcloud filestore snapshots list --project=\(projectID) --region=\(zone) --instance=\(instanceName)"
    }
}

// MARK: - Filestore Operations

/// Operations helper for Filestore
public struct FilestoreOperations {

    /// Enable Filestore API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable file.googleapis.com --project=\(projectID)"
    }

    /// Get instance IP address
    public static func getIPAddressCommand(instanceName: String, projectID: String, zone: String) -> String {
        "gcloud filestore instances describe \(instanceName) --project=\(projectID) --zone=\(zone) --format=\"value(networks[0].ipAddresses[0])\""
    }

    /// List operations
    public static func listOperationsCommand(projectID: String, zone: String) -> String {
        "gcloud filestore operations list --project=\(projectID) --zone=\(zone)"
    }

    /// Describe operation
    public static func describeOperationCommand(operationName: String, projectID: String, zone: String) -> String {
        "gcloud filestore operations describe \(operationName) --project=\(projectID) --zone=\(zone)"
    }

    /// Cancel operation
    public static func cancelOperationCommand(operationName: String, projectID: String, zone: String) -> String {
        "gcloud filestore operations cancel \(operationName) --project=\(projectID) --zone=\(zone)"
    }
}

// MARK: - DAIS Filestore Template

/// Filestore templates for DAIS deployments
public struct DAISFilestoreTemplate {

    /// Create a shared storage instance for applications
    public static func sharedStorage(
        projectID: String,
        zone: String,
        deploymentName: String,
        capacityGB: Int = 1024,
        network: String = "default"
    ) -> GoogleCloudFilestoreInstance {
        GoogleCloudFilestoreInstance(
            name: "\(deploymentName)-shared-storage",
            projectID: projectID,
            zone: zone,
            tier: .basicSSD,
            fileShares: [
                GoogleCloudFilestoreInstance.FileShare(
                    name: "shared",
                    capacityGB: capacityGB
                )
            ],
            networks: [
                GoogleCloudFilestoreInstance.NetworkConfig(
                    network: network
                )
            ],
            description: "Shared storage for \(deploymentName)",
            labels: [
                "deployment": deploymentName,
                "purpose": "shared-storage"
            ]
        )
    }

    /// Create an enterprise-grade HA storage instance
    public static func enterpriseStorage(
        projectID: String,
        region: String,
        deploymentName: String,
        capacityGB: Int = 2048,
        network: String,
        kmsKeyName: String? = nil
    ) -> GoogleCloudFilestoreInstance {
        GoogleCloudFilestoreInstance(
            name: "\(deploymentName)-enterprise-storage",
            projectID: projectID,
            zone: region,  // Enterprise uses region
            tier: .enterprise,
            fileShares: [
                GoogleCloudFilestoreInstance.FileShare(
                    name: "enterprise",
                    capacityGB: capacityGB,
                    nfsExportOptions: [
                        GoogleCloudFilestoreInstance.FileShare.NFSExportOption(
                            accessMode: .readWrite,
                            squashMode: .rootSquash
                        )
                    ]
                )
            ],
            networks: [
                GoogleCloudFilestoreInstance.NetworkConfig(
                    network: network,
                    connectMode: .privateServiceAccess
                )
            ],
            description: "Enterprise storage for \(deploymentName)",
            labels: [
                "deployment": deploymentName,
                "purpose": "enterprise-storage",
                "tier": "enterprise"
            ],
            kmsKeyName: kmsKeyName
        )
    }

    /// Create a high-scale storage for data processing
    public static func dataProcessingStorage(
        projectID: String,
        zone: String,
        deploymentName: String,
        capacityGB: Int = 10240,
        network: String
    ) -> GoogleCloudFilestoreInstance {
        GoogleCloudFilestoreInstance(
            name: "\(deploymentName)-data-storage",
            projectID: projectID,
            zone: zone,
            tier: .highScaleSSD,
            fileShares: [
                GoogleCloudFilestoreInstance.FileShare(
                    name: "data",
                    capacityGB: capacityGB
                )
            ],
            networks: [
                GoogleCloudFilestoreInstance.NetworkConfig(
                    network: network
                )
            ],
            description: "High-scale data storage for \(deploymentName)",
            labels: [
                "deployment": deploymentName,
                "purpose": "data-processing"
            ]
        )
    }

    /// Create backup for an instance
    public static func instanceBackup(
        projectID: String,
        region: String,
        deploymentName: String,
        sourceInstanceZone: String,
        sourceFileShare: String = "shared"
    ) -> GoogleCloudFilestoreBackup {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())

        return GoogleCloudFilestoreBackup(
            name: "\(deploymentName)-backup-\(dateString)",
            projectID: projectID,
            region: region,
            sourceInstance: "projects/\(projectID)/locations/\(sourceInstanceZone)/instances/\(deploymentName)-shared-storage",
            sourceFileShare: sourceFileShare,
            description: "Automated backup for \(deploymentName)",
            labels: [
                "deployment": deploymentName,
                "type": "scheduled-backup"
            ]
        )
    }

    /// Generate fstab entry for persistent mount
    public static func fstabEntry(
        filestoreIP: String,
        fileShareName: String,
        mountPoint: String,
        options: String = "defaults,timeo=600,retrans=3,_netdev"
    ) -> String {
        "\(filestoreIP):/\(fileShareName) \(mountPoint) nfs \(options) 0 0"
    }

    /// Generate mount script
    public static func mountScript(
        filestoreIP: String,
        fileShareName: String,
        mountPoint: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        MOUNT_POINT="\(mountPoint)"
        NFS_SERVER="\(filestoreIP):/\(fileShareName)"

        # Install NFS client if not present
        if ! command -v mount.nfs &> /dev/null; then
            if [ -f /etc/debian_version ]; then
                sudo apt-get update && sudo apt-get install -y nfs-common
            elif [ -f /etc/redhat-release ]; then
                sudo yum install -y nfs-utils
            fi
        fi

        # Create mount point
        sudo mkdir -p "$MOUNT_POINT"

        # Mount the NFS share
        sudo mount -t nfs "$NFS_SERVER" "$MOUNT_POINT"

        # Verify mount
        if mountpoint -q "$MOUNT_POINT"; then
            echo "Successfully mounted $NFS_SERVER to $MOUNT_POINT"
        else
            echo "Failed to mount NFS share"
            exit 1
        fi
        """
    }

    /// Generate setup script
    public static func setupScript(
        projectID: String,
        zone: String,
        deploymentName: String,
        capacityGB: Int = 1024,
        network: String = "default"
    ) -> String {
        """
        #!/bin/bash
        set -e

        # Filestore Setup for \(deploymentName)
        # Project: \(projectID)
        # Zone: \(zone)

        echo "Enabling Filestore API..."
        gcloud services enable file.googleapis.com --project=\(projectID)

        echo "Creating Filestore instance..."
        gcloud filestore instances create \(deploymentName)-shared-storage \\
            --project=\(projectID) \\
            --zone=\(zone) \\
            --tier=basic-ssd \\
            --file-share=name=shared,capacity=\(capacityGB)GB \\
            --network=name=\(network) \\
            --labels=deployment=\(deploymentName)

        echo "Waiting for instance to be ready..."
        while true; do
            STATE=$(gcloud filestore instances describe \(deploymentName)-shared-storage \\
                --project=\(projectID) \\
                --zone=\(zone) \\
                --format="value(state)")
            if [ "$STATE" == "READY" ]; then
                break
            fi
            echo "Instance state: $STATE, waiting..."
            sleep 30
        done

        echo "Getting instance IP address..."
        IP_ADDRESS=$(gcloud filestore instances describe \(deploymentName)-shared-storage \\
            --project=\(projectID) \\
            --zone=\(zone) \\
            --format="value(networks[0].ipAddresses[0])")

        echo ""
        echo "Filestore instance created successfully!"
        echo "Instance: \(deploymentName)-shared-storage"
        echo "IP Address: $IP_ADDRESS"
        echo "Mount command: sudo mount -t nfs $IP_ADDRESS:/shared /mnt/filestore"
        """
    }

    /// Generate teardown script
    public static func teardownScript(
        projectID: String,
        zone: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # Filestore Teardown for \(deploymentName)

        echo "Deleting Filestore instance..."
        gcloud filestore instances delete \(deploymentName)-shared-storage \\
            --project=\(projectID) \\
            --zone=\(zone) \\
            --quiet || true

        echo "Filestore teardown complete!"
        """
    }
}
