// GoogleCloudTasks.swift
// Cloud Tasks - Distributed Task Queue
//
// Cloud Tasks enables asynchronous task execution with reliable delivery,
// rate limiting, and retry policies.

import Foundation

// MARK: - Task Queue

/// Represents a Cloud Tasks queue
public struct GoogleCloudTaskQueue: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let rateLimits: RateLimits?
    public let retryConfig: RetryConfig?
    public let stackdriverLoggingConfig: StackdriverLoggingConfig?

    public init(
        name: String,
        projectID: String,
        location: String,
        rateLimits: RateLimits? = nil,
        retryConfig: RetryConfig? = nil,
        stackdriverLoggingConfig: StackdriverLoggingConfig? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.rateLimits = rateLimits
        self.retryConfig = retryConfig
        self.stackdriverLoggingConfig = stackdriverLoggingConfig
    }

    /// Rate limits for the queue
    public struct RateLimits: Codable, Sendable, Equatable {
        public let maxDispatchesPerSecond: Double?
        public let maxBurstSize: Int?
        public let maxConcurrentDispatches: Int?

        public init(
            maxDispatchesPerSecond: Double? = nil,
            maxBurstSize: Int? = nil,
            maxConcurrentDispatches: Int? = nil
        ) {
            self.maxDispatchesPerSecond = maxDispatchesPerSecond
            self.maxBurstSize = maxBurstSize
            self.maxConcurrentDispatches = maxConcurrentDispatches
        }
    }

    /// Retry configuration for failed tasks
    public struct RetryConfig: Codable, Sendable, Equatable {
        public let maxAttempts: Int?
        public let maxRetryDuration: String?
        public let minBackoff: String?
        public let maxBackoff: String?
        public let maxDoublings: Int?

        public init(
            maxAttempts: Int? = nil,
            maxRetryDuration: String? = nil,
            minBackoff: String? = nil,
            maxBackoff: String? = nil,
            maxDoublings: Int? = nil
        ) {
            self.maxAttempts = maxAttempts
            self.maxRetryDuration = maxRetryDuration
            self.minBackoff = minBackoff
            self.maxBackoff = maxBackoff
            self.maxDoublings = maxDoublings
        }
    }

    /// Stackdriver logging configuration
    public struct StackdriverLoggingConfig: Codable, Sendable, Equatable {
        public let samplingRatio: Double

        public init(samplingRatio: Double = 1.0) {
            self.samplingRatio = samplingRatio
        }
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/queues/\(name)"
    }

    /// Command to create queue
    public var createCommand: String {
        var cmd = "gcloud tasks queues create \(name)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"

        if let rateLimits = rateLimits {
            if let maxDispatchesPerSecond = rateLimits.maxDispatchesPerSecond {
                cmd += " --max-dispatches-per-second=\(maxDispatchesPerSecond)"
            }
            if let maxConcurrentDispatches = rateLimits.maxConcurrentDispatches {
                cmd += " --max-concurrent-dispatches=\(maxConcurrentDispatches)"
            }
        }

        if let retryConfig = retryConfig {
            if let maxAttempts = retryConfig.maxAttempts {
                cmd += " --max-attempts=\(maxAttempts)"
            }
            if let minBackoff = retryConfig.minBackoff {
                cmd += " --min-backoff=\(minBackoff)"
            }
            if let maxBackoff = retryConfig.maxBackoff {
                cmd += " --max-backoff=\(maxBackoff)"
            }
        }

        return cmd
    }

    /// Command to update queue
    public var updateCommand: String {
        var cmd = "gcloud tasks queues update \(name)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"
        return cmd
    }

    /// Command to delete queue
    public var deleteCommand: String {
        "gcloud tasks queues delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// Command to describe queue
    public var describeCommand: String {
        "gcloud tasks queues describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to pause queue
    public var pauseCommand: String {
        "gcloud tasks queues pause \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to resume queue
    public var resumeCommand: String {
        "gcloud tasks queues resume \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to purge queue
    public var purgeCommand: String {
        "gcloud tasks queues purge \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// Command to list queues
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud tasks queues list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - HTTP Task

/// Represents an HTTP task
public struct GoogleCloudHTTPTask: Codable, Sendable, Equatable {
    public let queueName: String
    public let projectID: String
    public let location: String
    public let url: String
    public let httpMethod: HTTPMethod
    public let headers: [String: String]?
    public let body: String?
    public let scheduleTime: Date?
    public let dispatchDeadline: String?
    public let taskID: String?
    public let oidcToken: OIDCToken?
    public let oauthToken: OAuthToken?

    public init(
        queueName: String,
        projectID: String,
        location: String,
        url: String,
        httpMethod: HTTPMethod = .post,
        headers: [String: String]? = nil,
        body: String? = nil,
        scheduleTime: Date? = nil,
        dispatchDeadline: String? = nil,
        taskID: String? = nil,
        oidcToken: OIDCToken? = nil,
        oauthToken: OAuthToken? = nil
    ) {
        self.queueName = queueName
        self.projectID = projectID
        self.location = location
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.body = body
        self.scheduleTime = scheduleTime
        self.dispatchDeadline = dispatchDeadline
        self.taskID = taskID
        self.oidcToken = oidcToken
        self.oauthToken = oauthToken
    }

    public enum HTTPMethod: String, Codable, Sendable, Equatable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
        case head = "HEAD"
        case options = "OPTIONS"
    }

    /// OIDC token for authentication
    public struct OIDCToken: Codable, Sendable, Equatable {
        public let serviceAccountEmail: String
        public let audience: String?

        public init(serviceAccountEmail: String, audience: String? = nil) {
            self.serviceAccountEmail = serviceAccountEmail
            self.audience = audience
        }
    }

    /// OAuth token for authentication
    public struct OAuthToken: Codable, Sendable, Equatable {
        public let serviceAccountEmail: String
        public let scope: String?

        public init(serviceAccountEmail: String, scope: String? = nil) {
            self.serviceAccountEmail = serviceAccountEmail
            self.scope = scope
        }
    }

    /// Command to create HTTP task
    public var createCommand: String {
        var cmd = "gcloud tasks create-http-task"

        if let taskID = taskID {
            cmd += " \(taskID)"
        }

        cmd += " --queue=\(queueName)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"
        cmd += " --url=\"\(url)\""
        cmd += " --method=\(httpMethod.rawValue)"

        if let headers = headers {
            for (key, value) in headers {
                cmd += " --header=\"\(key): \(value)\""
            }
        }

        if let body = body {
            cmd += " --body-content=\"\(body)\""
        }

        if let scheduleTime = scheduleTime {
            let formatter = ISO8601DateFormatter()
            cmd += " --schedule-time=\(formatter.string(from: scheduleTime))"
        }

        if let oidcToken = oidcToken {
            cmd += " --oidc-service-account-email=\(oidcToken.serviceAccountEmail)"
            if let audience = oidcToken.audience {
                cmd += " --oidc-token-audience=\(audience)"
            }
        }

        if let oauthToken = oauthToken {
            cmd += " --oauth-service-account-email=\(oauthToken.serviceAccountEmail)"
            if let scope = oauthToken.scope {
                cmd += " --oauth-token-scope=\(scope)"
            }
        }

        return cmd
    }
}

// MARK: - App Engine Task

/// Represents an App Engine task
public struct GoogleCloudAppEngineTask: Codable, Sendable, Equatable {
    public let queueName: String
    public let projectID: String
    public let location: String
    public let relativeUri: String
    public let httpMethod: GoogleCloudHTTPTask.HTTPMethod
    public let headers: [String: String]?
    public let body: String?
    public let scheduleTime: Date?
    public let taskID: String?
    public let appEngineRouting: AppEngineRouting?

    public init(
        queueName: String,
        projectID: String,
        location: String,
        relativeUri: String,
        httpMethod: GoogleCloudHTTPTask.HTTPMethod = .post,
        headers: [String: String]? = nil,
        body: String? = nil,
        scheduleTime: Date? = nil,
        taskID: String? = nil,
        appEngineRouting: AppEngineRouting? = nil
    ) {
        self.queueName = queueName
        self.projectID = projectID
        self.location = location
        self.relativeUri = relativeUri
        self.httpMethod = httpMethod
        self.headers = headers
        self.body = body
        self.scheduleTime = scheduleTime
        self.taskID = taskID
        self.appEngineRouting = appEngineRouting
    }

    /// App Engine routing configuration
    public struct AppEngineRouting: Codable, Sendable, Equatable {
        public let service: String?
        public let version: String?
        public let instance: String?

        public init(service: String? = nil, version: String? = nil, instance: String? = nil) {
            self.service = service
            self.version = version
            self.instance = instance
        }
    }

    /// Command to create App Engine task
    public var createCommand: String {
        var cmd = "gcloud tasks create-app-engine-task"

        if let taskID = taskID {
            cmd += " \(taskID)"
        }

        cmd += " --queue=\(queueName)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"
        cmd += " --relative-uri=\"\(relativeUri)\""
        cmd += " --method=\(httpMethod.rawValue)"

        if let headers = headers {
            for (key, value) in headers {
                cmd += " --header=\"\(key): \(value)\""
            }
        }

        if let body = body {
            cmd += " --body-content=\"\(body)\""
        }

        if let routing = appEngineRouting {
            if let service = routing.service {
                cmd += " --routing=\"service:\(service)\""
            }
        }

        return cmd
    }
}

// MARK: - Task Operations

/// Common task operations
public enum TaskOperations {

    /// Command to describe a task
    public static func describeTask(
        taskID: String,
        queueName: String,
        location: String,
        projectID: String
    ) -> String {
        "gcloud tasks describe \(taskID) --queue=\(queueName) --location=\(location) --project=\(projectID)"
    }

    /// Command to delete a task
    public static func deleteTask(
        taskID: String,
        queueName: String,
        location: String,
        projectID: String
    ) -> String {
        "gcloud tasks delete \(taskID) --queue=\(queueName) --location=\(location) --project=\(projectID) --quiet"
    }

    /// Command to run a task immediately
    public static func runTask(
        taskID: String,
        queueName: String,
        location: String,
        projectID: String
    ) -> String {
        "gcloud tasks run \(taskID) --queue=\(queueName) --location=\(location) --project=\(projectID)"
    }

    /// Command to list tasks in a queue
    public static func listTasks(
        queueName: String,
        location: String,
        projectID: String
    ) -> String {
        "gcloud tasks list --queue=\(queueName) --location=\(location) --project=\(projectID)"
    }

    /// Command to get queue IAM policy
    public static func getIAMPolicy(
        queueName: String,
        location: String,
        projectID: String
    ) -> String {
        "gcloud tasks queues get-iam-policy \(queueName) --location=\(location) --project=\(projectID)"
    }

    /// Command to add IAM binding
    public static func addIAMBinding(
        queueName: String,
        location: String,
        projectID: String,
        member: String,
        role: String
    ) -> String {
        "gcloud tasks queues add-iam-policy-binding \(queueName) --location=\(location) --project=\(projectID) --member=\"\(member)\" --role=\"\(role)\""
    }
}

// MARK: - Task Queue Roles

/// Predefined IAM roles for Cloud Tasks
public enum TaskQueueRole: String, Codable, Sendable, Equatable {
    case admin = "roles/cloudtasks.admin"
    case enqueuer = "roles/cloudtasks.enqueuer"
    case taskDeleter = "roles/cloudtasks.taskDeleter"
    case taskRunner = "roles/cloudtasks.taskRunner"
    case viewer = "roles/cloudtasks.viewer"
    case queueAdmin = "roles/cloudtasks.queueAdmin"

    public var description: String {
        switch self {
        case .admin:
            return "Full control of Cloud Tasks resources"
        case .enqueuer:
            return "Can create tasks"
        case .taskDeleter:
            return "Can delete tasks"
        case .taskRunner:
            return "Can run tasks"
        case .viewer:
            return "Read-only access to tasks and queues"
        case .queueAdmin:
            return "Administer queues"
        }
    }
}

// MARK: - DAIS Task Templates

/// DAIS-specific Cloud Tasks configurations
public enum DAISTasksTemplate {

    /// Queue for async API processing
    public static func apiProcessingQueue(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudTaskQueue {
        GoogleCloudTaskQueue(
            name: "\(deploymentName)-api-processing",
            projectID: projectID,
            location: location,
            rateLimits: GoogleCloudTaskQueue.RateLimits(
                maxDispatchesPerSecond: 500,
                maxConcurrentDispatches: 100
            ),
            retryConfig: GoogleCloudTaskQueue.RetryConfig(
                maxAttempts: 5,
                minBackoff: "1s",
                maxBackoff: "60s",
                maxDoublings: 4
            ),
            stackdriverLoggingConfig: GoogleCloudTaskQueue.StackdriverLoggingConfig(samplingRatio: 1.0)
        )
    }

    /// Queue for background jobs
    public static func backgroundJobsQueue(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudTaskQueue {
        GoogleCloudTaskQueue(
            name: "\(deploymentName)-background-jobs",
            projectID: projectID,
            location: location,
            rateLimits: GoogleCloudTaskQueue.RateLimits(
                maxDispatchesPerSecond: 100,
                maxConcurrentDispatches: 20
            ),
            retryConfig: GoogleCloudTaskQueue.RetryConfig(
                maxAttempts: 10,
                minBackoff: "10s",
                maxBackoff: "300s",
                maxDoublings: 5
            )
        )
    }

    /// Queue for high-priority tasks
    public static func highPriorityQueue(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudTaskQueue {
        GoogleCloudTaskQueue(
            name: "\(deploymentName)-high-priority",
            projectID: projectID,
            location: location,
            rateLimits: GoogleCloudTaskQueue.RateLimits(
                maxDispatchesPerSecond: 1000,
                maxConcurrentDispatches: 200
            ),
            retryConfig: GoogleCloudTaskQueue.RetryConfig(
                maxAttempts: 3,
                minBackoff: "0.5s",
                maxBackoff: "10s"
            )
        )
    }

    /// Queue for email notifications
    public static func emailQueue(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudTaskQueue {
        GoogleCloudTaskQueue(
            name: "\(deploymentName)-email-notifications",
            projectID: projectID,
            location: location,
            rateLimits: GoogleCloudTaskQueue.RateLimits(
                maxDispatchesPerSecond: 50,
                maxConcurrentDispatches: 10
            ),
            retryConfig: GoogleCloudTaskQueue.RetryConfig(
                maxAttempts: 5,
                minBackoff: "60s",
                maxBackoff: "3600s"
            )
        )
    }

    /// HTTP task for Cloud Run service
    public static func cloudRunTask(
        queueName: String,
        projectID: String,
        location: String,
        cloudRunURL: String,
        endpoint: String,
        payload: String,
        serviceAccountEmail: String
    ) -> GoogleCloudHTTPTask {
        GoogleCloudHTTPTask(
            queueName: queueName,
            projectID: projectID,
            location: location,
            url: "\(cloudRunURL)\(endpoint)",
            httpMethod: .post,
            headers: ["Content-Type": "application/json"],
            body: payload,
            oidcToken: GoogleCloudHTTPTask.OIDCToken(
                serviceAccountEmail: serviceAccountEmail,
                audience: cloudRunURL
            )
        )
    }

    /// HTTP task for Cloud Functions
    public static func cloudFunctionTask(
        queueName: String,
        projectID: String,
        location: String,
        functionURL: String,
        payload: String,
        serviceAccountEmail: String
    ) -> GoogleCloudHTTPTask {
        GoogleCloudHTTPTask(
            queueName: queueName,
            projectID: projectID,
            location: location,
            url: functionURL,
            httpMethod: .post,
            headers: ["Content-Type": "application/json"],
            body: payload,
            oidcToken: GoogleCloudHTTPTask.OIDCToken(
                serviceAccountEmail: serviceAccountEmail,
                audience: functionURL
            )
        )
    }

    /// Delayed task with schedule time
    public static func delayedTask(
        queueName: String,
        projectID: String,
        location: String,
        url: String,
        payload: String,
        delaySeconds: Int,
        serviceAccountEmail: String
    ) -> GoogleCloudHTTPTask {
        GoogleCloudHTTPTask(
            queueName: queueName,
            projectID: projectID,
            location: location,
            url: url,
            httpMethod: .post,
            headers: ["Content-Type": "application/json"],
            body: payload,
            scheduleTime: Date().addingTimeInterval(TimeInterval(delaySeconds)),
            oidcToken: GoogleCloudHTTPTask.OIDCToken(
                serviceAccountEmail: serviceAccountEmail
            )
        )
    }

    /// Setup script for DAIS task queues
    public static func setupScript(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Cloud Tasks Setup Script
        set -e

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        DEPLOYMENT_NAME="\(deploymentName)"

        echo "Enabling Cloud Tasks API..."
        gcloud services enable cloudtasks.googleapis.com --project=${PROJECT_ID}

        echo "Creating API processing queue..."
        gcloud tasks queues create ${DEPLOYMENT_NAME}-api-processing \\
            --location=${LOCATION} \\
            --project=${PROJECT_ID} \\
            --max-dispatches-per-second=500 \\
            --max-concurrent-dispatches=100 \\
            --max-attempts=5 \\
            --min-backoff=1s \\
            --max-backoff=60s || true

        echo "Creating background jobs queue..."
        gcloud tasks queues create ${DEPLOYMENT_NAME}-background-jobs \\
            --location=${LOCATION} \\
            --project=${PROJECT_ID} \\
            --max-dispatches-per-second=100 \\
            --max-concurrent-dispatches=20 \\
            --max-attempts=10 \\
            --min-backoff=10s \\
            --max-backoff=300s || true

        echo "Creating high-priority queue..."
        gcloud tasks queues create ${DEPLOYMENT_NAME}-high-priority \\
            --location=${LOCATION} \\
            --project=${PROJECT_ID} \\
            --max-dispatches-per-second=1000 \\
            --max-concurrent-dispatches=200 \\
            --max-attempts=3 || true

        echo "Cloud Tasks setup complete!"
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
        # DAIS Cloud Tasks Teardown Script
        set -e

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        DEPLOYMENT_NAME="\(deploymentName)"

        echo "Deleting task queues..."
        gcloud tasks queues delete ${DEPLOYMENT_NAME}-api-processing \\
            --location=${LOCATION} --project=${PROJECT_ID} --quiet || true
        gcloud tasks queues delete ${DEPLOYMENT_NAME}-background-jobs \\
            --location=${LOCATION} --project=${PROJECT_ID} --quiet || true
        gcloud tasks queues delete ${DEPLOYMENT_NAME}-high-priority \\
            --location=${LOCATION} --project=${PROJECT_ID} --quiet || true

        echo "Cloud Tasks teardown complete!"
        """
    }
}
