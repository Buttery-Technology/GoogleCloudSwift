import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Cloud Run Types Tests

@Test func testRunServiceExtractServiceId() {
    let service = RunService(
        name: "projects/my-project/locations/us-central1/services/my-service",
        uid: "123",
        generation: nil,
        labels: nil,
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
        uri: nil,
        reconciling: nil,
        etag: nil
    )

    #expect(service.serviceId == "my-service")
}

@Test func testRunServiceIsReady() {
    let readyCondition = RunCondition(
        type: "Ready",
        state: "CONDITION_SUCCEEDED",
        message: nil,
        lastTransitionTime: nil,
        severity: nil,
        reason: nil,
        revisionReason: nil,
        executionReason: nil
    )

    let service = RunService(
        name: nil,
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
        ingress: nil,
        launchStage: nil,
        description: nil,
        template: nil,
        traffic: nil,
        observedGeneration: nil,
        terminalCondition: readyCondition,
        conditions: nil,
        latestReadyRevision: nil,
        latestCreatedRevision: nil,
        trafficStatuses: nil,
        uri: nil,
        reconciling: nil,
        etag: nil
    )

    #expect(service.isReady)
}

@Test func testRunEnvVarValue() {
    let envVar = RunEnvVar.value("DATABASE_URL", "postgres://localhost/db")

    #expect(envVar.name == "DATABASE_URL")
    #expect(envVar.value == "postgres://localhost/db")
    #expect(envVar.valueSource == nil)
}

@Test func testRunEnvVarSecret() {
    let envVar = RunEnvVar.secret("API_KEY", secretName: "my-api-key", version: "latest")

    #expect(envVar.name == "API_KEY")
    #expect(envVar.value == nil)
    #expect(envVar.valueSource?.secretKeyRef?.secret == "my-api-key")
    #expect(envVar.valueSource?.secretKeyRef?.version == "latest")
}

@Test func testRunResourceRequirements() {
    let resources = RunResourceRequirements.resources(cpu: "2", memory: "1Gi", cpuIdle: false)

    #expect(resources.limits?["cpu"] == "2")
    #expect(resources.limits?["memory"] == "1Gi")
    #expect(resources.cpuIdle == false)
}

@Test func testRunTrafficTargetLatest() {
    let target = RunTrafficTarget.latest(percent: 100)

    #expect(target.type == "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
    #expect(target.percent == 100)
    #expect(target.revision == nil)
}

@Test func testRunTrafficTargetRevision() {
    let target = RunTrafficTarget.revision("my-service-00001", percent: 50)

    #expect(target.type == "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION")
    #expect(target.revision == "my-service-00001")
    #expect(target.percent == 50)
}

@Test func testRunJobExtractJobId() {
    let job = RunJob(
        name: "projects/my-project/locations/us-central1/jobs/my-job",
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
        executionCount: nil,
        latestCreatedExecution: nil,
        reconciling: nil,
        etag: nil
    )

    #expect(job.jobId == "my-job")
}

@Test func testRunExecutionIsComplete() {
    let incompleteExecution = RunExecution(
        name: nil,
        uid: nil,
        generation: nil,
        labels: nil,
        annotations: nil,
        createTime: nil,
        startTime: Date(),
        completionTime: nil,
        deleteTime: nil,
        expireTime: nil,
        launchStage: nil,
        job: nil,
        parallelism: nil,
        taskCount: nil,
        template: nil,
        reconciling: nil,
        conditions: nil,
        observedGeneration: nil,
        runningCount: nil,
        succeededCount: nil,
        failedCount: nil,
        cancelledCount: nil,
        retriedCount: nil,
        logUri: nil,
        etag: nil
    )

    #expect(!incompleteExecution.isComplete)

    let completeExecution = RunExecution(
        name: nil,
        uid: nil,
        generation: nil,
        labels: nil,
        annotations: nil,
        createTime: nil,
        startTime: Date(),
        completionTime: Date(),
        deleteTime: nil,
        expireTime: nil,
        launchStage: nil,
        job: nil,
        parallelism: nil,
        taskCount: nil,
        template: nil,
        reconciling: nil,
        conditions: nil,
        observedGeneration: nil,
        runningCount: nil,
        succeededCount: nil,
        failedCount: nil,
        cancelledCount: nil,
        retriedCount: nil,
        logUri: nil,
        etag: nil
    )

    #expect(completeExecution.isComplete)
}

@Test func testRunExecutionSucceeded() {
    let successExecution = RunExecution(
        name: nil,
        uid: nil,
        generation: nil,
        labels: nil,
        annotations: nil,
        createTime: nil,
        startTime: nil,
        completionTime: Date(),
        deleteTime: nil,
        expireTime: nil,
        launchStage: nil,
        job: nil,
        parallelism: nil,
        taskCount: 5,
        template: nil,
        reconciling: nil,
        conditions: nil,
        observedGeneration: nil,
        runningCount: 0,
        succeededCount: 5,
        failedCount: 0,
        cancelledCount: nil,
        retriedCount: nil,
        logUri: nil,
        etag: nil
    )

    #expect(successExecution.succeeded)

    let failedExecution = RunExecution(
        name: nil,
        uid: nil,
        generation: nil,
        labels: nil,
        annotations: nil,
        createTime: nil,
        startTime: nil,
        completionTime: Date(),
        deleteTime: nil,
        expireTime: nil,
        launchStage: nil,
        job: nil,
        parallelism: nil,
        taskCount: 5,
        template: nil,
        reconciling: nil,
        conditions: nil,
        observedGeneration: nil,
        runningCount: 0,
        succeededCount: 3,
        failedCount: 2,
        cancelledCount: nil,
        retriedCount: nil,
        logUri: nil,
        etag: nil
    )

    #expect(!failedExecution.succeeded)
}

// MARK: - IAM Types Tests

@Test func testIAMServiceAccountExtractAccountId() {
    let sa = IAMServiceAccount(
        name: nil,
        projectId: nil,
        uniqueId: nil,
        email: "my-sa@my-project.iam.gserviceaccount.com",
        displayName: nil,
        etag: nil,
        description: nil,
        oauth2ClientId: nil,
        disabled: nil
    )

    #expect(sa.accountId == "my-sa")
}

@Test func testIAMBindingServiceAccount() {
    let member = IAMBinding.serviceAccount("test@project.iam.gserviceaccount.com")
    #expect(member == "serviceAccount:test@project.iam.gserviceaccount.com")
}

@Test func testIAMBindingUser() {
    let member = IAMBinding.user("user@example.com")
    #expect(member == "user:user@example.com")
}

@Test func testIAMBindingGroup() {
    let member = IAMBinding.group("group@example.com")
    #expect(member == "group:group@example.com")
}

@Test func testIAMBindingDomain() {
    let member = IAMBinding.domain("example.com")
    #expect(member == "domain:example.com")
}

@Test func testIAMPolicyAddBinding() {
    let policy = IAMPolicy(version: 3, bindings: nil)

    let newPolicy = policy.addBinding(
        role: "roles/viewer",
        members: ["user:test@example.com"]
    )

    #expect(newPolicy.bindings?.count == 1)
    #expect(newPolicy.bindings?.first?.role == "roles/viewer")
    #expect(newPolicy.bindings?.first?.members?.contains("user:test@example.com") == true)
}

@Test func testIAMPolicyRemoveBinding() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:a@test.com"]),
            IAMBinding(role: "roles/editor", members: ["user:b@test.com"])
        ]
    )

    let newPolicy = policy.removeBinding(role: "roles/viewer")

    #expect(newPolicy.bindings?.count == 1)
    #expect(newPolicy.bindings?.first?.role == "roles/editor")
}

@Test func testIAMPolicyAddMember() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:existing@test.com"])
        ]
    )

    let newPolicy = policy.addMember("user:new@test.com", toRole: "roles/viewer")

    #expect(newPolicy.bindings?.first?.members?.count == 2)
    #expect(newPolicy.bindings?.first?.members?.contains("user:new@test.com") == true)
}

@Test func testIAMPolicyAddMemberToNewRole() {
    let policy = IAMPolicy(version: 3, bindings: nil)

    let newPolicy = policy.addMember("user:test@test.com", toRole: "roles/viewer")

    #expect(newPolicy.bindings?.count == 1)
    #expect(newPolicy.bindings?.first?.role == "roles/viewer")
}

@Test func testIAMPolicyRemoveMember() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:a@test.com", "user:b@test.com"])
        ]
    )

    let newPolicy = policy.removeMember("user:a@test.com", fromRole: "roles/viewer")

    #expect(newPolicy.bindings?.first?.members?.count == 1)
    #expect(newPolicy.bindings?.first?.members?.contains("user:b@test.com") == true)
    #expect(newPolicy.bindings?.first?.members?.contains("user:a@test.com") == false)
}

@Test func testIAMPolicyRemoveLastMemberRemovesBinding() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:only@test.com"])
        ]
    )

    let newPolicy = policy.removeMember("user:only@test.com", fromRole: "roles/viewer")

    #expect(newPolicy.bindings?.isEmpty == true)
}

@Test func testIAMServiceAccountKeyExtractKeyId() {
    let key = IAMServiceAccountKey(
        name: "projects/my-project/serviceAccounts/sa@my-project.iam.gserviceaccount.com/keys/key123",
        privateKeyType: nil,
        keyAlgorithm: nil,
        privateKeyData: nil,
        publicKeyData: nil,
        validAfterTime: nil,
        validBeforeTime: nil,
        keyOrigin: nil,
        keyType: nil,
        disabled: nil
    )

    #expect(key.keyId == "key123")
}

@Test func testIAMRoleExtractRoleId() {
    let role = IAMRole(
        name: "projects/my-project/roles/customRole",
        title: nil,
        description: nil,
        includedPermissions: nil,
        stage: nil,
        etag: nil,
        deleted: nil
    )

    #expect(role.roleId == "customRole")
}

// MARK: - Logging Types Tests

@Test func testLoggingLogEntryText() {
    let entry = LoggingLogEntry.text("Test message", severity: .error, labels: ["app": "test"])

    #expect(entry.textPayload == "Test message")
    #expect(entry.severity == "ERROR")
    #expect(entry.labels?["app"] == "test")
}

@Test func testLoggingLogEntryJSON() {
    let entry = LoggingLogEntry.json(
        ["key": "value", "count": 42],
        severity: .info
    )

    #expect(entry.jsonPayload != nil)
    #expect(entry.textPayload == nil)
    #expect(entry.severity == "INFO")
}

@Test func testLoggingSeverityNumericValues() {
    #expect(LoggingEntrySeverity.default.numericValue == 0)
    #expect(LoggingEntrySeverity.debug.numericValue == 100)
    #expect(LoggingEntrySeverity.info.numericValue == 200)
    #expect(LoggingEntrySeverity.notice.numericValue == 300)
    #expect(LoggingEntrySeverity.warning.numericValue == 400)
    #expect(LoggingEntrySeverity.error.numericValue == 500)
    #expect(LoggingEntrySeverity.critical.numericValue == 600)
    #expect(LoggingEntrySeverity.alert.numericValue == 700)
    #expect(LoggingEntrySeverity.emergency.numericValue == 800)
}

@Test func testLoggingMonitoredResourceGlobal() {
    let resource = LoggingMonitoredResource.global

    #expect(resource.type == "global")
    #expect(resource.labels == nil)
}

@Test func testLoggingMonitoredResourceGCEInstance() {
    let resource = LoggingMonitoredResource.gceInstance(
        projectId: "my-project",
        instanceId: "12345",
        zone: "us-central1-a"
    )

    #expect(resource.type == "gce_instance")
    #expect(resource.labels?["project_id"] == "my-project")
    #expect(resource.labels?["instance_id"] == "12345")
    #expect(resource.labels?["zone"] == "us-central1-a")
}

@Test func testLoggingSinkRequestToStorage() {
    let sink = LoggingSinkRequest.toStorage(
        name: "my-sink",
        bucketName: "my-bucket",
        filter: "severity >= ERROR"
    )

    #expect(sink.name == "my-sink")
    #expect(sink.destination == "storage.googleapis.com/my-bucket")
    #expect(sink.filter == "severity >= ERROR")
}

@Test func testLoggingSinkRequestToBigQuery() {
    let sink = LoggingSinkRequest.toBigQuery(
        name: "bq-sink",
        projectId: "my-project",
        datasetId: "logs_dataset",
        filter: nil,
        usePartitionedTables: true
    )

    #expect(sink.name == "bq-sink")
    #expect(sink.destination == "bigquery.googleapis.com/projects/my-project/datasets/logs_dataset")
    #expect(sink.bigqueryOptions?.usePartitionedTables == true)
}

@Test func testLoggingSinkRequestToPubSub() {
    let sink = LoggingSinkRequest.toPubSub(
        name: "pubsub-sink",
        projectId: "my-project",
        topicId: "logs-topic",
        filter: "resource.type=\"gce_instance\""
    )

    #expect(sink.name == "pubsub-sink")
    #expect(sink.destination == "pubsub.googleapis.com/projects/my-project/topics/logs-topic")
}

@Test func testLoggingMetricRequestCounter() {
    let metric = LoggingMetricRequest.counter(
        name: "error-count",
        filter: "severity >= ERROR",
        description: "Count of errors"
    )

    #expect(metric.name == "error-count")
    #expect(metric.filter == "severity >= ERROR")
    #expect(metric.description == "Count of errors")
}

// MARK: - Logging Filter Tests

@Test func testLoggingFilterSeverity() {
    let filter = LoggingFilter.severity(">=", .error)
    #expect(filter == "severity >= ERROR")
}

@Test func testLoggingFilterResourceType() {
    let filter = LoggingFilter.resourceType("gce_instance")
    #expect(filter == "resource.type = \"gce_instance\"")
}

@Test func testLoggingFilterLabel() {
    let filter = LoggingFilter.label("app", "my-app")
    #expect(filter == "labels.app = \"my-app\"")
}

@Test func testLoggingFilterLogName() {
    let filter = LoggingFilter.logName("my-log", projectId: "my-project")
    #expect(filter == "logName = \"projects/my-project/logs/my-log\"")
}

@Test func testLoggingFilterTextPayload() {
    let filter = LoggingFilter.textPayload(contains: "error")
    #expect(filter == "textPayload : \"error\"")
}

@Test func testLoggingFilterJSONPayload() {
    let filter = LoggingFilter.jsonPayload("status", equals: "failed")
    #expect(filter == "jsonPayload.status = \"failed\"")
}

@Test func testLoggingFilterAnd() {
    let filter = LoggingFilter.and(
        LoggingFilter.errors,
        LoggingFilter.resourceType("gce_instance")
    )
    #expect(filter == "severity >= ERROR AND resource.type = \"gce_instance\"")
}

@Test func testLoggingFilterOr() {
    let filter = LoggingFilter.or(
        LoggingFilter.resourceType("gce_instance"),
        LoggingFilter.resourceType("cloud_function")
    )
    #expect(filter == "(resource.type = \"gce_instance\" OR resource.type = \"cloud_function\")")
}

// MARK: - AnyCodable Tests

@Test func testAnyCodableEncodeString() throws {
    let value = AnyCodable("test string")
    let data = try JSONEncoder().encode(value)
    let json = String(data: data, encoding: .utf8)

    #expect(json == "\"test string\"")
}

@Test func testAnyCodableEncodeInt() throws {
    let value = AnyCodable(42)
    let data = try JSONEncoder().encode(value)
    let json = String(data: data, encoding: .utf8)

    #expect(json == "42")
}

@Test func testAnyCodableEncodeBool() throws {
    let value = AnyCodable(true)
    let data = try JSONEncoder().encode(value)
    let json = String(data: data, encoding: .utf8)

    #expect(json == "true")
}

@Test func testAnyCodableDecodeString() throws {
    let json = "\"hello\""
    let data = json.data(using: .utf8)!
    let value = try JSONDecoder().decode(AnyCodable.self, from: data)

    #expect(value.value as? String == "hello")
}

@Test func testAnyCodableDecodeInt() throws {
    let json = "123"
    let data = json.data(using: .utf8)!
    let value = try JSONDecoder().decode(AnyCodable.self, from: data)

    #expect(value.value as? Int == 123)
}

@Test func testAnyCodableDecodeDict() throws {
    let json = "{\"key\": \"value\"}"
    let data = json.data(using: .utf8)!
    let value = try JSONDecoder().decode(AnyCodable.self, from: data)

    let dict = value.value as? [String: Any]
    #expect(dict?["key"] as? String == "value")
}
