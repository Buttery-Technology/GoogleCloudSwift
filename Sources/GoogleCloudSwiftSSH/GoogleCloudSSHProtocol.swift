import Foundation
import NIOSSH

// MARK: - SSH Command Result

/// The result of executing a command over SSH.
public struct SSHCommandResult: Sendable {
    /// The exit code of the remote command.
    public let exitCode: Int

    /// Standard output from the command.
    public let stdout: String

    /// Standard error from the command.
    public let stderr: String

    /// Whether the command succeeded (exit code 0).
    public var succeeded: Bool { exitCode == 0 }

    public init(exitCode: Int, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

// MARK: - SSH Client Protocol

/// Protocol for SSH client operations, enabling mock implementations for testing.
public protocol GoogleCloudSSHClientProtocol: Actor, Sendable {
    /// Execute a command on a remote host.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - host: The remote host address.
    ///   - port: The SSH port (default: 22).
    ///   - username: The SSH username.
    ///   - privateKey: The private key for authentication.
    ///   - timeout: Maximum time to wait for the command to complete.
    /// - Returns: The command result with exit code, stdout, and stderr.
    func executeCommand(
        _ command: String,
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey,
        timeout: TimeInterval
    ) async throws -> SSHCommandResult

    /// Upload file data to a remote host via SCP.
    /// - Parameters:
    ///   - localData: The file contents to upload.
    ///   - remotePath: The destination path on the remote host.
    ///   - host: The remote host address.
    ///   - port: The SSH port (default: 22).
    ///   - username: The SSH username.
    ///   - privateKey: The private key for authentication.
    ///   - permissions: The file permissions (default: "0644").
    func uploadFile(
        localData: Data,
        remotePath: String,
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey,
        permissions: String
    ) async throws

    /// Download a file from a remote host via SCP.
    /// - Parameters:
    ///   - remotePath: The file path on the remote host.
    ///   - host: The remote host address.
    ///   - port: The SSH port (default: 22).
    ///   - username: The SSH username.
    ///   - privateKey: The private key for authentication.
    /// - Returns: The file contents.
    func downloadFile(
        remotePath: String,
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey
    ) async throws -> Data
}
