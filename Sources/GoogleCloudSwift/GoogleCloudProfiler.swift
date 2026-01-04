import Foundation

// MARK: - Cloud Profiler Profile

/// Represents a Cloud Profiler profile
public struct GoogleCloudProfilerProfile: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let profileType: ProfileType
    public let deployment: Deployment?
    public let duration: String?
    public let labels: [String: String]?
    public let createTime: Date?

    public enum ProfileType: String, Codable, Sendable, Equatable {
        case cpu = "CPU"
        case heap = "HEAP"
        case heapAlloc = "HEAP_ALLOC"
        case threads = "THREADS"
        case contention = "CONTENTION"
        case peakHeap = "PEAK_HEAP"
        case wallTime = "WALL"
    }

    public struct Deployment: Codable, Sendable, Equatable {
        public let projectID: String
        public let target: String
        public let labels: [String: String]?

        public init(projectID: String, target: String, labels: [String: String]? = nil) {
            self.projectID = projectID
            self.target = target
            self.labels = labels
        }
    }

    public init(
        name: String,
        projectID: String,
        profileType: ProfileType,
        deployment: Deployment? = nil,
        duration: String? = nil,
        labels: [String: String]? = nil,
        createTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.profileType = profileType
        self.deployment = deployment
        self.duration = duration
        self.labels = labels
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/profiles/\(name)"
    }
}

// MARK: - Profiler Agent Configuration

/// Configuration for the Cloud Profiler agent
public struct GoogleCloudProfilerAgentConfig: Codable, Sendable, Equatable {
    public let projectID: String
    public let service: String
    public let serviceVersion: String?
    public let zone: String?
    public let cpuProfilingEnabled: Bool
    public let heapProfilingEnabled: Bool
    public let allocationProfilingEnabled: Bool
    public let mutexProfilingEnabled: Bool
    public let debugLoggingEnabled: Bool

    public init(
        projectID: String,
        service: String,
        serviceVersion: String? = nil,
        zone: String? = nil,
        cpuProfilingEnabled: Bool = true,
        heapProfilingEnabled: Bool = true,
        allocationProfilingEnabled: Bool = false,
        mutexProfilingEnabled: Bool = false,
        debugLoggingEnabled: Bool = false
    ) {
        self.projectID = projectID
        self.service = service
        self.serviceVersion = serviceVersion
        self.zone = zone
        self.cpuProfilingEnabled = cpuProfilingEnabled
        self.heapProfilingEnabled = heapProfilingEnabled
        self.allocationProfilingEnabled = allocationProfilingEnabled
        self.mutexProfilingEnabled = mutexProfilingEnabled
        self.debugLoggingEnabled = debugLoggingEnabled
    }

    /// Environment variables for configuring the profiler agent
    public var environmentVariables: [String: String] {
        var vars: [String: String] = [
            "GOOGLE_CLOUD_PROJECT": projectID,
            "GAE_SERVICE": service
        ]

        if let version = serviceVersion {
            vars["GAE_VERSION"] = version
        }

        if let zone = zone {
            vars["GCLOUD_ZONE"] = zone
        }

        if cpuProfilingEnabled {
            vars["PROFILER_ENABLE_CPU"] = "true"
        }

        if heapProfilingEnabled {
            vars["PROFILER_ENABLE_HEAP"] = "true"
        }

        if allocationProfilingEnabled {
            vars["PROFILER_ENABLE_ALLOC"] = "true"
        }

        if mutexProfilingEnabled {
            vars["PROFILER_ENABLE_MUTEX"] = "true"
        }

        if debugLoggingEnabled {
            vars["PROFILER_DEBUG"] = "true"
        }

        return vars
    }

    /// Docker run command with profiler configuration
    public func dockerRunCommand(image: String) -> String {
        var cmd = "docker run"
        for (key, value) in environmentVariables {
            cmd += " -e \(key)=\(value)"
        }
        cmd += " \(image)"
        return cmd
    }
}

// MARK: - Profiler Operations

/// Helper operations for Cloud Profiler
public struct ProfilerOperations: Sendable {

    /// Command to enable Cloud Profiler API
    public static var enableAPICommand: String {
        "gcloud services enable cloudprofiler.googleapis.com"
    }

    /// Command to list profiles
    public static func listProfilesCommand(projectID: String, pageSize: Int? = nil) -> String {
        var cmd = """
        curl -X GET "https://cloudprofiler.googleapis.com/v2/projects/\(projectID)/profiles" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """

        if let size = pageSize {
            cmd = """
            curl -X GET "https://cloudprofiler.googleapis.com/v2/projects/\(projectID)/profiles?pageSize=\(size)" \\
              -H "Authorization: Bearer $(gcloud auth print-access-token)"
            """
        }

        return cmd
    }

    /// Command to get a specific profile
    public static func getProfileCommand(projectID: String, profileName: String) -> String {
        """
        curl -X GET "https://cloudprofiler.googleapis.com/v2/projects/\(projectID)/profiles/\(profileName)" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """
    }

    /// Command to delete a profile
    public static func deleteProfileCommand(projectID: String, profileName: String) -> String {
        """
        curl -X DELETE "https://cloudprofiler.googleapis.com/v2/projects/\(projectID)/profiles/\(profileName)" \\
          -H "Authorization: Bearer $(gcloud auth print-access-token)"
        """
    }

    /// IAM roles for Cloud Profiler
    public struct Roles {
        public static let agent = "roles/cloudprofiler.agent"
        public static let user = "roles/cloudprofiler.user"
    }

    /// Command to add profiler agent role
    public static func addAgentRoleCommand(projectID: String, serviceAccount: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=serviceAccount:\(serviceAccount) --role=roles/cloudprofiler.agent"
    }

    /// Command to add profiler user role
    public static func addUserRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=roles/cloudprofiler.user"
    }
}

// MARK: - Profiler Query

/// Query parameters for listing profiles
public struct GoogleCloudProfilerQuery: Codable, Sendable, Equatable {
    public let projectID: String
    public let startTime: Date?
    public let endTime: Date?
    public let profileType: GoogleCloudProfilerProfile.ProfileType?
    public let service: String?
    public let version: String?
    public let zone: String?

    public init(
        projectID: String,
        startTime: Date? = nil,
        endTime: Date? = nil,
        profileType: GoogleCloudProfilerProfile.ProfileType? = nil,
        service: String? = nil,
        version: String? = nil,
        zone: String? = nil
    ) {
        self.projectID = projectID
        self.startTime = startTime
        self.endTime = endTime
        self.profileType = profileType
        self.service = service
        self.version = version
        self.zone = zone
    }

    /// Build query parameters as URL string
    public var queryString: String {
        var params: [String] = []

        if let service = service {
            params.append("deployment.labels.service=\(service)")
        }

        if let version = version {
            params.append("deployment.labels.version=\(version)")
        }

        if let zone = zone {
            params.append("deployment.labels.zone=\(zone)")
        }

        if let type = profileType {
            params.append("profile_type=\(type.rawValue)")
        }

        return params.isEmpty ? "" : "?" + params.joined(separator: "&")
    }
}

// MARK: - Language-Specific Configurations

/// Language-specific profiler configurations
public struct ProfilerLanguageConfig: Sendable {

    /// Go profiler configuration
    public struct Go: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Go code snippet to initialize the profiler
        public var initCode: String {
            """
            import (
                "cloud.google.com/go/profiler"
            )

            func main() {
                if err := profiler.Start(profiler.Config{
                    Service:        "\(service)",
                    ServiceVersion: "\(serviceVersion)",
                    ProjectID:      "\(projectID)",
                }); err != nil {
                    log.Fatalf("Failed to start profiler: %v", err)
                }
                // Your application code here
            }
            """
        }

        /// Go module dependency
        public static var moduleDependency: String {
            "cloud.google.com/go/profiler"
        }
    }

    /// Python profiler configuration
    public struct Python: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Python code snippet to initialize the profiler
        public var initCode: String {
            """
            import googlecloudprofiler

            def start_profiler():
                try:
                    googlecloudprofiler.start(
                        service='\(service)',
                        service_version='\(serviceVersion)',
                        project_id='\(projectID)',
                    )
                except (ValueError, NotImplementedError) as e:
                    print(f"Failed to start profiler: {e}")

            if __name__ == '__main__':
                start_profiler()
                # Your application code here
            """
        }

        /// Pip install command
        public static var pipInstallCommand: String {
            "pip install google-cloud-profiler"
        }
    }

    /// Node.js profiler configuration
    public struct NodeJS: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Node.js code snippet to initialize the profiler
        public var initCode: String {
            """
            require('@google-cloud/profiler').start({
                serviceContext: {
                    service: '\(service)',
                    version: '\(serviceVersion)',
                },
                projectId: '\(projectID)',
            }).catch((err) => {
                console.error('Failed to start profiler:', err);
            });

            // Your application code here
            """
        }

        /// npm install command
        public static var npmInstallCommand: String {
            "npm install @google-cloud/profiler"
        }
    }

    /// Java profiler configuration
    public struct Java: Sendable {
        public let projectID: String
        public let service: String
        public let serviceVersion: String

        public init(projectID: String, service: String, serviceVersion: String = "1.0.0") {
            self.projectID = projectID
            self.service = service
            self.serviceVersion = serviceVersion
        }

        /// Java agent JVM argument
        public var jvmArgument: String {
            "-agentpath:/opt/cprof/profiler_java_agent.so=-cprof_service=\(service),-cprof_service_version=\(serviceVersion),-cprof_project_id=\(projectID)"
        }

        /// Dockerfile snippet for Java profiler
        public var dockerfileSnippet: String {
            """
            # Install Cloud Profiler agent
            RUN mkdir -p /opt/cprof && \\
                wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz | \\
                tar xzv -C /opt/cprof

            # Add profiler agent to JVM arguments
            ENV JAVA_TOOL_OPTIONS="\(jvmArgument)"
            """
        }
    }
}

// MARK: - DAIS Profiler Template

/// Production-ready Cloud Profiler templates for DAIS systems
public struct DAISProfilerTemplate: Sendable {
    public let projectID: String
    public let service: String
    public let serviceVersion: String
    public let serviceAccount: String?

    public init(
        projectID: String,
        service: String = "dais-service",
        serviceVersion: String = "1.0.0",
        serviceAccount: String? = nil
    ) {
        self.projectID = projectID
        self.service = service
        self.serviceVersion = serviceVersion
        self.serviceAccount = serviceAccount
    }

    /// Agent configuration
    public var agentConfig: GoogleCloudProfilerAgentConfig {
        GoogleCloudProfilerAgentConfig(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion,
            cpuProfilingEnabled: true,
            heapProfilingEnabled: true,
            allocationProfilingEnabled: false,
            mutexProfilingEnabled: false
        )
    }

    /// Go configuration
    public var goConfig: ProfilerLanguageConfig.Go {
        ProfilerLanguageConfig.Go(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Python configuration
    public var pythonConfig: ProfilerLanguageConfig.Python {
        ProfilerLanguageConfig.Python(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Node.js configuration
    public var nodeJSConfig: ProfilerLanguageConfig.NodeJS {
        ProfilerLanguageConfig.NodeJS(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Java configuration
    public var javaConfig: ProfilerLanguageConfig.Java {
        ProfilerLanguageConfig.Java(
            projectID: projectID,
            service: service,
            serviceVersion: serviceVersion
        )
    }

    /// Query for recent profiles
    public var recentProfilesQuery: GoogleCloudProfilerQuery {
        GoogleCloudProfilerQuery(
            projectID: projectID,
            service: service,
            version: serviceVersion
        )
    }

    /// Setup script
    public var setupScript: String {
        var script = """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        SERVICE_NAME="\(service)"
        SERVICE_VERSION="\(serviceVersion)"

        echo "Enabling Cloud Profiler API..."
        \(ProfilerOperations.enableAPICommand)

        """

        if let sa = serviceAccount {
            script += """
            echo "Granting profiler agent role..."
            \(ProfilerOperations.addAgentRoleCommand(projectID: projectID, serviceAccount: sa))

            """
        }

        script += """
        echo ""
        echo "DAIS Cloud Profiler setup complete!"
        echo ""
        echo "Service: $SERVICE_NAME"
        echo "Version: $SERVICE_VERSION"
        echo ""
        echo "Environment variables for agent configuration:"
        """

        for (key, value) in agentConfig.environmentVariables {
            script += "\necho \"  \(key)=\(value)\""
        }

        script += """

        echo ""
        echo "View profiles at:"
        echo "  https://console.cloud.google.com/profiler?project=$PROJECT_ID&service=$SERVICE_NAME"
        """

        return script
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        echo "Cloud Profiler teardown - no resources to delete"
        echo "Profiles are automatically retained according to retention policy"
        """
    }
}
