// GoogleCloudTranslation.swift
// Cloud Translation API for text translation

import Foundation

// MARK: - Translation Request

/// Request to translate text
public struct GoogleCloudTranslationRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location (global or region)
    public let location: String

    /// Text to translate (up to 30,000 characters)
    public let contents: [String]

    /// Source language code (BCP-47, e.g., "en", "de")
    public let sourceLanguageCode: String?

    /// Target language code (required)
    public let targetLanguageCode: String

    /// MIME type of source text
    public let mimeType: MIMEType?

    /// Glossary config for terminology
    public let glossaryConfig: GlossaryConfig?

    /// Model to use
    public let model: TranslationModel?

    /// MIME types
    public enum MIMEType: String, Codable, Sendable {
        case plainText = "text/plain"
        case html = "text/html"
    }

    /// Translation model types
    public enum TranslationModel: String, Codable, Sendable {
        case nmt = "nmt"           // Neural Machine Translation
        case base = "base"         // Phrase-based (legacy)
    }

    /// Glossary configuration
    public struct GlossaryConfig: Codable, Sendable, Equatable {
        /// Glossary resource name
        public let glossary: String

        /// Ignore case
        public let ignoreCase: Bool?

        public init(glossary: String, ignoreCase: Bool? = nil) {
            self.glossary = glossary
            self.ignoreCase = ignoreCase
        }
    }

    public init(
        projectID: String,
        location: String = "global",
        contents: [String],
        sourceLanguageCode: String? = nil,
        targetLanguageCode: String,
        mimeType: MIMEType? = nil,
        glossaryConfig: GlossaryConfig? = nil,
        model: TranslationModel? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.contents = contents
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
        self.mimeType = mimeType
        self.glossaryConfig = glossaryConfig
        self.model = model
    }

    /// Resource name for the parent
    public var parent: String {
        "projects/\(projectID)/locations/\(location)"
    }

    /// gcloud translate command
    public var translateCommand: String {
        if contents.count == 1, let text = contents.first {
            let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")
            return "gcloud translate text \"\(escapedText)\" --target-language=\(targetLanguageCode) --project=\(projectID)"
        }
        return "# Use Translation API for multiple text inputs"
    }
}

// MARK: - Translation Response

/// Response from translation
public struct GoogleCloudTranslationResponse: Codable, Sendable, Equatable {
    /// Translations
    public let translations: [Translation]

    /// Glossary translations (if glossary was used)
    public let glossaryTranslations: [Translation]?

    /// Individual translation result
    public struct Translation: Codable, Sendable, Equatable {
        /// Translated text
        public let translatedText: String

        /// Detected source language (if not provided)
        public let detectedLanguageCode: String?

        /// Model used
        public let model: String?

        /// Glossary translation info
        public let glossaryConfig: GoogleCloudTranslationRequest.GlossaryConfig?

        public init(
            translatedText: String,
            detectedLanguageCode: String? = nil,
            model: String? = nil,
            glossaryConfig: GoogleCloudTranslationRequest.GlossaryConfig? = nil
        ) {
            self.translatedText = translatedText
            self.detectedLanguageCode = detectedLanguageCode
            self.model = model
            self.glossaryConfig = glossaryConfig
        }
    }

    public init(translations: [Translation], glossaryTranslations: [Translation]? = nil) {
        self.translations = translations
        self.glossaryTranslations = glossaryTranslations
    }
}

// MARK: - Detect Language Request

/// Request to detect language
public struct GoogleCloudDetectLanguageRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Content to analyze
    public let content: String

    /// MIME type
    public let mimeType: GoogleCloudTranslationRequest.MIMEType?

    public init(
        projectID: String,
        location: String = "global",
        content: String,
        mimeType: GoogleCloudTranslationRequest.MIMEType? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.content = content
        self.mimeType = mimeType
    }

    /// gcloud detect command
    public var detectCommand: String {
        let escapedContent = content.replacingOccurrences(of: "\"", with: "\\\"")
        return "gcloud translate detect-language \"\(escapedContent)\" --project=\(projectID)"
    }
}

// MARK: - Detect Language Response

/// Response from language detection
public struct GoogleCloudDetectLanguageResponse: Codable, Sendable, Equatable {
    /// Detected languages
    public let languages: [DetectedLanguage]

    /// Individual detected language
    public struct DetectedLanguage: Codable, Sendable, Equatable {
        /// Language code
        public let languageCode: String

        /// Confidence (0.0 to 1.0)
        public let confidence: Double

        public init(languageCode: String, confidence: Double) {
            self.languageCode = languageCode
            self.confidence = confidence
        }
    }

    public init(languages: [DetectedLanguage]) {
        self.languages = languages
    }

    /// Most likely language
    public var mostLikely: DetectedLanguage? {
        languages.max(by: { $0.confidence < $1.confidence })
    }
}

// MARK: - Supported Languages

/// Supported language info
public struct GoogleCloudSupportedLanguage: Codable, Sendable, Equatable {
    /// Language code (BCP-47)
    public let languageCode: String

    /// Display name in target language
    public let displayName: String?

    /// Whether this language supports source translation
    public let supportSource: Bool

    /// Whether this language supports target translation
    public let supportTarget: Bool

    public init(
        languageCode: String,
        displayName: String? = nil,
        supportSource: Bool = true,
        supportTarget: Bool = true
    ) {
        self.languageCode = languageCode
        self.displayName = displayName
        self.supportSource = supportSource
        self.supportTarget = supportTarget
    }
}

// MARK: - Glossary

/// A glossary for translation terminology
public struct GoogleCloudGlossary: Codable, Sendable, Equatable {
    /// Glossary name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Language pair (unidirectional)
    public let languagePair: LanguagePair?

    /// Language codes set (all combinations)
    public let languageCodesSet: LanguageCodesSet?

    /// Input configuration
    public let inputConfig: InputConfig

    /// Entry count
    public let entryCount: Int?

    /// Submit time
    public let submitTime: String?

    /// End time
    public let endTime: String?

    /// Language pair for unidirectional glossary
    public struct LanguagePair: Codable, Sendable, Equatable {
        /// Source language code
        public let sourceLanguageCode: String

        /// Target language code
        public let targetLanguageCode: String

        public init(sourceLanguageCode: String, targetLanguageCode: String) {
            self.sourceLanguageCode = sourceLanguageCode
            self.targetLanguageCode = targetLanguageCode
        }
    }

    /// Language codes set for multi-language glossary
    public struct LanguageCodesSet: Codable, Sendable, Equatable {
        /// Language codes
        public let languageCodes: [String]

        public init(languageCodes: [String]) {
            self.languageCodes = languageCodes
        }
    }

    /// Input configuration
    public struct InputConfig: Codable, Sendable, Equatable {
        /// GCS source
        public let gcsSource: GCSSource

        public init(gcsSource: GCSSource) {
            self.gcsSource = gcsSource
        }

        /// GCS source
        public struct GCSSource: Codable, Sendable, Equatable {
            /// Input URI
            public let inputUri: String

            public init(inputUri: String) {
                self.inputUri = inputUri
            }
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        languagePair: LanguagePair? = nil,
        languageCodesSet: LanguageCodesSet? = nil,
        inputConfig: InputConfig,
        entryCount: Int? = nil,
        submitTime: String? = nil,
        endTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.languagePair = languagePair
        self.languageCodesSet = languageCodesSet
        self.inputConfig = inputConfig
        self.entryCount = entryCount
        self.submitTime = submitTime
        self.endTime = endTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/glossaries/\(name)"
    }

    /// Create glossary command
    public var createCommand: String {
        if let pair = languagePair {
            return """
            gcloud translate glossaries create \(name) \\
                --source-language=\(pair.sourceLanguageCode) \\
                --target-language=\(pair.targetLanguageCode) \\
                --input-uri=\(inputConfig.gcsSource.inputUri) \\
                --location=\(location) \\
                --project=\(projectID)
            """
        } else if let set = languageCodesSet {
            return """
            gcloud translate glossaries create \(name) \\
                --languages=\(set.languageCodes.joined(separator: ",")) \\
                --input-uri=\(inputConfig.gcsSource.inputUri) \\
                --location=\(location) \\
                --project=\(projectID)
            """
        }
        return "# Specify either languagePair or languageCodesSet"
    }

    /// Delete glossary command
    public var deleteCommand: String {
        "gcloud translate glossaries delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }
}

// MARK: - Batch Translation

/// Batch translation job
public struct GoogleCloudBatchTranslation: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Source language
    public let sourceLanguageCode: String

    /// Target language codes
    public let targetLanguageCodes: [String]

    /// Input configs
    public let inputConfigs: [InputConfig]

    /// Output config
    public let outputConfig: OutputConfig

    /// Glossaries (keyed by target language)
    public let glossaries: [String: GoogleCloudTranslationRequest.GlossaryConfig]?

    /// Models (keyed by target language)
    public let models: [String: String]?

    /// Input configuration
    public struct InputConfig: Codable, Sendable, Equatable {
        /// MIME type
        public let mimeType: GoogleCloudTranslationRequest.MIMEType

        /// GCS source
        public let gcsSource: GCSSource

        public init(mimeType: GoogleCloudTranslationRequest.MIMEType, gcsSource: GCSSource) {
            self.mimeType = mimeType
            self.gcsSource = gcsSource
        }

        /// GCS source
        public struct GCSSource: Codable, Sendable, Equatable {
            /// Input URI
            public let inputUri: String

            public init(inputUri: String) {
                self.inputUri = inputUri
            }
        }
    }

    /// Output configuration
    public struct OutputConfig: Codable, Sendable, Equatable {
        /// GCS destination
        public let gcsDestination: GCSDestination

        public init(gcsDestination: GCSDestination) {
            self.gcsDestination = gcsDestination
        }

        /// GCS destination
        public struct GCSDestination: Codable, Sendable, Equatable {
            /// Output URI prefix
            public let outputUriPrefix: String

            public init(outputUriPrefix: String) {
                self.outputUriPrefix = outputUriPrefix
            }
        }
    }

    public init(
        projectID: String,
        location: String = "us-central1",
        sourceLanguageCode: String,
        targetLanguageCodes: [String],
        inputConfigs: [InputConfig],
        outputConfig: OutputConfig,
        glossaries: [String: GoogleCloudTranslationRequest.GlossaryConfig]? = nil,
        models: [String: String]? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCodes = targetLanguageCodes
        self.inputConfigs = inputConfigs
        self.outputConfig = outputConfig
        self.glossaries = glossaries
        self.models = models
    }

    /// Resource name for the parent
    public var parent: String {
        "projects/\(projectID)/locations/\(location)"
    }
}

// MARK: - Adaptive MT Dataset

/// Adaptive Machine Translation dataset
public struct GoogleCloudAdaptiveMTDataset: Codable, Sendable, Equatable {
    /// Dataset name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String

    /// Source language code
    public let sourceLanguageCode: String

    /// Target language code
    public let targetLanguageCode: String

    /// Example count
    public let exampleCount: Int?

    /// Create time
    public let createTime: String?

    /// Update time
    public let updateTime: String?

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        displayName: String,
        sourceLanguageCode: String,
        targetLanguageCode: String,
        exampleCount: Int? = nil,
        createTime: String? = nil,
        updateTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
        self.exampleCount = exampleCount
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/adaptiveMtDatasets/\(name)"
    }
}

// MARK: - Custom Model

/// Custom translation model
public struct GoogleCloudTranslationModel: Codable, Sendable, Equatable {
    /// Model name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String

    /// Source language
    public let sourceLanguageCode: String

    /// Target language
    public let targetLanguageCode: String

    /// Training state
    public let trainState: TrainState?

    /// Create time
    public let createTime: String?

    /// Training state
    public enum TrainState: String, Codable, Sendable {
        case unspecified = "TRAIN_STATE_UNSPECIFIED"
        case queued = "QUEUED"
        case preparing = "PREPARING"
        case training = "TRAINING"
        case validating = "VALIDATING"
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
    }

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        displayName: String,
        sourceLanguageCode: String,
        targetLanguageCode: String,
        trainState: TrainState? = nil,
        createTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
        self.trainState = trainState
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/models/\(name)"
    }
}

// MARK: - Document Translation

/// Document translation request
public struct GoogleCloudDocumentTranslation: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Source language code
    public let sourceLanguageCode: String?

    /// Target language code
    public let targetLanguageCode: String

    /// Document input config
    public let documentInputConfig: DocumentInputConfig

    /// Document output config
    public let documentOutputConfig: DocumentOutputConfig?

    /// Glossary config
    public let glossaryConfig: GoogleCloudTranslationRequest.GlossaryConfig?

    /// Document input configuration
    public struct DocumentInputConfig: Codable, Sendable, Equatable {
        /// MIME type
        public let mimeType: String

        /// GCS source
        public let gcsSource: GCSSource?

        /// Inline content (base64)
        public let content: String?

        public init(mimeType: String, gcsSource: GCSSource? = nil, content: String? = nil) {
            self.mimeType = mimeType
            self.gcsSource = gcsSource
            self.content = content
        }

        /// GCS source
        public struct GCSSource: Codable, Sendable, Equatable {
            /// Input URI
            public let inputUri: String

            public init(inputUri: String) {
                self.inputUri = inputUri
            }
        }
    }

    /// Document output configuration
    public struct DocumentOutputConfig: Codable, Sendable, Equatable {
        /// GCS destination
        public let gcsDestination: GCSDestination?

        /// MIME type
        public let mimeType: String?

        public init(gcsDestination: GCSDestination? = nil, mimeType: String? = nil) {
            self.gcsDestination = gcsDestination
            self.mimeType = mimeType
        }

        /// GCS destination
        public struct GCSDestination: Codable, Sendable, Equatable {
            /// Output URI prefix
            public let outputUriPrefix: String

            public init(outputUriPrefix: String) {
                self.outputUriPrefix = outputUriPrefix
            }
        }
    }

    public init(
        projectID: String,
        location: String = "global",
        sourceLanguageCode: String? = nil,
        targetLanguageCode: String,
        documentInputConfig: DocumentInputConfig,
        documentOutputConfig: DocumentOutputConfig? = nil,
        glossaryConfig: GoogleCloudTranslationRequest.GlossaryConfig? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
        self.documentInputConfig = documentInputConfig
        self.documentOutputConfig = documentOutputConfig
        self.glossaryConfig = glossaryConfig
    }

    /// Parent resource
    public var parent: String {
        "projects/\(projectID)/locations/\(location)"
    }
}

// MARK: - Common Languages

/// Common language codes
public enum LanguageCode: String, Codable, Sendable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case russian = "ru"
    case japanese = "ja"
    case korean = "ko"
    case chinese = "zh"
    case chineseSimplified = "zh-CN"
    case chineseTraditional = "zh-TW"
    case arabic = "ar"
    case hindi = "hi"
    case dutch = "nl"
    case polish = "pl"
    case turkish = "tr"
    case vietnamese = "vi"
    case thai = "th"
    case indonesian = "id"
    case swedish = "sv"
    case danish = "da"
    case norwegian = "no"
    case finnish = "fi"
    case greek = "el"
    case hebrew = "he"
    case czech = "cs"
    case hungarian = "hu"
    case romanian = "ro"
    case ukrainian = "uk"

    /// Display name
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .chinese: return "Chinese"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .chineseTraditional: return "Chinese (Traditional)"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        case .dutch: return "Dutch"
        case .polish: return "Polish"
        case .turkish: return "Turkish"
        case .vietnamese: return "Vietnamese"
        case .thai: return "Thai"
        case .indonesian: return "Indonesian"
        case .swedish: return "Swedish"
        case .danish: return "Danish"
        case .norwegian: return "Norwegian"
        case .finnish: return "Finnish"
        case .greek: return "Greek"
        case .hebrew: return "Hebrew"
        case .czech: return "Czech"
        case .hungarian: return "Hungarian"
        case .romanian: return "Romanian"
        case .ukrainian: return "Ukrainian"
        }
    }
}

// MARK: - Operations

/// Translation operations helper
public struct GoogleCloudTranslationOperations: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "global") {
        self.projectID = projectID
        self.location = location
    }

    /// Translate text
    public func translate(_ text: String, to targetLanguage: String) -> String {
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")
        return "gcloud translate text \"\(escapedText)\" --target-language=\(targetLanguage) --project=\(projectID)"
    }

    /// Translate with source language specified
    public func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")
        return "gcloud translate text \"\(escapedText)\" --source-language=\(sourceLanguage) --target-language=\(targetLanguage) --project=\(projectID)"
    }

    /// Detect language
    public func detectLanguage(_ text: String) -> String {
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")
        return "gcloud translate detect-language \"\(escapedText)\" --project=\(projectID)"
    }

    /// List supported languages
    public var listLanguagesCommand: String {
        "gcloud translate list-languages --project=\(projectID)"
    }

    /// List glossaries
    public var listGlossariesCommand: String {
        "gcloud translate glossaries list --location=\(location) --project=\(projectID)"
    }

    /// Describe glossary
    public func describeGlossary(_ name: String) -> String {
        "gcloud translate glossaries describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Enable Translation API
    public var enableAPICommand: String {
        "gcloud services enable translate.googleapis.com --project=\(projectID)"
    }

    /// IAM roles for Translation
    public static let roles: [String: String] = [
        "roles/cloudtranslate.viewer": "Translation viewer",
        "roles/cloudtranslate.user": "Translation user",
        "roles/cloudtranslate.editor": "Translation editor",
        "roles/cloudtranslate.admin": "Translation admin"
    ]
}

// MARK: - DAIS Template

/// DAIS template for Translation
public struct DAISTranslationTemplate: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Service account
    public let serviceAccount: String

    /// Glossary bucket for terminology
    public let glossaryBucket: String

    /// Default source language
    public let defaultSourceLanguage: LanguageCode

    /// Default target languages
    public let defaultTargetLanguages: [LanguageCode]

    public init(
        projectID: String,
        location: String = "us-central1",
        serviceAccount: String = "translation-service",
        glossaryBucket: String = "translation-glossaries",
        defaultSourceLanguage: LanguageCode = .english,
        defaultTargetLanguages: [LanguageCode] = [.spanish, .french, .german]
    ) {
        self.projectID = projectID
        self.location = location
        self.serviceAccount = serviceAccount
        self.glossaryBucket = glossaryBucket
        self.defaultSourceLanguage = defaultSourceLanguage
        self.defaultTargetLanguages = defaultTargetLanguages
    }

    /// Quick translate
    public func translate(_ text: String, to language: LanguageCode) -> GoogleCloudTranslationRequest {
        GoogleCloudTranslationRequest(
            projectID: projectID,
            location: location,
            contents: [text],
            sourceLanguageCode: defaultSourceLanguage.rawValue,
            targetLanguageCode: language.rawValue
        )
    }

    /// Multi-language translate
    public func translateToAll(_ text: String) -> [GoogleCloudTranslationRequest] {
        defaultTargetLanguages.map { lang in
            GoogleCloudTranslationRequest(
                projectID: projectID,
                location: location,
                contents: [text],
                sourceLanguageCode: defaultSourceLanguage.rawValue,
                targetLanguageCode: lang.rawValue
            )
        }
    }

    /// Detect and translate
    public func detectLanguageRequest(_ text: String) -> GoogleCloudDetectLanguageRequest {
        GoogleCloudDetectLanguageRequest(
            projectID: projectID,
            location: location,
            content: text
        )
    }

    /// Create glossary for terminology
    public func createGlossary(
        name: String,
        sourceLanguage: LanguageCode,
        targetLanguage: LanguageCode,
        glossaryFile: String
    ) -> GoogleCloudGlossary {
        GoogleCloudGlossary(
            name: name,
            projectID: projectID,
            location: location,
            languagePair: GoogleCloudGlossary.LanguagePair(
                sourceLanguageCode: sourceLanguage.rawValue,
                targetLanguageCode: targetLanguage.rawValue
            ),
            inputConfig: GoogleCloudGlossary.InputConfig(
                gcsSource: GoogleCloudGlossary.InputConfig.GCSSource(
                    inputUri: "gs://\(glossaryBucket)/\(glossaryFile)"
                )
            )
        )
    }

    /// Create multi-language glossary
    public func createMultiLanguageGlossary(
        name: String,
        languages: [LanguageCode],
        glossaryFile: String
    ) -> GoogleCloudGlossary {
        GoogleCloudGlossary(
            name: name,
            projectID: projectID,
            location: location,
            languageCodesSet: GoogleCloudGlossary.LanguageCodesSet(
                languageCodes: languages.map { $0.rawValue }
            ),
            inputConfig: GoogleCloudGlossary.InputConfig(
                gcsSource: GoogleCloudGlossary.InputConfig.GCSSource(
                    inputUri: "gs://\(glossaryBucket)/\(glossaryFile)"
                )
            )
        )
    }

    /// Batch translation job
    public func batchTranslate(
        inputUri: String,
        outputUri: String,
        targetLanguages: [LanguageCode]
    ) -> GoogleCloudBatchTranslation {
        GoogleCloudBatchTranslation(
            projectID: projectID,
            location: location,
            sourceLanguageCode: defaultSourceLanguage.rawValue,
            targetLanguageCodes: targetLanguages.map { $0.rawValue },
            inputConfigs: [
                GoogleCloudBatchTranslation.InputConfig(
                    mimeType: .plainText,
                    gcsSource: GoogleCloudBatchTranslation.InputConfig.GCSSource(inputUri: inputUri)
                )
            ],
            outputConfig: GoogleCloudBatchTranslation.OutputConfig(
                gcsDestination: GoogleCloudBatchTranslation.OutputConfig.GCSDestination(
                    outputUriPrefix: outputUri
                )
            )
        )
    }

    /// Document translation
    public func translateDocument(
        inputUri: String,
        outputUri: String,
        targetLanguage: LanguageCode,
        mimeType: String = "application/pdf"
    ) -> GoogleCloudDocumentTranslation {
        GoogleCloudDocumentTranslation(
            projectID: projectID,
            location: location,
            sourceLanguageCode: defaultSourceLanguage.rawValue,
            targetLanguageCode: targetLanguage.rawValue,
            documentInputConfig: GoogleCloudDocumentTranslation.DocumentInputConfig(
                mimeType: mimeType,
                gcsSource: GoogleCloudDocumentTranslation.DocumentInputConfig.GCSSource(inputUri: inputUri)
            ),
            documentOutputConfig: GoogleCloudDocumentTranslation.DocumentOutputConfig(
                gcsDestination: GoogleCloudDocumentTranslation.DocumentOutputConfig.GCSDestination(
                    outputUriPrefix: outputUri
                )
            )
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        # DAIS Translation Setup

        PROJECT_ID="\(projectID)"

        # Enable Translation API
        gcloud services enable translate.googleapis.com --project=$PROJECT_ID

        # Create service account
        gcloud iam service-accounts create \(serviceAccount) \\
            --display-name="Translation Service Account" \\
            --project=$PROJECT_ID

        # Grant Translation user role
        gcloud projects add-iam-policy-binding $PROJECT_ID \\
            --member="serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com" \\
            --role="roles/cloudtranslate.user"

        # Create glossary bucket
        gsutil mb -p $PROJECT_ID -l \(location) gs://\(glossaryBucket)

        # Grant storage access
        gsutil iam ch serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com:objectAdmin gs://\(glossaryBucket)

        echo "Translation setup complete!"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        # DAIS Translation Teardown

        PROJECT_ID="\(projectID)"

        # Delete glossary bucket
        gsutil rm -r gs://\(glossaryBucket) || true

        # Delete service account
        gcloud iam service-accounts delete \(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com \\
            --quiet --project=$PROJECT_ID || true

        echo "Translation resources cleaned up!"
        """
    }

    /// Python translation script
    public var pythonScript: String {
        """
        from google.cloud import translate_v2 as translate
        from google.cloud import translate_v3 as translate_v3

        def translate_text(text, target_language, source_language=None):
            \"\"\"Translates text to target language.\"\"\"
            client = translate.Client()

            result = client.translate(
                text,
                target_language=target_language,
                source_language=source_language
            )

            print(f"Original: {result['input']}")
            print(f"Translation: {result['translatedText']}")
            print(f"Detected source: {result.get('detectedSourceLanguage', source_language)}")

            return result['translatedText']

        def detect_language(text):
            \"\"\"Detects the language of the text.\"\"\"
            client = translate.Client()
            result = client.detect_language(text)

            print(f"Text: {text}")
            print(f"Detected: {result['language']} (confidence: {result['confidence']:.2%})")

            return result['language']

        def list_languages(display_language='en'):
            \"\"\"Lists available languages.\"\"\"
            client = translate.Client()
            languages = client.get_languages(target_language=display_language)

            print(f"Supported languages ({len(languages)}):")
            for lang in languages[:10]:
                print(f"  {lang['language']}: {lang['name']}")

            return languages

        def translate_with_glossary(text, glossary_id, target_language):
            \"\"\"Translates with a glossary.\"\"\"
            client = translate_v3.TranslationServiceClient()
            parent = f"projects/\(projectID)/locations/\(location)"
            glossary = f"{parent}/glossaries/{glossary_id}"

            glossary_config = translate_v3.TranslateTextGlossaryConfig(glossary=glossary)

            response = client.translate_text(
                request={
                    "parent": parent,
                    "contents": [text],
                    "target_language_code": target_language,
                    "glossary_config": glossary_config,
                }
            )

            for translation in response.glossary_translations:
                print(f"Glossary translation: {translation.translated_text}")

            return response

        # Example usage
        if __name__ == "__main__":
            # Translate English to Spanish
            translate_text("Hello, how are you?", "es")

            # Detect language
            detect_language("Bonjour, comment allez-vous?")

            # List languages
            list_languages()
        """
    }

    /// Sample glossary CSV format
    public var sampleGlossaryCSV: String {
        """
        # Sample glossary file (TSV format for unidirectional glossary)
        # Upload to gs://\(glossaryBucket)/glossary.tsv

        Hello\tHola
        Goodbye\tAdiós
        Thank you\tGracias
        Welcome\tBienvenido
        """
    }
}
