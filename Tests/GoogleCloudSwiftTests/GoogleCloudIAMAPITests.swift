//
//  GoogleCloudIAMAPITests.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Mock IAM API

/// Mock implementation of GoogleCloudIAMAPIProtocol for testing.
actor MockIAMAPI: GoogleCloudIAMAPIProtocol {
    let projectId: String

    // Stubs for each method
    var listServiceAccountsHandler: ((Int?, String?) async throws -> IAMServiceAccountListResponse)?
    var getServiceAccountHandler: ((String) async throws -> IAMServiceAccount)?
    var createServiceAccountHandler: ((String, String?, String?) async throws -> IAMServiceAccount)?
    var deleteServiceAccountHandler: ((String) async throws -> Void)?
    var listServiceAccountKeysHandler: ((String, [IAMKeyType]?) async throws -> IAMServiceAccountKeyListResponse)?
    var createServiceAccountKeyHandler: ((String, IAMKeyAlgorithm, IAMPrivateKeyType) async throws -> IAMServiceAccountKey)?
    var deleteServiceAccountKeyHandler: ((String, String) async throws -> Void)?
    var getProjectIAMPolicyHandler: ((Int?) async throws -> IAMPolicy)?
    var setProjectIAMPolicyHandler: ((IAMPolicy, String?) async throws -> IAMPolicy)?
    var testProjectIAMPermissionsHandler: (([String]) async throws -> IAMTestPermissionsResponse)?

    // Call tracking
    var listServiceAccountsCalls: [(pageSize: Int?, pageToken: String?)] = []
    var getServiceAccountCalls: [String] = []
    var createServiceAccountCalls: [(accountId: String, displayName: String?, description: String?)] = []
    var deleteServiceAccountCalls: [String] = []
    var listServiceAccountKeysCalls: [(email: String, keyTypes: [IAMKeyType]?)] = []
    var createServiceAccountKeyCalls: [(email: String, keyAlgorithm: IAMKeyAlgorithm, privateKeyType: IAMPrivateKeyType)] = []
    var deleteServiceAccountKeyCalls: [(email: String, keyId: String)] = []
    var getProjectIAMPolicyCalls: [Int?] = []
    var setProjectIAMPolicyCalls: [(policy: IAMPolicy, updateMask: String?)] = []
    var testProjectIAMPermissionsCalls: [[String]] = []

    init(projectId: String = "test-project") {
        self.projectId = projectId
    }

    func listServiceAccounts(pageSize: Int?, pageToken: String?) async throws -> IAMServiceAccountListResponse {
        listServiceAccountsCalls.append((pageSize, pageToken))
        if let handler = listServiceAccountsHandler {
            return try await handler(pageSize, pageToken)
        }
        return IAMServiceAccountListResponse(accounts: [], nextPageToken: nil)
    }

    func getServiceAccount(email: String) async throws -> IAMServiceAccount {
        getServiceAccountCalls.append(email)
        if let handler = getServiceAccountHandler {
            return try await handler(email)
        }
        return createMockServiceAccount(email: email)
    }

    func createServiceAccount(accountId: String, displayName: String?, description: String?) async throws -> IAMServiceAccount {
        createServiceAccountCalls.append((accountId, displayName, description))
        if let handler = createServiceAccountHandler {
            return try await handler(accountId, displayName, description)
        }
        return createMockServiceAccount(accountId: accountId, displayName: displayName)
    }

    func deleteServiceAccount(email: String) async throws {
        deleteServiceAccountCalls.append(email)
        if let handler = deleteServiceAccountHandler {
            try await handler(email)
        }
    }

    func listServiceAccountKeys(email: String, keyTypes: [IAMKeyType]?) async throws -> IAMServiceAccountKeyListResponse {
        listServiceAccountKeysCalls.append((email, keyTypes))
        if let handler = listServiceAccountKeysHandler {
            return try await handler(email, keyTypes)
        }
        return IAMServiceAccountKeyListResponse(keys: [])
    }

    func createServiceAccountKey(email: String, keyAlgorithm: IAMKeyAlgorithm, privateKeyType: IAMPrivateKeyType) async throws -> IAMServiceAccountKey {
        createServiceAccountKeyCalls.append((email, keyAlgorithm, privateKeyType))
        if let handler = createServiceAccountKeyHandler {
            return try await handler(email, keyAlgorithm, privateKeyType)
        }
        return createMockServiceAccountKey(email: email)
    }

    func deleteServiceAccountKey(email: String, keyId: String) async throws {
        deleteServiceAccountKeyCalls.append((email, keyId))
        if let handler = deleteServiceAccountKeyHandler {
            try await handler(email, keyId)
        }
    }

    func getProjectIAMPolicy(requestedPolicyVersion: Int?) async throws -> IAMPolicy {
        getProjectIAMPolicyCalls.append(requestedPolicyVersion)
        if let handler = getProjectIAMPolicyHandler {
            return try await handler(requestedPolicyVersion)
        }
        return IAMPolicy(version: 3, bindings: [], etag: "ABCD")
    }

    func setProjectIAMPolicy(policy: IAMPolicy, updateMask: String?) async throws -> IAMPolicy {
        setProjectIAMPolicyCalls.append((policy, updateMask))
        if let handler = setProjectIAMPolicyHandler {
            return try await handler(policy, updateMask)
        }
        return policy
    }

    func testProjectIAMPermissions(permissions: [String]) async throws -> IAMTestPermissionsResponse {
        testProjectIAMPermissionsCalls.append(permissions)
        if let handler = testProjectIAMPermissionsHandler {
            return try await handler(permissions)
        }
        return IAMTestPermissionsResponse(permissions: permissions)
    }

    // MARK: - Mock Data Helpers

    private func createMockServiceAccount(
        email: String? = nil,
        accountId: String? = nil,
        displayName: String? = nil
    ) -> IAMServiceAccount {
        let id = accountId ?? "mock-sa"
        let finalEmail = email ?? "\(id)@\(projectId).iam.gserviceaccount.com"

        return IAMServiceAccount(
            name: "projects/\(projectId)/serviceAccounts/\(finalEmail)",
            projectId: projectId,
            uniqueId: "12345678901234567890",
            email: finalEmail,
            displayName: displayName ?? "Mock Service Account",
            etag: "CAE=",
            description: nil,
            oauth2ClientId: "12345678901234567890.apps.googleusercontent.com",
            disabled: false
        )
    }

    private func createMockServiceAccountKey(email: String) -> IAMServiceAccountKey {
        IAMServiceAccountKey(
            name: "projects/\(projectId)/serviceAccounts/\(email)/keys/abc123",
            privateKeyType: "TYPE_GOOGLE_CREDENTIALS_FILE",
            keyAlgorithm: "KEY_ALG_RSA_2048",
            privateKeyData: "eyJ0eXBlIjoic2VydmljZV9hY2NvdW50In0=",
            publicKeyData: nil,
            validAfterTime: Date(),
            validBeforeTime: Date().addingTimeInterval(365 * 24 * 60 * 60),
            keyOrigin: "GOOGLE_PROVIDED",
            keyType: "USER_MANAGED",
            disabled: false
        )
    }
}

// MARK: - Protocol Conformance Tests

@Test func testIAMAPIProtocolConformance() {
    func acceptsProtocol<T: GoogleCloudIAMAPIProtocol>(_ api: T) {}

    let mock = MockIAMAPI()
    acceptsProtocol(mock)
}

// MARK: - Mock IAM API Tests

@Test func testMockIAMAPIProjectId() async {
    let mock = MockIAMAPI(projectId: "my-iam-project")
    let projectId = await mock.projectId
    #expect(projectId == "my-iam-project")
}

@Test func testMockListServiceAccountsDefault() async throws {
    let mock = MockIAMAPI()
    let result = try await mock.listServiceAccounts(pageSize: nil, pageToken: nil)

    #expect(result.accounts?.isEmpty != false)
    #expect(result.nextPageToken == nil)

    let calls = await mock.listServiceAccountsCalls
    #expect(calls.count == 1)
}

@Test func testMockListServiceAccountsWithHandler() async throws {
    let mock = MockIAMAPI()

    await mock.setListServiceAccountsHandler { pageSize, pageToken in
        let sa = IAMServiceAccount(
            name: "projects/test-project/serviceAccounts/my-sa@test-project.iam.gserviceaccount.com",
            projectId: "test-project",
            uniqueId: "123",
            email: "my-sa@test-project.iam.gserviceaccount.com",
            displayName: "My SA",
            etag: nil,
            description: nil,
            oauth2ClientId: nil,
            disabled: false
        )
        return IAMServiceAccountListResponse(accounts: [sa], nextPageToken: "page2")
    }

    let result = try await mock.listServiceAccounts(pageSize: 10, pageToken: nil)

    #expect(result.accounts?.count == 1)
    #expect(result.accounts?.first?.accountId == "my-sa")
    #expect(result.nextPageToken == "page2")

    let calls = await mock.listServiceAccountsCalls
    #expect(calls.first?.pageSize == 10)
}

@Test func testMockGetServiceAccount() async throws {
    let mock = MockIAMAPI()
    let sa = try await mock.getServiceAccount(email: "test@test-project.iam.gserviceaccount.com")

    #expect(sa.email == "test@test-project.iam.gserviceaccount.com")
    #expect(sa.disabled == false)

    let calls = await mock.getServiceAccountCalls
    #expect(calls == ["test@test-project.iam.gserviceaccount.com"])
}

@Test func testMockCreateServiceAccount() async throws {
    let mock = MockIAMAPI()

    let sa = try await mock.createServiceAccount(
        accountId: "new-service",
        displayName: "New Service Account",
        description: "A test service account"
    )

    #expect(sa.displayName == "New Service Account")

    let calls = await mock.createServiceAccountCalls
    #expect(calls.count == 1)
    #expect(calls.first?.accountId == "new-service")
    #expect(calls.first?.displayName == "New Service Account")
}

@Test func testMockDeleteServiceAccount() async throws {
    let mock = MockIAMAPI()

    try await mock.deleteServiceAccount(email: "delete-me@project.iam.gserviceaccount.com")

    let calls = await mock.deleteServiceAccountCalls
    #expect(calls == ["delete-me@project.iam.gserviceaccount.com"])
}

@Test func testMockListServiceAccountKeys() async throws {
    let mock = MockIAMAPI()

    let result = try await mock.listServiceAccountKeys(
        email: "test@project.iam.gserviceaccount.com",
        keyTypes: [.userManaged]
    )

    #expect(result.keys?.isEmpty != false)

    let calls = await mock.listServiceAccountKeysCalls
    #expect(calls.count == 1)
    #expect(calls.first?.keyTypes == [.userManaged])
}

@Test func testMockCreateServiceAccountKey() async throws {
    let mock = MockIAMAPI()

    let key = try await mock.createServiceAccountKey(
        email: "test@project.iam.gserviceaccount.com",
        keyAlgorithm: .keyAlgRsa2048,
        privateKeyType: .googleCredentialsFile
    )

    #expect(key.keyId != nil)
    #expect(key.privateKeyData != nil)

    let calls = await mock.createServiceAccountKeyCalls
    #expect(calls.count == 1)
    #expect(calls.first?.keyAlgorithm == .keyAlgRsa2048)
}

@Test func testMockDeleteServiceAccountKey() async throws {
    let mock = MockIAMAPI()

    try await mock.deleteServiceAccountKey(
        email: "test@project.iam.gserviceaccount.com",
        keyId: "key123"
    )

    let calls = await mock.deleteServiceAccountKeyCalls
    #expect(calls.count == 1)
    #expect(calls.first?.keyId == "key123")
}

@Test func testMockGetProjectIAMPolicy() async throws {
    let mock = MockIAMAPI()

    await mock.setGetProjectIAMPolicyHandler { requestedVersion in
        IAMPolicy(
            version: 3,
            bindings: [
                IAMBinding(role: "roles/owner", members: ["user:admin@example.com"])
            ],
            etag: "BwXyz"
        )
    }

    let policy = try await mock.getProjectIAMPolicy(requestedPolicyVersion: 3)

    #expect(policy.version == 3)
    #expect(policy.bindings?.count == 1)
    #expect(policy.bindings?.first?.role == "roles/owner")

    let calls = await mock.getProjectIAMPolicyCalls
    #expect(calls.count == 1)
}

@Test func testMockSetProjectIAMPolicy() async throws {
    let mock = MockIAMAPI()
    let newPolicy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:viewer@example.com"])
        ]
    )

    let result = try await mock.setProjectIAMPolicy(policy: newPolicy, updateMask: nil)

    #expect(result.bindings?.first?.role == "roles/viewer")

    let calls = await mock.setProjectIAMPolicyCalls
    #expect(calls.count == 1)
}

@Test func testMockTestProjectIAMPermissions() async throws {
    let mock = MockIAMAPI()

    await mock.setTestProjectIAMPermissionsHandler { permissions in
        IAMTestPermissionsResponse(permissions: ["compute.instances.get"])
    }

    let result = try await mock.testProjectIAMPermissions(
        permissions: ["compute.instances.get", "compute.instances.delete"]
    )

    #expect(result.permissions?.count == 1)
    #expect(result.permissions?.contains("compute.instances.get") == true)
}

@Test func testMockIAMAPIErrorHandling() async {
    let mock = MockIAMAPI()

    await mock.setGetServiceAccountHandler { email in
        throw GoogleCloudAPIError.httpError(404, nil)
    }

    do {
        _ = try await mock.getServiceAccount(email: "nonexistent@project.iam.gserviceaccount.com")
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

// MARK: - Response Type Tests

@Test func testIAMServiceAccountDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com",
        "projectId": "my-project",
        "uniqueId": "123456789012345678901",
        "email": "my-sa@my-project.iam.gserviceaccount.com",
        "displayName": "My Service Account",
        "description": "A service account for testing",
        "etag": "CAE=",
        "oauth2ClientId": "123456789012345678901.apps.googleusercontent.com",
        "disabled": false
    }
    """

    let decoder = JSONDecoder()
    let sa = try decoder.decode(IAMServiceAccount.self, from: Data(json.utf8))

    #expect(sa.email == "my-sa@my-project.iam.gserviceaccount.com")
    #expect(sa.accountId == "my-sa")
    #expect(sa.displayName == "My Service Account")
    #expect(sa.description == "A service account for testing")
    #expect(sa.disabled == false)
}

@Test func testIAMServiceAccountKeyDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/serviceAccounts/sa@my-project.iam.gserviceaccount.com/keys/abc123def456",
        "privateKeyType": "TYPE_GOOGLE_CREDENTIALS_FILE",
        "keyAlgorithm": "KEY_ALG_RSA_2048",
        "validAfterTime": "2024-01-15T10:30:00.000Z",
        "validBeforeTime": "2034-01-15T10:30:00.000Z",
        "keyOrigin": "GOOGLE_PROVIDED",
        "keyType": "USER_MANAGED",
        "disabled": false
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let key = try decoder.decode(IAMServiceAccountKey.self, from: Data(json.utf8))

    #expect(key.keyId == "abc123def456")
    #expect(key.keyAlgorithm == "KEY_ALG_RSA_2048")
    #expect(key.keyType == "USER_MANAGED")
    #expect(key.disabled == false)
}

@Test func testIAMPolicyDecoding() throws {
    let json = """
    {
        "version": 3,
        "bindings": [
            {
                "role": "roles/owner",
                "members": ["user:admin@example.com"]
            },
            {
                "role": "roles/viewer",
                "members": [
                    "user:viewer1@example.com",
                    "group:devs@example.com",
                    "serviceAccount:bot@my-project.iam.gserviceaccount.com"
                ]
            }
        ],
        "etag": "BwXyzABC="
    }
    """

    let decoder = JSONDecoder()
    let policy = try decoder.decode(IAMPolicy.self, from: Data(json.utf8))

    #expect(policy.version == 3)
    #expect(policy.bindings?.count == 2)
    #expect(policy.bindings?[0].role == "roles/owner")
    #expect(policy.bindings?[1].members?.count == 3)
    #expect(policy.etag == "BwXyzABC=")
}

@Test func testIAMRoleDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/roles/customViewer",
        "title": "Custom Viewer",
        "description": "A custom viewer role",
        "includedPermissions": [
            "compute.instances.get",
            "compute.instances.list"
        ],
        "stage": "GA",
        "etag": "BwABC123="
    }
    """

    let decoder = JSONDecoder()
    let role = try decoder.decode(IAMRole.self, from: Data(json.utf8))

    #expect(role.roleId == "customViewer")
    #expect(role.title == "Custom Viewer")
    #expect(role.includedPermissions?.count == 2)
    #expect(role.stage == "GA")
}

// MARK: - Policy Helper Tests

@Test func testIAMPolicyAddBindingHelper() {
    let policy = IAMPolicy(version: 3, bindings: [])

    let updated = policy.addBinding(role: "roles/viewer", members: ["user:test@example.com"])

    #expect(updated.bindings?.count == 1)
    #expect(updated.bindings?.first?.role == "roles/viewer")
    #expect(updated.bindings?.first?.members?.contains("user:test@example.com") == true)
}

@Test func testIAMPolicyRemoveBindingHelper() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/owner", members: ["user:admin@example.com"]),
            IAMBinding(role: "roles/viewer", members: ["user:viewer@example.com"])
        ]
    )

    let updated = policy.removeBinding(role: "roles/owner")

    #expect(updated.bindings?.count == 1)
    #expect(updated.bindings?.first?.role == "roles/viewer")
}

@Test func testIAMPolicyAddMemberToExistingRole() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:viewer1@example.com"])
        ]
    )

    let updated = policy.addMember("user:viewer2@example.com", toRole: "roles/viewer")

    #expect(updated.bindings?.first?.members?.count == 2)
    #expect(updated.bindings?.first?.members?.contains("user:viewer2@example.com") == true)
}

@Test func testIAMPolicyAddMemberCreatesNewRole() {
    let policy = IAMPolicy(version: 3, bindings: [])

    let updated = policy.addMember("user:admin@example.com", toRole: "roles/owner")

    #expect(updated.bindings?.count == 1)
    #expect(updated.bindings?.first?.role == "roles/owner")
    #expect(updated.bindings?.first?.members?.contains("user:admin@example.com") == true)
}

@Test func testIAMPolicyRemoveMemberFromRole() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:viewer1@example.com", "user:viewer2@example.com"])
        ]
    )

    let updated = policy.removeMember("user:viewer1@example.com", fromRole: "roles/viewer")

    #expect(updated.bindings?.first?.members?.count == 1)
    #expect(updated.bindings?.first?.members?.contains("user:viewer2@example.com") == true)
}

@Test func testIAMPolicyRemoveLastMember() {
    let policy = IAMPolicy(
        version: 3,
        bindings: [
            IAMBinding(role: "roles/viewer", members: ["user:viewer@example.com"])
        ]
    )

    let updated = policy.removeMember("user:viewer@example.com", fromRole: "roles/viewer")

    // Binding should be removed when no members remain
    #expect(updated.bindings?.isEmpty == true)
}

@Test func testIAMPolicyWithBindings() {
    let policy = IAMPolicy.withBindings([
        IAMBinding.binding(
            role: "roles/editor",
            members: [
                IAMBinding.user("editor@example.com"),
                IAMBinding.serviceAccount("bot@project.iam.gserviceaccount.com")
            ]
        )
    ])

    #expect(policy.version == 3)
    #expect(policy.bindings?.count == 1)
}

// MARK: - IAMBinding Helper Tests

@Test func testIAMBindingMemberHelpers() {
    #expect(IAMBinding.user("test@example.com") == "user:test@example.com")
    #expect(IAMBinding.serviceAccount("sa@project.iam.gserviceaccount.com") == "serviceAccount:sa@project.iam.gserviceaccount.com")
    #expect(IAMBinding.group("group@example.com") == "group:group@example.com")
    #expect(IAMBinding.domain("example.com") == "domain:example.com")
    #expect(IAMBinding.allUsers == "allUsers")
    #expect(IAMBinding.allAuthenticatedUsers == "allAuthenticatedUsers")
}

// MARK: - Enum Tests

@Test func testIAMKeyTypeEnum() {
    #expect(IAMKeyType.userManaged.rawValue == "USER_MANAGED")
    #expect(IAMKeyType.systemManaged.rawValue == "SYSTEM_MANAGED")
}

@Test func testIAMKeyAlgorithmEnum() {
    #expect(IAMKeyAlgorithm.keyAlgRsa1024.rawValue == "KEY_ALG_RSA_1024")
    #expect(IAMKeyAlgorithm.keyAlgRsa2048.rawValue == "KEY_ALG_RSA_2048")
}

@Test func testIAMPrivateKeyTypeEnum() {
    #expect(IAMPrivateKeyType.googleCredentialsFile.rawValue == "TYPE_GOOGLE_CREDENTIALS_FILE")
    #expect(IAMPrivateKeyType.pkcs12.rawValue == "TYPE_PKCS12_FILE")
}

@Test func testIAMRoleViewEnum() {
    #expect(IAMRoleView.basic.rawValue == "BASIC")
    #expect(IAMRoleView.full.rawValue == "FULL")
}

@Test func testIAMRoleStageEnum() {
    #expect(IAMRoleStage.alpha.rawValue == "ALPHA")
    #expect(IAMRoleStage.beta.rawValue == "BETA")
    #expect(IAMRoleStage.ga.rawValue == "GA")
    #expect(IAMRoleStage.deprecated.rawValue == "DEPRECATED")
    #expect(IAMRoleStage.disabled.rawValue == "DISABLED")
}

// MARK: - Mock Helper Extensions

extension MockIAMAPI {
    func setListServiceAccountsHandler(_ handler: @escaping (Int?, String?) async throws -> IAMServiceAccountListResponse) {
        listServiceAccountsHandler = handler
    }

    func setGetServiceAccountHandler(_ handler: @escaping (String) async throws -> IAMServiceAccount) {
        getServiceAccountHandler = handler
    }

    func setGetProjectIAMPolicyHandler(_ handler: @escaping (Int?) async throws -> IAMPolicy) {
        getProjectIAMPolicyHandler = handler
    }

    func setTestProjectIAMPermissionsHandler(_ handler: @escaping ([String]) async throws -> IAMTestPermissionsResponse) {
        testProjectIAMPermissionsHandler = handler
    }
}
