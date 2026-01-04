// GoogleCloudArtifactRegistry.swift
// Artifact Registry API models for container and package management

import Foundation

// MARK: - Repository

/// Represents an Artifact Registry repository
public struct GoogleCloudArtifactRegistryRepository: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let format: RepositoryFormat
    public let description: String?
    public let labels: [String: String]
    public let kmsKeyName: String?
    public let mode: RepositoryMode
    public let cleanupPolicies: [CleanupPolicy]
    public let vulnerabilityScanningConfig: VulnerabilityScanningConfig?

    /// Repository format types
    public enum RepositoryFormat: String, Codable, Sendable, Equatable {
        case docker = "DOCKER"
        case maven = "MAVEN"
        case npm = "NPM"
        case python = "PYTHON"
        case apt = "APT"
        case yum = "YUM"
        case go = "GO"
        case kubeflow = "KFP"
        case generic = "GENERIC"
    }

    /// Repository mode
    public enum RepositoryMode: String, Codable, Sendable, Equatable {
        case standardRepository = "STANDARD_REPOSITORY"
        case virtualRepository = "VIRTUAL_REPOSITORY"
        case remoteRepository = "REMOTE_REPOSITORY"
    }

    /// Cleanup policy for automatic artifact deletion
    public struct CleanupPolicy: Codable, Sendable, Equatable {
        public let id: String
        public let action: Action
        public let condition: Condition?
        public let mostRecentVersions: MostRecentVersions?

        public enum Action: String, Codable, Sendable, Equatable {
            case delete = "DELETE"
            case keep = "KEEP"
        }

        public struct Condition: Codable, Sendable, Equatable {
            public let tagState: TagState?
            public let tagPrefixes: [String]?
            public let versionNamePrefixes: [String]?
            public let packageNamePrefixes: [String]?
            public let olderThan: String?
            public let newerThan: String?

            public enum TagState: String, Codable, Sendable, Equatable {
                case tagged = "TAGGED"
                case untagged = "UNTAGGED"
                case any = "ANY"
            }

            public init(
                tagState: TagState? = nil,
                tagPrefixes: [String]? = nil,
                versionNamePrefixes: [String]? = nil,
                packageNamePrefixes: [String]? = nil,
                olderThan: String? = nil,
                newerThan: String? = nil
            ) {
                self.tagState = tagState
                self.tagPrefixes = tagPrefixes
                self.versionNamePrefixes = versionNamePrefixes
                self.packageNamePrefixes = packageNamePrefixes
                self.olderThan = olderThan
                self.newerThan = newerThan
            }
        }

        public struct MostRecentVersions: Codable, Sendable, Equatable {
            public let packageNamePrefixes: [String]?
            public let keepCount: Int

            public init(packageNamePrefixes: [String]? = nil, keepCount: Int) {
                self.packageNamePrefixes = packageNamePrefixes
                self.keepCount = keepCount
            }
        }

        public init(
            id: String,
            action: Action,
            condition: Condition? = nil,
            mostRecentVersions: MostRecentVersions? = nil
        ) {
            self.id = id
            self.action = action
            self.condition = condition
            self.mostRecentVersions = mostRecentVersions
        }
    }

    /// Vulnerability scanning configuration
    public struct VulnerabilityScanningConfig: Codable, Sendable, Equatable {
        public let enablementConfig: EnablementConfig

        public enum EnablementConfig: String, Codable, Sendable, Equatable {
            case inherited = "INHERITED"
            case disabled = "DISABLED"
            case automatic = "AUTOMATIC"
        }

        public init(enablementConfig: EnablementConfig) {
            self.enablementConfig = enablementConfig
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        format: RepositoryFormat,
        description: String? = nil,
        labels: [String: String] = [:],
        kmsKeyName: String? = nil,
        mode: RepositoryMode = .standardRepository,
        cleanupPolicies: [CleanupPolicy] = [],
        vulnerabilityScanningConfig: VulnerabilityScanningConfig? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.format = format
        self.description = description
        self.labels = labels
        self.kmsKeyName = kmsKeyName
        self.mode = mode
        self.cleanupPolicies = cleanupPolicies
        self.vulnerabilityScanningConfig = vulnerabilityScanningConfig
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/repositories/\(name)"
    }

    /// Docker registry hostname
    public var dockerHost: String {
        "\(location)-docker.pkg.dev"
    }

    /// Full Docker image path prefix
    public var dockerImagePrefix: String {
        "\(dockerHost)/\(projectID)/\(name)"
    }

    /// Maven repository URL
    public var mavenRepositoryURL: String {
        "https://\(location)-maven.pkg.dev/\(projectID)/\(name)"
    }

    /// npm registry URL
    public var npmRegistryURL: String {
        "https://\(location)-npm.pkg.dev/\(projectID)/\(name)"
    }

    /// Python repository URL
    public var pythonRepositoryURL: String {
        "https://\(location)-python.pkg.dev/\(projectID)/\(name)"
    }

    /// gcloud command to create the repository
    public var createCommand: String {
        var cmd = "gcloud artifacts repositories create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --repository-format=\(format.rawValue.lowercased())"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        if let kmsKey = kmsKeyName {
            cmd += " --kms-key=\(kmsKey)"
        }

        if mode != .standardRepository {
            cmd += " --mode=\(mode.rawValue.lowercased().replacingOccurrences(of: "_", with: "-"))"
        }

        return cmd
    }

    /// gcloud command to delete the repository
    public var deleteCommand: String {
        "gcloud artifacts repositories delete \(name) --project=\(projectID) --location=\(location) --quiet"
    }

    /// gcloud command to describe the repository
    public var describeCommand: String {
        "gcloud artifacts repositories describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// gcloud command to update the repository
    public func updateCommand(description: String? = nil, labels: [String: String]? = nil) -> String {
        var cmd = "gcloud artifacts repositories update \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        if let lbls = labels, !lbls.isEmpty {
            let labelStr = lbls.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --update-labels=\(labelStr)"
        }

        return cmd
    }

    /// gcloud command to list repositories
    public static func listCommand(projectID: String, location: String? = nil) -> String {
        var cmd = "gcloud artifacts repositories list --project=\(projectID)"
        if let loc = location {
            cmd += " --location=\(loc)"
        }
        return cmd
    }

    /// gcloud command to set IAM policy
    public func addIAMBindingCommand(member: String, role: String) -> String {
        "gcloud artifacts repositories add-iam-policy-binding \(name) --project=\(projectID) --location=\(location) --member=\(member) --role=\(role)"
    }

    /// gcloud command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud artifacts repositories get-iam-policy \(name) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Docker Image

/// Represents a Docker image in Artifact Registry
public struct GoogleCloudDockerImage: Codable, Sendable, Equatable {
    public let name: String
    public let repositoryName: String
    public let projectID: String
    public let location: String
    public let tag: String?
    public let digest: String?

    public init(
        name: String,
        repositoryName: String,
        projectID: String,
        location: String,
        tag: String? = nil,
        digest: String? = nil
    ) {
        self.name = name
        self.repositoryName = repositoryName
        self.projectID = projectID
        self.location = location
        self.tag = tag
        self.digest = digest
    }

    /// Full image URL with tag
    public var imageURL: String {
        var url = "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name)"
        if let tag = tag {
            url += ":\(tag)"
        } else if let digest = digest {
            url += "@\(digest)"
        }
        return url
    }

    /// Full image URL with specific tag
    public func imageURL(tag: String) -> String {
        "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name):\(tag)"
    }

    /// Full image URL with digest
    public func imageURL(digest: String) -> String {
        "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name)@\(digest)"
    }

    /// gcloud command to list tags
    public var listTagsCommand: String {
        "gcloud artifacts docker tags list \(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name) --project=\(projectID)"
    }

    /// gcloud command to add a tag
    public func addTagCommand(sourceTag: String, newTag: String) -> String {
        let source = "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name):\(sourceTag)"
        let target = "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name):\(newTag)"
        return "gcloud artifacts docker tags add \(source) \(target) --project=\(projectID)"
    }

    /// gcloud command to delete a tag
    public func deleteTagCommand(tag: String) -> String {
        "gcloud artifacts docker tags delete \(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name):\(tag) --project=\(projectID) --quiet"
    }

    /// gcloud command to delete the image
    public var deleteCommand: String {
        var imageRef = "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name)"
        if let tag = tag {
            imageRef += ":\(tag)"
        } else if let digest = digest {
            imageRef += "@\(digest)"
        }
        return "gcloud artifacts docker images delete \(imageRef) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe the image
    public var describeCommand: String {
        var imageRef = "\(location)-docker.pkg.dev/\(projectID)/\(repositoryName)/\(name)"
        if let tag = tag {
            imageRef += ":\(tag)"
        } else if let digest = digest {
            imageRef += "@\(digest)"
        }
        return "gcloud artifacts docker images describe \(imageRef) --project=\(projectID)"
    }

    /// gcloud command to list images in repository
    public static func listCommand(projectID: String, location: String, repositoryName: String) -> String {
        "gcloud artifacts docker images list \(location)-docker.pkg.dev/\(projectID)/\(repositoryName) --project=\(projectID)"
    }

    /// Docker pull command
    public var dockerPullCommand: String {
        "docker pull \(imageURL)"
    }

    /// Docker push command
    public var dockerPushCommand: String {
        "docker push \(imageURL)"
    }

    /// Docker tag command (for retagging before push)
    public func dockerTagCommand(sourceImage: String) -> String {
        "docker tag \(sourceImage) \(imageURL)"
    }
}

// MARK: - Package

/// Represents a package in Artifact Registry (Maven, npm, Python, etc.)
public struct GoogleCloudPackage: Codable, Sendable, Equatable {
    public let name: String
    public let repositoryName: String
    public let projectID: String
    public let location: String
    public let format: GoogleCloudArtifactRegistryRepository.RepositoryFormat

    public init(
        name: String,
        repositoryName: String,
        projectID: String,
        location: String,
        format: GoogleCloudArtifactRegistryRepository.RepositoryFormat
    ) {
        self.name = name
        self.repositoryName = repositoryName
        self.projectID = projectID
        self.location = location
        self.format = format
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/repositories/\(repositoryName)/packages/\(name)"
    }

    /// gcloud command to list packages
    public static func listCommand(projectID: String, location: String, repositoryName: String) -> String {
        "gcloud artifacts packages list --project=\(projectID) --location=\(location) --repository=\(repositoryName)"
    }

    /// gcloud command to delete the package
    public var deleteCommand: String {
        "gcloud artifacts packages delete \(name) --project=\(projectID) --location=\(location) --repository=\(repositoryName) --quiet"
    }

    /// gcloud command to describe the package
    public var describeCommand: String {
        "gcloud artifacts packages describe \(name) --project=\(projectID) --location=\(location) --repository=\(repositoryName)"
    }
}

// MARK: - Package Version

/// Represents a package version in Artifact Registry
public struct GoogleCloudPackageVersion: Codable, Sendable, Equatable {
    public let version: String
    public let packageName: String
    public let repositoryName: String
    public let projectID: String
    public let location: String

    public init(
        version: String,
        packageName: String,
        repositoryName: String,
        projectID: String,
        location: String
    ) {
        self.version = version
        self.packageName = packageName
        self.repositoryName = repositoryName
        self.projectID = projectID
        self.location = location
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/repositories/\(repositoryName)/packages/\(packageName)/versions/\(version)"
    }

    /// gcloud command to list versions
    public static func listCommand(projectID: String, location: String, repositoryName: String, packageName: String) -> String {
        "gcloud artifacts versions list --project=\(projectID) --location=\(location) --repository=\(repositoryName) --package=\(packageName)"
    }

    /// gcloud command to delete the version
    public var deleteCommand: String {
        "gcloud artifacts versions delete \(version) --project=\(projectID) --location=\(location) --repository=\(repositoryName) --package=\(packageName) --quiet"
    }

    /// gcloud command to describe the version
    public var describeCommand: String {
        "gcloud artifacts versions describe \(version) --project=\(projectID) --location=\(location) --repository=\(repositoryName) --package=\(packageName)"
    }
}

// MARK: - Remote Repository Configuration

/// Configuration for remote repository upstream sources
public struct GoogleCloudRemoteRepositoryConfig: Codable, Sendable, Equatable {
    public let upstream: Upstream
    public let description: String?

    public enum Upstream: Codable, Sendable, Equatable {
        case dockerHub(publicRepository: Bool)
        case mavenCentral
        case npmRegistry
        case pypi
        case custom(uri: String)

        public var uri: String {
            switch self {
            case .dockerHub:
                return "https://registry-1.docker.io"
            case .mavenCentral:
                return "https://repo.maven.apache.org/maven2"
            case .npmRegistry:
                return "https://registry.npmjs.org"
            case .pypi:
                return "https://pypi.org"
            case .custom(let uri):
                return uri
            }
        }
    }

    public init(upstream: Upstream, description: String? = nil) {
        self.upstream = upstream
        self.description = description
    }
}

// MARK: - Virtual Repository Configuration

/// Configuration for virtual repository upstream sources
public struct GoogleCloudVirtualRepositoryConfig: Codable, Sendable, Equatable {
    public let upstreamPolicies: [UpstreamPolicy]

    public struct UpstreamPolicy: Codable, Sendable, Equatable {
        public let id: String
        public let repository: String
        public let priority: Int

        public init(id: String, repository: String, priority: Int) {
            self.id = id
            self.repository = repository
            self.priority = priority
        }
    }

    public init(upstreamPolicies: [UpstreamPolicy]) {
        self.upstreamPolicies = upstreamPolicies
    }
}

// MARK: - Artifact Registry Roles

/// Predefined IAM roles for Artifact Registry
public enum ArtifactRegistryRole: String, Codable, Sendable {
    case admin = "roles/artifactregistry.admin"
    case writer = "roles/artifactregistry.writer"
    case reader = "roles/artifactregistry.reader"
    case repoAdmin = "roles/artifactregistry.repoAdmin"
    case createOnPushWriter = "roles/artifactregistry.createOnPushWriter"
    case createOnPushRepoAdmin = "roles/artifactregistry.createOnPushRepoAdmin"
}

// MARK: - Docker Auth Configuration

/// Docker authentication configuration for Artifact Registry
public struct ArtifactRegistryDockerAuth: Codable, Sendable, Equatable {
    public let location: String

    public init(location: String) {
        self.location = location
    }

    /// Docker registry hostname
    public var host: String {
        "\(location)-docker.pkg.dev"
    }

    /// gcloud command to configure Docker authentication
    public var configureDockerCommand: String {
        "gcloud auth configure-docker \(host)"
    }

    /// gcloud command to print access token for Docker login
    public var printAccessTokenCommand: String {
        "gcloud auth print-access-token"
    }

    /// Docker login command using gcloud token
    public var dockerLoginCommand: String {
        "gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://\(host)"
    }

    /// Credential helper configuration for Docker
    public var credentialHelperConfig: String {
        """
        {
          "credHelpers": {
            "\(host)": "gcloud"
          }
        }
        """
    }
}

// MARK: - npm Configuration

/// npm configuration for Artifact Registry
public struct ArtifactRegistryNpmConfig: Codable, Sendable, Equatable {
    public let projectID: String
    public let location: String
    public let repositoryName: String
    public let scope: String?

    public init(projectID: String, location: String, repositoryName: String, scope: String? = nil) {
        self.projectID = projectID
        self.location = location
        self.repositoryName = repositoryName
        self.scope = scope
    }

    /// npm registry URL
    public var registryURL: String {
        "https://\(location)-npm.pkg.dev/\(projectID)/\(repositoryName)/"
    }

    /// gcloud command to print npm credentials
    public var printCredentialsCommand: String {
        var cmd = "gcloud artifacts print-settings npm"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --repository=\(repositoryName)"
        if let scope = scope {
            cmd += " --scope=\(scope)"
        }
        return cmd
    }

    /// .npmrc configuration content
    public var npmrcConfig: String {
        let scopePrefix = scope.map { "\($0):" } ?? ""
        return """
        \(scopePrefix)registry=\(registryURL)
        //\(location)-npm.pkg.dev/\(projectID)/\(repositoryName)/:always-auth=true
        """
    }
}

// MARK: - Maven Configuration

/// Maven configuration for Artifact Registry
public struct ArtifactRegistryMavenConfig: Codable, Sendable, Equatable {
    public let projectID: String
    public let location: String
    public let repositoryName: String

    public init(projectID: String, location: String, repositoryName: String) {
        self.projectID = projectID
        self.location = location
        self.repositoryName = repositoryName
    }

    /// Maven repository URL
    public var repositoryURL: String {
        "https://\(location)-maven.pkg.dev/\(projectID)/\(repositoryName)"
    }

    /// gcloud command to print Maven settings
    public var printSettingsCommand: String {
        "gcloud artifacts print-settings mvn --project=\(projectID) --location=\(location) --repository=\(repositoryName)"
    }

    /// pom.xml repository configuration
    public var pomRepositoryConfig: String {
        """
        <repository>
          <id>artifact-registry</id>
          <url>artifactregistry://\(location)-maven.pkg.dev/\(projectID)/\(repositoryName)</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
        """
    }

    /// pom.xml distribution management configuration
    public var pomDistributionConfig: String {
        """
        <distributionManagement>
          <repository>
            <id>artifact-registry</id>
            <url>artifactregistry://\(location)-maven.pkg.dev/\(projectID)/\(repositoryName)</url>
          </repository>
          <snapshotRepository>
            <id>artifact-registry</id>
            <url>artifactregistry://\(location)-maven.pkg.dev/\(projectID)/\(repositoryName)</url>
          </snapshotRepository>
        </distributionManagement>
        """
    }
}

// MARK: - Python Configuration

/// Python/pip configuration for Artifact Registry
public struct ArtifactRegistryPythonConfig: Codable, Sendable, Equatable {
    public let projectID: String
    public let location: String
    public let repositoryName: String

    public init(projectID: String, location: String, repositoryName: String) {
        self.projectID = projectID
        self.location = location
        self.repositoryName = repositoryName
    }

    /// Python repository URL
    public var repositoryURL: String {
        "https://\(location)-python.pkg.dev/\(projectID)/\(repositoryName)/simple/"
    }

    /// gcloud command to print pip settings
    public var printSettingsCommand: String {
        "gcloud artifacts print-settings python --project=\(projectID) --location=\(location) --repository=\(repositoryName)"
    }

    /// pip install command with index URL
    public func pipInstallCommand(package: String) -> String {
        "pip install --index-url \(repositoryURL) \(package)"
    }

    /// pip.conf configuration
    public var pipConfig: String {
        """
        [global]
        index-url = \(repositoryURL)
        """
    }

    /// twine upload command
    public func twineUploadCommand(distPath: String = "dist/*") -> String {
        "twine upload --repository-url \(repositoryURL.replacingOccurrences(of: "/simple/", with: "/")) \(distPath)"
    }
}

// MARK: - Vulnerability Scanning

/// Vulnerability scan result for an artifact
public struct GoogleCloudVulnerabilityScan: Codable, Sendable, Equatable {
    public let imageURL: String
    public let projectID: String

    public init(imageURL: String, projectID: String) {
        self.imageURL = imageURL
        self.projectID = projectID
    }

    /// gcloud command to scan the image
    public var scanCommand: String {
        "gcloud artifacts docker images scan \(imageURL) --project=\(projectID)"
    }

    /// gcloud command to list vulnerabilities
    public var listVulnerabilitiesCommand: String {
        "gcloud artifacts docker images list-vulnerabilities \(imageURL) --project=\(projectID)"
    }

    /// gcloud command to get scan status
    public static func getScanStatusCommand(operationID: String, location: String) -> String {
        "gcloud artifacts operations describe \(operationID) --location=\(location)"
    }
}

// MARK: - Operations

/// Artifact Registry operations commands
public enum ArtifactRegistryOperations {
    /// List all locations
    public static func listLocationsCommand(projectID: String) -> String {
        "gcloud artifacts locations list --project=\(projectID)"
    }

    /// List all repositories
    public static func listRepositoriesCommand(projectID: String, location: String? = nil) -> String {
        var cmd = "gcloud artifacts repositories list --project=\(projectID)"
        if let loc = location {
            cmd += " --location=\(loc)"
        }
        return cmd
    }

    /// Enable Artifact Registry API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable artifactregistry.googleapis.com --project=\(projectID)"
    }

    /// Set default repository
    public static func setDefaultRepoCommand(projectID: String, location: String, repositoryName: String) -> String {
        "gcloud config set artifacts/repository \(repositoryName) && gcloud config set artifacts/location \(location)"
    }
}

// MARK: - DAIS Artifact Registry Templates

/// Pre-configured Artifact Registry templates for DAIS deployments
public enum DAISArtifactRegistryTemplate {
    /// Create a Docker repository for DAIS images
    public static func dockerRepository(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudArtifactRegistryRepository {
        GoogleCloudArtifactRegistryRepository(
            name: "\(deploymentName)-docker",
            projectID: projectID,
            location: location,
            format: .docker,
            description: "Docker images for \(deploymentName)",
            labels: ["app": "dais", "deployment": deploymentName],
            cleanupPolicies: [
                .init(
                    id: "delete-untagged",
                    action: .delete,
                    condition: .init(tagState: .untagged, olderThan: "604800s") // 7 days
                ),
                .init(
                    id: "keep-recent",
                    action: .keep,
                    mostRecentVersions: .init(keepCount: 10)
                )
            ],
            vulnerabilityScanningConfig: .init(enablementConfig: .automatic)
        )
    }

    /// Create an npm repository for DAIS packages
    public static func npmRepository(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudArtifactRegistryRepository {
        GoogleCloudArtifactRegistryRepository(
            name: "\(deploymentName)-npm",
            projectID: projectID,
            location: location,
            format: .npm,
            description: "npm packages for \(deploymentName)",
            labels: ["app": "dais", "deployment": deploymentName]
        )
    }

    /// Create a Python repository for DAIS packages
    public static func pythonRepository(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudArtifactRegistryRepository {
        GoogleCloudArtifactRegistryRepository(
            name: "\(deploymentName)-python",
            projectID: projectID,
            location: location,
            format: .python,
            description: "Python packages for \(deploymentName)",
            labels: ["app": "dais", "deployment": deploymentName]
        )
    }

    /// Create a Docker image reference for DAIS services
    public static func dockerImage(
        projectID: String,
        location: String,
        deploymentName: String,
        imageName: String,
        tag: String = "latest"
    ) -> GoogleCloudDockerImage {
        GoogleCloudDockerImage(
            name: imageName,
            repositoryName: "\(deploymentName)-docker",
            projectID: projectID,
            location: location,
            tag: tag
        )
    }

    /// API service image
    public static func apiServiceImage(
        projectID: String,
        location: String,
        deploymentName: String,
        tag: String = "latest"
    ) -> GoogleCloudDockerImage {
        dockerImage(
            projectID: projectID,
            location: location,
            deploymentName: deploymentName,
            imageName: "api-service",
            tag: tag
        )
    }

    /// gRPC service image
    public static func grpcServiceImage(
        projectID: String,
        location: String,
        deploymentName: String,
        tag: String = "latest"
    ) -> GoogleCloudDockerImage {
        dockerImage(
            projectID: projectID,
            location: location,
            deploymentName: deploymentName,
            imageName: "grpc-service",
            tag: tag
        )
    }

    /// Worker service image
    public static func workerServiceImage(
        projectID: String,
        location: String,
        deploymentName: String,
        tag: String = "latest"
    ) -> GoogleCloudDockerImage {
        dockerImage(
            projectID: projectID,
            location: location,
            deploymentName: deploymentName,
            imageName: "worker",
            tag: tag
        )
    }

    /// Docker authentication configuration
    public static func dockerAuth(location: String) -> ArtifactRegistryDockerAuth {
        ArtifactRegistryDockerAuth(location: location)
    }

    /// Generate Dockerfile for Swift DAIS services
    public static func swiftDockerfile(
        baseImage: String = "swift:5.10-jammy",
        executableName: String,
        port: Int = 8080
    ) -> String {
        """
        # Build stage
        FROM \(baseImage) AS builder

        WORKDIR /app

        # Copy package files first for better caching
        COPY Package.swift Package.resolved ./
        RUN swift package resolve

        # Copy source and build
        COPY Sources ./Sources
        RUN swift build -c release --static-swift-stdlib

        # Runtime stage
        FROM ubuntu:22.04

        RUN apt-get update && apt-get install -y \\
            ca-certificates \\
            libcurl4 \\
            && rm -rf /var/lib/apt/lists/*

        WORKDIR /app

        COPY --from=builder /app/.build/release/\(executableName) ./

        EXPOSE \(port)

        ENTRYPOINT ["./\(executableName)"]
        """
    }

    /// Generate Cloud Build configuration for CI/CD
    public static func cloudbuildConfig(
        projectID: String,
        location: String,
        deploymentName: String,
        serviceName: String,
        cloudRunRegion: String
    ) -> String {
        let imageURL = "\(location)-docker.pkg.dev/\(projectID)/\(deploymentName)-docker/\(serviceName)"

        return """
        steps:
          # Build the container image
          - name: 'gcr.io/cloud-builders/docker'
            args: ['build', '-t', '\(imageURL):$COMMIT_SHA', '-t', '\(imageURL):latest', '.']

          # Push the container image to Artifact Registry
          - name: 'gcr.io/cloud-builders/docker'
            args: ['push', '--all-tags', '\(imageURL)']

          # Deploy to Cloud Run
          - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
            entrypoint: gcloud
            args:
              - 'run'
              - 'deploy'
              - '\(serviceName)'
              - '--image=\(imageURL):$COMMIT_SHA'
              - '--region=\(cloudRunRegion)'
              - '--platform=managed'

        images:
          - '\(imageURL):$COMMIT_SHA'
          - '\(imageURL):latest'

        options:
          logging: CLOUD_LOGGING_ONLY
        """
    }

    /// Generate complete setup script
    public static func setupScript(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> String {
        let dockerRepo = dockerRepository(projectID: projectID, location: location, deploymentName: deploymentName)
        let auth = dockerAuth(location: location)

        return """
        #!/bin/bash
        set -e

        # DAIS Artifact Registry Setup Script
        # Project: \(projectID)
        # Deployment: \(deploymentName)
        # Location: \(location)

        echo "Enabling Artifact Registry API..."
        \(ArtifactRegistryOperations.enableAPICommand(projectID: projectID))

        echo "Creating Docker repository..."
        \(dockerRepo.createCommand) || echo "Repository may already exist"

        echo "Configuring Docker authentication..."
        \(auth.configureDockerCommand)

        echo "Granting Cloud Build access to Artifact Registry..."
        PROJECT_NUMBER=$(gcloud projects describe \(projectID) --format='value(projectNumber)')
        gcloud artifacts repositories add-iam-policy-binding \(deploymentName)-docker \\
            --project=\(projectID) \\
            --location=\(location) \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/artifactregistry.writer"

        echo "Granting Cloud Run access to pull images..."
        gcloud artifacts repositories add-iam-policy-binding \(deploymentName)-docker \\
            --project=\(projectID) \\
            --location=\(location) \\
            --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \\
            --role="roles/artifactregistry.reader"

        echo ""
        echo "Artifact Registry Setup Complete!"
        echo ""
        echo "Docker repository: \(dockerRepo.dockerImagePrefix)"
        echo ""
        echo "To push an image:"
        echo "  docker tag my-image \(dockerRepo.dockerImagePrefix)/my-image:latest"
        echo "  docker push \(dockerRepo.dockerImagePrefix)/my-image:latest"
        """
    }

    /// Generate teardown script
    public static func teardownScript(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # DAIS Artifact Registry Teardown Script
        # WARNING: This will delete all images in the repository!

        echo "Deleting Docker repository..."
        gcloud artifacts repositories delete \(deploymentName)-docker \\
            --project=\(projectID) \\
            --location=\(location) \\
            --quiet || echo "Repository may not exist"

        echo "Artifact Registry teardown complete!"
        """
    }

    /// CI/CD setup script with Cloud Build trigger
    public static func cicdSetupScript(
        projectID: String,
        location: String,
        deploymentName: String,
        repoOwner: String,
        repoName: String,
        branchPattern: String = "^main$"
    ) -> String {
        """
        #!/bin/bash
        set -e

        # DAIS CI/CD Setup Script
        # Sets up Cloud Build triggers for automatic deployment

        echo "Enabling Cloud Build API..."
        gcloud services enable cloudbuild.googleapis.com --project=\(projectID)

        echo "Connecting GitHub repository..."
        echo "Please complete the OAuth flow in the Cloud Console:"
        echo "https://console.cloud.google.com/cloud-build/triggers/connect?project=\(projectID)"
        echo ""
        read -p "Press enter after connecting your repository..."

        echo "Creating Cloud Build trigger..."
        gcloud builds triggers create github \\
            --project=\(projectID) \\
            --repo-owner=\(repoOwner) \\
            --repo-name=\(repoName) \\
            --branch-pattern="\(branchPattern)" \\
            --build-config=cloudbuild.yaml \\
            --name="\(deploymentName)-deploy"

        echo ""
        echo "CI/CD Setup Complete!"
        echo "Commits to \(branchPattern) will automatically build and deploy."
        """
    }
}
