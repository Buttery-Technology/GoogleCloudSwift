// GoogleCloudVPCServiceControls.swift
// VPC Service Controls API for data exfiltration prevention

import Foundation

// MARK: - Access Policy

/// Represents a VPC Service Controls access policy
public struct GoogleCloudAccessPolicy: Codable, Sendable, Equatable {
    public let name: String
    public let organizationID: String
    public let title: String
    public let scopes: [String]?

    public init(
        name: String,
        organizationID: String,
        title: String,
        scopes: [String]? = nil
    ) {
        self.name = name
        self.organizationID = organizationID
        self.title = title
        self.scopes = scopes
    }

    /// Resource name for the access policy
    public var resourceName: String {
        "accessPolicies/\(name)"
    }

    /// Create an access policy
    public var createCommand: String {
        var cmd = "gcloud access-context-manager policies create"
        cmd += " --organization=\(organizationID)"
        cmd += " --title=\"\(title)\""
        if let scopes = scopes, !scopes.isEmpty {
            cmd += " --scopes=\(scopes.joined(separator: ","))"
        }
        return cmd
    }

    /// Describe an access policy
    public var describeCommand: String {
        "gcloud access-context-manager policies describe \(name)"
    }

    /// Delete an access policy
    public var deleteCommand: String {
        "gcloud access-context-manager policies delete \(name)"
    }

    /// List access policies
    public static func listCommand(organizationID: String) -> String {
        "gcloud access-context-manager policies list --organization=\(organizationID)"
    }
}

// MARK: - Service Perimeter

/// Represents a VPC Service Controls service perimeter
public struct GoogleCloudServicePerimeter: Codable, Sendable, Equatable {
    public let name: String
    public let policyID: String
    public let title: String
    public let description: String?
    public let perimeterType: PerimeterType
    public let resources: [String]
    public let restrictedServices: [String]
    public let accessLevels: [String]
    public let vpcAccessibleServices: VPCAccessibleServices?
    public let ingressPolicies: [IngressPolicy]?
    public let egressPolicies: [EgressPolicy]?
    public let useExplicitDryRunSpec: Bool?

    /// Type of service perimeter
    public enum PerimeterType: String, Codable, Sendable, Equatable {
        case regular = "PERIMETER_TYPE_REGULAR"
        case bridge = "PERIMETER_TYPE_BRIDGE"
    }

    /// VPC accessible services configuration
    public struct VPCAccessibleServices: Codable, Sendable, Equatable {
        public let enableRestriction: Bool
        public let allowedServices: [String]

        public init(enableRestriction: Bool, allowedServices: [String]) {
            self.enableRestriction = enableRestriction
            self.allowedServices = allowedServices
        }
    }

    /// Ingress policy for the perimeter
    public struct IngressPolicy: Codable, Sendable, Equatable {
        public let ingressFrom: IngressFrom
        public let ingressTo: IngressTo

        public struct IngressFrom: Codable, Sendable, Equatable {
            public let identityType: IdentityType?
            public let identities: [String]?
            public let sources: [IngressSource]?

            public enum IdentityType: String, Codable, Sendable, Equatable {
                case anyIdentity = "ANY_IDENTITY"
                case anyUserAccount = "ANY_USER_ACCOUNT"
                case anyServiceAccount = "ANY_SERVICE_ACCOUNT"
            }

            public struct IngressSource: Codable, Sendable, Equatable {
                public let accessLevel: String?
                public let resource: String?

                public init(accessLevel: String? = nil, resource: String? = nil) {
                    self.accessLevel = accessLevel
                    self.resource = resource
                }
            }

            public init(
                identityType: IdentityType? = nil,
                identities: [String]? = nil,
                sources: [IngressSource]? = nil
            ) {
                self.identityType = identityType
                self.identities = identities
                self.sources = sources
            }
        }

        public struct IngressTo: Codable, Sendable, Equatable {
            public let operations: [ServiceOperation]
            public let resources: [String]?

            public init(operations: [ServiceOperation], resources: [String]? = nil) {
                self.operations = operations
                self.resources = resources
            }
        }

        public init(ingressFrom: IngressFrom, ingressTo: IngressTo) {
            self.ingressFrom = ingressFrom
            self.ingressTo = ingressTo
        }
    }

    /// Egress policy for the perimeter
    public struct EgressPolicy: Codable, Sendable, Equatable {
        public let egressFrom: EgressFrom
        public let egressTo: EgressTo

        public struct EgressFrom: Codable, Sendable, Equatable {
            public let identityType: IngressPolicy.IngressFrom.IdentityType?
            public let identities: [String]?

            public init(
                identityType: IngressPolicy.IngressFrom.IdentityType? = nil,
                identities: [String]? = nil
            ) {
                self.identityType = identityType
                self.identities = identities
            }
        }

        public struct EgressTo: Codable, Sendable, Equatable {
            public let operations: [ServiceOperation]
            public let resources: [String]?
            public let externalResources: [String]?

            public init(
                operations: [ServiceOperation],
                resources: [String]? = nil,
                externalResources: [String]? = nil
            ) {
                self.operations = operations
                self.resources = resources
                self.externalResources = externalResources
            }
        }

        public init(egressFrom: EgressFrom, egressTo: EgressTo) {
            self.egressFrom = egressFrom
            self.egressTo = egressTo
        }
    }

    /// Service operation specification
    public struct ServiceOperation: Codable, Sendable, Equatable {
        public let serviceName: String
        public let methodSelectors: [MethodSelector]?

        public struct MethodSelector: Codable, Sendable, Equatable {
            public let method: String?
            public let permission: String?

            public init(method: String? = nil, permission: String? = nil) {
                self.method = method
                self.permission = permission
            }
        }

        public init(serviceName: String, methodSelectors: [MethodSelector]? = nil) {
            self.serviceName = serviceName
            self.methodSelectors = methodSelectors
        }
    }

    public init(
        name: String,
        policyID: String,
        title: String,
        description: String? = nil,
        perimeterType: PerimeterType = .regular,
        resources: [String] = [],
        restrictedServices: [String] = [],
        accessLevels: [String] = [],
        vpcAccessibleServices: VPCAccessibleServices? = nil,
        ingressPolicies: [IngressPolicy]? = nil,
        egressPolicies: [EgressPolicy]? = nil,
        useExplicitDryRunSpec: Bool? = nil
    ) {
        self.name = name
        self.policyID = policyID
        self.title = title
        self.description = description
        self.perimeterType = perimeterType
        self.resources = resources
        self.restrictedServices = restrictedServices
        self.accessLevels = accessLevels
        self.vpcAccessibleServices = vpcAccessibleServices
        self.ingressPolicies = ingressPolicies
        self.egressPolicies = egressPolicies
        self.useExplicitDryRunSpec = useExplicitDryRunSpec
    }

    /// Resource name for the perimeter
    public var resourceName: String {
        "accessPolicies/\(policyID)/servicePerimeters/\(name)"
    }

    /// Create a service perimeter
    public var createCommand: String {
        var cmd = "gcloud access-context-manager perimeters create \(name)"
        cmd += " --policy=\(policyID)"
        cmd += " --title=\"\(title)\""
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if perimeterType == .bridge {
            cmd += " --perimeter-type=bridge"
        }
        if !resources.isEmpty {
            cmd += " --resources=\(resources.joined(separator: ","))"
        }
        if !restrictedServices.isEmpty {
            cmd += " --restricted-services=\(restrictedServices.joined(separator: ","))"
        }
        if !accessLevels.isEmpty {
            cmd += " --access-levels=\(accessLevels.joined(separator: ","))"
        }
        if let vpcServices = vpcAccessibleServices {
            if vpcServices.enableRestriction {
                cmd += " --enable-vpc-accessible-services"
                if !vpcServices.allowedServices.isEmpty {
                    cmd += " --vpc-allowed-services=\(vpcServices.allowedServices.joined(separator: ","))"
                }
            }
        }
        return cmd
    }

    /// Describe a service perimeter
    public var describeCommand: String {
        "gcloud access-context-manager perimeters describe \(name) --policy=\(policyID)"
    }

    /// Delete a service perimeter
    public var deleteCommand: String {
        "gcloud access-context-manager perimeters delete \(name) --policy=\(policyID)"
    }

    /// Update resources in the perimeter
    public func updateResourcesCommand(resources: [String]) -> String {
        "gcloud access-context-manager perimeters update \(name) --policy=\(policyID) --resources=\(resources.joined(separator: ","))"
    }

    /// Add resources to the perimeter
    public func addResourcesCommand(resources: [String]) -> String {
        "gcloud access-context-manager perimeters update \(name) --policy=\(policyID) --add-resources=\(resources.joined(separator: ","))"
    }

    /// Remove resources from the perimeter
    public func removeResourcesCommand(resources: [String]) -> String {
        "gcloud access-context-manager perimeters update \(name) --policy=\(policyID) --remove-resources=\(resources.joined(separator: ","))"
    }

    /// Update restricted services
    public func updateRestrictedServicesCommand(services: [String]) -> String {
        "gcloud access-context-manager perimeters update \(name) --policy=\(policyID) --restricted-services=\(services.joined(separator: ","))"
    }

    /// Perform dry-run on the perimeter
    public var dryRunCreateCommand: String {
        var cmd = createCommand
        cmd += " --dry-run"
        return cmd
    }

    /// List service perimeters
    public static func listCommand(policyID: String) -> String {
        "gcloud access-context-manager perimeters list --policy=\(policyID)"
    }
}

// MARK: - Access Level

/// Represents a VPC Service Controls access level
public struct GoogleCloudAccessLevel: Codable, Sendable, Equatable {
    public let name: String
    public let policyID: String
    public let title: String
    public let description: String?
    public let basic: BasicLevel?
    public let custom: CustomLevel?

    /// Basic access level conditions
    public struct BasicLevel: Codable, Sendable, Equatable {
        public let conditions: [Condition]
        public let combiningFunction: CombiningFunction

        public enum CombiningFunction: String, Codable, Sendable, Equatable {
            case and = "AND"
            case or = "OR"
        }

        public struct Condition: Codable, Sendable, Equatable {
            public let ipSubnetworks: [String]?
            public let devicePolicy: DevicePolicy?
            public let requiredAccessLevels: [String]?
            public let negate: Bool?
            public let members: [String]?
            public let regions: [String]?

            public struct DevicePolicy: Codable, Sendable, Equatable {
                public let requireScreenlock: Bool?
                public let allowedEncryptionStatuses: [EncryptionStatus]?
                public let osConstraints: [OSConstraint]?
                public let allowedDeviceManagementLevels: [DeviceManagementLevel]?
                public let requireAdminApproval: Bool?
                public let requireCorpOwned: Bool?

                public enum EncryptionStatus: String, Codable, Sendable, Equatable {
                    case encryptionUnspecified = "ENCRYPTION_UNSPECIFIED"
                    case encryptionUnsupported = "ENCRYPTION_UNSUPPORTED"
                    case unencrypted = "UNENCRYPTED"
                    case encrypted = "ENCRYPTED"
                }

                public enum DeviceManagementLevel: String, Codable, Sendable, Equatable {
                    case managementUnspecified = "MANAGEMENT_UNSPECIFIED"
                    case none = "NONE"
                    case basic = "BASIC"
                    case complete = "COMPLETE"
                }

                public struct OSConstraint: Codable, Sendable, Equatable {
                    public let osType: OSType
                    public let minimumVersion: String?
                    public let requireVerifiedChromeOS: Bool?

                    public enum OSType: String, Codable, Sendable, Equatable {
                        case osUnspecified = "OS_UNSPECIFIED"
                        case desktopMac = "DESKTOP_MAC"
                        case desktopWindows = "DESKTOP_WINDOWS"
                        case desktopLinux = "DESKTOP_LINUX"
                        case desktopChromeOS = "DESKTOP_CHROME_OS"
                        case android = "ANDROID"
                        case ios = "IOS"
                    }

                    public init(
                        osType: OSType,
                        minimumVersion: String? = nil,
                        requireVerifiedChromeOS: Bool? = nil
                    ) {
                        self.osType = osType
                        self.minimumVersion = minimumVersion
                        self.requireVerifiedChromeOS = requireVerifiedChromeOS
                    }
                }

                public init(
                    requireScreenlock: Bool? = nil,
                    allowedEncryptionStatuses: [EncryptionStatus]? = nil,
                    osConstraints: [OSConstraint]? = nil,
                    allowedDeviceManagementLevels: [DeviceManagementLevel]? = nil,
                    requireAdminApproval: Bool? = nil,
                    requireCorpOwned: Bool? = nil
                ) {
                    self.requireScreenlock = requireScreenlock
                    self.allowedEncryptionStatuses = allowedEncryptionStatuses
                    self.osConstraints = osConstraints
                    self.allowedDeviceManagementLevels = allowedDeviceManagementLevels
                    self.requireAdminApproval = requireAdminApproval
                    self.requireCorpOwned = requireCorpOwned
                }
            }

            public init(
                ipSubnetworks: [String]? = nil,
                devicePolicy: DevicePolicy? = nil,
                requiredAccessLevels: [String]? = nil,
                negate: Bool? = nil,
                members: [String]? = nil,
                regions: [String]? = nil
            ) {
                self.ipSubnetworks = ipSubnetworks
                self.devicePolicy = devicePolicy
                self.requiredAccessLevels = requiredAccessLevels
                self.negate = negate
                self.members = members
                self.regions = regions
            }
        }

        public init(conditions: [Condition], combiningFunction: CombiningFunction = .and) {
            self.conditions = conditions
            self.combiningFunction = combiningFunction
        }
    }

    /// Custom access level with CEL expression
    public struct CustomLevel: Codable, Sendable, Equatable {
        public let expression: String

        public init(expression: String) {
            self.expression = expression
        }
    }

    public init(
        name: String,
        policyID: String,
        title: String,
        description: String? = nil,
        basic: BasicLevel? = nil,
        custom: CustomLevel? = nil
    ) {
        self.name = name
        self.policyID = policyID
        self.title = title
        self.description = description
        self.basic = basic
        self.custom = custom
    }

    /// Resource name for the access level
    public var resourceName: String {
        "accessPolicies/\(policyID)/accessLevels/\(name)"
    }

    /// Create an access level with IP-based conditions
    public var createCommand: String {
        var cmd = "gcloud access-context-manager levels create \(name)"
        cmd += " --policy=\(policyID)"
        cmd += " --title=\"\(title)\""
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        if let basic = basic, let firstCondition = basic.conditions.first {
            if let ipSubnetworks = firstCondition.ipSubnetworks, !ipSubnetworks.isEmpty {
                cmd += " --basic-level-spec=\"ipSubnetworks: [\(ipSubnetworks.map { "\"\($0)\"" }.joined(separator: ", "))]"
                cmd += ", combiningFunction: \(basic.combiningFunction.rawValue)\""
            }
            if let members = firstCondition.members, !members.isEmpty {
                cmd += " --basic-level-spec=\"members: [\(members.map { "\"\($0)\"" }.joined(separator: ", "))]"
                cmd += ", combiningFunction: \(basic.combiningFunction.rawValue)\""
            }
        }
        if let custom = custom {
            cmd += " --custom-level-spec=\"expression: \\\"\(custom.expression)\\\"\""
        }
        return cmd
    }

    /// Describe an access level
    public var describeCommand: String {
        "gcloud access-context-manager levels describe \(name) --policy=\(policyID)"
    }

    /// Delete an access level
    public var deleteCommand: String {
        "gcloud access-context-manager levels delete \(name) --policy=\(policyID)"
    }

    /// Update an access level
    public func updateCommand(title: String? = nil, description: String? = nil) -> String {
        var cmd = "gcloud access-context-manager levels update \(name) --policy=\(policyID)"
        if let title = title {
            cmd += " --title=\"\(title)\""
        }
        if let description = description {
            cmd += " --description=\"\(description)\""
        }
        return cmd
    }

    /// List access levels
    public static func listCommand(policyID: String) -> String {
        "gcloud access-context-manager levels list --policy=\(policyID)"
    }
}

// MARK: - Common Restricted Services

/// Common Google Cloud services to restrict in perimeters
public struct RestrictedServices {
    /// Storage services
    public static let storage = "storage.googleapis.com"
    public static let bigquery = "bigquery.googleapis.com"
    public static let bigtable = "bigtable.googleapis.com"
    public static let spanner = "spanner.googleapis.com"
    public static let firestore = "firestore.googleapis.com"
    public static let datastore = "datastore.googleapis.com"

    /// Compute services
    public static let compute = "compute.googleapis.com"
    public static let gke = "container.googleapis.com"
    public static let cloudRun = "run.googleapis.com"
    public static let cloudFunctions = "cloudfunctions.googleapis.com"
    public static let appEngine = "appengine.googleapis.com"

    /// AI/ML services
    public static let aiPlatform = "aiplatform.googleapis.com"
    public static let vertexAI = "aiplatform.googleapis.com"
    public static let visionAI = "vision.googleapis.com"
    public static let speechToText = "speech.googleapis.com"
    public static let textToSpeech = "texttospeech.googleapis.com"
    public static let translate = "translate.googleapis.com"

    /// Security services
    public static let secretManager = "secretmanager.googleapis.com"
    public static let kms = "cloudkms.googleapis.com"

    /// Analytics services
    public static let pubsub = "pubsub.googleapis.com"
    public static let dataflow = "dataflow.googleapis.com"
    public static let dataproc = "dataproc.googleapis.com"

    /// All commonly restricted services
    public static let allCommon: [String] = [
        storage, bigquery, bigtable, spanner, firestore, datastore,
        compute, gke, cloudRun, cloudFunctions, appEngine,
        aiPlatform, visionAI, speechToText, textToSpeech, translate,
        secretManager, kms,
        pubsub, dataflow, dataproc
    ]

    /// Data storage services only
    public static let dataStorage: [String] = [
        storage, bigquery, bigtable, spanner, firestore, datastore
    ]

    /// AI/ML services only
    public static let aiML: [String] = [
        aiPlatform, visionAI, speechToText, textToSpeech, translate
    ]
}

// MARK: - VPC-SC Operations

/// Operations for VPC Service Controls
public struct VPCServiceControlsOperations {

    /// Enable VPC Service Controls API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable accesscontextmanager.googleapis.com --project=\(projectID)"
    }

    /// Replace all perimeters in a policy (bulk operation)
    public static func replacePerimetersCommand(policyID: String, perimeterFile: String) -> String {
        "gcloud access-context-manager perimeters replace-all \(policyID) --source-file=\(perimeterFile)"
    }

    /// Replace all access levels in a policy (bulk operation)
    public static func replaceLevelsCommand(policyID: String, levelsFile: String) -> String {
        "gcloud access-context-manager levels replace-all \(policyID) --source-file=\(levelsFile)"
    }

    /// Commit dry-run changes to a perimeter
    public static func commitDryRunCommand(perimeterName: String, policyID: String) -> String {
        "gcloud access-context-manager perimeters dry-run enforce \(perimeterName) --policy=\(policyID)"
    }

    /// Clear dry-run spec from a perimeter
    public static func clearDryRunCommand(perimeterName: String, policyID: String) -> String {
        "gcloud access-context-manager perimeters dry-run drop \(perimeterName) --policy=\(policyID)"
    }

    /// Create a perimeter from YAML file
    public static func createPerimeterFromFileCommand(perimeterName: String, policyID: String, filePath: String) -> String {
        "gcloud access-context-manager perimeters create \(perimeterName) --policy=\(policyID) --perimeter-file=\(filePath)"
    }

    /// Update a perimeter from YAML file
    public static func updatePerimeterFromFileCommand(perimeterName: String, policyID: String, filePath: String) -> String {
        "gcloud access-context-manager perimeters update \(perimeterName) --policy=\(policyID) --perimeter-file=\(filePath)"
    }
}

// MARK: - DAIS VPC-SC Template

/// VPC Service Controls templates for DAIS deployments
public struct DAISVPCServiceControlsTemplate {

    /// Create access policy for DAIS
    public static func accessPolicy(
        organizationID: String,
        deploymentName: String
    ) -> GoogleCloudAccessPolicy {
        GoogleCloudAccessPolicy(
            name: "\(deploymentName)-policy",
            organizationID: organizationID,
            title: "\(deploymentName) Access Policy"
        )
    }

    /// Create corporate network access level
    public static func corporateNetworkLevel(
        policyID: String,
        deploymentName: String,
        corporateCIDRs: [String]
    ) -> GoogleCloudAccessLevel {
        GoogleCloudAccessLevel(
            name: "\(deploymentName)-corporate-network",
            policyID: policyID,
            title: "Corporate Network Access",
            description: "Allow access from corporate network ranges",
            basic: GoogleCloudAccessLevel.BasicLevel(
                conditions: [
                    GoogleCloudAccessLevel.BasicLevel.Condition(
                        ipSubnetworks: corporateCIDRs
                    )
                ]
            )
        )
    }

    /// Create trusted service account access level
    public static func trustedServiceAccountLevel(
        policyID: String,
        deploymentName: String,
        serviceAccounts: [String]
    ) -> GoogleCloudAccessLevel {
        GoogleCloudAccessLevel(
            name: "\(deploymentName)-trusted-sas",
            policyID: policyID,
            title: "Trusted Service Accounts",
            description: "Allow access from trusted service accounts",
            basic: GoogleCloudAccessLevel.BasicLevel(
                conditions: [
                    GoogleCloudAccessLevel.BasicLevel.Condition(
                        members: serviceAccounts.map { "serviceAccount:\($0)" }
                    )
                ]
            )
        )
    }

    /// Create data protection perimeter
    public static func dataProtectionPerimeter(
        policyID: String,
        deploymentName: String,
        projectNumbers: [String],
        accessLevels: [String] = []
    ) -> GoogleCloudServicePerimeter {
        GoogleCloudServicePerimeter(
            name: "\(deploymentName)-data-protection",
            policyID: policyID,
            title: "\(deploymentName) Data Protection Perimeter",
            description: "Protects data services from exfiltration",
            perimeterType: .regular,
            resources: projectNumbers.map { "projects/\($0)" },
            restrictedServices: RestrictedServices.dataStorage,
            accessLevels: accessLevels,
            vpcAccessibleServices: GoogleCloudServicePerimeter.VPCAccessibleServices(
                enableRestriction: true,
                allowedServices: ["RESTRICTED-SERVICES"]
            )
        )
    }

    /// Create AI/ML protection perimeter
    public static func aiMLProtectionPerimeter(
        policyID: String,
        deploymentName: String,
        projectNumbers: [String],
        accessLevels: [String] = []
    ) -> GoogleCloudServicePerimeter {
        GoogleCloudServicePerimeter(
            name: "\(deploymentName)-aiml-protection",
            policyID: policyID,
            title: "\(deploymentName) AI/ML Protection Perimeter",
            description: "Protects AI/ML services and models",
            perimeterType: .regular,
            resources: projectNumbers.map { "projects/\($0)" },
            restrictedServices: RestrictedServices.aiML,
            accessLevels: accessLevels
        )
    }

    /// Create bridge perimeter for cross-project access
    public static func bridgePerimeter(
        policyID: String,
        deploymentName: String,
        projectNumbers: [String]
    ) -> GoogleCloudServicePerimeter {
        GoogleCloudServicePerimeter(
            name: "\(deploymentName)-bridge",
            policyID: policyID,
            title: "\(deploymentName) Bridge Perimeter",
            description: "Enables cross-project communication",
            perimeterType: .bridge,
            resources: projectNumbers.map { "projects/\($0)" },
            restrictedServices: []
        )
    }

    /// Create comprehensive protection perimeter
    public static func comprehensivePerimeter(
        policyID: String,
        deploymentName: String,
        projectNumbers: [String],
        accessLevels: [String] = [],
        allowBigQueryExport: Bool = false
    ) -> GoogleCloudServicePerimeter {
        var egressPolicies: [GoogleCloudServicePerimeter.EgressPolicy]? = nil

        if allowBigQueryExport {
            egressPolicies = [
                GoogleCloudServicePerimeter.EgressPolicy(
                    egressFrom: GoogleCloudServicePerimeter.EgressPolicy.EgressFrom(
                        identityType: .anyIdentity
                    ),
                    egressTo: GoogleCloudServicePerimeter.EgressPolicy.EgressTo(
                        operations: [
                            GoogleCloudServicePerimeter.ServiceOperation(
                                serviceName: "bigquery.googleapis.com",
                                methodSelectors: [
                                    GoogleCloudServicePerimeter.ServiceOperation.MethodSelector(
                                        method: "google.cloud.bigquery.v2.JobService.InsertJob"
                                    )
                                ]
                            )
                        ],
                        externalResources: ["projects/*"]
                    )
                )
            ]
        }

        return GoogleCloudServicePerimeter(
            name: "\(deploymentName)-comprehensive",
            policyID: policyID,
            title: "\(deploymentName) Comprehensive Protection",
            description: "Full protection for all sensitive services",
            perimeterType: .regular,
            resources: projectNumbers.map { "projects/\($0)" },
            restrictedServices: RestrictedServices.allCommon,
            accessLevels: accessLevels,
            vpcAccessibleServices: GoogleCloudServicePerimeter.VPCAccessibleServices(
                enableRestriction: true,
                allowedServices: ["RESTRICTED-SERVICES"]
            ),
            egressPolicies: egressPolicies
        )
    }

    /// Generate perimeter YAML configuration
    public static func perimeterYAML(
        name: String,
        title: String,
        resources: [String],
        restrictedServices: [String],
        accessLevels: [String] = []
    ) -> String {
        var yaml = """
        name: \(name)
        title: \(title)
        perimeterType: PERIMETER_TYPE_REGULAR
        status:
          resources:
        """

        for resource in resources {
            yaml += "\n    - \(resource)"
        }

        yaml += "\n  restrictedServices:"
        for service in restrictedServices {
            yaml += "\n    - \(service)"
        }

        if !accessLevels.isEmpty {
            yaml += "\n  accessLevels:"
            for level in accessLevels {
                yaml += "\n    - \(level)"
            }
        }

        return yaml
    }

    /// Generate setup script for VPC-SC
    public static func setupScript(
        organizationID: String,
        projectID: String,
        projectNumber: String,
        deploymentName: String,
        corporateCIDRs: [String]
    ) -> String {
        """
        #!/bin/bash
        set -e

        # VPC Service Controls Setup for \(deploymentName)
        # Organization: \(organizationID)
        # Project: \(projectID)

        echo "Enabling Access Context Manager API..."
        gcloud services enable accesscontextmanager.googleapis.com --project=\(projectID)

        echo "Creating access policy..."
        POLICY_ID=$(gcloud access-context-manager policies create \\
            --organization=\(organizationID) \\
            --title="\(deploymentName) Access Policy" \\
            --format="value(name)" 2>/dev/null | tail -1)

        echo "Policy created: $POLICY_ID"

        echo "Creating corporate network access level..."
        gcloud access-context-manager levels create \(deploymentName)-corp-network \\
            --policy=$POLICY_ID \\
            --title="Corporate Network" \\
            --basic-level-spec="ipSubnetworks: [\(corporateCIDRs.map { "\"\($0)\"" }.joined(separator: ", "))]"

        echo "Creating data protection perimeter..."
        gcloud access-context-manager perimeters create \(deploymentName)-data \\
            --policy=$POLICY_ID \\
            --title="Data Protection" \\
            --resources="projects/\(projectNumber)" \\
            --restricted-services="\(RestrictedServices.dataStorage.joined(separator: ","))" \\
            --access-levels="\(deploymentName)-corp-network"

        echo "VPC Service Controls setup complete!"
        echo "Policy ID: $POLICY_ID"
        echo "Perimeter: \(deploymentName)-data"
        """
    }

    /// Generate teardown script
    public static func teardownScript(
        policyID: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # VPC Service Controls Teardown for \(deploymentName)

        echo "Deleting service perimeters..."
        gcloud access-context-manager perimeters delete \(deploymentName)-data --policy=\(policyID) --quiet || true
        gcloud access-context-manager perimeters delete \(deploymentName)-comprehensive --policy=\(policyID) --quiet || true
        gcloud access-context-manager perimeters delete \(deploymentName)-bridge --policy=\(policyID) --quiet || true

        echo "Deleting access levels..."
        gcloud access-context-manager levels delete \(deploymentName)-corp-network --policy=\(policyID) --quiet || true
        gcloud access-context-manager levels delete \(deploymentName)-trusted-sas --policy=\(policyID) --quiet || true

        echo "Deleting access policy..."
        gcloud access-context-manager policies delete \(policyID) --quiet || true

        echo "Teardown complete!"
        """
    }
}
