// GoogleCloudDocumentAI.swift
// Document AI for intelligent document processing

import Foundation

// MARK: - Document AI Processor

/// A Document AI processor for processing documents
public struct GoogleCloudDocumentAIProcessor: Codable, Sendable, Equatable {
    /// Processor name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location (us, eu)
    public let location: String

    /// Processor type
    public let type: ProcessorType

    /// Display name
    public let displayName: String?

    /// Processor state
    public let state: ProcessorState?

    /// Default processor version
    public let defaultProcessorVersion: String?

    /// Create time
    public let createTime: String?

    /// Processor type
    public enum ProcessorType: String, Codable, Sendable {
        case ocrProcessor = "OCR_PROCESSOR"
        case formParser = "FORM_PARSER_PROCESSOR"
        case documentQuality = "DOCUMENT_QUALITY_PROCESSOR"
        case documentSplitter = "DOCUMENT_SPLITTER_PROCESSOR"
        case invoiceParser = "INVOICE_PROCESSOR"
        case expenseParser = "EXPENSE_PROCESSOR"
        case identityDocument = "ID_PROOFING_PROCESSOR"
        case contractParser = "CONTRACT_PROCESSOR"
        case lendingDocument = "LENDING_DOCUMENT_SPLIT_PROCESSOR"
        case w2Parser = "W2_PROCESSOR"
        case form1099Parser = "1099_PROCESSOR"
        case bankStatement = "BANK_STATEMENT_PROCESSOR"
        case payslipParser = "PAYSLIP_PROCESSOR"
        case custom = "CUSTOM_EXTRACTION_PROCESSOR"
        case classifierProcessor = "CUSTOM_CLASSIFICATION_PROCESSOR"
        case summarizerProcessor = "SUMMARIZER_PROCESSOR"
    }

    /// Processor state
    public enum ProcessorState: String, Codable, Sendable {
        case unspecified = "STATE_UNSPECIFIED"
        case enabled = "ENABLED"
        case disabled = "DISABLED"
        case creating = "CREATING"
        case failed = "FAILED"
        case deleting = "DELETING"
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        type: ProcessorType,
        displayName: String? = nil,
        state: ProcessorState? = nil,
        defaultProcessorVersion: String? = nil,
        createTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.type = type
        self.displayName = displayName
        self.state = state
        self.defaultProcessorVersion = defaultProcessorVersion
        self.createTime = createTime
    }

    /// Resource name for the processor
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/processors/\(name)"
    }

    /// Command to create the processor
    public var createCommand: String {
        var cmd = "gcloud documentai processors create --location=\(location) --type=\(type.rawValue) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }
        return cmd
    }

    /// Command to describe the processor
    public var describeCommand: String {
        "gcloud documentai processors describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to delete the processor
    public var deleteCommand: String {
        "gcloud documentai processors delete \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to enable the processor
    public var enableCommand: String {
        "gcloud documentai processors enable \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to disable the processor
    public var disableCommand: String {
        "gcloud documentai processors disable \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to list processors
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud documentai processors list --location=\(location) --project=\(projectID)"
    }

    /// Command to list processor types
    public static func listTypesCommand(projectID: String, location: String) -> String {
        "gcloud documentai processor-types list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Processor Version

/// A version of a Document AI processor
public struct GoogleCloudDocumentAIProcessorVersion: Codable, Sendable, Equatable {
    /// Version name
    public let name: String

    /// Processor name
    public let processorName: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String?

    /// Version state
    public let state: VersionState?

    /// Model type
    public let modelType: ModelType?

    /// Create time
    public let createTime: String?

    /// Version state
    public enum VersionState: String, Codable, Sendable {
        case unspecified = "STATE_UNSPECIFIED"
        case deployed = "DEPLOYED"
        case deploying = "DEPLOYING"
        case undeployed = "UNDEPLOYED"
        case undeploying = "UNDEPLOYING"
        case creating = "CREATING"
        case deleting = "DELETING"
        case failed = "FAILED"
        case importing = "IMPORTING"
    }

    /// Model type
    public enum ModelType: String, Codable, Sendable {
        case unspecified = "MODEL_TYPE_UNSPECIFIED"
        case generativeAI = "MODEL_TYPE_GENERATIVE"
        case custom = "MODEL_TYPE_CUSTOM"
    }

    public init(
        name: String,
        processorName: String,
        projectID: String,
        location: String,
        displayName: String? = nil,
        state: VersionState? = nil,
        modelType: ModelType? = nil,
        createTime: String? = nil
    ) {
        self.name = name
        self.processorName = processorName
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.state = state
        self.modelType = modelType
        self.createTime = createTime
    }

    /// Resource name for the version
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/processors/\(processorName)/processorVersions/\(name)"
    }

    /// Command to describe the version
    public var describeCommand: String {
        "gcloud documentai processors versions describe \(name) --processor=\(processorName) --location=\(location) --project=\(projectID)"
    }

    /// Command to list versions
    public static func listCommand(processorName: String, location: String, projectID: String) -> String {
        "gcloud documentai processors versions list --processor=\(processorName) --location=\(location) --project=\(projectID)"
    }

    /// Command to deploy version
    public var deployCommand: String {
        "gcloud documentai processors versions deploy \(name) --processor=\(processorName) --location=\(location) --project=\(projectID)"
    }

    /// Command to undeploy version
    public var undeployCommand: String {
        "gcloud documentai processors versions undeploy \(name) --processor=\(processorName) --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Document

/// A document to be processed
public struct GoogleCloudDocument: Codable, Sendable, Equatable {
    /// Document content (base64 encoded)
    public let content: String?

    /// MIME type
    public let mimeType: String

    /// GCS URI for the document
    public let gcsUri: String?

    /// Supported MIME types
    public enum MimeType: String, Codable, Sendable {
        case pdf = "application/pdf"
        case gif = "image/gif"
        case tiff = "image/tiff"
        case jpeg = "image/jpeg"
        case png = "image/png"
        case bmp = "image/bmp"
        case webp = "image/webp"
    }

    public init(
        content: String? = nil,
        mimeType: String,
        gcsUri: String? = nil
    ) {
        self.content = content
        self.mimeType = mimeType
        self.gcsUri = gcsUri
    }

    /// Create from GCS URI
    public static func fromGCS(uri: String, mimeType: MimeType) -> GoogleCloudDocument {
        GoogleCloudDocument(
            content: nil,
            mimeType: mimeType.rawValue,
            gcsUri: uri
        )
    }
}

// MARK: - Process Request

/// A request to process a document
public struct GoogleCloudDocumentAIProcessRequest: Codable, Sendable, Equatable {
    /// Processor resource name
    public let processorName: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Document to process
    public let document: GoogleCloudDocument?

    /// GCS input URI
    public let inputGcsUri: String?

    /// GCS output URI
    public let outputGcsUri: String?

    /// Skip human review
    public let skipHumanReview: Bool

    /// Field mask for specific fields
    public let fieldMask: String?

    public init(
        processorName: String,
        projectID: String,
        location: String,
        document: GoogleCloudDocument? = nil,
        inputGcsUri: String? = nil,
        outputGcsUri: String? = nil,
        skipHumanReview: Bool = true,
        fieldMask: String? = nil
    ) {
        self.processorName = processorName
        self.projectID = projectID
        self.location = location
        self.document = document
        self.inputGcsUri = inputGcsUri
        self.outputGcsUri = outputGcsUri
        self.skipHumanReview = skipHumanReview
        self.fieldMask = fieldMask
    }

    /// Command to process a single document
    public func processCommand(inputFile: String) -> String {
        var cmd = "curl -X POST -H \"Authorization: Bearer $(gcloud auth print-access-token)\" "
        cmd += "-H \"Content-Type: application/json\" "
        cmd += "\"https://\(location)-documentai.googleapis.com/v1/projects/\(projectID)/locations/\(location)/processors/\(processorName):process\" "
        cmd += "-d '{\"rawDocument\": {\"mimeType\": \"\(document?.mimeType ?? "application/pdf")\", \"content\": \"'$(base64 -i \(inputFile))'\"}'"
        if skipHumanReview {
            cmd += ", \"skipHumanReview\": true"
        }
        cmd += "}'"
        return cmd
    }

    /// Command for batch processing
    public func batchProcessCommand() -> String {
        guard let inputUri = inputGcsUri, let outputUri = outputGcsUri else {
            return "# Error: inputGcsUri and outputGcsUri required for batch processing"
        }

        var cmd = "curl -X POST -H \"Authorization: Bearer $(gcloud auth print-access-token)\" "
        cmd += "-H \"Content-Type: application/json\" "
        cmd += "\"https://\(location)-documentai.googleapis.com/v1/projects/\(projectID)/locations/\(location)/processors/\(processorName):batchProcess\" "
        cmd += "-d '{\"inputDocuments\": {\"gcsPrefix\": {\"gcsUriPrefix\": \"\(inputUri)\"}}, "
        cmd += "\"documentOutputConfig\": {\"gcsOutputConfig\": {\"gcsUri\": \"\(outputUri)\"}}'"
        if skipHumanReview {
            cmd += ", \"skipHumanReview\": true"
        }
        cmd += "}'"
        return cmd
    }
}

// MARK: - Process Response

/// Response from document processing
public struct GoogleCloudDocumentAIProcessResponse: Codable, Sendable, Equatable {
    /// Processed document
    public let document: ProcessedDocument?

    /// Human review status
    public let humanReviewStatus: HumanReviewStatus?

    /// Processed document structure
    public struct ProcessedDocument: Codable, Sendable, Equatable {
        /// Extracted text
        public let text: String?

        /// Pages in the document
        public let pages: [Page]?

        /// Entities extracted
        public let entities: [Entity]?

        /// Errors
        public let errors: [ProcessError]?

        public init(
            text: String? = nil,
            pages: [Page]? = nil,
            entities: [Entity]? = nil,
            errors: [ProcessError]? = nil
        ) {
            self.text = text
            self.pages = pages
            self.entities = entities
            self.errors = errors
        }
    }

    /// A page in the document
    public struct Page: Codable, Sendable, Equatable {
        /// Page number
        public let pageNumber: Int?

        /// Detected languages
        public let detectedLanguages: [DetectedLanguage]?

        /// Blocks on the page
        public let blocks: [Block]?

        /// Paragraphs
        public let paragraphs: [Paragraph]?

        /// Tables
        public let tables: [Table]?

        /// Form fields
        public let formFields: [FormField]?

        public init(
            pageNumber: Int? = nil,
            detectedLanguages: [DetectedLanguage]? = nil,
            blocks: [Block]? = nil,
            paragraphs: [Paragraph]? = nil,
            tables: [Table]? = nil,
            formFields: [FormField]? = nil
        ) {
            self.pageNumber = pageNumber
            self.detectedLanguages = detectedLanguages
            self.blocks = blocks
            self.paragraphs = paragraphs
            self.tables = tables
            self.formFields = formFields
        }
    }

    /// Detected language
    public struct DetectedLanguage: Codable, Sendable, Equatable {
        public let languageCode: String
        public let confidence: Double

        public init(languageCode: String, confidence: Double) {
            self.languageCode = languageCode
            self.confidence = confidence
        }
    }

    /// A block of content
    public struct Block: Codable, Sendable, Equatable {
        public let textAnchor: TextAnchor?
        public let confidence: Double?

        public init(textAnchor: TextAnchor? = nil, confidence: Double? = nil) {
            self.textAnchor = textAnchor
            self.confidence = confidence
        }
    }

    /// A paragraph
    public struct Paragraph: Codable, Sendable, Equatable {
        public let textAnchor: TextAnchor?
        public let confidence: Double?

        public init(textAnchor: TextAnchor? = nil, confidence: Double? = nil) {
            self.textAnchor = textAnchor
            self.confidence = confidence
        }
    }

    /// A table
    public struct Table: Codable, Sendable, Equatable {
        public let headerRows: [TableRow]?
        public let bodyRows: [TableRow]?

        public init(headerRows: [TableRow]? = nil, bodyRows: [TableRow]? = nil) {
            self.headerRows = headerRows
            self.bodyRows = bodyRows
        }
    }

    /// A table row
    public struct TableRow: Codable, Sendable, Equatable {
        public let cells: [TableCell]?

        public init(cells: [TableCell]? = nil) {
            self.cells = cells
        }
    }

    /// A table cell
    public struct TableCell: Codable, Sendable, Equatable {
        public let textAnchor: TextAnchor?
        public let rowSpan: Int?
        public let colSpan: Int?

        public init(textAnchor: TextAnchor? = nil, rowSpan: Int? = nil, colSpan: Int? = nil) {
            self.textAnchor = textAnchor
            self.rowSpan = rowSpan
            self.colSpan = colSpan
        }
    }

    /// A form field
    public struct FormField: Codable, Sendable, Equatable {
        public let fieldName: TextAnchor?
        public let fieldValue: TextAnchor?
        public let confidence: Double?

        public init(fieldName: TextAnchor? = nil, fieldValue: TextAnchor? = nil, confidence: Double? = nil) {
            self.fieldName = fieldName
            self.fieldValue = fieldValue
            self.confidence = confidence
        }
    }

    /// Text anchor
    public struct TextAnchor: Codable, Sendable, Equatable {
        public let textSegments: [TextSegment]?
        public let content: String?

        public init(textSegments: [TextSegment]? = nil, content: String? = nil) {
            self.textSegments = textSegments
            self.content = content
        }
    }

    /// Text segment
    public struct TextSegment: Codable, Sendable, Equatable {
        public let startIndex: Int
        public let endIndex: Int

        public init(startIndex: Int, endIndex: Int) {
            self.startIndex = startIndex
            self.endIndex = endIndex
        }
    }

    /// Entity extracted from document
    public struct Entity: Codable, Sendable, Equatable {
        public let type: String
        public let mentionText: String?
        public let confidence: Double?
        public let normalizedValue: NormalizedValue?

        public init(
            type: String,
            mentionText: String? = nil,
            confidence: Double? = nil,
            normalizedValue: NormalizedValue? = nil
        ) {
            self.type = type
            self.mentionText = mentionText
            self.confidence = confidence
            self.normalizedValue = normalizedValue
        }
    }

    /// Normalized value
    public struct NormalizedValue: Codable, Sendable, Equatable {
        public let text: String?
        public let moneyValue: MoneyValue?
        public let dateValue: DateValue?

        public init(text: String? = nil, moneyValue: MoneyValue? = nil, dateValue: DateValue? = nil) {
            self.text = text
            self.moneyValue = moneyValue
            self.dateValue = dateValue
        }
    }

    /// Money value
    public struct MoneyValue: Codable, Sendable, Equatable {
        public let currencyCode: String
        public let units: Int64?
        public let nanos: Int32?

        public init(currencyCode: String, units: Int64? = nil, nanos: Int32? = nil) {
            self.currencyCode = currencyCode
            self.units = units
            self.nanos = nanos
        }
    }

    /// Date value
    public struct DateValue: Codable, Sendable, Equatable {
        public let year: Int
        public let month: Int
        public let day: Int

        public init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
    }

    /// Process error
    public struct ProcessError: Codable, Sendable, Equatable {
        public let message: String
        public let code: Int?

        public init(message: String, code: Int? = nil) {
            self.message = message
            self.code = code
        }
    }

    /// Human review status
    public struct HumanReviewStatus: Codable, Sendable, Equatable {
        public let state: State
        public let stateMessage: String?

        public enum State: String, Codable, Sendable {
            case unspecified = "STATE_UNSPECIFIED"
            case skipped = "SKIPPED"
            case validationPassed = "VALIDATION_PASSED"
            case inProgress = "IN_PROGRESS"
            case error = "ERROR"
        }

        public init(state: State, stateMessage: String? = nil) {
            self.state = state
            self.stateMessage = stateMessage
        }
    }

    public init(
        document: ProcessedDocument? = nil,
        humanReviewStatus: HumanReviewStatus? = nil
    ) {
        self.document = document
        self.humanReviewStatus = humanReviewStatus
    }
}

// MARK: - Human Review Config

/// Configuration for human review
public struct GoogleCloudDocumentAIHumanReviewConfig: Codable, Sendable, Equatable {
    /// Processor name
    public let processorName: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Review enabled
    public let enabled: Bool

    public init(
        processorName: String,
        projectID: String,
        location: String,
        enabled: Bool = true
    ) {
        self.processorName = processorName
        self.projectID = projectID
        self.location = location
        self.enabled = enabled
    }

    /// Command to update human review config
    public var updateCommand: String {
        let stateStr = enabled ? "ENABLED" : "DISABLED"
        return "curl -X PATCH -H \"Authorization: Bearer $(gcloud auth print-access-token)\" " +
            "-H \"Content-Type: application/json\" " +
            "\"https://\(location)-documentai.googleapis.com/v1/projects/\(projectID)/locations/\(location)/processors/\(processorName)/humanReviewConfig\" " +
            "-d '{\"state\": \"\(stateStr)\"}'"
    }
}

// MARK: - Evaluation

/// Evaluation of a processor version
public struct GoogleCloudDocumentAIEvaluation: Codable, Sendable, Equatable {
    /// Processor name
    public let processorName: String

    /// Version name
    public let versionName: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// All entities evaluation
    public let allEntitiesMetrics: EvaluationMetrics?

    /// Entity-specific evaluations
    public let entityMetrics: [String: EvaluationMetrics]?

    /// Evaluation metrics
    public struct EvaluationMetrics: Codable, Sendable, Equatable {
        public let precision: Double?
        public let recall: Double?
        public let f1Score: Double?
        public let predictedDocumentCount: Int?
        public let groundTruthDocumentCount: Int?

        public init(
            precision: Double? = nil,
            recall: Double? = nil,
            f1Score: Double? = nil,
            predictedDocumentCount: Int? = nil,
            groundTruthDocumentCount: Int? = nil
        ) {
            self.precision = precision
            self.recall = recall
            self.f1Score = f1Score
            self.predictedDocumentCount = predictedDocumentCount
            self.groundTruthDocumentCount = groundTruthDocumentCount
        }
    }

    public init(
        processorName: String,
        versionName: String,
        projectID: String,
        location: String,
        allEntitiesMetrics: EvaluationMetrics? = nil,
        entityMetrics: [String: EvaluationMetrics]? = nil
    ) {
        self.processorName = processorName
        self.versionName = versionName
        self.projectID = projectID
        self.location = location
        self.allEntitiesMetrics = allEntitiesMetrics
        self.entityMetrics = entityMetrics
    }

    /// Command to list evaluations
    public var listCommand: String {
        "gcloud documentai processors versions evaluations list --processor=\(processorName) --processor-version=\(versionName) --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Document AI Operations

/// Operations for Document AI
public struct DocumentAIOperations: Sendable {
    private init() {}

    /// Enable Document AI API
    public static var enableAPICommand: String {
        "gcloud services enable documentai.googleapis.com"
    }

    /// List all processors
    public static func listProcessorsCommand(projectID: String, location: String) -> String {
        "gcloud documentai processors list --location=\(location) --project=\(projectID)"
    }

    /// List processor types
    public static func listProcessorTypesCommand(projectID: String, location: String) -> String {
        "gcloud documentai processor-types list --location=\(location) --project=\(projectID)"
    }

    /// Get operation status
    public static func getOperationCommand(operationName: String) -> String {
        "gcloud documentai operations describe \(operationName)"
    }

    /// Add editor role
    public static func addEditorRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\"\(member)\" --role=\"roles/documentai.editor\""
    }

    /// Add admin role
    public static func addAdminRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\"\(member)\" --role=\"roles/documentai.admin\""
    }

    /// Add viewer role
    public static func addViewerRoleCommand(projectID: String, member: String) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\"\(member)\" --role=\"roles/documentai.viewer\""
    }
}

// MARK: - DAIS Document AI Template

/// DAIS template for Document AI processing pipelines
public struct DAISDocumentAITemplate: Sendable {
    /// Project ID
    public let projectID: String

    /// Location (us, eu)
    public let location: String

    /// Processor name prefix
    public let processorPrefix: String

    /// Service account email
    public let serviceAccount: String

    /// GCS bucket for documents
    public let documentBucket: String

    public init(
        projectID: String,
        location: String = "us",
        processorPrefix: String = "dais",
        serviceAccount: String,
        documentBucket: String
    ) {
        self.projectID = projectID
        self.location = location
        self.processorPrefix = processorPrefix
        self.serviceAccount = serviceAccount
        self.documentBucket = documentBucket
    }

    /// OCR processor for text extraction
    public var ocrProcessor: GoogleCloudDocumentAIProcessor {
        GoogleCloudDocumentAIProcessor(
            name: "\(processorPrefix)-ocr",
            projectID: projectID,
            location: location,
            type: .ocrProcessor,
            displayName: "DAIS OCR Processor"
        )
    }

    /// Form parser processor
    public var formParserProcessor: GoogleCloudDocumentAIProcessor {
        GoogleCloudDocumentAIProcessor(
            name: "\(processorPrefix)-form-parser",
            projectID: projectID,
            location: location,
            type: .formParser,
            displayName: "DAIS Form Parser"
        )
    }

    /// Invoice parser processor
    public var invoiceProcessor: GoogleCloudDocumentAIProcessor {
        GoogleCloudDocumentAIProcessor(
            name: "\(processorPrefix)-invoice",
            projectID: projectID,
            location: location,
            type: .invoiceParser,
            displayName: "DAIS Invoice Parser"
        )
    }

    /// Document quality processor
    public var qualityProcessor: GoogleCloudDocumentAIProcessor {
        GoogleCloudDocumentAIProcessor(
            name: "\(processorPrefix)-quality",
            projectID: projectID,
            location: location,
            type: .documentQuality,
            displayName: "DAIS Document Quality Checker"
        )
    }

    /// Custom extraction processor
    public var customProcessor: GoogleCloudDocumentAIProcessor {
        GoogleCloudDocumentAIProcessor(
            name: "\(processorPrefix)-custom",
            projectID: projectID,
            location: location,
            type: .custom,
            displayName: "DAIS Custom Extractor"
        )
    }

    /// Process request for OCR
    public func ocrRequest(gcsUri: String) -> GoogleCloudDocumentAIProcessRequest {
        GoogleCloudDocumentAIProcessRequest(
            processorName: "\(processorPrefix)-ocr",
            projectID: projectID,
            location: location,
            document: GoogleCloudDocument.fromGCS(uri: gcsUri, mimeType: .pdf),
            skipHumanReview: true
        )
    }

    /// Batch process request
    public func batchProcessRequest(inputPrefix: String, outputPrefix: String) -> GoogleCloudDocumentAIProcessRequest {
        GoogleCloudDocumentAIProcessRequest(
            processorName: "\(processorPrefix)-ocr",
            projectID: projectID,
            location: location,
            inputGcsUri: "gs://\(documentBucket)/\(inputPrefix)",
            outputGcsUri: "gs://\(documentBucket)/\(outputPrefix)",
            skipHumanReview: true
        )
    }

    /// Setup script for Document AI infrastructure
    public var setupScript: String {
        """
        #!/bin/bash
        set -e

        # Enable Document AI API
        gcloud services enable documentai.googleapis.com --project=\(projectID)

        # Create GCS bucket for documents
        gsutil mb -p \(projectID) -l \(location.uppercased()) gs://\(documentBucket)/ || true

        # Grant service account access
        gsutil iam ch serviceAccount:\(serviceAccount):objectAdmin gs://\(documentBucket)/

        # Create OCR processor
        gcloud documentai processors create \\
            --location=\(location) \\
            --type=OCR_PROCESSOR \\
            --display-name="DAIS OCR Processor" \\
            --project=\(projectID) || true

        # Create Form Parser processor
        gcloud documentai processors create \\
            --location=\(location) \\
            --type=FORM_PARSER_PROCESSOR \\
            --display-name="DAIS Form Parser" \\
            --project=\(projectID) || true

        # Create Invoice processor
        gcloud documentai processors create \\
            --location=\(location) \\
            --type=INVOICE_PROCESSOR \\
            --display-name="DAIS Invoice Parser" \\
            --project=\(projectID) || true

        # Create Document Quality processor
        gcloud documentai processors create \\
            --location=\(location) \\
            --type=DOCUMENT_QUALITY_PROCESSOR \\
            --display-name="DAIS Document Quality Checker" \\
            --project=\(projectID) || true

        # Grant Document AI roles to service account
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccount)" \\
            --role="roles/documentai.editor"

        echo "Document AI infrastructure created successfully"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -e

        # Delete processors (requires manual confirmation in gcloud)
        echo "Delete processors manually using:"
        echo "gcloud documentai processors list --location=\(location) --project=\(projectID)"
        echo "gcloud documentai processors delete PROCESSOR_ID --location=\(location) --project=\(projectID)"

        # Delete GCS bucket
        gsutil rm -r gs://\(documentBucket)/ || true

        echo "Document AI teardown complete"
        """
    }

    /// Python script for document processing
    public var pythonProcessingScript: String {
        """
        from google.cloud import documentai_v1 as documentai
        from google.cloud import storage
        import json

        def process_document(
            project_id: str,
            location: str,
            processor_id: str,
            file_path: str,
            mime_type: str = "application/pdf"
        ) -> documentai.Document:
            \"\"\"Process a document using Document AI.\"\"\"

            client = documentai.DocumentProcessorServiceClient()

            # Read the file
            with open(file_path, "rb") as f:
                content = f.read()

            # Create the document
            raw_document = documentai.RawDocument(content=content, mime_type=mime_type)

            # Process the document
            name = client.processor_path(project_id, location, processor_id)
            request = documentai.ProcessRequest(name=name, raw_document=raw_document)

            result = client.process_document(request=request)
            return result.document

        def extract_entities(document: documentai.Document) -> list:
            \"\"\"Extract entities from processed document.\"\"\"
            entities = []
            for entity in document.entities:
                entities.append({
                    "type": entity.type_,
                    "mention_text": entity.mention_text,
                    "confidence": entity.confidence,
                    "normalized_value": entity.normalized_value.text if entity.normalized_value else None
                })
            return entities

        def extract_form_fields(document: documentai.Document) -> list:
            \"\"\"Extract form fields from processed document.\"\"\"
            fields = []
            for page in document.pages:
                for field in page.form_fields:
                    field_name = get_text_from_layout(field.field_name, document.text)
                    field_value = get_text_from_layout(field.field_value, document.text)
                    fields.append({
                        "name": field_name,
                        "value": field_value,
                        "confidence": field.field_value.confidence
                    })
            return fields

        def get_text_from_layout(layout, full_text: str) -> str:
            \"\"\"Extract text from a layout element.\"\"\"
            if not layout.text_anchor.text_segments:
                return ""
            text = ""
            for segment in layout.text_anchor.text_segments:
                start = int(segment.start_index) if segment.start_index else 0
                end = int(segment.end_index)
                text += full_text[start:end]
            return text.strip()

        if __name__ == "__main__":
            document = process_document(
                project_id="\(projectID)",
                location="\(location)",
                processor_id="PROCESSOR_ID",  # Replace with actual processor ID
                file_path="document.pdf"
            )

            print(f"Text: {document.text[:500]}...")
            print(f"Entities: {json.dumps(extract_entities(document), indent=2)}")
        """
    }
}
