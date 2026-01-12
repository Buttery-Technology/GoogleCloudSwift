//
//  GoogleCloudLoggingAPITests.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Mock Logging API

/// Mock implementation of GoogleCloudLoggingAPIProtocol for testing.
actor MockLoggingAPI: GoogleCloudLoggingAPIProtocol {
    let projectId: String

    // Stubs for each method
    var writeLogEntriesHandler: ((String, [LoggingLogEntry], LoggingMonitoredResource?, [String: String]?, Bool, Bool) async throws -> LoggingWriteResponse)?
    var listLogEntriesHandler: ((String?, String?, Int?, String?, [String]?) async throws -> LoggingEntryListResponse)?
    var listLogsHandler: ((Int?, String?, [String]?) async throws -> LoggingLogListResponse)?
    var deleteLogHandler: ((String) async throws -> Void)?
    var listSinksHandler: ((Int?, String?) async throws -> LoggingSinkListResponse)?
    var getSinkHandler: ((String) async throws -> LoggingSink)?
    var createSinkHandler: ((LoggingSinkRequest, Bool) async throws -> LoggingSink)?
    var deleteSinkHandler: ((String) async throws -> Void)?
    var listMetricsHandler: ((Int?, String?) async throws -> LoggingMetricListResponse)?
    var getMetricHandler: ((String) async throws -> LoggingMetric)?
    var createMetricHandler: ((LoggingMetricRequest) async throws -> LoggingMetric)?
    var deleteMetricHandler: ((String) async throws -> Void)?

    // Call tracking
    var writeLogEntriesCalls: [(logName: String, entries: [LoggingLogEntry])] = []
    var listLogEntriesCalls: [(filter: String?, pageSize: Int?)] = []
    var listLogsCalls: [(pageSize: Int?, pageToken: String?)] = []
    var deleteLogCalls: [String] = []
    var listSinksCalls: [(pageSize: Int?, pageToken: String?)] = []
    var getSinkCalls: [String] = []
    var createSinkCalls: [(sink: LoggingSinkRequest, uniqueWriterIdentity: Bool)] = []
    var deleteSinkCalls: [String] = []
    var listMetricsCalls: [(pageSize: Int?, pageToken: String?)] = []
    var getMetricCalls: [String] = []
    var createMetricCalls: [LoggingMetricRequest] = []
    var deleteMetricCalls: [String] = []

    init(projectId: String = "test-project") {
        self.projectId = projectId
    }

    @discardableResult
    func writeLogEntries(
        logName: String,
        entries: [LoggingLogEntry],
        resource: LoggingMonitoredResource?,
        labels: [String: String]?,
        partialSuccess: Bool,
        dryRun: Bool
    ) async throws -> LoggingWriteResponse {
        writeLogEntriesCalls.append((logName, entries))
        if let handler = writeLogEntriesHandler {
            return try await handler(logName, entries, resource, labels, partialSuccess, dryRun)
        }
        return LoggingWriteResponse()
    }

    func listLogEntries(
        filter: String?,
        orderBy: String?,
        pageSize: Int?,
        pageToken: String?,
        resourceNames: [String]?
    ) async throws -> LoggingEntryListResponse {
        listLogEntriesCalls.append((filter, pageSize))
        if let handler = listLogEntriesHandler {
            return try await handler(filter, orderBy, pageSize, pageToken, resourceNames)
        }
        return LoggingEntryListResponse(entries: [], nextPageToken: nil)
    }

    func listLogs(pageSize: Int?, pageToken: String?, resourceNames: [String]?) async throws -> LoggingLogListResponse {
        listLogsCalls.append((pageSize, pageToken))
        if let handler = listLogsHandler {
            return try await handler(pageSize, pageToken, resourceNames)
        }
        return LoggingLogListResponse(logNames: [], nextPageToken: nil)
    }

    func deleteLog(logName: String) async throws {
        deleteLogCalls.append(logName)
        if let handler = deleteLogHandler {
            try await handler(logName)
        }
    }

    func listSinks(pageSize: Int?, pageToken: String?) async throws -> LoggingSinkListResponse {
        listSinksCalls.append((pageSize, pageToken))
        if let handler = listSinksHandler {
            return try await handler(pageSize, pageToken)
        }
        return LoggingSinkListResponse(sinks: [], nextPageToken: nil)
    }

    func getSink(sinkName: String) async throws -> LoggingSink {
        getSinkCalls.append(sinkName)
        if let handler = getSinkHandler {
            return try await handler(sinkName)
        }
        return createMockSink(name: sinkName)
    }

    func createSink(sink: LoggingSinkRequest, uniqueWriterIdentity: Bool) async throws -> LoggingSink {
        createSinkCalls.append((sink, uniqueWriterIdentity))
        if let handler = createSinkHandler {
            return try await handler(sink, uniqueWriterIdentity)
        }
        return createMockSink(name: sink.name, destination: sink.destination)
    }

    func deleteSink(sinkName: String) async throws {
        deleteSinkCalls.append(sinkName)
        if let handler = deleteSinkHandler {
            try await handler(sinkName)
        }
    }

    func listMetrics(pageSize: Int?, pageToken: String?) async throws -> LoggingMetricListResponse {
        listMetricsCalls.append((pageSize, pageToken))
        if let handler = listMetricsHandler {
            return try await handler(pageSize, pageToken)
        }
        return LoggingMetricListResponse(metrics: [], nextPageToken: nil)
    }

    func getMetric(metricName: String) async throws -> LoggingMetric {
        getMetricCalls.append(metricName)
        if let handler = getMetricHandler {
            return try await handler(metricName)
        }
        return createMockMetric(name: metricName)
    }

    func createMetric(metric: LoggingMetricRequest) async throws -> LoggingMetric {
        createMetricCalls.append(metric)
        if let handler = createMetricHandler {
            return try await handler(metric)
        }
        return createMockMetric(name: metric.name, filter: metric.filter)
    }

    func deleteMetric(metricName: String) async throws {
        deleteMetricCalls.append(metricName)
        if let handler = deleteMetricHandler {
            try await handler(metricName)
        }
    }

    // MARK: - Mock Data Helpers

    private func createMockSink(name: String, destination: String? = nil) -> LoggingSink {
        LoggingSink(
            name: name,
            destination: destination ?? "storage.googleapis.com/my-bucket",
            filter: nil,
            description: "Mock sink",
            disabled: false,
            exclusions: nil,
            outputVersionFormat: nil,
            writerIdentity: "serviceAccount:logging@\(projectId).iam.gserviceaccount.com",
            includeChildren: nil,
            bigqueryOptions: nil,
            createTime: Date(),
            updateTime: Date()
        )
    }

    private func createMockMetric(name: String, filter: String? = nil) -> LoggingMetric {
        LoggingMetric(
            name: name,
            description: "Mock metric",
            filter: filter ?? "severity >= ERROR",
            disabled: false,
            metricDescriptor: nil,
            valueExtractor: nil,
            labelExtractors: nil,
            bucketOptions: nil,
            createTime: Date(),
            updateTime: Date(),
            version: nil
        )
    }
}

// MARK: - Protocol Conformance Tests

@Test func testLoggingAPIProtocolConformance() {
    func acceptsProtocol<T: GoogleCloudLoggingAPIProtocol>(_ api: T) {}

    let mock = MockLoggingAPI()
    acceptsProtocol(mock)
}

// MARK: - Mock Logging API Tests

@Test func testMockLoggingAPIProjectId() async {
    let mock = MockLoggingAPI(projectId: "my-logging-project")
    let projectId = await mock.projectId
    #expect(projectId == "my-logging-project")
}

@Test func testMockWriteLogEntries() async throws {
    let mock = MockLoggingAPI()
    let entries = [
        LoggingLogEntry.text("Test message", severity: .info),
        LoggingLogEntry.json(["key": "value"], severity: .warning)
    ]

    try await mock.writeLogEntries(
        logName: "test-log",
        entries: entries,
        resource: .global,
        labels: ["env": "test"],
        partialSuccess: true,
        dryRun: false
    )

    let calls = await mock.writeLogEntriesCalls
    #expect(calls.count == 1)
    #expect(calls.first?.logName == "test-log")
    #expect(calls.first?.entries.count == 2)
}

@Test func testMockListLogEntries() async throws {
    let mock = MockLoggingAPI()

    await mock.setListLogEntriesHandler { filter, orderBy, pageSize, pageToken, resourceNames in
        let entry = LoggingEntry(
            logName: "projects/test-project/logs/test-log",
            resource: LoggingMonitoredResource(type: "global"),
            timestamp: Date(),
            receiveTimestamp: Date(),
            severity: "ERROR",
            insertId: "abc123",
            httpRequest: nil,
            labels: ["service": "api"],
            trace: nil,
            spanId: nil,
            traceSampled: nil,
            sourceLocation: nil,
            textPayload: "Error occurred",
            jsonPayload: nil,
            protoPayload: nil
        )
        return LoggingEntryListResponse(entries: [entry], nextPageToken: "page2")
    }

    let result = try await mock.listLogEntries(
        filter: "severity >= ERROR",
        orderBy: "timestamp desc",
        pageSize: 100,
        pageToken: nil,
        resourceNames: nil
    )

    #expect(result.entries?.count == 1)
    #expect(result.entries?.first?.severity == "ERROR")
    #expect(result.nextPageToken == "page2")

    let calls = await mock.listLogEntriesCalls
    #expect(calls.first?.filter == "severity >= ERROR")
}

@Test func testMockListLogs() async throws {
    let mock = MockLoggingAPI()

    await mock.setListLogsHandler { pageSize, pageToken, resourceNames in
        LoggingLogListResponse(
            logNames: ["projects/test-project/logs/app", "projects/test-project/logs/audit"],
            nextPageToken: nil
        )
    }

    let result = try await mock.listLogs(pageSize: nil, pageToken: nil, resourceNames: nil)

    #expect(result.logNames?.count == 2)
    #expect(result.logNames?.contains("projects/test-project/logs/app") == true)
}

@Test func testMockDeleteLog() async throws {
    let mock = MockLoggingAPI()

    try await mock.deleteLog(logName: "old-log")

    let calls = await mock.deleteLogCalls
    #expect(calls == ["old-log"])
}

@Test func testMockListSinks() async throws {
    let mock = MockLoggingAPI()

    await mock.setListSinksHandler { pageSize, pageToken in
        let sink = LoggingSink(
            name: "my-sink",
            destination: "storage.googleapis.com/my-bucket",
            filter: nil,
            description: nil,
            disabled: false,
            exclusions: nil,
            outputVersionFormat: nil,
            writerIdentity: nil,
            includeChildren: nil,
            bigqueryOptions: nil,
            createTime: nil,
            updateTime: nil
        )
        return LoggingSinkListResponse(sinks: [sink], nextPageToken: nil)
    }

    let result = try await mock.listSinks(pageSize: nil, pageToken: nil)

    #expect(result.sinks?.count == 1)
    #expect(result.sinks?.first?.name == "my-sink")
}

@Test func testMockGetSink() async throws {
    let mock = MockLoggingAPI()

    let sink = try await mock.getSink(sinkName: "my-sink")

    #expect(sink.name == "my-sink")
    #expect(sink.writerIdentity != nil)

    let calls = await mock.getSinkCalls
    #expect(calls == ["my-sink"])
}

@Test func testMockCreateSink() async throws {
    let mock = MockLoggingAPI()
    let sinkRequest = LoggingSinkRequest.toStorage(
        name: "backup-sink",
        bucketName: "my-backup-bucket",
        filter: "severity >= WARNING"
    )

    let sink = try await mock.createSink(sink: sinkRequest, uniqueWriterIdentity: true)

    #expect(sink.name == "backup-sink")

    let calls = await mock.createSinkCalls
    #expect(calls.count == 1)
    #expect(calls.first?.uniqueWriterIdentity == true)
}

@Test func testMockDeleteSink() async throws {
    let mock = MockLoggingAPI()

    try await mock.deleteSink(sinkName: "old-sink")

    let calls = await mock.deleteSinkCalls
    #expect(calls == ["old-sink"])
}

@Test func testMockListMetrics() async throws {
    let mock = MockLoggingAPI()

    let result = try await mock.listMetrics(pageSize: nil, pageToken: nil)

    #expect(result.metrics?.isEmpty != false)

    let calls = await mock.listMetricsCalls
    #expect(calls.count == 1)
}

@Test func testMockGetMetric() async throws {
    let mock = MockLoggingAPI()

    let metric = try await mock.getMetric(metricName: "error-count")

    #expect(metric.name == "error-count")
    #expect(metric.filter != nil)

    let calls = await mock.getMetricCalls
    #expect(calls == ["error-count"])
}

@Test func testMockCreateMetric() async throws {
    let mock = MockLoggingAPI()
    let metricRequest = LoggingMetricRequest.counter(
        name: "api-errors",
        filter: "severity >= ERROR AND resource.type = \"cloud_run_revision\"",
        description: "Count of API errors"
    )

    let metric = try await mock.createMetric(metric: metricRequest)

    #expect(metric.name == "api-errors")

    let calls = await mock.createMetricCalls
    #expect(calls.count == 1)
    #expect(calls.first?.name == "api-errors")
}

@Test func testMockDeleteMetric() async throws {
    let mock = MockLoggingAPI()

    try await mock.deleteMetric(metricName: "old-metric")

    let calls = await mock.deleteMetricCalls
    #expect(calls == ["old-metric"])
}

@Test func testMockLoggingAPIErrorHandling() async {
    let mock = MockLoggingAPI()

    await mock.setGetSinkHandler { sinkName in
        throw GoogleCloudAPIError.httpError(404, nil)
    }

    do {
        _ = try await mock.getSink(sinkName: "nonexistent-sink")
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

@Test func testLoggingLogEntryHelpers() {
    let textEntry = LoggingLogEntry.text("Hello World", severity: .info, labels: ["key": "value"])
    #expect(textEntry.textPayload == "Hello World")
    #expect(textEntry.severity == "INFO")
    #expect(textEntry.labels?["key"] == "value")

    let jsonEntry = LoggingLogEntry.json(["message": "test", "count": 42], severity: .warning)
    #expect(jsonEntry.jsonPayload != nil)
    #expect(jsonEntry.severity == "WARNING")
}

@Test func testLoggingMonitoredResourceHelpers() {
    let global = LoggingMonitoredResource.global
    #expect(global.type == "global")

    let gce = LoggingMonitoredResource.gceInstance(
        projectId: "my-project",
        instanceId: "12345",
        zone: "us-central1-a"
    )
    #expect(gce.type == "gce_instance")
    #expect(gce.labels?["instance_id"] == "12345")

    let cloudRun = LoggingMonitoredResource.cloudRunRevision(
        projectId: "my-project",
        serviceName: "my-api",
        revisionName: "my-api-00001",
        location: "us-central1"
    )
    #expect(cloudRun.type == "cloud_run_revision")
    #expect(cloudRun.labels?["service_name"] == "my-api")
}

@Test func testLoggingSinkRequestHelpers() {
    let storageSink = LoggingSinkRequest.toStorage(
        name: "storage-sink",
        bucketName: "my-bucket",
        filter: "severity >= ERROR"
    )
    #expect(storageSink.destination == "storage.googleapis.com/my-bucket")
    #expect(storageSink.filter == "severity >= ERROR")

    let bigquerySink = LoggingSinkRequest.toBigQuery(
        name: "bq-sink",
        projectId: "my-project",
        datasetId: "logs",
        usePartitionedTables: true
    )
    #expect(bigquerySink.destination == "bigquery.googleapis.com/projects/my-project/datasets/logs")
    #expect(bigquerySink.bigqueryOptions?.usePartitionedTables == true)

    let pubsubSink = LoggingSinkRequest.toPubSub(
        name: "pubsub-sink",
        projectId: "my-project",
        topicId: "log-topic"
    )
    #expect(pubsubSink.destination == "pubsub.googleapis.com/projects/my-project/topics/log-topic")
}

@Test func testLoggingMetricRequestHelper() {
    let counter = LoggingMetricRequest.counter(
        name: "error-count",
        filter: "severity >= ERROR",
        description: "Count of errors"
    )
    #expect(counter.name == "error-count")
    #expect(counter.filter == "severity >= ERROR")
    #expect(counter.description == "Count of errors")
}

// MARK: - Response Type Tests

@Test func testLoggingEntryDecoding() throws {
    let json = """
    {
        "logName": "projects/my-project/logs/my-app",
        "resource": {
            "type": "global"
        },
        "timestamp": "2024-01-15T10:30:00.000Z",
        "receiveTimestamp": "2024-01-15T10:30:01.000Z",
        "severity": "ERROR",
        "insertId": "abc123",
        "labels": {
            "service": "api",
            "version": "1.0.0"
        },
        "textPayload": "An error occurred"
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let entry = try decoder.decode(LoggingEntry.self, from: Data(json.utf8))

    #expect(entry.logName == "projects/my-project/logs/my-app")
    #expect(entry.severity == "ERROR")
    #expect(entry.severityLevel == .error)
    #expect(entry.labels?["service"] == "api")
    #expect(entry.textPayload == "An error occurred")
}

@Test func testLoggingSinkDecoding() throws {
    let json = """
    {
        "name": "my-sink",
        "destination": "storage.googleapis.com/my-bucket",
        "filter": "severity >= WARNING",
        "description": "Export warnings and errors",
        "disabled": false,
        "writerIdentity": "serviceAccount:p123-456@gcp-sa-logging.iam.gserviceaccount.com",
        "createTime": "2024-01-15T10:30:00.000Z"
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let sink = try decoder.decode(LoggingSink.self, from: Data(json.utf8))

    #expect(sink.name == "my-sink")
    #expect(sink.destination == "storage.googleapis.com/my-bucket")
    #expect(sink.filter == "severity >= WARNING")
    #expect(sink.disabled == false)
    #expect(sink.writerIdentity != nil)
}

@Test func testLoggingMetricDecoding() throws {
    let json = """
    {
        "name": "error-count",
        "description": "Count of errors",
        "filter": "severity >= ERROR",
        "disabled": false,
        "createTime": "2024-01-15T10:30:00.000Z",
        "updateTime": "2024-01-15T10:30:00.000Z"
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let metric = try decoder.decode(LoggingMetric.self, from: Data(json.utf8))

    #expect(metric.name == "error-count")
    #expect(metric.filter == "severity >= ERROR")
    #expect(metric.disabled == false)
}

@Test func testLoggingBucketDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/locations/us-central1/buckets/my-bucket",
        "description": "Custom log bucket",
        "retentionDays": 30,
        "locked": false,
        "lifecycleState": "ACTIVE",
        "analyticsEnabled": true
    }
    """

    let decoder = JSONDecoder()
    let bucket = try decoder.decode(LoggingBucket.self, from: Data(json.utf8))

    #expect(bucket.name?.contains("my-bucket") == true)
    #expect(bucket.retentionDays == 30)
    #expect(bucket.locked == false)
    #expect(bucket.analyticsEnabled == true)
}

// MARK: - Enum Tests

@Test func testLoggingEntrySeverity() {
    #expect(LoggingEntrySeverity.default.rawValue == "DEFAULT")
    #expect(LoggingEntrySeverity.debug.rawValue == "DEBUG")
    #expect(LoggingEntrySeverity.info.rawValue == "INFO")
    #expect(LoggingEntrySeverity.notice.rawValue == "NOTICE")
    #expect(LoggingEntrySeverity.warning.rawValue == "WARNING")
    #expect(LoggingEntrySeverity.error.rawValue == "ERROR")
    #expect(LoggingEntrySeverity.critical.rawValue == "CRITICAL")
    #expect(LoggingEntrySeverity.alert.rawValue == "ALERT")
    #expect(LoggingEntrySeverity.emergency.rawValue == "EMERGENCY")
}

@Test func testLoggingEntrySeverityNumericValues() {
    #expect(LoggingEntrySeverity.default.numericValue == 0)
    #expect(LoggingEntrySeverity.debug.numericValue == 100)
    #expect(LoggingEntrySeverity.info.numericValue == 200)
    #expect(LoggingEntrySeverity.warning.numericValue == 400)
    #expect(LoggingEntrySeverity.error.numericValue == 500)
    #expect(LoggingEntrySeverity.emergency.numericValue == 800)
}

// MARK: - Filter Helper Tests

@Test func testLoggingFilterHelpers() {
    #expect(LoggingFilter.severity(">=", .error) == "severity >= ERROR")
    #expect(LoggingFilter.errors == "severity >= ERROR")
    #expect(LoggingFilter.warnings == "severity >= WARNING")
    #expect(LoggingFilter.resourceType("gce_instance") == "resource.type = \"gce_instance\"")
    #expect(LoggingFilter.label("env", "prod") == "labels.env = \"prod\"")
    #expect(LoggingFilter.textPayload(contains: "error") == "textPayload : \"error\"")
    #expect(LoggingFilter.jsonPayload("status", equals: "failed") == "jsonPayload.status = \"failed\"")
}

@Test func testLoggingFilterCombination() {
    let combined = LoggingFilter.and(
        LoggingFilter.errors,
        LoggingFilter.resourceType("cloud_run_revision")
    )
    #expect(combined == "severity >= ERROR AND resource.type = \"cloud_run_revision\"")

    let orFilter = LoggingFilter.or(
        LoggingFilter.label("env", "prod"),
        LoggingFilter.label("env", "staging")
    )
    #expect(orFilter == "(labels.env = \"prod\" OR labels.env = \"staging\")")
}

@Test func testLoggingFilterLogNameHelper() {
    let filter = LoggingFilter.logName("my-app", projectId: "my-project")
    #expect(filter == "logName = \"projects/my-project/logs/my-app\"")
}

// MARK: - Mock Helper Extensions

extension MockLoggingAPI {
    func setListLogEntriesHandler(_ handler: @escaping (String?, String?, Int?, String?, [String]?) async throws -> LoggingEntryListResponse) {
        listLogEntriesHandler = handler
    }

    func setListLogsHandler(_ handler: @escaping (Int?, String?, [String]?) async throws -> LoggingLogListResponse) {
        listLogsHandler = handler
    }

    func setListSinksHandler(_ handler: @escaping (Int?, String?) async throws -> LoggingSinkListResponse) {
        listSinksHandler = handler
    }

    func setGetSinkHandler(_ handler: @escaping (String) async throws -> LoggingSink) {
        getSinkHandler = handler
    }
}
