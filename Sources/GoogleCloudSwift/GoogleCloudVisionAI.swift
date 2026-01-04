// GoogleCloudVisionAI.swift
// Cloud Vision AI for image analysis and understanding

import Foundation

// MARK: - Vision Request

/// A request to analyze an image with Vision AI
public struct GoogleCloudVisionRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Image source
    public let image: ImageSource

    /// Features to detect
    public let features: [Feature]

    /// Image context (optional hints)
    public let imageContext: ImageContext?

    /// Image source
    public struct ImageSource: Codable, Sendable, Equatable {
        /// Base64-encoded image content
        public let content: String?

        /// GCS URI for the image
        public let gcsUri: String?

        /// Image URL
        public let imageUri: String?

        public init(
            content: String? = nil,
            gcsUri: String? = nil,
            imageUri: String? = nil
        ) {
            self.content = content
            self.gcsUri = gcsUri
            self.imageUri = imageUri
        }

        /// Create from GCS URI
        public static func fromGCS(_ uri: String) -> ImageSource {
            ImageSource(gcsUri: uri)
        }

        /// Create from URL
        public static func fromURL(_ url: String) -> ImageSource {
            ImageSource(imageUri: url)
        }
    }

    /// A feature to detect
    public struct Feature: Codable, Sendable, Equatable {
        /// Feature type
        public let type: FeatureType

        /// Maximum results to return
        public let maxResults: Int?

        /// Model (for specific features)
        public let model: String?

        public init(
            type: FeatureType,
            maxResults: Int? = nil,
            model: String? = nil
        ) {
            self.type = type
            self.maxResults = maxResults
            self.model = model
        }
    }

    /// Feature type enum
    public enum FeatureType: String, Codable, Sendable {
        case faceDetection = "FACE_DETECTION"
        case landmarkDetection = "LANDMARK_DETECTION"
        case logoDetection = "LOGO_DETECTION"
        case labelDetection = "LABEL_DETECTION"
        case textDetection = "TEXT_DETECTION"
        case documentTextDetection = "DOCUMENT_TEXT_DETECTION"
        case safeSearchDetection = "SAFE_SEARCH_DETECTION"
        case imageProperties = "IMAGE_PROPERTIES"
        case cropHints = "CROP_HINTS"
        case webDetection = "WEB_DETECTION"
        case productSearch = "PRODUCT_SEARCH"
        case objectLocalization = "OBJECT_LOCALIZATION"
    }

    /// Image context for hints
    public struct ImageContext: Codable, Sendable, Equatable {
        /// Language hints
        public let languageHints: [String]?

        /// Crop hints parameters
        public let cropHintsParams: CropHintsParams?

        /// Product search parameters
        public let productSearchParams: ProductSearchParams?

        /// Web detection parameters
        public let webDetectionParams: WebDetectionParams?

        public init(
            languageHints: [String]? = nil,
            cropHintsParams: CropHintsParams? = nil,
            productSearchParams: ProductSearchParams? = nil,
            webDetectionParams: WebDetectionParams? = nil
        ) {
            self.languageHints = languageHints
            self.cropHintsParams = cropHintsParams
            self.productSearchParams = productSearchParams
            self.webDetectionParams = webDetectionParams
        }
    }

    /// Crop hints parameters
    public struct CropHintsParams: Codable, Sendable, Equatable {
        public let aspectRatios: [Double]?

        public init(aspectRatios: [Double]? = nil) {
            self.aspectRatios = aspectRatios
        }
    }

    /// Product search parameters
    public struct ProductSearchParams: Codable, Sendable, Equatable {
        public let productSet: String?
        public let productCategories: [String]?
        public let filter: String?

        public init(
            productSet: String? = nil,
            productCategories: [String]? = nil,
            filter: String? = nil
        ) {
            self.productSet = productSet
            self.productCategories = productCategories
            self.filter = filter
        }
    }

    /// Web detection parameters
    public struct WebDetectionParams: Codable, Sendable, Equatable {
        public let includeGeoResults: Bool?

        public init(includeGeoResults: Bool? = nil) {
            self.includeGeoResults = includeGeoResults
        }
    }

    public init(
        projectID: String,
        image: ImageSource,
        features: [Feature],
        imageContext: ImageContext? = nil
    ) {
        self.projectID = projectID
        self.image = image
        self.features = features
        self.imageContext = imageContext
    }

    /// Command to annotate image (uses first feature type for gcloud command)
    public var annotateCommand: String {
        if let gcsUri = image.gcsUri {
            let featureType = features.first?.type ?? .labelDetection
            switch featureType {
            case .labelDetection:
                return "gcloud ml vision detect-labels \(gcsUri) --project=\(projectID)"
            case .textDetection:
                return "gcloud ml vision detect-text \(gcsUri) --project=\(projectID)"
            case .faceDetection:
                return "gcloud ml vision detect-faces \(gcsUri) --project=\(projectID)"
            case .landmarkDetection:
                return "gcloud ml vision detect-landmarks \(gcsUri) --project=\(projectID)"
            case .logoDetection:
                return "gcloud ml vision detect-logos \(gcsUri) --project=\(projectID)"
            case .safeSearchDetection:
                return "gcloud ml vision detect-safe-search \(gcsUri) --project=\(projectID)"
            case .objectLocalization:
                return "gcloud ml vision detect-objects \(gcsUri) --project=\(projectID)"
            case .documentTextDetection:
                return "gcloud ml vision detect-document \(gcsUri) --project=\(projectID)"
            case .webDetection:
                return "gcloud ml vision detect-web \(gcsUri) --project=\(projectID)"
            case .imageProperties:
                return "gcloud ml vision detect-image-properties \(gcsUri) --project=\(projectID)"
            case .cropHints:
                return "gcloud ml vision suggest-crop \(gcsUri) --project=\(projectID)"
            case .productSearch:
                return "# Use Vision API client library for product search"
            }
        }
        return "# Use Vision API client library for base64 content"
    }

    /// Command using curl
    public func curlCommand(inputFile: String) -> String {
        let featuresJSON = features.map { feature in
            var json = "{\"type\": \"\(feature.type.rawValue)\""
            if let maxResults = feature.maxResults {
                json += ", \"maxResults\": \(maxResults)"
            }
            json += "}"
            return json
        }.joined(separator: ", ")

        return """
        curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
          -H "Content-Type: application/json" \\
          "https://vision.googleapis.com/v1/images:annotate" \\
          -d '{
            "requests": [{
              "image": {"content": "'$(base64 -i \(inputFile))'"},
              "features": [\(featuresJSON)]
            }]
          }'
        """
    }
}

// MARK: - Vision Response

/// Response from Vision AI analysis
public struct GoogleCloudVisionResponse: Codable, Sendable, Equatable {
    /// Face annotations
    public let faceAnnotations: [FaceAnnotation]?

    /// Landmark annotations
    public let landmarkAnnotations: [EntityAnnotation]?

    /// Logo annotations
    public let logoAnnotations: [EntityAnnotation]?

    /// Label annotations
    public let labelAnnotations: [EntityAnnotation]?

    /// Text annotations
    public let textAnnotations: [EntityAnnotation]?

    /// Full text annotation
    public let fullTextAnnotation: TextAnnotation?

    /// Safe search annotation
    public let safeSearchAnnotation: SafeSearchAnnotation?

    /// Image properties annotation
    public let imagePropertiesAnnotation: ImagePropertiesAnnotation?

    /// Crop hints annotation
    public let cropHintsAnnotation: CropHintsAnnotation?

    /// Web detection
    public let webDetection: WebDetection?

    /// Localized object annotations
    public let localizedObjectAnnotations: [LocalizedObjectAnnotation]?

    /// Error
    public let error: VisionError?

    public init(
        faceAnnotations: [FaceAnnotation]? = nil,
        landmarkAnnotations: [EntityAnnotation]? = nil,
        logoAnnotations: [EntityAnnotation]? = nil,
        labelAnnotations: [EntityAnnotation]? = nil,
        textAnnotations: [EntityAnnotation]? = nil,
        fullTextAnnotation: TextAnnotation? = nil,
        safeSearchAnnotation: SafeSearchAnnotation? = nil,
        imagePropertiesAnnotation: ImagePropertiesAnnotation? = nil,
        cropHintsAnnotation: CropHintsAnnotation? = nil,
        webDetection: WebDetection? = nil,
        localizedObjectAnnotations: [LocalizedObjectAnnotation]? = nil,
        error: VisionError? = nil
    ) {
        self.faceAnnotations = faceAnnotations
        self.landmarkAnnotations = landmarkAnnotations
        self.logoAnnotations = logoAnnotations
        self.labelAnnotations = labelAnnotations
        self.textAnnotations = textAnnotations
        self.fullTextAnnotation = fullTextAnnotation
        self.safeSearchAnnotation = safeSearchAnnotation
        self.imagePropertiesAnnotation = imagePropertiesAnnotation
        self.cropHintsAnnotation = cropHintsAnnotation
        self.webDetection = webDetection
        self.localizedObjectAnnotations = localizedObjectAnnotations
        self.error = error
    }
}

// MARK: - Face Annotation

/// Face detection result
public struct FaceAnnotation: Codable, Sendable, Equatable {
    /// Bounding polygon
    public let boundingPoly: BoundingPoly?

    /// Face bounding polygon
    public let fdBoundingPoly: BoundingPoly?

    /// Face landmarks
    public let landmarks: [Landmark]?

    /// Roll angle
    public let rollAngle: Double?

    /// Pan angle
    public let panAngle: Double?

    /// Tilt angle
    public let tiltAngle: Double?

    /// Detection confidence
    public let detectionConfidence: Double?

    /// Landmarking confidence
    public let landmarkingConfidence: Double?

    /// Joy likelihood
    public let joyLikelihood: Likelihood?

    /// Sorrow likelihood
    public let sorrowLikelihood: Likelihood?

    /// Anger likelihood
    public let angerLikelihood: Likelihood?

    /// Surprise likelihood
    public let surpriseLikelihood: Likelihood?

    /// Under exposed likelihood
    public let underExposedLikelihood: Likelihood?

    /// Blurred likelihood
    public let blurredLikelihood: Likelihood?

    /// Headwear likelihood
    public let headwearLikelihood: Likelihood?

    /// Face landmark
    public struct Landmark: Codable, Sendable, Equatable {
        public let type: LandmarkType
        public let position: Position

        public enum LandmarkType: String, Codable, Sendable {
            case unknownLandmark = "UNKNOWN_LANDMARK"
            case leftEye = "LEFT_EYE"
            case rightEye = "RIGHT_EYE"
            case leftEyebrowUpperMidpoint = "LEFT_EYEBROW_UPPER_MIDPOINT"
            case rightEyebrowUpperMidpoint = "RIGHT_EYEBROW_UPPER_MIDPOINT"
            case leftEarTragion = "LEFT_EAR_TRAGION"
            case rightEarTragion = "RIGHT_EAR_TRAGION"
            case noseTip = "NOSE_TIP"
            case upperLip = "UPPER_LIP"
            case lowerLip = "LOWER_LIP"
            case mouthLeft = "MOUTH_LEFT"
            case mouthRight = "MOUTH_RIGHT"
            case mouthCenter = "MOUTH_CENTER"
            case noseBottomRight = "NOSE_BOTTOM_RIGHT"
            case noseBottomLeft = "NOSE_BOTTOM_LEFT"
            case noseBottomCenter = "NOSE_BOTTOM_CENTER"
            case leftEyeTopBoundary = "LEFT_EYE_TOP_BOUNDARY"
            case leftEyeRightCorner = "LEFT_EYE_RIGHT_CORNER"
            case leftEyeBottomBoundary = "LEFT_EYE_BOTTOM_BOUNDARY"
            case leftEyeLeftCorner = "LEFT_EYE_LEFT_CORNER"
            case rightEyeTopBoundary = "RIGHT_EYE_TOP_BOUNDARY"
            case rightEyeRightCorner = "RIGHT_EYE_RIGHT_CORNER"
            case rightEyeBottomBoundary = "RIGHT_EYE_BOTTOM_BOUNDARY"
            case rightEyeLeftCorner = "RIGHT_EYE_LEFT_CORNER"
            case foreheadGlabella = "FOREHEAD_GLABELLA"
            case chinGnathion = "CHIN_GNATHION"
            case chinLeftGonion = "CHIN_LEFT_GONION"
            case chinRightGonion = "CHIN_RIGHT_GONION"
        }

        public init(type: LandmarkType, position: Position) {
            self.type = type
            self.position = position
        }
    }

    public init(
        boundingPoly: BoundingPoly? = nil,
        fdBoundingPoly: BoundingPoly? = nil,
        landmarks: [Landmark]? = nil,
        rollAngle: Double? = nil,
        panAngle: Double? = nil,
        tiltAngle: Double? = nil,
        detectionConfidence: Double? = nil,
        landmarkingConfidence: Double? = nil,
        joyLikelihood: Likelihood? = nil,
        sorrowLikelihood: Likelihood? = nil,
        angerLikelihood: Likelihood? = nil,
        surpriseLikelihood: Likelihood? = nil,
        underExposedLikelihood: Likelihood? = nil,
        blurredLikelihood: Likelihood? = nil,
        headwearLikelihood: Likelihood? = nil
    ) {
        self.boundingPoly = boundingPoly
        self.fdBoundingPoly = fdBoundingPoly
        self.landmarks = landmarks
        self.rollAngle = rollAngle
        self.panAngle = panAngle
        self.tiltAngle = tiltAngle
        self.detectionConfidence = detectionConfidence
        self.landmarkingConfidence = landmarkingConfidence
        self.joyLikelihood = joyLikelihood
        self.sorrowLikelihood = sorrowLikelihood
        self.angerLikelihood = angerLikelihood
        self.surpriseLikelihood = surpriseLikelihood
        self.underExposedLikelihood = underExposedLikelihood
        self.blurredLikelihood = blurredLikelihood
        self.headwearLikelihood = headwearLikelihood
    }
}

// MARK: - Entity Annotation

/// General entity annotation (labels, logos, landmarks, text)
public struct EntityAnnotation: Codable, Sendable, Equatable {
    /// Entity ID
    public let mid: String?

    /// Language code
    public let locale: String?

    /// Entity description
    public let description: String?

    /// Confidence score
    public let score: Double?

    /// Topicality score
    public let topicality: Double?

    /// Bounding polygon
    public let boundingPoly: BoundingPoly?

    /// Locations
    public let locations: [LocationInfo]?

    /// Properties
    public let properties: [Property]?

    /// Location info
    public struct LocationInfo: Codable, Sendable, Equatable {
        public let latLng: LatLng?

        public init(latLng: LatLng? = nil) {
            self.latLng = latLng
        }
    }

    /// Lat/Lng coordinates
    public struct LatLng: Codable, Sendable, Equatable {
        public let latitude: Double
        public let longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    /// Property key-value pair
    public struct Property: Codable, Sendable, Equatable {
        public let name: String
        public let value: String?
        public let uint64Value: UInt64?

        public init(name: String, value: String? = nil, uint64Value: UInt64? = nil) {
            self.name = name
            self.value = value
            self.uint64Value = uint64Value
        }
    }

    public init(
        mid: String? = nil,
        locale: String? = nil,
        description: String? = nil,
        score: Double? = nil,
        topicality: Double? = nil,
        boundingPoly: BoundingPoly? = nil,
        locations: [LocationInfo]? = nil,
        properties: [Property]? = nil
    ) {
        self.mid = mid
        self.locale = locale
        self.description = description
        self.score = score
        self.topicality = topicality
        self.boundingPoly = boundingPoly
        self.locations = locations
        self.properties = properties
    }
}

// MARK: - Text Annotation

/// Full text annotation from document text detection
public struct TextAnnotation: Codable, Sendable, Equatable {
    /// Pages
    public let pages: [Page]?

    /// Full text
    public let text: String?

    /// A page of text
    public struct Page: Codable, Sendable, Equatable {
        public let width: Int?
        public let height: Int?
        public let blocks: [Block]?
        public let confidence: Double?

        public init(width: Int? = nil, height: Int? = nil, blocks: [Block]? = nil, confidence: Double? = nil) {
            self.width = width
            self.height = height
            self.blocks = blocks
            self.confidence = confidence
        }
    }

    /// A block of text
    public struct Block: Codable, Sendable, Equatable {
        public let boundingBox: BoundingPoly?
        public let paragraphs: [Paragraph]?
        public let blockType: BlockType?
        public let confidence: Double?

        public enum BlockType: String, Codable, Sendable {
            case unknown = "UNKNOWN"
            case text = "TEXT"
            case table = "TABLE"
            case picture = "PICTURE"
            case ruler = "RULER"
            case barcode = "BARCODE"
        }

        public init(
            boundingBox: BoundingPoly? = nil,
            paragraphs: [Paragraph]? = nil,
            blockType: BlockType? = nil,
            confidence: Double? = nil
        ) {
            self.boundingBox = boundingBox
            self.paragraphs = paragraphs
            self.blockType = blockType
            self.confidence = confidence
        }
    }

    /// A paragraph of text
    public struct Paragraph: Codable, Sendable, Equatable {
        public let boundingBox: BoundingPoly?
        public let words: [Word]?
        public let confidence: Double?

        public init(boundingBox: BoundingPoly? = nil, words: [Word]? = nil, confidence: Double? = nil) {
            self.boundingBox = boundingBox
            self.words = words
            self.confidence = confidence
        }
    }

    /// A word
    public struct Word: Codable, Sendable, Equatable {
        public let boundingBox: BoundingPoly?
        public let symbols: [Symbol]?
        public let confidence: Double?

        public init(boundingBox: BoundingPoly? = nil, symbols: [Symbol]? = nil, confidence: Double? = nil) {
            self.boundingBox = boundingBox
            self.symbols = symbols
            self.confidence = confidence
        }
    }

    /// A symbol
    public struct Symbol: Codable, Sendable, Equatable {
        public let boundingBox: BoundingPoly?
        public let text: String?
        public let confidence: Double?

        public init(boundingBox: BoundingPoly? = nil, text: String? = nil, confidence: Double? = nil) {
            self.boundingBox = boundingBox
            self.text = text
            self.confidence = confidence
        }
    }

    public init(pages: [Page]? = nil, text: String? = nil) {
        self.pages = pages
        self.text = text
    }
}

// MARK: - Safe Search Annotation

/// Safe search detection result
public struct SafeSearchAnnotation: Codable, Sendable, Equatable {
    /// Adult content likelihood
    public let adult: Likelihood?

    /// Spoof likelihood
    public let spoof: Likelihood?

    /// Medical content likelihood
    public let medical: Likelihood?

    /// Violence likelihood
    public let violence: Likelihood?

    /// Racy content likelihood
    public let racy: Likelihood?

    public init(
        adult: Likelihood? = nil,
        spoof: Likelihood? = nil,
        medical: Likelihood? = nil,
        violence: Likelihood? = nil,
        racy: Likelihood? = nil
    ) {
        self.adult = adult
        self.spoof = spoof
        self.medical = medical
        self.violence = violence
        self.racy = racy
    }
}

// MARK: - Image Properties Annotation

/// Image properties annotation
public struct ImagePropertiesAnnotation: Codable, Sendable, Equatable {
    /// Dominant colors
    public let dominantColors: DominantColorsAnnotation?

    /// Dominant colors annotation
    public struct DominantColorsAnnotation: Codable, Sendable, Equatable {
        public let colors: [ColorInfo]?

        public init(colors: [ColorInfo]? = nil) {
            self.colors = colors
        }
    }

    /// Color info
    public struct ColorInfo: Codable, Sendable, Equatable {
        public let color: Color?
        public let score: Double?
        public let pixelFraction: Double?

        public struct Color: Codable, Sendable, Equatable {
            public let red: Double?
            public let green: Double?
            public let blue: Double?
            public let alpha: Double?

            public init(red: Double? = nil, green: Double? = nil, blue: Double? = nil, alpha: Double? = nil) {
                self.red = red
                self.green = green
                self.blue = blue
                self.alpha = alpha
            }
        }

        public init(color: Color? = nil, score: Double? = nil, pixelFraction: Double? = nil) {
            self.color = color
            self.score = score
            self.pixelFraction = pixelFraction
        }
    }

    public init(dominantColors: DominantColorsAnnotation? = nil) {
        self.dominantColors = dominantColors
    }
}

// MARK: - Crop Hints Annotation

/// Crop hints annotation
public struct CropHintsAnnotation: Codable, Sendable, Equatable {
    /// Crop hints
    public let cropHints: [CropHint]?

    /// A crop hint
    public struct CropHint: Codable, Sendable, Equatable {
        public let boundingPoly: BoundingPoly?
        public let confidence: Double?
        public let importanceFraction: Double?

        public init(boundingPoly: BoundingPoly? = nil, confidence: Double? = nil, importanceFraction: Double? = nil) {
            self.boundingPoly = boundingPoly
            self.confidence = confidence
            self.importanceFraction = importanceFraction
        }
    }

    public init(cropHints: [CropHint]? = nil) {
        self.cropHints = cropHints
    }
}

// MARK: - Web Detection

/// Web detection result
public struct WebDetection: Codable, Sendable, Equatable {
    /// Web entities
    public let webEntities: [WebEntity]?

    /// Full matching images
    public let fullMatchingImages: [WebImage]?

    /// Partial matching images
    public let partialMatchingImages: [WebImage]?

    /// Pages with matching images
    public let pagesWithMatchingImages: [WebPage]?

    /// Visually similar images
    public let visuallySimilarImages: [WebImage]?

    /// Best guess labels
    public let bestGuessLabels: [WebLabel]?

    /// Web entity
    public struct WebEntity: Codable, Sendable, Equatable {
        public let entityId: String?
        public let score: Double?
        public let description: String?

        public init(entityId: String? = nil, score: Double? = nil, description: String? = nil) {
            self.entityId = entityId
            self.score = score
            self.description = description
        }
    }

    /// Web image
    public struct WebImage: Codable, Sendable, Equatable {
        public let url: String?
        public let score: Double?

        public init(url: String? = nil, score: Double? = nil) {
            self.url = url
            self.score = score
        }
    }

    /// Web page
    public struct WebPage: Codable, Sendable, Equatable {
        public let url: String?
        public let score: Double?
        public let pageTitle: String?
        public let fullMatchingImages: [WebImage]?
        public let partialMatchingImages: [WebImage]?

        public init(
            url: String? = nil,
            score: Double? = nil,
            pageTitle: String? = nil,
            fullMatchingImages: [WebImage]? = nil,
            partialMatchingImages: [WebImage]? = nil
        ) {
            self.url = url
            self.score = score
            self.pageTitle = pageTitle
            self.fullMatchingImages = fullMatchingImages
            self.partialMatchingImages = partialMatchingImages
        }
    }

    /// Web label
    public struct WebLabel: Codable, Sendable, Equatable {
        public let label: String?
        public let languageCode: String?

        public init(label: String? = nil, languageCode: String? = nil) {
            self.label = label
            self.languageCode = languageCode
        }
    }

    public init(
        webEntities: [WebEntity]? = nil,
        fullMatchingImages: [WebImage]? = nil,
        partialMatchingImages: [WebImage]? = nil,
        pagesWithMatchingImages: [WebPage]? = nil,
        visuallySimilarImages: [WebImage]? = nil,
        bestGuessLabels: [WebLabel]? = nil
    ) {
        self.webEntities = webEntities
        self.fullMatchingImages = fullMatchingImages
        self.partialMatchingImages = partialMatchingImages
        self.pagesWithMatchingImages = pagesWithMatchingImages
        self.visuallySimilarImages = visuallySimilarImages
        self.bestGuessLabels = bestGuessLabels
    }
}

// MARK: - Localized Object Annotation

/// Object localization result
public struct LocalizedObjectAnnotation: Codable, Sendable, Equatable {
    /// Object ID
    public let mid: String?

    /// Object name
    public let name: String?

    /// Confidence score
    public let score: Double?

    /// Bounding polygon
    public let boundingPoly: BoundingPoly?

    public init(
        mid: String? = nil,
        name: String? = nil,
        score: Double? = nil,
        boundingPoly: BoundingPoly? = nil
    ) {
        self.mid = mid
        self.name = name
        self.score = score
        self.boundingPoly = boundingPoly
    }
}

// MARK: - Common Types

/// Bounding polygon
public struct BoundingPoly: Codable, Sendable, Equatable {
    /// Vertices
    public let vertices: [Vertex]?

    /// Normalized vertices
    public let normalizedVertices: [NormalizedVertex]?

    /// Vertex with integer coordinates
    public struct Vertex: Codable, Sendable, Equatable {
        public let x: Int?
        public let y: Int?

        public init(x: Int? = nil, y: Int? = nil) {
            self.x = x
            self.y = y
        }
    }

    /// Normalized vertex with float coordinates
    public struct NormalizedVertex: Codable, Sendable, Equatable {
        public let x: Double?
        public let y: Double?

        public init(x: Double? = nil, y: Double? = nil) {
            self.x = x
            self.y = y
        }
    }

    public init(vertices: [Vertex]? = nil, normalizedVertices: [NormalizedVertex]? = nil) {
        self.vertices = vertices
        self.normalizedVertices = normalizedVertices
    }
}

/// 3D position
public struct Position: Codable, Sendable, Equatable {
    public let x: Double
    public let y: Double
    public let z: Double?

    public init(x: Double, y: Double, z: Double? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
}

/// Likelihood enum
public enum Likelihood: String, Codable, Sendable {
    case unknown = "UNKNOWN"
    case veryUnlikely = "VERY_UNLIKELY"
    case unlikely = "UNLIKELY"
    case possible = "POSSIBLE"
    case likely = "LIKELY"
    case veryLikely = "VERY_LIKELY"
}

/// Vision error
public struct VisionError: Codable, Sendable, Equatable {
    public let code: Int?
    public let message: String?

    public init(code: Int? = nil, message: String? = nil) {
        self.code = code
        self.message = message
    }
}

// MARK: - Batch Annotation

/// Batch image annotation request
public struct GoogleCloudVisionBatchRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Input GCS URI
    public let inputGcsUri: String

    /// Output GCS URI
    public let outputGcsUri: String

    /// Features to detect
    public let features: [GoogleCloudVisionRequest.Feature]

    public init(
        projectID: String,
        inputGcsUri: String,
        outputGcsUri: String,
        features: [GoogleCloudVisionRequest.Feature]
    ) {
        self.projectID = projectID
        self.inputGcsUri = inputGcsUri
        self.outputGcsUri = outputGcsUri
        self.features = features
    }

    /// Command to run batch annotation
    public var batchAnnotateCommand: String {
        let featuresJSON = features.map { "{\"type\": \"\($0.type.rawValue)\"}" }.joined(separator: ", ")
        return """
        curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
          -H "Content-Type: application/json" \\
          "https://vision.googleapis.com/v1/files:asyncBatchAnnotate" \\
          -d '{
            "requests": [{
              "inputConfig": {"gcsSource": {"uri": "\(inputGcsUri)"}},
              "features": [\(featuresJSON)],
              "outputConfig": {"gcsDestination": {"uri": "\(outputGcsUri)"}}
            }]
          }'
        """
    }
}

// MARK: - Product Search

/// Vision Product Search product set
public struct GoogleCloudVisionProductSet: Codable, Sendable, Equatable {
    /// Product set name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String?

    /// Index time
    public let indexTime: String?

    /// Index error
    public let indexError: VisionError?

    public init(
        name: String,
        projectID: String,
        location: String,
        displayName: String? = nil,
        indexTime: String? = nil,
        indexError: VisionError? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.indexTime = indexTime
        self.indexError = indexError
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/productSets/\(name)"
    }

    /// Command to create product set
    public var createCommand: String {
        var cmd = "gcloud ml vision product-search product-sets create \(name) --location=\(location) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }
        return cmd
    }

    /// Command to list product sets
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ml vision product-search product-sets list --location=\(location) --project=\(projectID)"
    }
}

/// Vision Product Search product
public struct GoogleCloudVisionProduct: Codable, Sendable, Equatable {
    /// Product name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String?

    /// Product category
    public let productCategory: String

    /// Product labels
    public let productLabels: [KeyValue]?

    /// Description
    public let description: String?

    /// Key-value pair
    public struct KeyValue: Codable, Sendable, Equatable {
        public let key: String
        public let value: String

        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        displayName: String? = nil,
        productCategory: String,
        productLabels: [KeyValue]? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.productCategory = productCategory
        self.productLabels = productLabels
        self.description = description
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/products/\(name)"
    }

    /// Command to create product
    public var createCommand: String {
        var cmd = "gcloud ml vision product-search products create \(name) --location=\(location) --category=\(productCategory) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }
        return cmd
    }
}

// MARK: - Vision Operations

/// Operations for Vision AI
public struct VisionOperations: Sendable {
    private init() {}

    /// Enable Vision API
    public static var enableAPICommand: String {
        "gcloud services enable vision.googleapis.com"
    }

    /// Detect labels in an image
    public static func detectLabelsCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-labels \(imageUri) --project=\(projectID)"
    }

    /// Detect text in an image
    public static func detectTextCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-text \(imageUri) --project=\(projectID)"
    }

    /// Detect faces in an image
    public static func detectFacesCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-faces \(imageUri) --project=\(projectID)"
    }

    /// Detect landmarks in an image
    public static func detectLandmarksCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-landmarks \(imageUri) --project=\(projectID)"
    }

    /// Detect logos in an image
    public static func detectLogosCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-logos \(imageUri) --project=\(projectID)"
    }

    /// Detect objects in an image
    public static func detectObjectsCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-objects \(imageUri) --project=\(projectID)"
    }

    /// Run safe search detection
    public static func safeSearchCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-safe-search \(imageUri) --project=\(projectID)"
    }

    /// Detect web entities
    public static func detectWebCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-web \(imageUri) --project=\(projectID)"
    }

    /// Detect document text (OCR)
    public static func detectDocumentCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-document \(imageUri) --project=\(projectID)"
    }

    /// Get image properties
    public static func detectImagePropertiesCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision detect-image-properties \(imageUri) --project=\(projectID)"
    }

    /// Get crop hints
    public static func detectCropHintsCommand(imageUri: String, projectID: String) -> String {
        "gcloud ml vision suggest-crop \(imageUri) --project=\(projectID)"
    }
}

// MARK: - DAIS Vision AI Template

/// DAIS template for Vision AI processing
public struct DAISVisionAITemplate: Sendable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Service account
    public let serviceAccount: String

    /// GCS bucket for images
    public let imageBucket: String

    public init(
        projectID: String,
        location: String = "us-central1",
        serviceAccount: String,
        imageBucket: String
    ) {
        self.projectID = projectID
        self.location = location
        self.serviceAccount = serviceAccount
        self.imageBucket = imageBucket
    }

    /// Standard label detection request
    public func labelDetectionRequest(imageUri: String) -> GoogleCloudVisionRequest {
        GoogleCloudVisionRequest(
            projectID: projectID,
            image: GoogleCloudVisionRequest.ImageSource.fromGCS(imageUri),
            features: [
                GoogleCloudVisionRequest.Feature(type: .labelDetection, maxResults: 10)
            ]
        )
    }

    /// Comprehensive analysis request
    public func comprehensiveAnalysisRequest(imageUri: String) -> GoogleCloudVisionRequest {
        GoogleCloudVisionRequest(
            projectID: projectID,
            image: GoogleCloudVisionRequest.ImageSource.fromGCS(imageUri),
            features: [
                GoogleCloudVisionRequest.Feature(type: .labelDetection, maxResults: 10),
                GoogleCloudVisionRequest.Feature(type: .textDetection),
                GoogleCloudVisionRequest.Feature(type: .faceDetection),
                GoogleCloudVisionRequest.Feature(type: .objectLocalization, maxResults: 10),
                GoogleCloudVisionRequest.Feature(type: .safeSearchDetection),
                GoogleCloudVisionRequest.Feature(type: .imageProperties)
            ]
        )
    }

    /// OCR request for document images
    public func ocrRequest(imageUri: String) -> GoogleCloudVisionRequest {
        GoogleCloudVisionRequest(
            projectID: projectID,
            image: GoogleCloudVisionRequest.ImageSource.fromGCS(imageUri),
            features: [
                GoogleCloudVisionRequest.Feature(type: .documentTextDetection)
            ],
            imageContext: GoogleCloudVisionRequest.ImageContext(
                languageHints: ["en"]
            )
        )
    }

    /// Content moderation request
    public func moderationRequest(imageUri: String) -> GoogleCloudVisionRequest {
        GoogleCloudVisionRequest(
            projectID: projectID,
            image: GoogleCloudVisionRequest.ImageSource.fromGCS(imageUri),
            features: [
                GoogleCloudVisionRequest.Feature(type: .safeSearchDetection)
            ]
        )
    }

    /// Product search product set
    public var productSet: GoogleCloudVisionProductSet {
        GoogleCloudVisionProductSet(
            name: "dais-products",
            projectID: projectID,
            location: location,
            displayName: "DAIS Product Catalog"
        )
    }

    /// Setup script for Vision AI infrastructure
    public var setupScript: String {
        """
        #!/bin/bash
        set -e

        # Enable Vision API
        gcloud services enable vision.googleapis.com --project=\(projectID)

        # Create GCS bucket for images
        gsutil mb -p \(projectID) -l \(location.uppercased()) gs://\(imageBucket)/ || true

        # Grant service account access
        gsutil iam ch serviceAccount:\(serviceAccount):objectAdmin gs://\(imageBucket)/

        # Grant Vision API user role
        gcloud projects add-iam-policy-binding \(projectID) \\
            --member="serviceAccount:\(serviceAccount)" \\
            --role="roles/ml.developer"

        echo "Vision AI infrastructure created successfully"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -e

        # Delete GCS bucket
        gsutil rm -r gs://\(imageBucket)/ || true

        echo "Vision AI teardown complete"
        """
    }

    /// Python processing script
    public var pythonProcessingScript: String {
        """
        from google.cloud import vision
        import io

        def detect_labels(image_uri: str) -> list:
            \"\"\"Detect labels in an image.\"\"\"
            client = vision.ImageAnnotatorClient()
            image = vision.Image()
            image.source.image_uri = image_uri

            response = client.label_detection(image=image)
            labels = response.label_annotations

            return [{"description": label.description, "score": label.score} for label in labels]

        def detect_text(image_uri: str) -> str:
            \"\"\"Detect text in an image.\"\"\"
            client = vision.ImageAnnotatorClient()
            image = vision.Image()
            image.source.image_uri = image_uri

            response = client.text_detection(image=image)
            texts = response.text_annotations

            if texts:
                return texts[0].description
            return ""

        def detect_faces(image_uri: str) -> list:
            \"\"\"Detect faces in an image.\"\"\"
            client = vision.ImageAnnotatorClient()
            image = vision.Image()
            image.source.image_uri = image_uri

            response = client.face_detection(image=image)
            faces = response.face_annotations

            return [{
                "joy": face.joy_likelihood.name,
                "sorrow": face.sorrow_likelihood.name,
                "anger": face.anger_likelihood.name,
                "surprise": face.surprise_likelihood.name,
                "confidence": face.detection_confidence
            } for face in faces]

        def safe_search(image_uri: str) -> dict:
            \"\"\"Run safe search detection.\"\"\"
            client = vision.ImageAnnotatorClient()
            image = vision.Image()
            image.source.image_uri = image_uri

            response = client.safe_search_detection(image=image)
            safe = response.safe_search_annotation

            return {
                "adult": safe.adult.name,
                "spoof": safe.spoof.name,
                "medical": safe.medical.name,
                "violence": safe.violence.name,
                "racy": safe.racy.name
            }

        if __name__ == "__main__":
            image_uri = "gs://\(imageBucket)/test-image.jpg"

            print("Labels:", detect_labels(image_uri))
            print("Text:", detect_text(image_uri))
            print("Safe Search:", safe_search(image_uri))
        """
    }
}
