// GoogleCloudMediaCDN.swift
// Media CDN - Content delivery for streaming media
// Service #59

import Foundation

// MARK: - Edge Cache Service

/// A Media CDN Edge Cache Service for content delivery
public struct GoogleCloudEdgeCacheService: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let routing: Routing?
    public let labels: [String: String]?
    public let disableQuic: Bool?
    public let requireTls: Bool?
    public let edgeSecurityPolicy: String?
    public let edgeSslCertificates: [String]?
    public let logConfig: LogConfig?
    public let sslPolicy: String?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        description: String? = nil,
        routing: Routing? = nil,
        labels: [String: String]? = nil,
        disableQuic: Bool? = nil,
        requireTls: Bool? = nil,
        edgeSecurityPolicy: String? = nil,
        edgeSslCertificates: [String]? = nil,
        logConfig: LogConfig? = nil,
        sslPolicy: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.routing = routing
        self.labels = labels
        self.disableQuic = disableQuic
        self.requireTls = requireTls
        self.edgeSecurityPolicy = edgeSecurityPolicy
        self.edgeSslCertificates = edgeSslCertificates
        self.logConfig = logConfig
        self.sslPolicy = sslPolicy
    }

    /// Routing configuration
    public struct Routing: Codable, Sendable, Equatable {
        public let hostRules: [HostRule]?
        public let pathMatchers: [PathMatcher]?

        public init(hostRules: [HostRule]? = nil, pathMatchers: [PathMatcher]? = nil) {
            self.hostRules = hostRules
            self.pathMatchers = pathMatchers
        }

        public struct HostRule: Codable, Sendable, Equatable {
            public let description: String?
            public let hosts: [String]
            public let pathMatcher: String

            public init(description: String? = nil, hosts: [String], pathMatcher: String) {
                self.description = description
                self.hosts = hosts
                self.pathMatcher = pathMatcher
            }
        }

        public struct PathMatcher: Codable, Sendable, Equatable {
            public let name: String
            public let routeRules: [RouteRule]?

            public init(name: String, routeRules: [RouteRule]? = nil) {
                self.name = name
                self.routeRules = routeRules
            }
        }
    }

    /// Route rule
    public struct RouteRule: Codable, Sendable, Equatable {
        public let description: String?
        public let priority: Int
        public let matchRules: [MatchRule]?
        public let origin: String?
        public let routeAction: RouteAction?
        public let headerAction: HeaderAction?
        public let urlRedirect: URLRedirect?

        public init(
            description: String? = nil,
            priority: Int,
            matchRules: [MatchRule]? = nil,
            origin: String? = nil,
            routeAction: RouteAction? = nil,
            headerAction: HeaderAction? = nil,
            urlRedirect: URLRedirect? = nil
        ) {
            self.description = description
            self.priority = priority
            self.matchRules = matchRules
            self.origin = origin
            self.routeAction = routeAction
            self.headerAction = headerAction
            self.urlRedirect = urlRedirect
        }
    }

    /// Match rule
    public struct MatchRule: Codable, Sendable, Equatable {
        public let prefixMatch: String?
        public let fullPathMatch: String?
        public let pathTemplateMatch: String?
        public let headerMatches: [HeaderMatch]?
        public let queryParameterMatches: [QueryParameterMatch]?

        public init(
            prefixMatch: String? = nil,
            fullPathMatch: String? = nil,
            pathTemplateMatch: String? = nil,
            headerMatches: [HeaderMatch]? = nil,
            queryParameterMatches: [QueryParameterMatch]? = nil
        ) {
            self.prefixMatch = prefixMatch
            self.fullPathMatch = fullPathMatch
            self.pathTemplateMatch = pathTemplateMatch
            self.headerMatches = headerMatches
            self.queryParameterMatches = queryParameterMatches
        }
    }

    /// Header match
    public struct HeaderMatch: Codable, Sendable, Equatable {
        public let headerName: String
        public let exactMatch: String?
        public let prefixMatch: String?
        public let suffixMatch: String?
        public let presentMatch: Bool?
        public let invertMatch: Bool?

        public init(
            headerName: String,
            exactMatch: String? = nil,
            prefixMatch: String? = nil,
            suffixMatch: String? = nil,
            presentMatch: Bool? = nil,
            invertMatch: Bool? = nil
        ) {
            self.headerName = headerName
            self.exactMatch = exactMatch
            self.prefixMatch = prefixMatch
            self.suffixMatch = suffixMatch
            self.presentMatch = presentMatch
            self.invertMatch = invertMatch
        }
    }

    /// Query parameter match
    public struct QueryParameterMatch: Codable, Sendable, Equatable {
        public let name: String
        public let exactMatch: String?
        public let presentMatch: Bool?

        public init(name: String, exactMatch: String? = nil, presentMatch: Bool? = nil) {
            self.name = name
            self.exactMatch = exactMatch
            self.presentMatch = presentMatch
        }
    }

    /// Route action
    public struct RouteAction: Codable, Sendable, Equatable {
        public let cdnPolicy: CDNPolicy?
        public let corsPolicy: CorsPolicy?
        public let urlRewrite: URLRewrite?

        public init(cdnPolicy: CDNPolicy? = nil, corsPolicy: CorsPolicy? = nil, urlRewrite: URLRewrite? = nil) {
            self.cdnPolicy = cdnPolicy
            self.corsPolicy = corsPolicy
            self.urlRewrite = urlRewrite
        }
    }

    /// CDN policy
    public struct CDNPolicy: Codable, Sendable, Equatable {
        public let cacheMode: CacheMode?
        public let defaultTtl: String?
        public let maxTtl: String?
        public let clientTtl: String?
        public let negativeCaching: Bool?
        public let negativeCachingPolicy: [NegativeCachingPolicy]?
        public let signedRequestMode: SignedRequestMode?
        public let signedRequestKeyNames: [String]?
        public let cacheKeyPolicy: CacheKeyPolicy?
        public let signedTokenOptions: SignedTokenOptions?
        public let addSignatures: AddSignatures?

        public init(
            cacheMode: CacheMode? = nil,
            defaultTtl: String? = nil,
            maxTtl: String? = nil,
            clientTtl: String? = nil,
            negativeCaching: Bool? = nil,
            negativeCachingPolicy: [NegativeCachingPolicy]? = nil,
            signedRequestMode: SignedRequestMode? = nil,
            signedRequestKeyNames: [String]? = nil,
            cacheKeyPolicy: CacheKeyPolicy? = nil,
            signedTokenOptions: SignedTokenOptions? = nil,
            addSignatures: AddSignatures? = nil
        ) {
            self.cacheMode = cacheMode
            self.defaultTtl = defaultTtl
            self.maxTtl = maxTtl
            self.clientTtl = clientTtl
            self.negativeCaching = negativeCaching
            self.negativeCachingPolicy = negativeCachingPolicy
            self.signedRequestMode = signedRequestMode
            self.signedRequestKeyNames = signedRequestKeyNames
            self.cacheKeyPolicy = cacheKeyPolicy
            self.signedTokenOptions = signedTokenOptions
            self.addSignatures = addSignatures
        }

        public enum CacheMode: String, Codable, Sendable {
            case cacheModeUnspecified = "CACHE_MODE_UNSPECIFIED"
            case cacheAllStatic = "CACHE_ALL_STATIC"
            case useOriginHeaders = "USE_ORIGIN_HEADERS"
            case forceCacheAll = "FORCE_CACHE_ALL"
            case bypassCache = "BYPASS_CACHE"
        }

        public enum SignedRequestMode: String, Codable, Sendable {
            case signedRequestModeUnspecified = "SIGNED_REQUEST_MODE_UNSPECIFIED"
            case disabled = "DISABLED"
            case requireTokens = "REQUIRE_TOKENS"
            case requireSignatures = "REQUIRE_SIGNATURES"
        }
    }

    /// Negative caching policy
    public struct NegativeCachingPolicy: Codable, Sendable, Equatable {
        public let code: Int
        public let ttl: String?

        public init(code: Int, ttl: String? = nil) {
            self.code = code
            self.ttl = ttl
        }
    }

    /// Cache key policy
    public struct CacheKeyPolicy: Codable, Sendable, Equatable {
        public let includeProtocol: Bool?
        public let excludeHost: Bool?
        public let includedHeaderNames: [String]?
        public let excludedQueryParameters: [String]?
        public let includedQueryParameters: [String]?
        public let includedCookieNames: [String]?

        public init(
            includeProtocol: Bool? = nil,
            excludeHost: Bool? = nil,
            includedHeaderNames: [String]? = nil,
            excludedQueryParameters: [String]? = nil,
            includedQueryParameters: [String]? = nil,
            includedCookieNames: [String]? = nil
        ) {
            self.includeProtocol = includeProtocol
            self.excludeHost = excludeHost
            self.includedHeaderNames = includedHeaderNames
            self.excludedQueryParameters = excludedQueryParameters
            self.includedQueryParameters = includedQueryParameters
            self.includedCookieNames = includedCookieNames
        }
    }

    /// Signed token options
    public struct SignedTokenOptions: Codable, Sendable, Equatable {
        public let tokenQueryParameter: String?
        public let allowedSignatureAlgorithms: [SignatureAlgorithm]?

        public init(tokenQueryParameter: String? = nil, allowedSignatureAlgorithms: [SignatureAlgorithm]? = nil) {
            self.tokenQueryParameter = tokenQueryParameter
            self.allowedSignatureAlgorithms = allowedSignatureAlgorithms
        }

        public enum SignatureAlgorithm: String, Codable, Sendable {
            case signatureAlgorithmUnspecified = "SIGNATURE_ALGORITHM_UNSPECIFIED"
            case ed25519 = "ED25519"
            case hmacSha1 = "HMAC_SHA1"
            case hmacSha256 = "HMAC_SHA256"
        }
    }

    /// Add signatures configuration
    public struct AddSignatures: Codable, Sendable, Equatable {
        public let actions: [String]?
        public let copiedParameters: [String]?
        public let keyset: String?
        public let tokenTtl: String?
        public let tokenQueryParameter: String?

        public init(
            actions: [String]? = nil,
            copiedParameters: [String]? = nil,
            keyset: String? = nil,
            tokenTtl: String? = nil,
            tokenQueryParameter: String? = nil
        ) {
            self.actions = actions
            self.copiedParameters = copiedParameters
            self.keyset = keyset
            self.tokenTtl = tokenTtl
            self.tokenQueryParameter = tokenQueryParameter
        }
    }

    /// CORS policy
    public struct CorsPolicy: Codable, Sendable, Equatable {
        public let allowOrigins: [String]?
        public let allowMethods: [String]?
        public let allowHeaders: [String]?
        public let exposeHeaders: [String]?
        public let maxAge: String?
        public let allowCredentials: Bool?
        public let disabled: Bool?

        public init(
            allowOrigins: [String]? = nil,
            allowMethods: [String]? = nil,
            allowHeaders: [String]? = nil,
            exposeHeaders: [String]? = nil,
            maxAge: String? = nil,
            allowCredentials: Bool? = nil,
            disabled: Bool? = nil
        ) {
            self.allowOrigins = allowOrigins
            self.allowMethods = allowMethods
            self.allowHeaders = allowHeaders
            self.exposeHeaders = exposeHeaders
            self.maxAge = maxAge
            self.allowCredentials = allowCredentials
            self.disabled = disabled
        }
    }

    /// URL rewrite
    public struct URLRewrite: Codable, Sendable, Equatable {
        public let pathPrefixRewrite: String?
        public let pathTemplateRewrite: String?
        public let hostRewrite: String?

        public init(pathPrefixRewrite: String? = nil, pathTemplateRewrite: String? = nil, hostRewrite: String? = nil) {
            self.pathPrefixRewrite = pathPrefixRewrite
            self.pathTemplateRewrite = pathTemplateRewrite
            self.hostRewrite = hostRewrite
        }
    }

    /// URL redirect
    public struct URLRedirect: Codable, Sendable, Equatable {
        public let hostRedirect: String?
        public let pathRedirect: String?
        public let prefixRedirect: String?
        public let redirectResponseCode: RedirectResponseCode?
        public let httpsRedirect: Bool?
        public let stripQuery: Bool?

        public init(
            hostRedirect: String? = nil,
            pathRedirect: String? = nil,
            prefixRedirect: String? = nil,
            redirectResponseCode: RedirectResponseCode? = nil,
            httpsRedirect: Bool? = nil,
            stripQuery: Bool? = nil
        ) {
            self.hostRedirect = hostRedirect
            self.pathRedirect = pathRedirect
            self.prefixRedirect = prefixRedirect
            self.redirectResponseCode = redirectResponseCode
            self.httpsRedirect = httpsRedirect
            self.stripQuery = stripQuery
        }

        public enum RedirectResponseCode: String, Codable, Sendable {
            case movedPermanentlyDefault = "MOVED_PERMANENTLY_DEFAULT"
            case found = "FOUND"
            case seeOther = "SEE_OTHER"
            case temporaryRedirect = "TEMPORARY_REDIRECT"
            case permanentRedirect = "PERMANENT_REDIRECT"
        }
    }

    /// Header action
    public struct HeaderAction: Codable, Sendable, Equatable {
        public let requestHeadersToAdd: [HeaderKeyValue]?
        public let requestHeadersToRemove: [String]?
        public let responseHeadersToAdd: [HeaderKeyValue]?
        public let responseHeadersToRemove: [String]?

        public init(
            requestHeadersToAdd: [HeaderKeyValue]? = nil,
            requestHeadersToRemove: [String]? = nil,
            responseHeadersToAdd: [HeaderKeyValue]? = nil,
            responseHeadersToRemove: [String]? = nil
        ) {
            self.requestHeadersToAdd = requestHeadersToAdd
            self.requestHeadersToRemove = requestHeadersToRemove
            self.responseHeadersToAdd = responseHeadersToAdd
            self.responseHeadersToRemove = responseHeadersToRemove
        }
    }

    /// Header key value
    public struct HeaderKeyValue: Codable, Sendable, Equatable {
        public let headerName: String
        public let headerValue: String
        public let replace: Bool?

        public init(headerName: String, headerValue: String, replace: Bool? = nil) {
            self.headerName = headerName
            self.headerValue = headerValue
            self.replace = replace
        }
    }

    /// Log configuration
    public struct LogConfig: Codable, Sendable, Equatable {
        public let enable: Bool?
        public let sampleRate: Double?

        public init(enable: Bool? = nil, sampleRate: Double? = nil) {
            self.enable = enable
            self.sampleRate = sampleRate
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/edgeCacheServices/\(name)"
    }

    /// Create command
    public var createCommand: String {
        "gcloud edge-cache services create \(name) --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud edge-cache services describe \(name) --project=\(projectID)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud edge-cache services delete \(name) --project=\(projectID)"
    }
}

// MARK: - Edge Cache Origin

/// A Media CDN Edge Cache Origin
public struct GoogleCloudEdgeCacheOrigin: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let originAddress: String
    public let networkProtocol: NetworkProtocol?
    public let port: Int?
    public let retryConditions: [RetryCondition]?
    public let maxAttempts: Int?
    public let timeout: Timeout?
    public let failoverOrigin: String?
    public let awsV4Authentication: AWSV4Authentication?
    public let originOverrideAction: OriginOverrideAction?
    public let originRedirect: OriginRedirect?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        description: String? = nil,
        originAddress: String,
        networkProtocol: NetworkProtocol? = nil,
        port: Int? = nil,
        retryConditions: [RetryCondition]? = nil,
        maxAttempts: Int? = nil,
        timeout: Timeout? = nil,
        failoverOrigin: String? = nil,
        awsV4Authentication: AWSV4Authentication? = nil,
        originOverrideAction: OriginOverrideAction? = nil,
        originRedirect: OriginRedirect? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.originAddress = originAddress
        self.networkProtocol = networkProtocol
        self.port = port
        self.retryConditions = retryConditions
        self.maxAttempts = maxAttempts
        self.timeout = timeout
        self.failoverOrigin = failoverOrigin
        self.awsV4Authentication = awsV4Authentication
        self.originOverrideAction = originOverrideAction
        self.originRedirect = originRedirect
    }

    /// Network protocol
    public enum NetworkProtocol: String, Codable, Sendable {
        case http1_1 = "HTTP1_1"
        case http2 = "HTTP2"
    }

    /// Retry condition
    public enum RetryCondition: String, Codable, Sendable {
        case connectFailure = "CONNECT_FAILURE"
        case http5xx = "HTTP_5XX"
        case gatewayError = "GATEWAY_ERROR"
        case retriableError4xx = "RETRIABLE_4XX"
        case notFound = "NOT_FOUND"
        case forbidden = "FORBIDDEN"
    }

    /// Timeout configuration
    public struct Timeout: Codable, Sendable, Equatable {
        public let connectTimeout: String?
        public let maxAttemptsTimeout: String?
        public let responseTimeout: String?
        public let readTimeout: String?

        public init(
            connectTimeout: String? = nil,
            maxAttemptsTimeout: String? = nil,
            responseTimeout: String? = nil,
            readTimeout: String? = nil
        ) {
            self.connectTimeout = connectTimeout
            self.maxAttemptsTimeout = maxAttemptsTimeout
            self.responseTimeout = responseTimeout
            self.readTimeout = readTimeout
        }
    }

    /// AWS V4 authentication for S3-compatible origins
    public struct AWSV4Authentication: Codable, Sendable, Equatable {
        public let accessKeyId: String
        public let secretAccessKeyVersion: String
        public let originRegion: String

        public init(accessKeyId: String, secretAccessKeyVersion: String, originRegion: String) {
            self.accessKeyId = accessKeyId
            self.secretAccessKeyVersion = secretAccessKeyVersion
            self.originRegion = originRegion
        }
    }

    /// Origin override action
    public struct OriginOverrideAction: Codable, Sendable, Equatable {
        public let urlRewrite: URLRewrite?
        public let headerAction: HeaderAction?

        public init(urlRewrite: URLRewrite? = nil, headerAction: HeaderAction? = nil) {
            self.urlRewrite = urlRewrite
            self.headerAction = headerAction
        }

        public struct URLRewrite: Codable, Sendable, Equatable {
            public let hostRewrite: String?

            public init(hostRewrite: String? = nil) {
                self.hostRewrite = hostRewrite
            }
        }

        public struct HeaderAction: Codable, Sendable, Equatable {
            public let requestHeadersToAdd: [GoogleCloudEdgeCacheService.HeaderKeyValue]?

            public init(requestHeadersToAdd: [GoogleCloudEdgeCacheService.HeaderKeyValue]? = nil) {
                self.requestHeadersToAdd = requestHeadersToAdd
            }
        }
    }

    /// Origin redirect configuration
    public struct OriginRedirect: Codable, Sendable, Equatable {
        public let redirectConditions: [String]?

        public init(redirectConditions: [String]? = nil) {
            self.redirectConditions = redirectConditions
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/edgeCacheOrigins/\(name)"
    }

    /// Create command
    public var createCommand: String {
        "gcloud edge-cache origins create \(name) --origin-address=\(originAddress) --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud edge-cache origins describe \(name) --project=\(projectID)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud edge-cache origins delete \(name) --project=\(projectID)"
    }
}

// MARK: - Edge Cache Keyset

/// A Media CDN Edge Cache Keyset for signed URLs
public struct GoogleCloudEdgeCacheKeyset: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let publicKeys: [PublicKey]?
    public let validationSharedKeys: [ValidationSharedKey]?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        location: String = "global",
        description: String? = nil,
        publicKeys: [PublicKey]? = nil,
        validationSharedKeys: [ValidationSharedKey]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.publicKeys = publicKeys
        self.validationSharedKeys = validationSharedKeys
        self.labels = labels
    }

    /// Public key for Ed25519 signatures
    public struct PublicKey: Codable, Sendable, Equatable {
        public let id: String
        public let value: String?
        public let managed: Bool?

        public init(id: String, value: String? = nil, managed: Bool? = nil) {
            self.id = id
            self.value = value
            self.managed = managed
        }
    }

    /// Validation shared key for HMAC signatures
    public struct ValidationSharedKey: Codable, Sendable, Equatable {
        public let secretVersion: String

        public init(secretVersion: String) {
            self.secretVersion = secretVersion
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/edgeCacheKeysets/\(name)"
    }

    /// Create command
    public var createCommand: String {
        "gcloud edge-cache keysets create \(name) --project=\(projectID)"
    }

    /// Describe command
    public var describeCommand: String {
        "gcloud edge-cache keysets describe \(name) --project=\(projectID)"
    }

    /// Delete command
    public var deleteCommand: String {
        "gcloud edge-cache keysets delete \(name) --project=\(projectID)"
    }
}

// MARK: - Media CDN Operations

/// Operations for Media CDN
public struct MediaCDNOperations: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// Enable Media CDN API
    public var enableAPICommand: String {
        "gcloud services enable networkservices.googleapis.com --project=\(projectID)"
    }

    /// List edge cache services
    public var listServicesCommand: String {
        "gcloud edge-cache services list --project=\(projectID)"
    }

    /// List edge cache origins
    public var listOriginsCommand: String {
        "gcloud edge-cache origins list --project=\(projectID)"
    }

    /// List edge cache keysets
    public var listKeysetsCommand: String {
        "gcloud edge-cache keysets list --project=\(projectID)"
    }

    /// Invalidate cache
    public func invalidateCacheCommand(serviceName: String, urlPath: String, host: String? = nil) -> String {
        var cmd = "gcloud edge-cache services invalidate-cache \(serviceName) --path=\"\(urlPath)\" --project=\(projectID)"
        if let h = host {
            cmd += " --host=\"\(h)\""
        }
        return cmd
    }

    /// Export service config
    public func exportServiceCommand(serviceName: String, destination: String) -> String {
        "gcloud edge-cache services export \(serviceName) --destination=\(destination) --project=\(projectID)"
    }

    /// Import service config
    public func importServiceCommand(serviceName: String, source: String) -> String {
        "gcloud edge-cache services import \(serviceName) --source=\(source) --project=\(projectID)"
    }

    /// Generate signed URL (using openssl)
    public func generateSignedURLCommand(
        url: String,
        keyName: String,
        keyFile: String,
        expirationTime: String
    ) -> String {
        """
        # Generate signed URL for Media CDN
        URL="\(url)"
        KEY_NAME="\(keyName)"
        KEY_FILE="\(keyFile)"
        EXPIRATION="\(expirationTime)"

        # Calculate expiration timestamp
        EXPIRES=$(date -d "$EXPIRATION" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$EXPIRATION" +%s)

        # Create signature input
        SIGNATURE_INPUT="${URL}?Expires=${EXPIRES}&KeyName=${KEY_NAME}"

        # Generate Ed25519 signature (requires openssl 1.1.1+)
        SIGNATURE=$(echo -n "$SIGNATURE_INPUT" | openssl pkeyutl -sign -inkey "$KEY_FILE" | base64 | tr '+/' '-_' | tr -d '=')

        echo "${URL}?Expires=${EXPIRES}&KeyName=${KEY_NAME}&Signature=${SIGNATURE}"
        """
    }

    /// IAM roles for Media CDN
    public enum MediaCDNRole: String, Sendable {
        case networkServicesAdmin = "roles/networkservices.admin"
        case networkServicesEditor = "roles/networkservices.editor"
        case networkServicesViewer = "roles/networkservices.viewer"
    }

    /// Add IAM binding
    public func addIAMBindingCommand(member: String, role: MediaCDNRole) -> String {
        "gcloud projects add-iam-policy-binding \(projectID) --member=\(member) --role=\(role.rawValue)"
    }

    /// Get metrics command
    public func getMetricsCommand(serviceName: String, metricType: String = "request_count") -> String {
        """
        gcloud monitoring metrics list \\
            --filter="metric.type=networkservices.googleapis.com/edge_cache/\(metricType) AND resource.labels.service_name=\(serviceName)" \\
            --project=\(projectID)
        """
    }
}

// MARK: - DAIS Media CDN Template

/// DAIS template for Media CDN configurations
public struct DAISMediaCDNTemplate: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "global") {
        self.projectID = projectID
        self.location = location
    }

    /// Create a GCS origin
    public func gcsOrigin(
        name: String,
        bucketName: String,
        description: String? = nil
    ) -> GoogleCloudEdgeCacheOrigin {
        GoogleCloudEdgeCacheOrigin(
            name: name,
            projectID: projectID,
            location: location,
            description: description ?? "GCS bucket origin",
            originAddress: "\(bucketName).storage.googleapis.com",
            networkProtocol: .http2,
            retryConditions: [.connectFailure, .http5xx, .gatewayError],
            maxAttempts: 3,
            timeout: .init(
                connectTimeout: "5s",
                responseTimeout: "30s"
            )
        )
    }

    /// Create an AWS S3 origin with authentication
    public func s3Origin(
        name: String,
        bucketName: String,
        region: String,
        accessKeyId: String,
        secretAccessKeySecretVersion: String
    ) -> GoogleCloudEdgeCacheOrigin {
        GoogleCloudEdgeCacheOrigin(
            name: name,
            projectID: projectID,
            location: location,
            description: "AWS S3 origin",
            originAddress: "\(bucketName).s3.\(region).amazonaws.com",
            networkProtocol: .http2,
            retryConditions: [.connectFailure, .http5xx],
            maxAttempts: 3,
            awsV4Authentication: .init(
                accessKeyId: accessKeyId,
                secretAccessKeyVersion: secretAccessKeySecretVersion,
                originRegion: region
            )
        )
    }

    /// Create a custom origin
    public func customOrigin(
        name: String,
        originAddress: String,
        port: Int = 443,
        description: String? = nil
    ) -> GoogleCloudEdgeCacheOrigin {
        GoogleCloudEdgeCacheOrigin(
            name: name,
            projectID: projectID,
            location: location,
            description: description,
            originAddress: originAddress,
            networkProtocol: .http2,
            port: port,
            retryConditions: [.connectFailure, .http5xx, .gatewayError],
            maxAttempts: 3
        )
    }

    /// Create a keyset for signed URLs
    public func signedURLKeyset(
        name: String,
        publicKeyId: String,
        publicKeyValue: String
    ) -> GoogleCloudEdgeCacheKeyset {
        GoogleCloudEdgeCacheKeyset(
            name: name,
            projectID: projectID,
            location: location,
            description: "Keyset for signed URL validation",
            publicKeys: [
                .init(id: publicKeyId, value: publicKeyValue)
            ]
        )
    }

    /// Create an edge cache service for video streaming
    public func videoStreamingService(
        name: String,
        hosts: [String],
        originName: String,
        defaultTtl: String = "86400s",
        requireSignedURLs: Bool = false,
        keysetName: String? = nil
    ) -> GoogleCloudEdgeCacheService {
        var cdnPolicy = GoogleCloudEdgeCacheService.CDNPolicy(
            cacheMode: .cacheAllStatic,
            defaultTtl: defaultTtl,
            maxTtl: "604800s", // 7 days
            clientTtl: "3600s",
            negativeCaching: true,
            negativeCachingPolicy: [
                .init(code: 404, ttl: "120s"),
                .init(code: 500, ttl: "10s")
            ]
        )

        if requireSignedURLs, let keyset = keysetName {
            cdnPolicy = GoogleCloudEdgeCacheService.CDNPolicy(
                cacheMode: .cacheAllStatic,
                defaultTtl: defaultTtl,
                maxTtl: "604800s",
                clientTtl: "3600s",
                negativeCaching: true,
                signedRequestMode: .requireTokens,
                signedRequestKeyNames: [keyset],
                signedTokenOptions: .init(
                    tokenQueryParameter: "edge-token",
                    allowedSignatureAlgorithms: [.ed25519]
                )
            )
        }

        let routeRule = GoogleCloudEdgeCacheService.RouteRule(
            priority: 1,
            matchRules: [
                .init(prefixMatch: "/")
            ],
            origin: originName,
            routeAction: .init(
                cdnPolicy: cdnPolicy,
                corsPolicy: .init(
                    allowOrigins: ["*"],
                    allowMethods: ["GET", "HEAD", "OPTIONS"],
                    allowHeaders: ["Range", "Origin"],
                    exposeHeaders: ["Content-Length", "Content-Range"],
                    maxAge: "3600s"
                )
            ),
            headerAction: .init(
                responseHeadersToAdd: [
                    .init(headerName: "X-Cache-Status", headerValue: "{cdn_cache_status}"),
                    .init(headerName: "Cache-Control", headerValue: "public, max-age=3600")
                ]
            )
        )

        return GoogleCloudEdgeCacheService(
            name: name,
            projectID: projectID,
            location: location,
            description: "Video streaming edge cache service",
            routing: .init(
                hostRules: [
                    .init(hosts: hosts, pathMatcher: "main")
                ],
                pathMatchers: [
                    .init(name: "main", routeRules: [routeRule])
                ]
            ),
            requireTls: true,
            logConfig: .init(enable: true, sampleRate: 1.0)
        )
    }

    /// Create an edge cache service for live streaming
    public func liveStreamingService(
        name: String,
        hosts: [String],
        originName: String
    ) -> GoogleCloudEdgeCacheService {
        let hlsRule = GoogleCloudEdgeCacheService.RouteRule(
            priority: 1,
            matchRules: [
                .init(pathTemplateMatch: "/**/*.m3u8")
            ],
            origin: originName,
            routeAction: .init(
                cdnPolicy: .init(
                    cacheMode: .useOriginHeaders,
                    defaultTtl: "2s",
                    maxTtl: "10s"
                )
            )
        )

        let segmentRule = GoogleCloudEdgeCacheService.RouteRule(
            priority: 2,
            matchRules: [
                .init(pathTemplateMatch: "/**/*.ts"),
                .init(pathTemplateMatch: "/**/*.m4s"),
                .init(pathTemplateMatch: "/**/*.cmfv"),
                .init(pathTemplateMatch: "/**/*.cmfa")
            ],
            origin: originName,
            routeAction: .init(
                cdnPolicy: .init(
                    cacheMode: .cacheAllStatic,
                    defaultTtl: "86400s",
                    maxTtl: "604800s"
                )
            )
        )

        let dashRule = GoogleCloudEdgeCacheService.RouteRule(
            priority: 3,
            matchRules: [
                .init(pathTemplateMatch: "/**/*.mpd")
            ],
            origin: originName,
            routeAction: .init(
                cdnPolicy: .init(
                    cacheMode: .useOriginHeaders,
                    defaultTtl: "2s",
                    maxTtl: "10s"
                )
            )
        )

        return GoogleCloudEdgeCacheService(
            name: name,
            projectID: projectID,
            location: location,
            description: "Live streaming edge cache service",
            routing: .init(
                hostRules: [
                    .init(hosts: hosts, pathMatcher: "live")
                ],
                pathMatchers: [
                    .init(name: "live", routeRules: [hlsRule, segmentRule, dashRule])
                ]
            ),
            requireTls: true,
            logConfig: .init(enable: true, sampleRate: 1.0)
        )
    }

    /// Operations helper
    public var operations: MediaCDNOperations {
        MediaCDNOperations(projectID: projectID)
    }

    /// Generate setup script for video streaming
    public func videoStreamingSetupScript(
        serviceName: String,
        originName: String,
        bucketName: String,
        domains: [String]
    ) -> String {
        """
        #!/bin/bash
        # Media CDN Video Streaming Setup Script
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"
        SERVICE_NAME="\(serviceName)"
        ORIGIN_NAME="\(originName)"
        BUCKET_NAME="\(bucketName)"
        DOMAINS="\(domains.joined(separator: ","))"

        echo "=== Enabling Media CDN API ==="
        gcloud services enable networkservices.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Creating GCS Bucket for Content ==="
        gsutil mb -p $PROJECT -l US gs://$BUCKET_NAME || echo "Bucket already exists"

        echo ""
        echo "=== Setting Bucket CORS ==="
        cat > /tmp/cors.json << 'CORS'
        [
            {
                "origin": ["*"],
                "method": ["GET", "HEAD", "OPTIONS"],
                "responseHeader": ["Content-Type", "Content-Length", "Content-Range", "Range"],
                "maxAgeSeconds": 3600
            }
        ]
        CORS
        gsutil cors set /tmp/cors.json gs://$BUCKET_NAME

        echo ""
        echo "=== Creating Edge Cache Origin ==="
        gcloud edge-cache origins create $ORIGIN_NAME \\
            --origin-address="${BUCKET_NAME}.storage.googleapis.com" \\
            --protocol=HTTP2 \\
            --project=$PROJECT

        echo ""
        echo "=== Creating Edge Cache Service ==="
        cat > /tmp/service.yaml << 'YAML'
        name: $SERVICE_NAME
        routing:
          hostRules:
            - hosts:
                - "*"
              pathMatcher: main
          pathMatchers:
            - name: main
              routeRules:
                - priority: 1
                  matchRules:
                    - prefixMatch: /
                  origin: $ORIGIN_NAME
                  routeAction:
                    cdnPolicy:
                      cacheMode: CACHE_ALL_STATIC
                      defaultTtl: 86400s
                      maxTtl: 604800s
        requireTls: true
        logConfig:
          enable: true
          sampleRate: 1.0
        YAML

        gcloud edge-cache services import $SERVICE_NAME \\
            --source=/tmp/service.yaml \\
            --project=$PROJECT

        echo ""
        echo "=== Setup Complete ==="
        echo "Service: $SERVICE_NAME"
        echo "Origin: $ORIGIN_NAME"
        echo "Bucket: gs://$BUCKET_NAME"
        echo ""
        echo "Configure your DNS to point domains to the Edge Cache service IP."
        gcloud edge-cache services describe $SERVICE_NAME --project=$PROJECT --format="value(ipv4Addresses)"
        """
    }

    /// Generate cache invalidation script
    public func cacheInvalidationScript(serviceName: String) -> String {
        """
        #!/bin/bash
        # Media CDN Cache Invalidation Script
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"
        SERVICE_NAME="\(serviceName)"

        # Usage: ./invalidate.sh [path] [host]
        PATH_PATTERN="${1:-/*}"
        HOST="${2:-}"

        echo "=== Invalidating Cache ==="
        echo "Service: $SERVICE_NAME"
        echo "Path: $PATH_PATTERN"

        if [ -n "$HOST" ]; then
            echo "Host: $HOST"
            gcloud edge-cache services invalidate-cache $SERVICE_NAME \\
                --path="$PATH_PATTERN" \\
                --host="$HOST" \\
                --project=$PROJECT
        else
            gcloud edge-cache services invalidate-cache $SERVICE_NAME \\
                --path="$PATH_PATTERN" \\
                --project=$PROJECT
        fi

        echo ""
        echo "=== Cache Invalidation Initiated ==="
        """
    }
}
