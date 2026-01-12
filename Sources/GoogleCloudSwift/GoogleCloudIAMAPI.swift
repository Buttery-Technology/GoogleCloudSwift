//
//  GoogleCloudIAMAPI.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import AsyncHTTPClient
import Foundation
import NIOCore

/// REST API client for Google Cloud Identity and Access Management (IAM).
///
/// Provides methods for managing service accounts, keys, roles, and IAM policies via the REST API.
///
/// ## Example Usage
/// ```swift
/// let iamAPI = await GoogleCloudIAMAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // List service accounts
/// let accounts = try await iamAPI.listServiceAccounts()
///
/// // Create a service account
/// let sa = try await iamAPI.createServiceAccount(
///     accountId: "my-service-account",
///     displayName: "My Service Account"
/// )
///
/// // Get IAM policy for a project
/// let policy = try await iamAPI.getProjectIAMPolicy()
/// ```
public actor GoogleCloudIAMAPI {
    private let client: GoogleCloudHTTPClient
    private let _projectId: String

    /// The Google Cloud project ID this client operates on.
    public var projectId: String { _projectId }

    private static let baseURL = "https://iam.googleapis.com"

    /// Initialize the IAM API client.
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

    /// Create an IAM API client, inferring project ID from auth credentials.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds.
    /// - Returns: A configured IAM API client.
    public static func create(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 60
    ) async -> GoogleCloudIAMAPI {
        let projectId = await authClient.projectId
        return GoogleCloudIAMAPI(
            authClient: authClient,
            httpClient: httpClient,
            projectId: projectId,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    // MARK: - Service Accounts

    /// List all service accounts in the project.
    /// - Parameters:
    ///   - pageSize: Maximum number of service accounts to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of service accounts.
    public func listServiceAccounts(
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> IAMServiceAccountListResponse {
        var params: [String: String] = [:]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<IAMServiceAccountListResponse> = try await client.get(
            path: "/v1/projects/\(_projectId)/serviceAccounts",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a pagination helper for listing all service accounts.
    /// - Parameter pageSize: Maximum number of service accounts per page.
    /// - Returns: A pagination helper.
    public func listAllServiceAccounts(
        pageSize: Int? = nil
    ) -> PaginationHelper<IAMServiceAccount> {
        PaginationHelper { pageToken in
            let response = try await self.listServiceAccounts(
                pageSize: pageSize,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.accounts,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get a service account.
    /// - Parameter email: The service account email address.
    /// - Returns: The service account details.
    public func getServiceAccount(email: String) async throws -> IAMServiceAccount {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        let response: GoogleCloudAPIResponse<IAMServiceAccount> = try await client.get(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)"
        )
        return response.data
    }

    /// Create a new service account.
    /// - Parameters:
    ///   - accountId: The account ID (used in the email address).
    ///   - displayName: Human-readable name for the service account.
    ///   - description: Description of the service account's purpose.
    /// - Returns: The created service account.
    public func createServiceAccount(
        accountId: String,
        displayName: String? = nil,
        description: String? = nil
    ) async throws -> IAMServiceAccount {
        let request = IAMCreateServiceAccountRequest(
            accountId: accountId,
            serviceAccount: IAMServiceAccountInput(
                displayName: displayName,
                description: description
            )
        )

        let response: GoogleCloudAPIResponse<IAMServiceAccount> = try await client.post(
            path: "/v1/projects/\(_projectId)/serviceAccounts",
            body: request
        )
        return response.data
    }

    /// Update a service account.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - displayName: New display name.
    ///   - description: New description.
    /// - Returns: The updated service account.
    public func updateServiceAccount(
        email: String,
        displayName: String? = nil,
        description: String? = nil
    ) async throws -> IAMServiceAccount {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email

        var updateMask: [String] = []
        var update: [String: String] = [:]

        if let displayName = displayName {
            updateMask.append("displayName")
            update["displayName"] = displayName
        }
        if let description = description {
            updateMask.append("description")
            update["description"] = description
        }

        let params = ["updateMask": updateMask.joined(separator: ",")]

        let response: GoogleCloudAPIResponse<IAMServiceAccount> = try await client.patch(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)",
            body: update,
            queryParameters: params
        )
        return response.data
    }

    /// Delete a service account.
    /// - Parameter email: The service account email address.
    public func deleteServiceAccount(email: String) async throws {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        try await client.deleteNoContent(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)"
        )
    }

    /// Enable a disabled service account.
    /// - Parameter email: The service account email address.
    public func enableServiceAccount(email: String) async throws {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await client.post(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail):enable",
            body: EmptyBody()
        )
    }

    /// Disable a service account.
    /// - Parameter email: The service account email address.
    public func disableServiceAccount(email: String) async throws {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await client.post(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail):disable",
            body: EmptyBody()
        )
    }

    /// Undelete a service account (within 30 days of deletion).
    /// - Parameter email: The service account email address.
    /// - Returns: The undeleted service account.
    public func undeleteServiceAccount(email: String) async throws -> IAMServiceAccount {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        let response: GoogleCloudAPIResponse<IAMUndeleteServiceAccountResponse> = try await client.post(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail):undelete",
            body: EmptyBody()
        )
        return response.data.restoredAccount
    }

    // MARK: - Service Account Keys

    /// List all keys for a service account.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - keyTypes: Filter by key types (USER_MANAGED or SYSTEM_MANAGED).
    /// - Returns: A list of keys.
    public func listServiceAccountKeys(
        email: String,
        keyTypes: [IAMKeyType]? = nil
    ) async throws -> IAMServiceAccountKeyListResponse {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email

        var params: [String: String] = [:]
        if let keyTypes = keyTypes {
            params["keyTypes"] = keyTypes.map { $0.rawValue }.joined(separator: ",")
        }

        let response: GoogleCloudAPIResponse<IAMServiceAccountKeyListResponse> = try await client.get(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)/keys",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a specific service account key.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - keyId: The key ID.
    ///   - publicKeyType: The format for the public key.
    /// - Returns: The key details.
    public func getServiceAccountKey(
        email: String,
        keyId: String,
        publicKeyType: IAMPublicKeyType? = nil
    ) async throws -> IAMServiceAccountKey {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email

        var params: [String: String] = [:]
        if let publicKeyType = publicKeyType {
            params["publicKeyType"] = publicKeyType.rawValue
        }

        let response: GoogleCloudAPIResponse<IAMServiceAccountKey> = try await client.get(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)/keys/\(keyId)",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Create a new service account key.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - keyAlgorithm: The algorithm for the key.
    ///   - privateKeyType: The format for the private key.
    /// - Returns: The created key (including private key data).
    public func createServiceAccountKey(
        email: String,
        keyAlgorithm: IAMKeyAlgorithm = .keyAlgRsa2048,
        privateKeyType: IAMPrivateKeyType = .googleCredentialsFile
    ) async throws -> IAMServiceAccountKey {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email

        let request = IAMCreateServiceAccountKeyRequest(
            keyAlgorithm: keyAlgorithm.rawValue,
            privateKeyType: privateKeyType.rawValue
        )

        let response: GoogleCloudAPIResponse<IAMServiceAccountKey> = try await client.post(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)/keys",
            body: request
        )
        return response.data
    }

    /// Delete a service account key.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - keyId: The key ID.
    public func deleteServiceAccountKey(email: String, keyId: String) async throws {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        try await client.deleteNoContent(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)/keys/\(keyId)"
        )
    }

    /// Upload a public key for a service account.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - publicKeyData: The public key in PEM format.
    /// - Returns: The uploaded key.
    public func uploadServiceAccountKey(
        email: String,
        publicKeyData: String
    ) async throws -> IAMServiceAccountKey {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email

        let request = IAMUploadServiceAccountKeyRequest(publicKeyData: publicKeyData)

        let response: GoogleCloudAPIResponse<IAMServiceAccountKey> = try await client.post(
            path: "/v1/projects/\(_projectId)/serviceAccounts/\(encodedEmail)/keys:upload",
            body: request
        )
        return response.data
    }

    // MARK: - IAM Policies

    /// Get the IAM policy for the project.
    /// - Parameter requestedPolicyVersion: The policy version to request.
    /// - Returns: The IAM policy.
    public func getProjectIAMPolicy(
        requestedPolicyVersion: Int? = nil
    ) async throws -> IAMPolicy {
        try await getIAMPolicy(
            resource: "projects/\(_projectId)",
            requestedPolicyVersion: requestedPolicyVersion
        )
    }

    /// Set the IAM policy for the project.
    /// - Parameters:
    ///   - policy: The new policy.
    ///   - updateMask: Fields to update (optional).
    /// - Returns: The updated policy.
    public func setProjectIAMPolicy(
        policy: IAMPolicy,
        updateMask: String? = nil
    ) async throws -> IAMPolicy {
        try await setIAMPolicy(
            resource: "projects/\(_projectId)",
            policy: policy,
            updateMask: updateMask
        )
    }

    /// Test IAM permissions on the project.
    /// - Parameter permissions: The permissions to test.
    /// - Returns: The permissions that the caller has.
    public func testProjectIAMPermissions(
        permissions: [String]
    ) async throws -> IAMTestPermissionsResponse {
        try await testIAMPermissions(
            resource: "projects/\(_projectId)",
            permissions: permissions
        )
    }

    /// Get the IAM policy for a service account.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - requestedPolicyVersion: The policy version to request.
    /// - Returns: The IAM policy.
    public func getServiceAccountIAMPolicy(
        email: String,
        requestedPolicyVersion: Int? = nil
    ) async throws -> IAMPolicy {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        return try await getIAMPolicy(
            resource: "projects/\(_projectId)/serviceAccounts/\(encodedEmail)",
            requestedPolicyVersion: requestedPolicyVersion
        )
    }

    /// Set the IAM policy for a service account.
    /// - Parameters:
    ///   - email: The service account email address.
    ///   - policy: The new policy.
    ///   - updateMask: Fields to update (optional).
    /// - Returns: The updated policy.
    public func setServiceAccountIAMPolicy(
        email: String,
        policy: IAMPolicy,
        updateMask: String? = nil
    ) async throws -> IAMPolicy {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        return try await setIAMPolicy(
            resource: "projects/\(_projectId)/serviceAccounts/\(encodedEmail)",
            policy: policy,
            updateMask: updateMask
        )
    }

    // MARK: - Roles

    /// List predefined roles.
    /// - Parameters:
    ///   - pageSize: Maximum number of roles to return.
    ///   - pageToken: Token for pagination.
    ///   - view: Level of detail (BASIC or FULL).
    /// - Returns: A list of roles.
    public func listRoles(
        pageSize: Int? = nil,
        pageToken: String? = nil,
        view: IAMRoleView = .basic
    ) async throws -> IAMRoleListResponse {
        var params: [String: String] = ["view": view.rawValue]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<IAMRoleListResponse> = try await client.get(
            path: "/v1/roles",
            queryParameters: params
        )
        return response.data
    }

    /// List custom roles in the project.
    /// - Parameters:
    ///   - pageSize: Maximum number of roles to return.
    ///   - pageToken: Token for pagination.
    ///   - view: Level of detail (BASIC or FULL).
    ///   - showDeleted: Include deleted roles.
    /// - Returns: A list of roles.
    public func listProjectRoles(
        pageSize: Int? = nil,
        pageToken: String? = nil,
        view: IAMRoleView = .basic,
        showDeleted: Bool = false
    ) async throws -> IAMRoleListResponse {
        var params: [String: String] = ["view": view.rawValue]
        if let pageSize = pageSize { params["pageSize"] = String(pageSize) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }
        if showDeleted { params["showDeleted"] = "true" }

        let response: GoogleCloudAPIResponse<IAMRoleListResponse> = try await client.get(
            path: "/v1/projects/\(_projectId)/roles",
            queryParameters: params
        )
        return response.data
    }

    /// Get a role by name.
    /// - Parameter name: The full role name (e.g., "roles/compute.admin").
    /// - Returns: The role details.
    public func getRole(name: String) async throws -> IAMRole {
        let response: GoogleCloudAPIResponse<IAMRole> = try await client.get(
            path: "/v1/\(name)"
        )
        return response.data
    }

    /// Create a custom role in the project.
    /// - Parameters:
    ///   - roleId: The role ID (used in the role name).
    ///   - title: Display name for the role.
    ///   - description: Description of the role.
    ///   - permissions: List of permissions.
    ///   - stage: Launch stage (ALPHA, BETA, GA, etc.).
    /// - Returns: The created role.
    public func createProjectRole(
        roleId: String,
        title: String,
        description: String? = nil,
        permissions: [String],
        stage: IAMRoleStage = .ga
    ) async throws -> IAMRole {
        let request = IAMCreateRoleRequest(
            roleId: roleId,
            role: IAMRoleInput(
                title: title,
                description: description,
                includedPermissions: permissions,
                stage: stage.rawValue
            )
        )

        let response: GoogleCloudAPIResponse<IAMRole> = try await client.post(
            path: "/v1/projects/\(_projectId)/roles",
            body: request
        )
        return response.data
    }

    /// Update a custom role.
    /// - Parameters:
    ///   - name: The full role name.
    ///   - title: New display name.
    ///   - description: New description.
    ///   - permissions: New list of permissions.
    ///   - updateMask: Fields to update.
    /// - Returns: The updated role.
    public func updateProjectRole(
        name: String,
        title: String? = nil,
        description: String? = nil,
        permissions: [String]? = nil,
        updateMask: String
    ) async throws -> IAMRole {
        let role = IAMRoleUpdate(
            title: title,
            description: description,
            includedPermissions: permissions
        )

        let params = ["updateMask": updateMask]

        let response: GoogleCloudAPIResponse<IAMRole> = try await client.patch(
            path: "/v1/\(name)",
            body: role,
            queryParameters: params
        )
        return response.data
    }

    /// Delete a custom role.
    /// - Parameter name: The full role name.
    /// - Returns: The deleted role (can be undeleted within 7 days).
    public func deleteProjectRole(name: String) async throws -> IAMRole {
        let response: GoogleCloudAPIResponse<IAMRole> = try await client.delete(
            path: "/v1/\(name)"
        )
        return response.data
    }

    /// Undelete a custom role (within 7 days of deletion).
    /// - Parameter name: The full role name.
    /// - Returns: The undeleted role.
    public func undeleteProjectRole(name: String) async throws -> IAMRole {
        let response: GoogleCloudAPIResponse<IAMRole> = try await client.post(
            path: "/v1/\(name):undelete",
            body: EmptyBody()
        )
        return response.data
    }

    /// Query testable permissions for a resource.
    /// - Parameters:
    ///   - fullResourceName: The full resource name.
    ///   - pageSize: Maximum number of permissions to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: List of testable permissions.
    public func queryTestablePermissions(
        fullResourceName: String,
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> IAMQueryTestablePermissionsResponse {
        let request = IAMQueryTestablePermissionsRequest(
            fullResourceName: fullResourceName,
            pageSize: pageSize,
            pageToken: pageToken
        )

        let response: GoogleCloudAPIResponse<IAMQueryTestablePermissionsResponse> = try await client.post(
            path: "/v1/permissions:queryTestablePermissions",
            body: request
        )
        return response.data
    }

    // MARK: - Private Helpers

    private func getIAMPolicy(
        resource: String,
        requestedPolicyVersion: Int?
    ) async throws -> IAMPolicy {
        let request = IAMGetIAMPolicyRequest(
            options: requestedPolicyVersion.map { IAMGetPolicyOptions(requestedPolicyVersion: $0) }
        )

        let response: GoogleCloudAPIResponse<IAMPolicy> = try await client.post(
            path: "/v1/\(resource):getIamPolicy",
            body: request
        )
        return response.data
    }

    private func setIAMPolicy(
        resource: String,
        policy: IAMPolicy,
        updateMask: String?
    ) async throws -> IAMPolicy {
        let request = IAMSetIAMPolicyRequest(
            policy: policy,
            updateMask: updateMask
        )

        let response: GoogleCloudAPIResponse<IAMPolicy> = try await client.post(
            path: "/v1/\(resource):setIamPolicy",
            body: request
        )
        return response.data
    }

    private func testIAMPermissions(
        resource: String,
        permissions: [String]
    ) async throws -> IAMTestPermissionsResponse {
        let request = IAMTestIAMPermissionsRequest(permissions: permissions)

        let response: GoogleCloudAPIResponse<IAMTestPermissionsResponse> = try await client.post(
            path: "/v1/\(resource):testIamPermissions",
            body: request
        )
        return response.data
    }
}

// MARK: - Request Types

struct IAMCreateServiceAccountRequest: Encodable, Sendable {
    let accountId: String
    let serviceAccount: IAMServiceAccountInput
}

struct IAMServiceAccountInput: Encodable, Sendable {
    let displayName: String?
    let description: String?
}

struct IAMCreateServiceAccountKeyRequest: Encodable, Sendable {
    let keyAlgorithm: String
    let privateKeyType: String
}

struct IAMUploadServiceAccountKeyRequest: Encodable, Sendable {
    let publicKeyData: String
}

struct IAMCreateRoleRequest: Encodable, Sendable {
    let roleId: String
    let role: IAMRoleInput
}

struct IAMRoleInput: Encodable, Sendable {
    let title: String
    let description: String?
    let includedPermissions: [String]
    let stage: String
}

struct IAMRoleUpdate: Encodable, Sendable {
    let title: String?
    let description: String?
    let includedPermissions: [String]?
}

struct IAMQueryTestablePermissionsRequest: Encodable, Sendable {
    let fullResourceName: String
    let pageSize: Int?
    let pageToken: String?
}

struct IAMGetIAMPolicyRequest: Encodable, Sendable {
    let options: IAMGetPolicyOptions?
}

struct IAMGetPolicyOptions: Encodable, Sendable {
    let requestedPolicyVersion: Int
}

struct IAMSetIAMPolicyRequest: Encodable, Sendable {
    let policy: IAMPolicy
    let updateMask: String?
}

struct IAMTestIAMPermissionsRequest: Encodable, Sendable {
    let permissions: [String]
}

// MARK: - Response Types

/// List of service accounts response.
public struct IAMServiceAccountListResponse: Codable, Sendable {
    public let accounts: [IAMServiceAccount]?
    public let nextPageToken: String?
}

/// IAM service account.
public struct IAMServiceAccount: Codable, Sendable {
    public let name: String?
    public let projectId: String?
    public let uniqueId: String?
    public let email: String?
    public let displayName: String?
    public let etag: String?
    public let description: String?
    public let oauth2ClientId: String?
    public let disabled: Bool?

    /// Extract the account ID from the email.
    public var accountId: String? {
        email?.components(separatedBy: "@").first
    }
}

struct IAMUndeleteServiceAccountResponse: Codable, Sendable {
    let restoredAccount: IAMServiceAccount
}

/// List of service account keys response.
public struct IAMServiceAccountKeyListResponse: Codable, Sendable {
    public let keys: [IAMServiceAccountKey]?
}

/// Service account key.
public struct IAMServiceAccountKey: Codable, Sendable {
    public let name: String?
    public let privateKeyType: String?
    public let keyAlgorithm: String?
    public let privateKeyData: String?
    public let publicKeyData: String?
    public let validAfterTime: Date?
    public let validBeforeTime: Date?
    public let keyOrigin: String?
    public let keyType: String?
    public let disabled: Bool?

    /// Extract the key ID from the full name.
    public var keyId: String? {
        name?.components(separatedBy: "/").last
    }

    /// Decode the private key data (base64).
    public var decodedPrivateKey: Data? {
        guard let data = privateKeyData else { return nil }
        return Data(base64Encoded: data)
    }
}

/// IAM policy.
public struct IAMPolicy: Codable, Sendable {
    public let version: Int?
    public let bindings: [IAMBinding]?
    public let auditConfigs: [IAMAuditConfig]?
    public let etag: String?

    public init(
        version: Int? = nil,
        bindings: [IAMBinding]? = nil,
        auditConfigs: [IAMAuditConfig]? = nil,
        etag: String? = nil
    ) {
        self.version = version
        self.bindings = bindings
        self.auditConfigs = auditConfigs
        self.etag = etag
    }

    /// Create a new policy with the specified bindings.
    public static func withBindings(_ bindings: [IAMBinding]) -> IAMPolicy {
        IAMPolicy(version: 3, bindings: bindings)
    }
}

/// IAM binding (role + members).
public struct IAMBinding: Codable, Sendable {
    public let role: String?
    public let members: [String]?
    public let condition: IAMPolicyCondition?

    public init(
        role: String? = nil,
        members: [String]? = nil,
        condition: IAMPolicyCondition? = nil
    ) {
        self.role = role
        self.members = members
        self.condition = condition
    }

    /// Create a binding for a role with members.
    public static func binding(
        role: String,
        members: [String],
        condition: IAMPolicyCondition? = nil
    ) -> IAMBinding {
        IAMBinding(role: role, members: members, condition: condition)
    }

    /// Create a service account member string.
    public static func serviceAccount(_ email: String) -> String {
        "serviceAccount:\(email)"
    }

    /// Create a user member string.
    public static func user(_ email: String) -> String {
        "user:\(email)"
    }

    /// Create a group member string.
    public static func group(_ email: String) -> String {
        "group:\(email)"
    }

    /// Create a domain member string.
    public static func domain(_ domain: String) -> String {
        "domain:\(domain)"
    }

    /// All users (public access).
    public static let allUsers = "allUsers"

    /// All authenticated users.
    public static let allAuthenticatedUsers = "allAuthenticatedUsers"
}

/// IAM condition.
public struct IAMPolicyCondition: Codable, Sendable {
    public let title: String?
    public let description: String?
    public let expression: String?

    public init(title: String? = nil, description: String? = nil, expression: String? = nil) {
        self.title = title
        self.description = description
        self.expression = expression
    }
}

/// Audit configuration.
public struct IAMAuditConfig: Codable, Sendable {
    public let service: String?
    public let auditLogConfigs: [IAMAuditLogConfig]?
}

/// Audit log configuration.
public struct IAMAuditLogConfig: Codable, Sendable {
    public let logType: String?
    public let exemptedMembers: [String]?
}

/// Test permissions response.
public struct IAMTestPermissionsResponse: Codable, Sendable {
    public let permissions: [String]?
}

/// List of roles response.
public struct IAMRoleListResponse: Codable, Sendable {
    public let roles: [IAMRole]?
    public let nextPageToken: String?
}

/// IAM role.
public struct IAMRole: Codable, Sendable {
    public let name: String?
    public let title: String?
    public let description: String?
    public let includedPermissions: [String]?
    public let stage: String?
    public let etag: String?
    public let deleted: Bool?

    /// Extract the role ID from the full name.
    public var roleId: String? {
        name?.components(separatedBy: "/").last
    }
}

/// Query testable permissions response.
public struct IAMQueryTestablePermissionsResponse: Codable, Sendable {
    public let permissions: [IAMPermission]?
    public let nextPageToken: String?
}

/// IAM permission.
public struct IAMPermission: Codable, Sendable {
    public let name: String?
    public let title: String?
    public let description: String?
    public let customRolesSupportLevel: String?
    public let apiDisabled: Bool?
}

// MARK: - Enums

/// Key type for service account keys.
public enum IAMKeyType: String, Sendable {
    case userManaged = "USER_MANAGED"
    case systemManaged = "SYSTEM_MANAGED"
}

/// Public key format.
public enum IAMPublicKeyType: String, Sendable {
    case pem = "TYPE_X509_PEM_FILE"
    case raw = "TYPE_RAW_PUBLIC_KEY"
}

/// Private key format.
public enum IAMPrivateKeyType: String, Sendable {
    case googleCredentialsFile = "TYPE_GOOGLE_CREDENTIALS_FILE"
    case pkcs12 = "TYPE_PKCS12_FILE"
}

/// Key algorithm.
public enum IAMKeyAlgorithm: String, Sendable {
    case keyAlgRsa1024 = "KEY_ALG_RSA_1024"
    case keyAlgRsa2048 = "KEY_ALG_RSA_2048"
}

/// Role view level.
public enum IAMRoleView: String, Sendable {
    case basic = "BASIC"
    case full = "FULL"
}

/// Role launch stage.
public enum IAMRoleStage: String, Sendable {
    case alpha = "ALPHA"
    case beta = "BETA"
    case ga = "GA"
    case deprecated = "DEPRECATED"
    case disabled = "DISABLED"
}

// MARK: - Policy Helpers

extension IAMPolicy {
    /// Add a binding to the policy.
    /// - Parameters:
    ///   - role: The role to bind.
    ///   - members: The members to grant the role.
    /// - Returns: A new policy with the binding added.
    public func addBinding(role: String, members: [String]) -> IAMPolicy {
        var newBindings = bindings ?? []
        newBindings.append(IAMBinding(role: role, members: members))
        return IAMPolicy(version: version, bindings: newBindings, auditConfigs: auditConfigs, etag: etag)
    }

    /// Remove a binding from the policy.
    /// - Parameter role: The role to remove.
    /// - Returns: A new policy with the binding removed.
    public func removeBinding(role: String) -> IAMPolicy {
        let newBindings = bindings?.filter { $0.role != role }
        return IAMPolicy(version: version, bindings: newBindings, auditConfigs: auditConfigs, etag: etag)
    }

    /// Add a member to a role binding.
    /// - Parameters:
    ///   - member: The member to add.
    ///   - role: The role to add the member to.
    /// - Returns: A new policy with the member added.
    public func addMember(_ member: String, toRole role: String) -> IAMPolicy {
        var newBindings = bindings ?? []

        if let index = newBindings.firstIndex(where: { $0.role == role }) {
            var binding = newBindings[index]
            var members = binding.members ?? []
            if !members.contains(member) {
                members.append(member)
            }
            newBindings[index] = IAMBinding(role: role, members: members, condition: binding.condition)
        } else {
            newBindings.append(IAMBinding(role: role, members: [member]))
        }

        return IAMPolicy(version: version, bindings: newBindings, auditConfigs: auditConfigs, etag: etag)
    }

    /// Remove a member from a role binding.
    /// - Parameters:
    ///   - member: The member to remove.
    ///   - role: The role to remove the member from.
    /// - Returns: A new policy with the member removed.
    public func removeMember(_ member: String, fromRole role: String) -> IAMPolicy {
        var newBindings = bindings ?? []

        if let index = newBindings.firstIndex(where: { $0.role == role }) {
            var binding = newBindings[index]
            var members = binding.members ?? []
            members.removeAll { $0 == member }

            if members.isEmpty {
                newBindings.remove(at: index)
            } else {
                newBindings[index] = IAMBinding(role: role, members: members, condition: binding.condition)
            }
        }

        return IAMPolicy(version: version, bindings: newBindings, auditConfigs: auditConfigs, etag: etag)
    }
}
