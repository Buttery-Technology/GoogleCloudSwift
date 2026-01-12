//
//  GoogleCloudProtocols.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation

/// Protocol for Google Cloud authentication clients.
///
/// Implement this protocol to create mock authentication clients for testing.
///
/// ## Example Mock Implementation
/// ```swift
/// actor MockAuthClient: GoogleCloudAuthClientProtocol {
///     var projectId: String { "test-project" }
///     var serviceAccountEmail: String { "test@test-project.iam.gserviceaccount.com" }
///
///     func getAccessToken() async throws -> GoogleCloudAccessToken {
///         GoogleCloudAccessToken(
///             token: "mock-token",
///             tokenType: "Bearer",
///             expiresAt: Date().addingTimeInterval(3600)
///         )
///     }
///
///     func refreshToken() async throws -> GoogleCloudAccessToken {
///         try await getAccessToken()
///     }
/// }
/// ```
public protocol GoogleCloudAuthClientProtocol: Actor, Sendable {
    /// The Google Cloud project ID from the credentials.
    var projectId: String { get }

    /// The service account email from the credentials.
    var serviceAccountEmail: String { get }

    /// Get a valid access token, refreshing if necessary.
    func getAccessToken() async throws -> GoogleCloudAccessToken

    /// Force refresh the access token.
    func refreshToken() async throws -> GoogleCloudAccessToken
}

// Conform the real auth client to the protocol
extension GoogleCloudAuthClient: GoogleCloudAuthClientProtocol {}

// MARK: - Storage API Protocol

/// Protocol for Cloud Storage API operations.
///
/// Implement this protocol to create mock storage clients for testing.
public protocol GoogleCloudStorageAPIProtocol: Actor, Sendable {
    /// The Google Cloud project ID.
    var projectId: String { get }

    // Bucket operations
    func listBuckets(prefix: String?, maxResults: Int?, pageToken: String?) async throws -> StorageBucketList
    func getBucket(name: String) async throws -> StorageBucket
    func createBucket(_ bucket: CreateBucketRequest) async throws -> StorageBucket
    func deleteBucket(name: String) async throws

    // Object operations
    func listObjects(bucket: String, prefix: String?, delimiter: String?, maxResults: Int?, pageToken: String?) async throws -> StorageObjectList
    func getObject(bucket: String, name: String) async throws -> StorageObject
    func downloadObject(bucket: String, name: String) async throws -> Data
    func uploadObjectSimple(bucket: String, name: String, data: Data, contentType: String) async throws -> StorageObject
    func deleteObject(bucket: String, name: String) async throws
}

// MARK: - Compute API Protocol

/// Protocol for Compute Engine API operations.
///
/// Implement this protocol to create mock compute clients for testing.
public protocol GoogleCloudComputeAPIProtocol: Actor, Sendable {
    /// The Google Cloud project ID.
    var projectId: String { get }

    // Instance operations
    func listInstances(zone: String, filter: String?, maxResults: Int?, pageToken: String?) async throws -> GoogleCloudListResponse<ComputeInstance>
    func getInstance(name: String, zone: String) async throws -> ComputeInstance
    func createInstance(_ instance: ComputeInstanceInsert, zone: String) async throws -> GoogleCloudOperation
    func deleteInstance(name: String, zone: String) async throws -> GoogleCloudOperation
    func startInstance(name: String, zone: String) async throws -> GoogleCloudOperation
    func stopInstance(name: String, zone: String) async throws -> GoogleCloudOperation

    // Zone operations
    func listZones(filter: String?, maxResults: Int?, pageToken: String?) async throws -> GoogleCloudListResponse<Zone>
    func getZone(name: String) async throws -> Zone

    // Operation polling
    func waitForZoneOperation(operationName: String, zone: String, timeout: TimeInterval, pollInterval: TimeInterval) async throws -> GoogleCloudOperation
}

// MARK: - Secret Manager API Protocol

/// Protocol for Secret Manager API operations.
///
/// Implement this protocol to create mock secret manager clients for testing.
public protocol GoogleCloudSecretManagerAPIProtocol: Actor, Sendable {
    /// The Google Cloud project ID.
    var projectId: String { get }

    // Secret operations
    func listSecrets(filter: String?, pageSize: Int?, pageToken: String?) async throws -> SecretListResponse
    func getSecret(secretId: String) async throws -> Secret
    func createSecret(secretId: String, replication: SecretReplication, labels: [String: String]?) async throws -> Secret
    func deleteSecret(secretId: String) async throws

    // Version operations
    func addSecretVersion(secretId: String, data: Data) async throws -> SecretVersion
    func getSecretVersion(secretId: String, version: String) async throws -> SecretVersion
    func accessSecretVersion(secretId: String, version: String) async throws -> Data
    func destroySecretVersion(secretId: String, version: String) async throws -> SecretVersion
}

// MARK: - Cloud Run API Protocol

/// Protocol for Cloud Run API operations.
///
/// Implement this protocol to create mock Cloud Run clients for testing.
public protocol GoogleCloudRunAPIProtocol: Actor, Sendable {
    /// The Google Cloud project ID.
    var projectId: String { get }

    // Service operations
    func listServices(location: String, pageSize: Int?, pageToken: String?, showDeleted: Bool) async throws -> RunServiceListResponse
    func getService(location: String, serviceId: String) async throws -> RunService
    func createService(location: String, serviceId: String, service: RunServiceRequest, validateOnly: Bool) async throws -> RunOperation
    func updateService(location: String, serviceId: String, service: RunServiceRequest, allowMissing: Bool) async throws -> RunOperation
    func deleteService(location: String, serviceId: String, validateOnly: Bool) async throws -> RunOperation

    // Job operations
    func listJobs(location: String, pageSize: Int?, pageToken: String?, showDeleted: Bool) async throws -> RunJobListResponse
    func getJob(location: String, jobId: String) async throws -> RunJob
    func createJob(location: String, jobId: String, job: RunJobRequest, validateOnly: Bool) async throws -> RunOperation
    func runJob(location: String, jobId: String, overrides: RunJobOverrides?, validateOnly: Bool) async throws -> RunOperation
    func deleteJob(location: String, jobId: String, validateOnly: Bool) async throws -> RunOperation

    // Operation polling
    func waitForOperation(_ operation: RunOperation, timeout: TimeInterval, pollInterval: TimeInterval) async throws -> RunOperation
}

// Conform the real Cloud Run API to the protocol
extension GoogleCloudRunAPI: GoogleCloudRunAPIProtocol {}

// MARK: - IAM API Protocol

/// Protocol for IAM API operations.
///
/// Implement this protocol to create mock IAM clients for testing.
public protocol GoogleCloudIAMAPIProtocol: Actor, Sendable {
    /// The Google Cloud project ID.
    var projectId: String { get }

    // Service account operations
    func listServiceAccounts(pageSize: Int?, pageToken: String?) async throws -> IAMServiceAccountListResponse
    func getServiceAccount(email: String) async throws -> IAMServiceAccount
    func createServiceAccount(accountId: String, displayName: String?, description: String?) async throws -> IAMServiceAccount
    func deleteServiceAccount(email: String) async throws

    // Key operations
    func listServiceAccountKeys(email: String, keyTypes: [IAMKeyType]?) async throws -> IAMServiceAccountKeyListResponse
    func createServiceAccountKey(email: String, keyAlgorithm: IAMKeyAlgorithm, privateKeyType: IAMPrivateKeyType) async throws -> IAMServiceAccountKey
    func deleteServiceAccountKey(email: String, keyId: String) async throws

    // Policy operations
    func getProjectIAMPolicy(requestedPolicyVersion: Int?) async throws -> IAMPolicy
    func setProjectIAMPolicy(policy: IAMPolicy, updateMask: String?) async throws -> IAMPolicy
    func testProjectIAMPermissions(permissions: [String]) async throws -> IAMTestPermissionsResponse
}

// Conform the real IAM API to the protocol
extension GoogleCloudIAMAPI: GoogleCloudIAMAPIProtocol {}

// MARK: - Logging API Protocol

/// Protocol for Cloud Logging API operations.
///
/// Implement this protocol to create mock logging clients for testing.
public protocol GoogleCloudLoggingAPIProtocol: Actor, Sendable {
    /// The Google Cloud project ID.
    var projectId: String { get }

    // Entry operations
    @discardableResult
    func writeLogEntries(logName: String, entries: [LoggingLogEntry], resource: LoggingMonitoredResource?, labels: [String: String]?, partialSuccess: Bool, dryRun: Bool) async throws -> LoggingWriteResponse
    func listLogEntries(filter: String?, orderBy: String?, pageSize: Int?, pageToken: String?, resourceNames: [String]?) async throws -> LoggingEntryListResponse

    // Log operations
    func listLogs(pageSize: Int?, pageToken: String?, resourceNames: [String]?) async throws -> LoggingLogListResponse
    func deleteLog(logName: String) async throws

    // Sink operations
    func listSinks(pageSize: Int?, pageToken: String?) async throws -> LoggingSinkListResponse
    func getSink(sinkName: String) async throws -> LoggingSink
    func createSink(sink: LoggingSinkRequest, uniqueWriterIdentity: Bool) async throws -> LoggingSink
    func deleteSink(sinkName: String) async throws

    // Metric operations
    func listMetrics(pageSize: Int?, pageToken: String?) async throws -> LoggingMetricListResponse
    func getMetric(metricName: String) async throws -> LoggingMetric
    func createMetric(metric: LoggingMetricRequest) async throws -> LoggingMetric
    func deleteMetric(metricName: String) async throws
}

// Conform the real Logging API to the protocol
extension GoogleCloudLoggingAPI: GoogleCloudLoggingAPIProtocol {}

// MARK: - Conformance Extensions

extension GoogleCloudStorageAPI: GoogleCloudStorageAPIProtocol {}
extension GoogleCloudComputeAPI: GoogleCloudComputeAPIProtocol {}
extension GoogleCloudSecretManagerAPI: GoogleCloudSecretManagerAPIProtocol {}

// MARK: - Mock Factory Helpers

/// Factory for creating mock implementations for testing.
///
/// ## Example Usage
/// ```swift
/// // Create a mock storage API
/// let mockStorage = MockStorageAPI(projectId: "test-project")
/// mockStorage.stubListBuckets { _ in
///     StorageBucketListResponse(items: [mockBucket], nextPageToken: nil)
/// }
///
/// // Use in tests
/// let service = MyService(storageAPI: mockStorage)
/// ```
public enum GoogleCloudMockFactory {
    /// Create a simple mock access token for testing.
    public static func mockAccessToken(expiresIn: TimeInterval = 3600) -> GoogleCloudAccessToken {
        GoogleCloudAccessToken(
            token: "mock-access-token-\(UUID().uuidString)",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(expiresIn)
        )
    }
}

// MARK: - Test Helpers

/// A simple in-memory mock auth client for testing.
///
/// ## Example Usage
/// ```swift
/// let mockAuth = InMemoryMockAuthClient(projectId: "test-project")
/// let api = await GoogleCloudStorageAPI.create(
///     authClient: mockAuth,
///     httpClient: httpClient
/// )
/// ```
public actor InMemoryMockAuthClient: GoogleCloudAuthClientProtocol {
    public let projectId: String
    public let serviceAccountEmail: String
    private var token: GoogleCloudAccessToken

    public init(
        projectId: String = "test-project",
        serviceAccountEmail: String? = nil
    ) {
        self.projectId = projectId
        self.serviceAccountEmail = serviceAccountEmail ?? "test@\(projectId).iam.gserviceaccount.com"
        self.token = GoogleCloudMockFactory.mockAccessToken()
    }

    public func getAccessToken() async throws -> GoogleCloudAccessToken {
        if token.isExpired {
            token = GoogleCloudMockFactory.mockAccessToken()
        }
        return token
    }

    public func refreshToken() async throws -> GoogleCloudAccessToken {
        token = GoogleCloudMockFactory.mockAccessToken()
        return token
    }
}
