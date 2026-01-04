// GoogleCloudRetail.swift
// Retail API - Product catalog and recommendations
// Service #58

import Foundation

// MARK: - Product Catalog

/// A retail product catalog
public struct GoogleCloudRetailCatalog: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let displayName: String?
    public let productLevelConfig: ProductLevelConfig?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        displayName: String? = nil,
        productLevelConfig: ProductLevelConfig? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.productLevelConfig = productLevelConfig
    }

    /// Product level configuration
    public struct ProductLevelConfig: Codable, Sendable, Equatable {
        public let ingestionProductType: String?
        public let merchantCenterProductIdField: String?

        public init(
            ingestionProductType: String? = nil,
            merchantCenterProductIdField: String? = nil
        ) {
            self.ingestionProductType = ingestionProductType
            self.merchantCenterProductIdField = merchantCenterProductIdField
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/catalogs/\(name)"
    }
}

// MARK: - Product

/// A retail product
public struct GoogleCloudRetailProduct: Codable, Sendable, Equatable {
    public let id: String
    public let name: String?
    public let title: String
    public let description: String?
    public let categories: [String]?
    public let priceInfo: PriceInfo?
    public let availability: Availability?
    public let availableQuantity: Int?
    public let images: [Image]?
    public let uri: String?
    public let tags: [String]?
    public let attributes: [String: CustomAttribute]?
    public let brands: [String]?
    public let gtin: String?
    public let fulfillmentInfo: [FulfillmentInfo]?
    public let publishTime: String?
    public let retrievableFields: String?
    public let primaryProductId: String?
    public let productType: ProductType?

    public init(
        id: String,
        name: String? = nil,
        title: String,
        description: String? = nil,
        categories: [String]? = nil,
        priceInfo: PriceInfo? = nil,
        availability: Availability? = nil,
        availableQuantity: Int? = nil,
        images: [Image]? = nil,
        uri: String? = nil,
        tags: [String]? = nil,
        attributes: [String: CustomAttribute]? = nil,
        brands: [String]? = nil,
        gtin: String? = nil,
        fulfillmentInfo: [FulfillmentInfo]? = nil,
        publishTime: String? = nil,
        retrievableFields: String? = nil,
        primaryProductId: String? = nil,
        productType: ProductType? = nil
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.description = description
        self.categories = categories
        self.priceInfo = priceInfo
        self.availability = availability
        self.availableQuantity = availableQuantity
        self.images = images
        self.uri = uri
        self.tags = tags
        self.attributes = attributes
        self.brands = brands
        self.gtin = gtin
        self.fulfillmentInfo = fulfillmentInfo
        self.publishTime = publishTime
        self.retrievableFields = retrievableFields
        self.primaryProductId = primaryProductId
        self.productType = productType
    }

    /// Product type
    public enum ProductType: String, Codable, Sendable {
        case typeUnspecified = "TYPE_UNSPECIFIED"
        case primary = "PRIMARY"
        case variant = "VARIANT"
        case collection = "COLLECTION"
    }

    /// Availability status
    public enum Availability: String, Codable, Sendable {
        case availabilityUnspecified = "AVAILABILITY_UNSPECIFIED"
        case inStock = "IN_STOCK"
        case outOfStock = "OUT_OF_STOCK"
        case preorder = "PREORDER"
        case backorder = "BACKORDER"
    }

    /// Price information
    public struct PriceInfo: Codable, Sendable, Equatable {
        public let currencyCode: String?
        public let price: Double?
        public let originalPrice: Double?
        public let cost: Double?
        public let priceEffectiveTime: String?
        public let priceExpireTime: String?
        public let priceRange: PriceRange?

        public init(
            currencyCode: String? = nil,
            price: Double? = nil,
            originalPrice: Double? = nil,
            cost: Double? = nil,
            priceEffectiveTime: String? = nil,
            priceExpireTime: String? = nil,
            priceRange: PriceRange? = nil
        ) {
            self.currencyCode = currencyCode
            self.price = price
            self.originalPrice = originalPrice
            self.cost = cost
            self.priceEffectiveTime = priceEffectiveTime
            self.priceExpireTime = priceExpireTime
            self.priceRange = priceRange
        }

        public struct PriceRange: Codable, Sendable, Equatable {
            public let price: Price?
            public let originalPrice: Price?

            public init(price: Price? = nil, originalPrice: Price? = nil) {
                self.price = price
                self.originalPrice = originalPrice
            }

            public struct Price: Codable, Sendable, Equatable {
                public let minimum: Double?
                public let maximum: Double?

                public init(minimum: Double? = nil, maximum: Double? = nil) {
                    self.minimum = minimum
                    self.maximum = maximum
                }
            }
        }
    }

    /// Product image
    public struct Image: Codable, Sendable, Equatable {
        public let uri: String
        public let height: Int?
        public let width: Int?

        public init(uri: String, height: Int? = nil, width: Int? = nil) {
            self.uri = uri
            self.height = height
            self.width = width
        }
    }

    /// Custom attribute
    public struct CustomAttribute: Codable, Sendable, Equatable {
        public let text: [String]?
        public let numbers: [Double]?
        public let searchable: Bool?
        public let indexable: Bool?

        public init(
            text: [String]? = nil,
            numbers: [Double]? = nil,
            searchable: Bool? = nil,
            indexable: Bool? = nil
        ) {
            self.text = text
            self.numbers = numbers
            self.searchable = searchable
            self.indexable = indexable
        }
    }

    /// Fulfillment information
    public struct FulfillmentInfo: Codable, Sendable, Equatable {
        public let type: String?
        public let placeIds: [String]?

        public init(type: String? = nil, placeIds: [String]? = nil) {
            self.type = type
            self.placeIds = placeIds
        }
    }
}

// MARK: - User Event

/// A retail user event for tracking
public struct GoogleCloudRetailUserEvent: Codable, Sendable, Equatable {
    public let eventType: EventType
    public let visitorId: String
    public let eventTime: String?
    public let experimentIds: [String]?
    public let attributionToken: String?
    public let productDetails: [ProductDetail]?
    public let cartId: String?
    public let purchaseTransaction: PurchaseTransaction?
    public let searchQuery: String?
    public let filter: String?
    public let orderBy: String?
    public let offset: Int?
    public let pageCategories: [String]?
    public let userInfo: UserInfo?
    public let uri: String?
    public let referrerUri: String?
    public let pageViewId: String?

    public init(
        eventType: EventType,
        visitorId: String,
        eventTime: String? = nil,
        experimentIds: [String]? = nil,
        attributionToken: String? = nil,
        productDetails: [ProductDetail]? = nil,
        cartId: String? = nil,
        purchaseTransaction: PurchaseTransaction? = nil,
        searchQuery: String? = nil,
        filter: String? = nil,
        orderBy: String? = nil,
        offset: Int? = nil,
        pageCategories: [String]? = nil,
        userInfo: UserInfo? = nil,
        uri: String? = nil,
        referrerUri: String? = nil,
        pageViewId: String? = nil
    ) {
        self.eventType = eventType
        self.visitorId = visitorId
        self.eventTime = eventTime
        self.experimentIds = experimentIds
        self.attributionToken = attributionToken
        self.productDetails = productDetails
        self.cartId = cartId
        self.purchaseTransaction = purchaseTransaction
        self.searchQuery = searchQuery
        self.filter = filter
        self.orderBy = orderBy
        self.offset = offset
        self.pageCategories = pageCategories
        self.userInfo = userInfo
        self.uri = uri
        self.referrerUri = referrerUri
        self.pageViewId = pageViewId
    }

    /// Event type
    public enum EventType: String, Codable, Sendable {
        case eventTypeUnspecified = "EVENT_TYPE_UNSPECIFIED"
        case homePageView = "home-page-view"
        case categoryPageView = "category-page-view"
        case productPageView = "detail-page-view"
        case searchPageView = "search"
        case addToCart = "add-to-cart"
        case removeFromCart = "remove-from-cart"
        case purchaseComplete = "purchase-complete"
        case shoppingCartPageView = "shopping-cart-page-view"
    }

    /// Product detail in event
    public struct ProductDetail: Codable, Sendable, Equatable {
        public let product: GoogleCloudRetailProduct?
        public let quantity: Int?

        public init(product: GoogleCloudRetailProduct? = nil, quantity: Int? = nil) {
            self.product = product
            self.quantity = quantity
        }
    }

    /// Purchase transaction
    public struct PurchaseTransaction: Codable, Sendable, Equatable {
        public let id: String?
        public let revenue: Double?
        public let tax: Double?
        public let cost: Double?
        public let currencyCode: String?

        public init(
            id: String? = nil,
            revenue: Double? = nil,
            tax: Double? = nil,
            cost: Double? = nil,
            currencyCode: String? = nil
        ) {
            self.id = id
            self.revenue = revenue
            self.tax = tax
            self.cost = cost
            self.currencyCode = currencyCode
        }
    }

    /// User information
    public struct UserInfo: Codable, Sendable, Equatable {
        public let userId: String?
        public let ipAddress: String?
        public let userAgent: String?
        public let directUserRequest: Bool?

        public init(
            userId: String? = nil,
            ipAddress: String? = nil,
            userAgent: String? = nil,
            directUserRequest: Bool? = nil
        ) {
            self.userId = userId
            self.ipAddress = ipAddress
            self.userAgent = userAgent
            self.directUserRequest = directUserRequest
        }
    }
}

// MARK: - Serving Config

/// A serving configuration for recommendations or search
public struct GoogleCloudRetailServingConfig: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let catalogName: String
    public let displayName: String?
    public let modelId: String?
    public let priceRerankingLevel: String?
    public let facetControlIds: [String]?
    public let dynamicFacetSpec: DynamicFacetSpec?
    public let boostControlIds: [String]?
    public let filterControlIds: [String]?
    public let redirectControlIds: [String]?
    public let solutionTypes: [SolutionType]?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        catalogName: String = "default_catalog",
        displayName: String? = nil,
        modelId: String? = nil,
        priceRerankingLevel: String? = nil,
        facetControlIds: [String]? = nil,
        dynamicFacetSpec: DynamicFacetSpec? = nil,
        boostControlIds: [String]? = nil,
        filterControlIds: [String]? = nil,
        redirectControlIds: [String]? = nil,
        solutionTypes: [SolutionType]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.catalogName = catalogName
        self.displayName = displayName
        self.modelId = modelId
        self.priceRerankingLevel = priceRerankingLevel
        self.facetControlIds = facetControlIds
        self.dynamicFacetSpec = dynamicFacetSpec
        self.boostControlIds = boostControlIds
        self.filterControlIds = filterControlIds
        self.redirectControlIds = redirectControlIds
        self.solutionTypes = solutionTypes
    }

    /// Solution type
    public enum SolutionType: String, Codable, Sendable {
        case solutionTypeUnspecified = "SOLUTION_TYPE_UNSPECIFIED"
        case recommendation = "SOLUTION_TYPE_RECOMMENDATION"
        case search = "SOLUTION_TYPE_SEARCH"
    }

    /// Dynamic facet specification
    public struct DynamicFacetSpec: Codable, Sendable, Equatable {
        public let mode: Mode?

        public init(mode: Mode? = nil) {
            self.mode = mode
        }

        public enum Mode: String, Codable, Sendable {
            case modeUnspecified = "MODE_UNSPECIFIED"
            case disabled = "DISABLED"
            case enabled = "ENABLED"
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/servingConfigs/\(name)"
    }
}

// MARK: - Model

/// A recommendation or search model
public struct GoogleCloudRetailModel: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let catalogName: String
    public let displayName: String?
    public let modelType: ModelType
    public let optimizationObjective: String?
    public let periodicTuningState: PeriodicTuningState?
    public let trainingState: TrainingState?
    public let servingState: ServingState?
    public let createTime: String?
    public let updateTime: String?
    public let dataState: DataState?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        catalogName: String = "default_catalog",
        displayName: String? = nil,
        modelType: ModelType,
        optimizationObjective: String? = nil,
        periodicTuningState: PeriodicTuningState? = nil,
        trainingState: TrainingState? = nil,
        servingState: ServingState? = nil,
        createTime: String? = nil,
        updateTime: String? = nil,
        dataState: DataState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.catalogName = catalogName
        self.displayName = displayName
        self.modelType = modelType
        self.optimizationObjective = optimizationObjective
        self.periodicTuningState = periodicTuningState
        self.trainingState = trainingState
        self.servingState = servingState
        self.createTime = createTime
        self.updateTime = updateTime
        self.dataState = dataState
    }

    /// Model type
    public enum ModelType: String, Codable, Sendable {
        case typeUnspecified = "TYPE_UNSPECIFIED"
        case recommendationsAI = "RECOMMENDATIONS_AI"
        case searchOptimization = "SEARCH_OPTIMIZATION"
    }

    /// Periodic tuning state
    public enum PeriodicTuningState: String, Codable, Sendable {
        case periodicTuningDisabled = "PERIODIC_TUNING_DISABLED"
        case allTuningDisabled = "ALL_TUNING_DISABLED"
        case periodicTuningEnabled = "PERIODIC_TUNING_ENABLED"
    }

    /// Training state
    public enum TrainingState: String, Codable, Sendable {
        case trainingStateUnspecified = "TRAINING_STATE_UNSPECIFIED"
        case paused = "PAUSED"
        case training = "TRAINING"
    }

    /// Serving state
    public enum ServingState: String, Codable, Sendable {
        case servingStateUnspecified = "SERVING_STATE_UNSPECIFIED"
        case inactive = "INACTIVE"
        case active = "ACTIVE"
        case tuned = "TUNED"
    }

    /// Data state
    public enum DataState: String, Codable, Sendable {
        case dataStateUnspecified = "DATA_STATE_UNSPECIFIED"
        case dataOk = "DATA_OK"
        case dataError = "DATA_ERROR"
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/models/\(name)"
    }
}

// MARK: - Retail Operations

/// Operations for Retail API
public struct RetailOperations: Sendable {
    public let projectID: String
    public let location: String
    public let catalogName: String

    public init(projectID: String, location: String = "global", catalogName: String = "default_catalog") {
        self.projectID = projectID
        self.location = location
        self.catalogName = catalogName
    }

    /// Enable Retail API
    public var enableAPICommand: String {
        "gcloud services enable retail.googleapis.com --project=\(projectID)"
    }

    /// Import products from GCS
    public func importProductsCommand(branchId: String = "default_branch", gcsUri: String) -> String {
        """
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/branches/\(branchId)/products:import" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '{
                "inputConfig": {
                    "gcsSource": {
                        "inputUris": ["\(gcsUri)"]
                    }
                }
            }'
        """
    }

    /// Import user events from GCS
    public func importUserEventsCommand(gcsUri: String) -> String {
        """
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/userEvents:import" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '{
                "inputConfig": {
                    "gcsSource": {
                        "inputUris": ["\(gcsUri)"]
                    }
                }
            }'
        """
    }

    /// Write a user event
    public func writeUserEventCommand(event: GoogleCloudRetailUserEvent) -> String {
        """
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/userEvents:write" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '{
                "eventType": "\(event.eventType.rawValue)",
                "visitorId": "\(event.visitorId)"
            }'
        """
    }

    /// Get recommendations
    public func getRecommendationsCommand(
        servingConfigId: String,
        visitorId: String,
        productId: String? = nil
    ) -> String {
        var body = """
        {
            "placement": "projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/servingConfigs/\(servingConfigId)",
            "visitorId": "\(visitorId)"
        """
        if let pid = productId {
            body += """
            ,
                "productDetails": [{"product": {"id": "\(pid)"}}]
            """
        }
        body += "\n}"

        return """
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/placements/\(servingConfigId):predict" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '\(body)'
        """
    }

    /// Search products
    public func searchProductsCommand(
        servingConfigId: String,
        visitorId: String,
        query: String
    ) -> String {
        """
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/placements/\(servingConfigId):search" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '{
                "placement": "projects/\(projectID)/locations/\(location)/catalogs/\(catalogName)/servingConfigs/\(servingConfigId)",
                "visitorId": "\(visitorId)",
                "query": "\(query)"
            }'
        """
    }

    /// List products
    public var listProductsCommand: String {
        "gcloud retail products list --project=\(projectID) --location=\(location)"
    }

    /// IAM roles for Retail
    public enum RetailRole: String, Sendable {
        case retailAdmin = "roles/retail.admin"
        case retailEditor = "roles/retail.editor"
        case retailViewer = "roles/retail.viewer"
    }

    /// Add IAM binding
    public func addIAMBindingCommand(member: String, role: RetailRole) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=\(role.rawValue)"
    }
}

// MARK: - DAIS Retail Template

/// DAIS template for Retail configurations
public struct DAISRetailTemplate: Sendable {
    public let projectID: String
    public let location: String
    public let catalogName: String

    public init(projectID: String, location: String = "global", catalogName: String = "default_catalog") {
        self.projectID = projectID
        self.location = location
        self.catalogName = catalogName
    }

    /// Create a product
    public func product(
        id: String,
        title: String,
        description: String? = nil,
        categories: [String]? = nil,
        price: Double,
        currencyCode: String = "USD",
        availability: GoogleCloudRetailProduct.Availability = .inStock,
        imageUri: String? = nil,
        uri: String? = nil
    ) -> GoogleCloudRetailProduct {
        var images: [GoogleCloudRetailProduct.Image]? = nil
        if let img = imageUri {
            images = [GoogleCloudRetailProduct.Image(uri: img)]
        }

        return GoogleCloudRetailProduct(
            id: id,
            title: title,
            description: description,
            categories: categories,
            priceInfo: .init(
                currencyCode: currencyCode,
                price: price
            ),
            availability: availability,
            images: images,
            uri: uri,
            productType: .primary
        )
    }

    /// Create a product view event
    public func productViewEvent(
        visitorId: String,
        productId: String,
        productTitle: String
    ) -> GoogleCloudRetailUserEvent {
        GoogleCloudRetailUserEvent(
            eventType: .productPageView,
            visitorId: visitorId,
            productDetails: [
                .init(product: .init(id: productId, title: productTitle), quantity: 1)
            ]
        )
    }

    /// Create an add to cart event
    public func addToCartEvent(
        visitorId: String,
        productId: String,
        productTitle: String,
        quantity: Int = 1,
        cartId: String? = nil
    ) -> GoogleCloudRetailUserEvent {
        GoogleCloudRetailUserEvent(
            eventType: .addToCart,
            visitorId: visitorId,
            productDetails: [
                .init(product: .init(id: productId, title: productTitle), quantity: quantity)
            ],
            cartId: cartId
        )
    }

    /// Create a purchase event
    public func purchaseEvent(
        visitorId: String,
        transactionId: String,
        products: [(id: String, title: String, quantity: Int, price: Double)],
        currencyCode: String = "USD"
    ) -> GoogleCloudRetailUserEvent {
        let productDetails = products.map { p in
            GoogleCloudRetailUserEvent.ProductDetail(
                product: .init(
                    id: p.id,
                    title: p.title,
                    priceInfo: .init(currencyCode: currencyCode, price: p.price)
                ),
                quantity: p.quantity
            )
        }

        let totalRevenue = products.reduce(0.0) { $0 + (Double($1.quantity) * $1.price) }

        return GoogleCloudRetailUserEvent(
            eventType: .purchaseComplete,
            visitorId: visitorId,
            productDetails: productDetails,
            purchaseTransaction: .init(
                id: transactionId,
                revenue: totalRevenue,
                currencyCode: currencyCode
            )
        )
    }

    /// Create a search event
    public func searchEvent(
        visitorId: String,
        query: String,
        pageCategories: [String]? = nil
    ) -> GoogleCloudRetailUserEvent {
        GoogleCloudRetailUserEvent(
            eventType: .searchPageView,
            visitorId: visitorId,
            searchQuery: query,
            pageCategories: pageCategories
        )
    }

    /// Create a recommendation serving config
    public func recommendationConfig(
        name: String,
        displayName: String,
        modelId: String
    ) -> GoogleCloudRetailServingConfig {
        GoogleCloudRetailServingConfig(
            name: name,
            projectID: projectID,
            location: location,
            catalogName: catalogName,
            displayName: displayName,
            modelId: modelId,
            solutionTypes: [.recommendation]
        )
    }

    /// Create a search serving config
    public func searchConfig(
        name: String,
        displayName: String,
        enableDynamicFacets: Bool = true
    ) -> GoogleCloudRetailServingConfig {
        GoogleCloudRetailServingConfig(
            name: name,
            projectID: projectID,
            location: location,
            catalogName: catalogName,
            displayName: displayName,
            dynamicFacetSpec: enableDynamicFacets ? .init(mode: .enabled) : nil,
            solutionTypes: [.search]
        )
    }

    /// Operations helper
    public var operations: RetailOperations {
        RetailOperations(projectID: projectID, location: location, catalogName: catalogName)
    }

    /// Generate product import script
    public func productImportScript(gcsUri: String) -> String {
        """
        #!/bin/bash
        # Retail Product Import Script
        # Project: \(projectID)
        # Catalog: \(catalogName)

        set -e

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        CATALOG="\(catalogName)"
        GCS_URI="\(gcsUri)"

        echo "=== Enabling Retail API ==="
        gcloud services enable retail.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Importing Products ==="
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/$PROJECT/locations/$LOCATION/catalogs/$CATALOG/branches/default_branch/products:import" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '{
                "inputConfig": {
                    "gcsSource": {
                        "inputUris": ["'"$GCS_URI"'"]
                    }
                }
            }'

        echo ""
        echo "=== Import Started ==="
        echo "Check the operation status to monitor progress."
        """
    }

    /// Generate user events import script
    public func userEventsImportScript(gcsUri: String) -> String {
        """
        #!/bin/bash
        # Retail User Events Import Script
        # Project: \(projectID)
        # Catalog: \(catalogName)

        set -e

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        CATALOG="\(catalogName)"
        GCS_URI="\(gcsUri)"

        echo "=== Importing User Events ==="
        curl -X POST \\
            "https://retail.googleapis.com/v2/projects/$PROJECT/locations/$LOCATION/catalogs/$CATALOG/userEvents:import" \\
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
            -H "Content-Type: application/json" \\
            -d '{
                "inputConfig": {
                    "gcsSource": {
                        "inputUris": ["'"$GCS_URI"'"]
                    }
                }
            }'

        echo ""
        echo "=== Import Started ==="
        """
    }
}
