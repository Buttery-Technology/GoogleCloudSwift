// GoogleCloudCDN.swift
// Cloud CDN - Content Delivery Network
//
// Cloud CDN accelerates content delivery using Google's global edge network.
// It works with HTTP(S) Load Balancing to cache content close to users.

import Foundation

// MARK: - CDN Policy

/// Represents a Cloud CDN cache policy configuration
public struct CDNCachePolicy: Codable, Sendable, Equatable {
    public let cacheMode: CacheMode
    public let defaultTTL: Int?
    public let maxTTL: Int?
    public let clientTTL: Int?
    public let negativeCaching: Bool
    public let negativeCachingPolicy: [NegativeCachingPolicy]?
    public let serveWhileStale: Int?
    public let cacheKeyPolicy: CacheKeyPolicy?
    public let bypassCacheOnRequestHeaders: [BypassCacheHeader]?

    public init(
        cacheMode: CacheMode = .cacheAllStatic,
        defaultTTL: Int? = 3600,
        maxTTL: Int? = 86400,
        clientTTL: Int? = nil,
        negativeCaching: Bool = false,
        negativeCachingPolicy: [NegativeCachingPolicy]? = nil,
        serveWhileStale: Int? = nil,
        cacheKeyPolicy: CacheKeyPolicy? = nil,
        bypassCacheOnRequestHeaders: [BypassCacheHeader]? = nil
    ) {
        self.cacheMode = cacheMode
        self.defaultTTL = defaultTTL
        self.maxTTL = maxTTL
        self.clientTTL = clientTTL
        self.negativeCaching = negativeCaching
        self.negativeCachingPolicy = negativeCachingPolicy
        self.serveWhileStale = serveWhileStale
        self.cacheKeyPolicy = cacheKeyPolicy
        self.bypassCacheOnRequestHeaders = bypassCacheOnRequestHeaders
    }

    /// Cache mode determines how responses are cached
    public enum CacheMode: String, Codable, Sendable, Equatable {
        case useOriginHeaders = "USE_ORIGIN_HEADERS"
        case forceCacheAll = "FORCE_CACHE_ALL"
        case cacheAllStatic = "CACHE_ALL_STATIC"

        public var description: String {
            switch self {
            case .useOriginHeaders:
                return "Use Cache-Control headers from origin"
            case .forceCacheAll:
                return "Cache all content regardless of headers"
            case .cacheAllStatic:
                return "Cache static content (images, CSS, JS)"
            }
        }
    }

    /// Negative caching policy for error responses
    public struct NegativeCachingPolicy: Codable, Sendable, Equatable {
        public let code: Int
        public let ttl: Int

        public init(code: Int, ttl: Int) {
            self.code = code
            self.ttl = ttl
        }
    }

    /// Cache key policy configuration
    public struct CacheKeyPolicy: Codable, Sendable, Equatable {
        public let includeHost: Bool
        public let includeProtocol: Bool
        public let includeQueryString: Bool
        public let queryStringWhitelist: [String]?
        public let queryStringBlacklist: [String]?
        public let includeHttpHeaders: [String]?
        public let includeNamedCookies: [String]?

        public init(
            includeHost: Bool = true,
            includeProtocol: Bool = true,
            includeQueryString: Bool = true,
            queryStringWhitelist: [String]? = nil,
            queryStringBlacklist: [String]? = nil,
            includeHttpHeaders: [String]? = nil,
            includeNamedCookies: [String]? = nil
        ) {
            self.includeHost = includeHost
            self.includeProtocol = includeProtocol
            self.includeQueryString = includeQueryString
            self.queryStringWhitelist = queryStringWhitelist
            self.queryStringBlacklist = queryStringBlacklist
            self.includeHttpHeaders = includeHttpHeaders
            self.includeNamedCookies = includeNamedCookies
        }
    }

    /// Header that bypasses cache when present
    public struct BypassCacheHeader: Codable, Sendable, Equatable {
        public let headerName: String

        public init(headerName: String) {
            self.headerName = headerName
        }
    }
}

// MARK: - CDN Backend Bucket

/// Represents a Cloud Storage bucket configured for CDN
public struct CDNBackendBucket: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let bucketName: String
    public let description: String?
    public let enableCDN: Bool
    public let cdnPolicy: CDNCachePolicy?
    public let customResponseHeaders: [String]?
    public let compressionMode: CompressionMode?

    public init(
        name: String,
        projectID: String,
        bucketName: String,
        description: String? = nil,
        enableCDN: Bool = true,
        cdnPolicy: CDNCachePolicy? = nil,
        customResponseHeaders: [String]? = nil,
        compressionMode: CompressionMode? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.bucketName = bucketName
        self.description = description
        self.enableCDN = enableCDN
        self.cdnPolicy = cdnPolicy
        self.customResponseHeaders = customResponseHeaders
        self.compressionMode = compressionMode
    }

    public enum CompressionMode: String, Codable, Sendable, Equatable {
        case automatic = "AUTOMATIC"
        case disabled = "DISABLED"
    }

    /// Command to create backend bucket
    public var createCommand: String {
        var cmd = "gcloud compute backend-buckets create \(name)"
        cmd += " --gcs-bucket-name=\(bucketName)"
        cmd += " --project=\(projectID)"

        if enableCDN {
            cmd += " --enable-cdn"
        }

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        if let compressionMode = compressionMode {
            cmd += " --compression-mode=\(compressionMode.rawValue)"
        }

        return cmd
    }

    /// Command to update backend bucket
    public var updateCommand: String {
        var cmd = "gcloud compute backend-buckets update \(name)"
        cmd += " --project=\(projectID)"

        if enableCDN {
            cmd += " --enable-cdn"
        } else {
            cmd += " --no-enable-cdn"
        }

        return cmd
    }

    /// Command to delete backend bucket
    public var deleteCommand: String {
        "gcloud compute backend-buckets delete \(name) --project=\(projectID) --quiet"
    }

    /// Command to describe backend bucket
    public var describeCommand: String {
        "gcloud compute backend-buckets describe \(name) --project=\(projectID)"
    }

    /// Command to list backend buckets
    public static func listCommand(projectID: String) -> String {
        "gcloud compute backend-buckets list --project=\(projectID)"
    }
}

// MARK: - CDN Signed URL

/// Represents a signed URL key for Cloud CDN
public struct CDNSignedURLKey: Codable, Sendable, Equatable {
    public let keyName: String
    public let keyValue: String

    public init(keyName: String, keyValue: String) {
        self.keyName = keyName
        self.keyValue = keyValue
    }

    /// Command to add signed URL key to backend bucket
    public func addToBackendBucketCommand(backendBucket: String, projectID: String) -> String {
        "gcloud compute backend-buckets add-signed-url-key \(backendBucket) --key-name=\(keyName) --key-file=- --project=\(projectID)"
    }

    /// Command to add signed URL key to backend service
    public func addToBackendServiceCommand(backendService: String, projectID: String) -> String {
        "gcloud compute backend-services add-signed-url-key \(backendService) --key-name=\(keyName) --key-file=- --project=\(projectID)"
    }

    /// Command to delete signed URL key from backend bucket
    public static func deleteFromBackendBucketCommand(keyName: String, backendBucket: String, projectID: String) -> String {
        "gcloud compute backend-buckets delete-signed-url-key \(backendBucket) --key-name=\(keyName) --project=\(projectID)"
    }

    /// Command to delete signed URL key from backend service
    public static func deleteFromBackendServiceCommand(keyName: String, backendService: String, projectID: String) -> String {
        "gcloud compute backend-services delete-signed-url-key \(backendService) --key-name=\(keyName) --project=\(projectID)"
    }
}

// MARK: - CDN Signed URL Generator

/// Generates signed URLs for Cloud CDN
public enum CDNSignedURLGenerator {

    /// Generate a signed URL for Cloud CDN
    public static func generateSignedURL(
        url: String,
        keyName: String,
        keyValue: String,
        expiration: Date
    ) -> String {
        let expirationUnix = Int(expiration.timeIntervalSince1970)

        // In production, compute HMAC-SHA1 signature of URL with expiration
        // For CLI generation:
        return "gcloud compute sign-url \"\(url)\" --key-name=\(keyName) --key-file=- --expires-in=\(expirationUnix)"
    }

    /// Command to sign a URL using gcloud
    public static func signURLCommand(
        url: String,
        keyName: String,
        keyFilePath: String,
        expiresIn: String = "1h"
    ) -> String {
        "gcloud compute sign-url \"\(url)\" --key-name=\(keyName) --key-file=\(keyFilePath) --expires-in=\(expiresIn)"
    }
}

// MARK: - CDN Cache Invalidation

/// Represents a cache invalidation request
public struct CDNCacheInvalidation: Codable, Sendable, Equatable {
    public let urlMap: String
    public let projectID: String
    public let path: String
    public let host: String?

    public init(
        urlMap: String,
        projectID: String,
        path: String,
        host: String? = nil
    ) {
        self.urlMap = urlMap
        self.projectID = projectID
        self.path = path
        self.host = host
    }

    /// Command to invalidate cache
    public var invalidateCommand: String {
        var cmd = "gcloud compute url-maps invalidate-cdn-cache \(urlMap)"
        cmd += " --path=\"\(path)\""
        cmd += " --project=\(projectID)"

        if let host = host {
            cmd += " --host=\(host)"
        }

        return cmd
    }

    /// Command to invalidate all cache
    public static func invalidateAllCommand(urlMap: String, projectID: String) -> String {
        "gcloud compute url-maps invalidate-cdn-cache \(urlMap) --path=\"/*\" --project=\(projectID)"
    }
}

// MARK: - CDN Edge Security Policy

/// Edge security policy for Cloud CDN
public struct CDNEdgeSecurityPolicy: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?

    public init(
        name: String,
        projectID: String,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
    }

    /// Command to create edge security policy
    public var createCommand: String {
        var cmd = "gcloud compute security-policies create \(name)"
        cmd += " --type=CLOUD_ARMOR_EDGE"
        cmd += " --project=\(projectID)"

        if let description = description {
            cmd += " --description=\"\(description)\""
        }

        return cmd
    }

    /// Command to attach to backend bucket
    public func attachToBackendBucketCommand(backendBucket: String) -> String {
        "gcloud compute backend-buckets update \(backendBucket) --edge-security-policy=\(name) --project=\(projectID)"
    }

    /// Command to attach to backend service
    public func attachToBackendServiceCommand(backendService: String) -> String {
        "gcloud compute backend-services update \(backendService) --edge-security-policy=\(name) --project=\(projectID) --global"
    }
}

// MARK: - CDN Operations

/// Common CDN operations
public enum CDNOperations {

    /// Enable CDN on a backend service
    public static func enableCDNOnBackendService(
        backendService: String,
        projectID: String,
        cacheMode: CDNCachePolicy.CacheMode = .cacheAllStatic
    ) -> String {
        "gcloud compute backend-services update \(backendService) --enable-cdn --cache-mode=\(cacheMode.rawValue) --project=\(projectID) --global"
    }

    /// Disable CDN on a backend service
    public static func disableCDNOnBackendService(
        backendService: String,
        projectID: String
    ) -> String {
        "gcloud compute backend-services update \(backendService) --no-enable-cdn --project=\(projectID) --global"
    }

    /// Set cache TTL on backend service
    public static func setCacheTTL(
        backendService: String,
        projectID: String,
        defaultTTL: Int,
        maxTTL: Int,
        clientTTL: Int? = nil
    ) -> String {
        var cmd = "gcloud compute backend-services update \(backendService)"
        cmd += " --default-ttl=\(defaultTTL)"
        cmd += " --max-ttl=\(maxTTL)"

        if let clientTTL = clientTTL {
            cmd += " --client-ttl=\(clientTTL)"
        }

        cmd += " --project=\(projectID) --global"
        return cmd
    }

    /// Enable negative caching
    public static func enableNegativeCaching(
        backendService: String,
        projectID: String
    ) -> String {
        "gcloud compute backend-services update \(backendService) --negative-caching --project=\(projectID) --global"
    }

    /// Set serve while stale
    public static func setServeWhileStale(
        backendService: String,
        projectID: String,
        seconds: Int
    ) -> String {
        "gcloud compute backend-services update \(backendService) --serve-while-stale=\(seconds) --project=\(projectID) --global"
    }

    /// Configure cache key policy
    public static func setCacheKeyPolicy(
        backendService: String,
        projectID: String,
        includeHost: Bool = true,
        includeProtocol: Bool = true,
        includeQueryString: Bool = true,
        queryStringWhitelist: [String]? = nil
    ) -> String {
        var cmd = "gcloud compute backend-services update \(backendService)"

        if includeHost {
            cmd += " --cache-key-include-host"
        } else {
            cmd += " --no-cache-key-include-host"
        }

        if includeProtocol {
            cmd += " --cache-key-include-protocol"
        } else {
            cmd += " --no-cache-key-include-protocol"
        }

        if includeQueryString {
            cmd += " --cache-key-include-query-string"
            if let whitelist = queryStringWhitelist, !whitelist.isEmpty {
                cmd += " --cache-key-query-string-whitelist=\(whitelist.joined(separator: ","))"
            }
        } else {
            cmd += " --no-cache-key-include-query-string"
        }

        cmd += " --project=\(projectID) --global"
        return cmd
    }

    /// Get CDN cache statistics
    public static func getCacheStatsCommand(projectID: String) -> String {
        "gcloud logging read 'resource.type=\"http_load_balancer\" AND jsonPayload.cacheHit:*' --project=\(projectID) --limit=100 --format=json"
    }

    /// Monitor cache hit ratio
    public static func cacheHitRatioMQL(projectID: String, backendService: String) -> String {
        """
        fetch https_lb_rule
        | metric 'loadbalancing.googleapis.com/https/request_count'
        | filter resource.backend_target_name == '\(backendService)'
        | group_by [metric.cache_result]
        | every 1m
        """
    }
}

// MARK: - DAIS CDN Templates

/// DAIS-specific CDN configurations
public enum DAISCDNTemplate {

    /// Static assets backend bucket
    public static func staticAssetsBucket(
        projectID: String,
        deploymentName: String,
        storageBucket: String
    ) -> CDNBackendBucket {
        CDNBackendBucket(
            name: "\(deploymentName)-static-assets",
            projectID: projectID,
            bucketName: storageBucket,
            description: "DAIS static assets CDN backend",
            enableCDN: true,
            cdnPolicy: CDNCachePolicy(
                cacheMode: .cacheAllStatic,
                defaultTTL: 86400,
                maxTTL: 604800,
                negativeCaching: true,
                negativeCachingPolicy: [
                    .init(code: 404, ttl: 60),
                    .init(code: 500, ttl: 10)
                ]
            ),
            customResponseHeaders: [
                "X-Cache-Status: {cdn_cache_status}",
                "X-Cache-ID: {cdn_cache_id}"
            ],
            compressionMode: .automatic
        )
    }

    /// API cache policy (short TTL, query string aware)
    public static func apiCachePolicy() -> CDNCachePolicy {
        CDNCachePolicy(
            cacheMode: .useOriginHeaders,
            defaultTTL: 60,
            maxTTL: 300,
            clientTTL: 60,
            negativeCaching: true,
            negativeCachingPolicy: [
                .init(code: 404, ttl: 30),
                .init(code: 429, ttl: 10),
                .init(code: 500, ttl: 5)
            ],
            serveWhileStale: 86400,
            cacheKeyPolicy: CDNCachePolicy.CacheKeyPolicy(
                includeHost: true,
                includeProtocol: false,
                includeQueryString: true,
                includeHttpHeaders: ["Authorization"],
                includeNamedCookies: nil
            ),
            bypassCacheOnRequestHeaders: [
                .init(headerName: "Cache-Control"),
                .init(headerName: "Pragma")
            ]
        )
    }

    /// Media streaming cache policy
    public static func mediaCachePolicy() -> CDNCachePolicy {
        CDNCachePolicy(
            cacheMode: .forceCacheAll,
            defaultTTL: 2592000, // 30 days
            maxTTL: 31536000,    // 1 year
            clientTTL: 86400,
            negativeCaching: false,
            serveWhileStale: 604800, // 7 days
            cacheKeyPolicy: CDNCachePolicy.CacheKeyPolicy(
                includeHost: true,
                includeProtocol: false,
                includeQueryString: false
            )
        )
    }

    /// Edge security policy for CDN
    public static func edgeSecurityPolicy(
        projectID: String,
        deploymentName: String
    ) -> CDNEdgeSecurityPolicy {
        CDNEdgeSecurityPolicy(
            name: "\(deploymentName)-cdn-edge-policy",
            projectID: projectID,
            description: "DAIS CDN edge security policy"
        )
    }

    /// Signed URL key for protected content
    public static func signedURLKey(keyName: String, keyValue: String) -> CDNSignedURLKey {
        CDNSignedURLKey(keyName: keyName, keyValue: keyValue)
    }

    /// Cache invalidation for deployment updates
    public static func deploymentInvalidation(
        projectID: String,
        urlMap: String
    ) -> CDNCacheInvalidation {
        CDNCacheInvalidation(
            urlMap: urlMap,
            projectID: projectID,
            path: "/*"
        )
    }

    /// Setup script for DAIS CDN
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        storageBucket: String,
        urlMap: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS CDN Setup Script
        set -e

        PROJECT_ID="\(projectID)"
        DEPLOYMENT_NAME="\(deploymentName)"
        STORAGE_BUCKET="\(storageBucket)"
        URL_MAP="\(urlMap)"

        echo "Creating backend bucket for static assets..."
        gcloud compute backend-buckets create ${DEPLOYMENT_NAME}-static-assets \\
            --gcs-bucket-name=${STORAGE_BUCKET} \\
            --enable-cdn \\
            --project=${PROJECT_ID}

        echo "Configuring CDN cache policy..."
        gcloud compute backend-buckets update ${DEPLOYMENT_NAME}-static-assets \\
            --cache-mode=CACHE_ALL_STATIC \\
            --default-ttl=86400 \\
            --max-ttl=604800 \\
            --project=${PROJECT_ID}

        echo "Adding path matcher to URL map..."
        gcloud compute url-maps add-path-matcher ${URL_MAP} \\
            --path-matcher-name=static-assets \\
            --default-backend-bucket=${DEPLOYMENT_NAME}-static-assets \\
            --path-rules="/static/*=${DEPLOYMENT_NAME}-static-assets,/assets/*=${DEPLOYMENT_NAME}-static-assets" \\
            --project=${PROJECT_ID}

        echo "CDN setup complete!"
        """
    }

    /// Teardown script for DAIS CDN
    public static func teardownScript(
        projectID: String,
        deploymentName: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS CDN Teardown Script
        set -e

        PROJECT_ID="\(projectID)"
        DEPLOYMENT_NAME="\(deploymentName)"

        echo "Deleting backend bucket..."
        gcloud compute backend-buckets delete ${DEPLOYMENT_NAME}-static-assets \\
            --project=${PROJECT_ID} --quiet || true

        echo "CDN teardown complete!"
        """
    }

    /// Common CDN response headers
    public static let standardResponseHeaders: [String] = [
        "X-Cache-Status: {cdn_cache_status}",
        "X-Cache-ID: {cdn_cache_id}",
        "Strict-Transport-Security: max-age=31536000; includeSubDomains",
        "X-Content-Type-Options: nosniff",
        "X-Frame-Options: DENY"
    ]

    /// Cache bypass headers for dynamic content
    public static let cacheBypassHeaders: [CDNCachePolicy.BypassCacheHeader] = [
        .init(headerName: "Authorization"),
        .init(headerName: "Cookie"),
        .init(headerName: "Cache-Control")
    ]
}
