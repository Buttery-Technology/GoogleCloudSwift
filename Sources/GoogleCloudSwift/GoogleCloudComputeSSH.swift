import Foundation
import NIOSSH

// MARK: - Compute SSH Integration

/// High-level SSH integration with Google Cloud Compute Engine.
///
/// Resolves instance names to IPs, injects SSH keys via metadata, and provides
/// a convenient interface for remote command execution and file transfer.
public actor GoogleCloudComputeSSH {

    private let computeAPI: GoogleCloudComputeAPI
    private let sshClient: any GoogleCloudSSHClientProtocol

    /// Initialize with a Compute API client and SSH client.
    /// - Parameters:
    ///   - computeAPI: The Compute Engine API client for instance lookups.
    ///   - sshClient: The SSH client for remote operations.
    public init(computeAPI: GoogleCloudComputeAPI, sshClient: any GoogleCloudSSHClientProtocol) {
        self.computeAPI = computeAPI
        self.sshClient = sshClient
    }

    // MARK: - Instance Resolution

    /// Get the external IP address of a Compute Engine instance.
    /// - Parameters:
    ///   - instanceName: The instance name.
    ///   - zone: The zone where the instance is located.
    /// - Returns: The external IP address.
    public func getExternalIP(instanceName: String, zone: String) async throws -> String {
        let instance = try await computeAPI.getInstance(name: instanceName, zone: zone)
        guard let ip = instance.networkInterfaces?.first?.accessConfigs?.first?.natIP else {
            throw GoogleCloudSSHError.noExternalIP(instanceName: instanceName)
        }
        return ip
    }

    // MARK: - SSH Key Injection

    /// Inject an SSH public key into an instance's metadata.
    ///
    /// Reads the current metadata, appends the new key, and updates via the Compute API.
    /// - Parameters:
    ///   - instanceName: The instance name.
    ///   - zone: The zone where the instance is located.
    ///   - keyPair: The SSH key pair to inject.
    public func injectSSHKey(
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair
    ) async throws {
        let instance = try await computeAPI.getInstance(name: instanceName, zone: zone)

        let existingSSHKeys = instance.metadata?.items?.first(where: { $0.key == "ssh-keys" })?.value
        let newValue = GoogleCloudSSHKeyManager.buildSSHKeysMetadata(
            existing: existingSSHKeys,
            newKeys: [keyPair]
        )

        guard let fingerprint = instance.metadata?.fingerprint else {
            throw GoogleCloudSSHError.keyGenerationFailed("Instance metadata has no fingerprint — cannot inject SSH key")
        }

        let sshKeysItem = MetadataItemInsert(key: "ssh-keys", value: newValue)

        // Preserve existing metadata items
        var items: [MetadataItemInsert] = instance.metadata?.items?
            .filter { $0.key != "ssh-keys" }
            .compactMap { item in
                guard let key = item.key, let value = item.value else { return nil }
                return MetadataItemInsert(key: key, value: value)
            } ?? []
        items.append(sshKeysItem)

        let operation = try await computeAPI.setMetadata(
            name: instanceName,
            zone: zone,
            items: items,
            fingerprint: fingerprint
        )

        _ = try await computeAPI.waitForOperation(operation)
    }

    // MARK: - SSH Connectivity

    /// Wait until SSH is reachable on an instance.
    /// - Parameters:
    ///   - instanceName: The instance name.
    ///   - zone: The zone.
    ///   - keyPair: The SSH key pair for authentication.
    ///   - username: The SSH username (default: key pair username).
    ///   - timeout: Maximum wait time in seconds (default: 120).
    public func waitForSSH(
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair,
        username: String? = nil,
        timeout: TimeInterval = 120
    ) async throws {
        let host = try await getExternalIP(instanceName: instanceName, zone: zone)
        let user = username ?? keyPair.username
        let start = Date()

        while Date().timeIntervalSince(start) < timeout {
            do {
                let result = try await sshClient.executeCommand(
                    "echo ok",
                    host: host,
                    port: 22,
                    username: user,
                    privateKey: keyPair.privateKey,
                    timeout: 10
                )
                if result.succeeded { return }
            } catch {
                // SSH not ready yet, retry
            }
            try await Task.sleep(nanoseconds: 5_000_000_000)
        }
        throw GoogleCloudSSHError.timeout(timeout)
    }

    // MARK: - Command Execution

    /// Execute a command on a Compute Engine instance.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - instanceName: The instance name.
    ///   - zone: The zone.
    ///   - keyPair: The SSH key pair for authentication.
    ///   - username: The SSH username (default: key pair username).
    ///   - timeout: Command timeout in seconds (default: 30).
    /// - Returns: The command result.
    public func executeCommand(
        _ command: String,
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair,
        username: String? = nil,
        timeout: TimeInterval = 30
    ) async throws -> SSHCommandResult {
        let host = try await getExternalIP(instanceName: instanceName, zone: zone)
        return try await sshClient.executeCommand(
            command,
            host: host,
            port: 22,
            username: username ?? keyPair.username,
            privateKey: keyPair.privateKey,
            timeout: timeout
        )
    }

    /// Execute multiple commands sequentially on a Compute Engine instance.
    /// - Parameters:
    ///   - commands: The shell commands to execute.
    ///   - instanceName: The instance name.
    ///   - zone: The zone.
    ///   - keyPair: The SSH key pair for authentication.
    ///   - username: The SSH username (default: key pair username).
    ///   - stopOnFailure: Whether to stop on the first failed command (default: true).
    /// - Returns: Results for each executed command.
    public func executeCommands(
        _ commands: [String],
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair,
        username: String? = nil,
        stopOnFailure: Bool = true
    ) async throws -> [SSHCommandResult] {
        let host = try await getExternalIP(instanceName: instanceName, zone: zone)
        let user = username ?? keyPair.username
        var results: [SSHCommandResult] = []

        for command in commands {
            let result = try await sshClient.executeCommand(
                command,
                host: host,
                port: 22,
                username: user,
                privateKey: keyPair.privateKey,
                timeout: 30
            )
            results.append(result)
            if stopOnFailure && !result.succeeded {
                break
            }
        }
        return results
    }

    // MARK: - File Transfer

    /// Upload a file to a Compute Engine instance.
    public func uploadFile(
        localData: Data,
        remotePath: String,
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair,
        username: String? = nil,
        permissions: String = "0644"
    ) async throws {
        let host = try await getExternalIP(instanceName: instanceName, zone: zone)
        try await sshClient.uploadFile(
            localData: localData,
            remotePath: remotePath,
            host: host,
            port: 22,
            username: username ?? keyPair.username,
            privateKey: keyPair.privateKey,
            permissions: permissions
        )
    }

    /// Download a file from a Compute Engine instance.
    public func downloadFile(
        remotePath: String,
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair,
        username: String? = nil
    ) async throws -> Data {
        let host = try await getExternalIP(instanceName: instanceName, zone: zone)
        return try await sshClient.downloadFile(
            remotePath: remotePath,
            host: host,
            port: 22,
            username: username ?? keyPair.username,
            privateKey: keyPair.privateKey
        )
    }

    // MARK: - Provisioning

    /// Provision an instance with SSH key injection, setup commands, and file uploads.
    /// - Parameters:
    ///   - instanceName: The instance name.
    ///   - zone: The zone.
    ///   - keyPair: The SSH key pair (will be injected into instance metadata).
    ///   - setupCommands: Commands to run after SSH is available.
    ///   - filesToUpload: Files to upload as (localData, remotePath) tuples.
    /// - Returns: Results of all setup commands.
    public func provisionInstance(
        instanceName: String,
        zone: String,
        keyPair: GoogleCloudSSHKeyManager.SSHKeyPair,
        setupCommands: [String] = [],
        filesToUpload: [(data: Data, remotePath: String)] = []
    ) async throws -> [SSHCommandResult] {
        // Inject SSH key
        try await injectSSHKey(instanceName: instanceName, zone: zone, keyPair: keyPair)

        // Wait for SSH to be reachable
        try await waitForSSH(instanceName: instanceName, zone: zone, keyPair: keyPair)

        // Upload files
        for file in filesToUpload {
            try await uploadFile(
                localData: file.data,
                remotePath: file.remotePath,
                instanceName: instanceName,
                zone: zone,
                keyPair: keyPair
            )
        }

        // Run setup commands
        if !setupCommands.isEmpty {
            return try await executeCommands(
                setupCommands,
                instanceName: instanceName,
                zone: zone,
                keyPair: keyPair,
                stopOnFailure: true
            )
        }
        return []
    }
}
