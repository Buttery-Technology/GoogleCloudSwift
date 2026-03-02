import Foundation
import Crypto
import NIOSSH

// MARK: - SSH Key Manager

/// Manages SSH key pair generation and formatting for Google Cloud Compute Engine.
public struct GoogleCloudSSHKeyManager: Sendable {

    /// Supported key algorithms for SSH key generation.
    public enum KeyAlgorithm: Sendable {
        case ed25519
        case ecdsaP256
        case ecdsaP384
    }

    /// An SSH key pair with the private key and formatted public key.
    public struct SSHKeyPair: Sendable {
        /// The NIO SSH private key for authentication.
        public let privateKey: NIOSSHPrivateKey

        /// The public key in OpenSSH authorized_keys format (e.g., "ssh-ed25519 AAAA... user@host").
        public let authorizedKey: String

        /// The username associated with this key pair.
        public let username: String
    }

    /// Generate a new SSH key pair.
    /// - Parameters:
    ///   - algorithm: The key algorithm to use (default: Ed25519).
    ///   - username: The username for the public key comment.
    /// - Returns: A new SSH key pair.
    public static func generateKeyPair(
        algorithm: KeyAlgorithm = .ed25519,
        username: String = "dais"
    ) throws -> SSHKeyPair {
        switch algorithm {
        case .ed25519:
            let privateKey = Curve25519.Signing.PrivateKey()
            let nioKey = NIOSSHPrivateKey(ed25519Key: privateKey)
            let publicKeyData = privateKey.publicKey.rawRepresentation
            let keyType = "ssh-ed25519"
            var encoded = Data()
            encoded.appendSSHString(keyType)
            encoded.appendSSHBytes(publicKeyData)
            let authorizedKey = "\(keyType) \(encoded.base64EncodedString()) \(username)"
            return SSHKeyPair(privateKey: nioKey, authorizedKey: authorizedKey, username: username)

        case .ecdsaP256:
            let privateKey = P256.Signing.PrivateKey()
            let nioKey = NIOSSHPrivateKey(p256Key: privateKey)
            let publicKeyBytes = privateKey.publicKey.x963Representation
            let keyType = "ecdsa-sha2-nistp256"
            let curveName = "nistp256"
            var encoded = Data()
            encoded.appendSSHString(keyType)
            encoded.appendSSHString(curveName)
            encoded.appendSSHBytes(publicKeyBytes)
            let authorizedKey = "\(keyType) \(encoded.base64EncodedString()) \(username)"
            return SSHKeyPair(privateKey: nioKey, authorizedKey: authorizedKey, username: username)

        case .ecdsaP384:
            let privateKey = P384.Signing.PrivateKey()
            let nioKey = NIOSSHPrivateKey(p384Key: privateKey)
            let publicKeyBytes = privateKey.publicKey.x963Representation
            let keyType = "ecdsa-sha2-nistp384"
            let curveName = "nistp384"
            var encoded = Data()
            encoded.appendSSHString(keyType)
            encoded.appendSSHString(curveName)
            encoded.appendSSHBytes(publicKeyBytes)
            let authorizedKey = "\(keyType) \(encoded.base64EncodedString()) \(username)"
            return SSHKeyPair(privateKey: nioKey, authorizedKey: authorizedKey, username: username)
        }
    }

    /// Format a key pair for GCE instance metadata.
    ///
    /// GCE expects SSH keys in the format: `username:ssh-type base64key username`
    /// - Parameter keyPair: The key pair to format.
    /// - Returns: A metadata-formatted string.
    public static func formatForGCEMetadata(_ keyPair: SSHKeyPair) -> String {
        "\(keyPair.username):\(keyPair.authorizedKey)"
    }

    /// Build a complete `ssh-keys` metadata value by appending new keys to existing ones.
    /// - Parameters:
    ///   - existing: The current `ssh-keys` metadata value (may be nil or empty).
    ///   - newKeys: Key pairs to add.
    /// - Returns: The combined metadata value with one key per line.
    public static func buildSSHKeysMetadata(
        existing: String?,
        newKeys: [SSHKeyPair]
    ) -> String {
        var lines: [String] = []
        if let existing, !existing.isEmpty {
            lines = existing.components(separatedBy: "\n").filter { !$0.isEmpty }
        }
        for key in newKeys {
            let formatted = formatForGCEMetadata(key)
            if !lines.contains(formatted) {
                lines.append(formatted)
            }
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Data SSH Encoding Helpers

extension Data {
    mutating func appendSSHString(_ string: String) {
        let bytes = Array(string.utf8)
        appendSSHUInt32(UInt32(bytes.count))
        append(contentsOf: bytes)
    }

    mutating func appendSSHBytes(_ bytes: Data) {
        appendSSHUInt32(UInt32(bytes.count))
        append(bytes)
    }

    mutating func appendSSHBytes(_ bytes: [UInt8]) {
        appendSSHUInt32(UInt32(bytes.count))
        append(contentsOf: bytes)
    }

    mutating func appendSSHUInt32(_ value: UInt32) {
        var bigEndian = value.bigEndian
        append(Data(bytes: &bigEndian, count: 4))
    }
}
