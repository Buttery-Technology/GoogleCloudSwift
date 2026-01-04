// GoogleCloudBuild.swift
// Cloud Build API models for CI/CD pipelines

import Foundation

// MARK: - Build

/// Represents a Cloud Build build
public struct GoogleCloudBuild: Codable, Sendable, Equatable {
    public let id: String?
    public let projectID: String
    public let steps: [BuildStep]
    public let source: BuildSource?
    public let images: [String]
    public let artifacts: Artifacts?
    public let timeout: String
    public let queueTtl: String?
    public let logsBucket: String?
    public let options: BuildOptions?
    public let substitutions: [String: String]
    public let tags: [String]
    public let serviceAccount: String?
    public let availableSecrets: AvailableSecrets?

    /// A single build step
    public struct BuildStep: Codable, Sendable, Equatable {
        public let name: String
        public let args: [String]
        public let env: [String]
        public let dir: String?
        public let id: String?
        public let waitFor: [String]
        public let entrypoint: String?
        public let secretEnv: [String]
        public let volumes: [Volume]
        public let timeout: String?
        public let script: String?

        public struct Volume: Codable, Sendable, Equatable {
            public let name: String
            public let path: String

            public init(name: String, path: String) {
                self.name = name
                self.path = path
            }
        }

        public init(
            name: String,
            args: [String] = [],
            env: [String] = [],
            dir: String? = nil,
            id: String? = nil,
            waitFor: [String] = [],
            entrypoint: String? = nil,
            secretEnv: [String] = [],
            volumes: [Volume] = [],
            timeout: String? = nil,
            script: String? = nil
        ) {
            self.name = name
            self.args = args
            self.env = env
            self.dir = dir
            self.id = id
            self.waitFor = waitFor
            self.entrypoint = entrypoint
            self.secretEnv = secretEnv
            self.volumes = volumes
            self.timeout = timeout
            self.script = script
        }
    }

    /// Build source configuration
    public enum BuildSource: Codable, Sendable, Equatable {
        case storageSource(bucket: String, object: String, generation: Int64?)
        case repoSource(repoName: String, branchName: String?, tagName: String?, commitSha: String?, dir: String?)
        case gitSource(url: String, revision: String?, dir: String?)
        case connectedRepository(repository: String, revision: String?, dir: String?)
    }

    /// Build artifacts configuration
    public struct Artifacts: Codable, Sendable, Equatable {
        public let images: [String]
        public let objects: Objects?
        public let mavenArtifacts: [MavenArtifact]
        public let pythonPackages: [PythonPackage]
        public let npmPackages: [NpmPackage]

        public struct Objects: Codable, Sendable, Equatable {
            public let location: String
            public let paths: [String]

            public init(location: String, paths: [String]) {
                self.location = location
                self.paths = paths
            }
        }

        public struct MavenArtifact: Codable, Sendable, Equatable {
            public let repository: String
            public let path: String
            public let artifactId: String?
            public let groupId: String?
            public let version: String?

            public init(
                repository: String,
                path: String,
                artifactId: String? = nil,
                groupId: String? = nil,
                version: String? = nil
            ) {
                self.repository = repository
                self.path = path
                self.artifactId = artifactId
                self.groupId = groupId
                self.version = version
            }
        }

        public struct PythonPackage: Codable, Sendable, Equatable {
            public let repository: String
            public let paths: [String]

            public init(repository: String, paths: [String]) {
                self.repository = repository
                self.paths = paths
            }
        }

        public struct NpmPackage: Codable, Sendable, Equatable {
            public let repository: String
            public let packagePath: String

            public init(repository: String, packagePath: String) {
                self.repository = repository
                self.packagePath = packagePath
            }
        }

        public init(
            images: [String] = [],
            objects: Objects? = nil,
            mavenArtifacts: [MavenArtifact] = [],
            pythonPackages: [PythonPackage] = [],
            npmPackages: [NpmPackage] = []
        ) {
            self.images = images
            self.objects = objects
            self.mavenArtifacts = mavenArtifacts
            self.pythonPackages = pythonPackages
            self.npmPackages = npmPackages
        }
    }

    /// Build options
    public struct BuildOptions: Codable, Sendable, Equatable {
        public let machineType: MachineType?
        public let diskSizeGb: Int64?
        public let substitutionOption: SubstitutionOption?
        public let dynamicSubstitutions: Bool?
        public let logStreamingOption: LogStreamingOption?
        public let logging: Logging?
        public let env: [String]
        public let secretEnv: [String]
        public let volumes: [BuildStep.Volume]
        public let pool: PoolOption?
        public let requestedVerifyOption: RequestedVerifyOption?

        public enum MachineType: String, Codable, Sendable, Equatable {
            case unspecified = "UNSPECIFIED"
            case n1Highcpu8 = "N1_HIGHCPU_8"
            case n1Highcpu32 = "N1_HIGHCPU_32"
            case e2Highcpu8 = "E2_HIGHCPU_8"
            case e2Highcpu32 = "E2_HIGHCPU_32"
            case e2Medium = "E2_MEDIUM"
        }

        public enum SubstitutionOption: String, Codable, Sendable, Equatable {
            case mustMatch = "MUST_MATCH"
            case allowLoose = "ALLOW_LOOSE"
        }

        public enum LogStreamingOption: String, Codable, Sendable, Equatable {
            case streamDefault = "STREAM_DEFAULT"
            case streamOn = "STREAM_ON"
            case streamOff = "STREAM_OFF"
        }

        public enum Logging: String, Codable, Sendable, Equatable {
            case loggingUnspecified = "LOGGING_UNSPECIFIED"
            case legacy = "LEGACY"
            case gcpDefaultLogsBucket = "GCS_ONLY"
            case cloudLoggingOnly = "CLOUD_LOGGING_ONLY"
            case none = "NONE"
        }

        public struct PoolOption: Codable, Sendable, Equatable {
            public let name: String

            public init(name: String) {
                self.name = name
            }
        }

        public enum RequestedVerifyOption: String, Codable, Sendable, Equatable {
            case notVerified = "NOT_VERIFIED"
            case verified = "VERIFIED"
        }

        public init(
            machineType: MachineType? = nil,
            diskSizeGb: Int64? = nil,
            substitutionOption: SubstitutionOption? = nil,
            dynamicSubstitutions: Bool? = nil,
            logStreamingOption: LogStreamingOption? = nil,
            logging: Logging? = nil,
            env: [String] = [],
            secretEnv: [String] = [],
            volumes: [BuildStep.Volume] = [],
            pool: PoolOption? = nil,
            requestedVerifyOption: RequestedVerifyOption? = nil
        ) {
            self.machineType = machineType
            self.diskSizeGb = diskSizeGb
            self.substitutionOption = substitutionOption
            self.dynamicSubstitutions = dynamicSubstitutions
            self.logStreamingOption = logStreamingOption
            self.logging = logging
            self.env = env
            self.secretEnv = secretEnv
            self.volumes = volumes
            self.pool = pool
            self.requestedVerifyOption = requestedVerifyOption
        }
    }

    /// Available secrets configuration
    public struct AvailableSecrets: Codable, Sendable, Equatable {
        public let secretManager: [SecretManagerSecret]
        public let inline: [InlineSecret]

        public struct SecretManagerSecret: Codable, Sendable, Equatable {
            public let versionName: String
            public let env: String

            public init(versionName: String, env: String) {
                self.versionName = versionName
                self.env = env
            }
        }

        public struct InlineSecret: Codable, Sendable, Equatable {
            public let kmsKeyName: String
            public let envMap: [String: String]

            public init(kmsKeyName: String, envMap: [String: String]) {
                self.kmsKeyName = kmsKeyName
                self.envMap = envMap
            }
        }

        public init(
            secretManager: [SecretManagerSecret] = [],
            inline: [InlineSecret] = []
        ) {
            self.secretManager = secretManager
            self.inline = inline
        }
    }

    public init(
        id: String? = nil,
        projectID: String,
        steps: [BuildStep],
        source: BuildSource? = nil,
        images: [String] = [],
        artifacts: Artifacts? = nil,
        timeout: String = "600s",
        queueTtl: String? = nil,
        logsBucket: String? = nil,
        options: BuildOptions? = nil,
        substitutions: [String: String] = [:],
        tags: [String] = [],
        serviceAccount: String? = nil,
        availableSecrets: AvailableSecrets? = nil
    ) {
        self.id = id
        self.projectID = projectID
        self.steps = steps
        self.source = source
        self.images = images
        self.artifacts = artifacts
        self.timeout = timeout
        self.queueTtl = queueTtl
        self.logsBucket = logsBucket
        self.options = options
        self.substitutions = substitutions
        self.tags = tags
        self.serviceAccount = serviceAccount
        self.availableSecrets = availableSecrets
    }

    /// gcloud command to submit the build
    public var submitCommand: String {
        "gcloud builds submit --project=\(projectID)"
    }

    /// gcloud command to describe a build
    public func describeCommand(buildID: String, region: String? = nil) -> String {
        var cmd = "gcloud builds describe \(buildID) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to list builds
    public static func listCommand(projectID: String, region: String? = nil, ongoing: Bool = false) -> String {
        var cmd = "gcloud builds list --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        if ongoing {
            cmd += " --ongoing"
        }
        return cmd
    }

    /// gcloud command to cancel a build
    public static func cancelCommand(buildID: String, projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud builds cancel \(buildID) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to stream logs
    public static func logCommand(buildID: String, projectID: String, region: String? = nil, stream: Bool = false) -> String {
        var cmd = "gcloud builds log \(buildID) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        if stream {
            cmd += " --stream"
        }
        return cmd
    }
}

// MARK: - Build Trigger

/// Represents a Cloud Build trigger
public struct GoogleCloudBuildTrigger: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let tags: [String]
    public let disabled: Bool
    public let triggerSource: TriggerSource
    public let buildConfig: BuildConfig
    public let substitutions: [String: String]
    public let ignoredFiles: [String]
    public let includedFiles: [String]
    public let filter: String?
    public let serviceAccount: String?
    public let approvalRequired: Bool
    public let region: String?

    /// Trigger source configuration
    public enum TriggerSource: Codable, Sendable, Equatable {
        case github(owner: String, name: String, eventConfig: GitHubEventConfig)
        case cloudSourceRepository(repoName: String, eventConfig: RepoEventConfig)
        case pubsub(topic: String, serviceAccountEmail: String?)
        case webhook(secretName: String)
        case manual

        public enum GitHubEventConfig: Codable, Sendable, Equatable {
            case push(branch: String?, tag: String?, invertRegex: Bool)
            case pullRequest(branch: String, commentControl: CommentControl?, invertRegex: Bool)

            public enum CommentControl: String, Codable, Sendable, Equatable {
                case commentsDisabled = "COMMENTS_DISABLED"
                case commentsEnabled = "COMMENTS_ENABLED"
                case commentsEnabledForExternalContributorsOnly = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
            }
        }

        public enum RepoEventConfig: Codable, Sendable, Equatable {
            case push(branch: String?, tag: String?, invertRegex: Bool)
        }
    }

    /// Build configuration
    public enum BuildConfig: Codable, Sendable, Equatable {
        case filename(String)
        case inlineConfig(GoogleCloudBuild)
        case autodetect
    }

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        tags: [String] = [],
        disabled: Bool = false,
        triggerSource: TriggerSource,
        buildConfig: BuildConfig,
        substitutions: [String: String] = [:],
        ignoredFiles: [String] = [],
        includedFiles: [String] = [],
        filter: String? = nil,
        serviceAccount: String? = nil,
        approvalRequired: Bool = false,
        region: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.tags = tags
        self.disabled = disabled
        self.triggerSource = triggerSource
        self.buildConfig = buildConfig
        self.substitutions = substitutions
        self.ignoredFiles = ignoredFiles
        self.includedFiles = includedFiles
        self.filter = filter
        self.serviceAccount = serviceAccount
        self.approvalRequired = approvalRequired
        self.region = region
    }

    /// Full resource name
    public var resourceName: String {
        if let region = region {
            return "projects/\(projectID)/locations/\(region)/triggers/\(name)"
        }
        return "projects/\(projectID)/triggers/\(name)"
    }

    /// gcloud command to create the trigger (GitHub)
    public var createCommandGitHub: String? {
        guard case .github(let owner, let repoName, let eventConfig) = triggerSource else {
            return nil
        }

        var cmd = "gcloud builds triggers create github"
        cmd += " --name=\(name)"
        cmd += " --project=\(projectID)"
        cmd += " --repo-owner=\(owner)"
        cmd += " --repo-name=\(repoName)"

        if let region = region {
            cmd += " --region=\(region)"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        switch eventConfig {
        case .push(let branch, let tag, let invertRegex):
            if let branch = branch {
                cmd += " --branch-pattern=\"\(branch)\""
            }
            if let tag = tag {
                cmd += " --tag-pattern=\"\(tag)\""
            }
            if invertRegex {
                cmd += " --invert-regex"
            }
        case .pullRequest(let branch, let commentControl, let invertRegex):
            cmd += " --pull-request-pattern=\"\(branch)\""
            if let control = commentControl {
                cmd += " --comment-control=\(control.rawValue)"
            }
            if invertRegex {
                cmd += " --invert-regex"
            }
        }

        switch buildConfig {
        case .filename(let file):
            cmd += " --build-config=\(file)"
        case .autodetect:
            break
        case .inlineConfig:
            break
        }

        if !substitutions.isEmpty {
            let subsStr = substitutions.map { "_\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --substitutions=\(subsStr)"
        }

        if !includedFiles.isEmpty {
            cmd += " --included-files=\(includedFiles.joined(separator: ","))"
        }

        if !ignoredFiles.isEmpty {
            cmd += " --ignored-files=\(ignoredFiles.joined(separator: ","))"
        }

        if let sa = serviceAccount {
            cmd += " --service-account=\(sa)"
        }

        if approvalRequired {
            cmd += " --require-approval"
        }

        return cmd
    }

    /// gcloud command to create a Cloud Source Repository trigger
    public var createCommandCSR: String? {
        guard case .cloudSourceRepository(let repoName, let eventConfig) = triggerSource else {
            return nil
        }

        var cmd = "gcloud builds triggers create cloud-source-repositories"
        cmd += " --name=\(name)"
        cmd += " --project=\(projectID)"
        cmd += " --repo=\(repoName)"

        if let region = region {
            cmd += " --region=\(region)"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        switch eventConfig {
        case .push(let branch, let tag, let invertRegex):
            if let branch = branch {
                cmd += " --branch-pattern=\"\(branch)\""
            }
            if let tag = tag {
                cmd += " --tag-pattern=\"\(tag)\""
            }
            if invertRegex {
                cmd += " --invert-regex"
            }
        }

        switch buildConfig {
        case .filename(let file):
            cmd += " --build-config=\(file)"
        case .autodetect:
            break
        case .inlineConfig:
            break
        }

        return cmd
    }

    /// gcloud command to create a Pub/Sub trigger
    public var createCommandPubSub: String? {
        guard case .pubsub(let topic, let serviceAccountEmail) = triggerSource else {
            return nil
        }

        var cmd = "gcloud builds triggers create pubsub"
        cmd += " --name=\(name)"
        cmd += " --project=\(projectID)"
        cmd += " --topic=\(topic)"

        if let region = region {
            cmd += " --region=\(region)"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        if let sa = serviceAccountEmail {
            cmd += " --service-account=\(sa)"
        }

        switch buildConfig {
        case .filename(let file):
            cmd += " --build-config=\(file)"
        case .autodetect:
            break
        case .inlineConfig:
            break
        }

        return cmd
    }

    /// gcloud command to create a webhook trigger
    public var createCommandWebhook: String? {
        guard case .webhook(let secretName) = triggerSource else {
            return nil
        }

        var cmd = "gcloud builds triggers create webhook"
        cmd += " --name=\(name)"
        cmd += " --project=\(projectID)"
        cmd += " --secret=\(secretName)"

        if let region = region {
            cmd += " --region=\(region)"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        switch buildConfig {
        case .filename(let file):
            cmd += " --build-config=\(file)"
        case .autodetect:
            break
        case .inlineConfig:
            break
        }

        return cmd
    }

    /// gcloud command to create a manual trigger
    public var createCommandManual: String? {
        guard case .manual = triggerSource else {
            return nil
        }

        var cmd = "gcloud builds triggers create manual"
        cmd += " --name=\(name)"
        cmd += " --project=\(projectID)"

        if let region = region {
            cmd += " --region=\(region)"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        switch buildConfig {
        case .filename(let file):
            cmd += " --build-config=\(file)"
        case .autodetect:
            break
        case .inlineConfig:
            break
        }

        return cmd
    }

    /// gcloud command to delete the trigger
    public var deleteCommand: String {
        var cmd = "gcloud builds triggers delete \(name) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe the trigger
    public var describeCommand: String {
        var cmd = "gcloud builds triggers describe \(name) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to run the trigger manually
    public func runCommand(branchName: String? = nil, tagName: String? = nil, sha: String? = nil) -> String {
        var cmd = "gcloud builds triggers run \(name) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        if let branch = branchName {
            cmd += " --branch=\(branch)"
        }
        if let tag = tagName {
            cmd += " --tag=\(tag)"
        }
        if let sha = sha {
            cmd += " --sha=\(sha)"
        }
        return cmd
    }

    /// gcloud command to list triggers
    public static func listCommand(projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud builds triggers list --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }
}

// MARK: - Worker Pool

/// Represents a Cloud Build private worker pool
public struct GoogleCloudBuildWorkerPool: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let displayName: String?
    public let privatePoolConfig: PrivatePoolConfig

    /// Private pool configuration
    public struct PrivatePoolConfig: Codable, Sendable, Equatable {
        public let workerConfig: WorkerConfig
        public let networkConfig: NetworkConfig?

        public struct WorkerConfig: Codable, Sendable, Equatable {
            public let machineType: String
            public let diskSizeGb: Int64

            public init(machineType: String = "e2-standard-4", diskSizeGb: Int64 = 100) {
                self.machineType = machineType
                self.diskSizeGb = diskSizeGb
            }
        }

        public struct NetworkConfig: Codable, Sendable, Equatable {
            public let peeredNetwork: String
            public let peeredNetworkIPRange: String?
            public let egressOption: EgressOption?

            public enum EgressOption: String, Codable, Sendable, Equatable {
                case noPublicEgress = "NO_PUBLIC_EGRESS"
                case publicEgress = "PUBLIC_EGRESS"
            }

            public init(
                peeredNetwork: String,
                peeredNetworkIPRange: String? = nil,
                egressOption: EgressOption? = nil
            ) {
                self.peeredNetwork = peeredNetwork
                self.peeredNetworkIPRange = peeredNetworkIPRange
                self.egressOption = egressOption
            }
        }

        public init(
            workerConfig: WorkerConfig,
            networkConfig: NetworkConfig? = nil
        ) {
            self.workerConfig = workerConfig
            self.networkConfig = networkConfig
        }
    }

    public init(
        name: String,
        projectID: String,
        region: String,
        displayName: String? = nil,
        privatePoolConfig: PrivatePoolConfig
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.displayName = displayName
        self.privatePoolConfig = privatePoolConfig
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/workerPools/\(name)"
    }

    /// gcloud command to create the worker pool
    public var createCommand: String {
        var cmd = "gcloud builds worker-pools create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"

        let config = privatePoolConfig.workerConfig
        cmd += " --worker-machine-type=\(config.machineType)"
        cmd += " --worker-disk-size=\(config.diskSizeGb)GB"

        if let network = privatePoolConfig.networkConfig {
            cmd += " --peered-network=\(network.peeredNetwork)"
            if let range = network.peeredNetworkIPRange {
                cmd += " --peered-network-ip-range=\(range)"
            }
            if let egress = network.egressOption {
                cmd += " --no-public-egress=\(egress == .noPublicEgress)"
            }
        }

        return cmd
    }

    /// gcloud command to delete the worker pool
    public var deleteCommand: String {
        "gcloud builds worker-pools delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe the worker pool
    public var describeCommand: String {
        "gcloud builds worker-pools describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to update the worker pool
    public func updateCommand(machineType: String? = nil, diskSizeGb: Int64? = nil) -> String {
        var cmd = "gcloud builds worker-pools update \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"

        if let mt = machineType {
            cmd += " --worker-machine-type=\(mt)"
        }
        if let ds = diskSizeGb {
            cmd += " --worker-disk-size=\(ds)GB"
        }

        return cmd
    }

    /// gcloud command to list worker pools
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud builds worker-pools list --project=\(projectID) --region=\(region)"
    }
}

// MARK: - GitHub Connection

/// Represents a Cloud Build GitHub connection (2nd gen)
public struct GoogleCloudBuildConnection: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let connectionType: ConnectionType

    public enum ConnectionType: Codable, Sendable, Equatable {
        case github(appInstallationId: Int64?)
        case githubEnterprise(hostUri: String, appInstallationId: Int64?)
        case gitlab(hostUri: String?, authorizerCredential: String?, readAuthorizerCredential: String?)
        case bitbucketDataCenter(hostUri: String, authorizerCredential: String?, readAuthorizerCredential: String?)
        case bitbucketCloud(workspace: String, authorizerCredential: String?, readAuthorizerCredential: String?)
    }

    public init(
        name: String,
        projectID: String,
        region: String,
        connectionType: ConnectionType
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.connectionType = connectionType
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/connections/\(name)"
    }

    /// gcloud command to create a GitHub connection
    public var createCommand: String? {
        switch connectionType {
        case .github:
            var cmd = "gcloud builds connections create github \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --region=\(region)"
            return cmd
        case .githubEnterprise(let hostUri, _):
            var cmd = "gcloud builds connections create github-enterprise \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --region=\(region)"
            cmd += " --host-uri=\(hostUri)"
            return cmd
        case .gitlab(let hostUri, _, _):
            var cmd = "gcloud builds connections create gitlab \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --region=\(region)"
            if let uri = hostUri {
                cmd += " --host-uri=\(uri)"
            }
            return cmd
        case .bitbucketDataCenter(let hostUri, _, _):
            var cmd = "gcloud builds connections create bitbucket-data-center \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --region=\(region)"
            cmd += " --host-uri=\(hostUri)"
            return cmd
        case .bitbucketCloud(let workspace, _, _):
            var cmd = "gcloud builds connections create bitbucket-cloud \(name)"
            cmd += " --project=\(projectID)"
            cmd += " --region=\(region)"
            cmd += " --workspace=\(workspace)"
            return cmd
        }
    }

    /// gcloud command to delete the connection
    public var deleteCommand: String {
        "gcloud builds connections delete \(name) --project=\(projectID) --region=\(region) --quiet"
    }

    /// gcloud command to describe the connection
    public var describeCommand: String {
        "gcloud builds connections describe \(name) --project=\(projectID) --region=\(region)"
    }

    /// gcloud command to list connections
    public static func listCommand(projectID: String, region: String) -> String {
        "gcloud builds connections list --project=\(projectID) --region=\(region)"
    }
}

// MARK: - Repository (2nd gen)

/// Represents a Cloud Build repository (2nd gen, linked to a connection)
public struct GoogleCloudBuildRepository: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let region: String
    public let connectionName: String
    public let remoteUri: String

    public init(
        name: String,
        projectID: String,
        region: String,
        connectionName: String,
        remoteUri: String
    ) {
        self.name = name
        self.projectID = projectID
        self.region = region
        self.connectionName = connectionName
        self.remoteUri = remoteUri
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(region)/connections/\(connectionName)/repositories/\(name)"
    }

    /// gcloud command to create the repository link
    public var createCommand: String {
        var cmd = "gcloud builds repositories create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --region=\(region)"
        cmd += " --connection=\(connectionName)"
        cmd += " --remote-uri=\(remoteUri)"
        return cmd
    }

    /// gcloud command to delete the repository link
    public var deleteCommand: String {
        "gcloud builds repositories delete \(name) --project=\(projectID) --region=\(region) --connection=\(connectionName) --quiet"
    }

    /// gcloud command to describe the repository
    public var describeCommand: String {
        "gcloud builds repositories describe \(name) --project=\(projectID) --region=\(region) --connection=\(connectionName)"
    }

    /// gcloud command to list repositories
    public static func listCommand(projectID: String, region: String, connectionName: String) -> String {
        "gcloud builds repositories list --project=\(projectID) --region=\(region) --connection=\(connectionName)"
    }
}

// MARK: - Cloud Build Operations

/// Cloud Build operations and utility commands
public enum CloudBuildOperations {
    /// Enable Cloud Build API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable cloudbuild.googleapis.com --project=\(projectID)"
    }

    /// Submit a build from local source
    public static func submitCommand(
        projectID: String,
        configFile: String? = nil,
        tag: String? = nil,
        substitutions: [String: String] = [:],
        timeout: String? = nil,
        machineType: GoogleCloudBuild.BuildOptions.MachineType? = nil,
        region: String? = nil,
        workerPool: String? = nil,
        gcsLogDir: String? = nil,
        gcsSourceStagingDir: String? = nil,
        ignoreFile: String? = nil,
        noCache: Bool = false,
        async: Bool = false
    ) -> String {
        var cmd = "gcloud builds submit --project=\(projectID)"

        if let config = configFile {
            cmd += " --config=\(config)"
        }

        if let t = tag {
            cmd += " --tag=\(t)"
        }

        if !substitutions.isEmpty {
            let subsStr = substitutions.map { "_\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --substitutions=\(subsStr)"
        }

        if let timeout = timeout {
            cmd += " --timeout=\(timeout)"
        }

        if let mt = machineType {
            cmd += " --machine-type=\(mt.rawValue)"
        }

        if let region = region {
            cmd += " --region=\(region)"
        }

        if let pool = workerPool {
            cmd += " --worker-pool=\(pool)"
        }

        if let logDir = gcsLogDir {
            cmd += " --gcs-log-dir=\(logDir)"
        }

        if let stagingDir = gcsSourceStagingDir {
            cmd += " --gcs-source-staging-dir=\(stagingDir)"
        }

        if let ignoreFile = ignoreFile {
            cmd += " --ignore-file=\(ignoreFile)"
        }

        if noCache {
            cmd += " --no-cache"
        }

        if async {
            cmd += " --async"
        }

        return cmd
    }

    /// Get the Cloud Build service account
    public static func getServiceAccountCommand(projectID: String) -> String {
        "gcloud projects describe \(projectID) --format='value(projectNumber)'@cloudbuild.gserviceaccount.com"
    }

    /// Grant Cloud Build access to deploy to Cloud Run
    public static func grantCloudRunDeployerCommand(projectID: String) -> String {
        """
        PROJECT_NUMBER=$(gcloud projects describe \(projectID) --format='value(projectNumber)')
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/run.admin"
        gcloud iam service-accounts add-iam-policy-binding \\
            ${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/iam.serviceAccountUser"
        """
    }

    /// Grant Cloud Build access to deploy to GKE
    public static func grantGKEDeployerCommand(projectID: String) -> String {
        """
        PROJECT_NUMBER=$(gcloud projects describe \(projectID) --format='value(projectNumber)')
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/container.developer"
        """
    }

    /// Grant Cloud Build access to push to Artifact Registry
    public static func grantArtifactRegistryWriterCommand(projectID: String) -> String {
        """
        PROJECT_NUMBER=$(gcloud projects describe \(projectID) --format='value(projectNumber)')
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/artifactregistry.writer"
        """
    }

    /// Approve a pending build
    public static func approveCommand(buildID: String, projectID: String, region: String? = nil) -> String {
        var cmd = "gcloud builds approve \(buildID) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// Reject a pending build
    public static func rejectCommand(buildID: String, projectID: String, region: String? = nil, comment: String? = nil) -> String {
        var cmd = "gcloud builds reject \(buildID) --project=\(projectID)"
        if let region = region {
            cmd += " --region=\(region)"
        }
        if let comment = comment {
            cmd += " --comment=\"\(comment)\""
        }
        return cmd
    }
}

// MARK: - Cloudbuild.yaml Generator

/// Generates cloudbuild.yaml configuration files
public enum CloudBuildConfigGenerator {
    /// Generate a basic Docker build and push configuration
    public static func dockerBuildPush(
        imageName: String,
        dockerfile: String = "Dockerfile",
        context: String = "."
    ) -> String {
        """
        steps:
          - name: 'gcr.io/cloud-builders/docker'
            args:
              - 'build'
              - '-t'
              - '\(imageName):$COMMIT_SHA'
              - '-t'
              - '\(imageName):latest'
              - '-f'
              - '\(dockerfile)'
              - '\(context)'

          - name: 'gcr.io/cloud-builders/docker'
            args: ['push', '--all-tags', '\(imageName)']

        images:
          - '\(imageName):$COMMIT_SHA'
          - '\(imageName):latest'
        """
    }

    /// Generate a Docker build, push, and Cloud Run deploy configuration
    public static func dockerBuildDeployCloudRun(
        imageName: String,
        serviceName: String,
        region: String,
        dockerfile: String = "Dockerfile",
        context: String = ".",
        envVars: [String: String] = [:],
        memory: String? = nil,
        cpu: String? = nil,
        minInstances: Int? = nil,
        maxInstances: Int? = nil,
        allowUnauthenticated: Bool = true
    ) -> String {
        var deployArgs = """
              - 'run'
              - 'deploy'
              - '\(serviceName)'
              - '--image=\(imageName):$COMMIT_SHA'
              - '--region=\(region)'
              - '--platform=managed'
        """

        if allowUnauthenticated {
            deployArgs += "\n      - '--allow-unauthenticated'"
        }

        if let mem = memory {
            deployArgs += "\n      - '--memory=\(mem)'"
        }

        if let c = cpu {
            deployArgs += "\n      - '--cpu=\(c)'"
        }

        if let min = minInstances {
            deployArgs += "\n      - '--min-instances=\(min)'"
        }

        if let max = maxInstances {
            deployArgs += "\n      - '--max-instances=\(max)'"
        }

        if !envVars.isEmpty {
            let envStr = envVars.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            deployArgs += "\n      - '--set-env-vars=\(envStr)'"
        }

        return """
        steps:
          - name: 'gcr.io/cloud-builders/docker'
            args:
              - 'build'
              - '-t'
              - '\(imageName):$COMMIT_SHA'
              - '-t'
              - '\(imageName):latest'
              - '-f'
              - '\(dockerfile)'
              - '\(context)'

          - name: 'gcr.io/cloud-builders/docker'
            args: ['push', '--all-tags', '\(imageName)']

          - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
            entrypoint: gcloud
            args:
        \(deployArgs)

        images:
          - '\(imageName):$COMMIT_SHA'
          - '\(imageName):latest'

        options:
          logging: CLOUD_LOGGING_ONLY
        """
    }

    /// Generate a Swift build and test configuration
    public static func swiftBuildTest() -> String {
        """
        steps:
          - name: 'swift:5.10'
            entrypoint: 'bash'
            args:
              - '-c'
              - |
                swift build
                swift test

        options:
          logging: CLOUD_LOGGING_ONLY
        """
    }

    /// Generate a Swift build, Docker build, and Cloud Run deploy configuration
    public static func swiftDockerCloudRun(
        imageName: String,
        serviceName: String,
        region: String,
        executableName: String,
        port: Int = 8080
    ) -> String {
        """
        steps:
          # Run tests
          - name: 'swift:5.10'
            id: 'test'
            entrypoint: 'bash'
            args:
              - '-c'
              - |
                swift build
                swift test

          # Build Docker image
          - name: 'gcr.io/cloud-builders/docker'
            id: 'build'
            waitFor: ['test']
            args:
              - 'build'
              - '-t'
              - '\(imageName):$COMMIT_SHA'
              - '-t'
              - '\(imageName):latest'
              - '.'

          # Push to Artifact Registry
          - name: 'gcr.io/cloud-builders/docker'
            id: 'push'
            waitFor: ['build']
            args: ['push', '--all-tags', '\(imageName)']

          # Deploy to Cloud Run
          - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
            id: 'deploy'
            waitFor: ['push']
            entrypoint: gcloud
            args:
              - 'run'
              - 'deploy'
              - '\(serviceName)'
              - '--image=\(imageName):$COMMIT_SHA'
              - '--region=\(region)'
              - '--platform=managed'
              - '--port=\(port)'
              - '--allow-unauthenticated'

        images:
          - '\(imageName):$COMMIT_SHA'
          - '\(imageName):latest'

        options:
          logging: CLOUD_LOGGING_ONLY
        """
    }

    /// Generate a multi-service deployment configuration
    public static func multiServiceDeploy(
        services: [(name: String, imageName: String, dockerfile: String, region: String)]
    ) -> String {
        var steps = "steps:\n"

        // Build steps
        for (index, service) in services.enumerated() {
            steps += """
              - name: 'gcr.io/cloud-builders/docker'
                id: 'build-\(service.name)'
                args:
                  - 'build'
                  - '-t'
                  - '\(service.imageName):$COMMIT_SHA'
                  - '-f'
                  - '\(service.dockerfile)'
                  - '.'

            """
            if index < services.count - 1 {
                steps += "\n"
            }
        }

        // Push steps
        for service in services {
            steps += """

              - name: 'gcr.io/cloud-builders/docker'
                id: 'push-\(service.name)'
                waitFor: ['build-\(service.name)']
                args: ['push', '\(service.imageName):$COMMIT_SHA']
            """
        }

        // Deploy steps
        for service in services {
            steps += """

              - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
                id: 'deploy-\(service.name)'
                waitFor: ['push-\(service.name)']
                entrypoint: gcloud
                args:
                  - 'run'
                  - 'deploy'
                  - '\(service.name)'
                  - '--image=\(service.imageName):$COMMIT_SHA'
                  - '--region=\(service.region)'
                  - '--platform=managed'
            """
        }

        // Images
        steps += "\n\nimages:\n"
        for service in services {
            steps += "  - '\(service.imageName):$COMMIT_SHA'\n"
        }

        steps += "\noptions:\n  logging: CLOUD_LOGGING_ONLY"

        return steps
    }
}

// MARK: - DAIS Cloud Build Templates

/// Pre-configured Cloud Build templates for DAIS deployments
public enum DAISCloudBuildTemplate {
    /// Create a GitHub trigger for DAIS deployment
    public static func githubTrigger(
        projectID: String,
        deploymentName: String,
        owner: String,
        repo: String,
        branch: String = "^main$",
        region: String? = nil
    ) -> GoogleCloudBuildTrigger {
        GoogleCloudBuildTrigger(
            name: "\(deploymentName)-deploy",
            projectID: projectID,
            description: "Deploy \(deploymentName) on push to main",
            tags: ["dais", deploymentName],
            triggerSource: .github(
                owner: owner,
                name: repo,
                eventConfig: .push(branch: branch, tag: nil, invertRegex: false)
            ),
            buildConfig: .filename("cloudbuild.yaml"),
            substitutions: [
                "DEPLOYMENT_NAME": deploymentName
            ],
            region: region
        )
    }

    /// Create a PR preview trigger
    public static func prPreviewTrigger(
        projectID: String,
        deploymentName: String,
        owner: String,
        repo: String,
        region: String? = nil
    ) -> GoogleCloudBuildTrigger {
        GoogleCloudBuildTrigger(
            name: "\(deploymentName)-pr-preview",
            projectID: projectID,
            description: "Deploy preview for PRs to \(deploymentName)",
            tags: ["dais", deploymentName, "preview"],
            triggerSource: .github(
                owner: owner,
                name: repo,
                eventConfig: .pullRequest(branch: "^main$", commentControl: .commentsEnabledForExternalContributorsOnly, invertRegex: false)
            ),
            buildConfig: .filename("cloudbuild-preview.yaml"),
            region: region
        )
    }

    /// Create a manual trigger for on-demand deployments
    public static func manualTrigger(
        projectID: String,
        deploymentName: String,
        region: String? = nil
    ) -> GoogleCloudBuildTrigger {
        GoogleCloudBuildTrigger(
            name: "\(deploymentName)-manual",
            projectID: projectID,
            description: "Manual deployment for \(deploymentName)",
            tags: ["dais", deploymentName, "manual"],
            triggerSource: .manual,
            buildConfig: .filename("cloudbuild.yaml"),
            region: region
        )
    }

    /// Generate a complete DAIS cloudbuild.yaml
    public static func cloudbuildYaml(
        projectID: String,
        location: String,
        deploymentName: String,
        cloudRunRegion: String,
        services: [(name: String, port: Int)]
    ) -> String {
        let imageBase = "\(location)-docker.pkg.dev/\(projectID)/\(deploymentName)-docker"

        var yaml = """
        # DAIS Cloud Build Configuration
        # Deployment: \(deploymentName)

        substitutions:
          _DEPLOYMENT_NAME: '\(deploymentName)'
          _REGION: '\(cloudRunRegion)'

        steps:
        """

        // Build steps for each service
        for service in services {
            yaml += """

          # Build \(service.name)
          - name: 'gcr.io/cloud-builders/docker'
            id: 'build-\(service.name)'
            args:
              - 'build'
              - '-t'
              - '\(imageBase)/\(service.name):$COMMIT_SHA'
              - '-t'
              - '\(imageBase)/\(service.name):latest'
              - '-f'
              - 'services/\(service.name)/Dockerfile'
              - '.'
        """
        }

        // Push steps
        for service in services {
            yaml += """

          # Push \(service.name)
          - name: 'gcr.io/cloud-builders/docker'
            id: 'push-\(service.name)'
            waitFor: ['build-\(service.name)']
            args: ['push', '--all-tags', '\(imageBase)/\(service.name)']
        """
        }

        // Deploy steps
        for service in services {
            yaml += """

          # Deploy \(service.name)
          - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
            id: 'deploy-\(service.name)'
            waitFor: ['push-\(service.name)']
            entrypoint: gcloud
            args:
              - 'run'
              - 'deploy'
              - '${_DEPLOYMENT_NAME}-\(service.name)'
              - '--image=\(imageBase)/\(service.name):$COMMIT_SHA'
              - '--region=${_REGION}'
              - '--platform=managed'
              - '--port=\(service.port)'
        """
        }

        // Images section
        yaml += "\n\nimages:\n"
        for service in services {
            yaml += "  - '\(imageBase)/\(service.name):$COMMIT_SHA'\n"
            yaml += "  - '\(imageBase)/\(service.name):latest'\n"
        }

        yaml += """

        options:
          logging: CLOUD_LOGGING_ONLY
          machineType: 'E2_HIGHCPU_8'

        timeout: '1800s'
        """

        return yaml
    }

    /// Generate complete CI/CD setup script
    public static func setupScript(
        projectID: String,
        location: String,
        deploymentName: String,
        githubOwner: String,
        githubRepo: String,
        cloudRunRegion: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # DAIS Cloud Build Setup Script
        # Project: \(projectID)
        # Deployment: \(deploymentName)

        echo "Enabling Cloud Build API..."
        gcloud services enable cloudbuild.googleapis.com --project=\(projectID)

        echo "Getting project number..."
        PROJECT_NUMBER=$(gcloud projects describe \(projectID) --format='value(projectNumber)')

        echo "Granting Cloud Build permissions..."

        # Grant Artifact Registry Writer
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/artifactregistry.writer"

        # Grant Cloud Run Admin
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/run.admin"

        # Grant Service Account User
        gcloud iam service-accounts add-iam-policy-binding \\
            ${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \\
            --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \\
            --role="roles/iam.serviceAccountUser" \\
            --project=\(projectID)

        echo "Creating GitHub connection..."
        echo "Please complete the OAuth flow in the Cloud Console:"
        echo "https://console.cloud.google.com/cloud-build/repositories/2nd-gen/connect?project=\(projectID)"
        echo ""
        read -p "Press enter after connecting your GitHub account..."

        echo "Creating build trigger..."
        gcloud builds triggers create github \\
            --name="\(deploymentName)-deploy" \\
            --project=\(projectID) \\
            --repo-owner=\(githubOwner) \\
            --repo-name=\(githubRepo) \\
            --branch-pattern="^main$" \\
            --build-config=cloudbuild.yaml \\
            --description="Deploy \(deploymentName) on push to main"

        echo ""
        echo "Cloud Build Setup Complete!"
        echo ""
        echo "Build trigger: \(deploymentName)-deploy"
        echo "Pushes to main branch will automatically build and deploy."
        echo ""
        echo "To manually trigger a build:"
        echo "  gcloud builds triggers run \(deploymentName)-deploy --branch=main --project=\(projectID)"
        """
    }

    /// Generate teardown script
    public static func teardownScript(
        projectID: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # DAIS Cloud Build Teardown Script

        echo "Deleting build triggers..."
        gcloud builds triggers delete \(deploymentName)-deploy --project=\(projectID) --quiet || true
        gcloud builds triggers delete \(deploymentName)-pr-preview --project=\(projectID) --quiet || true
        gcloud builds triggers delete \(deploymentName)-manual --project=\(projectID) --quiet || true

        echo "Cloud Build teardown complete!"
        """
    }

    /// Worker pool for private builds
    public static func workerPool(
        projectID: String,
        region: String,
        deploymentName: String,
        vpcNetwork: String? = nil
    ) -> GoogleCloudBuildWorkerPool {
        var networkConfig: GoogleCloudBuildWorkerPool.PrivatePoolConfig.NetworkConfig?
        if let network = vpcNetwork {
            networkConfig = .init(peeredNetwork: network, egressOption: .noPublicEgress)
        }

        return GoogleCloudBuildWorkerPool(
            name: "\(deploymentName)-pool",
            projectID: projectID,
            region: region,
            displayName: "DAIS \(deploymentName) Worker Pool",
            privatePoolConfig: .init(
                workerConfig: .init(machineType: "e2-standard-4", diskSizeGb: 100),
                networkConfig: networkConfig
            )
        )
    }
}
