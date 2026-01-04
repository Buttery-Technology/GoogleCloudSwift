import Foundation

// MARK: - Cloud DLP Info Types

/// Represents a DLP info type for sensitive data detection
public struct GoogleCloudDLPInfoType: Codable, Sendable, Equatable {
    public let name: String
    public let version: String?
    public let sensitivityScore: SensitivityScore?

    public enum SensitivityScore: String, Codable, Sendable, Equatable {
        case sensitivityLow = "SENSITIVITY_LOW"
        case sensitivityModerate = "SENSITIVITY_MODERATE"
        case sensitivityHigh = "SENSITIVITY_HIGH"
    }

    public init(name: String, version: String? = nil, sensitivityScore: SensitivityScore? = nil) {
        self.name = name
        self.version = version
        self.sensitivityScore = sensitivityScore
    }

    /// Common built-in info types
    public static let creditCardNumber = GoogleCloudDLPInfoType(name: "CREDIT_CARD_NUMBER")
    public static let emailAddress = GoogleCloudDLPInfoType(name: "EMAIL_ADDRESS")
    public static let phoneNumber = GoogleCloudDLPInfoType(name: "PHONE_NUMBER")
    public static let usSSN = GoogleCloudDLPInfoType(name: "US_SOCIAL_SECURITY_NUMBER")
    public static let usBankRoutingNumber = GoogleCloudDLPInfoType(name: "US_BANK_ROUTING_MICR")
    public static let ipAddress = GoogleCloudDLPInfoType(name: "IP_ADDRESS")
    public static let macAddress = GoogleCloudDLPInfoType(name: "MAC_ADDRESS")
    public static let imeiHardwareID = GoogleCloudDLPInfoType(name: "IMEI_HARDWARE_ID")
    public static let dateOfBirth = GoogleCloudDLPInfoType(name: "DATE_OF_BIRTH")
    public static let personName = GoogleCloudDLPInfoType(name: "PERSON_NAME")
    public static let streetAddress = GoogleCloudDLPInfoType(name: "STREET_ADDRESS")
    public static let usDriversLicense = GoogleCloudDLPInfoType(name: "US_DRIVERS_LICENSE_NUMBER")
    public static let usPassport = GoogleCloudDLPInfoType(name: "US_PASSPORT")
    public static let cryptoWallet = GoogleCloudDLPInfoType(name: "CRYPTO_WALLET")
    public static let ibanCode = GoogleCloudDLPInfoType(name: "IBAN_CODE")
    public static let swiftCode = GoogleCloudDLPInfoType(name: "SWIFT_CODE")
    public static let medicalRecordNumber = GoogleCloudDLPInfoType(name: "MEDICAL_RECORD_NUMBER")
    public static let genderIdentity = GoogleCloudDLPInfoType(name: "GENDER")
    public static let ethnicGroup = GoogleCloudDLPInfoType(name: "ETHNIC_GROUP")
    public static let age = GoogleCloudDLPInfoType(name: "AGE")

    /// All common PII info types
    public static var allPII: [GoogleCloudDLPInfoType] {
        [
            .creditCardNumber, .emailAddress, .phoneNumber, .usSSN,
            .ipAddress, .dateOfBirth, .personName, .streetAddress,
            .usDriversLicense, .usPassport
        ]
    }

    /// Financial info types
    public static var financial: [GoogleCloudDLPInfoType] {
        [.creditCardNumber, .usBankRoutingNumber, .ibanCode, .swiftCode, .cryptoWallet]
    }

    /// Healthcare info types
    public static var healthcare: [GoogleCloudDLPInfoType] {
        [.medicalRecordNumber, .dateOfBirth, .personName, .usSSN]
    }
}

// MARK: - Inspect Config

/// Configuration for DLP content inspection
public struct GoogleCloudDLPInspectConfig: Codable, Sendable, Equatable {
    public let infoTypes: [GoogleCloudDLPInfoType]?
    public let minLikelihood: Likelihood?
    public let limits: FindingLimits?
    public let includeQuote: Bool?
    public let excludeInfoTypes: Bool?
    public let customInfoTypes: [CustomInfoType]?
    public let ruleSet: [InspectionRuleSet]?

    public enum Likelihood: String, Codable, Sendable, Equatable {
        case likelihoodUnspecified = "LIKELIHOOD_UNSPECIFIED"
        case veryUnlikely = "VERY_UNLIKELY"
        case unlikely = "UNLIKELY"
        case possible = "POSSIBLE"
        case likely = "LIKELY"
        case veryLikely = "VERY_LIKELY"
    }

    public struct FindingLimits: Codable, Sendable, Equatable {
        public let maxFindingsPerItem: Int?
        public let maxFindingsPerRequest: Int?
        public let maxFindingsPerInfoType: [InfoTypeLimit]?

        public struct InfoTypeLimit: Codable, Sendable, Equatable {
            public let infoType: GoogleCloudDLPInfoType
            public let maxFindings: Int

            public init(infoType: GoogleCloudDLPInfoType, maxFindings: Int) {
                self.infoType = infoType
                self.maxFindings = maxFindings
            }
        }

        public init(
            maxFindingsPerItem: Int? = nil,
            maxFindingsPerRequest: Int? = nil,
            maxFindingsPerInfoType: [InfoTypeLimit]? = nil
        ) {
            self.maxFindingsPerItem = maxFindingsPerItem
            self.maxFindingsPerRequest = maxFindingsPerRequest
            self.maxFindingsPerInfoType = maxFindingsPerInfoType
        }
    }

    public struct CustomInfoType: Codable, Sendable, Equatable {
        public let infoType: GoogleCloudDLPInfoType
        public let likelihood: Likelihood?
        public let regex: Regex?
        public let dictionary: Dictionary?

        public struct Regex: Codable, Sendable, Equatable {
            public let pattern: String
            public let groupIndexes: [Int]?

            public init(pattern: String, groupIndexes: [Int]? = nil) {
                self.pattern = pattern
                self.groupIndexes = groupIndexes
            }
        }

        public struct Dictionary: Codable, Sendable, Equatable {
            public let wordList: WordList?
            public let cloudStoragePath: CloudStoragePath?

            public struct WordList: Codable, Sendable, Equatable {
                public let words: [String]

                public init(words: [String]) {
                    self.words = words
                }
            }

            public struct CloudStoragePath: Codable, Sendable, Equatable {
                public let path: String

                public init(path: String) {
                    self.path = path
                }
            }

            public init(wordList: WordList? = nil, cloudStoragePath: CloudStoragePath? = nil) {
                self.wordList = wordList
                self.cloudStoragePath = cloudStoragePath
            }
        }

        public init(
            infoType: GoogleCloudDLPInfoType,
            likelihood: Likelihood? = nil,
            regex: Regex? = nil,
            dictionary: Dictionary? = nil
        ) {
            self.infoType = infoType
            self.likelihood = likelihood
            self.regex = regex
            self.dictionary = dictionary
        }
    }

    public struct InspectionRuleSet: Codable, Sendable, Equatable {
        public let infoTypes: [GoogleCloudDLPInfoType]
        public let rules: [InspectionRule]

        public struct InspectionRule: Codable, Sendable, Equatable {
            public let hotwordRule: HotwordRule?
            public let exclusionRule: ExclusionRule?

            public struct HotwordRule: Codable, Sendable, Equatable {
                public let hotwordRegex: Regex
                public let proximity: Proximity
                public let likelihoodAdjustment: LikelihoodAdjustment

                public struct Regex: Codable, Sendable, Equatable {
                    public let pattern: String

                    public init(pattern: String) {
                        self.pattern = pattern
                    }
                }

                public struct Proximity: Codable, Sendable, Equatable {
                    public let windowBefore: Int?
                    public let windowAfter: Int?

                    public init(windowBefore: Int? = nil, windowAfter: Int? = nil) {
                        self.windowBefore = windowBefore
                        self.windowAfter = windowAfter
                    }
                }

                public struct LikelihoodAdjustment: Codable, Sendable, Equatable {
                    public let fixedLikelihood: Likelihood?
                    public let relativeLikelihood: Int?

                    public init(fixedLikelihood: Likelihood? = nil, relativeLikelihood: Int? = nil) {
                        self.fixedLikelihood = fixedLikelihood
                        self.relativeLikelihood = relativeLikelihood
                    }
                }

                public init(
                    hotwordRegex: Regex,
                    proximity: Proximity,
                    likelihoodAdjustment: LikelihoodAdjustment
                ) {
                    self.hotwordRegex = hotwordRegex
                    self.proximity = proximity
                    self.likelihoodAdjustment = likelihoodAdjustment
                }
            }

            public struct ExclusionRule: Codable, Sendable, Equatable {
                public let matchingType: MatchingType
                public let regex: Regex?
                public let dictionary: CustomInfoType.Dictionary?

                public enum MatchingType: String, Codable, Sendable, Equatable {
                    case matchingTypeFullMatch = "MATCHING_TYPE_FULL_MATCH"
                    case matchingTypePartialMatch = "MATCHING_TYPE_PARTIAL_MATCH"
                    case matchingTypeInverseMatch = "MATCHING_TYPE_INVERSE_MATCH"
                }

                public struct Regex: Codable, Sendable, Equatable {
                    public let pattern: String

                    public init(pattern: String) {
                        self.pattern = pattern
                    }
                }

                public init(
                    matchingType: MatchingType,
                    regex: Regex? = nil,
                    dictionary: CustomInfoType.Dictionary? = nil
                ) {
                    self.matchingType = matchingType
                    self.regex = regex
                    self.dictionary = dictionary
                }
            }

            public init(hotwordRule: HotwordRule? = nil, exclusionRule: ExclusionRule? = nil) {
                self.hotwordRule = hotwordRule
                self.exclusionRule = exclusionRule
            }
        }

        public init(infoTypes: [GoogleCloudDLPInfoType], rules: [InspectionRule]) {
            self.infoTypes = infoTypes
            self.rules = rules
        }
    }

    public init(
        infoTypes: [GoogleCloudDLPInfoType]? = nil,
        minLikelihood: Likelihood? = nil,
        limits: FindingLimits? = nil,
        includeQuote: Bool? = nil,
        excludeInfoTypes: Bool? = nil,
        customInfoTypes: [CustomInfoType]? = nil,
        ruleSet: [InspectionRuleSet]? = nil
    ) {
        self.infoTypes = infoTypes
        self.minLikelihood = minLikelihood
        self.limits = limits
        self.includeQuote = includeQuote
        self.excludeInfoTypes = excludeInfoTypes
        self.customInfoTypes = customInfoTypes
        self.ruleSet = ruleSet
    }
}

// MARK: - Deidentify Config

/// Configuration for DLP data de-identification
public struct GoogleCloudDLPDeidentifyConfig: Codable, Sendable, Equatable {
    public let infoTypeTransformations: InfoTypeTransformations?
    public let recordTransformations: RecordTransformations?

    public struct InfoTypeTransformations: Codable, Sendable, Equatable {
        public let transformations: [InfoTypeTransformation]

        public struct InfoTypeTransformation: Codable, Sendable, Equatable {
            public let infoTypes: [GoogleCloudDLPInfoType]?
            public let primitiveTransformation: PrimitiveTransformation

            public init(
                infoTypes: [GoogleCloudDLPInfoType]? = nil,
                primitiveTransformation: PrimitiveTransformation
            ) {
                self.infoTypes = infoTypes
                self.primitiveTransformation = primitiveTransformation
            }
        }

        public init(transformations: [InfoTypeTransformation]) {
            self.transformations = transformations
        }
    }

    public struct RecordTransformations: Codable, Sendable, Equatable {
        public let fieldTransformations: [FieldTransformation]?

        public struct FieldTransformation: Codable, Sendable, Equatable {
            public let fields: [FieldId]
            public let primitiveTransformation: PrimitiveTransformation?
            public let condition: RecordCondition?

            public struct FieldId: Codable, Sendable, Equatable {
                public let name: String

                public init(name: String) {
                    self.name = name
                }
            }

            public struct RecordCondition: Codable, Sendable, Equatable {
                public let expressions: Expressions?

                public struct Expressions: Codable, Sendable, Equatable {
                    public let logicalOperator: LogicalOperator?
                    public let conditions: Conditions?

                    public enum LogicalOperator: String, Codable, Sendable, Equatable {
                        case and = "AND"
                    }

                    public struct Conditions: Codable, Sendable, Equatable {
                        public let conditions: [Condition]

                        public struct Condition: Codable, Sendable, Equatable {
                            public let field: FieldId
                            public let `operator`: Operator
                            public let value: Value

                            public enum Operator: String, Codable, Sendable, Equatable {
                                case equalTo = "EQUAL_TO"
                                case notEqualTo = "NOT_EQUAL_TO"
                                case greaterThan = "GREATER_THAN"
                                case lessThan = "LESS_THAN"
                                case greaterThanOrEquals = "GREATER_THAN_OR_EQUALS"
                                case lessThanOrEquals = "LESS_THAN_OR_EQUALS"
                                case exists = "EXISTS"
                            }

                            public struct Value: Codable, Sendable, Equatable {
                                public let stringValue: String?
                                public let integerValue: Int64?
                                public let booleanValue: Bool?

                                public init(
                                    stringValue: String? = nil,
                                    integerValue: Int64? = nil,
                                    booleanValue: Bool? = nil
                                ) {
                                    self.stringValue = stringValue
                                    self.integerValue = integerValue
                                    self.booleanValue = booleanValue
                                }
                            }

                            public init(field: FieldId, operator: Operator, value: Value) {
                                self.field = field
                                self.operator = `operator`
                                self.value = value
                            }
                        }

                        public init(conditions: [Condition]) {
                            self.conditions = conditions
                        }
                    }

                    public init(
                        logicalOperator: LogicalOperator? = nil,
                        conditions: Conditions? = nil
                    ) {
                        self.logicalOperator = logicalOperator
                        self.conditions = conditions
                    }
                }

                public init(expressions: Expressions? = nil) {
                    self.expressions = expressions
                }
            }

            public init(
                fields: [FieldId],
                primitiveTransformation: PrimitiveTransformation? = nil,
                condition: RecordCondition? = nil
            ) {
                self.fields = fields
                self.primitiveTransformation = primitiveTransformation
                self.condition = condition
            }
        }

        public init(fieldTransformations: [FieldTransformation]? = nil) {
            self.fieldTransformations = fieldTransformations
        }
    }

    public init(
        infoTypeTransformations: InfoTypeTransformations? = nil,
        recordTransformations: RecordTransformations? = nil
    ) {
        self.infoTypeTransformations = infoTypeTransformations
        self.recordTransformations = recordTransformations
    }
}

// MARK: - Primitive Transformation

/// Primitive transformation types for de-identification
public struct PrimitiveTransformation: Codable, Sendable, Equatable {
    public let replaceConfig: ReplaceConfig?
    public let redactConfig: RedactConfig?
    public let characterMaskConfig: CharacterMaskConfig?
    public let cryptoReplaceFfxFpeConfig: CryptoReplaceFfxFpeConfig?
    public let cryptoHashConfig: CryptoHashConfig?
    public let dateShiftConfig: DateShiftConfig?
    public let bucketingConfig: BucketingConfig?
    public let replaceWithInfoTypeConfig: ReplaceWithInfoTypeConfig?

    public struct ReplaceConfig: Codable, Sendable, Equatable {
        public let newValue: Value

        public struct Value: Codable, Sendable, Equatable {
            public let stringValue: String?
            public let integerValue: Int64?

            public init(stringValue: String? = nil, integerValue: Int64? = nil) {
                self.stringValue = stringValue
                self.integerValue = integerValue
            }
        }

        public init(newValue: Value) {
            self.newValue = newValue
        }
    }

    public struct RedactConfig: Codable, Sendable, Equatable {
        public init() {}
    }

    public struct CharacterMaskConfig: Codable, Sendable, Equatable {
        public let maskingCharacter: String?
        public let numberToMask: Int?
        public let reverseOrder: Bool?
        public let charactersToIgnore: [CharsToIgnore]?

        public struct CharsToIgnore: Codable, Sendable, Equatable {
            public let charactersToSkip: String?
            public let commonCharactersToIgnore: CommonCharsToIgnore?

            public enum CommonCharsToIgnore: String, Codable, Sendable, Equatable {
                case numeric = "NUMERIC"
                case alphaUpperCase = "ALPHA_UPPER_CASE"
                case alphaLowerCase = "ALPHA_LOWER_CASE"
                case punctuation = "PUNCTUATION"
                case whitespace = "WHITESPACE"
            }

            public init(
                charactersToSkip: String? = nil,
                commonCharactersToIgnore: CommonCharsToIgnore? = nil
            ) {
                self.charactersToSkip = charactersToSkip
                self.commonCharactersToIgnore = commonCharactersToIgnore
            }
        }

        public init(
            maskingCharacter: String? = nil,
            numberToMask: Int? = nil,
            reverseOrder: Bool? = nil,
            charactersToIgnore: [CharsToIgnore]? = nil
        ) {
            self.maskingCharacter = maskingCharacter
            self.numberToMask = numberToMask
            self.reverseOrder = reverseOrder
            self.charactersToIgnore = charactersToIgnore
        }
    }

    public struct CryptoReplaceFfxFpeConfig: Codable, Sendable, Equatable {
        public let cryptoKey: CryptoKey
        public let commonAlphabet: CommonAlphabet?
        public let customAlphabet: String?
        public let radix: Int?
        public let surrogateInfoType: GoogleCloudDLPInfoType?

        public struct CryptoKey: Codable, Sendable, Equatable {
            public let kmsWrapped: KmsWrappedCryptoKey?
            public let unwrapped: UnwrappedCryptoKey?
            public let transient: TransientCryptoKey?

            public struct KmsWrappedCryptoKey: Codable, Sendable, Equatable {
                public let wrappedKey: String
                public let cryptoKeyName: String

                public init(wrappedKey: String, cryptoKeyName: String) {
                    self.wrappedKey = wrappedKey
                    self.cryptoKeyName = cryptoKeyName
                }
            }

            public struct UnwrappedCryptoKey: Codable, Sendable, Equatable {
                public let key: String

                public init(key: String) {
                    self.key = key
                }
            }

            public struct TransientCryptoKey: Codable, Sendable, Equatable {
                public let name: String

                public init(name: String) {
                    self.name = name
                }
            }

            public init(
                kmsWrapped: KmsWrappedCryptoKey? = nil,
                unwrapped: UnwrappedCryptoKey? = nil,
                transient: TransientCryptoKey? = nil
            ) {
                self.kmsWrapped = kmsWrapped
                self.unwrapped = unwrapped
                self.transient = transient
            }
        }

        public enum CommonAlphabet: String, Codable, Sendable, Equatable {
            case numeric = "NUMERIC"
            case hexadecimal = "HEXADECIMAL"
            case upperCaseAlphaNumeric = "UPPER_CASE_ALPHA_NUMERIC"
            case alphaNumeric = "ALPHA_NUMERIC"
        }

        public init(
            cryptoKey: CryptoKey,
            commonAlphabet: CommonAlphabet? = nil,
            customAlphabet: String? = nil,
            radix: Int? = nil,
            surrogateInfoType: GoogleCloudDLPInfoType? = nil
        ) {
            self.cryptoKey = cryptoKey
            self.commonAlphabet = commonAlphabet
            self.customAlphabet = customAlphabet
            self.radix = radix
            self.surrogateInfoType = surrogateInfoType
        }
    }

    public struct CryptoHashConfig: Codable, Sendable, Equatable {
        public let cryptoKey: CryptoReplaceFfxFpeConfig.CryptoKey

        public init(cryptoKey: CryptoReplaceFfxFpeConfig.CryptoKey) {
            self.cryptoKey = cryptoKey
        }
    }

    public struct DateShiftConfig: Codable, Sendable, Equatable {
        public let upperBoundDays: Int
        public let lowerBoundDays: Int
        public let cryptoKey: CryptoReplaceFfxFpeConfig.CryptoKey?

        public init(
            upperBoundDays: Int,
            lowerBoundDays: Int,
            cryptoKey: CryptoReplaceFfxFpeConfig.CryptoKey? = nil
        ) {
            self.upperBoundDays = upperBoundDays
            self.lowerBoundDays = lowerBoundDays
            self.cryptoKey = cryptoKey
        }
    }

    public struct BucketingConfig: Codable, Sendable, Equatable {
        public let buckets: [Bucket]

        public struct Bucket: Codable, Sendable, Equatable {
            public let min: BucketValue?
            public let max: BucketValue?
            public let replacementValue: BucketValue

            public struct BucketValue: Codable, Sendable, Equatable {
                public let integerValue: Int64?
                public let floatValue: Double?
                public let stringValue: String?

                public init(
                    integerValue: Int64? = nil,
                    floatValue: Double? = nil,
                    stringValue: String? = nil
                ) {
                    self.integerValue = integerValue
                    self.floatValue = floatValue
                    self.stringValue = stringValue
                }
            }

            public init(min: BucketValue? = nil, max: BucketValue? = nil, replacementValue: BucketValue) {
                self.min = min
                self.max = max
                self.replacementValue = replacementValue
            }
        }

        public init(buckets: [Bucket]) {
            self.buckets = buckets
        }
    }

    public struct ReplaceWithInfoTypeConfig: Codable, Sendable, Equatable {
        public init() {}
    }

    public init(
        replaceConfig: ReplaceConfig? = nil,
        redactConfig: RedactConfig? = nil,
        characterMaskConfig: CharacterMaskConfig? = nil,
        cryptoReplaceFfxFpeConfig: CryptoReplaceFfxFpeConfig? = nil,
        cryptoHashConfig: CryptoHashConfig? = nil,
        dateShiftConfig: DateShiftConfig? = nil,
        bucketingConfig: BucketingConfig? = nil,
        replaceWithInfoTypeConfig: ReplaceWithInfoTypeConfig? = nil
    ) {
        self.replaceConfig = replaceConfig
        self.redactConfig = redactConfig
        self.characterMaskConfig = characterMaskConfig
        self.cryptoReplaceFfxFpeConfig = cryptoReplaceFfxFpeConfig
        self.cryptoHashConfig = cryptoHashConfig
        self.dateShiftConfig = dateShiftConfig
        self.bucketingConfig = bucketingConfig
        self.replaceWithInfoTypeConfig = replaceWithInfoTypeConfig
    }

    /// Create a redaction transformation
    public static var redact: PrimitiveTransformation {
        PrimitiveTransformation(redactConfig: RedactConfig())
    }

    /// Create a replacement transformation
    public static func replace(with value: String) -> PrimitiveTransformation {
        PrimitiveTransformation(replaceConfig: ReplaceConfig(
            newValue: ReplaceConfig.Value(stringValue: value)
        ))
    }

    /// Create a character masking transformation
    public static func mask(character: String = "*", numberToMask: Int? = nil, reverseOrder: Bool = false) -> PrimitiveTransformation {
        PrimitiveTransformation(characterMaskConfig: CharacterMaskConfig(
            maskingCharacter: character,
            numberToMask: numberToMask,
            reverseOrder: reverseOrder
        ))
    }

    /// Create a replacement with info type transformation
    public static var replaceWithInfoType: PrimitiveTransformation {
        PrimitiveTransformation(replaceWithInfoTypeConfig: ReplaceWithInfoTypeConfig())
    }
}

// MARK: - Inspect Template

/// Represents a DLP inspect template for reusable inspection configurations
public struct GoogleCloudDLPInspectTemplate: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String?
    public let description: String?
    public let inspectConfig: GoogleCloudDLPInspectConfig
    public let createTime: Date?
    public let updateTime: Date?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        displayName: String? = nil,
        description: String? = nil,
        inspectConfig: GoogleCloudDLPInspectConfig,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.description = description
        self.inspectConfig = inspectConfig
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/inspectTemplates/\(name)"
    }

    /// Command to create the template
    public var createCommand: String {
        var cmd = "gcloud dlp inspect-templates create \(name) --project=\(projectID) --location=\(location)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let description = description {
            cmd += " --description='\(description)'"
        }
        return cmd
    }

    /// Command to delete the template
    public var deleteCommand: String {
        "gcloud dlp inspect-templates delete \(resourceName) --quiet"
    }

    /// Command to describe the template
    public var describeCommand: String {
        "gcloud dlp inspect-templates describe \(resourceName)"
    }
}

// MARK: - Deidentify Template

/// Represents a DLP deidentify template for reusable de-identification configurations
public struct GoogleCloudDLPDeidentifyTemplate: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String?
    public let description: String?
    public let deidentifyConfig: GoogleCloudDLPDeidentifyConfig
    public let createTime: Date?
    public let updateTime: Date?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        displayName: String? = nil,
        description: String? = nil,
        deidentifyConfig: GoogleCloudDLPDeidentifyConfig,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.description = description
        self.deidentifyConfig = deidentifyConfig
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/deidentifyTemplates/\(name)"
    }

    /// Command to create the template
    public var createCommand: String {
        var cmd = "gcloud dlp deidentify-templates create \(name) --project=\(projectID) --location=\(location)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let description = description {
            cmd += " --description='\(description)'"
        }
        return cmd
    }

    /// Command to delete the template
    public var deleteCommand: String {
        "gcloud dlp deidentify-templates delete \(resourceName) --quiet"
    }

    /// Command to describe the template
    public var describeCommand: String {
        "gcloud dlp deidentify-templates describe \(resourceName)"
    }
}

// MARK: - Job Trigger

/// Represents a DLP job trigger for scheduled inspection
public struct GoogleCloudDLPJobTrigger: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String?
    public let description: String?
    public let triggers: [Trigger]?
    public let inspectJob: InspectJobConfig?
    public let status: Status?
    public let createTime: Date?
    public let updateTime: Date?

    public struct Trigger: Codable, Sendable, Equatable {
        public let schedule: Schedule?
        public let manual: Manual?

        public struct Schedule: Codable, Sendable, Equatable {
            public let recurrencePeriodDuration: String

            public init(recurrencePeriodDuration: String) {
                self.recurrencePeriodDuration = recurrencePeriodDuration
            }

            /// Create a schedule with hours
            public static func hours(_ hours: Int) -> Schedule {
                Schedule(recurrencePeriodDuration: "\(hours * 3600)s")
            }

            /// Create a schedule with days
            public static func days(_ days: Int) -> Schedule {
                Schedule(recurrencePeriodDuration: "\(days * 86400)s")
            }
        }

        public struct Manual: Codable, Sendable, Equatable {
            public init() {}
        }

        public init(schedule: Schedule? = nil, manual: Manual? = nil) {
            self.schedule = schedule
            self.manual = manual
        }
    }

    public struct InspectJobConfig: Codable, Sendable, Equatable {
        public let storageConfig: StorageConfig
        public let inspectConfig: GoogleCloudDLPInspectConfig?
        public let inspectTemplateName: String?
        public let actions: [Action]?

        public struct StorageConfig: Codable, Sendable, Equatable {
            public let datastoreOptions: DatastoreOptions?
            public let cloudStorageOptions: CloudStorageOptions?
            public let bigQueryOptions: BigQueryOptions?

            public struct DatastoreOptions: Codable, Sendable, Equatable {
                public let partitionId: PartitionId
                public let kind: Kind

                public struct PartitionId: Codable, Sendable, Equatable {
                    public let projectId: String
                    public let namespaceId: String?

                    public init(projectId: String, namespaceId: String? = nil) {
                        self.projectId = projectId
                        self.namespaceId = namespaceId
                    }
                }

                public struct Kind: Codable, Sendable, Equatable {
                    public let name: String

                    public init(name: String) {
                        self.name = name
                    }
                }

                public init(partitionId: PartitionId, kind: Kind) {
                    self.partitionId = partitionId
                    self.kind = kind
                }
            }

            public struct CloudStorageOptions: Codable, Sendable, Equatable {
                public let fileSet: FileSet
                public let bytesLimitPerFile: Int64?
                public let bytesLimitPerFilePercent: Int?
                public let fileTypes: [FileType]?
                public let sampleMethod: SampleMethod?
                public let filesLimitPercent: Int?

                public struct FileSet: Codable, Sendable, Equatable {
                    public let url: String?
                    public let regexFileSet: RegexFileSet?

                    public struct RegexFileSet: Codable, Sendable, Equatable {
                        public let bucketName: String
                        public let includeRegex: [String]?
                        public let excludeRegex: [String]?

                        public init(
                            bucketName: String,
                            includeRegex: [String]? = nil,
                            excludeRegex: [String]? = nil
                        ) {
                            self.bucketName = bucketName
                            self.includeRegex = includeRegex
                            self.excludeRegex = excludeRegex
                        }
                    }

                    public init(url: String? = nil, regexFileSet: RegexFileSet? = nil) {
                        self.url = url
                        self.regexFileSet = regexFileSet
                    }
                }

                public enum FileType: String, Codable, Sendable, Equatable {
                    case binaryFile = "BINARY_FILE"
                    case textFile = "TEXT_FILE"
                    case image = "IMAGE"
                    case word = "WORD"
                    case pdf = "PDF"
                    case avro = "AVRO"
                    case csv = "CSV"
                    case tsv = "TSV"
                    case excel = "EXCEL"
                    case powerpoint = "POWERPOINT"
                }

                public enum SampleMethod: String, Codable, Sendable, Equatable {
                    case top = "TOP"
                    case randomStart = "RANDOM_START"
                }

                public init(
                    fileSet: FileSet,
                    bytesLimitPerFile: Int64? = nil,
                    bytesLimitPerFilePercent: Int? = nil,
                    fileTypes: [FileType]? = nil,
                    sampleMethod: SampleMethod? = nil,
                    filesLimitPercent: Int? = nil
                ) {
                    self.fileSet = fileSet
                    self.bytesLimitPerFile = bytesLimitPerFile
                    self.bytesLimitPerFilePercent = bytesLimitPerFilePercent
                    self.fileTypes = fileTypes
                    self.sampleMethod = sampleMethod
                    self.filesLimitPercent = filesLimitPercent
                }
            }

            public struct BigQueryOptions: Codable, Sendable, Equatable {
                public let tableReference: TableReference
                public let rowsLimit: Int64?
                public let rowsLimitPercent: Int?
                public let sampleMethod: SampleMethod?
                public let identifyingFields: [FieldId]?

                public struct TableReference: Codable, Sendable, Equatable {
                    public let projectId: String
                    public let datasetId: String
                    public let tableId: String

                    public init(projectId: String, datasetId: String, tableId: String) {
                        self.projectId = projectId
                        self.datasetId = datasetId
                        self.tableId = tableId
                    }
                }

                public struct FieldId: Codable, Sendable, Equatable {
                    public let name: String

                    public init(name: String) {
                        self.name = name
                    }
                }

                public enum SampleMethod: String, Codable, Sendable, Equatable {
                    case top = "TOP"
                    case randomStart = "RANDOM_START"
                }

                public init(
                    tableReference: TableReference,
                    rowsLimit: Int64? = nil,
                    rowsLimitPercent: Int? = nil,
                    sampleMethod: SampleMethod? = nil,
                    identifyingFields: [FieldId]? = nil
                ) {
                    self.tableReference = tableReference
                    self.rowsLimit = rowsLimit
                    self.rowsLimitPercent = rowsLimitPercent
                    self.sampleMethod = sampleMethod
                    self.identifyingFields = identifyingFields
                }
            }

            public init(
                datastoreOptions: DatastoreOptions? = nil,
                cloudStorageOptions: CloudStorageOptions? = nil,
                bigQueryOptions: BigQueryOptions? = nil
            ) {
                self.datastoreOptions = datastoreOptions
                self.cloudStorageOptions = cloudStorageOptions
                self.bigQueryOptions = bigQueryOptions
            }
        }

        public struct Action: Codable, Sendable, Equatable {
            public let saveFindings: SaveFindings?
            public let pubSub: PublishToPubSub?
            public let publishSummaryToCscc: PublishSummaryToCscc?
            public let jobNotificationEmails: JobNotificationEmails?

            public struct SaveFindings: Codable, Sendable, Equatable {
                public let outputConfig: OutputStorageConfig

                public struct OutputStorageConfig: Codable, Sendable, Equatable {
                    public let table: TableReference?
                    public let outputSchema: OutputSchema?

                    public struct TableReference: Codable, Sendable, Equatable {
                        public let projectId: String
                        public let datasetId: String
                        public let tableId: String

                        public init(projectId: String, datasetId: String, tableId: String) {
                            self.projectId = projectId
                            self.datasetId = datasetId
                            self.tableId = tableId
                        }
                    }

                    public enum OutputSchema: String, Codable, Sendable, Equatable {
                        case basicColumns = "BASIC_COLUMNS"
                        case gcsColumns = "GCS_COLUMNS"
                        case datastoreColumns = "DATASTORE_COLUMNS"
                        case bigQueryColumns = "BIG_QUERY_COLUMNS"
                        case allColumns = "ALL_COLUMNS"
                    }

                    public init(table: TableReference? = nil, outputSchema: OutputSchema? = nil) {
                        self.table = table
                        self.outputSchema = outputSchema
                    }
                }

                public init(outputConfig: OutputStorageConfig) {
                    self.outputConfig = outputConfig
                }
            }

            public struct PublishToPubSub: Codable, Sendable, Equatable {
                public let topic: String

                public init(topic: String) {
                    self.topic = topic
                }
            }

            public struct PublishSummaryToCscc: Codable, Sendable, Equatable {
                public init() {}
            }

            public struct JobNotificationEmails: Codable, Sendable, Equatable {
                public init() {}
            }

            public init(
                saveFindings: SaveFindings? = nil,
                pubSub: PublishToPubSub? = nil,
                publishSummaryToCscc: PublishSummaryToCscc? = nil,
                jobNotificationEmails: JobNotificationEmails? = nil
            ) {
                self.saveFindings = saveFindings
                self.pubSub = pubSub
                self.publishSummaryToCscc = publishSummaryToCscc
                self.jobNotificationEmails = jobNotificationEmails
            }
        }

        public init(
            storageConfig: StorageConfig,
            inspectConfig: GoogleCloudDLPInspectConfig? = nil,
            inspectTemplateName: String? = nil,
            actions: [Action]? = nil
        ) {
            self.storageConfig = storageConfig
            self.inspectConfig = inspectConfig
            self.inspectTemplateName = inspectTemplateName
            self.actions = actions
        }
    }

    public enum Status: String, Codable, Sendable, Equatable {
        case statusUnspecified = "STATUS_UNSPECIFIED"
        case healthy = "HEALTHY"
        case paused = "PAUSED"
        case cancelled = "CANCELLED"
    }

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        displayName: String? = nil,
        description: String? = nil,
        triggers: [Trigger]? = nil,
        inspectJob: InspectJobConfig? = nil,
        status: Status? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.description = description
        self.triggers = triggers
        self.inspectJob = inspectJob
        self.status = status
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/jobTriggers/\(name)"
    }

    /// Command to list job triggers
    public var listCommand: String {
        "gcloud dlp job-triggers list --project=\(projectID) --location=\(location)"
    }

    /// Command to describe the trigger
    public var describeCommand: String {
        "gcloud dlp job-triggers describe \(resourceName)"
    }

    /// Command to delete the trigger
    public var deleteCommand: String {
        "gcloud dlp job-triggers delete \(resourceName) --quiet"
    }

    /// Command to activate the trigger
    public var activateCommand: String {
        "gcloud dlp job-triggers activate \(resourceName)"
    }

    /// Command to pause the trigger
    public var pauseCommand: String {
        "gcloud dlp job-triggers pause \(resourceName)"
    }
}

// MARK: - DLP Operations

/// Helper operations for Cloud DLP
public struct DLPOperations: Sendable {

    /// Command to inspect content inline
    public static func inspectContentCommand(projectID: String, content: String, infoTypes: [GoogleCloudDLPInfoType]) -> String {
        let types = infoTypes.map { $0.name }.joined(separator: ",")
        return "echo '\(content)' | gcloud dlp text inspect --project=\(projectID) --info-types=\(types)"
    }

    /// Command to inspect a file
    public static func inspectFileCommand(projectID: String, file: String, infoTypes: [GoogleCloudDLPInfoType]) -> String {
        let types = infoTypes.map { $0.name }.joined(separator: ",")
        return "gcloud dlp text inspect --project=\(projectID) --content-file=\(file) --info-types=\(types)"
    }

    /// Command to list inspect templates
    public static func listInspectTemplatesCommand(projectID: String, location: String = "global") -> String {
        "gcloud dlp inspect-templates list --project=\(projectID) --location=\(location)"
    }

    /// Command to list deidentify templates
    public static func listDeidentifyTemplatesCommand(projectID: String, location: String = "global") -> String {
        "gcloud dlp deidentify-templates list --project=\(projectID) --location=\(location)"
    }

    /// Command to list job triggers
    public static func listJobTriggersCommand(projectID: String, location: String = "global") -> String {
        "gcloud dlp job-triggers list --project=\(projectID) --location=\(location)"
    }

    /// Command to list DLP jobs
    public static func listJobsCommand(projectID: String, location: String = "global", jobType: String? = nil) -> String {
        var cmd = "gcloud dlp jobs list --project=\(projectID) --location=\(location)"
        if let jobType = jobType {
            cmd += " --filter='type=\(jobType)'"
        }
        return cmd
    }

    /// Command to enable DLP API
    public static var enableAPICommand: String {
        "gcloud services enable dlp.googleapis.com"
    }

    /// Command to redact an image
    public static func redactImageCommand(projectID: String, inputPath: String, outputPath: String, infoTypes: [GoogleCloudDLPInfoType]) -> String {
        let types = infoTypes.map { $0.name }.joined(separator: ",")
        return "gcloud dlp images redact --project=\(projectID) --input-file=\(inputPath) --output-file=\(outputPath) --info-types=\(types)"
    }
}

// MARK: - DAIS DLP Template

/// Production-ready DLP templates for DAIS systems
public struct DAISDLPTemplate: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "global") {
        self.projectID = projectID
        self.location = location
    }

    /// PII inspection configuration
    public var piiInspectConfig: GoogleCloudDLPInspectConfig {
        GoogleCloudDLPInspectConfig(
            infoTypes: GoogleCloudDLPInfoType.allPII,
            minLikelihood: .likely,
            limits: GoogleCloudDLPInspectConfig.FindingLimits(
                maxFindingsPerItem: 100,
                maxFindingsPerRequest: 1000
            ),
            includeQuote: true
        )
    }

    /// Financial data inspection configuration
    public var financialInspectConfig: GoogleCloudDLPInspectConfig {
        GoogleCloudDLPInspectConfig(
            infoTypes: GoogleCloudDLPInfoType.financial,
            minLikelihood: .possible,
            includeQuote: true
        )
    }

    /// Healthcare data inspection configuration
    public var healthcareInspectConfig: GoogleCloudDLPInspectConfig {
        GoogleCloudDLPInspectConfig(
            infoTypes: GoogleCloudDLPInfoType.healthcare,
            minLikelihood: .likely,
            includeQuote: true
        )
    }

    /// Basic redaction de-identification config
    public var redactionDeidentifyConfig: GoogleCloudDLPDeidentifyConfig {
        GoogleCloudDLPDeidentifyConfig(
            infoTypeTransformations: GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations(
                transformations: [
                    GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                        primitiveTransformation: .redact
                    )
                ]
            )
        )
    }

    /// Masking de-identification config
    public var maskingDeidentifyConfig: GoogleCloudDLPDeidentifyConfig {
        GoogleCloudDLPDeidentifyConfig(
            infoTypeTransformations: GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations(
                transformations: [
                    GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                        infoTypes: [.creditCardNumber],
                        primitiveTransformation: .mask(character: "*", numberToMask: 12)
                    ),
                    GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                        infoTypes: [.usSSN],
                        primitiveTransformation: .mask(character: "X", numberToMask: 5)
                    ),
                    GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                        infoTypes: [.emailAddress, .phoneNumber],
                        primitiveTransformation: .replaceWithInfoType
                    )
                ]
            )
        )
    }

    /// PII inspect template
    public var piiInspectTemplate: GoogleCloudDLPInspectTemplate {
        GoogleCloudDLPInspectTemplate(
            name: "dais-pii-inspect",
            projectID: projectID,
            location: location,
            displayName: "DAIS PII Inspection Template",
            description: "Inspects for common PII including SSN, credit cards, emails, and phone numbers",
            inspectConfig: piiInspectConfig
        )
    }

    /// Redaction de-identify template
    public var redactionDeidentifyTemplate: GoogleCloudDLPDeidentifyTemplate {
        GoogleCloudDLPDeidentifyTemplate(
            name: "dais-redaction-deidentify",
            projectID: projectID,
            location: location,
            displayName: "DAIS Redaction Template",
            description: "Redacts all sensitive data findings",
            deidentifyConfig: redactionDeidentifyConfig
        )
    }

    /// Masking de-identify template
    public var maskingDeidentifyTemplate: GoogleCloudDLPDeidentifyTemplate {
        GoogleCloudDLPDeidentifyTemplate(
            name: "dais-masking-deidentify",
            projectID: projectID,
            location: location,
            displayName: "DAIS Masking Template",
            description: "Masks credit cards, SSNs, and replaces other PII with info type names",
            deidentifyConfig: maskingDeidentifyConfig
        )
    }

    /// Setup script to deploy DLP templates and resources
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"

        echo "Enabling Cloud DLP API..."
        gcloud services enable dlp.googleapis.com --project=$PROJECT_ID

        echo ""
        echo "Cloud DLP setup complete!"
        echo ""
        echo "Available commands:"
        echo "  Inspect text: gcloud dlp text inspect --project=$PROJECT_ID --info-types=CREDIT_CARD_NUMBER,EMAIL_ADDRESS"
        echo "  List templates: gcloud dlp inspect-templates list --project=$PROJECT_ID --location=$LOCATION"
        echo "  List job triggers: gcloud dlp job-triggers list --project=$PROJECT_ID --location=$LOCATION"
        """
    }
}
