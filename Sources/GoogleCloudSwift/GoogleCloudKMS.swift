// GoogleCloudKMS.swift
// Cloud KMS - Key Management Service
//
// Cloud KMS provides centralized key management with hardware security module
// (HSM) support for encryption, signing, and key rotation.

import Foundation

// MARK: - Key Ring

/// Represents a Cloud KMS key ring
public struct GoogleCloudKeyRing: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String

    public init(
        name: String,
        projectID: String,
        location: String
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/keyRings/\(name)"
    }

    /// Command to create key ring
    public var createCommand: String {
        "gcloud kms keyrings create \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to describe key ring
    public var describeCommand: String {
        "gcloud kms keyrings describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to list key rings
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud kms keyrings list --location=\(location) --project=\(projectID)"
    }

    /// Command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud kms keyrings get-iam-policy \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to add IAM binding
    public func addIAMBindingCommand(member: String, role: String) -> String {
        "gcloud kms keyrings add-iam-policy-binding \(name) --location=\(location) --project=\(projectID) --member=\"\(member)\" --role=\"\(role)\""
    }
}

// MARK: - Crypto Key

/// Represents a Cloud KMS crypto key
public struct GoogleCloudCryptoKey: Codable, Sendable, Equatable {
    public let name: String
    public let keyRing: String
    public let projectID: String
    public let location: String
    public let purpose: KeyPurpose
    public let protectionLevel: ProtectionLevel
    public let rotationPeriod: String?
    public let nextRotationTime: Date?
    public let versionTemplate: VersionTemplate?
    public let labels: [String: String]?

    public init(
        name: String,
        keyRing: String,
        projectID: String,
        location: String,
        purpose: KeyPurpose = .encryptDecrypt,
        protectionLevel: ProtectionLevel = .software,
        rotationPeriod: String? = nil,
        nextRotationTime: Date? = nil,
        versionTemplate: VersionTemplate? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.keyRing = keyRing
        self.projectID = projectID
        self.location = location
        self.purpose = purpose
        self.protectionLevel = protectionLevel
        self.rotationPeriod = rotationPeriod
        self.nextRotationTime = nextRotationTime
        self.versionTemplate = versionTemplate
        self.labels = labels
    }

    /// Key purpose
    public enum KeyPurpose: String, Codable, Sendable, Equatable {
        case encryptDecrypt = "encryption"
        case asymmetricSign = "asymmetric-signing"
        case asymmetricDecrypt = "asymmetric-encryption"
        case mac = "mac"
        case rawEncryptDecrypt = "raw-encryption"

        public var description: String {
            switch self {
            case .encryptDecrypt:
                return "Symmetric encryption and decryption"
            case .asymmetricSign:
                return "Asymmetric signing"
            case .asymmetricDecrypt:
                return "Asymmetric encryption"
            case .mac:
                return "MAC signing and verification"
            case .rawEncryptDecrypt:
                return "Raw symmetric encryption"
            }
        }
    }

    /// Protection level
    public enum ProtectionLevel: String, Codable, Sendable, Equatable {
        case software = "software"
        case hsm = "hsm"
        case external = "external"
        case externalVpc = "external-vpc"

        public var description: String {
            switch self {
            case .software:
                return "Software-protected key"
            case .hsm:
                return "Hardware Security Module protected"
            case .external:
                return "Externally managed key"
            case .externalVpc:
                return "External key via VPC"
            }
        }
    }

    /// Version template configuration
    public struct VersionTemplate: Codable, Sendable, Equatable {
        public let algorithm: Algorithm
        public let protectionLevel: ProtectionLevel

        public init(algorithm: Algorithm, protectionLevel: ProtectionLevel = .software) {
            self.algorithm = algorithm
            self.protectionLevel = protectionLevel
        }
    }

    /// Key algorithm
    public enum Algorithm: String, Codable, Sendable, Equatable {
        // Symmetric encryption
        case googleSymmetricEncryption = "google-symmetric-encryption"
        case aes128Gcm = "aes-128-gcm"
        case aes256Gcm = "aes-256-gcm"
        case aes128Cbc = "aes-128-cbc"
        case aes256Cbc = "aes-256-cbc"
        case aes128Ctr = "aes-128-ctr"
        case aes256Ctr = "aes-256-ctr"

        // RSA signing
        case rsaSignPss2048Sha256 = "rsa-sign-pss-2048-sha256"
        case rsaSignPss3072Sha256 = "rsa-sign-pss-3072-sha256"
        case rsaSignPss4096Sha256 = "rsa-sign-pss-4096-sha256"
        case rsaSignPss4096Sha512 = "rsa-sign-pss-4096-sha512"
        case rsaSignPkcs12048Sha256 = "rsa-sign-pkcs1-2048-sha256"
        case rsaSignPkcs13072Sha256 = "rsa-sign-pkcs1-3072-sha256"
        case rsaSignPkcs14096Sha256 = "rsa-sign-pkcs1-4096-sha256"
        case rsaSignPkcs14096Sha512 = "rsa-sign-pkcs1-4096-sha512"

        // EC signing
        case ecSignP256Sha256 = "ec-sign-p256-sha256"
        case ecSignP384Sha384 = "ec-sign-p384-sha384"
        case ecSignSecp256k1Sha256 = "ec-sign-secp256k1-sha256"

        // RSA encryption
        case rsaDecryptOaep2048Sha256 = "rsa-decrypt-oaep-2048-sha256"
        case rsaDecryptOaep3072Sha256 = "rsa-decrypt-oaep-3072-sha256"
        case rsaDecryptOaep4096Sha256 = "rsa-decrypt-oaep-4096-sha256"
        case rsaDecryptOaep4096Sha512 = "rsa-decrypt-oaep-4096-sha512"

        // HMAC
        case hmacSha256 = "hmac-sha256"
        case hmacSha1 = "hmac-sha1"
        case hmacSha384 = "hmac-sha384"
        case hmacSha512 = "hmac-sha512"
        case hmacSha224 = "hmac-sha224"
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/keyRings/\(keyRing)/cryptoKeys/\(name)"
    }

    /// Command to create crypto key
    public var createCommand: String {
        var cmd = "gcloud kms keys create \(name)"
        cmd += " --keyring=\(keyRing)"
        cmd += " --location=\(location)"
        cmd += " --project=\(projectID)"
        cmd += " --purpose=\(purpose.rawValue)"
        cmd += " --protection-level=\(protectionLevel.rawValue)"

        if let rotationPeriod = rotationPeriod {
            cmd += " --rotation-period=\(rotationPeriod)"
        }

        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }

        return cmd
    }

    /// Command to describe crypto key
    public var describeCommand: String {
        "gcloud kms keys describe \(name) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to list crypto keys
    public static func listCommand(keyRing: String, location: String, projectID: String) -> String {
        "gcloud kms keys list --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to update rotation schedule
    public func updateRotationCommand(rotationPeriod: String) -> String {
        "gcloud kms keys update \(name) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --rotation-period=\(rotationPeriod)"
    }

    /// Command to set primary version
    public func setPrimaryVersionCommand(version: String) -> String {
        "gcloud kms keys set-primary-version \(name) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version)"
    }

    /// Command to get IAM policy
    public var getIAMPolicyCommand: String {
        "gcloud kms keys get-iam-policy \(name) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to add IAM binding
    public func addIAMBindingCommand(member: String, role: String) -> String {
        "gcloud kms keys add-iam-policy-binding \(name) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --member=\"\(member)\" --role=\"\(role)\""
    }
}

// MARK: - Crypto Key Version

/// Represents a specific version of a crypto key
public struct GoogleCloudCryptoKeyVersion: Codable, Sendable, Equatable {
    public let keyName: String
    public let keyRing: String
    public let projectID: String
    public let location: String
    public let version: String
    public let state: VersionState?

    public init(
        keyName: String,
        keyRing: String,
        projectID: String,
        location: String,
        version: String,
        state: VersionState? = nil
    ) {
        self.keyName = keyName
        self.keyRing = keyRing
        self.projectID = projectID
        self.location = location
        self.version = version
        self.state = state
    }

    /// Version state
    public enum VersionState: String, Codable, Sendable, Equatable {
        case pendingGeneration = "PENDING_GENERATION"
        case enabled = "ENABLED"
        case disabled = "DISABLED"
        case destroyed = "DESTROYED"
        case destroyScheduled = "DESTROY_SCHEDULED"
        case pendingImport = "PENDING_IMPORT"
        case importFailed = "IMPORT_FAILED"
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/keyRings/\(keyRing)/cryptoKeys/\(keyName)/cryptoKeyVersions/\(version)"
    }

    /// Command to create new version
    public var createCommand: String {
        "gcloud kms keys versions create --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to describe version
    public var describeCommand: String {
        "gcloud kms keys versions describe \(version) --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to disable version
    public var disableCommand: String {
        "gcloud kms keys versions disable \(version) --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to enable version
    public var enableCommand: String {
        "gcloud kms keys versions enable \(version) --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to destroy version (with 24h delay)
    public var destroyCommand: String {
        "gcloud kms keys versions destroy \(version) --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to restore version (before destruction completes)
    public var restoreCommand: String {
        "gcloud kms keys versions restore \(version) --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to list versions
    public static func listCommand(keyName: String, keyRing: String, location: String, projectID: String) -> String {
        "gcloud kms keys versions list --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }

    /// Command to get public key (for asymmetric keys)
    public var getPublicKeyCommand: String {
        "gcloud kms keys versions get-public-key \(version) --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID)"
    }
}

// MARK: - KMS Operations

/// Common KMS operations
public enum KMSOperations {

    /// Encrypt plaintext
    public static func encryptCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        plaintextFile: String,
        ciphertextFile: String
    ) -> String {
        "gcloud kms encrypt --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --plaintext-file=\(plaintextFile) --ciphertext-file=\(ciphertextFile)"
    }

    /// Decrypt ciphertext
    public static func decryptCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        ciphertextFile: String,
        plaintextFile: String
    ) -> String {
        "gcloud kms decrypt --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --ciphertext-file=\(ciphertextFile) --plaintext-file=\(plaintextFile)"
    }

    /// Sign data with asymmetric key
    public static func asymmetricSignCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        version: String,
        inputFile: String,
        signatureFile: String,
        digestAlgorithm: String = "sha256"
    ) -> String {
        "gcloud kms asymmetric-sign --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version) --input-file=\(inputFile) --signature-file=\(signatureFile) --digest-algorithm=\(digestAlgorithm)"
    }

    /// Verify signature with asymmetric key
    public static func asymmetricVerifyCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        version: String,
        inputFile: String,
        signatureFile: String,
        digestAlgorithm: String = "sha256"
    ) -> String {
        "gcloud kms asymmetric-verify --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version) --input-file=\(inputFile) --signature-file=\(signatureFile) --digest-algorithm=\(digestAlgorithm)"
    }

    /// Create MAC signature
    public static func macSignCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        version: String,
        inputFile: String,
        signatureFile: String
    ) -> String {
        "gcloud kms mac-sign --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version) --input-file=\(inputFile) --signature-file=\(signatureFile)"
    }

    /// Verify MAC signature
    public static func macVerifyCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        version: String,
        inputFile: String,
        signatureFile: String
    ) -> String {
        "gcloud kms mac-verify --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version) --input-file=\(inputFile) --signature-file=\(signatureFile)"
    }

    /// Raw encrypt (for raw-encryption keys)
    public static func rawEncryptCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        version: String,
        plaintextFile: String,
        ciphertextFile: String
    ) -> String {
        "gcloud kms raw-encrypt --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version) --plaintext-file=\(plaintextFile) --ciphertext-file=\(ciphertextFile)"
    }

    /// Raw decrypt (for raw-encryption keys)
    public static func rawDecryptCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        version: String,
        ciphertextFile: String,
        plaintextFile: String
    ) -> String {
        "gcloud kms raw-decrypt --key=\(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --version=\(version) --ciphertext-file=\(ciphertextFile) --plaintext-file=\(plaintextFile)"
    }
}

// MARK: - KMS Roles

/// Predefined IAM roles for Cloud KMS
public enum KMSRole: String, Codable, Sendable, Equatable {
    case admin = "roles/cloudkms.admin"
    case cryptoKeyDecrypter = "roles/cloudkms.cryptoKeyDecrypter"
    case cryptoKeyEncrypter = "roles/cloudkms.cryptoKeyEncrypter"
    case cryptoKeyEncrypterDecrypter = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    case publicKeyViewer = "roles/cloudkms.publicKeyViewer"
    case signer = "roles/cloudkms.signer"
    case signerVerifier = "roles/cloudkms.signerVerifier"
    case viewer = "roles/cloudkms.viewer"
    case importer = "roles/cloudkms.importer"

    public var description: String {
        switch self {
        case .admin:
            return "Full control over Cloud KMS resources"
        case .cryptoKeyDecrypter:
            return "Decrypt using crypto keys"
        case .cryptoKeyEncrypter:
            return "Encrypt using crypto keys"
        case .cryptoKeyEncrypterDecrypter:
            return "Encrypt and decrypt using crypto keys"
        case .publicKeyViewer:
            return "View public keys for asymmetric keys"
        case .signer:
            return "Sign data using crypto keys"
        case .signerVerifier:
            return "Sign and verify using crypto keys"
        case .viewer:
            return "Read-only access to KMS resources"
        case .importer:
            return "Import keys into KMS"
        }
    }
}

// MARK: - DAIS KMS Templates

/// DAIS-specific KMS configurations
public enum DAISKMSTemplate {

    /// Key ring for DAIS deployment
    public static func keyRing(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> GoogleCloudKeyRing {
        GoogleCloudKeyRing(
            name: "\(deploymentName)-keyring",
            projectID: projectID,
            location: location
        )
    }

    /// Encryption key for data at rest
    public static func dataEncryptionKey(
        projectID: String,
        location: String,
        keyRing: String,
        deploymentName: String
    ) -> GoogleCloudCryptoKey {
        GoogleCloudCryptoKey(
            name: "\(deploymentName)-data-key",
            keyRing: keyRing,
            projectID: projectID,
            location: location,
            purpose: .encryptDecrypt,
            protectionLevel: .software,
            rotationPeriod: "7776000s", // 90 days
            labels: ["environment": "production", "purpose": "data-encryption"]
        )
    }

    /// HSM-protected encryption key
    public static func hsmEncryptionKey(
        projectID: String,
        location: String,
        keyRing: String,
        deploymentName: String
    ) -> GoogleCloudCryptoKey {
        GoogleCloudCryptoKey(
            name: "\(deploymentName)-hsm-key",
            keyRing: keyRing,
            projectID: projectID,
            location: location,
            purpose: .encryptDecrypt,
            protectionLevel: .hsm,
            rotationPeriod: "2592000s", // 30 days
            labels: ["environment": "production", "purpose": "hsm-encryption"]
        )
    }

    /// Signing key for JWT tokens
    public static func signingKey(
        projectID: String,
        location: String,
        keyRing: String,
        deploymentName: String
    ) -> GoogleCloudCryptoKey {
        GoogleCloudCryptoKey(
            name: "\(deploymentName)-signing-key",
            keyRing: keyRing,
            projectID: projectID,
            location: location,
            purpose: .asymmetricSign,
            protectionLevel: .software,
            versionTemplate: GoogleCloudCryptoKey.VersionTemplate(
                algorithm: .ecSignP256Sha256,
                protectionLevel: .software
            ),
            labels: ["environment": "production", "purpose": "signing"]
        )
    }

    /// MAC key for API authentication
    public static func macKey(
        projectID: String,
        location: String,
        keyRing: String,
        deploymentName: String
    ) -> GoogleCloudCryptoKey {
        GoogleCloudCryptoKey(
            name: "\(deploymentName)-mac-key",
            keyRing: keyRing,
            projectID: projectID,
            location: location,
            purpose: .mac,
            protectionLevel: .software,
            versionTemplate: GoogleCloudCryptoKey.VersionTemplate(
                algorithm: .hmacSha256,
                protectionLevel: .software
            ),
            labels: ["environment": "production", "purpose": "mac"]
        )
    }

    /// Setup script for DAIS KMS
    public static func setupScript(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Cloud KMS Setup Script
        set -e

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        DEPLOYMENT_NAME="\(deploymentName)"
        KEYRING_NAME="${DEPLOYMENT_NAME}-keyring"

        echo "Enabling Cloud KMS API..."
        gcloud services enable cloudkms.googleapis.com --project=${PROJECT_ID}

        echo "Creating key ring..."
        gcloud kms keyrings create ${KEYRING_NAME} \\
            --location=${LOCATION} \\
            --project=${PROJECT_ID} || true

        echo "Creating data encryption key..."
        gcloud kms keys create ${DEPLOYMENT_NAME}-data-key \\
            --keyring=${KEYRING_NAME} \\
            --location=${LOCATION} \\
            --project=${PROJECT_ID} \\
            --purpose=encryption \\
            --rotation-period=7776000s \\
            --labels=environment=production,purpose=data-encryption || true

        echo "Creating signing key..."
        gcloud kms keys create ${DEPLOYMENT_NAME}-signing-key \\
            --keyring=${KEYRING_NAME} \\
            --location=${LOCATION} \\
            --project=${PROJECT_ID} \\
            --purpose=asymmetric-signing \\
            --default-algorithm=ec-sign-p256-sha256 \\
            --labels=environment=production,purpose=signing || true

        echo "Cloud KMS setup complete!"
        """
    }

    /// Teardown script for DAIS KMS
    public static func teardownScript(
        projectID: String,
        location: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Cloud KMS Teardown Script
        # WARNING: Key destruction is permanent after 24 hours!
        set -e

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        DEPLOYMENT_NAME="\(deploymentName)"
        KEYRING_NAME="${DEPLOYMENT_NAME}-keyring"

        echo "WARNING: This will schedule key versions for destruction!"
        echo "Keys will be permanently destroyed after 24 hours."
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Aborted."
            exit 1
        fi

        echo "Scheduling key versions for destruction..."
        for key in $(gcloud kms keys list --keyring=${KEYRING_NAME} --location=${LOCATION} --project=${PROJECT_ID} --format="value(name)"); do
            for version in $(gcloud kms keys versions list --key=${key} --keyring=${KEYRING_NAME} --location=${LOCATION} --project=${PROJECT_ID} --format="value(name)" --filter="state=ENABLED"); do
                echo "Destroying version: ${version}"
                gcloud kms keys versions destroy ${version} \\
                    --key=${key} \\
                    --keyring=${KEYRING_NAME} \\
                    --location=${LOCATION} \\
                    --project=${PROJECT_ID} --quiet || true
            done
        done

        echo "Cloud KMS teardown scheduled. Keys will be destroyed after 24 hours."
        """
    }

    /// Grant encrypter role
    public static func grantEncrypterCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        serviceAccountEmail: String
    ) -> String {
        "gcloud kms keys add-iam-policy-binding \(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --member=\"serviceAccount:\(serviceAccountEmail)\" --role=\"roles/cloudkms.cryptoKeyEncrypter\""
    }

    /// Grant decrypter role
    public static func grantDecrypterCommand(
        keyName: String,
        keyRing: String,
        location: String,
        projectID: String,
        serviceAccountEmail: String
    ) -> String {
        "gcloud kms keys add-iam-policy-binding \(keyName) --keyring=\(keyRing) --location=\(location) --project=\(projectID) --member=\"serviceAccount:\(serviceAccountEmail)\" --role=\"roles/cloudkms.cryptoKeyDecrypter\""
    }
}
