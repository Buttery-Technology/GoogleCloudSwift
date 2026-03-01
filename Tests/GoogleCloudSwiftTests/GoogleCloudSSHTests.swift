import Foundation
import Testing
import NIOSSH
@testable import GoogleCloudSwift

// MARK: - Mock SSH Client

/// Mock implementation of GoogleCloudSSHClientProtocol for testing.
actor MockSSHClient: GoogleCloudSSHClientProtocol {
    private var executeCommandHandler: ((String, String, Int, String) async throws -> SSHCommandResult)?
    private var uploadFileHandler: ((Data, String, String) async throws -> Void)?
    private var downloadFileHandler: ((String, String) async throws -> Data)?

    var executeCommandCalls: [(command: String, host: String, port: Int, username: String)] = []
    var uploadFileCalls: [(remotePath: String, host: String)] = []
    var downloadFileCalls: [(remotePath: String, host: String)] = []

    func setExecuteCommandHandler(_ handler: @escaping (String, String, Int, String) async throws -> SSHCommandResult) {
        executeCommandHandler = handler
    }

    func setDownloadFileHandler(_ handler: @escaping (String, String) async throws -> Data) {
        downloadFileHandler = handler
    }

    func executeCommand(
        _ command: String,
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey,
        timeout: TimeInterval
    ) async throws -> SSHCommandResult {
        executeCommandCalls.append((command, host, port, username))
        if let handler = executeCommandHandler {
            return try await handler(command, host, port, username)
        }
        return SSHCommandResult(exitCode: 0, stdout: "", stderr: "")
    }

    func uploadFile(
        localData: Data,
        remotePath: String,
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey,
        permissions: String
    ) async throws {
        uploadFileCalls.append((remotePath, host))
        if let handler = uploadFileHandler {
            try await handler(localData, remotePath, host)
        }
    }

    func downloadFile(
        remotePath: String,
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey
    ) async throws -> Data {
        downloadFileCalls.append((remotePath, host))
        if let handler = downloadFileHandler {
            return try await handler(remotePath, host)
        }
        return Data()
    }
}

// MARK: - Key Generation Tests

@Test func testEd25519KeyGeneration() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair(algorithm: .ed25519, username: "testuser")

    #expect(keyPair.username == "testuser")
    #expect(keyPair.authorizedKey.hasPrefix("ssh-ed25519 "))
    #expect(keyPair.authorizedKey.hasSuffix(" testuser"))
}

@Test func testECDSAP256KeyGeneration() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair(algorithm: .ecdsaP256, username: "ec2-user")

    #expect(keyPair.username == "ec2-user")
    #expect(keyPair.authorizedKey.hasPrefix("ecdsa-sha2-nistp256 "))
    #expect(keyPair.authorizedKey.hasSuffix(" ec2-user"))
}

@Test func testECDSAP384KeyGeneration() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair(algorithm: .ecdsaP384, username: "admin")

    #expect(keyPair.username == "admin")
    #expect(keyPair.authorizedKey.hasPrefix("ecdsa-sha2-nistp384 "))
    #expect(keyPair.authorizedKey.hasSuffix(" admin"))
}

@Test func testDefaultKeyGeneration() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair()

    #expect(keyPair.username == "dais")
    #expect(keyPair.authorizedKey.hasPrefix("ssh-ed25519 "))
}

@Test func testKeyPairsAreUnique() throws {
    let keyPair1 = try GoogleCloudSSHKeyManager.generateKeyPair()
    let keyPair2 = try GoogleCloudSSHKeyManager.generateKeyPair()

    #expect(keyPair1.authorizedKey != keyPair2.authorizedKey)
}

// MARK: - GCE Metadata Formatting Tests

@Test func testFormatForGCEMetadata() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair(username: "deployer")
    let formatted = GoogleCloudSSHKeyManager.formatForGCEMetadata(keyPair)

    #expect(formatted.hasPrefix("deployer:ssh-ed25519 "))
    #expect(formatted.contains(" deployer"))
}

@Test func testBuildSSHKeysMetadataFromEmpty() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair(username: "user1")
    let metadata = GoogleCloudSSHKeyManager.buildSSHKeysMetadata(existing: nil, newKeys: [keyPair])

    #expect(metadata.contains("user1:ssh-ed25519"))
    #expect(!metadata.contains("\n"))
}

@Test func testBuildSSHKeysMetadataAppends() throws {
    let keyPair1 = try GoogleCloudSSHKeyManager.generateKeyPair(username: "user1")
    let existing = GoogleCloudSSHKeyManager.formatForGCEMetadata(keyPair1)

    let keyPair2 = try GoogleCloudSSHKeyManager.generateKeyPair(username: "user2")
    let metadata = GoogleCloudSSHKeyManager.buildSSHKeysMetadata(existing: existing, newKeys: [keyPair2])

    let lines = metadata.components(separatedBy: "\n")
    #expect(lines.count == 2)
    #expect(lines[0].hasPrefix("user1:"))
    #expect(lines[1].hasPrefix("user2:"))
}

@Test func testBuildSSHKeysMetadataDeduplicates() throws {
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair(username: "user1")
    let existing = GoogleCloudSSHKeyManager.formatForGCEMetadata(keyPair)

    let metadata = GoogleCloudSSHKeyManager.buildSSHKeysMetadata(existing: existing, newKeys: [keyPair])

    let lines = metadata.components(separatedBy: "\n")
    #expect(lines.count == 1)
}

// MARK: - SSHCommandResult Tests

@Test func testSSHCommandResultSucceeded() {
    let result = SSHCommandResult(exitCode: 0, stdout: "hello", stderr: "")
    #expect(result.succeeded)
    #expect(result.exitCode == 0)
    #expect(result.stdout == "hello")
}

@Test func testSSHCommandResultFailed() {
    let result = SSHCommandResult(exitCode: 1, stdout: "", stderr: "error occurred")
    #expect(!result.succeeded)
    #expect(result.exitCode == 1)
    #expect(result.stderr == "error occurred")
}

@Test func testSSHCommandResultNonZeroExitCode() {
    let result = SSHCommandResult(exitCode: 127, stdout: "", stderr: "command not found")
    #expect(!result.succeeded)
    #expect(result.exitCode == 127)
}

// MARK: - Error Type Tests

@Test func testSSHErrorDescriptions() {
    let errors: [GoogleCloudSSHError] = [
        .connectionFailed("refused"),
        .authenticationFailed("key rejected"),
        .channelFailed("session open failed"),
        .commandFailed(exitCode: 1, stderr: "oops"),
        .timeout(30),
        .transferFailed("scp error"),
        .keyGenerationFailed("bad algorithm"),
        .noExternalIP(instanceName: "my-vm"),
    ]

    for error in errors {
        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
    }
}

@Test func testSSHErrorNoExternalIP() {
    let error = GoogleCloudSSHError.noExternalIP(instanceName: "test-vm")
    #expect(error.errorDescription?.contains("test-vm") == true)
}

@Test func testSSHErrorCommandFailed() {
    let error = GoogleCloudSSHError.commandFailed(exitCode: 2, stderr: "file not found")
    #expect(error.errorDescription?.contains("2") == true)
    #expect(error.errorDescription?.contains("file not found") == true)
}

// MARK: - Mock SSH Client Integration Tests

@Test func testMockSSHClientExecuteCommand() async throws {
    let mock = MockSSHClient()
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair()

    await mock.setExecuteCommandHandler { command, host, port, username in
        SSHCommandResult(exitCode: 0, stdout: "pong", stderr: "")
    }

    let result = try await mock.executeCommand(
        "echo pong",
        host: "10.0.0.1",
        port: 22,
        username: "dais",
        privateKey: keyPair.privateKey,
        timeout: 10
    )

    #expect(result.succeeded)
    #expect(result.stdout == "pong")

    let calls = await mock.executeCommandCalls
    #expect(calls.count == 1)
    #expect(calls[0].command == "echo pong")
    #expect(calls[0].host == "10.0.0.1")
}

@Test func testMockSSHClientUploadFile() async throws {
    let mock = MockSSHClient()
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair()
    let testData = Data("hello world".utf8)

    try await mock.uploadFile(
        localData: testData,
        remotePath: "/tmp/test.txt",
        host: "10.0.0.1",
        port: 22,
        username: "dais",
        privateKey: keyPair.privateKey,
        permissions: "0644"
    )

    let calls = await mock.uploadFileCalls
    #expect(calls.count == 1)
    #expect(calls[0].remotePath == "/tmp/test.txt")
}

@Test func testMockSSHClientDownloadFile() async throws {
    let mock = MockSSHClient()
    let keyPair = try GoogleCloudSSHKeyManager.generateKeyPair()
    let expectedData = Data("file contents".utf8)

    await mock.setDownloadFileHandler { _, _ in expectedData }

    let result = try await mock.downloadFile(
        remotePath: "/opt/dais/.env",
        host: "10.0.0.1",
        port: 22,
        username: "dais",
        privateKey: keyPair.privateKey
    )

    #expect(result == expectedData)

    let calls = await mock.downloadFileCalls
    #expect(calls.count == 1)
    #expect(calls[0].remotePath == "/opt/dais/.env")
}

// MARK: - SSH Client Protocol Conformance

@Test func testSSHClientProtocolConformance() {
    func acceptsProtocol<T: GoogleCloudSSHClientProtocol>(_ client: T) {}

    let mock = MockSSHClient()
    acceptsProtocol(mock)
}

@Test func testGoogleCloudSSHClientConformsToProtocol() {
    func acceptsProtocol<T: GoogleCloudSSHClientProtocol>(_ client: T) {}

    let client = GoogleCloudSSHClient()
    acceptsProtocol(client)
}
