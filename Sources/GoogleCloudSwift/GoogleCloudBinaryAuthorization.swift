// GoogleCloudBinaryAuthorization.swift
// Binary Authorization - Container image security policy enforcement
// Service #53

import Foundation

// MARK: - Binary Authorization Policy

/// A Binary Authorization policy that controls which container images can be deployed
public struct GoogleCloudBinaryAuthorizationPolicy: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let globalPolicyEvaluationMode: GlobalPolicyEvaluationMode?
    public let admissionWhitelistPatterns: [AdmissionWhitelistPattern]?
    public let defaultAdmissionRule: AdmissionRule
    public let clusterAdmissionRules: [String: AdmissionRule]?
    public let kubernetesNamespaceAdmissionRules: [String: AdmissionRule]?
    public let kubernetesServiceAccountAdmissionRules: [String: AdmissionRule]?
    public let istioServiceIdentityAdmissionRules: [String: AdmissionRule]?
    public let updateTime: String?

    public init(
        name: String? = nil,
        projectID: String,
        description: String? = nil,
        globalPolicyEvaluationMode: GlobalPolicyEvaluationMode? = nil,
        admissionWhitelistPatterns: [AdmissionWhitelistPattern]? = nil,
        defaultAdmissionRule: AdmissionRule,
        clusterAdmissionRules: [String: AdmissionRule]? = nil,
        kubernetesNamespaceAdmissionRules: [String: AdmissionRule]? = nil,
        kubernetesServiceAccountAdmissionRules: [String: AdmissionRule]? = nil,
        istioServiceIdentityAdmissionRules: [String: AdmissionRule]? = nil,
        updateTime: String? = nil
    ) {
        self.name = name ?? "projects/\(projectID)/policy"
        self.projectID = projectID
        self.description = description
        self.globalPolicyEvaluationMode = globalPolicyEvaluationMode
        self.admissionWhitelistPatterns = admissionWhitelistPatterns
        self.defaultAdmissionRule = defaultAdmissionRule
        self.clusterAdmissionRules = clusterAdmissionRules
        self.kubernetesNamespaceAdmissionRules = kubernetesNamespaceAdmissionRules
        self.kubernetesServiceAccountAdmissionRules = kubernetesServiceAccountAdmissionRules
        self.istioServiceIdentityAdmissionRules = istioServiceIdentityAdmissionRules
        self.updateTime = updateTime
    }

    /// Global policy evaluation mode
    public enum GlobalPolicyEvaluationMode: String, Codable, Sendable {
        case globalPolicyEvaluationModeUnspecified = "GLOBAL_POLICY_EVALUATION_MODE_UNSPECIFIED"
        case enable = "ENABLE"
        case disable = "DISABLE"
    }

    /// Pattern for whitelisting images by name
    public struct AdmissionWhitelistPattern: Codable, Sendable, Equatable {
        public let namePattern: String

        public init(namePattern: String) {
            self.namePattern = namePattern
        }

        /// Create a pattern for GCR images
        public static func gcr(project: String) -> AdmissionWhitelistPattern {
            AdmissionWhitelistPattern(namePattern: "gcr.io/\(project)/*")
        }

        /// Create a pattern for Artifact Registry images
        public static func artifactRegistry(project: String, location: String, repository: String) -> AdmissionWhitelistPattern {
            AdmissionWhitelistPattern(namePattern: "\(location)-docker.pkg.dev/\(project)/\(repository)/*")
        }

        /// Create a pattern for all Artifact Registry images in a project
        public static func allArtifactRegistry(project: String) -> AdmissionWhitelistPattern {
            AdmissionWhitelistPattern(namePattern: "*-docker.pkg.dev/\(project)/*")
        }
    }

    /// Get policy command
    public var getPolicyCommand: String {
        "gcloud container binauthz policy export --project=\(projectID)"
    }

    /// Update policy command
    public var updatePolicyCommand: String {
        "gcloud container binauthz policy import policy.yaml --project=\(projectID)"
    }

    /// Generate YAML representation
    public func toYAML() -> String {
        var yaml = """
        name: \(name)
        """

        if let desc = description {
            yaml += "\ndescription: \"\(desc)\""
        }

        if let mode = globalPolicyEvaluationMode {
            yaml += "\nglobalPolicyEvaluationMode: \(mode.rawValue)"
        }

        if let patterns = admissionWhitelistPatterns, !patterns.isEmpty {
            yaml += "\nadmissionWhitelistPatterns:"
            for pattern in patterns {
                yaml += "\n  - namePattern: \(pattern.namePattern)"
            }
        }

        yaml += "\ndefaultAdmissionRule:"
        yaml += defaultAdmissionRule.toYAMLIndented(indent: "  ")

        if let clusterRules = clusterAdmissionRules, !clusterRules.isEmpty {
            yaml += "\nclusterAdmissionRules:"
            for (cluster, rule) in clusterRules.sorted(by: { $0.key < $1.key }) {
                yaml += "\n  \(cluster):"
                yaml += rule.toYAMLIndented(indent: "    ")
            }
        }

        if let namespaceRules = kubernetesNamespaceAdmissionRules, !namespaceRules.isEmpty {
            yaml += "\nkubernetesNamespaceAdmissionRules:"
            for (namespace, rule) in namespaceRules.sorted(by: { $0.key < $1.key }) {
                yaml += "\n  \(namespace):"
                yaml += rule.toYAMLIndented(indent: "    ")
            }
        }

        return yaml
    }
}

// MARK: - Admission Rule

/// Rule for allowing or denying container images
public struct AdmissionRule: Codable, Sendable, Equatable {
    public let evaluationMode: EvaluationMode
    public let requireAttestationsBy: [String]?
    public let enforcementMode: EnforcementMode

    public init(
        evaluationMode: EvaluationMode,
        requireAttestationsBy: [String]? = nil,
        enforcementMode: EnforcementMode = .enforcedBlockAndAuditLog
    ) {
        self.evaluationMode = evaluationMode
        self.requireAttestationsBy = requireAttestationsBy
        self.enforcementMode = enforcementMode
    }

    /// Evaluation mode for admission
    public enum EvaluationMode: String, Codable, Sendable {
        case evaluationModeUnspecified = "EVALUATION_MODE_UNSPECIFIED"
        case alwaysAllow = "ALWAYS_ALLOW"
        case alwaysDeny = "ALWAYS_DENY"
        case requireAttestation = "REQUIRE_ATTESTATION"
    }

    /// Enforcement mode for the rule
    public enum EnforcementMode: String, Codable, Sendable {
        case enforcementModeUnspecified = "ENFORCEMENT_MODE_UNSPECIFIED"
        case enforcedBlockAndAuditLog = "ENFORCED_BLOCK_AND_AUDIT_LOG"
        case dryrunAuditLogOnly = "DRYRUN_AUDIT_LOG_ONLY"
    }

    /// Create a rule that always allows
    public static var allowAll: AdmissionRule {
        AdmissionRule(
            evaluationMode: .alwaysAllow,
            enforcementMode: .enforcedBlockAndAuditLog
        )
    }

    /// Create a rule that always denies
    public static var denyAll: AdmissionRule {
        AdmissionRule(
            evaluationMode: .alwaysDeny,
            enforcementMode: .enforcedBlockAndAuditLog
        )
    }

    /// Create a rule that requires attestation
    public static func requireAttestation(attestors: [String]) -> AdmissionRule {
        AdmissionRule(
            evaluationMode: .requireAttestation,
            requireAttestationsBy: attestors,
            enforcementMode: .enforcedBlockAndAuditLog
        )
    }

    /// Generate YAML indented
    func toYAMLIndented(indent: String) -> String {
        var yaml = "\n\(indent)evaluationMode: \(evaluationMode.rawValue)"
        if let attestors = requireAttestationsBy, !attestors.isEmpty {
            yaml += "\n\(indent)requireAttestationsBy:"
            for attestor in attestors {
                yaml += "\n\(indent)  - \(attestor)"
            }
        }
        yaml += "\n\(indent)enforcementMode: \(enforcementMode.rawValue)"
        return yaml
    }
}

// MARK: - Attestor

/// An attestor that verifies container images
public struct GoogleCloudAttestor: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let userOwnedGrafeasNote: UserOwnedGrafeasNote?
    public let updateTime: String?

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        userOwnedGrafeasNote: UserOwnedGrafeasNote? = nil,
        updateTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.userOwnedGrafeasNote = userOwnedGrafeasNote
        self.updateTime = updateTime
    }

    /// Resource name for the attestor
    public var resourceName: String {
        "projects/\(projectID)/attestors/\(name)"
    }

    /// User-owned Grafeas note
    public struct UserOwnedGrafeasNote: Codable, Sendable, Equatable {
        public let noteReference: String
        public let publicKeys: [PublicKey]?
        public let delegationServiceAccountEmail: String?

        public init(
            noteReference: String,
            publicKeys: [PublicKey]? = nil,
            delegationServiceAccountEmail: String? = nil
        ) {
            self.noteReference = noteReference
            self.publicKeys = publicKeys
            self.delegationServiceAccountEmail = delegationServiceAccountEmail
        }
    }

    /// Public key for attestor
    public struct PublicKey: Codable, Sendable, Equatable {
        public let id: String?
        public let comment: String?
        public let asciiArmoredPgpPublicKey: String?
        public let pkixPublicKey: PkixPublicKey?

        public init(
            id: String? = nil,
            comment: String? = nil,
            asciiArmoredPgpPublicKey: String? = nil,
            pkixPublicKey: PkixPublicKey? = nil
        ) {
            self.id = id
            self.comment = comment
            self.asciiArmoredPgpPublicKey = asciiArmoredPgpPublicKey
            self.pkixPublicKey = pkixPublicKey
        }
    }

    /// PKIX public key
    public struct PkixPublicKey: Codable, Sendable, Equatable {
        public let publicKeyPem: String
        public let signatureAlgorithm: SignatureAlgorithm

        public init(
            publicKeyPem: String,
            signatureAlgorithm: SignatureAlgorithm
        ) {
            self.publicKeyPem = publicKeyPem
            self.signatureAlgorithm = signatureAlgorithm
        }

        public enum SignatureAlgorithm: String, Codable, Sendable {
            case signatureAlgorithmUnspecified = "SIGNATURE_ALGORITHM_UNSPECIFIED"
            case rsaPss2048Sha256 = "RSA_PSS_2048_SHA256"
            case rsaPss3072Sha256 = "RSA_PSS_3072_SHA256"
            case rsaPss4096Sha256 = "RSA_PSS_4096_SHA256"
            case rsaPss4096Sha512 = "RSA_PSS_4096_SHA512"
            case rsaSignPkcs12048Sha256 = "RSA_SIGN_PKCS1_2048_SHA256"
            case rsaSignPkcs13072Sha256 = "RSA_SIGN_PKCS1_3072_SHA256"
            case rsaSignPkcs14096Sha256 = "RSA_SIGN_PKCS1_4096_SHA256"
            case rsaSignPkcs14096Sha512 = "RSA_SIGN_PKCS1_4096_SHA512"
            case ecdsaP256Sha256 = "ECDSA_P256_SHA256"
            case ecdsaP384Sha384 = "ECDSA_P384_SHA384"
            case ecdsaP521Sha512 = "ECDSA_P521_SHA512"
        }
    }

    /// Create attestor command
    public var createCommand: String {
        var cmd = "gcloud container binauthz attestors create \(name) --project=\(projectID)"
        if let note = userOwnedGrafeasNote {
            cmd += " --attestation-authority-note=\(note.noteReference)"
        }
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        return cmd
    }

    /// Delete attestor command
    public var deleteCommand: String {
        "gcloud container binauthz attestors delete \(name) --project=\(projectID)"
    }

    /// Describe attestor command
    public var describeCommand: String {
        "gcloud container binauthz attestors describe \(name) --project=\(projectID)"
    }

    /// Add public key command
    public func addPublicKeyCommand(keyPath: String) -> String {
        "gcloud container binauthz attestors public-keys add --attestor=\(name) --project=\(projectID) --public-key-file=\(keyPath)"
    }

    /// Add KMS key command
    public func addKMSKeyCommand(kmsKeyVersionResourceID: String) -> String {
        "gcloud container binauthz attestors public-keys add --attestor=\(name) --project=\(projectID) --keyversion=\(kmsKeyVersionResourceID)"
    }

    /// List public keys command
    public var listPublicKeysCommand: String {
        "gcloud container binauthz attestors public-keys list --attestor=\(name) --project=\(projectID)"
    }

    /// Remove public key command
    public func removePublicKeyCommand(keyID: String) -> String {
        "gcloud container binauthz attestors public-keys remove \(keyID) --attestor=\(name) --project=\(projectID)"
    }
}

// MARK: - Attestation

/// An attestation for a container image
public struct GoogleCloudAttestation: Codable, Sendable, Equatable {
    public let resourceUri: String
    public let attestorName: String
    public let projectID: String
    public let signature: String?
    public let publicKeyID: String?
    public let payloadType: String?
    public let serializedPayload: String?

    public init(
        resourceUri: String,
        attestorName: String,
        projectID: String,
        signature: String? = nil,
        publicKeyID: String? = nil,
        payloadType: String? = nil,
        serializedPayload: String? = nil
    ) {
        self.resourceUri = resourceUri
        self.attestorName = attestorName
        self.projectID = projectID
        self.signature = signature
        self.publicKeyID = publicKeyID
        self.payloadType = payloadType
        self.serializedPayload = serializedPayload
    }

    /// Create attestation with PGP key
    public func createPGPCommand(signatureFile: String) -> String {
        "gcloud container binauthz attestations create --artifact-url=\(resourceUri) --attestor=\(attestorName) --project=\(projectID) --signature-file=\(signatureFile)"
    }

    /// Create attestation with KMS key
    public func createKMSCommand(kmsKeyVersion: String) -> String {
        "gcloud container binauthz attestations create --artifact-url=\(resourceUri) --attestor=\(attestorName) --project=\(projectID) --keyversion=\(kmsKeyVersion)"
    }

    /// List attestations command
    public var listCommand: String {
        "gcloud container binauthz attestations list --attestor=\(attestorName) --project=\(projectID)"
    }

    /// Verify attestation command
    public var verifyCommand: String {
        "gcloud container binauthz attestations verify --artifact-url=\(resourceUri) --attestor=\(attestorName) --project=\(projectID)"
    }

    /// Sign and create attestation command script
    public func signAndCreateScript(kmsKeyVersion: String) -> String {
        """
        #!/bin/bash
        # Sign and create attestation for \(resourceUri)

        IMAGE_URI="\(resourceUri)"
        ATTESTOR="\(attestorName)"
        PROJECT="\(projectID)"
        KEY_VERSION="\(kmsKeyVersion)"

        # Create attestation
        gcloud container binauthz attestations create \\
            --artifact-url="$IMAGE_URI" \\
            --attestor="$ATTESTOR" \\
            --project="$PROJECT" \\
            --keyversion="$KEY_VERSION"

        echo "Attestation created for $IMAGE_URI"

        # Verify attestation
        gcloud container binauthz attestations verify \\
            --artifact-url="$IMAGE_URI" \\
            --attestor="$ATTESTOR" \\
            --project="$PROJECT"
        """
    }
}

// MARK: - Container Analysis Note

/// A Container Analysis note for Binary Authorization
public struct ContainerAnalysisNote: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let noteID: String
    public let shortDescription: String?
    public let longDescription: String?
    public let kind: NoteKind
    public let relatedUrl: [RelatedUrl]?
    public let expirationTime: String?
    public let attestationAuthority: AttestationAuthority?

    public init(
        name: String? = nil,
        projectID: String,
        noteID: String,
        shortDescription: String? = nil,
        longDescription: String? = nil,
        kind: NoteKind = .attestation,
        relatedUrl: [RelatedUrl]? = nil,
        expirationTime: String? = nil,
        attestationAuthority: AttestationAuthority? = nil
    ) {
        self.name = name ?? "projects/\(projectID)/notes/\(noteID)"
        self.projectID = projectID
        self.noteID = noteID
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.kind = kind
        self.relatedUrl = relatedUrl
        self.expirationTime = expirationTime
        self.attestationAuthority = attestationAuthority
    }

    /// Note kind
    public enum NoteKind: String, Codable, Sendable {
        case noteKindUnspecified = "NOTE_KIND_UNSPECIFIED"
        case vulnerability = "VULNERABILITY"
        case build = "BUILD"
        case image = "IMAGE"
        case package = "PACKAGE"
        case deployment = "DEPLOYMENT"
        case discovery = "DISCOVERY"
        case attestation = "ATTESTATION"
        case upgrade = "UPGRADE"
        case compliance = "COMPLIANCE"
        case dsseAttestation = "DSSE_ATTESTATION"
        case vulnerabilityAssessment = "VULNERABILITY_ASSESSMENT"
        case sbomReference = "SBOM_REFERENCE"
    }

    /// Related URL
    public struct RelatedUrl: Codable, Sendable, Equatable {
        public let url: String
        public let label: String?

        public init(url: String, label: String? = nil) {
            self.url = url
            self.label = label
        }
    }

    /// Attestation authority hint
    public struct AttestationAuthority: Codable, Sendable, Equatable {
        public let hint: Hint

        public init(hint: Hint) {
            self.hint = hint
        }

        public struct Hint: Codable, Sendable, Equatable {
            public let humanReadableName: String

            public init(humanReadableName: String) {
                self.humanReadableName = humanReadableName
            }
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/notes/\(noteID)"
    }

    /// Create note command
    public var createCommand: String {
        "gcloud artifacts notes create \(noteID) --project=\(projectID)"
    }

    /// Delete note command
    public var deleteCommand: String {
        "gcloud artifacts notes delete \(noteID) --project=\(projectID)"
    }

    /// Describe note command
    public var describeCommand: String {
        "gcloud artifacts notes describe \(noteID) --project=\(projectID)"
    }
}

// MARK: - Binary Authorization Operations

/// Operations for Binary Authorization
public struct BinaryAuthorizationOperations: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Enable Binary Authorization API
    public var enableAPICommand: String {
        "gcloud services enable binaryauthorization.googleapis.com --project=\(projectID)"
    }

    /// Enable Container Analysis API
    public var enableContainerAnalysisAPICommand: String {
        "gcloud services enable containeranalysis.googleapis.com --project=\(projectID)"
    }

    /// Get policy command
    public var getPolicyCommand: String {
        "gcloud container binauthz policy export --project=\(projectID)"
    }

    /// Import policy command
    public func importPolicyCommand(policyFile: String) -> String {
        "gcloud container binauthz policy import \(policyFile) --project=\(projectID)"
    }

    /// List attestors command
    public var listAttestorsCommand: String {
        "gcloud container binauthz attestors list --project=\(projectID)"
    }

    /// Create attestor command
    public func createAttestorCommand(name: String, noteReference: String, description: String? = nil) -> String {
        var cmd = "gcloud container binauthz attestors create \(name) --project=\(projectID) --attestation-authority-note=\(noteReference)"
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        return cmd
    }

    /// Delete attestor command
    public func deleteAttestorCommand(name: String) -> String {
        "gcloud container binauthz attestors delete \(name) --project=\(projectID)"
    }

    /// Describe attestor command
    public func describeAttestorCommand(name: String) -> String {
        "gcloud container binauthz attestors describe \(name) --project=\(projectID)"
    }

    /// Create attestation command
    public func createAttestationCommand(imageUri: String, attestor: String, kmsKeyVersion: String) -> String {
        "gcloud container binauthz attestations create --artifact-url=\(imageUri) --attestor=\(attestor) --project=\(projectID) --keyversion=\(kmsKeyVersion)"
    }

    /// List attestations command
    public func listAttestationsCommand(attestor: String) -> String {
        "gcloud container binauthz attestations list --attestor=\(attestor) --project=\(projectID)"
    }

    /// Verify attestation command
    public func verifyAttestationCommand(imageUri: String, attestor: String) -> String {
        "gcloud container binauthz attestations verify --artifact-url=\(imageUri) --attestor=\(attestor) --project=\(projectID)"
    }

    /// Add IAM binding for attestor
    public func addAttestorIAMBindingCommand(attestor: String, member: String, role: BinaryAuthorizationRole) -> String {
        "gcloud container binauthz attestors add-iam-policy-binding \(attestor) --project=\(projectID) --member=\(member) --role=\(role.rawValue)"
    }

    /// IAM roles for Binary Authorization
    public enum BinaryAuthorizationRole: String, Sendable {
        case attestorViewer = "roles/binaryauthorization.attestorsViewer"
        case attestorEditor = "roles/binaryauthorization.attestorsEditor"
        case attestorAdmin = "roles/binaryauthorization.attestorsAdmin"
        case policyViewer = "roles/binaryauthorization.policyViewer"
        case policyEditor = "roles/binaryauthorization.policyEditor"
        case attestationViewer = "roles/binaryauthorization.attestationsViewer"
        case attestationCreator = "roles/binaryauthorization.attestationsCreator"
    }

    /// Generate key pair for attestation
    public func generateKeyPairScript(keyName: String) -> String {
        """
        #!/bin/bash
        # Generate key pair for Binary Authorization attestation

        KEY_NAME="\(keyName)"

        # Generate private key
        openssl ecparam -genkey -name prime256v1 -noout -out "${KEY_NAME}.pem"

        # Extract public key
        openssl ec -in "${KEY_NAME}.pem" -pubout -out "${KEY_NAME}.pub"

        echo "Generated key pair:"
        echo "  Private key: ${KEY_NAME}.pem"
        echo "  Public key: ${KEY_NAME}.pub"

        # Display public key for adding to attestor
        echo ""
        echo "Public key content:"
        cat "${KEY_NAME}.pub"
        """
    }

    /// Create KMS key for attestation
    public func createKMSKeyScript(keyRing: String, keyName: String, location: String = "global") -> String {
        """
        #!/bin/bash
        # Create KMS key for Binary Authorization attestation

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        KEY_RING="\(keyRing)"
        KEY_NAME="\(keyName)"

        # Create key ring (if not exists)
        gcloud kms keyrings create $KEY_RING \\
            --location=$LOCATION \\
            --project=$PROJECT || true

        # Create asymmetric signing key
        gcloud kms keys create $KEY_NAME \\
            --keyring=$KEY_RING \\
            --location=$LOCATION \\
            --purpose=asymmetric-signing \\
            --default-algorithm=ec-sign-p256-sha256 \\
            --project=$PROJECT

        # Get key version resource name
        KEY_VERSION=$(gcloud kms keys versions list \\
            --key=$KEY_NAME \\
            --keyring=$KEY_RING \\
            --location=$LOCATION \\
            --project=$PROJECT \\
            --format='value(name)' \\
            --filter='state=ENABLED' \\
            | head -1)

        echo "KMS key version created: $KEY_VERSION"
        """
    }
}

// MARK: - DAIS Binary Authorization Template

/// DAIS template for Binary Authorization configurations
public struct DAISBinaryAuthorizationTemplate: Sendable {
    public let projectID: String
    public let defaultAttestorLocation: String

    public init(
        projectID: String,
        defaultAttestorLocation: String = "global"
    ) {
        self.projectID = projectID
        self.defaultAttestorLocation = defaultAttestorLocation
    }

    /// Create a policy that requires attestation for all images
    public func attestationRequiredPolicy(attestorNames: [String]) -> GoogleCloudBinaryAuthorizationPolicy {
        let attestorRefs = attestorNames.map { "projects/\(projectID)/attestors/\($0)" }
        return GoogleCloudBinaryAuthorizationPolicy(
            projectID: projectID,
            description: "Require attestation for all container images",
            globalPolicyEvaluationMode: .enable,
            defaultAdmissionRule: .requireAttestation(attestors: attestorRefs)
        )
    }

    /// Create a policy that allows all images (development)
    public var allowAllPolicy: GoogleCloudBinaryAuthorizationPolicy {
        GoogleCloudBinaryAuthorizationPolicy(
            projectID: projectID,
            description: "Allow all container images (development only)",
            globalPolicyEvaluationMode: .enable,
            defaultAdmissionRule: .allowAll
        )
    }

    /// Create a policy that denies all images by default
    public var denyAllPolicy: GoogleCloudBinaryAuthorizationPolicy {
        GoogleCloudBinaryAuthorizationPolicy(
            projectID: projectID,
            description: "Deny all container images by default",
            globalPolicyEvaluationMode: .enable,
            defaultAdmissionRule: .denyAll
        )
    }

    /// Create a policy with cluster-specific rules
    public func clusterSpecificPolicy(
        defaultRule: AdmissionRule,
        clusterRules: [String: AdmissionRule]
    ) -> GoogleCloudBinaryAuthorizationPolicy {
        GoogleCloudBinaryAuthorizationPolicy(
            projectID: projectID,
            description: "Cluster-specific Binary Authorization policy",
            globalPolicyEvaluationMode: .enable,
            defaultAdmissionRule: defaultRule,
            clusterAdmissionRules: clusterRules
        )
    }

    /// Create a policy with namespace-specific rules
    public func namespaceSpecificPolicy(
        defaultRule: AdmissionRule,
        namespaceRules: [String: AdmissionRule]
    ) -> GoogleCloudBinaryAuthorizationPolicy {
        GoogleCloudBinaryAuthorizationPolicy(
            projectID: projectID,
            description: "Namespace-specific Binary Authorization policy",
            globalPolicyEvaluationMode: .enable,
            defaultAdmissionRule: defaultRule,
            kubernetesNamespaceAdmissionRules: namespaceRules
        )
    }

    /// Create an attestor with KMS key
    public func kmsAttestor(
        name: String,
        kmsKeyVersion: String,
        description: String? = nil
    ) -> GoogleCloudAttestor {
        GoogleCloudAttestor(
            name: name,
            projectID: projectID,
            description: description,
            userOwnedGrafeasNote: .init(
                noteReference: "projects/\(projectID)/notes/\(name)-note",
                publicKeys: [
                    .init(pkixPublicKey: nil)
                ]
            )
        )
    }

    /// Create an attestor
    public func attestor(
        name: String,
        description: String? = nil
    ) -> GoogleCloudAttestor {
        GoogleCloudAttestor(
            name: name,
            projectID: projectID,
            description: description,
            userOwnedGrafeasNote: .init(
                noteReference: "projects/\(projectID)/notes/\(name)-note"
            )
        )
    }

    /// Create a Container Analysis note for attestation
    public func attestationNote(
        noteID: String,
        description: String
    ) -> ContainerAnalysisNote {
        ContainerAnalysisNote(
            projectID: projectID,
            noteID: noteID,
            shortDescription: description,
            kind: .attestation,
            attestationAuthority: .init(
                hint: .init(humanReadableName: description)
            )
        )
    }

    /// Create attestation for an image
    public func attestation(
        imageUri: String,
        attestorName: String
    ) -> GoogleCloudAttestation {
        GoogleCloudAttestation(
            resourceUri: imageUri,
            attestorName: attestorName,
            projectID: projectID
        )
    }

    /// Operations helper
    public var operations: BinaryAuthorizationOperations {
        BinaryAuthorizationOperations(projectID: projectID)
    }

    /// Generate setup script for Binary Authorization
    public var setupScript: String {
        """
        #!/bin/bash
        # Binary Authorization Setup Script
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"

        echo "=== Enabling APIs ==="
        gcloud services enable binaryauthorization.googleapis.com --project=$PROJECT
        gcloud services enable containeranalysis.googleapis.com --project=$PROJECT
        gcloud services enable container.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Creating KMS Key Ring and Key ==="
        gcloud kms keyrings create binauthz-keys --location=global --project=$PROJECT || true
        gcloud kms keys create attestor-key \\
            --keyring=binauthz-keys \\
            --location=global \\
            --purpose=asymmetric-signing \\
            --default-algorithm=ec-sign-p256-sha256 \\
            --project=$PROJECT || true

        KEY_VERSION=$(gcloud kms keys versions list \\
            --key=attestor-key \\
            --keyring=binauthz-keys \\
            --location=global \\
            --project=$PROJECT \\
            --format='value(name)' \\
            --filter='state=ENABLED' \\
            | head -1)

        echo "KMS Key Version: $KEY_VERSION"

        echo ""
        echo "=== Creating Attestation Note ==="
        cat > note.json << 'EOF'
        {
          "attestation": {
            "hint": {
              "humanReadableName": "Production Attestor"
            }
          }
        }
        EOF

        curl -X POST \\
            -H "Content-Type: application/json" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            --data-binary @note.json \\
            "https://containeranalysis.googleapis.com/v1/projects/$PROJECT/notes?noteId=production-attestor-note" || true

        echo ""
        echo "=== Creating Attestor ==="
        gcloud container binauthz attestors create production-attestor \\
            --project=$PROJECT \\
            --attestation-authority-note=projects/$PROJECT/notes/production-attestor-note \\
            --attestation-authority-note-project=$PROJECT \\
            --description="Production deployment attestor" || true

        echo ""
        echo "=== Adding KMS Key to Attestor ==="
        gcloud container binauthz attestors public-keys add \\
            --attestor=production-attestor \\
            --project=$PROJECT \\
            --keyversion=$KEY_VERSION || true

        echo ""
        echo "=== Setup Complete ==="
        echo "Attestor: production-attestor"
        echo "KMS Key: $KEY_VERSION"
        echo ""
        echo "To create an attestation for an image:"
        echo "gcloud container binauthz attestations create \\\\"
        echo "    --artifact-url=<IMAGE_URI> \\\\"
        echo "    --attestor=production-attestor \\\\"
        echo "    --project=$PROJECT \\\\"
        echo "    --keyversion=$KEY_VERSION"
        """
    }

    /// Generate CI/CD integration script
    public var cicdIntegrationScript: String {
        """
        #!/bin/bash
        # Binary Authorization CI/CD Integration Script
        # Add to your CI/CD pipeline after image build

        set -e

        PROJECT="\(projectID)"
        ATTESTOR="production-attestor"

        # Get KMS key version
        KEY_VERSION=$(gcloud kms keys versions list \\
            --key=attestor-key \\
            --keyring=binauthz-keys \\
            --location=global \\
            --project=$PROJECT \\
            --format='value(name)' \\
            --filter='state=ENABLED' \\
            | head -1)

        # Image URI should be passed as argument
        IMAGE_URI="${1:?Image URI required}"

        echo "Creating attestation for: $IMAGE_URI"

        # Create attestation
        gcloud container binauthz attestations create \\
            --artifact-url="$IMAGE_URI" \\
            --attestor="$ATTESTOR" \\
            --project="$PROJECT" \\
            --keyversion="$KEY_VERSION"

        echo "Attestation created successfully"

        # Verify attestation
        echo "Verifying attestation..."
        gcloud container binauthz attestations verify \\
            --artifact-url="$IMAGE_URI" \\
            --attestor="$ATTESTOR" \\
            --project="$PROJECT"

        echo "Attestation verified successfully"
        """
    }

    /// Generate policy YAML for requiring attestation
    public func requireAttestationPolicyYAML(attestorName: String) -> String {
        """
        # Binary Authorization Policy
        # Requires attestation for all container deployments

        name: projects/\(projectID)/policy
        globalPolicyEvaluationMode: ENABLE
        defaultAdmissionRule:
          evaluationMode: REQUIRE_ATTESTATION
          requireAttestationsBy:
            - projects/\(projectID)/attestors/\(attestorName)
          enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
        """
    }

    /// Generate policy YAML for dry-run mode
    public func dryRunPolicyYAML(attestorName: String) -> String {
        """
        # Binary Authorization Policy (Dry Run)
        # Logs policy violations but does not block deployments

        name: projects/\(projectID)/policy
        globalPolicyEvaluationMode: ENABLE
        defaultAdmissionRule:
          evaluationMode: REQUIRE_ATTESTATION
          requireAttestationsBy:
            - projects/\(projectID)/attestors/\(attestorName)
          enforcementMode: DRYRUN_AUDIT_LOG_ONLY
        """
    }
}

// MARK: - Continuous Validation

/// Continuous validation configuration for Binary Authorization
public struct ContinuousValidation: Codable, Sendable, Equatable {
    public let enabled: Bool
    public let enabledPod: CVPodPolicy?

    public init(
        enabled: Bool = true,
        enabledPod: CVPodPolicy? = nil
    ) {
        self.enabled = enabled
        self.enabledPod = enabledPod
    }

    /// Pod policy for continuous validation
    public struct CVPodPolicy: Codable, Sendable, Equatable {
        public let checkSets: [String]?
        public let images: [ImagePattern]?

        public init(
            checkSets: [String]? = nil,
            images: [ImagePattern]? = nil
        ) {
            self.checkSets = checkSets
            self.images = images
        }

        public struct ImagePattern: Codable, Sendable, Equatable {
            public let glob: String
            public let checkSets: [String]?
            public let allowUnmonitoredImageSources: Bool?

            public init(
                glob: String,
                checkSets: [String]? = nil,
                allowUnmonitoredImageSources: Bool? = nil
            ) {
                self.glob = glob
                self.checkSets = checkSets
                self.allowUnmonitoredImageSources = allowUnmonitoredImageSources
            }
        }
    }
}

// MARK: - Check Set

/// A check set for Binary Authorization CV
public struct CVCheckSet: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let scope: Scope
    public let checks: [Check]?

    public init(
        name: String,
        projectID: String,
        scope: Scope,
        checks: [Check]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.scope = scope
        self.checks = checks
    }

    /// Scope for the check set
    public enum Scope: Codable, Sendable, Equatable {
        case kubernetesNamespace(String)
        case kubernetesServiceAccount(String)

        private enum CodingKeys: String, CodingKey {
            case kubernetesNamespace
            case kubernetesServiceAccount
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let namespace = try container.decodeIfPresent(String.self, forKey: .kubernetesNamespace) {
                self = .kubernetesNamespace(namespace)
            } else if let serviceAccount = try container.decodeIfPresent(String.self, forKey: .kubernetesServiceAccount) {
                self = .kubernetesServiceAccount(serviceAccount)
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown scope"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .kubernetesNamespace(let namespace):
                try container.encode(namespace, forKey: .kubernetesNamespace)
            case .kubernetesServiceAccount(let serviceAccount):
                try container.encode(serviceAccount, forKey: .kubernetesServiceAccount)
            }
        }
    }

    /// Check for the check set
    public struct Check: Codable, Sendable, Equatable {
        public let alwaysDeny: Bool?
        public let simpleSigningAttestationCheck: SimpleSigningAttestationCheck?
        public let trustedDirectoryCheck: TrustedDirectoryCheck?
        public let vulnerabilityCheck: VulnerabilityCheck?
        public let slsaCheck: SLSACheck?

        public init(
            alwaysDeny: Bool? = nil,
            simpleSigningAttestationCheck: SimpleSigningAttestationCheck? = nil,
            trustedDirectoryCheck: TrustedDirectoryCheck? = nil,
            vulnerabilityCheck: VulnerabilityCheck? = nil,
            slsaCheck: SLSACheck? = nil
        ) {
            self.alwaysDeny = alwaysDeny
            self.simpleSigningAttestationCheck = simpleSigningAttestationCheck
            self.trustedDirectoryCheck = trustedDirectoryCheck
            self.vulnerabilityCheck = vulnerabilityCheck
            self.slsaCheck = slsaCheck
        }

        public struct SimpleSigningAttestationCheck: Codable, Sendable, Equatable {
            public let attestationAuthenticators: [AttestationAuthenticator]?
            public let containerAnalysisAttestationProjects: [String]?

            public init(
                attestationAuthenticators: [AttestationAuthenticator]? = nil,
                containerAnalysisAttestationProjects: [String]? = nil
            ) {
                self.attestationAuthenticators = attestationAuthenticators
                self.containerAnalysisAttestationProjects = containerAnalysisAttestationProjects
            }
        }

        public struct AttestationAuthenticator: Codable, Sendable, Equatable {
            public let displayName: String?
            public let pkixPublicKeySet: PkixPublicKeySet?

            public init(displayName: String? = nil, pkixPublicKeySet: PkixPublicKeySet? = nil) {
                self.displayName = displayName
                self.pkixPublicKeySet = pkixPublicKeySet
            }

            public struct PkixPublicKeySet: Codable, Sendable, Equatable {
                public let pkixPublicKeys: [GoogleCloudAttestor.PkixPublicKey]?

                public init(pkixPublicKeys: [GoogleCloudAttestor.PkixPublicKey]? = nil) {
                    self.pkixPublicKeys = pkixPublicKeys
                }
            }
        }

        public struct TrustedDirectoryCheck: Codable, Sendable, Equatable {
            public let trustedDirPatterns: [String]

            public init(trustedDirPatterns: [String]) {
                self.trustedDirPatterns = trustedDirPatterns
            }
        }

        public struct VulnerabilityCheck: Codable, Sendable, Equatable {
            public let maximumFixableSeverity: Severity?
            public let maximumUnfixableSeverity: Severity?
            public let allowedCves: [String]?
            public let blockedCves: [String]?

            public init(
                maximumFixableSeverity: Severity? = nil,
                maximumUnfixableSeverity: Severity? = nil,
                allowedCves: [String]? = nil,
                blockedCves: [String]? = nil
            ) {
                self.maximumFixableSeverity = maximumFixableSeverity
                self.maximumUnfixableSeverity = maximumUnfixableSeverity
                self.allowedCves = allowedCves
                self.blockedCves = blockedCves
            }

            public enum Severity: String, Codable, Sendable {
                case severityUnspecified = "SEVERITY_UNSPECIFIED"
                case minimal = "MINIMAL"
                case low = "LOW"
                case medium = "MEDIUM"
                case high = "HIGH"
                case critical = "CRITICAL"
            }
        }

        public struct SLSACheck: Codable, Sendable, Equatable {
            public let rules: [Rule]?

            public init(rules: [Rule]? = nil) {
                self.rules = rules
            }

            public struct Rule: Codable, Sendable, Equatable {
                public let trustedBuilder: String?
                public let attestationSource: AttestationSource?

                public init(trustedBuilder: String? = nil, attestationSource: AttestationSource? = nil) {
                    self.trustedBuilder = trustedBuilder
                    self.attestationSource = attestationSource
                }

                public struct AttestationSource: Codable, Sendable, Equatable {
                    public let containerAnalysisAttestationProjects: [String]?

                    public init(containerAnalysisAttestationProjects: [String]? = nil) {
                        self.containerAnalysisAttestationProjects = containerAnalysisAttestationProjects
                    }
                }
            }
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/checkSets/\(name)"
    }
}
