import Foundation
import AsyncHTTPClient

// MARK: - Compute Engine API Client

/// A client for interacting with the Google Cloud Compute Engine REST API.
///
/// This client provides direct REST API access to Compute Engine resources
/// without requiring the gcloud CLI.
///
/// ## Example Usage
/// ```swift
/// let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
/// defer { try? httpClient.syncShutdown() }
///
/// let authClient = try GoogleCloudAuthClient(
///     credentialsPath: "/path/to/service-account.json",
///     httpClient: httpClient,
///     scopes: GoogleCloudAuthClient.computeScopes
/// )
///
/// let computeAPI = GoogleCloudComputeAPI(
///     authClient: authClient,
///     httpClient: httpClient,
///     projectId: "my-project"
/// )
///
/// // List instances in a zone
/// let instances = try await computeAPI.listInstances(zone: "us-central1-a")
/// ```
public actor GoogleCloudComputeAPI {
    private let client: GoogleCloudHTTPClient
    private let projectId: String

    private static let baseURL = "https://compute.googleapis.com"

    /// Initialize the Compute Engine API client.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - projectId: The Google Cloud project ID.
    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        projectId: String
    ) {
        self.projectId = projectId
        self.client = GoogleCloudHTTPClient(
            authClient: authClient,
            httpClient: httpClient,
            baseURL: Self.baseURL
        )
    }

    /// Create a Compute Engine API client, inferring project ID from auth credentials.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    /// - Returns: A configured Compute Engine API client.
    public static func create(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient
    ) async -> GoogleCloudComputeAPI {
        let projectId = await authClient.projectId
        return GoogleCloudComputeAPI(
            authClient: authClient,
            httpClient: httpClient,
            projectId: projectId
        )
    }

    // MARK: - Instances

    /// List all instances in a zone.
    /// - Parameters:
    ///   - zone: The zone to list instances from.
    ///   - filter: Optional filter expression.
    ///   - maxResults: Maximum number of results to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list response containing instances.
    public func listInstances(
        zone: String,
        filter: String? = nil,
        maxResults: Int? = nil,
        pageToken: String? = nil
    ) async throws -> GoogleCloudListResponse<ComputeInstance> {
        var params: [String: String] = [:]
        if let filter = filter { params["filter"] = filter }
        if let maxResults = maxResults { params["maxResults"] = String(maxResults) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<ComputeInstance>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get details of a specific instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    /// - Returns: The instance details.
    public func getInstance(name: String, zone: String) async throws -> ComputeInstance {
        let response: GoogleCloudAPIResponse<ComputeInstance> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)"
        )
        return response.data
    }

    /// Create a new instance.
    /// - Parameters:
    ///   - instance: The instance configuration.
    ///   - zone: The zone to create the instance in.
    /// - Returns: The operation for tracking instance creation.
    public func createInstance(
        _ instance: ComputeInstanceInsert,
        zone: String
    ) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances",
            body: instance
        )
        return response.data
    }

    /// Create an instance from a GoogleCloudComputeInstance configuration.
    /// - Parameters:
    ///   - config: The instance configuration model.
    /// - Returns: The operation for tracking instance creation.
    public func createInstance(from config: GoogleCloudComputeInstance) async throws -> GoogleCloudOperation {
        let insert = ComputeInstanceInsert(from: config, projectId: projectId)
        return try await createInstance(insert, zone: config.zone)
    }

    /// Delete an instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    /// - Returns: The operation for tracking instance deletion.
    public func deleteInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.delete(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)"
        )
        return response.data
    }

    /// Start a stopped instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    /// - Returns: The operation for tracking the start.
    public func startInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)/start"
        )
        return response.data
    }

    /// Stop a running instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    /// - Returns: The operation for tracking the stop.
    public func stopInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)/stop"
        )
        return response.data
    }

    /// Reset an instance (hard restart).
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    /// - Returns: The operation for tracking the reset.
    public func resetInstance(name: String, zone: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)/reset"
        )
        return response.data
    }

    /// Set labels on an instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    ///   - labels: The labels to set.
    ///   - labelFingerprint: The current label fingerprint (from getInstance).
    /// - Returns: The operation for tracking the update.
    public func setLabels(
        name: String,
        zone: String,
        labels: [String: String],
        labelFingerprint: String
    ) async throws -> GoogleCloudOperation {
        let body = SetLabelsRequest(labels: labels, labelFingerprint: labelFingerprint)
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)/setLabels",
            body: body
        )
        return response.data
    }

    /// Set metadata on an instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    ///   - items: The metadata items to set.
    ///   - fingerprint: The current metadata fingerprint (from getInstance).
    /// - Returns: The operation for tracking the update.
    public func setMetadata(
        name: String,
        zone: String,
        items: [MetadataItemInsert],
        fingerprint: String
    ) async throws -> GoogleCloudOperation {
        let body = SetMetadataRequest(items: items, fingerprint: fingerprint)
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)/setMetadata",
            body: body
        )
        return response.data
    }

    /// Get the serial port output from an instance.
    /// - Parameters:
    ///   - name: The instance name.
    ///   - zone: The zone where the instance is located.
    ///   - port: The port number (1-4, defaults to 1).
    ///   - start: The byte position to start reading from. Use -1 to get only new output since last call.
    /// - Returns: The serial port output.
    public func getSerialPortOutput(
        name: String,
        zone: String,
        port: Int = 1,
        start: Int64? = nil
    ) async throws -> SerialPortOutput {
        var params: [String: String] = ["port": String(port)]
        if let start = start { params["start"] = String(start) }

        let response: GoogleCloudAPIResponse<SerialPortOutput> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/instances/\(name)/serialPort",
            queryParameters: params
        )
        return response.data
    }

    // MARK: - Pagination Helpers

    /// Get a pagination helper for listing all instances in a zone.
    /// - Parameters:
    ///   - zone: The zone to list instances from.
    ///   - filter: Optional filter expression.
    ///   - maxResults: Maximum number of results per page.
    /// - Returns: A pagination helper that can be used to iterate through all pages.
    public func listAllInstances(
        zone: String,
        filter: String? = nil,
        maxResults: Int? = nil
    ) -> PaginationHelper<ComputeInstance> {
        PaginationHelper { pageToken in
            try await self.listInstances(
                zone: zone,
                filter: filter,
                maxResults: maxResults,
                pageToken: pageToken
            )
        }
    }

    /// Get a pagination helper for listing all machine types in a zone.
    /// - Parameters:
    ///   - zone: The zone to list machine types for.
    ///   - filter: Optional filter expression.
    ///   - maxResults: Maximum number of results per page.
    /// - Returns: A pagination helper that can be used to iterate through all pages.
    public func listAllMachineTypes(
        zone: String,
        filter: String? = nil,
        maxResults: Int? = nil
    ) -> PaginationHelper<MachineType> {
        PaginationHelper { pageToken in
            try await self.listMachineTypes(
                zone: zone,
                filter: filter,
                maxResults: maxResults
            )
        }
    }

    // MARK: - Zone Operations

    /// Get the status of a zone operation.
    /// - Parameters:
    ///   - operationName: The operation name.
    ///   - zone: The zone where the operation is running.
    /// - Returns: The operation status.
    public func getZoneOperation(operationName: String, zone: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/operations/\(operationName)"
        )
        return response.data
    }

    /// Wait for a zone operation to complete.
    /// - Parameters:
    ///   - operationName: The operation name.
    ///   - zone: The zone where the operation is running.
    ///   - timeout: Maximum time to wait in seconds.
    ///   - pollInterval: Interval between status checks in seconds.
    /// - Returns: The completed operation.
    /// - Throws: `GoogleCloudAPIError.cancelled` if the task is cancelled.
    public func waitForZoneOperation(
        operationName: String,
        zone: String,
        timeout: TimeInterval = 300,
        pollInterval: TimeInterval = 5
    ) async throws -> GoogleCloudOperation {
        let startTime = Date()

        while true {
            // Check for task cancellation
            try Task.checkCancellation()

            let operation = try await getZoneOperation(operationName: operationName, zone: zone)

            if operation.isDone {
                if operation.hasError {
                    throw GoogleCloudAPIError.requestFailed("Operation failed: \(operation.errorMessage ?? "Unknown error")")
                }
                return operation
            }

            if Date().timeIntervalSince(startTime) > timeout {
                throw GoogleCloudAPIError.requestFailed("Operation timed out after \(timeout) seconds")
            }

            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
    }

    // MARK: - Global Operations

    /// Get the status of a global operation.
    /// - Parameter operationName: The operation name.
    /// - Returns: The operation status.
    public func getGlobalOperation(operationName: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/global/operations/\(operationName)"
        )
        return response.data
    }

    /// Wait for a global operation to complete.
    /// - Parameters:
    ///   - operationName: The operation name.
    ///   - timeout: Maximum time to wait in seconds.
    ///   - pollInterval: Interval between status checks in seconds.
    /// - Returns: The completed operation.
    /// - Throws: `GoogleCloudAPIError.cancelled` if the task is cancelled.
    public func waitForGlobalOperation(
        operationName: String,
        timeout: TimeInterval = 300,
        pollInterval: TimeInterval = 5
    ) async throws -> GoogleCloudOperation {
        let startTime = Date()

        while true {
            // Check for task cancellation
            try Task.checkCancellation()

            let operation = try await getGlobalOperation(operationName: operationName)

            if operation.isDone {
                if operation.hasError {
                    throw GoogleCloudAPIError.requestFailed("Operation failed: \(operation.errorMessage ?? "Unknown error")")
                }
                return operation
            }

            if Date().timeIntervalSince(startTime) > timeout {
                throw GoogleCloudAPIError.requestFailed("Operation timed out after \(timeout) seconds")
            }

            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
    }

    // MARK: - Regional Operations

    /// Get the status of a regional operation.
    /// - Parameters:
    ///   - operationName: The operation name.
    ///   - region: The region where the operation is running.
    /// - Returns: The operation status.
    public func getRegionOperation(operationName: String, region: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/regions/\(region)/operations/\(operationName)"
        )
        return response.data
    }

    /// Wait for a regional operation to complete.
    /// - Parameters:
    ///   - operationName: The operation name.
    ///   - region: The region where the operation is running.
    ///   - timeout: Maximum time to wait in seconds.
    ///   - pollInterval: Interval between status checks in seconds.
    /// - Returns: The completed operation.
    /// - Throws: `GoogleCloudAPIError.cancelled` if the task is cancelled.
    public func waitForRegionOperation(
        operationName: String,
        region: String,
        timeout: TimeInterval = 300,
        pollInterval: TimeInterval = 5
    ) async throws -> GoogleCloudOperation {
        let startTime = Date()

        while true {
            // Check for task cancellation
            try Task.checkCancellation()

            let operation = try await getRegionOperation(operationName: operationName, region: region)

            if operation.isDone {
                if operation.hasError {
                    throw GoogleCloudAPIError.requestFailed("Operation failed: \(operation.errorMessage ?? "Unknown error")")
                }
                return operation
            }

            if Date().timeIntervalSince(startTime) > timeout {
                throw GoogleCloudAPIError.requestFailed("Operation timed out after \(timeout) seconds")
            }

            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
    }

    /// Wait for an operation to complete, automatically detecting whether it's zonal, regional, or global.
    /// - Parameters:
    ///   - operation: The operation to wait for.
    ///   - timeout: Maximum time to wait in seconds.
    ///   - pollInterval: Interval between status checks in seconds.
    /// - Returns: The completed operation.
    /// - Throws: `GoogleCloudAPIError.cancelled` if the task is cancelled.
    public func waitForOperation(
        _ operation: GoogleCloudOperation,
        timeout: TimeInterval = 300,
        pollInterval: TimeInterval = 5
    ) async throws -> GoogleCloudOperation {
        guard let name = operation.name else {
            throw GoogleCloudAPIError.requestFailed("Operation has no name")
        }

        // Determine operation scope from the selfLink or zone/region fields
        if let zone = operation.zone {
            // Extract zone name from URL if needed
            let zoneName = zone.components(separatedBy: "/").last ?? zone
            return try await waitForZoneOperation(
                operationName: name,
                zone: zoneName,
                timeout: timeout,
                pollInterval: pollInterval
            )
        } else if let region = operation.region {
            // Extract region name from URL if needed
            let regionName = region.components(separatedBy: "/").last ?? region
            return try await waitForRegionOperation(
                operationName: name,
                region: regionName,
                timeout: timeout,
                pollInterval: pollInterval
            )
        } else {
            // Global operation
            return try await waitForGlobalOperation(
                operationName: name,
                timeout: timeout,
                pollInterval: pollInterval
            )
        }
    }

    // MARK: - Machine Types

    /// List available machine types in a zone.
    /// - Parameters:
    ///   - zone: The zone to list machine types for.
    ///   - filter: Optional filter expression.
    ///   - maxResults: Maximum number of results to return.
    /// - Returns: A list of machine types.
    public func listMachineTypes(
        zone: String,
        filter: String? = nil,
        maxResults: Int? = nil
    ) async throws -> GoogleCloudListResponse<MachineType> {
        var params: [String: String] = [:]
        if let filter = filter { params["filter"] = filter }
        if let maxResults = maxResults { params["maxResults"] = String(maxResults) }

        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<MachineType>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/machineTypes",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get details of a specific machine type.
    /// - Parameters:
    ///   - name: The machine type name (e.g., "e2-medium").
    ///   - zone: The zone.
    /// - Returns: The machine type details.
    public func getMachineType(name: String, zone: String) async throws -> MachineType {
        let response: GoogleCloudAPIResponse<MachineType> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/machineTypes/\(name)"
        )
        return response.data
    }

    // MARK: - Zones

    /// List all zones in the project.
    /// - Returns: A list of zones.
    public func listZones() async throws -> GoogleCloudListResponse<Zone> {
        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<Zone>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones"
        )
        return response.data
    }

    /// Get details of a specific zone.
    /// - Parameter name: The zone name.
    /// - Returns: The zone details.
    public func getZone(name: String) async throws -> Zone {
        let response: GoogleCloudAPIResponse<Zone> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(name)"
        )
        return response.data
    }

    // MARK: - Regions

    /// List all regions.
    /// - Returns: A list of regions.
    public func listRegions() async throws -> GoogleCloudListResponse<Region> {
        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<Region>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/regions"
        )
        return response.data
    }

    /// Get details of a specific region.
    /// - Parameter name: The region name.
    /// - Returns: The region details.
    public func getRegion(name: String) async throws -> Region {
        let response: GoogleCloudAPIResponse<Region> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/regions/\(name)"
        )
        return response.data
    }

    // MARK: - Disks

    /// List disks in a zone.
    /// - Parameters:
    ///   - zone: The zone.
    ///   - filter: Optional filter expression.
    /// - Returns: A list of disks.
    public func listDisks(zone: String, filter: String? = nil) async throws -> GoogleCloudListResponse<Disk> {
        var params: [String: String] = [:]
        if let filter = filter { params["filter"] = filter }

        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<Disk>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/disks",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a specific disk.
    /// - Parameters:
    ///   - name: The disk name.
    ///   - zone: The zone.
    /// - Returns: The disk details.
    public func getDisk(name: String, zone: String) async throws -> Disk {
        let response: GoogleCloudAPIResponse<Disk> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/zones/\(zone)/disks/\(name)"
        )
        return response.data
    }

    // MARK: - Networks

    /// List VPC networks.
    /// - Returns: A list of networks.
    public func listNetworks() async throws -> GoogleCloudListResponse<Network> {
        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<Network>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/global/networks"
        )
        return response.data
    }

    /// Get a specific network.
    /// - Parameter name: The network name.
    /// - Returns: The network details.
    public func getNetwork(name: String) async throws -> Network {
        let response: GoogleCloudAPIResponse<Network> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/global/networks/\(name)"
        )
        return response.data
    }

    // MARK: - Firewalls

    /// List firewall rules.
    /// - Returns: A list of firewall rules.
    public func listFirewalls() async throws -> GoogleCloudListResponse<Firewall> {
        let response: GoogleCloudAPIResponse<GoogleCloudListResponse<Firewall>> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/global/firewalls"
        )
        return response.data
    }

    /// Get a specific firewall rule.
    /// - Parameter name: The firewall name.
    /// - Returns: The firewall details.
    public func getFirewall(name: String) async throws -> Firewall {
        let response: GoogleCloudAPIResponse<Firewall> = try await client.get(
            path: "/compute/v1/projects/\(projectId)/global/firewalls/\(name)"
        )
        return response.data
    }

    /// Create a firewall rule.
    /// - Parameter firewall: The firewall configuration.
    /// - Returns: The operation for tracking creation.
    public func createFirewall(_ firewall: FirewallInsert) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.post(
            path: "/compute/v1/projects/\(projectId)/global/firewalls",
            body: firewall
        )
        return response.data
    }

    /// Delete a firewall rule.
    /// - Parameter name: The firewall name.
    /// - Returns: The operation for tracking deletion.
    public func deleteFirewall(name: String) async throws -> GoogleCloudOperation {
        let response: GoogleCloudAPIResponse<GoogleCloudOperation> = try await client.delete(
            path: "/compute/v1/projects/\(projectId)/global/firewalls/\(name)"
        )
        return response.data
    }
}

// MARK: - API Response Types

/// Compute Engine instance from the API.
public struct ComputeInstance: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let zone: String?
    public let machineType: String?
    public let status: String?
    public let statusMessage: String?
    public let selfLink: String?
    public let creationTimestamp: String?
    public let networkInterfaces: [NetworkInterface]?
    public let disks: [AttachedDisk]?
    public let metadata: Metadata?
    public let tags: Tags?
    public let labels: [String: String]?
    public let labelFingerprint: String?
    public let scheduling: Scheduling?
    public let serviceAccounts: [ServiceAccount]?
    public let cpuPlatform: String?
    public let canIpForward: Bool?
    public let deletionProtection: Bool?
    public let fingerprint: String?
}

public struct NetworkInterface: Codable, Sendable {
    public let name: String?
    public let network: String?
    public let subnetwork: String?
    public let networkIP: String?
    public let accessConfigs: [AccessConfig]?
    public let fingerprint: String?
}

public struct AccessConfig: Codable, Sendable {
    public let type: String?
    public let name: String?
    public let natIP: String?
    public let networkTier: String?
}

public struct AttachedDisk: Codable, Sendable {
    public let type: String?
    public let mode: String?
    public let source: String?
    public let deviceName: String?
    public let index: Int?
    public let boot: Bool?
    public let autoDelete: Bool?
    public let licenses: [String]?
    public let interface: String?
    public let diskSizeGb: String?
    public let initializeParams: InitializeParams?
}

public struct InitializeParams: Codable, Sendable {
    public let diskName: String?
    public let sourceImage: String?
    public let diskSizeGb: String?
    public let diskType: String?
}

public struct Metadata: Codable, Sendable {
    public let fingerprint: String?
    public let items: [MetadataItem]?
}

public struct MetadataItem: Codable, Sendable {
    public let key: String?
    public let value: String?
}

public struct Tags: Codable, Sendable {
    public let items: [String]?
    public let fingerprint: String?
}

public struct Scheduling: Codable, Sendable {
    public let onHostMaintenance: String?
    public let automaticRestart: Bool?
    public let preemptible: Bool?
    public let provisioningModel: String?
}

public struct ServiceAccount: Codable, Sendable {
    public let email: String?
    public let scopes: [String]?
}

/// Machine type from the API.
public struct MachineType: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let guestCpus: Int?
    public let memoryMb: Int?
    public let imageSpaceGb: Int?
    public let maximumPersistentDisks: Int?
    public let maximumPersistentDisksSizeGb: String?
    public let zone: String?
    public let selfLink: String?
    public let isSharedCpu: Bool?
    public let creationTimestamp: String?
}

/// Zone from the API.
public struct Zone: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let status: String?
    public let region: String?
    public let selfLink: String?
    public let availableCpuPlatforms: [String]?
    public let creationTimestamp: String?
}

/// Region from the API.
public struct Region: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let status: String?
    public let zones: [String]?
    public let selfLink: String?
    public let creationTimestamp: String?
}

/// Disk from the API.
public struct Disk: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let sizeGb: String?
    public let zone: String?
    public let status: String?
    public let type: String?
    public let sourceImage: String?
    public let selfLink: String?
    public let users: [String]?
    public let labels: [String: String]?
    public let creationTimestamp: String?
}

/// Network from the API.
public struct Network: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let selfLink: String?
    public let autoCreateSubnetworks: Bool?
    public let subnetworks: [String]?
    public let routingConfig: RoutingConfig?
    public let mtu: Int?
    public let creationTimestamp: String?
}

public struct RoutingConfig: Codable, Sendable {
    public let routingMode: String?
}

/// Firewall from the API.
public struct Firewall: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let network: String?
    public let priority: Int?
    public let direction: String?
    public let sourceRanges: [String]?
    public let destinationRanges: [String]?
    public let sourceTags: [String]?
    public let targetTags: [String]?
    public let allowed: [FirewallAllowed]?
    public let denied: [FirewallDenied]?
    public let disabled: Bool?
    public let selfLink: String?
    public let creationTimestamp: String?
}

public struct FirewallAllowed: Codable, Sendable {
    public let ipProtocol: String?
    public let ports: [String]?

    enum CodingKeys: String, CodingKey {
        case ipProtocol = "IPProtocol"
        case ports
    }
}

public struct FirewallDenied: Codable, Sendable {
    public let ipProtocol: String?
    public let ports: [String]?

    enum CodingKeys: String, CodingKey {
        case ipProtocol = "IPProtocol"
        case ports
    }
}

// MARK: - Request Types

/// Request body for creating an instance.
public struct ComputeInstanceInsert: Encodable, Sendable {
    public let name: String
    public let machineType: String
    public let disks: [DiskInsert]
    public let networkInterfaces: [NetworkInterfaceInsert]
    public let metadata: MetadataInsert?
    public let tags: TagsInsert?
    public let labels: [String: String]?
    public let scheduling: SchedulingInsert?
    public let serviceAccounts: [ServiceAccountInsert]?
    public let deletionProtection: Bool?

    public init(
        name: String,
        machineType: String,
        zone: String,
        disks: [DiskInsert],
        networkInterfaces: [NetworkInterfaceInsert],
        metadata: MetadataInsert? = nil,
        tags: TagsInsert? = nil,
        labels: [String: String]? = nil,
        scheduling: SchedulingInsert? = nil,
        serviceAccounts: [ServiceAccountInsert]? = nil,
        deletionProtection: Bool? = nil
    ) {
        self.name = name
        self.machineType = "zones/\(zone)/machineTypes/\(machineType)"
        self.disks = disks
        self.networkInterfaces = networkInterfaces
        self.metadata = metadata
        self.tags = tags
        self.labels = labels
        self.scheduling = scheduling
        self.serviceAccounts = serviceAccounts
        self.deletionProtection = deletionProtection
    }

    /// Create from a GoogleCloudComputeInstance configuration.
    public init(from config: GoogleCloudComputeInstance, projectId: String) {
        self.name = config.name
        self.machineType = "zones/\(config.zone)/machineTypes/\(config.machineType.rawValue)"

        let bootDisk = DiskInsert(
            boot: true,
            autoDelete: config.bootDisk.autoDelete,
            initializeParams: InitializeParamsInsert(
                sourceImage: config.bootDisk.image.rawValue,
                diskSizeGb: String(config.bootDisk.sizeGB),
                diskType: "zones/\(config.zone)/diskTypes/\(config.bootDisk.diskType.rawValue)"
            )
        )
        self.disks = [bootDisk]

        var networkInterface = NetworkInterfaceInsert(
            network: "global/networks/\(config.network.network)",
            subnetwork: config.network.subnetwork
        )
        if config.network.assignExternalIP {
            networkInterface = NetworkInterfaceInsert(
                network: "global/networks/\(config.network.network)",
                subnetwork: config.network.subnetwork,
                accessConfigs: [
                    AccessConfigInsert(
                        type: "ONE_TO_ONE_NAT",
                        name: "External NAT",
                        networkTier: config.network.networkTier.rawValue
                    )
                ]
            )
        }
        self.networkInterfaces = [networkInterface]

        if let script = config.startupScript {
            self.metadata = MetadataInsert(items: [
                MetadataItemInsert(key: "startup-script", value: script)
            ])
        } else {
            self.metadata = nil
        }

        if !config.networkTags.isEmpty {
            self.tags = TagsInsert(items: config.networkTags)
        } else {
            self.tags = nil
        }

        self.labels = config.labels.isEmpty ? nil : config.labels

        self.scheduling = SchedulingInsert(
            onHostMaintenance: config.scheduling.onHostMaintenance.rawValue,
            automaticRestart: config.scheduling.automaticRestart,
            preemptible: config.scheduling.preemptible,
            provisioningModel: config.scheduling.spot ? "SPOT" : "STANDARD"
        )

        if let sa = config.serviceAccount {
            self.serviceAccounts = [ServiceAccountInsert(email: sa.email, scopes: sa.scopes)]
        } else {
            self.serviceAccounts = nil
        }

        self.deletionProtection = config.deletionProtection
    }
}

public struct DiskInsert: Encodable, Sendable {
    public let boot: Bool?
    public let autoDelete: Bool?
    public let initializeParams: InitializeParamsInsert?

    public init(boot: Bool? = nil, autoDelete: Bool? = nil, initializeParams: InitializeParamsInsert? = nil) {
        self.boot = boot
        self.autoDelete = autoDelete
        self.initializeParams = initializeParams
    }
}

public struct InitializeParamsInsert: Encodable, Sendable {
    public let sourceImage: String?
    public let diskSizeGb: String?
    public let diskType: String?

    public init(sourceImage: String? = nil, diskSizeGb: String? = nil, diskType: String? = nil) {
        self.sourceImage = sourceImage
        self.diskSizeGb = diskSizeGb
        self.diskType = diskType
    }
}

public struct NetworkInterfaceInsert: Encodable, Sendable {
    public let network: String?
    public let subnetwork: String?
    public let accessConfigs: [AccessConfigInsert]?

    public init(network: String? = nil, subnetwork: String? = nil, accessConfigs: [AccessConfigInsert]? = nil) {
        self.network = network
        self.subnetwork = subnetwork
        self.accessConfigs = accessConfigs
    }
}

public struct AccessConfigInsert: Encodable, Sendable {
    public let type: String?
    public let name: String?
    public let networkTier: String?

    public init(type: String? = nil, name: String? = nil, networkTier: String? = nil) {
        self.type = type
        self.name = name
        self.networkTier = networkTier
    }
}

public struct MetadataInsert: Encodable, Sendable {
    public let items: [MetadataItemInsert]?

    public init(items: [MetadataItemInsert]? = nil) {
        self.items = items
    }
}

public struct MetadataItemInsert: Encodable, Sendable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct TagsInsert: Encodable, Sendable {
    public let items: [String]?

    public init(items: [String]? = nil) {
        self.items = items
    }
}

public struct SchedulingInsert: Encodable, Sendable {
    public let onHostMaintenance: String?
    public let automaticRestart: Bool?
    public let preemptible: Bool?
    public let provisioningModel: String?

    public init(
        onHostMaintenance: String? = nil,
        automaticRestart: Bool? = nil,
        preemptible: Bool? = nil,
        provisioningModel: String? = nil
    ) {
        self.onHostMaintenance = onHostMaintenance
        self.automaticRestart = automaticRestart
        self.preemptible = preemptible
        self.provisioningModel = provisioningModel
    }
}

public struct ServiceAccountInsert: Encodable, Sendable {
    public let email: String
    public let scopes: [String]

    public init(email: String, scopes: [String]) {
        self.email = email
        self.scopes = scopes
    }
}

/// Request body for creating a firewall rule.
public struct FirewallInsert: Encodable, Sendable {
    public let name: String
    public let network: String
    public let description: String?
    public let priority: Int?
    public let direction: String?
    public let sourceRanges: [String]?
    public let targetTags: [String]?
    public let allowed: [FirewallAllowedInsert]?

    public init(
        name: String,
        network: String = "global/networks/default",
        description: String? = nil,
        priority: Int? = 1000,
        direction: String? = "INGRESS",
        sourceRanges: [String]? = nil,
        targetTags: [String]? = nil,
        allowed: [FirewallAllowedInsert]? = nil
    ) {
        self.name = name
        self.network = network
        self.description = description
        self.priority = priority
        self.direction = direction
        self.sourceRanges = sourceRanges
        self.targetTags = targetTags
        self.allowed = allowed
    }
}

public struct FirewallAllowedInsert: Encodable, Sendable {
    public let ipProtocol: String
    public let ports: [String]?

    enum CodingKeys: String, CodingKey {
        case ipProtocol = "IPProtocol"
        case ports
    }

    public init(ipProtocol: String, ports: [String]? = nil) {
        self.ipProtocol = ipProtocol
        self.ports = ports
    }
}

struct SetLabelsRequest: Encodable, Sendable {
    let labels: [String: String]
    let labelFingerprint: String
}

struct SetMetadataRequest: Encodable, Sendable {
    let items: [MetadataItemInsert]
    let fingerprint: String
}

/// Serial port output from an instance.
public struct SerialPortOutput: Codable, Sendable {
    /// The content of the serial port output.
    public let contents: String?
    /// The byte position of the next output.
    public let next: Int64?
    /// The byte position of the start of this output.
    public let start: Int64?
    /// The instance selfLink.
    public let selfLink: String?
}
