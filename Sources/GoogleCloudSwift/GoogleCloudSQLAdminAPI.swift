import AsyncHTTPClient
import Foundation

// MARK: - Cloud SQL Admin API Client

/// A client for interacting with the Google Cloud SQL Admin REST API.
///
/// Provides direct REST API access to Cloud SQL instances, databases,
/// backups, and users without requiring the gcloud CLI.
///
/// ## Example Usage
/// ```swift
/// let sqlAPI = await GoogleCloudSQLAdminAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
/// let instances = try await sqlAPI.listInstances()
/// ```
public actor GoogleCloudSQLAdminAPI {
	private let client: GoogleCloudHTTPClient
	private let _projectId: String

	public var projectId: String { _projectId }

	private static let baseURL = "https://sqladmin.googleapis.com"

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

	public static func create(
		authClient: GoogleCloudAuthClient,
		httpClient: HTTPClient,
		retryConfiguration: RetryConfiguration = .default,
		requestTimeout: TimeInterval = 60
	) async -> GoogleCloudSQLAdminAPI {
		let projectId = await authClient.projectId
		return GoogleCloudSQLAdminAPI(
			authClient: authClient,
			httpClient: httpClient,
			projectId: projectId,
			retryConfiguration: retryConfiguration,
			requestTimeout: requestTimeout
		)
	}

	// MARK: - Instances

	/// List all Cloud SQL instances in the project.
	public func listInstances(
		filter: String? = nil,
		maxResults: Int? = nil,
		pageToken: String? = nil
	) async throws -> SQLInstancesListResponse {
		var params: [String: String] = [:]
		if let filter { params["filter"] = filter }
		if let maxResults { params["maxResults"] = String(maxResults) }
		if let pageToken { params["pageToken"] = pageToken }

		let response: GoogleCloudAPIResponse<SQLInstancesListResponse> = try await client.get(
			path: "/v1/projects/\(projectId)/instances",
			queryParameters: params.isEmpty ? nil : params
		)
		return response.data
	}

	/// Get details of a specific Cloud SQL instance.
	public func getInstance(name: String) async throws -> SQLDatabaseInstance {
		let response: GoogleCloudAPIResponse<SQLDatabaseInstance> = try await client.get(
			path: "/v1/projects/\(projectId)/instances/\(name)"
		)
		return response.data
	}

	/// Create a new Cloud SQL instance.
	public func createInstance(_ body: SQLDatabaseInstanceInsert) async throws -> SQLOperation {
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.post(
			path: "/v1/projects/\(projectId)/instances",
			body: body
		)
		return response.data
	}

	/// Delete a Cloud SQL instance.
	public func deleteInstance(name: String) async throws -> SQLOperation {
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.delete(
			path: "/v1/projects/\(projectId)/instances/\(name)"
		)
		return response.data
	}

	/// Patch (update) a Cloud SQL instance.
	public func patchInstance(name: String, body: SQLDatabaseInstancePatch) async throws -> SQLOperation {
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.patch(
			path: "/v1/projects/\(projectId)/instances/\(name)",
			body: body
		)
		return response.data
	}

	/// Restart a Cloud SQL instance.
	public func restartInstance(name: String) async throws -> SQLOperation {
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.post(
			path: "/v1/projects/\(projectId)/instances/\(name)/restart"
		)
		return response.data
	}

	/// Start a stopped instance by setting activation policy to ALWAYS.
	public func startInstance(name: String) async throws -> SQLOperation {
		let body = SQLDatabaseInstancePatch(settings: SQLSettingsPatch(activationPolicy: "ALWAYS"))
		return try await patchInstance(name: name, body: body)
	}

	/// Stop an instance by setting activation policy to NEVER.
	public func stopInstance(name: String) async throws -> SQLOperation {
		let body = SQLDatabaseInstancePatch(settings: SQLSettingsPatch(activationPolicy: "NEVER"))
		return try await patchInstance(name: name, body: body)
	}

	// MARK: - Backups

	/// List backup runs for an instance.
	public func listBackupRuns(
		instance: String,
		maxResults: Int? = nil,
		pageToken: String? = nil
	) async throws -> SQLBackupRunsListResponse {
		var params: [String: String] = [:]
		if let maxResults { params["maxResults"] = String(maxResults) }
		if let pageToken { params["pageToken"] = pageToken }

		let response: GoogleCloudAPIResponse<SQLBackupRunsListResponse> = try await client.get(
			path: "/v1/projects/\(projectId)/instances/\(instance)/backupRuns",
			queryParameters: params.isEmpty ? nil : params
		)
		return response.data
	}

	/// Create an on-demand backup.
	public func createBackupRun(instance: String) async throws -> SQLOperation {
		struct BackupRunInsert: Encodable { let instance: String }
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.post(
			path: "/v1/projects/\(projectId)/instances/\(instance)/backupRuns",
			body: BackupRunInsert(instance: instance)
		)
		return response.data
	}

	/// Restore a backup to an instance.
	public func restoreBackup(instance: String, backupRunId: String, project: String? = nil) async throws -> SQLOperation {
		struct RestoreContext: Encodable {
			let backupRunId: String
			let instanceId: String
			let project: String
		}
		struct RestoreRequest: Encodable {
			let restoreBackupContext: RestoreContext
		}

		let request = RestoreRequest(
			restoreBackupContext: RestoreContext(
				backupRunId: backupRunId,
				instanceId: instance,
				project: project ?? projectId
			)
		)

		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.post(
			path: "/v1/projects/\(projectId)/instances/\(instance)/restoreBackup",
			body: request
		)
		return response.data
	}

	// MARK: - Databases

	/// List databases within a Cloud SQL instance.
	public func listDatabases(instance: String) async throws -> SQLDatabasesListResponse {
		let response: GoogleCloudAPIResponse<SQLDatabasesListResponse> = try await client.get(
			path: "/v1/projects/\(projectId)/instances/\(instance)/databases"
		)
		return response.data
	}

	/// Create a database within an instance.
	public func createDatabase(instance: String, name: String, charset: String = "UTF8", collation: String? = nil) async throws -> SQLOperation {
		struct DatabaseInsert: Encodable {
			let instance: String
			let name: String
			let project: String
			let charset: String
			let collation: String?
		}

		let body = DatabaseInsert(instance: instance, name: name, project: projectId, charset: charset, collation: collation)
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.post(
			path: "/v1/projects/\(projectId)/instances/\(instance)/databases",
			body: body
		)
		return response.data
	}

	/// Delete a database within an instance.
	public func deleteDatabase(instance: String, name: String) async throws -> SQLOperation {
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.delete(
			path: "/v1/projects/\(projectId)/instances/\(instance)/databases/\(name)"
		)
		return response.data
	}

	// MARK: - Users

	/// List users for an instance.
	public func listUsers(instance: String) async throws -> SQLUsersListResponse {
		let response: GoogleCloudAPIResponse<SQLUsersListResponse> = try await client.get(
			path: "/v1/projects/\(projectId)/instances/\(instance)/users"
		)
		return response.data
	}

	// MARK: - Operations

	/// Get an operation status.
	public func getOperation(name: String) async throws -> SQLOperation {
		let response: GoogleCloudAPIResponse<SQLOperation> = try await client.get(
			path: "/v1/projects/\(projectId)/operations/\(name)"
		)
		return response.data
	}

	/// Poll an operation until it completes or times out.
	public func waitForOperation(name: String, timeoutSeconds: TimeInterval = 300, pollIntervalSeconds: TimeInterval = 5) async throws -> SQLOperation {
		let deadline = Date().addingTimeInterval(timeoutSeconds)
		while Date() < deadline {
			let op = try await getOperation(name: name)
			if op.status == "DONE" { return op }
			try await Task.sleep(nanoseconds: UInt64(pollIntervalSeconds * 1_000_000_000))
		}
		throw GoogleCloudAPIError.timeout(timeoutSeconds)
	}
}

// MARK: - Response Models

public struct SQLInstancesListResponse: Codable, Sendable {
	public let kind: String?
	public let items: [SQLDatabaseInstance]?
	public let nextPageToken: String?
}

public struct SQLDatabaseInstance: Codable, Sendable {
	public let kind: String?
	public let name: String?
	public let project: String?
	public let state: String?
	public let databaseVersion: String?
	public let region: String?
	public let connectionName: String?
	public let serviceAccountEmailAddress: String?
	public let gceZone: String?
	public let secondaryGceZone: String?
	public let ipAddresses: [SQLIpMapping]?
	public let settings: SQLSettings?
	public let serverCaCert: SQLSslCert?
	public let selfLink: String?
	public let createTime: String?
	public let backendType: String?
	public let instanceType: String?
	public let databaseInstalledVersion: String?
}

public struct SQLIpMapping: Codable, Sendable {
	public let type: String?
	public let ipAddress: String?
	public let timeToRetire: String?
}

public struct SQLSettings: Codable, Sendable {
	public let settingsVersion: String?
	public let tier: String?
	public let edition: String?
	public let activationPolicy: String?
	public let storageAutoResize: Bool?
	public let storageAutoResizeLimit: String?
	public let dataDiskSizeGb: String?
	public let dataDiskType: String?
	public let availabilityType: String?
	public let backupConfiguration: SQLBackupConfiguration?
	public let locationPreference: SQLLocationPreference?
	public let databaseFlags: [SQLDatabaseFlag]?
	public let ipConfiguration: SQLIpConfiguration?
	public let deletionProtectionEnabled: Bool?
	public let maintenanceWindow: SQLMaintenanceWindow?
	public let pricingPlan: String?
}

public struct SQLBackupConfiguration: Codable, Sendable {
	public let enabled: Bool?
	public let startTime: String?
	public let kind: String?
	public let pointInTimeRecoveryEnabled: Bool?
	public let transactionLogRetentionDays: Int?
	public let backupRetentionSettings: SQLBackupRetentionSettings?
}

public struct SQLBackupRetentionSettings: Codable, Sendable {
	public let retentionUnit: String?
	public let retainedBackups: Int?
}

public struct SQLLocationPreference: Codable, Sendable {
	public let zone: String?
	public let secondaryZone: String?
}

public struct SQLDatabaseFlag: Codable, Sendable {
	public let name: String?
	public let value: String?
}

public struct SQLIpConfiguration: Codable, Sendable {
	public let ipv4Enabled: Bool?
	public let privateNetwork: String?
	public let authorizedNetworks: [SQLAclEntry]?
	public let requireSsl: Bool?
}

public struct SQLAclEntry: Codable, Sendable {
	public let value: String?
	public let name: String?
	public let expirationTime: String?
}

public struct SQLMaintenanceWindow: Codable, Sendable {
	public let day: Int?
	public let hour: Int?
	public let updateTrack: String?
}

public struct SQLSslCert: Codable, Sendable {
	public let kind: String?
	public let certSerialNumber: String?
	public let cert: String?
	public let commonName: String?
	public let sha1Fingerprint: String?
	public let instance: String?
	public let createTime: String?
	public let expirationTime: String?
}

// MARK: - Backup Runs

public struct SQLBackupRunsListResponse: Codable, Sendable {
	public let kind: String?
	public let items: [SQLBackupRun]?
	public let nextPageToken: String?
}

public struct SQLBackupRun: Codable, Sendable {
	public let kind: String?
	public let id: String?
	public let status: String?
	public let type: String?
	public let instance: String?
	public let startTime: String?
	public let endTime: String?
	public let windowStartTime: String?
	public let error: SQLOperationError?
	public let selfLink: String?
	public let location: String?
	public let diskEncryptionConfiguration: String?
	public let backupKind: String?
}

// MARK: - Databases

public struct SQLDatabasesListResponse: Codable, Sendable {
	public let kind: String?
	public let items: [SQLDatabase]?
}

public struct SQLDatabase: Codable, Sendable {
	public let kind: String?
	public let name: String?
	public let charset: String?
	public let collation: String?
	public let project: String?
	public let instance: String?
	public let selfLink: String?
	public let etag: String?
}

// MARK: - Users

public struct SQLUsersListResponse: Codable, Sendable {
	public let kind: String?
	public let items: [SQLUser]?
	public let nextPageToken: String?
}

public struct SQLUser: Codable, Sendable {
	public let kind: String?
	public let name: String?
	public let host: String?
	public let instance: String?
	public let project: String?
	public let type: String?
	public let etag: String?
}

// MARK: - Operations

public struct SQLOperation: Codable, Sendable {
	public let kind: String?
	public let name: String?
	public let status: String?
	public let operationType: String?
	public let targetId: String?
	public let targetProject: String?
	public let targetLink: String?
	public let insertTime: String?
	public let startTime: String?
	public let endTime: String?
	public let error: SQLOperationErrors?
	public let selfLink: String?
	public let user: String?
}

public struct SQLOperationErrors: Codable, Sendable {
	public let kind: String?
	public let errors: [SQLOperationError]?
}

public struct SQLOperationError: Codable, Sendable {
	public let kind: String?
	public let code: String?
	public let message: String?
}

// MARK: - Insert / Patch Request Bodies

public struct SQLDatabaseInstanceInsert: Encodable, Sendable {
	public let name: String
	public let project: String
	public let region: String
	public let databaseVersion: String
	public let settings: SQLSettingsInsert
	public let rootPassword: String?

	public init(
		name: String,
		project: String,
		region: String,
		databaseVersion: String,
		settings: SQLSettingsInsert,
		rootPassword: String? = nil
	) {
		self.name = name
		self.project = project
		self.region = region
		self.databaseVersion = databaseVersion
		self.settings = settings
		self.rootPassword = rootPassword
	}
}

public struct SQLSettingsInsert: Encodable, Sendable {
	public let tier: String
	public let edition: String?
	public let activationPolicy: String?
	public let availabilityType: String?
	public let dataDiskSizeGb: String?
	public let dataDiskType: String?
	public let storageAutoResize: Bool?
	public let backupConfiguration: SQLBackupConfigurationInsert?
	public let ipConfiguration: SQLIpConfigurationInsert?
	public let databaseFlags: [SQLDatabaseFlagInsert]?
	public let deletionProtectionEnabled: Bool?

	public init(
		tier: String,
		edition: String? = nil,
		activationPolicy: String? = nil,
		availabilityType: String? = nil,
		dataDiskSizeGb: String? = nil,
		dataDiskType: String? = nil,
		storageAutoResize: Bool? = nil,
		backupConfiguration: SQLBackupConfigurationInsert? = nil,
		ipConfiguration: SQLIpConfigurationInsert? = nil,
		databaseFlags: [SQLDatabaseFlagInsert]? = nil,
		deletionProtectionEnabled: Bool? = nil
	) {
		self.tier = tier
		self.edition = edition
		self.activationPolicy = activationPolicy
		self.availabilityType = availabilityType
		self.dataDiskSizeGb = dataDiskSizeGb
		self.dataDiskType = dataDiskType
		self.storageAutoResize = storageAutoResize
		self.backupConfiguration = backupConfiguration
		self.ipConfiguration = ipConfiguration
		self.databaseFlags = databaseFlags
		self.deletionProtectionEnabled = deletionProtectionEnabled
	}
}

public struct SQLBackupConfigurationInsert: Encodable, Sendable {
	public let enabled: Bool?
	public let startTime: String?
	public let pointInTimeRecoveryEnabled: Bool?

	public init(enabled: Bool? = nil, startTime: String? = nil, pointInTimeRecoveryEnabled: Bool? = nil) {
		self.enabled = enabled
		self.startTime = startTime
		self.pointInTimeRecoveryEnabled = pointInTimeRecoveryEnabled
	}
}

public struct SQLIpConfigurationInsert: Encodable, Sendable {
	public let ipv4Enabled: Bool?
	public let privateNetwork: String?
	public let requireSsl: Bool?

	public init(ipv4Enabled: Bool? = nil, privateNetwork: String? = nil, requireSsl: Bool? = nil) {
		self.ipv4Enabled = ipv4Enabled
		self.privateNetwork = privateNetwork
		self.requireSsl = requireSsl
	}
}

public struct SQLDatabaseFlagInsert: Encodable, Sendable {
	public let name: String
	public let value: String

	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}
}

public struct SQLDatabaseInstancePatch: Encodable, Sendable {
	public let settings: SQLSettingsPatch?

	public init(settings: SQLSettingsPatch? = nil) {
		self.settings = settings
	}
}

public struct SQLSettingsPatch: Encodable, Sendable {
	public let tier: String?
	public let activationPolicy: String?
	public let availabilityType: String?
	public let dataDiskSizeGb: String?
	public let storageAutoResize: Bool?
	public let backupConfiguration: SQLBackupConfigurationInsert?
	public let deletionProtectionEnabled: Bool?

	public init(
		tier: String? = nil,
		activationPolicy: String? = nil,
		availabilityType: String? = nil,
		dataDiskSizeGb: String? = nil,
		storageAutoResize: Bool? = nil,
		backupConfiguration: SQLBackupConfigurationInsert? = nil,
		deletionProtectionEnabled: Bool? = nil
	) {
		self.tier = tier
		self.activationPolicy = activationPolicy
		self.availabilityType = availabilityType
		self.dataDiskSizeGb = dataDiskSizeGb
		self.storageAutoResize = storageAutoResize
		self.backupConfiguration = backupConfiguration
		self.deletionProtectionEnabled = deletionProtectionEnabled
	}
}
