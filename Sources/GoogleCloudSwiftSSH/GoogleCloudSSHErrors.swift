import Foundation

// MARK: - SSH Error Types

/// Errors that can occur during SSH operations with Google Cloud instances.
public enum GoogleCloudSSHError: Error, Sendable, LocalizedError {
    /// Failed to establish a TCP connection to the remote host.
    case connectionFailed(String)

    /// SSH authentication failed (e.g., key rejected).
    case authenticationFailed(String)

    /// Failed to open an SSH channel or session.
    case channelFailed(String)

    /// A remote command exited with a non-zero status.
    case commandFailed(exitCode: Int, stderr: String)

    /// The operation exceeded the allowed time limit.
    case timeout(TimeInterval)

    /// File transfer (SCP) failed.
    case transferFailed(String)

    /// SSH key generation failed.
    case keyGenerationFailed(String)

    /// The specified instance has no external IP address.
    case noExternalIP(instanceName: String)

    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "SSH connection failed: \(message)"
        case .authenticationFailed(let message):
            return "SSH authentication failed: \(message)"
        case .channelFailed(let message):
            return "SSH channel failed: \(message)"
        case .commandFailed(let exitCode, let stderr):
            return "Command failed with exit code \(exitCode): \(stderr)"
        case .timeout(let interval):
            return "SSH operation timed out after \(Int(interval)) seconds"
        case .transferFailed(let message):
            return "File transfer failed: \(message)"
        case .keyGenerationFailed(let message):
            return "SSH key generation failed: \(message)"
        case .noExternalIP(let instanceName):
            return "Instance '\(instanceName)' has no external IP address"
        }
    }
}
