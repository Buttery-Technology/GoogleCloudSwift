//
//  GoogleCloudSecretManagerAPITests.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Mock Secret Manager API

/// Mock implementation of GoogleCloudSecretManagerAPIProtocol for testing.
actor MockSecretManagerAPI: GoogleCloudSecretManagerAPIProtocol {
    let projectId: String

    // Stubs for each method
    var listSecretsHandler: ((String?, Int?, String?) async throws -> SecretListResponse)?
    var getSecretHandler: ((String) async throws -> Secret)?
    var createSecretHandler: ((String, SecretReplication, [String: String]?) async throws -> Secret)?
    var deleteSecretHandler: ((String) async throws -> Void)?
    var addSecretVersionHandler: ((String, Data) async throws -> SecretVersion)?
    var getSecretVersionHandler: ((String, String) async throws -> SecretVersion)?
    var accessSecretVersionHandler: ((String, String) async throws -> Data)?
    var destroySecretVersionHandler: ((String, String) async throws -> SecretVersion)?

    // Call tracking
    var listSecretsCalls: [(filter: String?, pageSize: Int?, pageToken: String?)] = []
    var getSecretCalls: [String] = []
    var createSecretCalls: [(secretId: String, replication: SecretReplication, labels: [String: String]?)] = []
    var deleteSecretCalls: [String] = []
    var addSecretVersionCalls: [(secretId: String, data: Data)] = []
    var getSecretVersionCalls: [(secretId: String, version: String)] = []
    var accessSecretVersionCalls: [(secretId: String, version: String)] = []
    var destroySecretVersionCalls: [(secretId: String, version: String)] = []

    init(projectId: String = "test-project") {
        self.projectId = projectId
    }

    func listSecrets(filter: String?, pageSize: Int?, pageToken: String?) async throws -> SecretListResponse {
        listSecretsCalls.append((filter, pageSize, pageToken))
        if let handler = listSecretsHandler {
            return try await handler(filter, pageSize, pageToken)
        }
        return SecretListResponse(secrets: [], nextPageToken: nil, totalSize: nil)
    }

    func getSecret(secretId: String) async throws -> Secret {
        getSecretCalls.append(secretId)
        if let handler = getSecretHandler {
            return try await handler(secretId)
        }
        return createMockSecret(secretId: secretId)
    }

    func createSecret(secretId: String, replication: SecretReplication, labels: [String: String]?) async throws -> Secret {
        createSecretCalls.append((secretId, replication, labels))
        if let handler = createSecretHandler {
            return try await handler(secretId, replication, labels)
        }
        return createMockSecret(secretId: secretId, labels: labels)
    }

    func deleteSecret(secretId: String) async throws {
        deleteSecretCalls.append(secretId)
        if let handler = deleteSecretHandler {
            try await handler(secretId)
        }
    }

    func addSecretVersion(secretId: String, data: Data) async throws -> SecretVersion {
        addSecretVersionCalls.append((secretId, data))
        if let handler = addSecretVersionHandler {
            return try await handler(secretId, data)
        }
        return createMockSecretVersion(secretId: secretId, version: "1")
    }

    func getSecretVersion(secretId: String, version: String) async throws -> SecretVersion {
        getSecretVersionCalls.append((secretId, version))
        if let handler = getSecretVersionHandler {
            return try await handler(secretId, version)
        }
        return createMockSecretVersion(secretId: secretId, version: version)
    }

    func accessSecretVersion(secretId: String, version: String) async throws -> Data {
        accessSecretVersionCalls.append((secretId, version))
        if let handler = accessSecretVersionHandler {
            return try await handler(secretId, version)
        }
        return Data("mock-secret-value".utf8)
    }

    func destroySecretVersion(secretId: String, version: String) async throws -> SecretVersion {
        destroySecretVersionCalls.append((secretId, version))
        if let handler = destroySecretVersionHandler {
            return try await handler(secretId, version)
        }
        return createMockSecretVersion(secretId: secretId, version: version, state: "DESTROYED")
    }

    // MARK: - Mock Data Helpers

    private func createMockSecret(
        secretId: String,
        labels: [String: String]? = nil
    ) -> Secret {
        Secret(
            name: "projects/\(projectId)/secrets/\(secretId)",
            createTime: Date(),
            labels: labels,
            replication: Secret.ReplicationResponse(
                automatic: Secret.ReplicationResponse.AutomaticResponse(),
                userManaged: nil
            ),
            etag: "CAE="
        )
    }

    private func createMockSecretVersion(
        secretId: String,
        version: String,
        state: String = "ENABLED"
    ) -> SecretVersion {
        SecretVersion(
            name: "projects/\(projectId)/secrets/\(secretId)/versions/\(version)",
            createTime: Date(),
            destroyTime: state == "DESTROYED" ? Date() : nil,
            state: state,
            etag: "CAE=",
            replicationStatus: nil
        )
    }
}

// MARK: - Protocol Conformance Tests

@Test func testSecretManagerAPIProtocolConformance() {
    // Verify that GoogleCloudSecretManagerAPI conforms to the protocol
    func acceptsProtocol<T: GoogleCloudSecretManagerAPIProtocol>(_ api: T) {}

    let mock = MockSecretManagerAPI()
    acceptsProtocol(mock)
}

// MARK: - Mock Secret Manager API Tests

@Test func testMockSecretManagerAPIProjectId() async {
    let mock = MockSecretManagerAPI(projectId: "my-secret-project")
    let projectId = await mock.projectId
    #expect(projectId == "my-secret-project")
}

@Test func testMockListSecretsDefault() async throws {
    let mock = MockSecretManagerAPI()
    let result = try await mock.listSecrets(filter: nil, pageSize: nil, pageToken: nil)

    #expect(result.secrets?.isEmpty != false)
    #expect(result.nextPageToken == nil)

    let calls = await mock.listSecretsCalls
    #expect(calls.count == 1)
}

@Test func testMockListSecretsWithHandler() async throws {
    let mock = MockSecretManagerAPI()

    await mock.setListSecretsHandler { filter, pageSize, pageToken in
        let secret = Secret(
            name: "projects/test-project/secrets/my-secret",
            createTime: Date(),
            labels: ["env": "test"],
            replication: nil,
            etag: nil
        )
        return SecretListResponse(secrets: [secret], nextPageToken: "next-page", totalSize: 100)
    }

    let result = try await mock.listSecrets(filter: "labels.env:test", pageSize: 10, pageToken: nil)

    #expect(result.secrets?.count == 1)
    #expect(result.secrets?.first?.secretId == "my-secret")
    #expect(result.nextPageToken == "next-page")
    #expect(result.totalSize == 100)

    let calls = await mock.listSecretsCalls
    #expect(calls.count == 1)
    #expect(calls.first?.filter == "labels.env:test")
    #expect(calls.first?.pageSize == 10)
}

@Test func testMockGetSecret() async throws {
    let mock = MockSecretManagerAPI()
    let secret = try await mock.getSecret(secretId: "my-api-key")

    #expect(secret.secretId == "my-api-key")
    #expect(secret.name?.contains("my-api-key") == true)

    let calls = await mock.getSecretCalls
    #expect(calls == ["my-api-key"])
}

@Test func testMockCreateSecret() async throws {
    let mock = MockSecretManagerAPI()

    let secret = try await mock.createSecret(
        secretId: "new-secret",
        replication: .automatic,
        labels: ["env": "prod"]
    )

    #expect(secret.secretId == "new-secret")

    let calls = await mock.createSecretCalls
    #expect(calls.count == 1)
    #expect(calls.first?.secretId == "new-secret")
    #expect(calls.first?.labels?["env"] == "prod")
}

@Test func testMockDeleteSecret() async throws {
    let mock = MockSecretManagerAPI()

    try await mock.deleteSecret(secretId: "secret-to-delete")

    let calls = await mock.deleteSecretCalls
    #expect(calls == ["secret-to-delete"])
}

@Test func testMockAddSecretVersion() async throws {
    let mock = MockSecretManagerAPI()
    let secretData = Data("my-secret-value".utf8)

    let version = try await mock.addSecretVersion(secretId: "my-secret", data: secretData)

    #expect(version.versionId != nil)
    #expect(version.state == "ENABLED")

    let calls = await mock.addSecretVersionCalls
    #expect(calls.count == 1)
    #expect(calls.first?.secretId == "my-secret")
    #expect(calls.first?.data == secretData)
}

@Test func testMockGetSecretVersion() async throws {
    let mock = MockSecretManagerAPI()

    let version = try await mock.getSecretVersion(secretId: "my-secret", version: "2")

    #expect(version.versionId == "2")
    #expect(version.isEnabled)

    let calls = await mock.getSecretVersionCalls
    #expect(calls.count == 1)
    #expect(calls.first?.secretId == "my-secret")
    #expect(calls.first?.version == "2")
}

@Test func testMockAccessSecretVersion() async throws {
    let mock = MockSecretManagerAPI()

    await mock.setAccessSecretVersionHandler { secretId, version in
        Data("super-secret-\(secretId)-v\(version)".utf8)
    }

    let data = try await mock.accessSecretVersion(secretId: "api-key", version: "latest")
    let value = String(data: data, encoding: .utf8)

    #expect(value == "super-secret-api-key-vlatest")

    let calls = await mock.accessSecretVersionCalls
    #expect(calls.count == 1)
    #expect(calls.first?.secretId == "api-key")
    #expect(calls.first?.version == "latest")
}

@Test func testMockDestroySecretVersion() async throws {
    let mock = MockSecretManagerAPI()

    let version = try await mock.destroySecretVersion(secretId: "old-secret", version: "1")

    #expect(version.isDestroyed)
    #expect(version.state == "DESTROYED")

    let calls = await mock.destroySecretVersionCalls
    #expect(calls.count == 1)
}

@Test func testMockSecretManagerAPIErrorHandling() async {
    let mock = MockSecretManagerAPI()

    await mock.setGetSecretHandler { secretId in
        throw GoogleCloudAPIError.httpError(404, nil)
    }

    do {
        _ = try await mock.getSecret(secretId: "nonexistent-secret")
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

@Test func testSecretReplicationAutomaticEncoding() throws {
    let replication = SecretReplication.automatic
    let encoder = JSONEncoder()
    let data = try encoder.encode(replication)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["automatic"] != nil)
    #expect(json?["userManaged"] == nil)
}

@Test func testSecretReplicationUserManagedEncoding() throws {
    let replication = SecretReplication.userManaged(locations: ["us-east1", "us-west1"])
    let encoder = JSONEncoder()
    let data = try encoder.encode(replication)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["automatic"] == nil)
    let userManaged = json?["userManaged"] as? [String: Any]
    let replicas = userManaged?["replicas"] as? [[String: Any]]
    #expect(replicas?.count == 2)
    #expect(replicas?[0]["location"] as? String == "us-east1")
    #expect(replicas?[1]["location"] as? String == "us-west1")
}

@Test func testSecretPayloadEncoding() throws {
    let payload = SecretPayload(data: "SGVsbG8gV29ybGQ=") // "Hello World" base64
    let encoder = JSONEncoder()
    let data = try encoder.encode(payload)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["data"] as? String == "SGVsbG8gV29ybGQ=")
}

// MARK: - Response Type Tests

@Test func testSecretDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/secrets/my-secret",
        "createTime": "2024-01-15T10:30:00.000Z",
        "labels": {
            "env": "production",
            "team": "backend"
        },
        "replication": {
            "automatic": {}
        },
        "etag": "CAE="
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let secret = try decoder.decode(Secret.self, from: Data(json.utf8))

    #expect(secret.name == "projects/my-project/secrets/my-secret")
    #expect(secret.secretId == "my-secret")
    #expect(secret.labels?["env"] == "production")
    #expect(secret.labels?["team"] == "backend")
    #expect(secret.replication?.automatic != nil)
    #expect(secret.etag == "CAE=")
    #expect(secret.createTime != nil)
}

@Test func testSecretVersionDecoding() throws {
    let json = """
    {
        "name": "projects/my-project/secrets/my-secret/versions/3",
        "createTime": "2024-01-15T10:30:00.000Z",
        "state": "ENABLED",
        "etag": "CAI=",
        "replicationStatus": {
            "automatic": {}
        }
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let version = try decoder.decode(SecretVersion.self, from: Data(json.utf8))

    #expect(version.name == "projects/my-project/secrets/my-secret/versions/3")
    #expect(version.versionId == "3")
    #expect(version.state == "ENABLED")
    #expect(version.isEnabled)
    #expect(!version.isDisabled)
    #expect(!version.isDestroyed)
    #expect(version.createTime != nil)
}

@Test func testSecretVersionStateHelpers() {
    let enabledVersion = SecretVersion(
        name: "projects/p/secrets/s/versions/1",
        createTime: nil,
        destroyTime: nil,
        state: "ENABLED",
        etag: nil,
        replicationStatus: nil
    )
    #expect(enabledVersion.isEnabled)
    #expect(!enabledVersion.isDisabled)
    #expect(!enabledVersion.isDestroyed)

    let disabledVersion = SecretVersion(
        name: "projects/p/secrets/s/versions/2",
        createTime: nil,
        destroyTime: nil,
        state: "DISABLED",
        etag: nil,
        replicationStatus: nil
    )
    #expect(!disabledVersion.isEnabled)
    #expect(disabledVersion.isDisabled)
    #expect(!disabledVersion.isDestroyed)

    let destroyedVersion = SecretVersion(
        name: "projects/p/secrets/s/versions/3",
        createTime: Date(),
        destroyTime: Date(),
        state: "DESTROYED",
        etag: nil,
        replicationStatus: nil
    )
    #expect(!destroyedVersion.isEnabled)
    #expect(!destroyedVersion.isDisabled)
    #expect(destroyedVersion.isDestroyed)
}

@Test func testSecretListResponseDecoding() throws {
    let json = """
    {
        "secrets": [
            {"name": "projects/p/secrets/secret1"},
            {"name": "projects/p/secrets/secret2"}
        ],
        "nextPageToken": "token123",
        "totalSize": 50
    }
    """

    let decoder = JSONDecoder()
    let response = try decoder.decode(SecretListResponse.self, from: Data(json.utf8))

    #expect(response.secrets?.count == 2)
    #expect(response.secrets?[0].secretId == "secret1")
    #expect(response.secrets?[1].secretId == "secret2")
    #expect(response.nextPageToken == "token123")
    #expect(response.totalSize == 50)
}

@Test func testSecretVersionListResponseDecoding() throws {
    let json = """
    {
        "versions": [
            {"name": "projects/p/secrets/s/versions/1", "state": "DESTROYED"},
            {"name": "projects/p/secrets/s/versions/2", "state": "DISABLED"},
            {"name": "projects/p/secrets/s/versions/3", "state": "ENABLED"}
        ],
        "nextPageToken": null,
        "totalSize": 3
    }
    """

    let decoder = JSONDecoder()
    let response = try decoder.decode(SecretVersionListResponse.self, from: Data(json.utf8))

    #expect(response.versions?.count == 3)
    #expect(response.versions?[0].isDestroyed == true)
    #expect(response.versions?[1].isDisabled == true)
    #expect(response.versions?[2].isEnabled == true)
    #expect(response.totalSize == 3)
}

@Test func testSecretIdExtraction() {
    let secret = Secret(
        name: "projects/my-project/secrets/api-key-prod",
        createTime: nil,
        labels: nil,
        replication: nil,
        etag: nil
    )

    #expect(secret.secretId == "api-key-prod")
}

@Test func testSecretVersionIdExtraction() {
    let version = SecretVersion(
        name: "projects/my-project/secrets/my-secret/versions/42",
        createTime: nil,
        destroyTime: nil,
        state: "ENABLED",
        etag: nil,
        replicationStatus: nil
    )

    #expect(version.versionId == "42")
}

// MARK: - Mock Helper Extensions

extension MockSecretManagerAPI {
    func setListSecretsHandler(_ handler: @escaping (String?, Int?, String?) async throws -> SecretListResponse) {
        listSecretsHandler = handler
    }

    func setGetSecretHandler(_ handler: @escaping (String) async throws -> Secret) {
        getSecretHandler = handler
    }

    func setAccessSecretVersionHandler(_ handler: @escaping (String, String) async throws -> Data) {
        accessSecretVersionHandler = handler
    }
}
