//
//  GoogleCloudRunAPITests.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Mock Cloud Run API

/// Mock implementation of GoogleCloudRunAPIProtocol for testing.
actor MockRunAPI: GoogleCloudRunAPIProtocol {
    let projectId: String

    // Stubs for each method
    var listServicesHandler: ((String, Int?, String?, Bool) async throws -> RunServiceListResponse)?
    var getServiceHandler: ((String, String) async throws -> RunService)?
    var createServiceHandler: ((String, String, RunServiceRequest, Bool) async throws -> RunOperation)?
    var updateServiceHandler: ((String, String, RunServiceRequest, Bool) async throws -> RunOperation)?
    var deleteServiceHandler: ((String, String, Bool) async throws -> RunOperation)?
    var listJobsHandler: ((String, Int?, String?, Bool) async throws -> RunJobListResponse)?
    var getJobHandler: ((String, String) async throws -> RunJob)?
    var createJobHandler: ((String, String, RunJobRequest, Bool) async throws -> RunOperation)?
    var runJobHandler: ((String, String, RunJobOverrides?, Bool) async throws -> RunOperation)?
    var deleteJobHandler: ((String, String, Bool) async throws -> RunOperation)?
    var waitForOperationHandler: ((RunOperation, TimeInterval, TimeInterval) async throws -> RunOperation)?

    // Call tracking
    var listServicesCalls: [(location: String, pageSize: Int?, pageToken: String?, showDeleted: Bool)] = []
    var getServiceCalls: [(location: String, serviceId: String)] = []
    var createServiceCalls: [(location: String, serviceId: String, service: RunServiceRequest, validateOnly: Bool)] = []
    var updateServiceCalls: [(location: String, serviceId: String, service: RunServiceRequest, allowMissing: Bool)] = []
    var deleteServiceCalls: [(location: String, serviceId: String, validateOnly: Bool)] = []
    var listJobsCalls: [(location: String, pageSize: Int?, pageToken: String?, showDeleted: Bool)] = []
    var getJobCalls: [(location: String, jobId: String)] = []
    var createJobCalls: [(location: String, jobId: String, job: RunJobRequest, validateOnly: Bool)] = []
    var runJobCalls: [(location: String, jobId: String, overrides: RunJobOverrides?, validateOnly: Bool)] = []
    var deleteJobCalls: [(location: String, jobId: String, validateOnly: Bool)] = []
    var waitForOperationCalls: [RunOperation] = []

    init(projectId: String = "test-project") {
        self.projectId = projectId
    }

    func listServices(location: String, pageSize: Int?, pageToken: String?, showDeleted: Bool) async throws -> RunServiceListResponse {
        listServicesCalls.append((location, pageSize, pageToken, showDeleted))
        if let handler = listServicesHandler {
            return try await handler(location, pageSize, pageToken, showDeleted)
        }
        return RunServiceListResponse(services: [], nextPageToken: nil)
    }

    func getService(location: String, serviceId: String) async throws -> RunService {
        getServiceCalls.append((location, serviceId))
        if let handler = getServiceHandler {
            return try await handler(location, serviceId)
        }
        return createMockService(serviceId: serviceId, location: location)
    }

    func createService(location: String, serviceId: String, service: RunServiceRequest, validateOnly: Bool) async throws -> RunOperation {
        createServiceCalls.append((location, serviceId, service, validateOnly))
        if let handler = createServiceHandler {
            return try await handler(location, serviceId, service, validateOnly)
        }
        return createMockOperation(name: "create-service-\(serviceId)")
    }

    func updateService(location: String, serviceId: String, service: RunServiceRequest, allowMissing: Bool) async throws -> RunOperation {
        updateServiceCalls.append((location, serviceId, service, allowMissing))
        if let handler = updateServiceHandler {
            return try await handler(location, serviceId, service, allowMissing)
        }
        return createMockOperation(name: "update-service-\(serviceId)")
    }

    func deleteService(location: String, serviceId: String, validateOnly: Bool) async throws -> RunOperation {
        deleteServiceCalls.append((location, serviceId, validateOnly))
        if let handler = deleteServiceHandler {
            return try await handler(location, serviceId, validateOnly)
        }
        return createMockOperation(name: "delete-service-\(serviceId)")
    }

    func listJobs(location: String, pageSize: Int?, pageToken: String?, showDeleted: Bool) async throws -> RunJobListResponse {
        listJobsCalls.append((location, pageSize, pageToken, showDeleted))
        if let handler = listJobsHandler {
            return try await handler(location, pageSize, pageToken, showDeleted)
        }
        return RunJobListResponse(jobs: [], nextPageToken: nil)
    }

    func getJob(location: String, jobId: String) async throws -> RunJob {
        getJobCalls.append((location, jobId))
        if let handler = getJobHandler {
            return try await handler(location, jobId)
        }
        return createMockJob(jobId: jobId, location: location)
    }

    func createJob(location: String, jobId: String, job: RunJobRequest, validateOnly: Bool) async throws -> RunOperation {
        createJobCalls.append((location, jobId, job, validateOnly))
        if let handler = createJobHandler {
            return try await handler(location, jobId, job, validateOnly)
        }
        return createMockOperation(name: "create-job-\(jobId)")
    }

    func runJob(location: String, jobId: String, overrides: RunJobOverrides?, validateOnly: Bool) async throws -> RunOperation {
        runJobCalls.append((location, jobId, overrides, validateOnly))
        if let handler = runJobHandler {
            return try await handler(location, jobId, overrides, validateOnly)
        }
        return createMockOperation(name: "run-job-\(jobId)")
    }

    func deleteJob(location: String, jobId: String, validateOnly: Bool) async throws -> RunOperation {
        deleteJobCalls.append((location, jobId, validateOnly))
        if let handler = deleteJobHandler {
            return try await handler(location, jobId, validateOnly)
        }
        return createMockOperation(name: "delete-job-\(jobId)")
    }

    func waitForOperation(_ operation: RunOperation, timeout: TimeInterval, pollInterval: TimeInterval) async throws -> RunOperation {
        waitForOperationCalls.append(operation)
        if let handler = waitForOperationHandler {
            return try await handler(operation, timeout, pollInterval)
        }
        return RunOperation(name: operation.name, metadata: nil, done: true, error: nil, response: nil)
    }

    // MARK: - Mock Data Helpers

    private func createMockService(serviceId: String, location: String) -> RunService {
        RunService(
            name: "projects/\(projectId)/locations/\(location)/services/\(serviceId)",
            uid: "service-uid-123",
            generation: "1",
            labels: nil,
            annotations: nil,
            createTime: Date(),
            updateTime: Date(),
            deleteTime: nil,
            expireTime: nil,
            creator: "test@example.com",
            lastModifier: "test@example.com",
            ingress: "INGRESS_TRAFFIC_ALL",
            launchStage: "GA",
            description: nil,
            template: nil,
            traffic: nil,
            observedGeneration: "1",
            terminalCondition: RunCondition(
                type: "Ready",
                state: "CONDITION_SUCCEEDED",
                message: nil,
                lastTransitionTime: Date(),
                severity: nil,
                reason: nil,
                revisionReason: nil,
                executionReason: nil
            ),
            conditions: nil,
            latestReadyRevision: "projects/\(projectId)/locations/\(location)/services/\(serviceId)/revisions/\(serviceId)-00001",
            latestCreatedRevision: "projects/\(projectId)/locations/\(location)/services/\(serviceId)/revisions/\(serviceId)-00001",
            trafficStatuses: nil,
            uri: "https://\(serviceId)-abc123.run.app",
            reconciling: false,
            etag: "CAE="
        )
    }

    private func createMockJob(jobId: String, location: String) -> RunJob {
        RunJob(
            name: "projects/\(projectId)/locations/\(location)/jobs/\(jobId)",
            uid: "job-uid-123",
            generation: "1",
            labels: nil,
            annotations: nil,
            createTime: Date(),
            updateTime: Date(),
            deleteTime: nil,
            expireTime: nil,
            creator: "test@example.com",
            lastModifier: "test@example.com",
            launchStage: "GA",
            template: nil,
            observedGeneration: "1",
            terminalCondition: nil,
            conditions: nil,
            executionCount: 5,
            latestCreatedExecution: nil,
            reconciling: false,
            etag: "CAE="
        )
    }

    private func createMockOperation(name: String, done: Bool = false) -> RunOperation {
        RunOperation(
            name: "projects/\(projectId)/locations/us-central1/operations/\(name)",
            metadata: RunOperationMetadata(
                createTime: Date(),
                endTime: nil,
                target: nil,
                verb: "create",
                statusDetail: nil,
                cancelRequested: false,
                apiVersion: "v2"
            ),
            done: done,
            error: nil,
            response: nil
        )
    }
}

// MARK: - Protocol Conformance Tests

@Test func testRunAPIProtocolConformance() {
    func acceptsProtocol<T: GoogleCloudRunAPIProtocol>(_ api: T) {}

    let mock = MockRunAPI()
    acceptsProtocol(mock)
}

// MARK: - Mock Cloud Run API Tests

@Test func testMockRunAPIProjectId() async {
    let mock = MockRunAPI(projectId: "my-run-project")
    let projectId = await mock.projectId
    #expect(projectId == "my-run-project")
}

@Test func testMockListServicesDefault() async throws {
    let mock = MockRunAPI()
    let result = try await mock.listServices(location: "us-central1", pageSize: nil, pageToken: nil, showDeleted: false)

    #expect(result.services?.isEmpty != false)
    #expect(result.nextPageToken == nil)

    let calls = await mock.listServicesCalls
    #expect(calls.count == 1)
    #expect(calls.first?.location == "us-central1")
}

@Test func testMockListServicesWithHandler() async throws {
    let mock = MockRunAPI()

    await mock.setListServicesHandler { location, pageSize, pageToken, showDeleted in
        let service = RunService(
            name: "projects/test-project/locations/\(location)/services/my-api",
            uid: nil,
            generation: nil,
            labels: ["env": "prod"],
            annotations: nil,
            createTime: nil,
            updateTime: nil,
            deleteTime: nil,
            expireTime: nil,
            creator: nil,
            lastModifier: nil,
            ingress: nil,
            launchStage: nil,
            description: nil,
            template: nil,
            traffic: nil,
            observedGeneration: nil,
            terminalCondition: nil,
            conditions: nil,
            latestReadyRevision: nil,
            latestCreatedRevision: nil,
            trafficStatuses: nil,
            uri: "https://my-api.run.app",
            reconciling: nil,
            etag: nil
        )
        return RunServiceListResponse(services: [service], nextPageToken: "page2")
    }

    let result = try await mock.listServices(location: "us-west1", pageSize: 10, pageToken: nil, showDeleted: false)

    #expect(result.services?.count == 1)
    #expect(result.services?.first?.serviceId == "my-api")
    #expect(result.nextPageToken == "page2")

    let calls = await mock.listServicesCalls
    #expect(calls.first?.pageSize == 10)
}

@Test func testMockGetService() async throws {
    let mock = MockRunAPI()
    let service = try await mock.getService(location: "us-central1", serviceId: "my-api")

    #expect(service.serviceId == "my-api")
    #expect(service.isReady)
    #expect(service.uri?.contains("my-api") == true)

    let calls = await mock.getServiceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.serviceId == "my-api")
}

@Test func testMockCreateService() async throws {
    let mock = MockRunAPI()
    let request = RunServiceRequest(
        template: RunRevisionTemplate(
            containers: [RunContainer(image: "gcr.io/my-project/my-image:latest")]
        )
    )

    let operation = try await mock.createService(
        location: "us-central1",
        serviceId: "new-service",
        service: request,
        validateOnly: false
    )

    #expect(operation.name?.contains("new-service") == true)

    let calls = await mock.createServiceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.serviceId == "new-service")
    #expect(calls.first?.validateOnly == false)
}

@Test func testMockDeleteService() async throws {
    let mock = MockRunAPI()

    let operation = try await mock.deleteService(
        location: "us-central1",
        serviceId: "old-service",
        validateOnly: false
    )

    #expect(operation.name?.contains("old-service") == true)

    let calls = await mock.deleteServiceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.serviceId == "old-service")
}

@Test func testMockListJobs() async throws {
    let mock = MockRunAPI()

    await mock.setListJobsHandler { location, pageSize, pageToken, showDeleted in
        let job = RunJob(
            name: "projects/test-project/locations/\(location)/jobs/batch-job",
            uid: nil,
            generation: nil,
            labels: nil,
            annotations: nil,
            createTime: nil,
            updateTime: nil,
            deleteTime: nil,
            expireTime: nil,
            creator: nil,
            lastModifier: nil,
            launchStage: nil,
            template: nil,
            observedGeneration: nil,
            terminalCondition: nil,
            conditions: nil,
            executionCount: 10,
            latestCreatedExecution: nil,
            reconciling: nil,
            etag: nil
        )
        return RunJobListResponse(jobs: [job], nextPageToken: nil)
    }

    let result = try await mock.listJobs(location: "us-central1", pageSize: nil, pageToken: nil, showDeleted: false)

    #expect(result.jobs?.count == 1)
    #expect(result.jobs?.first?.jobId == "batch-job")
    #expect(result.jobs?.first?.executionCount == 10)
}

@Test func testMockGetJob() async throws {
    let mock = MockRunAPI()
    let job = try await mock.getJob(location: "us-central1", jobId: "my-batch-job")

    #expect(job.jobId == "my-batch-job")
    #expect(job.executionCount == 5)

    let calls = await mock.getJobCalls
    #expect(calls.count == 1)
    #expect(calls.first?.jobId == "my-batch-job")
}

@Test func testMockRunJob() async throws {
    let mock = MockRunAPI()

    let operation = try await mock.runJob(
        location: "us-central1",
        jobId: "my-job",
        overrides: RunJobOverrides(taskCount: 5),
        validateOnly: false
    )

    #expect(operation.name?.contains("my-job") == true)

    let calls = await mock.runJobCalls
    #expect(calls.count == 1)
    #expect(calls.first?.jobId == "my-job")
    #expect(calls.first?.overrides?.taskCount == 5)
}

@Test func testMockWaitForOperation() async throws {
    let mock = MockRunAPI()
    let op = RunOperation(name: "test-op", metadata: nil, done: false, error: nil, response: nil)

    let result = try await mock.waitForOperation(op, timeout: 60, pollInterval: 1)

    #expect(result.done == true)

    let calls = await mock.waitForOperationCalls
    #expect(calls.count == 1)
}

@Test func testMockRunAPIErrorHandling() async {
    let mock = MockRunAPI()

    await mock.setGetServiceHandler { location, serviceId in
        throw GoogleCloudAPIError.httpError(404, nil)
    }

    do {
        _ = try await mock.getService(location: "us-central1", serviceId: "nonexistent")
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAPIError {
        if case .httpError(let code, _) = error {
            #expect(code == 404)
        } else {
            #expect(Bool(false), "Wrong error case")
        }
    } catch {
        #expect(Bool(false), "Wrong error type: \(error)")
    }
}

// MARK: - Request Type Tests

@Test func testRunServiceRequestEncoding() throws {
    let request = RunServiceRequest(
        template: RunRevisionTemplate(
            scaling: RunRevisionScaling(minInstanceCount: 1, maxInstanceCount: 10),
            containers: [
                RunContainer(
                    name: "main",
                    image: "gcr.io/my-project/my-image:v1",
                    env: [
                        RunEnvVar.value("PORT", "8080"),
                        RunEnvVar.secret("API_KEY", secretName: "my-secret")
                    ],
                    resources: RunResourceRequirements.resources(cpu: "1", memory: "512Mi"),
                    ports: [RunContainerPort(name: "http1", containerPort: 8080)]
                )
            ]
        ),
        traffic: [RunTrafficTarget.latest(percent: 100)],
        labels: ["app": "my-app"],
        ingress: .all
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["ingress"] as? String == "INGRESS_TRAFFIC_ALL")
    #expect((json?["labels"] as? [String: String])?["app"] == "my-app")

    let template = json?["template"] as? [String: Any]
    let scaling = template?["scaling"] as? [String: Any]
    #expect(scaling?["minInstanceCount"] as? Int == 1)
    #expect(scaling?["maxInstanceCount"] as? Int == 10)

    let traffic = json?["traffic"] as? [[String: Any]]
    #expect(traffic?.first?["percent"] as? Int == 100)
}

@Test func testRunJobRequestEncoding() throws {
    let request = RunJobRequest(
        template: RunExecutionTemplate(
            parallelism: 3,
            taskCount: 10,
            template: RunTaskTemplate(
                containers: [RunContainer(image: "gcr.io/my-project/batch:latest")],
                maxRetries: 3,
                timeout: "3600s"
            )
        ),
        labels: ["type": "batch"]
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    let template = json?["template"] as? [String: Any]
    #expect(template?["parallelism"] as? Int == 3)
    #expect(template?["taskCount"] as? Int == 10)
}

@Test func testRunJobOverridesEncoding() throws {
    let overrides = RunJobOverrides(
        containerOverrides: [
            RunContainerOverride(name: "main", args: ["--verbose"], env: [RunEnvVar.value("DEBUG", "true")])
        ],
        taskCount: 5,
        timeout: "1800s"
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(overrides)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["taskCount"] as? Int == 5)
    #expect(json?["timeout"] as? String == "1800s")

    let containerOverrides = json?["containerOverrides"] as? [[String: Any]]
    #expect(containerOverrides?.first?["name"] as? String == "main")
}

// MARK: - Response Type Tests

@Test func testRunServiceDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/services/my-api",
        "uid": "abc123",
        "generation": "5",
        "labels": {"env": "production"},
        "createTime": "2024-01-15T10:30:00.000Z",
        "updateTime": "2024-01-15T11:00:00.000Z",
        "creator": "user@example.com",
        "ingress": "INGRESS_TRAFFIC_ALL",
        "launchStage": "GA",
        "terminalCondition": {
            "type": "Ready",
            "state": "CONDITION_SUCCEEDED"
        },
        "latestReadyRevision": "projects/my-project/locations/us-central1/services/my-api/revisions/my-api-00005",
        "uri": "https://my-api-abc123.a.run.app",
        "reconciling": false,
        "etag": "CAE="
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let service = try decoder.decode(RunService.self, from: Data(json.utf8))

    #expect(service.serviceId == "my-api")
    #expect(service.isReady)
    #expect(service.labels?["env"] == "production")
    #expect(service.uri == "https://my-api-abc123.a.run.app")
    #expect(service.generation == "5")
}

@Test func testRunJobDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/jobs/batch-processor",
        "uid": "job-abc123",
        "generation": "3",
        "createTime": "2024-01-15T10:30:00.000Z",
        "executionCount": 42,
        "latestCreatedExecution": {
            "name": "projects/my-project/locations/us-central1/jobs/batch-processor/executions/exec-001",
            "createTime": "2024-01-15T12:00:00.000Z"
        }
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let job = try decoder.decode(RunJob.self, from: Data(json.utf8))

    #expect(job.jobId == "batch-processor")
    #expect(job.executionCount == 42)
    #expect(job.latestCreatedExecution?.name?.contains("exec-001") == true)
}

@Test func testRunExecutionDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/jobs/batch/executions/exec-123",
        "uid": "exec-uid",
        "createTime": "2024-01-15T10:30:00.000Z",
        "startTime": "2024-01-15T10:30:05.000Z",
        "completionTime": "2024-01-15T10:45:00.000Z",
        "parallelism": 3,
        "taskCount": 10,
        "runningCount": 0,
        "succeededCount": 10,
        "failedCount": 0
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let execution = try decoder.decode(RunExecution.self, from: Data(json.utf8))

    #expect(execution.executionId == "exec-123")
    #expect(execution.isComplete)
    #expect(execution.succeeded)
    #expect(execution.taskCount == 10)
    #expect(execution.succeededCount == 10)
}

@Test func testRunRevisionDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/services/my-api/revisions/my-api-00001",
        "uid": "rev-abc",
        "generation": "1",
        "service": "projects/my-project/locations/us-central1/services/my-api",
        "scaling": {
            "minInstanceCount": 0,
            "maxInstanceCount": 100
        },
        "maxInstanceRequestConcurrency": 80,
        "timeout": "300s"
    }
    """

    let decoder = JSONDecoder()
    let revision = try decoder.decode(RunRevision.self, from: Data(json.utf8))

    #expect(revision.revisionId == "my-api-00001")
    #expect(revision.scaling?.minInstanceCount == 0)
    #expect(revision.scaling?.maxInstanceCount == 100)
    #expect(revision.maxInstanceRequestConcurrency == 80)
    #expect(revision.timeout == "300s")
}

@Test func testRunOperationDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/operations/op-12345",
        "metadata": {
            "createTime": "2024-01-15T10:30:00.000Z",
            "verb": "create",
            "apiVersion": "v2"
        },
        "done": true,
        "response": {
            "@type": "type.googleapis.com/google.cloud.run.v2.Service"
        }
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let operation = try decoder.decode(RunOperation.self, from: Data(json.utf8))

    #expect(operation.name?.contains("op-12345") == true)
    #expect(operation.done == true)
    #expect(operation.metadata?.verb == "create")
}

@Test func testRunOperationWithErrorDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/operations/op-failed",
        "done": true,
        "error": {
            "code": 400,
            "message": "Invalid container image"
        }
    }
    """

    let decoder = JSONDecoder()
    let operation = try decoder.decode(RunOperation.self, from: Data(json.utf8))

    #expect(operation.done == true)
    #expect(operation.error?.code == 400)
    #expect(operation.error?.message == "Invalid container image")
}

@Test func testRunIngressEnum() {
    #expect(RunIngress.all.rawValue == "INGRESS_TRAFFIC_ALL")
    #expect(RunIngress.internalOnly.rawValue == "INGRESS_TRAFFIC_INTERNAL_ONLY")
    #expect(RunIngress.internalLoadBalancer.rawValue == "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER")
}

@Test func testRunEnvVarHelpers() {
    let valueEnv = RunEnvVar.value("PORT", "8080")
    #expect(valueEnv.name == "PORT")
    #expect(valueEnv.value == "8080")

    let secretEnv = RunEnvVar.secret("API_KEY", secretName: "my-secret", version: "2")
    #expect(secretEnv.name == "API_KEY")
    #expect(secretEnv.valueSource?.secretKeyRef?.secret == "my-secret")
    #expect(secretEnv.valueSource?.secretKeyRef?.version == "2")
}

@Test func testRunTrafficTargetHelpers() {
    let latest = RunTrafficTarget.latest(percent: 100)
    #expect(latest.type == "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
    #expect(latest.percent == 100)

    let revision = RunTrafficTarget.revision("my-api-00001", percent: 50)
    #expect(revision.type == "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION")
    #expect(revision.revision == "my-api-00001")
    #expect(revision.percent == 50)
}

@Test func testRunResourceRequirementsHelper() {
    let resources = RunResourceRequirements.resources(cpu: "2", memory: "1Gi", cpuIdle: false)

    #expect(resources.limits?["cpu"] == "2")
    #expect(resources.limits?["memory"] == "1Gi")
    #expect(resources.cpuIdle == false)
}

// MARK: - Mock Helper Extensions

extension MockRunAPI {
    func setListServicesHandler(_ handler: @escaping (String, Int?, String?, Bool) async throws -> RunServiceListResponse) {
        listServicesHandler = handler
    }

    func setGetServiceHandler(_ handler: @escaping (String, String) async throws -> RunService) {
        getServiceHandler = handler
    }

    func setListJobsHandler(_ handler: @escaping (String, Int?, String?, Bool) async throws -> RunJobListResponse) {
        listJobsHandler = handler
    }
}
