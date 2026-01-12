//
//  GoogleCloudRunAPI.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import AsyncHTTPClient
import Foundation
import NIOCore

/// REST API client for Google Cloud Run.
///
/// Provides methods for managing Cloud Run services, jobs, and revisions via the REST API v2.
///
/// ## Example Usage
/// ```swift
/// let runAPI = await GoogleCloudRunAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // List services in a region
/// let services = try await runAPI.listServices(location: "us-central1")
///
/// // Deploy a new service
/// let service = try await runAPI.createService(
///     location: "us-central1",
///     serviceId: "my-api",
///     service: RunServiceRequest(...)
/// )
///
/// // Run a job
/// try await runAPI.runJob(location: "us-central1", jobId: "my-batch-job")
/// ```
public actor GoogleCloudRunAPI {
    private let client: GoogleCloudHTTPClient
    private let _projectId: String

    /// The Google Cloud project ID this client operates on.
    public var projectId: String { _projectId }

    private static let baseURL = "https://run.googleapis.com"

    /// Initialize the Cloud Run API client.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - projectId: The Google Cloud project ID.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds.
    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        projectId: String,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) {
        self._projectId = projectId
        self.client = GoogleCloudHTTPClient(
            authClient: authClient,
            httpClient: httpClient,
            baseURL: Self.baseURL,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    /// Create a Cloud Run API client, inferring project ID from auth credentials.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds.
    /// - Returns: A configured Cloud Run API client.
    public static func create(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) async -> GoogleCloudRunAPI {
        let projectId = await authClient.projectId
        return GoogleCloudRunAPI(
            authClient: authClient,
            httpClient: httpClient,
            projectId: projectId,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    // MARK: - Services

    /// List all Cloud Run services in a location.
    /// - Parameters:
    ///   - location: The region/location (e.g., "us-central1"). Use "-" for all locations.
    ///   - pageSize: Maximum number of services to return.
    ///   - pageToken: Token for pagination.
    ///   - showDeleted: Include services marked for deletion.
    /// - Returns: A list of services.
    public func listServices(
        location: String,
        pageSize: Int? = nil,
        pageToken: String? = nil,
        showDeleted: Bool = false
    ) async throws -> RunServiceListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }
        if showDeleted { params["showDeleted"] = "true" }

        let response: GoogleCloudAPIResponse<RunServiceListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a pagination helper for listing all services in a location.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - pageSize: Maximum number of services per page.
    /// - Returns: A pagination helper.
    public func listAllServices(
        location: String,
        pageSize: Int? = nil
    ) -> PaginationHelper<RunService> {
        PaginationHelper { pageToken in
            let response = try await self.listServices(
                location: location,
                pageSize: pageSize,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.services,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get a Cloud Run service.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    /// - Returns: The service details.
    public func getService(location: String, serviceId: String) async throws -> RunService {
        let response: GoogleCloudAPIResponse<RunService> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services/\(serviceId)"
        )
        return response.data
    }

    /// Create a new Cloud Run service.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    ///   - service: The service configuration.
    ///   - validateOnly: If true, validates the request without creating the service.
    /// - Returns: A long-running operation that can be polled for completion.
    public func createService(
        location: String,
        serviceId: String,
        service: RunServiceRequest,
        validateOnly: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = ["serviceId": serviceId]
        if validateOnly { params["validateOnly"] = "true" }

        let response: GoogleCloudAPIResponse<RunOperation> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services",
            body: service,
            queryParameters: params
        )
        return response.data
    }

    /// Update a Cloud Run service.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    ///   - service: The updated service configuration.
    ///   - allowMissing: If true, creates the service if it doesn't exist.
    /// - Returns: A long-running operation that can be polled for completion.
    public func updateService(
        location: String,
        serviceId: String,
        service: RunServiceRequest,
        allowMissing: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = [:]
        if allowMissing { params["allowMissing"] = "true" }

        let response: GoogleCloudAPIResponse<RunOperation> = try await client.patch(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services/\(serviceId)",
            body: service,
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Delete a Cloud Run service.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    ///   - validateOnly: If true, validates the request without deleting.
    /// - Returns: A long-running operation.
    public func deleteService(
        location: String,
        serviceId: String,
        validateOnly: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = [:]
        if validateOnly { params["validateOnly"] = "true" }

        let response: GoogleCloudAPIResponse<RunOperation> = try await client.delete(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services/\(serviceId)",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    // MARK: - Revisions

    /// List all revisions of a service.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    ///   - pageSize: Maximum number of revisions to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of revisions.
    public func listRevisions(
        location: String,
        serviceId: String,
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> RunRevisionListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<RunRevisionListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services/\(serviceId)/revisions",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a specific revision.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    ///   - revisionId: The revision ID.
    /// - Returns: The revision details.
    public func getRevision(
        location: String,
        serviceId: String,
        revisionId: String
    ) async throws -> RunRevision {
        let response: GoogleCloudAPIResponse<RunRevision> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services/\(serviceId)/revisions/\(revisionId)"
        )
        return response.data
    }

    /// Delete a revision.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - serviceId: The service ID.
    ///   - revisionId: The revision ID.
    /// - Returns: A long-running operation.
    public func deleteRevision(
        location: String,
        serviceId: String,
        revisionId: String
    ) async throws -> RunOperation {
        let response: GoogleCloudAPIResponse<RunOperation> = try await client.delete(
            path: "/v2/projects/\(_projectId)/locations/\(location)/services/\(serviceId)/revisions/\(revisionId)"
        )
        return response.data
    }

    // MARK: - Jobs

    /// List all Cloud Run jobs in a location.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - pageSize: Maximum number of jobs to return.
    ///   - pageToken: Token for pagination.
    ///   - showDeleted: Include jobs marked for deletion.
    /// - Returns: A list of jobs.
    public func listJobs(
        location: String,
        pageSize: Int? = nil,
        pageToken: String? = nil,
        showDeleted: Bool = false
    ) async throws -> RunJobListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }
        if showDeleted { params["showDeleted"] = "true" }

        let response: GoogleCloudAPIResponse<RunJobListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a pagination helper for listing all jobs in a location.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - pageSize: Maximum number of jobs per page.
    /// - Returns: A pagination helper.
    public func listAllJobs(
        location: String,
        pageSize: Int? = nil
    ) -> PaginationHelper<RunJob> {
        PaginationHelper { pageToken in
            let response = try await self.listJobs(
                location: location,
                pageSize: pageSize,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.jobs,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get a Cloud Run job.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    /// - Returns: The job details.
    public func getJob(location: String, jobId: String) async throws -> RunJob {
        let response: GoogleCloudAPIResponse<RunJob> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)"
        )
        return response.data
    }

    /// Create a new Cloud Run job.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - job: The job configuration.
    ///   - validateOnly: If true, validates the request without creating the job.
    /// - Returns: A long-running operation.
    public func createJob(
        location: String,
        jobId: String,
        job: RunJobRequest,
        validateOnly: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = ["jobId": jobId]
        if validateOnly { params["validateOnly"] = "true" }

        let response: GoogleCloudAPIResponse<RunOperation> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs",
            body: job,
            queryParameters: params
        )
        return response.data
    }

    /// Update a Cloud Run job.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - job: The updated job configuration.
    ///   - allowMissing: If true, creates the job if it doesn't exist.
    /// - Returns: A long-running operation.
    public func updateJob(
        location: String,
        jobId: String,
        job: RunJobRequest,
        allowMissing: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = [:]
        if allowMissing { params["allowMissing"] = "true" }

        let response: GoogleCloudAPIResponse<RunOperation> = try await client.patch(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)",
            body: job,
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Delete a Cloud Run job.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - validateOnly: If true, validates the request without deleting.
    /// - Returns: A long-running operation.
    public func deleteJob(
        location: String,
        jobId: String,
        validateOnly: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = [:]
        if validateOnly { params["validateOnly"] = "true" }

        let response: GoogleCloudAPIResponse<RunOperation> = try await client.delete(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Run a Cloud Run job (trigger an execution).
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - overrides: Optional overrides for this execution.
    ///   - validateOnly: If true, validates the request without running.
    /// - Returns: A long-running operation for the execution.
    public func runJob(
        location: String,
        jobId: String,
        overrides: RunJobOverrides? = nil,
        validateOnly: Bool = false
    ) async throws -> RunOperation {
        var params: [String: String] = [:]
        if validateOnly { params["validateOnly"] = "true" }

        let body = RunJobRunRequest(overrides: overrides)
        let response: GoogleCloudAPIResponse<RunOperation> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId):run",
            body: body,
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    // MARK: - Executions

    /// List all executions of a job.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - pageSize: Maximum number of executions to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of executions.
    public func listExecutions(
        location: String,
        jobId: String,
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> RunExecutionListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<RunExecutionListResponse> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)/executions",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a specific execution.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - executionId: The execution ID.
    /// - Returns: The execution details.
    public func getExecution(
        location: String,
        jobId: String,
        executionId: String
    ) async throws -> RunExecution {
        let response: GoogleCloudAPIResponse<RunExecution> = try await client.get(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)/executions/\(executionId)"
        )
        return response.data
    }

    /// Cancel an execution.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - executionId: The execution ID.
    /// - Returns: A long-running operation.
    public func cancelExecution(
        location: String,
        jobId: String,
        executionId: String
    ) async throws -> RunOperation {
        let response: GoogleCloudAPIResponse<RunOperation> = try await client.post(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)/executions/\(executionId):cancel",
            body: EmptyBody()
        )
        return response.data
    }

    /// Delete an execution.
    /// - Parameters:
    ///   - location: The region/location.
    ///   - jobId: The job ID.
    ///   - executionId: The execution ID.
    /// - Returns: A long-running operation.
    public func deleteExecution(
        location: String,
        jobId: String,
        executionId: String
    ) async throws -> RunOperation {
        let response: GoogleCloudAPIResponse<RunOperation> = try await client.delete(
            path: "/v2/projects/\(_projectId)/locations/\(location)/jobs/\(jobId)/executions/\(executionId)"
        )
        return response.data
    }

    // MARK: - Operations

    /// Get the status of a long-running operation.
    /// - Parameter operationName: The full operation name.
    /// - Returns: The operation status.
    public func getOperation(operationName: String) async throws -> RunOperation {
        let response: GoogleCloudAPIResponse<RunOperation> = try await client.get(
            path: "/v2/\(operationName)"
        )
        return response.data
    }

    /// Wait for an operation to complete.
    /// - Parameters:
    ///   - operation: The operation to wait for.
    ///   - timeout: Maximum time to wait in seconds.
    ///   - pollInterval: Interval between status checks in seconds.
    /// - Returns: The completed operation.
    public func waitForOperation(
        _ operation: RunOperation,
        timeout: TimeInterval = 300,
        pollInterval: TimeInterval = 5
    ) async throws -> RunOperation {
        guard let name = operation.name else {
            throw GoogleCloudAPIError.requestFailed("Operation has no name")
        }

        let startTime = Date()

        while true {
            try Task.checkCancellation()

            let op = try await getOperation(operationName: name)

            if op.done == true {
                if let error = op.error {
                    throw GoogleCloudAPIError.operationFailed(error.message ?? "Unknown error")
                }
                return op
            }

            if Date().timeIntervalSince(startTime) > timeout {
                throw GoogleCloudAPIError.timeout(timeout)
            }

            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
    }
}

// MARK: - Request Types

/// Request to create or update a Cloud Run service.
public struct RunServiceRequest: Encodable, Sendable {
    public let template: RunRevisionTemplate?
    public let traffic: [RunTrafficTarget]?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let ingress: String?
    public let launchStage: String?
    public let description: String?
    public let binaryAuthorization: RunBinaryAuthorization?

    public init(
        template: RunRevisionTemplate? = nil,
        traffic: [RunTrafficTarget]? = nil,
        labels: [String: String]? = nil,
        annotations: [String: String]? = nil,
        ingress: RunIngress? = nil,
        launchStage: String? = nil,
        description: String? = nil,
        binaryAuthorization: RunBinaryAuthorization? = nil
    ) {
        self.template = template
        self.traffic = traffic
        self.labels = labels
        self.annotations = annotations
        self.ingress = ingress?.rawValue
        self.launchStage = launchStage
        self.description = description
        self.binaryAuthorization = binaryAuthorization
    }
}

/// Request to create or update a Cloud Run job.
public struct RunJobRequest: Encodable, Sendable {
    public let template: RunExecutionTemplate?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let launchStage: String?

    public init(
        template: RunExecutionTemplate? = nil,
        labels: [String: String]? = nil,
        annotations: [String: String]? = nil,
        launchStage: String? = nil
    ) {
        self.template = template
        self.labels = labels
        self.annotations = annotations
        self.launchStage = launchStage
    }
}

/// Request to run a job.
struct RunJobRunRequest: Encodable, Sendable {
    let overrides: RunJobOverrides?
}

/// Overrides for a job execution.
public struct RunJobOverrides: Encodable, Sendable {
    public let containerOverrides: [RunContainerOverride]?
    public let taskCount: Int?
    public let timeout: String?

    public init(
        containerOverrides: [RunContainerOverride]? = nil,
        taskCount: Int? = nil,
        timeout: String? = nil
    ) {
        self.containerOverrides = containerOverrides
        self.taskCount = taskCount
        self.timeout = timeout
    }
}

/// Override for a container in a job execution.
public struct RunContainerOverride: Encodable, Sendable {
    public let name: String?
    public let args: [String]?
    public let env: [RunEnvVar]?
    public let clearArgs: Bool?

    public init(
        name: String? = nil,
        args: [String]? = nil,
        env: [RunEnvVar]? = nil,
        clearArgs: Bool? = nil
    ) {
        self.name = name
        self.args = args
        self.env = env
        self.clearArgs = clearArgs
    }
}

// MARK: - Response Types

/// List of services response.
public struct RunServiceListResponse: Codable, Sendable {
    public let services: [RunService]?
    public let nextPageToken: String?
}

/// Cloud Run service.
public struct RunService: Codable, Sendable {
    public let name: String?
    public let uid: String?
    public let generation: String?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let createTime: Date?
    public let updateTime: Date?
    public let deleteTime: Date?
    public let expireTime: Date?
    public let creator: String?
    public let lastModifier: String?
    public let ingress: String?
    public let launchStage: String?
    public let description: String?
    public let template: RunRevisionTemplate?
    public let traffic: [RunTrafficTarget]?
    public let observedGeneration: String?
    public let terminalCondition: RunCondition?
    public let conditions: [RunCondition]?
    public let latestReadyRevision: String?
    public let latestCreatedRevision: String?
    public let trafficStatuses: [RunTrafficTargetStatus]?
    public let uri: String?
    public let reconciling: Bool?
    public let etag: String?

    /// Extract the service ID from the full resource name.
    public var serviceId: String? {
        name?.components(separatedBy: "/").last
    }

    /// Check if the service is ready.
    public var isReady: Bool {
        terminalCondition?.state == "CONDITION_SUCCEEDED"
    }
}

/// Revision template.
public struct RunRevisionTemplate: Codable, Sendable {
    public let revision: String?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let scaling: RunRevisionScaling?
    public let vpcAccess: RunVpcAccess?
    public let timeout: String?
    public let serviceAccount: String?
    public let containers: [RunContainer]?
    public let volumes: [RunVolume]?
    public let executionEnvironment: String?
    public let encryptionKey: String?
    public let maxInstanceRequestConcurrency: Int?
    public let sessionAffinity: Bool?

    public init(
        revision: String? = nil,
        labels: [String: String]? = nil,
        annotations: [String: String]? = nil,
        scaling: RunRevisionScaling? = nil,
        vpcAccess: RunVpcAccess? = nil,
        timeout: String? = nil,
        serviceAccount: String? = nil,
        containers: [RunContainer]? = nil,
        volumes: [RunVolume]? = nil,
        executionEnvironment: String? = nil,
        encryptionKey: String? = nil,
        maxInstanceRequestConcurrency: Int? = nil,
        sessionAffinity: Bool? = nil
    ) {
        self.revision = revision
        self.labels = labels
        self.annotations = annotations
        self.scaling = scaling
        self.vpcAccess = vpcAccess
        self.timeout = timeout
        self.serviceAccount = serviceAccount
        self.containers = containers
        self.volumes = volumes
        self.executionEnvironment = executionEnvironment
        self.encryptionKey = encryptionKey
        self.maxInstanceRequestConcurrency = maxInstanceRequestConcurrency
        self.sessionAffinity = sessionAffinity
    }
}

/// Revision scaling configuration.
public struct RunRevisionScaling: Codable, Sendable {
    public let minInstanceCount: Int?
    public let maxInstanceCount: Int?

    public init(minInstanceCount: Int? = nil, maxInstanceCount: Int? = nil) {
        self.minInstanceCount = minInstanceCount
        self.maxInstanceCount = maxInstanceCount
    }
}

/// VPC access configuration.
public struct RunVpcAccess: Codable, Sendable {
    public let connector: String?
    public let egress: String?
    public let networkInterfaces: [RunNetworkInterface]?

    public init(
        connector: String? = nil,
        egress: String? = nil,
        networkInterfaces: [RunNetworkInterface]? = nil
    ) {
        self.connector = connector
        self.egress = egress
        self.networkInterfaces = networkInterfaces
    }
}

/// Network interface for direct VPC egress.
public struct RunNetworkInterface: Codable, Sendable {
    public let network: String?
    public let subnetwork: String?
    public let tags: [String]?

    public init(network: String? = nil, subnetwork: String? = nil, tags: [String]? = nil) {
        self.network = network
        self.subnetwork = subnetwork
        self.tags = tags
    }
}

/// Container configuration.
public struct RunContainer: Codable, Sendable {
    public let name: String?
    public let image: String?
    public let command: [String]?
    public let args: [String]?
    public let env: [RunEnvVar]?
    public let resources: RunResourceRequirements?
    public let ports: [RunContainerPort]?
    public let volumeMounts: [RunVolumeMount]?
    public let workingDir: String?
    public let livenessProbe: RunProbe?
    public let startupProbe: RunProbe?
    public let dependsOn: [String]?

    public init(
        name: String? = nil,
        image: String? = nil,
        command: [String]? = nil,
        args: [String]? = nil,
        env: [RunEnvVar]? = nil,
        resources: RunResourceRequirements? = nil,
        ports: [RunContainerPort]? = nil,
        volumeMounts: [RunVolumeMount]? = nil,
        workingDir: String? = nil,
        livenessProbe: RunProbe? = nil,
        startupProbe: RunProbe? = nil,
        dependsOn: [String]? = nil
    ) {
        self.name = name
        self.image = image
        self.command = command
        self.args = args
        self.env = env
        self.resources = resources
        self.ports = ports
        self.volumeMounts = volumeMounts
        self.workingDir = workingDir
        self.livenessProbe = livenessProbe
        self.startupProbe = startupProbe
        self.dependsOn = dependsOn
    }
}

/// Environment variable.
public struct RunEnvVar: Codable, Sendable {
    public let name: String?
    public let value: String?
    public let valueSource: RunEnvVarSource?

    public init(name: String? = nil, value: String? = nil, valueSource: RunEnvVarSource? = nil) {
        self.name = name
        self.value = value
        self.valueSource = valueSource
    }

    /// Create an environment variable with a direct value.
    public static func value(_ name: String, _ value: String) -> RunEnvVar {
        RunEnvVar(name: name, value: value)
    }

    /// Create an environment variable from a secret.
    public static func secret(_ name: String, secretName: String, version: String = "latest") -> RunEnvVar {
        RunEnvVar(
            name: name,
            valueSource: RunEnvVarSource(
                secretKeyRef: RunSecretKeySelector(secret: secretName, version: version)
            )
        )
    }
}

/// Environment variable source.
public struct RunEnvVarSource: Codable, Sendable {
    public let secretKeyRef: RunSecretKeySelector?

    public init(secretKeyRef: RunSecretKeySelector? = nil) {
        self.secretKeyRef = secretKeyRef
    }
}

/// Secret key selector.
public struct RunSecretKeySelector: Codable, Sendable {
    public let secret: String?
    public let version: String?

    public init(secret: String? = nil, version: String? = nil) {
        self.secret = secret
        self.version = version
    }
}

/// Resource requirements.
public struct RunResourceRequirements: Codable, Sendable {
    public let limits: [String: String]?
    public let cpuIdle: Bool?
    public let startupCpuBoost: Bool?

    public init(
        limits: [String: String]? = nil,
        cpuIdle: Bool? = nil,
        startupCpuBoost: Bool? = nil
    ) {
        self.limits = limits
        self.cpuIdle = cpuIdle
        self.startupCpuBoost = startupCpuBoost
    }

    /// Create resource requirements with CPU and memory limits.
    public static func resources(cpu: String, memory: String, cpuIdle: Bool = true) -> RunResourceRequirements {
        RunResourceRequirements(
            limits: ["cpu": cpu, "memory": memory],
            cpuIdle: cpuIdle
        )
    }
}

/// Container port.
public struct RunContainerPort: Codable, Sendable {
    public let name: String?
    public let containerPort: Int?

    public init(name: String? = nil, containerPort: Int? = nil) {
        self.name = name
        self.containerPort = containerPort
    }
}

/// Volume mount.
public struct RunVolumeMount: Codable, Sendable {
    public let name: String?
    public let mountPath: String?

    public init(name: String? = nil, mountPath: String? = nil) {
        self.name = name
        self.mountPath = mountPath
    }
}

/// Volume configuration.
public struct RunVolume: Codable, Sendable {
    public let name: String?
    public let secret: RunSecretVolumeSource?
    public let cloudSqlInstance: RunCloudSqlInstance?
    public let emptyDir: RunEmptyDirVolumeSource?

    public init(
        name: String? = nil,
        secret: RunSecretVolumeSource? = nil,
        cloudSqlInstance: RunCloudSqlInstance? = nil,
        emptyDir: RunEmptyDirVolumeSource? = nil
    ) {
        self.name = name
        self.secret = secret
        self.cloudSqlInstance = cloudSqlInstance
        self.emptyDir = emptyDir
    }
}

/// Secret volume source.
public struct RunSecretVolumeSource: Codable, Sendable {
    public let secret: String?
    public let items: [RunVersionToPath]?
    public let defaultMode: Int?

    public init(secret: String? = nil, items: [RunVersionToPath]? = nil, defaultMode: Int? = nil) {
        self.secret = secret
        self.items = items
        self.defaultMode = defaultMode
    }
}

/// Version to path mapping.
public struct RunVersionToPath: Codable, Sendable {
    public let path: String?
    public let version: String?
    public let mode: Int?

    public init(path: String? = nil, version: String? = nil, mode: Int? = nil) {
        self.path = path
        self.version = version
        self.mode = mode
    }
}

/// Cloud SQL instance configuration.
public struct RunCloudSqlInstance: Codable, Sendable {
    public let instances: [String]?

    public init(instances: [String]? = nil) {
        self.instances = instances
    }
}

/// Empty directory volume source.
public struct RunEmptyDirVolumeSource: Codable, Sendable {
    public let medium: String?
    public let sizeLimit: String?

    public init(medium: String? = nil, sizeLimit: String? = nil) {
        self.medium = medium
        self.sizeLimit = sizeLimit
    }
}

/// Probe configuration.
public struct RunProbe: Codable, Sendable {
    public let initialDelaySeconds: Int?
    public let timeoutSeconds: Int?
    public let periodSeconds: Int?
    public let failureThreshold: Int?
    public let httpGet: RunHTTPGetAction?
    public let tcpSocket: RunTCPSocketAction?
    public let grpc: RunGRPCAction?

    public init(
        initialDelaySeconds: Int? = nil,
        timeoutSeconds: Int? = nil,
        periodSeconds: Int? = nil,
        failureThreshold: Int? = nil,
        httpGet: RunHTTPGetAction? = nil,
        tcpSocket: RunTCPSocketAction? = nil,
        grpc: RunGRPCAction? = nil
    ) {
        self.initialDelaySeconds = initialDelaySeconds
        self.timeoutSeconds = timeoutSeconds
        self.periodSeconds = periodSeconds
        self.failureThreshold = failureThreshold
        self.httpGet = httpGet
        self.tcpSocket = tcpSocket
        self.grpc = grpc
    }
}

/// HTTP GET action for probes.
public struct RunHTTPGetAction: Codable, Sendable {
    public let path: String?
    public let httpHeaders: [RunHTTPHeader]?
    public let port: Int?

    public init(path: String? = nil, httpHeaders: [RunHTTPHeader]? = nil, port: Int? = nil) {
        self.path = path
        self.httpHeaders = httpHeaders
        self.port = port
    }
}

/// HTTP header.
public struct RunHTTPHeader: Codable, Sendable {
    public let name: String?
    public let value: String?

    public init(name: String? = nil, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

/// TCP socket action for probes.
public struct RunTCPSocketAction: Codable, Sendable {
    public let port: Int?

    public init(port: Int? = nil) {
        self.port = port
    }
}

/// gRPC action for probes.
public struct RunGRPCAction: Codable, Sendable {
    public let port: Int?
    public let service: String?

    public init(port: Int? = nil, service: String? = nil) {
        self.port = port
        self.service = service
    }
}

/// Traffic target.
public struct RunTrafficTarget: Codable, Sendable {
    public let type: String?
    public let revision: String?
    public let percent: Int?
    public let tag: String?

    public init(type: String? = nil, revision: String? = nil, percent: Int? = nil, tag: String? = nil) {
        self.type = type
        self.revision = revision
        self.percent = percent
        self.tag = tag
    }

    /// Create a traffic target for the latest revision.
    public static func latest(percent: Int) -> RunTrafficTarget {
        RunTrafficTarget(type: "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", percent: percent)
    }

    /// Create a traffic target for a specific revision.
    public static func revision(_ name: String, percent: Int) -> RunTrafficTarget {
        RunTrafficTarget(type: "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION", revision: name, percent: percent)
    }
}

/// Traffic target status.
public struct RunTrafficTargetStatus: Codable, Sendable {
    public let type: String?
    public let revision: String?
    public let percent: Int?
    public let tag: String?
    public let uri: String?
}

/// Condition status.
public struct RunCondition: Codable, Sendable {
    public let type: String?
    public let state: String?
    public let message: String?
    public let lastTransitionTime: Date?
    public let severity: String?
    public let reason: String?
    public let revisionReason: String?
    public let executionReason: String?
}

/// Binary authorization configuration.
public struct RunBinaryAuthorization: Codable, Sendable {
    public let useDefault: Bool?
    public let policy: String?
    public let breakglassJustification: String?

    public init(useDefault: Bool? = nil, policy: String? = nil, breakglassJustification: String? = nil) {
        self.useDefault = useDefault
        self.policy = policy
        self.breakglassJustification = breakglassJustification
    }
}

/// List of revisions response.
public struct RunRevisionListResponse: Codable, Sendable {
    public let revisions: [RunRevision]?
    public let nextPageToken: String?
}

/// Cloud Run revision.
public struct RunRevision: Codable, Sendable {
    public let name: String?
    public let uid: String?
    public let generation: String?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let createTime: Date?
    public let updateTime: Date?
    public let deleteTime: Date?
    public let expireTime: Date?
    public let launchStage: String?
    public let service: String?
    public let scaling: RunRevisionScaling?
    public let vpcAccess: RunVpcAccess?
    public let maxInstanceRequestConcurrency: Int?
    public let timeout: String?
    public let serviceAccount: String?
    public let containers: [RunContainer]?
    public let volumes: [RunVolume]?
    public let executionEnvironment: String?
    public let encryptionKey: String?
    public let reconciling: Bool?
    public let conditions: [RunCondition]?
    public let observedGeneration: String?
    public let logUri: String?
    public let etag: String?

    /// Extract the revision ID from the full resource name.
    public var revisionId: String? {
        name?.components(separatedBy: "/").last
    }
}

/// List of jobs response.
public struct RunJobListResponse: Codable, Sendable {
    public let jobs: [RunJob]?
    public let nextPageToken: String?
}

/// Cloud Run job.
public struct RunJob: Codable, Sendable {
    public let name: String?
    public let uid: String?
    public let generation: String?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let createTime: Date?
    public let updateTime: Date?
    public let deleteTime: Date?
    public let expireTime: Date?
    public let creator: String?
    public let lastModifier: String?
    public let launchStage: String?
    public let template: RunExecutionTemplate?
    public let observedGeneration: String?
    public let terminalCondition: RunCondition?
    public let conditions: [RunCondition]?
    public let executionCount: Int?
    public let latestCreatedExecution: RunExecutionReference?
    public let reconciling: Bool?
    public let etag: String?

    /// Extract the job ID from the full resource name.
    public var jobId: String? {
        name?.components(separatedBy: "/").last
    }
}

/// Execution template.
public struct RunExecutionTemplate: Codable, Sendable {
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let parallelism: Int?
    public let taskCount: Int?
    public let template: RunTaskTemplate?

    public init(
        labels: [String: String]? = nil,
        annotations: [String: String]? = nil,
        parallelism: Int? = nil,
        taskCount: Int? = nil,
        template: RunTaskTemplate? = nil
    ) {
        self.labels = labels
        self.annotations = annotations
        self.parallelism = parallelism
        self.taskCount = taskCount
        self.template = template
    }
}

/// Task template.
public struct RunTaskTemplate: Codable, Sendable {
    public let containers: [RunContainer]?
    public let volumes: [RunVolume]?
    public let maxRetries: Int?
    public let timeout: String?
    public let serviceAccount: String?
    public let executionEnvironment: String?
    public let encryptionKey: String?
    public let vpcAccess: RunVpcAccess?

    public init(
        containers: [RunContainer]? = nil,
        volumes: [RunVolume]? = nil,
        maxRetries: Int? = nil,
        timeout: String? = nil,
        serviceAccount: String? = nil,
        executionEnvironment: String? = nil,
        encryptionKey: String? = nil,
        vpcAccess: RunVpcAccess? = nil
    ) {
        self.containers = containers
        self.volumes = volumes
        self.maxRetries = maxRetries
        self.timeout = timeout
        self.serviceAccount = serviceAccount
        self.executionEnvironment = executionEnvironment
        self.encryptionKey = encryptionKey
        self.vpcAccess = vpcAccess
    }
}

/// Execution reference.
public struct RunExecutionReference: Codable, Sendable {
    public let name: String?
    public let createTime: Date?
    public let completionTime: Date?
}

/// List of executions response.
public struct RunExecutionListResponse: Codable, Sendable {
    public let executions: [RunExecution]?
    public let nextPageToken: String?
}

/// Cloud Run execution.
public struct RunExecution: Codable, Sendable {
    public let name: String?
    public let uid: String?
    public let generation: String?
    public let labels: [String: String]?
    public let annotations: [String: String]?
    public let createTime: Date?
    public let startTime: Date?
    public let completionTime: Date?
    public let deleteTime: Date?
    public let expireTime: Date?
    public let launchStage: String?
    public let job: String?
    public let parallelism: Int?
    public let taskCount: Int?
    public let template: RunTaskTemplate?
    public let reconciling: Bool?
    public let conditions: [RunCondition]?
    public let observedGeneration: String?
    public let runningCount: Int?
    public let succeededCount: Int?
    public let failedCount: Int?
    public let cancelledCount: Int?
    public let retriedCount: Int?
    public let logUri: String?
    public let etag: String?

    /// Extract the execution ID from the full resource name.
    public var executionId: String? {
        name?.components(separatedBy: "/").last
    }

    /// Check if the execution is complete.
    public var isComplete: Bool {
        completionTime != nil
    }

    /// Check if the execution succeeded.
    public var succeeded: Bool {
        guard let total = taskCount else { return false }
        return succeededCount == total
    }
}

/// Cloud Run operation (long-running).
public struct RunOperation: Codable, Sendable {
    public let name: String?
    public let metadata: RunOperationMetadata?
    public let done: Bool?
    public let error: RunOperationError?
    public let response: [String: AnyCodable]?
}

/// Operation metadata.
public struct RunOperationMetadata: Codable, Sendable {
    public let createTime: Date?
    public let endTime: Date?
    public let target: String?
    public let verb: String?
    public let statusDetail: String?
    public let cancelRequested: Bool?
    public let apiVersion: String?

    enum CodingKeys: String, CodingKey {
        case createTime
        case endTime
        case target
        case verb
        case statusDetail
        case cancelRequested
        case apiVersion
    }
}

/// Operation error.
public struct RunOperationError: Codable, Sendable {
    public let code: Int?
    public let message: String?
    public let details: [[String: AnyCodable]]?
}

/// Ingress settings.
public enum RunIngress: String, Sendable {
    /// All traffic is allowed.
    case all = "INGRESS_TRAFFIC_ALL"
    /// Only internal traffic is allowed.
    case internalOnly = "INGRESS_TRAFFIC_INTERNAL_ONLY"
    /// Internal and Cloud Load Balancing traffic is allowed.
    case internalLoadBalancer = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

/// Helper for dynamic JSON values in responses.
public struct AnyCodable: Codable, @unchecked Sendable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode value"))
        }
    }
}
