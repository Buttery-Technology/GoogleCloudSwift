//
//  GoogleCloudSecretManagerAPI.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/9/26.
//

import AsyncHTTPClient
import Foundation
import NIOCore

/// REST API client for Google Cloud Secret Manager.
///
/// Provides methods for managing secrets and their versions via the REST API.
///
/// ## Example Usage
/// ```swift
/// let secretManager = await GoogleCloudSecretManagerAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // Create a secret
/// let secret = try await secretManager.createSecret(secretId: "my-api-key")
///
/// // Add a secret version with data
/// let version = try await secretManager.addSecretVersion(
///     secretId: "my-api-key",
///     data: "super-secret-value".data(using: .utf8)!
/// )
///
/// // Access the secret value
/// let secretData = try await secretManager.accessSecretVersion(secretId: "my-api-key")
/// let secretString = String(data: secretData, encoding: .utf8)
/// ```
public actor GoogleCloudSecretManagerAPI {
    private let client: GoogleCloudHTTPClient
    private let _projectId: String

    /// The Google Cloud project ID this client operates on.
    public var projectId: String { _projectId }

    private static let baseURL = "https://secretmanager.googleapis.com"

    /// Initialize the Secret Manager API client.
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

    /// Create a Secret Manager API client, inferring project ID from auth credentials.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds.
    /// - Returns: A configured Secret Manager API client.
    public static func create(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) async -> GoogleCloudSecretManagerAPI {
        let projectId = await authClient.projectId
        return GoogleCloudSecretManagerAPI(
            authClient: authClient,
            httpClient: httpClient,
            projectId: projectId,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    // MARK: - Secrets

    /// List all secrets in the project.
    /// - Parameters:
    ///   - filter: Optional filter expression.
    ///   - pageSize: Maximum number of secrets to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of secrets.
    public func listSecrets(
        filter: String? = nil,
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> SecretListResponse {
        var params: [String: String] = [:]
        if let filter = filter { params["filter"] = filter }
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<SecretListResponse> = try await client.get(
            path: "/v1/projects/\(_projectId)/secrets",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a pagination helper for listing all secrets.
    /// - Parameters:
    ///   - filter: Optional filter expression.
    ///   - pageSize: Maximum number of secrets per page.
    /// - Returns: A pagination helper.
    public func listAllSecrets(
        filter: String? = nil,
        pageSize: Int? = nil
    ) -> PaginationHelper<Secret> {
        PaginationHelper { pageToken in
            let response = try await self.listSecrets(
                filter: filter,
                pageSize: pageSize,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.secrets,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get a secret's metadata.
    /// - Parameter secretId: The secret ID (name).
    /// - Returns: The secret metadata.
    public func getSecret(secretId: String) async throws -> Secret {
        let response: GoogleCloudAPIResponse<Secret> = try await client.get(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)"
        )
        return response.data
    }

    /// Create a new secret.
    /// - Parameters:
    ///   - secretId: The secret ID (name).
    ///   - replication: Replication policy (default: automatic).
    ///   - labels: Optional labels.
    /// - Returns: The created secret.
    public func createSecret(
        secretId: String,
        replication: SecretReplication = .automatic,
        labels: [String: String]? = nil
    ) async throws -> Secret {
        let request = CreateSecretRequest(replication: replication, labels: labels)

        let response: GoogleCloudAPIResponse<Secret> = try await client.post(
            path: "/v1/projects/\(_projectId)/secrets",
            body: request,
            queryParameters: ["secretId": secretId]
        )
        return response.data
    }

    /// Delete a secret and all its versions.
    /// - Parameter secretId: The secret ID.
    public func deleteSecret(secretId: String) async throws {
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await client.delete(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)"
        )
    }

    /// Update a secret's metadata (labels).
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - labels: New labels for the secret.
    /// - Returns: The updated secret.
    public func updateSecret(
        secretId: String,
        labels: [String: String]
    ) async throws -> Secret {
        let request = UpdateSecretRequest(labels: labels)

        let response: GoogleCloudAPIResponse<Secret> = try await client.patch(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)",
            body: request,
            queryParameters: ["updateMask": "labels"]
        )
        return response.data
    }

    // MARK: - Secret Versions

    /// List versions of a secret.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - filter: Optional filter expression (e.g., "state:ENABLED").
    ///   - pageSize: Maximum number of versions to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of secret versions.
    public func listSecretVersions(
        secretId: String,
        filter: String? = nil,
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> SecretVersionListResponse {
        var params: [String: String] = [:]
        if let filter = filter { params["filter"] = filter }
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<SecretVersionListResponse> = try await client.get(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)/versions",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get metadata for a specific secret version.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - version: The version ID ("latest" or a version number).
    /// - Returns: The secret version metadata.
    public func getSecretVersion(
        secretId: String,
        version: String = "latest"
    ) async throws -> SecretVersion {
        let response: GoogleCloudAPIResponse<SecretVersion> = try await client.get(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)/versions/\(version)"
        )
        return response.data
    }

    /// Access a secret version's data (the actual secret value).
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - version: The version ID ("latest" or a version number).
    /// - Returns: The secret data.
    public func accessSecretVersion(
        secretId: String,
        version: String = "latest"
    ) async throws -> Data {
        let response: GoogleCloudAPIResponse<AccessSecretVersionResponse> = try await client.get(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)/versions/\(version):access"
        )

        guard let base64Data = response.data.payload?.data,
              let data = Data(base64Encoded: base64Data) else {
            throw GoogleCloudAPIError.invalidResponse("Secret payload is missing or invalid")
        }

        return data
    }

    /// Access a secret version's data as a string.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - version: The version ID ("latest" or a version number).
    /// - Returns: The secret value as a string.
    public func accessSecretVersionString(
        secretId: String,
        version: String = "latest"
    ) async throws -> String {
        let data = try await accessSecretVersion(secretId: secretId, version: version)
        guard let string = String(data: data, encoding: .utf8) else {
            throw GoogleCloudAPIError.invalidResponse("Secret data is not valid UTF-8")
        }
        return string
    }

    /// Add a new version to a secret.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - data: The secret data.
    /// - Returns: The created secret version.
    public func addSecretVersion(
        secretId: String,
        data: Data
    ) async throws -> SecretVersion {
        let request = AddSecretVersionRequest(
            payload: SecretPayload(data: data.base64EncodedString())
        )

        let response: GoogleCloudAPIResponse<SecretVersion> = try await client.post(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId):addVersion",
            body: request
        )
        return response.data
    }

    /// Add a new version to a secret with a string value.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - value: The secret value as a string.
    /// - Returns: The created secret version.
    public func addSecretVersion(
        secretId: String,
        value: String
    ) async throws -> SecretVersion {
        guard let data = value.data(using: .utf8) else {
            throw GoogleCloudAPIError.encodingError("Failed to encode string as UTF-8")
        }
        return try await addSecretVersion(secretId: secretId, data: data)
    }

    /// Disable a secret version.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - version: The version ID.
    /// - Returns: The updated secret version.
    public func disableSecretVersion(
        secretId: String,
        version: String
    ) async throws -> SecretVersion {
        let response: GoogleCloudAPIResponse<SecretVersion> = try await client.post(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)/versions/\(version):disable",
            body: EmptyBody()
        )
        return response.data
    }

    /// Enable a previously disabled secret version.
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - version: The version ID.
    /// - Returns: The updated secret version.
    public func enableSecretVersion(
        secretId: String,
        version: String
    ) async throws -> SecretVersion {
        let response: GoogleCloudAPIResponse<SecretVersion> = try await client.post(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)/versions/\(version):enable",
            body: EmptyBody()
        )
        return response.data
    }

    /// Destroy a secret version (irreversible).
    /// - Parameters:
    ///   - secretId: The secret ID.
    ///   - version: The version ID.
    /// - Returns: The destroyed secret version.
    public func destroySecretVersion(
        secretId: String,
        version: String
    ) async throws -> SecretVersion {
        let response: GoogleCloudAPIResponse<SecretVersion> = try await client.post(
            path: "/v1/projects/\(_projectId)/secrets/\(secretId)/versions/\(version):destroy",
            body: EmptyBody()
        )
        return response.data
    }
}

// MARK: - Request Types

/// Replication configuration for a secret.
public enum SecretReplication: Encodable, Sendable {
    /// Automatic replication (Google manages).
    case automatic

    /// User-managed replication to specific locations.
    case userManaged(locations: [String])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .automatic:
            try container.encode(AutomaticReplication(), forKey: .automatic)
        case .userManaged(let locations):
            let replicas = locations.map { UserManagedReplica(location: $0) }
            try container.encode(UserManagedReplication(replicas: replicas), forKey: .userManaged)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case automatic
        case userManaged
    }

    private struct AutomaticReplication: Encodable {}

    private struct UserManagedReplication: Encodable {
        let replicas: [UserManagedReplica]
    }

    private struct UserManagedReplica: Encodable {
        let location: String
    }
}

/// Request to create a secret.
struct CreateSecretRequest: Encodable, Sendable {
    let replication: SecretReplication
    let labels: [String: String]?
}

/// Request to update a secret.
struct UpdateSecretRequest: Encodable, Sendable {
    let labels: [String: String]
}

/// Request to add a secret version.
struct AddSecretVersionRequest: Encodable, Sendable {
    let payload: SecretPayload
}

/// Secret payload containing the data.
public struct SecretPayload: Codable, Sendable {
    public let data: String  // Base64-encoded
}

// MARK: - Response Types

/// List of secrets.
public struct SecretListResponse: Codable, Sendable {
    public let secrets: [Secret]?
    public let nextPageToken: String?
    public let totalSize: Int?
}

/// Secret metadata.
public struct Secret: Codable, Sendable {
    public let name: String?
    public let createTime: Date?
    public let labels: [String: String]?
    public let replication: ReplicationResponse?
    public let etag: String?

    /// Extract the secret ID from the full resource name.
    public var secretId: String? {
        name?.components(separatedBy: "/").last
    }

    public struct ReplicationResponse: Codable, Sendable {
        public let automatic: AutomaticResponse?
        public let userManaged: UserManagedResponse?

        public struct AutomaticResponse: Codable, Sendable {}

        public struct UserManagedResponse: Codable, Sendable {
            public let replicas: [ReplicaResponse]?

            public struct ReplicaResponse: Codable, Sendable {
                public let location: String?
            }
        }
    }
}

/// List of secret versions.
public struct SecretVersionListResponse: Codable, Sendable {
    public let versions: [SecretVersion]?
    public let nextPageToken: String?
    public let totalSize: Int?
}

/// Secret version metadata.
public struct SecretVersion: Codable, Sendable {
    public let name: String?
    public let createTime: Date?
    public let destroyTime: Date?
    public let state: String?
    public let etag: String?
    public let replicationStatus: ReplicationStatus?

    /// Extract the version ID from the full resource name.
    public var versionId: String? {
        name?.components(separatedBy: "/").last
    }

    /// Whether this version is enabled.
    public var isEnabled: Bool {
        state == "ENABLED"
    }

    /// Whether this version is disabled.
    public var isDisabled: Bool {
        state == "DISABLED"
    }

    /// Whether this version is destroyed.
    public var isDestroyed: Bool {
        state == "DESTROYED"
    }

    public struct ReplicationStatus: Codable, Sendable {
        public let automatic: AutomaticStatus?
        public let userManaged: UserManagedStatus?

        public struct AutomaticStatus: Codable, Sendable {}

        public struct UserManagedStatus: Codable, Sendable {
            public let replicas: [ReplicaStatus]?

            public struct ReplicaStatus: Codable, Sendable {
                public let location: String?
            }
        }
    }
}

/// Response when accessing a secret version's data.
struct AccessSecretVersionResponse: Codable, Sendable {
    let name: String?
    let payload: SecretPayload?
}
