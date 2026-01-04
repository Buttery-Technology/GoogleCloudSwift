// GoogleCloudCertificateAuthority.swift
// Certificate Authority Service - Private CA management
// Service #54

import Foundation

// MARK: - Certificate Authority Pool

/// A pool of Certificate Authorities
public struct GoogleCloudCaPool: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let tier: Tier
    public let issuancePolicy: IssuancePolicy?
    public let publishingOptions: PublishingOptions?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        location: String,
        tier: Tier = .devops,
        issuancePolicy: IssuancePolicy? = nil,
        publishingOptions: PublishingOptions? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.tier = tier
        self.issuancePolicy = issuancePolicy
        self.publishingOptions = publishingOptions
        self.labels = labels
    }

    /// CA Pool tier
    public enum Tier: String, Codable, Sendable {
        case tierUnspecified = "TIER_UNSPECIFIED"
        case enterprise = "ENTERPRISE"
        case devops = "DEVOPS"

        public var description: String {
            switch self {
            case .tierUnspecified: return "Unspecified tier"
            case .enterprise: return "Enterprise tier with advanced features"
            case .devops: return "DevOps tier for development and CI/CD"
            }
        }
    }

    /// Issuance policy for the CA pool
    public struct IssuancePolicy: Codable, Sendable, Equatable {
        public let allowedKeyTypes: [AllowedKeyType]?
        public let maximumLifetime: String?
        public let allowedIssuanceModes: AllowedIssuanceModes?
        public let baselineValues: CertificateConfig.X509Parameters?
        public let identityConstraints: IdentityConstraints?
        public let passthroughExtensions: PassthroughExtensions?

        public init(
            allowedKeyTypes: [AllowedKeyType]? = nil,
            maximumLifetime: String? = nil,
            allowedIssuanceModes: AllowedIssuanceModes? = nil,
            baselineValues: CertificateConfig.X509Parameters? = nil,
            identityConstraints: IdentityConstraints? = nil,
            passthroughExtensions: PassthroughExtensions? = nil
        ) {
            self.allowedKeyTypes = allowedKeyTypes
            self.maximumLifetime = maximumLifetime
            self.allowedIssuanceModes = allowedIssuanceModes
            self.baselineValues = baselineValues
            self.identityConstraints = identityConstraints
            self.passthroughExtensions = passthroughExtensions
        }

        public struct AllowedKeyType: Codable, Sendable, Equatable {
            public let rsa: RSAKeyType?
            public let ellipticCurve: EllipticCurveKeyType?

            public init(rsa: RSAKeyType? = nil, ellipticCurve: EllipticCurveKeyType? = nil) {
                self.rsa = rsa
                self.ellipticCurve = ellipticCurve
            }

            public struct RSAKeyType: Codable, Sendable, Equatable {
                public let minModulusSize: Int64?
                public let maxModulusSize: Int64?

                public init(minModulusSize: Int64? = nil, maxModulusSize: Int64? = nil) {
                    self.minModulusSize = minModulusSize
                    self.maxModulusSize = maxModulusSize
                }
            }

            public struct EllipticCurveKeyType: Codable, Sendable, Equatable {
                public let signatureAlgorithm: SignatureAlgorithm?

                public init(signatureAlgorithm: SignatureAlgorithm? = nil) {
                    self.signatureAlgorithm = signatureAlgorithm
                }

                public enum SignatureAlgorithm: String, Codable, Sendable {
                    case ecSignatureAlgorithmUnspecified = "EC_SIGNATURE_ALGORITHM_UNSPECIFIED"
                    case ecdsaP256 = "ECDSA_P256"
                    case ecdsaP384 = "ECDSA_P384"
                }
            }

            public static var rsa2048: AllowedKeyType {
                AllowedKeyType(rsa: RSAKeyType(minModulusSize: 2048, maxModulusSize: 4096))
            }

            public static var ecdsaP256: AllowedKeyType {
                AllowedKeyType(ellipticCurve: EllipticCurveKeyType(signatureAlgorithm: .ecdsaP256))
            }
        }

        public struct AllowedIssuanceModes: Codable, Sendable, Equatable {
            public let allowCsrBasedIssuance: Bool?
            public let allowConfigBasedIssuance: Bool?

            public init(allowCsrBasedIssuance: Bool? = nil, allowConfigBasedIssuance: Bool? = nil) {
                self.allowCsrBasedIssuance = allowCsrBasedIssuance
                self.allowConfigBasedIssuance = allowConfigBasedIssuance
            }
        }

        public struct IdentityConstraints: Codable, Sendable, Equatable {
            public let celExpression: CelExpression?
            public let allowSubjectPassthrough: Bool?
            public let allowSubjectAltNamesPassthrough: Bool?

            public init(
                celExpression: CelExpression? = nil,
                allowSubjectPassthrough: Bool? = nil,
                allowSubjectAltNamesPassthrough: Bool? = nil
            ) {
                self.celExpression = celExpression
                self.allowSubjectPassthrough = allowSubjectPassthrough
                self.allowSubjectAltNamesPassthrough = allowSubjectAltNamesPassthrough
            }

            public struct CelExpression: Codable, Sendable, Equatable {
                public let expression: String
                public let title: String?
                public let description: String?

                public init(expression: String, title: String? = nil, description: String? = nil) {
                    self.expression = expression
                    self.title = title
                    self.description = description
                }
            }
        }

        public struct PassthroughExtensions: Codable, Sendable, Equatable {
            public let knownExtensions: [KnownExtension]?
            public let additionalExtensions: [ObjectId]?

            public init(knownExtensions: [KnownExtension]? = nil, additionalExtensions: [ObjectId]? = nil) {
                self.knownExtensions = knownExtensions
                self.additionalExtensions = additionalExtensions
            }

            public enum KnownExtension: String, Codable, Sendable {
                case knownExtensionUnspecified = "KNOWN_EXTENSION_UNSPECIFIED"
                case baseKeyUsage = "BASE_KEY_USAGE"
                case extendedKeyUsage = "EXTENDED_KEY_USAGE"
                case caOptions = "CA_OPTIONS"
                case policyIds = "POLICY_IDS"
                case aiaOcspServers = "AIA_OCSP_SERVERS"
            }

            public struct ObjectId: Codable, Sendable, Equatable {
                public let objectIdPath: [Int]

                public init(objectIdPath: [Int]) {
                    self.objectIdPath = objectIdPath
                }
            }
        }
    }

    /// Publishing options for CA pool
    public struct PublishingOptions: Codable, Sendable, Equatable {
        public let publishCaCert: Bool?
        public let publishCrl: Bool?
        public let encodingFormat: EncodingFormat?

        public init(
            publishCaCert: Bool? = nil,
            publishCrl: Bool? = nil,
            encodingFormat: EncodingFormat? = nil
        ) {
            self.publishCaCert = publishCaCert
            self.publishCrl = publishCrl
            self.encodingFormat = encodingFormat
        }

        public enum EncodingFormat: String, Codable, Sendable {
            case encodingFormatUnspecified = "ENCODING_FORMAT_UNSPECIFIED"
            case pem = "PEM"
            case der = "DER"
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/caPools/\(name)"
    }

    /// Create CA pool command
    public var createCommand: String {
        var cmd = "gcloud privateca pools create \(name) --project=\(projectID) --location=\(location) --tier=\(tier.rawValue.lowercased())"
        if let policy = publishingOptions {
            if policy.publishCaCert == true {
                cmd += " --publish-ca-cert"
            }
            if policy.publishCrl == true {
                cmd += " --publish-crl"
            }
        }
        return cmd
    }

    /// Delete CA pool command
    public var deleteCommand: String {
        "gcloud privateca pools delete \(name) --project=\(projectID) --location=\(location)"
    }

    /// Describe CA pool command
    public var describeCommand: String {
        "gcloud privateca pools describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// List CAs in pool command
    public var listCAsCommand: String {
        "gcloud privateca roots list --pool=\(name) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Certificate Authority

/// A Certificate Authority
public struct GoogleCloudCertificateAuthority: Codable, Sendable, Equatable {
    public let name: String
    public let caPoolName: String
    public let projectID: String
    public let location: String
    public let type: CAType
    public let config: CertificateConfig?
    public let lifetime: String?
    public let keySpec: KeyVersionSpec?
    public let state: State?
    public let pemCaCertificates: [String]?
    public let gcsBucket: String?
    public let labels: [String: String]?

    public init(
        name: String,
        caPoolName: String,
        projectID: String,
        location: String,
        type: CAType = .selfSigned,
        config: CertificateConfig? = nil,
        lifetime: String? = nil,
        keySpec: KeyVersionSpec? = nil,
        state: State? = nil,
        pemCaCertificates: [String]? = nil,
        gcsBucket: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.caPoolName = caPoolName
        self.projectID = projectID
        self.location = location
        self.type = type
        self.config = config
        self.lifetime = lifetime
        self.keySpec = keySpec
        self.state = state
        self.pemCaCertificates = pemCaCertificates
        self.gcsBucket = gcsBucket
        self.labels = labels
    }

    /// Certificate Authority type
    public enum CAType: String, Codable, Sendable {
        case typeUnspecified = "TYPE_UNSPECIFIED"
        case selfSigned = "SELF_SIGNED"
        case subordinate = "SUBORDINATE"
    }

    /// Certificate Authority state
    public enum State: String, Codable, Sendable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case enabled = "ENABLED"
        case disabled = "DISABLED"
        case staged = "STAGED"
        case awaitingUserActivation = "AWAITING_USER_ACTIVATION"
        case deleted = "DELETED"
    }

    /// Key version specification
    public struct KeyVersionSpec: Codable, Sendable, Equatable {
        public let cloudKmsKeyVersion: String?
        public let algorithm: SignHashAlgorithm?

        public init(cloudKmsKeyVersion: String? = nil, algorithm: SignHashAlgorithm? = nil) {
            self.cloudKmsKeyVersion = cloudKmsKeyVersion
            self.algorithm = algorithm
        }

        public enum SignHashAlgorithm: String, Codable, Sendable {
            case signHashAlgorithmUnspecified = "SIGN_HASH_ALGORITHM_UNSPECIFIED"
            case rsaPss2048Sha256 = "RSA_PSS_2048_SHA256"
            case rsaPss3072Sha256 = "RSA_PSS_3072_SHA256"
            case rsaPss4096Sha256 = "RSA_PSS_4096_SHA256"
            case rsaPkcs12048Sha256 = "RSA_PKCS1_2048_SHA256"
            case rsaPkcs13072Sha256 = "RSA_PKCS1_3072_SHA256"
            case rsaPkcs14096Sha256 = "RSA_PKCS1_4096_SHA256"
            case ecP256Sha256 = "EC_P256_SHA256"
            case ecP384Sha384 = "EC_P384_SHA384"
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/caPools/\(caPoolName)/certificateAuthorities/\(name)"
    }

    /// Create root CA command
    public var createRootCACommand: String {
        var cmd = "gcloud privateca roots create \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
        if let keySpec = keySpec, let algo = keySpec.algorithm {
            cmd += " --key-algorithm=\(algo.rawValue.lowercased().replacingOccurrences(of: "_", with: "-"))"
        }
        if let config = config, let subject = config.subjectConfig?.subject {
            if let org = subject.organization {
                cmd += " --subject=\"O=\(org)\""
            }
        }
        if let lifetime = lifetime {
            cmd += " --validity=\(lifetime)"
        }
        return cmd
    }

    /// Create subordinate CA command
    public var createSubordinateCACommand: String {
        "gcloud privateca subordinates create \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
    }

    /// Enable CA command
    public var enableCommand: String {
        "gcloud privateca roots enable \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
    }

    /// Disable CA command
    public var disableCommand: String {
        "gcloud privateca roots disable \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
    }

    /// Delete CA command
    public var deleteCommand: String {
        "gcloud privateca roots delete \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
    }

    /// Describe CA command
    public var describeCommand: String {
        "gcloud privateca roots describe \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
    }

    /// Get CA certificate command
    public var getCertificateCommand: String {
        "gcloud privateca roots get-ca-crt \(name) --pool=\(caPoolName) --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Certificate

/// A certificate issued by a CA
public struct GoogleCloudCertificate: Codable, Sendable, Equatable {
    public let name: String
    public let caPoolName: String
    public let projectID: String
    public let location: String
    public let lifetime: String?
    public let config: CertificateConfig?
    public let pemCsr: String?
    public let pemCertificate: String?
    public let pemCertificateChain: [String]?
    public let revocationDetails: RevocationDetails?
    public let certificateTemplate: String?
    public let subjectMode: SubjectRequestMode?
    public let labels: [String: String]?

    public init(
        name: String,
        caPoolName: String,
        projectID: String,
        location: String,
        lifetime: String? = nil,
        config: CertificateConfig? = nil,
        pemCsr: String? = nil,
        pemCertificate: String? = nil,
        pemCertificateChain: [String]? = nil,
        revocationDetails: RevocationDetails? = nil,
        certificateTemplate: String? = nil,
        subjectMode: SubjectRequestMode? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.caPoolName = caPoolName
        self.projectID = projectID
        self.location = location
        self.lifetime = lifetime
        self.config = config
        self.pemCsr = pemCsr
        self.pemCertificate = pemCertificate
        self.pemCertificateChain = pemCertificateChain
        self.revocationDetails = revocationDetails
        self.certificateTemplate = certificateTemplate
        self.subjectMode = subjectMode
        self.labels = labels
    }

    /// Subject request mode
    public enum SubjectRequestMode: String, Codable, Sendable {
        case subjectRequestModeUnspecified = "SUBJECT_REQUEST_MODE_UNSPECIFIED"
        case `default` = "DEFAULT"
        case reflectedSpiffe = "REFLECTED_SPIFFE"
    }

    /// Revocation details
    public struct RevocationDetails: Codable, Sendable, Equatable {
        public let revocationState: RevocationReason?
        public let revocationTime: String?

        public init(revocationState: RevocationReason? = nil, revocationTime: String? = nil) {
            self.revocationState = revocationState
            self.revocationTime = revocationTime
        }
    }

    /// Revocation reason
    public enum RevocationReason: String, Codable, Sendable {
        case revocationReasonUnspecified = "REVOCATION_REASON_UNSPECIFIED"
        case keyCompromise = "KEY_COMPROMISE"
        case certificateAuthorityCompromise = "CERTIFICATE_AUTHORITY_COMPROMISE"
        case affiliationChanged = "AFFILIATION_CHANGED"
        case superseded = "SUPERSEDED"
        case cessationOfOperation = "CESSATION_OF_OPERATION"
        case certificateHold = "CERTIFICATE_HOLD"
        case privilegeWithdrawn = "PRIVILEGE_WITHDRAWN"
        case attributeAuthorityCompromise = "ATTRIBUTE_AUTHORITY_COMPROMISE"
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/caPools/\(caPoolName)/certificates/\(name)"
    }

    /// Create certificate command (config-based)
    public var createCommand: String {
        var cmd = "gcloud privateca certificates create \(name) --issuer-pool=\(caPoolName) --project=\(projectID) --issuer-location=\(location)"
        if let lifetime = lifetime {
            cmd += " --validity=\(lifetime)"
        }
        return cmd
    }

    /// Create certificate from CSR command
    public func createFromCSRCommand(csrPath: String) -> String {
        var cmd = "gcloud privateca certificates create \(name) --issuer-pool=\(caPoolName) --project=\(projectID) --issuer-location=\(location) --csr=\(csrPath)"
        if let lifetime = lifetime {
            cmd += " --validity=\(lifetime)"
        }
        return cmd
    }

    /// Describe certificate command
    public var describeCommand: String {
        "gcloud privateca certificates describe \(name) --issuer-pool=\(caPoolName) --project=\(projectID) --issuer-location=\(location)"
    }

    /// Export certificate command
    public func exportCommand(outputFile: String) -> String {
        "gcloud privateca certificates export \(name) --issuer-pool=\(caPoolName) --project=\(projectID) --issuer-location=\(location) --output-file=\(outputFile)"
    }

    /// Revoke certificate command
    public func revokeCommand(reason: RevocationReason = .cessationOfOperation) -> String {
        "gcloud privateca certificates revoke \(name) --issuer-pool=\(caPoolName) --project=\(projectID) --issuer-location=\(location) --reason=\(reason.rawValue.lowercased().replacingOccurrences(of: "_", with: "-"))"
    }
}

// MARK: - Certificate Config

/// Configuration for certificates
public struct CertificateConfig: Codable, Sendable, Equatable {
    public let subjectConfig: SubjectConfig?
    public let x509Config: X509Parameters?
    public let publicKey: PublicKey?

    public init(
        subjectConfig: SubjectConfig? = nil,
        x509Config: X509Parameters? = nil,
        publicKey: PublicKey? = nil
    ) {
        self.subjectConfig = subjectConfig
        self.x509Config = x509Config
        self.publicKey = publicKey
    }

    /// Subject configuration
    public struct SubjectConfig: Codable, Sendable, Equatable {
        public let subject: Subject?
        public let subjectAltName: SubjectAltNames?

        public init(subject: Subject? = nil, subjectAltName: SubjectAltNames? = nil) {
            self.subject = subject
            self.subjectAltName = subjectAltName
        }
    }

    /// Subject details
    public struct Subject: Codable, Sendable, Equatable {
        public let commonName: String?
        public let organization: String?
        public let organizationalUnit: String?
        public let locality: String?
        public let province: String?
        public let countryCode: String?
        public let streetAddress: String?
        public let postalCode: String?

        public init(
            commonName: String? = nil,
            organization: String? = nil,
            organizationalUnit: String? = nil,
            locality: String? = nil,
            province: String? = nil,
            countryCode: String? = nil,
            streetAddress: String? = nil,
            postalCode: String? = nil
        ) {
            self.commonName = commonName
            self.organization = organization
            self.organizationalUnit = organizationalUnit
            self.locality = locality
            self.province = province
            self.countryCode = countryCode
            self.streetAddress = streetAddress
            self.postalCode = postalCode
        }

        /// Create subject string
        public var subjectString: String {
            var parts: [String] = []
            if let cn = commonName { parts.append("CN=\(cn)") }
            if let o = organization { parts.append("O=\(o)") }
            if let ou = organizationalUnit { parts.append("OU=\(ou)") }
            if let l = locality { parts.append("L=\(l)") }
            if let st = province { parts.append("ST=\(st)") }
            if let c = countryCode { parts.append("C=\(c)") }
            return parts.joined(separator: ", ")
        }
    }

    /// Subject alternative names
    public struct SubjectAltNames: Codable, Sendable, Equatable {
        public let dnsNames: [String]?
        public let uris: [String]?
        public let emailAddresses: [String]?
        public let ipAddresses: [String]?

        public init(
            dnsNames: [String]? = nil,
            uris: [String]? = nil,
            emailAddresses: [String]? = nil,
            ipAddresses: [String]? = nil
        ) {
            self.dnsNames = dnsNames
            self.uris = uris
            self.emailAddresses = emailAddresses
            self.ipAddresses = ipAddresses
        }
    }

    /// X.509 parameters
    public struct X509Parameters: Codable, Sendable, Equatable {
        public let keyUsage: KeyUsage?
        public let caOptions: CaOptions?
        public let policyIds: [ObjectId]?
        public let aiaOcspServers: [String]?
        public let additionalExtensions: [X509Extension]?

        public init(
            keyUsage: KeyUsage? = nil,
            caOptions: CaOptions? = nil,
            policyIds: [ObjectId]? = nil,
            aiaOcspServers: [String]? = nil,
            additionalExtensions: [X509Extension]? = nil
        ) {
            self.keyUsage = keyUsage
            self.caOptions = caOptions
            self.policyIds = policyIds
            self.aiaOcspServers = aiaOcspServers
            self.additionalExtensions = additionalExtensions
        }

        public struct ObjectId: Codable, Sendable, Equatable {
            public let objectIdPath: [Int]

            public init(objectIdPath: [Int]) {
                self.objectIdPath = objectIdPath
            }
        }

        public struct X509Extension: Codable, Sendable, Equatable {
            public let objectId: ObjectId
            public let critical: Bool?
            public let value: String

            public init(objectId: ObjectId, critical: Bool? = nil, value: String) {
                self.objectId = objectId
                self.critical = critical
                self.value = value
            }
        }
    }

    /// Key usage configuration
    public struct KeyUsage: Codable, Sendable, Equatable {
        public let baseKeyUsage: BaseKeyUsage?
        public let extendedKeyUsage: ExtendedKeyUsage?
        public let unknownExtendedKeyUsages: [X509Parameters.ObjectId]?

        public init(
            baseKeyUsage: BaseKeyUsage? = nil,
            extendedKeyUsage: ExtendedKeyUsage? = nil,
            unknownExtendedKeyUsages: [X509Parameters.ObjectId]? = nil
        ) {
            self.baseKeyUsage = baseKeyUsage
            self.extendedKeyUsage = extendedKeyUsage
            self.unknownExtendedKeyUsages = unknownExtendedKeyUsages
        }

        public struct BaseKeyUsage: Codable, Sendable, Equatable {
            public let digitalSignature: Bool?
            public let contentCommitment: Bool?
            public let keyEncipherment: Bool?
            public let dataEncipherment: Bool?
            public let keyAgreement: Bool?
            public let certSign: Bool?
            public let crlSign: Bool?
            public let encipherOnly: Bool?
            public let decipherOnly: Bool?

            public init(
                digitalSignature: Bool? = nil,
                contentCommitment: Bool? = nil,
                keyEncipherment: Bool? = nil,
                dataEncipherment: Bool? = nil,
                keyAgreement: Bool? = nil,
                certSign: Bool? = nil,
                crlSign: Bool? = nil,
                encipherOnly: Bool? = nil,
                decipherOnly: Bool? = nil
            ) {
                self.digitalSignature = digitalSignature
                self.contentCommitment = contentCommitment
                self.keyEncipherment = keyEncipherment
                self.dataEncipherment = dataEncipherment
                self.keyAgreement = keyAgreement
                self.certSign = certSign
                self.crlSign = crlSign
                self.encipherOnly = encipherOnly
                self.decipherOnly = decipherOnly
            }

            public static var serverAuth: BaseKeyUsage {
                BaseKeyUsage(digitalSignature: true, keyEncipherment: true)
            }

            public static var clientAuth: BaseKeyUsage {
                BaseKeyUsage(digitalSignature: true)
            }

            public static var codeSign: BaseKeyUsage {
                BaseKeyUsage(digitalSignature: true)
            }

            public static var caUsage: BaseKeyUsage {
                BaseKeyUsage(certSign: true, crlSign: true)
            }
        }

        public struct ExtendedKeyUsage: Codable, Sendable, Equatable {
            public let serverAuth: Bool?
            public let clientAuth: Bool?
            public let codeSigning: Bool?
            public let emailProtection: Bool?
            public let timeStamping: Bool?
            public let ocspSigning: Bool?

            public init(
                serverAuth: Bool? = nil,
                clientAuth: Bool? = nil,
                codeSigning: Bool? = nil,
                emailProtection: Bool? = nil,
                timeStamping: Bool? = nil,
                ocspSigning: Bool? = nil
            ) {
                self.serverAuth = serverAuth
                self.clientAuth = clientAuth
                self.codeSigning = codeSigning
                self.emailProtection = emailProtection
                self.timeStamping = timeStamping
                self.ocspSigning = ocspSigning
            }

            public static var serverAuth: ExtendedKeyUsage {
                ExtendedKeyUsage(serverAuth: true)
            }

            public static var clientAuth: ExtendedKeyUsage {
                ExtendedKeyUsage(clientAuth: true)
            }

            public static var mutualTLS: ExtendedKeyUsage {
                ExtendedKeyUsage(serverAuth: true, clientAuth: true)
            }

            public static var codeSigning: ExtendedKeyUsage {
                ExtendedKeyUsage(codeSigning: true)
            }
        }
    }

    /// CA options
    public struct CaOptions: Codable, Sendable, Equatable {
        public let isCa: Bool?
        public let maxIssuerPathLength: Int?

        public init(isCa: Bool? = nil, maxIssuerPathLength: Int? = nil) {
            self.isCa = isCa
            self.maxIssuerPathLength = maxIssuerPathLength
        }

        public static var rootCA: CaOptions {
            CaOptions(isCa: true, maxIssuerPathLength: nil)
        }

        public static var intermediateCA: CaOptions {
            CaOptions(isCa: true, maxIssuerPathLength: 0)
        }

        public static var endEntity: CaOptions {
            CaOptions(isCa: false)
        }
    }

    /// Public key
    public struct PublicKey: Codable, Sendable, Equatable {
        public let key: String?
        public let format: KeyFormat?

        public init(key: String? = nil, format: KeyFormat? = nil) {
            self.key = key
            self.format = format
        }

        public enum KeyFormat: String, Codable, Sendable {
            case keyFormatUnspecified = "KEY_FORMAT_UNSPECIFIED"
            case pem = "PEM"
        }
    }
}

// MARK: - Certificate Template

/// A certificate template for standardized issuance
public struct GoogleCloudCertificateTemplate: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let predefinedValues: CertificateConfig.X509Parameters?
    public let identityConstraints: GoogleCloudCaPool.IssuancePolicy.IdentityConstraints?
    public let passthroughExtensions: GoogleCloudCaPool.IssuancePolicy.PassthroughExtensions?
    public let maximumLifetime: String?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        location: String,
        description: String? = nil,
        predefinedValues: CertificateConfig.X509Parameters? = nil,
        identityConstraints: GoogleCloudCaPool.IssuancePolicy.IdentityConstraints? = nil,
        passthroughExtensions: GoogleCloudCaPool.IssuancePolicy.PassthroughExtensions? = nil,
        maximumLifetime: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.predefinedValues = predefinedValues
        self.identityConstraints = identityConstraints
        self.passthroughExtensions = passthroughExtensions
        self.maximumLifetime = maximumLifetime
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/certificateTemplates/\(name)"
    }

    /// Create template command
    public var createCommand: String {
        var cmd = "gcloud privateca templates create \(name) --project=\(projectID) --location=\(location)"
        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }
        return cmd
    }

    /// Delete template command
    public var deleteCommand: String {
        "gcloud privateca templates delete \(name) --project=\(projectID) --location=\(location)"
    }

    /// Describe template command
    public var describeCommand: String {
        "gcloud privateca templates describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// List templates command
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud privateca templates list --project=\(projectID) --location=\(location)"
    }
}

// MARK: - Certificate Revocation List

/// A Certificate Revocation List
public struct GoogleCloudCertificateRevocationList: Codable, Sendable, Equatable {
    public let name: String
    public let sequenceNumber: Int64?
    public let revokedCertificates: [RevokedCertificate]?
    public let pemCrl: String?
    public let accessUrl: String?
    public let state: State?
    public let createTime: String?
    public let updateTime: String?

    public init(
        name: String,
        sequenceNumber: Int64? = nil,
        revokedCertificates: [RevokedCertificate]? = nil,
        pemCrl: String? = nil,
        accessUrl: String? = nil,
        state: State? = nil,
        createTime: String? = nil,
        updateTime: String? = nil
    ) {
        self.name = name
        self.sequenceNumber = sequenceNumber
        self.revokedCertificates = revokedCertificates
        self.pemCrl = pemCrl
        self.accessUrl = accessUrl
        self.state = state
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// CRL state
    public enum State: String, Codable, Sendable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case active = "ACTIVE"
        case superseded = "SUPERSEDED"
    }

    /// Revoked certificate entry
    public struct RevokedCertificate: Codable, Sendable, Equatable {
        public let certificate: String?
        public let hexSerialNumber: String?
        public let revocationReason: GoogleCloudCertificate.RevocationReason?

        public init(
            certificate: String? = nil,
            hexSerialNumber: String? = nil,
            revocationReason: GoogleCloudCertificate.RevocationReason? = nil
        ) {
            self.certificate = certificate
            self.hexSerialNumber = hexSerialNumber
            self.revocationReason = revocationReason
        }
    }
}

// MARK: - Certificate Authority Service Operations

/// Operations for Certificate Authority Service
public struct CertificateAuthorityOperations: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "us-central1") {
        self.projectID = projectID
        self.location = location
    }

    /// Enable Certificate Authority Service API
    public var enableAPICommand: String {
        "gcloud services enable privateca.googleapis.com --project=\(projectID)"
    }

    /// List CA pools command
    public var listPoolsCommand: String {
        "gcloud privateca pools list --project=\(projectID) --location=\(location)"
    }

    /// List all CAs command
    public var listCAsCommand: String {
        "gcloud privateca roots list --project=\(projectID) --location=\(location)"
    }

    /// List certificates command
    public func listCertificatesCommand(pool: String) -> String {
        "gcloud privateca certificates list --issuer-pool=\(pool) --project=\(projectID) --issuer-location=\(location)"
    }

    /// List templates command
    public var listTemplatesCommand: String {
        "gcloud privateca templates list --project=\(projectID) --location=\(location)"
    }

    /// Create CSR command
    public func createCSRCommand(keyFile: String, csrFile: String, subject: String) -> String {
        "openssl req -newkey rsa:2048 -nodes -keyout \(keyFile) -out \(csrFile) -subj \"/\(subject)\""
    }

    /// Verify certificate command
    public func verifyCertificateCommand(certFile: String, caCertFile: String) -> String {
        "openssl verify -CAfile \(caCertFile) \(certFile)"
    }

    /// Show certificate details command
    public func showCertificateDetailsCommand(certFile: String) -> String {
        "openssl x509 -in \(certFile) -text -noout"
    }

    /// Add IAM binding for CA pool
    public func addPoolIAMBindingCommand(pool: String, member: String, role: CASRole) -> String {
        "gcloud privateca pools add-iam-policy-binding \(pool) --project=\(projectID) --location=\(location) --member=\(member) --role=\(role.rawValue)"
    }

    /// IAM roles for Certificate Authority Service
    public enum CASRole: String, Sendable {
        case caServiceAdmin = "roles/privateca.admin"
        case caServiceOperationManager = "roles/privateca.caManager"
        case certificateManager = "roles/privateca.certificateManager"
        case certificateRequester = "roles/privateca.certificateRequester"
        case auditor = "roles/privateca.auditor"
    }

    /// Locations
    public static var availableLocations: [String] {
        [
            "us-central1", "us-east1", "us-west1", "us-west2",
            "europe-west1", "europe-west2", "europe-west3",
            "asia-east1", "asia-southeast1", "asia-northeast1",
            "australia-southeast1", "northamerica-northeast1"
        ]
    }
}

// MARK: - DAIS Certificate Authority Template

/// DAIS template for Certificate Authority configurations
public struct DAISCertificateAuthorityTemplate: Sendable {
    public let projectID: String
    public let location: String
    public let organization: String

    public init(
        projectID: String,
        location: String = "us-central1",
        organization: String
    ) {
        self.projectID = projectID
        self.location = location
        self.organization = organization
    }

    /// Create a development CA pool
    public func devOpsPool(name: String) -> GoogleCloudCaPool {
        GoogleCloudCaPool(
            name: name,
            projectID: projectID,
            location: location,
            tier: .devops,
            publishingOptions: GoogleCloudCaPool.PublishingOptions(
                publishCaCert: true,
                publishCrl: true
            )
        )
    }

    /// Create an enterprise CA pool
    public func enterprisePool(name: String) -> GoogleCloudCaPool {
        GoogleCloudCaPool(
            name: name,
            projectID: projectID,
            location: location,
            tier: .enterprise,
            issuancePolicy: GoogleCloudCaPool.IssuancePolicy(
                allowedKeyTypes: [.rsa2048, .ecdsaP256],
                maximumLifetime: "31536000s", // 1 year
                allowedIssuanceModes: .init(allowCsrBasedIssuance: true, allowConfigBasedIssuance: true)
            ),
            publishingOptions: GoogleCloudCaPool.PublishingOptions(
                publishCaCert: true,
                publishCrl: true,
                encodingFormat: .pem
            )
        )
    }

    /// Create a root CA
    public func rootCA(
        name: String,
        pool: String,
        lifetime: String = "315360000s" // 10 years
    ) -> GoogleCloudCertificateAuthority {
        GoogleCloudCertificateAuthority(
            name: name,
            caPoolName: pool,
            projectID: projectID,
            location: location,
            type: .selfSigned,
            config: CertificateConfig(
                subjectConfig: .init(
                    subject: .init(
                        commonName: "\(organization) Root CA",
                        organization: organization
                    )
                ),
                x509Config: .init(
                    keyUsage: .init(
                        baseKeyUsage: .caUsage,
                        extendedKeyUsage: nil
                    ),
                    caOptions: .rootCA
                )
            ),
            lifetime: lifetime,
            keySpec: .init(algorithm: .ecP384Sha384)
        )
    }

    /// Create a subordinate CA
    public func subordinateCA(
        name: String,
        pool: String,
        lifetime: String = "94608000s" // 3 years
    ) -> GoogleCloudCertificateAuthority {
        GoogleCloudCertificateAuthority(
            name: name,
            caPoolName: pool,
            projectID: projectID,
            location: location,
            type: .subordinate,
            config: CertificateConfig(
                subjectConfig: .init(
                    subject: .init(
                        commonName: "\(organization) Issuing CA",
                        organization: organization
                    )
                ),
                x509Config: .init(
                    keyUsage: .init(
                        baseKeyUsage: .caUsage,
                        extendedKeyUsage: nil
                    ),
                    caOptions: .intermediateCA
                )
            ),
            lifetime: lifetime,
            keySpec: .init(algorithm: .ecP256Sha256)
        )
    }

    /// Create a server certificate
    public func serverCertificate(
        name: String,
        pool: String,
        dnsNames: [String],
        lifetime: String = "7776000s" // 90 days
    ) -> GoogleCloudCertificate {
        GoogleCloudCertificate(
            name: name,
            caPoolName: pool,
            projectID: projectID,
            location: location,
            lifetime: lifetime,
            config: CertificateConfig(
                subjectConfig: .init(
                    subject: .init(
                        commonName: dnsNames.first,
                        organization: organization
                    ),
                    subjectAltName: .init(dnsNames: dnsNames)
                ),
                x509Config: .init(
                    keyUsage: .init(
                        baseKeyUsage: .serverAuth,
                        extendedKeyUsage: .serverAuth
                    ),
                    caOptions: .endEntity
                )
            )
        )
    }

    /// Create a client certificate
    public func clientCertificate(
        name: String,
        pool: String,
        email: String,
        lifetime: String = "31536000s" // 1 year
    ) -> GoogleCloudCertificate {
        GoogleCloudCertificate(
            name: name,
            caPoolName: pool,
            projectID: projectID,
            location: location,
            lifetime: lifetime,
            config: CertificateConfig(
                subjectConfig: .init(
                    subject: .init(
                        commonName: email,
                        organization: organization
                    ),
                    subjectAltName: .init(emailAddresses: [email])
                ),
                x509Config: .init(
                    keyUsage: .init(
                        baseKeyUsage: .clientAuth,
                        extendedKeyUsage: .clientAuth
                    ),
                    caOptions: .endEntity
                )
            )
        )
    }

    /// Create a mutual TLS certificate template
    public var mTLSTemplate: GoogleCloudCertificateTemplate {
        GoogleCloudCertificateTemplate(
            name: "mtls-template",
            projectID: projectID,
            location: location,
            description: "Template for mutual TLS certificates",
            predefinedValues: .init(
                keyUsage: .init(
                    baseKeyUsage: .init(digitalSignature: true, keyEncipherment: true),
                    extendedKeyUsage: .mutualTLS
                ),
                caOptions: .endEntity
            ),
            maximumLifetime: "7776000s" // 90 days
        )
    }

    /// Create a code signing certificate template
    public var codeSigningTemplate: GoogleCloudCertificateTemplate {
        GoogleCloudCertificateTemplate(
            name: "codesigning-template",
            projectID: projectID,
            location: location,
            description: "Template for code signing certificates",
            predefinedValues: .init(
                keyUsage: .init(
                    baseKeyUsage: .codeSign,
                    extendedKeyUsage: .codeSigning
                ),
                caOptions: .endEntity
            ),
            maximumLifetime: "31536000s" // 1 year
        )
    }

    /// Operations helper
    public var operations: CertificateAuthorityOperations {
        CertificateAuthorityOperations(projectID: projectID, location: location)
    }

    /// Generate setup script for CA infrastructure
    public var setupScript: String {
        """
        #!/bin/bash
        # Certificate Authority Service Setup Script
        # Project: \(projectID)
        # Organization: \(organization)

        set -e

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        POOL_NAME="primary-pool"
        ROOT_CA_NAME="root-ca"

        echo "=== Enabling APIs ==="
        gcloud services enable privateca.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Creating CA Pool ==="
        gcloud privateca pools create $POOL_NAME \\
            --project=$PROJECT \\
            --location=$LOCATION \\
            --tier=devops \\
            --publish-ca-cert \\
            --publish-crl

        echo ""
        echo "=== Creating Root CA ==="
        gcloud privateca roots create $ROOT_CA_NAME \\
            --pool=$POOL_NAME \\
            --project=$PROJECT \\
            --location=$LOCATION \\
            --key-algorithm=ec-p384-sha384 \\
            --subject="CN=\(organization) Root CA, O=\(organization)" \\
            --validity=P10Y \\
            --auto-enable

        echo ""
        echo "=== Verifying Setup ==="
        gcloud privateca pools describe $POOL_NAME --project=$PROJECT --location=$LOCATION
        gcloud privateca roots describe $ROOT_CA_NAME --pool=$POOL_NAME --project=$PROJECT --location=$LOCATION

        echo ""
        echo "=== Setup Complete ==="
        echo "CA Pool: $POOL_NAME"
        echo "Root CA: $ROOT_CA_NAME"
        echo ""
        echo "To issue a certificate:"
        echo "gcloud privateca certificates create my-cert \\\\"
        echo "    --issuer-pool=$POOL_NAME \\\\"
        echo "    --issuer-location=$LOCATION \\\\"
        echo "    --project=$PROJECT \\\\"
        echo "    --generate-key \\\\"
        echo "    --key-output-file=key.pem \\\\"
        echo "    --cert-output-file=cert.pem \\\\"
        echo "    --dns-san=example.com"
        """
    }

    /// Generate certificate issuance script
    public func issueCertificateScript(
        certName: String,
        dnsNames: [String],
        poolName: String = "primary-pool"
    ) -> String {
        let dnsArgs = dnsNames.map { "--dns-san=\($0)" }.joined(separator: " ")
        return """
        #!/bin/bash
        # Certificate Issuance Script

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        POOL="\(poolName)"
        CERT_NAME="\(certName)"

        echo "Issuing certificate: $CERT_NAME"

        gcloud privateca certificates create $CERT_NAME \\
            --issuer-pool=$POOL \\
            --issuer-location=$LOCATION \\
            --project=$PROJECT \\
            --generate-key \\
            --key-output-file="${CERT_NAME}.key" \\
            --cert-output-file="${CERT_NAME}.crt" \\
            \(dnsArgs) \\
            --validity=P90D

        echo ""
        echo "Certificate issued:"
        echo "  Certificate: ${CERT_NAME}.crt"
        echo "  Private Key: ${CERT_NAME}.key"
        echo ""
        echo "View certificate details:"
        echo "openssl x509 -in ${CERT_NAME}.crt -text -noout"
        """
    }
}
