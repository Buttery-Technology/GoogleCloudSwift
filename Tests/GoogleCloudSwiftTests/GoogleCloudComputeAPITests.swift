//
//  GoogleCloudComputeAPITests.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Mock Compute API

/// Mock implementation of GoogleCloudComputeAPIProtocol for testing.
actor MockComputeAPI: GoogleCloudComputeAPIProtocol {
    let projectId: String

    // Stubs for each method
    var listInstancesHandler: ((String, String?, Int?, String?) async throws -> GoogleCloudListResponse<ComputeInstance>)?
    var getInstanceHandler: ((String, String) async throws -> ComputeInstance)?
    var createInstanceHandler: ((ComputeInstanceInsert, String) async throws -> GoogleCloudOperation)?
    var deleteInstanceHandler: ((String, String) async throws -> GoogleCloudOperation)?
    var startInstanceHandler: ((String, String) async throws -> GoogleCloudOperation)?
    var stopInstanceHandler: ((String, String) async throws -> GoogleCloudOperation)?
    var listZonesHandler: ((String?, Int?, String?) async throws -> GoogleCloudListResponse<Zone>)?
    var getZoneHandler: ((String) async throws -> Zone)?
    var waitForZoneOperationHandler: ((String, String, TimeInterval, TimeInterval) async throws -> GoogleCloudOperation)?

    // Call tracking
    var listInstancesCalls: [(zone: String, filter: String?, maxResults: Int?, pageToken: String?)] = []
    var getInstanceCalls: [(name: String, zone: String)] = []
    var createInstanceCalls: [(instance: ComputeInstanceInsert, zone: String)] = []
    var deleteInstanceCalls: [(name: String, zone: String)] = []
    var startInstanceCalls: [(name: String, zone: String)] = []
    var stopInstanceCalls: [(name: String, zone: String)] = []
    var listZonesCalls: [(filter: String?, maxResults: Int?, pageToken: String?)] = []
    var getZoneCalls: [String] = []
    var waitForZoneOperationCalls: [(operationName: String, zone: String)] = []

    init(projectId: String = "test-project") {
        self.projectId = projectId
    }

    func listInstances(zone: String, filter: String?, maxResults: Int?, pageToken: String?) async throws -> GoogleCloudListResponse<ComputeInstance> {
        listInstancesCalls.append((zone, filter, maxResults, pageToken))
        if let handler = listInstancesHandler {
            return try await handler(zone, filter, maxResults, pageToken)
        }
        return GoogleCloudListResponse(items: [], nextPageToken: nil)
    }

    func getInstance(name: String, zone: String) async throws -> ComputeInstance {
        getInstanceCalls.append((name, zone))
        if let handler = getInstanceHandler {
            return try await handler(name, zone)
        }
        return createMockInstance(name: name, zone: zone)
    }

    func createInstance(_ instance: ComputeInstanceInsert, zone: String) async throws -> GoogleCloudOperation {
        createInstanceCalls.append((instance, zone))
        if let handler = createInstanceHandler {
            return try await handler(instance, zone)
        }
        return createMockOperation(name: "create-\(instance.name)", zone: zone)
    }

    func deleteInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        deleteInstanceCalls.append((name, zone))
        if let handler = deleteInstanceHandler {
            return try await handler(name, zone)
        }
        return createMockOperation(name: "delete-\(name)", zone: zone)
    }

    func startInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        startInstanceCalls.append((name, zone))
        if let handler = startInstanceHandler {
            return try await handler(name, zone)
        }
        return createMockOperation(name: "start-\(name)", zone: zone)
    }

    func stopInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        stopInstanceCalls.append((name, zone))
        if let handler = stopInstanceHandler {
            return try await handler(name, zone)
        }
        return createMockOperation(name: "stop-\(name)", zone: zone)
    }

    func listZones(filter: String?, maxResults: Int?, pageToken: String?) async throws -> GoogleCloudListResponse<Zone> {
        listZonesCalls.append((filter, maxResults, pageToken))
        if let handler = listZonesHandler {
            return try await handler(filter, maxResults, pageToken)
        }
        return GoogleCloudListResponse(items: [], nextPageToken: nil)
    }

    func getZone(name: String) async throws -> Zone {
        getZoneCalls.append(name)
        if let handler = getZoneHandler {
            return try await handler(name)
        }
        return createMockZone(name: name)
    }

    func waitForZoneOperation(operationName: String, zone: String, timeout: TimeInterval, pollInterval: TimeInterval) async throws -> GoogleCloudOperation {
        waitForZoneOperationCalls.append((operationName, zone))
        if let handler = waitForZoneOperationHandler {
            return try await handler(operationName, zone, timeout, pollInterval)
        }
        return createMockOperation(name: operationName, zone: zone, status: "DONE")
    }

    // MARK: - Mock Data Helpers

    private func createMockInstance(name: String, zone: String, status: String = "RUNNING") -> ComputeInstance {
        ComputeInstance(
            id: "12345",
            name: name,
            description: nil,
            zone: "projects/\(projectId)/zones/\(zone)",
            machineType: "zones/\(zone)/machineTypes/e2-medium",
            status: status,
            statusMessage: nil,
            selfLink: "https://compute.googleapis.com/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)",
            creationTimestamp: Date(),
            networkInterfaces: [
                NetworkInterface(
                    name: "nic0",
                    network: "global/networks/default",
                    subnetwork: nil,
                    networkIP: "10.128.0.2",
                    accessConfigs: nil,
                    fingerprint: nil
                )
            ],
            disks: nil,
            metadata: nil,
            tags: nil,
            labels: nil,
            labelFingerprint: nil,
            scheduling: nil,
            serviceAccounts: nil,
            cpuPlatform: "Intel Broadwell",
            canIpForward: false,
            deletionProtection: false,
            fingerprint: "abc123"
        )
    }

    private func createMockZone(name: String) -> Zone {
        Zone(
            id: "12345",
            name: name,
            description: name,
            status: "UP",
            region: "projects/\(projectId)/regions/\(name.components(separatedBy: "-").dropLast().joined(separator: "-"))",
            selfLink: "https://compute.googleapis.com/compute/v1/projects/\(projectId)/zones/\(name)",
            availableCpuPlatforms: ["Intel Broadwell", "Intel Skylake"],
            creationTimestamp: Date()
        )
    }

    private func createMockOperation(name: String, zone: String, status: String = "RUNNING") -> GoogleCloudOperation {
        GoogleCloudOperation(
            kind: "compute#operation",
            id: "op-123",
            name: name,
            description: nil,
            operationType: "compute.instances.insert",
            status: status,
            statusMessage: nil,
            targetLink: nil,
            targetId: nil,
            user: nil,
            progress: status == "DONE" ? 100 : 50,
            insertTime: Date(),
            startTime: Date(),
            endTime: status == "DONE" ? Date() : nil,
            selfLink: "https://compute.googleapis.com/compute/v1/projects/\(projectId)/zones/\(zone)/operations/\(name)",
            zone: "projects/\(projectId)/zones/\(zone)",
            region: nil,
            httpErrorStatusCode: nil,
            httpErrorMessage: nil,
            error: nil,
            warnings: nil
        )
    }
}

// MARK: - Protocol Conformance Tests

@Test func testComputeAPIProtocolConformance() {
    func acceptsProtocol<T: GoogleCloudComputeAPIProtocol>(_ api: T) {}

    let mock = MockComputeAPI()
    acceptsProtocol(mock)
}

// MARK: - Mock Compute API Tests

@Test func testMockComputeAPIProjectId() async {
    let mock = MockComputeAPI(projectId: "my-compute-project")
    let projectId = await mock.projectId
    #expect(projectId == "my-compute-project")
}

@Test func testMockListInstancesDefault() async throws {
    let mock = MockComputeAPI()
    let result = try await mock.listInstances(zone: "us-central1-a", filter: nil, maxResults: nil, pageToken: nil)

    #expect(result.items?.isEmpty != false)
    #expect(result.nextPageToken == nil)

    let calls = await mock.listInstancesCalls
    #expect(calls.count == 1)
    #expect(calls.first?.zone == "us-central1-a")
}

@Test func testMockListInstancesWithHandler() async throws {
    let mock = MockComputeAPI()

    await mock.setListInstancesHandler { zone, filter, maxResults, pageToken in
        let instance = ComputeInstance(
            id: "123",
            name: "test-vm",
            description: nil,
            zone: "projects/test-project/zones/\(zone)",
            machineType: "e2-medium",
            status: "RUNNING",
            statusMessage: nil,
            selfLink: nil,
            creationTimestamp: nil,
            networkInterfaces: nil,
            disks: nil,
            metadata: nil,
            tags: nil,
            labels: ["env": "test"],
            labelFingerprint: nil,
            scheduling: nil,
            serviceAccounts: nil,
            cpuPlatform: nil,
            canIpForward: nil,
            deletionProtection: nil,
            fingerprint: nil
        )
        return GoogleCloudListResponse(items: [instance], nextPageToken: "page2")
    }

    let result = try await mock.listInstances(zone: "us-west1-b", filter: "status=RUNNING", maxResults: 10, pageToken: nil)

    #expect(result.items?.count == 1)
    #expect(result.items?.first?.name == "test-vm")
    #expect(result.items?.first?.labels?["env"] == "test")
    #expect(result.nextPageToken == "page2")

    let calls = await mock.listInstancesCalls
    #expect(calls.count == 1)
    #expect(calls.first?.filter == "status=RUNNING")
    #expect(calls.first?.maxResults == 10)
}

@Test func testMockGetInstance() async throws {
    let mock = MockComputeAPI()
    let instance = try await mock.getInstance(name: "my-vm", zone: "us-central1-a")

    #expect(instance.name == "my-vm")
    #expect(instance.status == "RUNNING")

    let calls = await mock.getInstanceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.name == "my-vm")
    #expect(calls.first?.zone == "us-central1-a")
}

@Test func testMockCreateInstance() async throws {
    let mock = MockComputeAPI()
    let instanceInsert = ComputeInstanceInsert(
        name: "new-vm",
        machineType: "e2-small",
        zone: "us-central1-a",
        disks: [DiskInsert(boot: true, autoDelete: true, initializeParams: nil)],
        networkInterfaces: [NetworkInterfaceInsert(network: "default")]
    )

    let operation = try await mock.createInstance(instanceInsert, zone: "us-central1-a")

    #expect(operation.name?.contains("new-vm") == true)
    #expect(operation.status == "RUNNING")

    let calls = await mock.createInstanceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.instance.name == "new-vm")
    #expect(calls.first?.zone == "us-central1-a")
}

@Test func testMockDeleteInstance() async throws {
    let mock = MockComputeAPI()

    let operation = try await mock.deleteInstance(name: "vm-to-delete", zone: "us-east1-b")

    #expect(operation.name?.contains("vm-to-delete") == true)

    let calls = await mock.deleteInstanceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.name == "vm-to-delete")
    #expect(calls.first?.zone == "us-east1-b")
}

@Test func testMockStartInstance() async throws {
    let mock = MockComputeAPI()

    let operation = try await mock.startInstance(name: "stopped-vm", zone: "us-central1-a")

    #expect(operation.name?.contains("stopped-vm") == true)

    let calls = await mock.startInstanceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.name == "stopped-vm")
}

@Test func testMockStopInstance() async throws {
    let mock = MockComputeAPI()

    let operation = try await mock.stopInstance(name: "running-vm", zone: "us-central1-a")

    #expect(operation.name?.contains("running-vm") == true)

    let calls = await mock.stopInstanceCalls
    #expect(calls.count == 1)
    #expect(calls.first?.name == "running-vm")
}

@Test func testMockListZones() async throws {
    let mock = MockComputeAPI()

    await mock.setListZonesHandler { filter, maxResults, pageToken in
        let zones = [
            Zone(id: "1", name: "us-central1-a", description: nil, status: "UP", region: nil, selfLink: nil, availableCpuPlatforms: nil, creationTimestamp: nil),
            Zone(id: "2", name: "us-central1-b", description: nil, status: "UP", region: nil, selfLink: nil, availableCpuPlatforms: nil, creationTimestamp: nil)
        ]
        return GoogleCloudListResponse(items: zones, nextPageToken: nil)
    }

    let result = try await mock.listZones(filter: nil, maxResults: nil, pageToken: nil)

    #expect(result.items?.count == 2)
    #expect(result.items?[0].name == "us-central1-a")

    let calls = await mock.listZonesCalls
    #expect(calls.count == 1)
}

@Test func testMockGetZone() async throws {
    let mock = MockComputeAPI()
    let zone = try await mock.getZone(name: "us-west1-a")

    #expect(zone.name == "us-west1-a")
    #expect(zone.status == "UP")

    let calls = await mock.getZoneCalls
    #expect(calls == ["us-west1-a"])
}

@Test func testMockWaitForZoneOperation() async throws {
    let mock = MockComputeAPI()

    let operation = try await mock.waitForZoneOperation(
        operationName: "op-12345",
        zone: "us-central1-a",
        timeout: 60,
        pollInterval: 1
    )

    #expect(operation.status == "DONE")
    #expect(operation.isDone)

    let calls = await mock.waitForZoneOperationCalls
    #expect(calls.count == 1)
    #expect(calls.first?.operationName == "op-12345")
    #expect(calls.first?.zone == "us-central1-a")
}

@Test func testMockComputeAPIErrorHandling() async {
    let mock = MockComputeAPI()

    await mock.setGetInstanceHandler { name, zone in
        throw GoogleCloudAPIError.httpError(404, nil)
    }

    do {
        _ = try await mock.getInstance(name: "nonexistent-vm", zone: "us-central1-a")
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

@Test func testComputeInstanceInsertEncoding() throws {
    let instance = ComputeInstanceInsert(
        name: "test-vm",
        machineType: "e2-medium",
        zone: "us-central1-a",
        disks: [
            DiskInsert(
                boot: true,
                autoDelete: true,
                initializeParams: InitializeParamsInsert(
                    sourceImage: "projects/debian-cloud/global/images/family/debian-11",
                    diskSizeGb: "20",
                    diskType: "zones/us-central1-a/diskTypes/pd-standard"
                )
            )
        ],
        networkInterfaces: [
            NetworkInterfaceInsert(
                network: "global/networks/default",
                accessConfigs: [AccessConfigInsert(type: "ONE_TO_ONE_NAT", name: "External NAT")]
            )
        ],
        labels: ["env": "test", "team": "dev"]
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(instance)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["name"] as? String == "test-vm")
    #expect((json?["machineType"] as? String)?.contains("e2-medium") == true)
    #expect((json?["labels"] as? [String: String])?["env"] == "test")

    let disks = json?["disks"] as? [[String: Any]]
    #expect(disks?.count == 1)
    #expect(disks?[0]["boot"] as? Bool == true)
}

@Test func testFirewallInsertRequestEncoding() throws {
    let firewall = FirewallInsert(
        name: "allow-http",
        network: "global/networks/default",
        description: "Allow HTTP traffic",
        priority: 1000,
        direction: "INGRESS",
        sourceRanges: ["0.0.0.0/0"],
        targetTags: ["http-server"],
        allowed: [FirewallAllowedInsert(ipProtocol: "tcp", ports: ["80", "443"])]
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(firewall)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["name"] as? String == "allow-http")
    #expect(json?["priority"] as? Int == 1000)
    #expect(json?["direction"] as? String == "INGRESS")

    let allowed = json?["allowed"] as? [[String: Any]]
    #expect(allowed?[0]["IPProtocol"] as? String == "tcp")
    #expect((allowed?[0]["ports"] as? [String])?.contains("80") == true)
}

// MARK: - Response Type Tests

@Test func testComputeInstanceDecoding() throws {
    let json = """
    {
        "id": "123456789",
        "name": "my-instance",
        "zone": "projects/my-project/zones/us-central1-a",
        "machineType": "zones/us-central1-a/machineTypes/e2-medium",
        "status": "RUNNING",
        "creationTimestamp": "2024-01-15T10:30:00.000Z",
        "networkInterfaces": [
            {
                "name": "nic0",
                "network": "global/networks/default",
                "networkIP": "10.128.0.2",
                "accessConfigs": [
                    {
                        "type": "ONE_TO_ONE_NAT",
                        "name": "External NAT",
                        "natIP": "35.192.0.1"
                    }
                ]
            }
        ],
        "labels": {
            "env": "production"
        },
        "cpuPlatform": "Intel Broadwell",
        "deletionProtection": false
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let instance = try decoder.decode(ComputeInstance.self, from: Data(json.utf8))

    #expect(instance.name == "my-instance")
    #expect(instance.status == "RUNNING")
    #expect(instance.labels?["env"] == "production")
    #expect(instance.networkInterfaces?.count == 1)
    #expect(instance.networkInterfaces?[0].networkIP == "10.128.0.2")
    #expect(instance.networkInterfaces?[0].accessConfigs?[0].natIP == "35.192.0.1")
    #expect(instance.cpuPlatform == "Intel Broadwell")
    #expect(instance.deletionProtection == false)
}

@Test func testZoneDecoding() throws {
    let json = """
    {
        "id": "12345",
        "name": "us-central1-a",
        "description": "us-central1-a",
        "status": "UP",
        "region": "projects/my-project/regions/us-central1",
        "availableCpuPlatforms": ["Intel Broadwell", "Intel Skylake", "Intel Ice Lake"],
        "creationTimestamp": "2024-01-01T00:00:00.000Z"
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let zone = try decoder.decode(Zone.self, from: Data(json.utf8))

    #expect(zone.name == "us-central1-a")
    #expect(zone.status == "UP")
    #expect(zone.availableCpuPlatforms?.contains("Intel Skylake") == true)
}

@Test func testMachineTypeDecoding() throws {
    let json = """
    {
        "id": "12345",
        "name": "e2-medium",
        "description": "2 vCPUs, 4 GB RAM",
        "guestCpus": 2,
        "memoryMb": 4096,
        "zone": "projects/my-project/zones/us-central1-a",
        "isSharedCpu": true
    }
    """

    let decoder = JSONDecoder()
    let machineType = try decoder.decode(MachineType.self, from: Data(json.utf8))

    #expect(machineType.name == "e2-medium")
    #expect(machineType.guestCpus == 2)
    #expect(machineType.memoryMb == 4096)
    #expect(machineType.isSharedCpu == true)
}

@Test func testDiskDecoding() throws {
    let json = """
    {
        "id": "12345",
        "name": "boot-disk",
        "sizeGb": "100",
        "zone": "projects/my-project/zones/us-central1-a",
        "status": "READY",
        "type": "projects/my-project/zones/us-central1-a/diskTypes/pd-ssd",
        "sourceImage": "projects/debian-cloud/global/images/debian-11-bullseye-v20240115",
        "users": ["projects/my-project/zones/us-central1-a/instances/my-instance"]
    }
    """

    let decoder = JSONDecoder()
    let disk = try decoder.decode(Disk.self, from: Data(json.utf8))

    #expect(disk.name == "boot-disk")
    #expect(disk.sizeGb == "100")
    #expect(disk.status == "READY")
    #expect(disk.users?.count == 1)
}

@Test func testNetworkDecoding() throws {
    let json = """
    {
        "id": "12345",
        "name": "default",
        "autoCreateSubnetworks": true,
        "mtu": 1460,
        "routingConfig": {
            "routingMode": "REGIONAL"
        }
    }
    """

    let decoder = JSONDecoder()
    let network = try decoder.decode(Network.self, from: Data(json.utf8))

    #expect(network.name == "default")
    #expect(network.autoCreateSubnetworks == true)
    #expect(network.mtu == 1460)
    #expect(network.routingConfig?.routingMode == "REGIONAL")
}

@Test func testFirewallDecoding() throws {
    let json = """
    {
        "id": "12345",
        "name": "allow-ssh",
        "network": "global/networks/default",
        "priority": 1000,
        "direction": "INGRESS",
        "sourceRanges": ["0.0.0.0/0"],
        "allowed": [
            {
                "IPProtocol": "tcp",
                "ports": ["22"]
            }
        ],
        "disabled": false
    }
    """

    let decoder = JSONDecoder()
    let firewall = try decoder.decode(Firewall.self, from: Data(json.utf8))

    #expect(firewall.name == "allow-ssh")
    #expect(firewall.priority == 1000)
    #expect(firewall.direction == "INGRESS")
    #expect(firewall.sourceRanges?.contains("0.0.0.0/0") == true)
    #expect(firewall.allowed?[0].ipProtocol == "tcp")
    #expect(firewall.allowed?[0].ports?.contains("22") == true)
    #expect(firewall.disabled == false)
}

@Test func testGoogleCloudOperationDecoding() throws {
    let json = """
    {
        "kind": "compute#operation",
        "id": "op-12345",
        "name": "operation-name",
        "zone": "projects/my-project/zones/us-central1-a",
        "operationType": "compute.instances.insert",
        "status": "DONE",
        "progress": 100,
        "insertTime": "2024-01-15T10:30:00.000Z",
        "startTime": "2024-01-15T10:30:01.000Z",
        "endTime": "2024-01-15T10:30:30.000Z"
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let operation = try decoder.decode(GoogleCloudOperation.self, from: Data(json.utf8))

    #expect(operation.name == "operation-name")
    #expect(operation.status == "DONE")
    #expect(operation.isDone)
    #expect(!operation.hasError)
    #expect(operation.progress == 100)
}

@Test func testGoogleCloudOperationWithError() throws {
    let json = """
    {
        "kind": "compute#operation",
        "id": "op-error",
        "name": "failed-operation",
        "status": "DONE",
        "error": {
            "errors": [
                {
                    "code": "RESOURCE_NOT_FOUND",
                    "message": "The resource 'projects/my-project/zones/us-central1-a/instances/missing' was not found"
                }
            ]
        }
    }
    """

    let decoder = JSONDecoder()
    let operation = try decoder.decode(GoogleCloudOperation.self, from: Data(json.utf8))

    #expect(operation.isDone)
    #expect(operation.hasError)
    #expect(operation.errorMessage?.contains("was not found") == true)
}

@Test func testSerialPortOutputDecoding() throws {
    let json = """
    {
        "contents": "Boot sequence started...",
        "next": 1024,
        "start": 0
    }
    """

    let decoder = JSONDecoder()
    let output = try decoder.decode(SerialPortOutput.self, from: Data(json.utf8))

    #expect(output.contents == "Boot sequence started...")
    #expect(output.next == 1024)
    #expect(output.start == 0)
}

// MARK: - Mock Helper Extensions

extension MockComputeAPI {
    func setListInstancesHandler(_ handler: @escaping (String, String?, Int?, String?) async throws -> GoogleCloudListResponse<ComputeInstance>) {
        listInstancesHandler = handler
    }

    func setGetInstanceHandler(_ handler: @escaping (String, String) async throws -> ComputeInstance) {
        getInstanceHandler = handler
    }

    func setListZonesHandler(_ handler: @escaping (String?, Int?, String?) async throws -> GoogleCloudListResponse<Zone>) {
        listZonesHandler = handler
    }
}
