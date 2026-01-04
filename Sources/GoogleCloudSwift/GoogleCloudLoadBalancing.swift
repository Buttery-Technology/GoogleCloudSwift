//
//  GoogleCloudLoadBalancing.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 1/4/26.
//

import Foundation

// MARK: - Health Check

/// Represents a Cloud Load Balancing health check.
///
/// Health checks determine whether backend instances can receive traffic.
public struct GoogleCloudHealthCheck: Codable, Sendable, Equatable {
    /// Name of the health check
    public let name: String

    /// Project ID
    public let projectID: String

    /// Type of health check
    public let type: HealthCheckType

    /// Check interval in seconds
    public let checkIntervalSec: Int

    /// Timeout in seconds
    public let timeoutSec: Int

    /// Healthy threshold (consecutive successes)
    public let healthyThreshold: Int

    /// Unhealthy threshold (consecutive failures)
    public let unhealthyThreshold: Int

    /// Description
    public let description: String?

    /// HTTP health check configuration
    public let httpHealthCheck: HTTPHealthCheckConfig?

    /// HTTPS health check configuration
    public let httpsHealthCheck: HTTPSHealthCheckConfig?

    /// TCP health check configuration
    public let tcpHealthCheck: TCPHealthCheckConfig?

    /// gRPC health check configuration
    public let grpcHealthCheck: GRPCHealthCheckConfig?

    /// Whether this is a global or regional health check
    public let isGlobal: Bool

    /// Region for regional health checks
    public let region: String?

    public init(
        name: String,
        projectID: String,
        type: HealthCheckType = .http,
        checkIntervalSec: Int = 5,
        timeoutSec: Int = 5,
        healthyThreshold: Int = 2,
        unhealthyThreshold: Int = 2,
        description: String? = nil,
        httpHealthCheck: HTTPHealthCheckConfig? = nil,
        httpsHealthCheck: HTTPSHealthCheckConfig? = nil,
        tcpHealthCheck: TCPHealthCheckConfig? = nil,
        grpcHealthCheck: GRPCHealthCheckConfig? = nil,
        isGlobal: Bool = true,
        region: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.type = type
        self.checkIntervalSec = checkIntervalSec
        self.timeoutSec = timeoutSec
        self.healthyThreshold = healthyThreshold
        self.unhealthyThreshold = unhealthyThreshold
        self.description = description
        self.httpHealthCheck = httpHealthCheck
        self.httpsHealthCheck = httpsHealthCheck
        self.tcpHealthCheck = tcpHealthCheck
        self.grpcHealthCheck = grpcHealthCheck
        self.isGlobal = isGlobal
        self.region = region
    }

    /// Full resource name
    public var resourceName: String {
        if isGlobal {
            return "projects/\(projectID)/global/healthChecks/\(name)"
        } else {
            return "projects/\(projectID)/regions/\(region ?? "")/healthChecks/\(name)"
        }
    }

    /// gcloud command to create this health check
    public var createCommand: String {
        var cmd = "gcloud compute health-checks create \(type.rawValue) \(name)"
        cmd += " --project=\(projectID)"

        if !isGlobal, let region = region {
            cmd += " --region=\(region)"
        } else {
            cmd += " --global"
        }

        cmd += " --check-interval=\(checkIntervalSec)s"
        cmd += " --timeout=\(timeoutSec)s"
        cmd += " --healthy-threshold=\(healthyThreshold)"
        cmd += " --unhealthy-threshold=\(unhealthyThreshold)"

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        switch type {
        case .http:
            if let http = httpHealthCheck {
                cmd += " --port=\(http.port)"
                if let path = http.requestPath {
                    cmd += " --request-path=\(path)"
                }
                if let host = http.host {
                    cmd += " --host=\(host)"
                }
            }
        case .https:
            if let https = httpsHealthCheck {
                cmd += " --port=\(https.port)"
                if let path = https.requestPath {
                    cmd += " --request-path=\(path)"
                }
            }
        case .tcp:
            if let tcp = tcpHealthCheck {
                cmd += " --port=\(tcp.port)"
            }
        case .ssl:
            if let tcp = tcpHealthCheck {
                cmd += " --port=\(tcp.port)"
            }
        case .grpc:
            if let grpc = grpcHealthCheck {
                cmd += " --port=\(grpc.port)"
                if let service = grpc.grpcServiceName {
                    cmd += " --grpc-service-name=\(service)"
                }
            }
        case .http2:
            if let http = httpHealthCheck {
                cmd += " --port=\(http.port)"
                if let path = http.requestPath {
                    cmd += " --request-path=\(path)"
                }
            }
        }

        return cmd
    }

    /// gcloud command to delete this health check
    public var deleteCommand: String {
        var cmd = "gcloud compute health-checks delete \(name) --project=\(projectID)"
        if !isGlobal, let region = region {
            cmd += " --region=\(region)"
        } else {
            cmd += " --global"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe this health check
    public var describeCommand: String {
        var cmd = "gcloud compute health-checks describe \(name) --project=\(projectID)"
        if !isGlobal, let region = region {
            cmd += " --region=\(region)"
        } else {
            cmd += " --global"
        }
        return cmd
    }

    /// gcloud command to list health checks
    public static func listCommand(projectID: String, global: Bool = true, region: String? = nil) -> String {
        var cmd = "gcloud compute health-checks list --project=\(projectID)"
        if !global, let region = region {
            cmd += " --filter=\"region:\(region)\""
        }
        return cmd
    }

    /// Health check type
    public enum HealthCheckType: String, Codable, Sendable {
        case http = "http"
        case https = "https"
        case tcp = "tcp"
        case ssl = "ssl"
        case grpc = "grpc"
        case http2 = "http2"
    }

    /// HTTP health check configuration
    public struct HTTPHealthCheckConfig: Codable, Sendable, Equatable {
        public let port: Int
        public let requestPath: String?
        public let host: String?
        public let proxyHeader: ProxyHeader?

        public init(port: Int = 80, requestPath: String? = "/", host: String? = nil, proxyHeader: ProxyHeader? = nil) {
            self.port = port
            self.requestPath = requestPath
            self.host = host
            self.proxyHeader = proxyHeader
        }

        public enum ProxyHeader: String, Codable, Sendable {
            case none = "NONE"
            case proxyV1 = "PROXY_V1"
        }
    }

    /// HTTPS health check configuration
    public struct HTTPSHealthCheckConfig: Codable, Sendable, Equatable {
        public let port: Int
        public let requestPath: String?
        public let host: String?

        public init(port: Int = 443, requestPath: String? = "/", host: String? = nil) {
            self.port = port
            self.requestPath = requestPath
            self.host = host
        }
    }

    /// TCP health check configuration
    public struct TCPHealthCheckConfig: Codable, Sendable, Equatable {
        public let port: Int
        public let request: String?
        public let response: String?

        public init(port: Int, request: String? = nil, response: String? = nil) {
            self.port = port
            self.request = request
            self.response = response
        }
    }

    /// gRPC health check configuration
    public struct GRPCHealthCheckConfig: Codable, Sendable, Equatable {
        public let port: Int
        public let grpcServiceName: String?

        public init(port: Int = 443, grpcServiceName: String? = nil) {
            self.port = port
            self.grpcServiceName = grpcServiceName
        }
    }
}

// MARK: - Backend Service

/// Represents a Cloud Load Balancing backend service.
///
/// Backend services define how traffic is distributed to backends.
public struct GoogleCloudBackendService: Codable, Sendable, Equatable {
    /// Name of the backend service
    public let name: String

    /// Project ID
    public let projectID: String

    /// Protocol for communicating with backends
    public let `protocol`: BackendProtocol

    /// Port name for named ports
    public let portName: String?

    /// Timeout in seconds
    public let timeoutSec: Int

    /// Health check references
    public let healthChecks: [String]

    /// Description
    public let description: String?

    /// Load balancing scheme
    public let loadBalancingScheme: LoadBalancingScheme

    /// Session affinity
    public let sessionAffinity: SessionAffinity

    /// Affinity cookie TTL
    public let affinityCookieTtlSec: Int?

    /// Connection draining timeout
    public let connectionDrainingTimeoutSec: Int

    /// Enable CDN
    public let enableCDN: Bool

    /// CDN policy
    public let cdnPolicy: CDNPolicy?

    /// IAP configuration
    public let iap: IAPConfig?

    /// Logging configuration
    public let logConfig: LogConfig?

    /// Whether this is a global or regional backend service
    public let isGlobal: Bool

    /// Region for regional backend services
    public let region: String?

    /// Backends
    public let backends: [Backend]

    public init(
        name: String,
        projectID: String,
        protocol: BackendProtocol = .http,
        portName: String? = nil,
        timeoutSec: Int = 30,
        healthChecks: [String] = [],
        description: String? = nil,
        loadBalancingScheme: LoadBalancingScheme = .external,
        sessionAffinity: SessionAffinity = .none,
        affinityCookieTtlSec: Int? = nil,
        connectionDrainingTimeoutSec: Int = 300,
        enableCDN: Bool = false,
        cdnPolicy: CDNPolicy? = nil,
        iap: IAPConfig? = nil,
        logConfig: LogConfig? = nil,
        isGlobal: Bool = true,
        region: String? = nil,
        backends: [Backend] = []
    ) {
        self.name = name
        self.projectID = projectID
        self.protocol = `protocol`
        self.portName = portName
        self.timeoutSec = timeoutSec
        self.healthChecks = healthChecks
        self.description = description
        self.loadBalancingScheme = loadBalancingScheme
        self.sessionAffinity = sessionAffinity
        self.affinityCookieTtlSec = affinityCookieTtlSec
        self.connectionDrainingTimeoutSec = connectionDrainingTimeoutSec
        self.enableCDN = enableCDN
        self.cdnPolicy = cdnPolicy
        self.iap = iap
        self.logConfig = logConfig
        self.isGlobal = isGlobal
        self.region = region
        self.backends = backends
    }

    /// Full resource name
    public var resourceName: String {
        if isGlobal {
            return "projects/\(projectID)/global/backendServices/\(name)"
        } else {
            return "projects/\(projectID)/regions/\(region ?? "")/backendServices/\(name)"
        }
    }

    /// gcloud command to create this backend service
    public var createCommand: String {
        var cmd = "gcloud compute backend-services create \(name)"
        cmd += " --project=\(projectID)"

        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }

        cmd += " --protocol=\(`protocol`.rawValue)"
        cmd += " --timeout=\(timeoutSec)s"
        cmd += " --connection-draining-timeout=\(connectionDrainingTimeoutSec)s"

        if let portName = portName {
            cmd += " --port-name=\(portName)"
        }

        if !healthChecks.isEmpty {
            cmd += " --health-checks=\(healthChecks.joined(separator: ","))"
            if isGlobal {
                cmd += " --global-health-checks"
            }
        }

        cmd += " --load-balancing-scheme=\(loadBalancingScheme.rawValue)"

        if sessionAffinity != .none {
            cmd += " --session-affinity=\(sessionAffinity.rawValue)"
        }

        if enableCDN {
            cmd += " --enable-cdn"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to add a backend
    public func addBackendCommand(backend: Backend) -> String {
        var cmd = "gcloud compute backend-services add-backend \(name)"
        cmd += " --project=\(projectID)"

        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }

        switch backend.group {
        case .instanceGroup(let name, let zone):
            cmd += " --instance-group=\(name)"
            cmd += " --instance-group-zone=\(zone)"
        case .networkEndpointGroup(let name, let zone):
            cmd += " --network-endpoint-group=\(name)"
            if let zone = zone {
                cmd += " --network-endpoint-group-zone=\(zone)"
            }
        case .serverlessNEG(let name, let region):
            cmd += " --network-endpoint-group=\(name)"
            cmd += " --network-endpoint-group-region=\(region)"
        }

        if let mode = backend.balancingMode {
            cmd += " --balancing-mode=\(mode.rawValue)"
        }

        if let capacity = backend.capacityScaler {
            cmd += " --capacity-scaler=\(capacity)"
        }

        if let maxRate = backend.maxRate {
            cmd += " --max-rate=\(maxRate)"
        }

        if let maxRatePerInstance = backend.maxRatePerInstance {
            cmd += " --max-rate-per-instance=\(maxRatePerInstance)"
        }

        if let maxConnections = backend.maxConnections {
            cmd += " --max-connections=\(maxConnections)"
        }

        return cmd
    }

    /// gcloud command to delete this backend service
    public var deleteCommand: String {
        var cmd = "gcloud compute backend-services delete \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe this backend service
    public var describeCommand: String {
        var cmd = "gcloud compute backend-services describe \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to list backend services
    public static func listCommand(projectID: String, global: Bool = true) -> String {
        var cmd = "gcloud compute backend-services list --project=\(projectID)"
        if global {
            cmd += " --global"
        }
        return cmd
    }

    /// Backend protocol
    public enum BackendProtocol: String, Codable, Sendable {
        case http = "HTTP"
        case https = "HTTPS"
        case http2 = "HTTP2"
        case tcp = "TCP"
        case ssl = "SSL"
        case grpc = "GRPC"
        case unspecified = "UNSPECIFIED"
    }

    /// Load balancing scheme
    public enum LoadBalancingScheme: String, Codable, Sendable {
        case external = "EXTERNAL"
        case externalManaged = "EXTERNAL_MANAGED"
        case `internal` = "INTERNAL"
        case internalManaged = "INTERNAL_MANAGED"
        case internalSelfManaged = "INTERNAL_SELF_MANAGED"
    }

    /// Session affinity
    public enum SessionAffinity: String, Codable, Sendable {
        case none = "NONE"
        case clientIp = "CLIENT_IP"
        case clientIpProtocol = "CLIENT_IP_PROTO"
        case clientIpPortProto = "CLIENT_IP_PORT_PROTO"
        case generatedCookie = "GENERATED_COOKIE"
        case headerField = "HEADER_FIELD"
        case httpCookie = "HTTP_COOKIE"
    }

    /// Backend configuration
    public struct Backend: Codable, Sendable, Equatable {
        public let group: BackendGroup
        public let balancingMode: BalancingMode?
        public let capacityScaler: Double?
        public let maxRate: Int?
        public let maxRatePerInstance: Double?
        public let maxConnections: Int?
        public let maxConnectionsPerInstance: Int?

        public init(
            group: BackendGroup,
            balancingMode: BalancingMode? = nil,
            capacityScaler: Double? = 1.0,
            maxRate: Int? = nil,
            maxRatePerInstance: Double? = nil,
            maxConnections: Int? = nil,
            maxConnectionsPerInstance: Int? = nil
        ) {
            self.group = group
            self.balancingMode = balancingMode
            self.capacityScaler = capacityScaler
            self.maxRate = maxRate
            self.maxRatePerInstance = maxRatePerInstance
            self.maxConnections = maxConnections
            self.maxConnectionsPerInstance = maxConnectionsPerInstance
        }

        public enum BackendGroup: Codable, Sendable, Equatable {
            case instanceGroup(name: String, zone: String)
            case networkEndpointGroup(name: String, zone: String?)
            case serverlessNEG(name: String, region: String)
        }

        public enum BalancingMode: String, Codable, Sendable {
            case utilization = "UTILIZATION"
            case rate = "RATE"
            case connection = "CONNECTION"
        }
    }

    /// CDN policy configuration
    public struct CDNPolicy: Codable, Sendable, Equatable {
        public let cacheMode: CacheMode
        public let defaultTtl: Int?
        public let maxTtl: Int?
        public let clientTtl: Int?
        public let negativeCaching: Bool
        public let signedUrlCacheMaxAgeSec: Int?

        public init(
            cacheMode: CacheMode = .cacheAllStatic,
            defaultTtl: Int? = 3600,
            maxTtl: Int? = 86400,
            clientTtl: Int? = nil,
            negativeCaching: Bool = false,
            signedUrlCacheMaxAgeSec: Int? = nil
        ) {
            self.cacheMode = cacheMode
            self.defaultTtl = defaultTtl
            self.maxTtl = maxTtl
            self.clientTtl = clientTtl
            self.negativeCaching = negativeCaching
            self.signedUrlCacheMaxAgeSec = signedUrlCacheMaxAgeSec
        }

        public enum CacheMode: String, Codable, Sendable {
            case cacheAllStatic = "CACHE_ALL_STATIC"
            case useOriginHeaders = "USE_ORIGIN_HEADERS"
            case forceCacheAll = "FORCE_CACHE_ALL"
        }
    }

    /// IAP configuration
    public struct IAPConfig: Codable, Sendable, Equatable {
        public let enabled: Bool
        public let oauth2ClientId: String?
        public let oauth2ClientSecret: String?

        public init(enabled: Bool, oauth2ClientId: String? = nil, oauth2ClientSecret: String? = nil) {
            self.enabled = enabled
            self.oauth2ClientId = oauth2ClientId
            self.oauth2ClientSecret = oauth2ClientSecret
        }
    }

    /// Logging configuration
    public struct LogConfig: Codable, Sendable, Equatable {
        public let enable: Bool
        public let sampleRate: Double

        public init(enable: Bool = true, sampleRate: Double = 1.0) {
            self.enable = enable
            self.sampleRate = sampleRate
        }
    }
}

// MARK: - URL Map

/// Represents a Cloud Load Balancing URL map.
///
/// URL maps route requests to backend services based on URL patterns.
public struct GoogleCloudURLMap: Codable, Sendable, Equatable {
    /// Name of the URL map
    public let name: String

    /// Project ID
    public let projectID: String

    /// Default backend service
    public let defaultService: String

    /// Description
    public let description: String?

    /// Host rules
    public let hostRules: [HostRule]

    /// Path matchers
    public let pathMatchers: [PathMatcher]

    /// Whether this is a global or regional URL map
    public let isGlobal: Bool

    /// Region for regional URL maps
    public let region: String?

    public init(
        name: String,
        projectID: String,
        defaultService: String,
        description: String? = nil,
        hostRules: [HostRule] = [],
        pathMatchers: [PathMatcher] = [],
        isGlobal: Bool = true,
        region: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.defaultService = defaultService
        self.description = description
        self.hostRules = hostRules
        self.pathMatchers = pathMatchers
        self.isGlobal = isGlobal
        self.region = region
    }

    /// Full resource name
    public var resourceName: String {
        if isGlobal {
            return "projects/\(projectID)/global/urlMaps/\(name)"
        } else {
            return "projects/\(projectID)/regions/\(region ?? "")/urlMaps/\(name)"
        }
    }

    /// gcloud command to create this URL map
    public var createCommand: String {
        var cmd = "gcloud compute url-maps create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --default-service=\(defaultService)"

        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to add a path matcher
    public func addPathMatcherCommand(pathMatcher: PathMatcher, hosts: [String]) -> String {
        var cmd = "gcloud compute url-maps add-path-matcher \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --path-matcher-name=\(pathMatcher.name)"
        cmd += " --default-service=\(pathMatcher.defaultService)"

        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }

        if !hosts.isEmpty {
            cmd += " --new-hosts=\(hosts.joined(separator: ","))"
        }

        if !pathMatcher.pathRules.isEmpty {
            let paths = pathMatcher.pathRules.map { "\($0.paths.joined(separator: ","))=\($0.service)" }.joined(separator: ",")
            cmd += " --path-rules=\(paths)"
        }

        return cmd
    }

    /// gcloud command to delete this URL map
    public var deleteCommand: String {
        var cmd = "gcloud compute url-maps delete \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe this URL map
    public var describeCommand: String {
        var cmd = "gcloud compute url-maps describe \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to list URL maps
    public static func listCommand(projectID: String, global: Bool = true) -> String {
        var cmd = "gcloud compute url-maps list --project=\(projectID)"
        if global {
            cmd += " --global"
        }
        return cmd
    }

    /// Host rule
    public struct HostRule: Codable, Sendable, Equatable {
        public let hosts: [String]
        public let pathMatcher: String

        public init(hosts: [String], pathMatcher: String) {
            self.hosts = hosts
            self.pathMatcher = pathMatcher
        }
    }

    /// Path matcher
    public struct PathMatcher: Codable, Sendable, Equatable {
        public let name: String
        public let defaultService: String
        public let pathRules: [PathRule]

        public init(name: String, defaultService: String, pathRules: [PathRule] = []) {
            self.name = name
            self.defaultService = defaultService
            self.pathRules = pathRules
        }
    }

    /// Path rule
    public struct PathRule: Codable, Sendable, Equatable {
        public let paths: [String]
        public let service: String

        public init(paths: [String], service: String) {
            self.paths = paths
            self.service = service
        }
    }
}

// MARK: - Target Proxy

/// Represents a target HTTP(S) proxy for load balancing.
public struct GoogleCloudTargetProxy: Codable, Sendable, Equatable {
    /// Name of the target proxy
    public let name: String

    /// Project ID
    public let projectID: String

    /// Type of proxy
    public let type: ProxyType

    /// URL map reference
    public let urlMap: String?

    /// SSL certificates (for HTTPS proxies)
    public let sslCertificates: [String]

    /// SSL policy (for HTTPS proxies)
    public let sslPolicy: String?

    /// Backend service (for TCP/SSL proxies)
    public let backendService: String?

    /// Description
    public let description: String?

    /// Whether this is a global or regional proxy
    public let isGlobal: Bool

    /// Region for regional proxies
    public let region: String?

    public init(
        name: String,
        projectID: String,
        type: ProxyType,
        urlMap: String? = nil,
        sslCertificates: [String] = [],
        sslPolicy: String? = nil,
        backendService: String? = nil,
        description: String? = nil,
        isGlobal: Bool = true,
        region: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.type = type
        self.urlMap = urlMap
        self.sslCertificates = sslCertificates
        self.sslPolicy = sslPolicy
        self.backendService = backendService
        self.description = description
        self.isGlobal = isGlobal
        self.region = region
    }

    /// Full resource name
    public var resourceName: String {
        let typePrefix = type.resourcePrefix
        if isGlobal {
            return "projects/\(projectID)/global/\(typePrefix)/\(name)"
        } else {
            return "projects/\(projectID)/regions/\(region ?? "")/\(typePrefix)/\(name)"
        }
    }

    /// gcloud command to create this target proxy
    public var createCommand: String {
        var cmd = "gcloud compute target-\(type.gcloudType)-proxies create \(name)"
        cmd += " --project=\(projectID)"

        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }

        switch type {
        case .http:
            if let urlMap = urlMap {
                cmd += " --url-map=\(urlMap)"
                if isGlobal {
                    cmd += " --global-url-map"
                }
            }
        case .https:
            if let urlMap = urlMap {
                cmd += " --url-map=\(urlMap)"
                if isGlobal {
                    cmd += " --global-url-map"
                }
            }
            if !sslCertificates.isEmpty {
                cmd += " --ssl-certificates=\(sslCertificates.joined(separator: ","))"
            }
            if let sslPolicy = sslPolicy {
                cmd += " --ssl-policy=\(sslPolicy)"
            }
        case .tcp:
            if let backend = backendService {
                cmd += " --backend-service=\(backend)"
            }
        case .ssl:
            if let backend = backendService {
                cmd += " --backend-service=\(backend)"
            }
            if !sslCertificates.isEmpty {
                cmd += " --ssl-certificates=\(sslCertificates.joined(separator: ","))"
            }
        case .grpc:
            if let urlMap = urlMap {
                cmd += " --url-map=\(urlMap)"
            }
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to delete this target proxy
    public var deleteCommand: String {
        var cmd = "gcloud compute target-\(type.gcloudType)-proxies delete \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// Proxy type
    public enum ProxyType: String, Codable, Sendable {
        case http = "HTTP"
        case https = "HTTPS"
        case tcp = "TCP"
        case ssl = "SSL"
        case grpc = "GRPC"

        var gcloudType: String {
            rawValue.lowercased()
        }

        var resourcePrefix: String {
            "target\(rawValue.capitalized)Proxies"
        }
    }
}

// MARK: - Forwarding Rule

/// Represents a Cloud Load Balancing forwarding rule.
///
/// Forwarding rules route traffic to target proxies or backend services.
public struct GoogleCloudForwardingRule: Codable, Sendable, Equatable {
    /// Name of the forwarding rule
    public let name: String

    /// Project ID
    public let projectID: String

    /// IP address (or empty for ephemeral)
    public let ipAddress: String?

    /// IP protocol
    public let ipProtocol: IPProtocol

    /// Port range
    public let portRange: String?

    /// Ports (for internal load balancers)
    public let ports: [String]

    /// Target (target proxy or backend service)
    public let target: String

    /// Load balancing scheme
    public let loadBalancingScheme: LoadBalancingScheme

    /// Network (for internal load balancers)
    public let network: String?

    /// Subnetwork (for internal load balancers)
    public let subnetwork: String?

    /// Description
    public let description: String?

    /// Whether this is a global or regional forwarding rule
    public let isGlobal: Bool

    /// Region for regional forwarding rules
    public let region: String?

    /// Network tier
    public let networkTier: NetworkTier

    /// Allow global access (for internal load balancers)
    public let allowGlobalAccess: Bool

    public init(
        name: String,
        projectID: String,
        ipAddress: String? = nil,
        ipProtocol: IPProtocol = .tcp,
        portRange: String? = nil,
        ports: [String] = [],
        target: String,
        loadBalancingScheme: LoadBalancingScheme = .external,
        network: String? = nil,
        subnetwork: String? = nil,
        description: String? = nil,
        isGlobal: Bool = true,
        region: String? = nil,
        networkTier: NetworkTier = .premium,
        allowGlobalAccess: Bool = false
    ) {
        self.name = name
        self.projectID = projectID
        self.ipAddress = ipAddress
        self.ipProtocol = ipProtocol
        self.portRange = portRange
        self.ports = ports
        self.target = target
        self.loadBalancingScheme = loadBalancingScheme
        self.network = network
        self.subnetwork = subnetwork
        self.description = description
        self.isGlobal = isGlobal
        self.region = region
        self.networkTier = networkTier
        self.allowGlobalAccess = allowGlobalAccess
    }

    /// Full resource name
    public var resourceName: String {
        if isGlobal {
            return "projects/\(projectID)/global/forwardingRules/\(name)"
        } else {
            return "projects/\(projectID)/regions/\(region ?? "")/forwardingRules/\(name)"
        }
    }

    /// gcloud command to create this forwarding rule
    public var createCommand: String {
        var cmd = "gcloud compute forwarding-rules create \(name)"
        cmd += " --project=\(projectID)"

        if isGlobal {
            cmd += " --global"
            cmd += " --target-\(targetType)-proxy=\(target)"
            cmd += " --global-target-\(targetType)-proxy"
        } else if let region = region {
            cmd += " --region=\(region)"
            cmd += " --target-\(targetType)-proxy=\(target)"
            cmd += " --target-\(targetType)-proxy-region=\(region)"
        }

        if let ipAddress = ipAddress {
            cmd += " --address=\(ipAddress)"
        }

        if let portRange = portRange {
            cmd += " --ports=\(portRange)"
        } else if !ports.isEmpty {
            cmd += " --ports=\(ports.joined(separator: ","))"
        }

        cmd += " --load-balancing-scheme=\(loadBalancingScheme.rawValue)"
        cmd += " --network-tier=\(networkTier.rawValue)"

        if let network = network {
            cmd += " --network=\(network)"
        }

        if let subnetwork = subnetwork {
            cmd += " --subnet=\(subnetwork)"
        }

        if allowGlobalAccess {
            cmd += " --allow-global-access"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to delete this forwarding rule
    public var deleteCommand: String {
        var cmd = "gcloud compute forwarding-rules delete \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe this forwarding rule
    public var describeCommand: String {
        var cmd = "gcloud compute forwarding-rules describe \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to list forwarding rules
    public static func listCommand(projectID: String, global: Bool = true, region: String? = nil) -> String {
        var cmd = "gcloud compute forwarding-rules list --project=\(projectID)"
        if global {
            cmd += " --global"
        } else if let region = region {
            cmd += " --regions=\(region)"
        }
        return cmd
    }

    /// Helper to determine target type from target string
    private var targetType: String {
        if target.contains("https") { return "https" }
        if target.contains("http") { return "http" }
        if target.contains("ssl") { return "ssl" }
        if target.contains("tcp") { return "tcp" }
        if target.contains("grpc") { return "grpc" }
        return "http"
    }

    /// IP protocol
    public enum IPProtocol: String, Codable, Sendable {
        case tcp = "TCP"
        case udp = "UDP"
        case esp = "ESP"
        case ah = "AH"
        case sctp = "SCTP"
        case icmp = "ICMP"
    }

    /// Load balancing scheme
    public enum LoadBalancingScheme: String, Codable, Sendable {
        case external = "EXTERNAL"
        case externalManaged = "EXTERNAL_MANAGED"
        case `internal` = "INTERNAL"
        case internalManaged = "INTERNAL_MANAGED"
        case internalSelfManaged = "INTERNAL_SELF_MANAGED"
    }

    /// Network tier
    public enum NetworkTier: String, Codable, Sendable {
        case premium = "PREMIUM"
        case standard = "STANDARD"
    }
}

// MARK: - SSL Certificate

/// Represents a Cloud Load Balancing SSL certificate.
public struct GoogleCloudSSLCertificate: Codable, Sendable, Equatable {
    /// Name of the certificate
    public let name: String

    /// Project ID
    public let projectID: String

    /// Certificate type
    public let type: CertificateType

    /// Domains for managed certificates
    public let domains: [String]

    /// Certificate file path (for self-managed)
    public let certificatePath: String?

    /// Private key file path (for self-managed)
    public let privateKeyPath: String?

    /// Description
    public let description: String?

    /// Whether this is a global or regional certificate
    public let isGlobal: Bool

    /// Region for regional certificates
    public let region: String?

    public init(
        name: String,
        projectID: String,
        type: CertificateType = .managed,
        domains: [String] = [],
        certificatePath: String? = nil,
        privateKeyPath: String? = nil,
        description: String? = nil,
        isGlobal: Bool = true,
        region: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.type = type
        self.domains = domains
        self.certificatePath = certificatePath
        self.privateKeyPath = privateKeyPath
        self.description = description
        self.isGlobal = isGlobal
        self.region = region
    }

    /// Full resource name
    public var resourceName: String {
        if isGlobal {
            return "projects/\(projectID)/global/sslCertificates/\(name)"
        } else {
            return "projects/\(projectID)/regions/\(region ?? "")/sslCertificates/\(name)"
        }
    }

    /// gcloud command to create this certificate
    public var createCommand: String {
        var cmd: String

        switch type {
        case .managed:
            cmd = "gcloud compute ssl-certificates create \(name)"
            cmd += " --project=\(projectID)"
            if isGlobal {
                cmd += " --global"
            } else if let region = region {
                cmd += " --region=\(region)"
            }
            if !domains.isEmpty {
                cmd += " --domains=\(domains.joined(separator: ","))"
            }
        case .selfManaged:
            cmd = "gcloud compute ssl-certificates create \(name)"
            cmd += " --project=\(projectID)"
            if isGlobal {
                cmd += " --global"
            } else if let region = region {
                cmd += " --region=\(region)"
            }
            if let cert = certificatePath {
                cmd += " --certificate=\(cert)"
            }
            if let key = privateKeyPath {
                cmd += " --private-key=\(key)"
            }
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to delete this certificate
    public var deleteCommand: String {
        var cmd = "gcloud compute ssl-certificates delete \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to describe this certificate
    public var describeCommand: String {
        var cmd = "gcloud compute ssl-certificates describe \(name) --project=\(projectID)"
        if isGlobal {
            cmd += " --global"
        } else if let region = region {
            cmd += " --region=\(region)"
        }
        return cmd
    }

    /// gcloud command to list SSL certificates
    public static func listCommand(projectID: String, global: Bool = true) -> String {
        var cmd = "gcloud compute ssl-certificates list --project=\(projectID)"
        if global {
            cmd += " --global"
        }
        return cmd
    }

    /// Certificate type
    public enum CertificateType: String, Codable, Sendable {
        case managed = "MANAGED"
        case selfManaged = "SELF_MANAGED"
    }
}

// MARK: - SSL Policy

/// Represents a Cloud Load Balancing SSL policy.
public struct GoogleCloudSSLPolicy: Codable, Sendable, Equatable {
    /// Name of the SSL policy
    public let name: String

    /// Project ID
    public let projectID: String

    /// Minimum TLS version
    public let minTlsVersion: TLSVersion

    /// Profile
    public let profile: Profile

    /// Custom features (when profile is CUSTOM)
    public let customFeatures: [String]

    /// Description
    public let description: String?

    public init(
        name: String,
        projectID: String,
        minTlsVersion: TLSVersion = .tls12,
        profile: Profile = .modern,
        customFeatures: [String] = [],
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.minTlsVersion = minTlsVersion
        self.profile = profile
        self.customFeatures = customFeatures
        self.description = description
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/sslPolicies/\(name)"
    }

    /// gcloud command to create this SSL policy
    public var createCommand: String {
        var cmd = "gcloud compute ssl-policies create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --min-tls-version=\(minTlsVersion.rawValue)"
        cmd += " --profile=\(profile.rawValue)"

        if profile == .custom && !customFeatures.isEmpty {
            cmd += " --custom-features=\(customFeatures.joined(separator: ","))"
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to delete this SSL policy
    public var deleteCommand: String {
        "gcloud compute ssl-policies delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe this SSL policy
    public var describeCommand: String {
        "gcloud compute ssl-policies describe \(name) --project=\(projectID)"
    }

    /// gcloud command to list SSL policies
    public static func listCommand(projectID: String) -> String {
        "gcloud compute ssl-policies list --project=\(projectID)"
    }

    /// TLS version
    public enum TLSVersion: String, Codable, Sendable {
        case tls10 = "TLS_1_0"
        case tls11 = "TLS_1_1"
        case tls12 = "TLS_1_2"
        case tls13 = "TLS_1_3"
    }

    /// SSL policy profile
    public enum Profile: String, Codable, Sendable {
        case compatible = "COMPATIBLE"
        case modern = "MODERN"
        case restricted = "RESTRICTED"
        case custom = "CUSTOM"
    }
}

// MARK: - Network Endpoint Group

/// Represents a Network Endpoint Group (NEG).
public struct GoogleCloudNetworkEndpointGroup: Codable, Sendable, Equatable {
    /// Name of the NEG
    public let name: String

    /// Project ID
    public let projectID: String

    /// NEG type
    public let type: NEGType

    /// Network
    public let network: String?

    /// Subnetwork
    public let subnetwork: String?

    /// Default port
    public let defaultPort: Int?

    /// Zone (for zonal NEGs)
    public let zone: String?

    /// Region (for regional/serverless NEGs)
    public let region: String?

    /// Cloud Run service (for serverless NEGs)
    public let cloudRunService: String?

    /// Cloud Functions function (for serverless NEGs)
    public let cloudFunction: String?

    /// App Engine service (for serverless NEGs)
    public let appEngineService: String?

    /// Description
    public let description: String?

    public init(
        name: String,
        projectID: String,
        type: NEGType,
        network: String? = nil,
        subnetwork: String? = nil,
        defaultPort: Int? = nil,
        zone: String? = nil,
        region: String? = nil,
        cloudRunService: String? = nil,
        cloudFunction: String? = nil,
        appEngineService: String? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.type = type
        self.network = network
        self.subnetwork = subnetwork
        self.defaultPort = defaultPort
        self.zone = zone
        self.region = region
        self.cloudRunService = cloudRunService
        self.cloudFunction = cloudFunction
        self.appEngineService = appEngineService
        self.description = description
    }

    /// Full resource name
    public var resourceName: String {
        switch type {
        case .zonalGCE, .zonalNonGCP:
            return "projects/\(projectID)/zones/\(zone ?? "")/networkEndpointGroups/\(name)"
        case .serverless, .privateServiceConnect:
            return "projects/\(projectID)/regions/\(region ?? "")/networkEndpointGroups/\(name)"
        case .internet:
            return "projects/\(projectID)/global/networkEndpointGroups/\(name)"
        }
    }

    /// gcloud command to create this NEG
    public var createCommand: String {
        var cmd = "gcloud compute network-endpoint-groups create \(name)"
        cmd += " --project=\(projectID)"

        switch type {
        case .zonalGCE:
            if let zone = zone {
                cmd += " --zone=\(zone)"
            }
            cmd += " --network-endpoint-type=GCE_VM_IP_PORT"
            if let network = network {
                cmd += " --network=\(network)"
            }
            if let subnet = subnetwork {
                cmd += " --subnet=\(subnet)"
            }
            if let port = defaultPort {
                cmd += " --default-port=\(port)"
            }

        case .zonalNonGCP:
            if let zone = zone {
                cmd += " --zone=\(zone)"
            }
            cmd += " --network-endpoint-type=NON_GCP_PRIVATE_IP_PORT"
            if let network = network {
                cmd += " --network=\(network)"
            }

        case .serverless:
            if let region = region {
                cmd += " --region=\(region)"
            }
            cmd += " --network-endpoint-type=SERVERLESS"
            if let cloudRun = cloudRunService {
                cmd += " --cloud-run-service=\(cloudRun)"
            }
            if let function = cloudFunction {
                cmd += " --cloud-function-name=\(function)"
            }
            if let appEngine = appEngineService {
                cmd += " --app-engine-service=\(appEngine)"
            }

        case .internet:
            cmd += " --global"
            cmd += " --network-endpoint-type=INTERNET_FQDN_PORT"

        case .privateServiceConnect:
            if let region = region {
                cmd += " --region=\(region)"
            }
            cmd += " --network-endpoint-type=PRIVATE_SERVICE_CONNECT"
            if let subnet = subnetwork {
                cmd += " --psc-target-service=\(subnet)"
            }
        }

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        return cmd
    }

    /// gcloud command to delete this NEG
    public var deleteCommand: String {
        var cmd = "gcloud compute network-endpoint-groups delete \(name) --project=\(projectID)"
        switch type {
        case .zonalGCE, .zonalNonGCP:
            if let zone = zone {
                cmd += " --zone=\(zone)"
            }
        case .serverless, .privateServiceConnect:
            if let region = region {
                cmd += " --region=\(region)"
            }
        case .internet:
            cmd += " --global"
        }
        cmd += " --quiet"
        return cmd
    }

    /// gcloud command to list NEGs
    public static func listCommand(projectID: String, zone: String? = nil, region: String? = nil) -> String {
        var cmd = "gcloud compute network-endpoint-groups list --project=\(projectID)"
        if let zone = zone {
            cmd += " --zones=\(zone)"
        }
        if let region = region {
            cmd += " --regions=\(region)"
        }
        return cmd
    }

    /// NEG type
    public enum NEGType: String, Codable, Sendable {
        case zonalGCE = "ZONAL_GCE"
        case zonalNonGCP = "ZONAL_NON_GCP"
        case serverless = "SERVERLESS"
        case internet = "INTERNET"
        case privateServiceConnect = "PRIVATE_SERVICE_CONNECT"
    }
}

// MARK: - DAIS Load Balancing Templates

/// Predefined load balancing configurations for DAIS deployments.
public enum DAISLoadBalancingTemplate {
    /// Create a health check for HTTP services
    public static func httpHealthCheck(
        projectID: String,
        deploymentName: String,
        port: Int = 8080,
        path: String = "/health"
    ) -> GoogleCloudHealthCheck {
        GoogleCloudHealthCheck(
            name: "\(deploymentName)-http-hc",
            projectID: projectID,
            type: .http,
            checkIntervalSec: 5,
            timeoutSec: 5,
            healthyThreshold: 2,
            unhealthyThreshold: 3,
            description: "HTTP health check for \(deploymentName)",
            httpHealthCheck: .init(port: port, requestPath: path)
        )
    }

    /// Create a health check for gRPC services
    public static func grpcHealthCheck(
        projectID: String,
        deploymentName: String,
        port: Int = 9090
    ) -> GoogleCloudHealthCheck {
        GoogleCloudHealthCheck(
            name: "\(deploymentName)-grpc-hc",
            projectID: projectID,
            type: .grpc,
            checkIntervalSec: 5,
            timeoutSec: 5,
            healthyThreshold: 2,
            unhealthyThreshold: 3,
            description: "gRPC health check for \(deploymentName)",
            grpcHealthCheck: .init(port: port, grpcServiceName: "grpc.health.v1.Health")
        )
    }

    /// Create a backend service for HTTP
    public static func httpBackendService(
        projectID: String,
        deploymentName: String,
        healthCheckName: String
    ) -> GoogleCloudBackendService {
        GoogleCloudBackendService(
            name: "\(deploymentName)-http-backend",
            projectID: projectID,
            protocol: .http,
            portName: "http",
            timeoutSec: 30,
            healthChecks: [healthCheckName],
            description: "HTTP backend service for \(deploymentName)",
            loadBalancingScheme: .externalManaged,
            sessionAffinity: .none,
            connectionDrainingTimeoutSec: 300,
            logConfig: .init(enable: true, sampleRate: 1.0)
        )
    }

    /// Create a backend service for gRPC
    public static func grpcBackendService(
        projectID: String,
        deploymentName: String,
        healthCheckName: String
    ) -> GoogleCloudBackendService {
        GoogleCloudBackendService(
            name: "\(deploymentName)-grpc-backend",
            projectID: projectID,
            protocol: .grpc,
            portName: "grpc",
            timeoutSec: 60,
            healthChecks: [healthCheckName],
            description: "gRPC backend service for \(deploymentName)",
            loadBalancingScheme: .externalManaged,
            sessionAffinity: .none,
            connectionDrainingTimeoutSec: 300,
            logConfig: .init(enable: true, sampleRate: 1.0)
        )
    }

    /// Create a URL map
    public static func urlMap(
        projectID: String,
        deploymentName: String,
        defaultBackendService: String
    ) -> GoogleCloudURLMap {
        GoogleCloudURLMap(
            name: "\(deploymentName)-url-map",
            projectID: projectID,
            defaultService: defaultBackendService,
            description: "URL map for \(deploymentName)"
        )
    }

    /// Create a managed SSL certificate
    public static func sslCertificate(
        projectID: String,
        deploymentName: String,
        domains: [String]
    ) -> GoogleCloudSSLCertificate {
        GoogleCloudSSLCertificate(
            name: "\(deploymentName)-cert",
            projectID: projectID,
            type: .managed,
            domains: domains,
            description: "SSL certificate for \(deploymentName)"
        )
    }

    /// Create an SSL policy with modern settings
    public static func sslPolicy(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudSSLPolicy {
        GoogleCloudSSLPolicy(
            name: "\(deploymentName)-ssl-policy",
            projectID: projectID,
            minTlsVersion: .tls12,
            profile: .modern,
            description: "SSL policy for \(deploymentName)"
        )
    }

    /// Create an HTTPS target proxy
    public static func httpsTargetProxy(
        projectID: String,
        deploymentName: String,
        urlMapName: String,
        sslCertificateName: String,
        sslPolicyName: String? = nil
    ) -> GoogleCloudTargetProxy {
        GoogleCloudTargetProxy(
            name: "\(deploymentName)-https-proxy",
            projectID: projectID,
            type: .https,
            urlMap: urlMapName,
            sslCertificates: [sslCertificateName],
            sslPolicy: sslPolicyName,
            description: "HTTPS proxy for \(deploymentName)"
        )
    }

    /// Create an HTTP target proxy (for redirect)
    public static func httpTargetProxy(
        projectID: String,
        deploymentName: String,
        urlMapName: String
    ) -> GoogleCloudTargetProxy {
        GoogleCloudTargetProxy(
            name: "\(deploymentName)-http-proxy",
            projectID: projectID,
            type: .http,
            urlMap: urlMapName,
            description: "HTTP proxy for \(deploymentName) (redirect)"
        )
    }

    /// Create an HTTPS forwarding rule
    public static func httpsForwardingRule(
        projectID: String,
        deploymentName: String,
        targetProxyName: String,
        ipAddress: String? = nil
    ) -> GoogleCloudForwardingRule {
        GoogleCloudForwardingRule(
            name: "\(deploymentName)-https-rule",
            projectID: projectID,
            ipAddress: ipAddress,
            ipProtocol: .tcp,
            portRange: "443",
            target: targetProxyName,
            loadBalancingScheme: .externalManaged,
            description: "HTTPS forwarding rule for \(deploymentName)",
            networkTier: .premium
        )
    }

    /// Create an HTTP forwarding rule (for redirect)
    public static func httpForwardingRule(
        projectID: String,
        deploymentName: String,
        targetProxyName: String,
        ipAddress: String? = nil
    ) -> GoogleCloudForwardingRule {
        GoogleCloudForwardingRule(
            name: "\(deploymentName)-http-rule",
            projectID: projectID,
            ipAddress: ipAddress,
            ipProtocol: .tcp,
            portRange: "80",
            target: targetProxyName,
            loadBalancingScheme: .externalManaged,
            description: "HTTP forwarding rule for \(deploymentName)",
            networkTier: .premium
        )
    }

    /// Create a serverless NEG for Cloud Run
    public static func cloudRunNEG(
        projectID: String,
        deploymentName: String,
        region: String,
        cloudRunServiceName: String
    ) -> GoogleCloudNetworkEndpointGroup {
        GoogleCloudNetworkEndpointGroup(
            name: "\(deploymentName)-cloudrun-neg",
            projectID: projectID,
            type: .serverless,
            region: region,
            cloudRunService: cloudRunServiceName,
            description: "Serverless NEG for Cloud Run service"
        )
    }

    /// Generate a complete HTTPS load balancer setup script
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        domains: [String],
        cloudRunServiceName: String,
        region: String
    ) -> String {
        let healthCheck = httpHealthCheck(projectID: projectID, deploymentName: deploymentName)
        let neg = cloudRunNEG(projectID: projectID, deploymentName: deploymentName, region: region, cloudRunServiceName: cloudRunServiceName)
        let backendService = httpBackendService(projectID: projectID, deploymentName: deploymentName, healthCheckName: healthCheck.name)
        let urlMap = urlMap(projectID: projectID, deploymentName: deploymentName, defaultBackendService: backendService.name)
        let cert = sslCertificate(projectID: projectID, deploymentName: deploymentName, domains: domains)
        let sslPolicy = sslPolicy(projectID: projectID, deploymentName: deploymentName)
        let httpsProxy = httpsTargetProxy(projectID: projectID, deploymentName: deploymentName, urlMapName: urlMap.name, sslCertificateName: cert.name, sslPolicyName: sslPolicy.name)
        let httpsRule = httpsForwardingRule(projectID: projectID, deploymentName: deploymentName, targetProxyName: httpsProxy.name)

        return """
        #!/bin/bash
        # DAIS Load Balancer Setup Script
        # Deployment: \(deploymentName)
        # Domains: \(domains.joined(separator: ", "))

        set -e

        echo "========================================"
        echo "DAIS Load Balancer Configuration"
        echo "========================================"

        # Reserve static IP
        echo "Reserving static IP address..."
        gcloud compute addresses create \(deploymentName)-ip \\
            --project=\(projectID) \\
            --global \\
            --ip-version=IPV4

        IP_ADDRESS=$(gcloud compute addresses describe \(deploymentName)-ip --project=\(projectID) --global --format="value(address)")
        echo "Reserved IP: $IP_ADDRESS"

        # Create serverless NEG
        echo "Creating serverless NEG..."
        \(neg.createCommand)

        # Create health check
        echo "Creating health check..."
        \(healthCheck.createCommand)

        # Create backend service
        echo "Creating backend service..."
        \(backendService.createCommand)

        # Add backend to service
        echo "Adding backend..."
        gcloud compute backend-services add-backend \(backendService.name) \\
            --project=\(projectID) \\
            --global \\
            --network-endpoint-group=\(neg.name) \\
            --network-endpoint-group-region=\(region)

        # Create URL map
        echo "Creating URL map..."
        \(urlMap.createCommand)

        # Create SSL certificate
        echo "Creating SSL certificate..."
        \(cert.createCommand)

        # Create SSL policy
        echo "Creating SSL policy..."
        \(sslPolicy.createCommand)

        # Create HTTPS target proxy
        echo "Creating HTTPS target proxy..."
        \(httpsProxy.createCommand)

        # Create forwarding rule
        echo "Creating forwarding rule..."
        gcloud compute forwarding-rules create \(httpsRule.name) \\
            --project=\(projectID) \\
            --global \\
            --address=$IP_ADDRESS \\
            --target-https-proxy=\(httpsProxy.name) \\
            --ports=443 \\
            --load-balancing-scheme=EXTERNAL_MANAGED \\
            --network-tier=PREMIUM

        echo ""
        echo "========================================"
        echo "Load Balancer Setup Complete!"
        echo "========================================"
        echo ""
        echo "IP Address: $IP_ADDRESS"
        echo "Domains: \(domains.joined(separator: ", "))"
        echo ""
        echo "IMPORTANT: Add these DNS records:"
        \(domains.map { "echo \"  \($0) -> $IP_ADDRESS\"" }.joined(separator: "\n"))
        echo ""
        echo "SSL certificate provisioning may take up to 60 minutes."
        echo "Check status with:"
        echo "  gcloud compute ssl-certificates describe \(cert.name) --project=\(projectID) --global"
        """
    }

    /// Generate a teardown script
    public static func teardownScript(
        projectID: String,
        deploymentName: String,
        region: String
    ) -> String {
        """
        #!/bin/bash
        # DAIS Load Balancer Teardown Script
        # WARNING: This will delete the entire load balancer configuration!

        set -e

        echo "Deleting forwarding rules..."
        gcloud compute forwarding-rules delete \(deploymentName)-https-rule --project=\(projectID) --global --quiet || true
        gcloud compute forwarding-rules delete \(deploymentName)-http-rule --project=\(projectID) --global --quiet || true

        echo "Deleting target proxies..."
        gcloud compute target-https-proxies delete \(deploymentName)-https-proxy --project=\(projectID) --global --quiet || true
        gcloud compute target-http-proxies delete \(deploymentName)-http-proxy --project=\(projectID) --global --quiet || true

        echo "Deleting SSL policy..."
        gcloud compute ssl-policies delete \(deploymentName)-ssl-policy --project=\(projectID) --quiet || true

        echo "Deleting SSL certificate..."
        gcloud compute ssl-certificates delete \(deploymentName)-cert --project=\(projectID) --global --quiet || true

        echo "Deleting URL map..."
        gcloud compute url-maps delete \(deploymentName)-url-map --project=\(projectID) --global --quiet || true

        echo "Deleting backend service..."
        gcloud compute backend-services delete \(deploymentName)-http-backend --project=\(projectID) --global --quiet || true
        gcloud compute backend-services delete \(deploymentName)-grpc-backend --project=\(projectID) --global --quiet || true

        echo "Deleting health checks..."
        gcloud compute health-checks delete \(deploymentName)-http-hc --project=\(projectID) --global --quiet || true
        gcloud compute health-checks delete \(deploymentName)-grpc-hc --project=\(projectID) --global --quiet || true

        echo "Deleting serverless NEG..."
        gcloud compute network-endpoint-groups delete \(deploymentName)-cloudrun-neg --project=\(projectID) --region=\(region) --quiet || true

        echo "Releasing static IP..."
        gcloud compute addresses delete \(deploymentName)-ip --project=\(projectID) --global --quiet || true

        echo "Load balancer teardown complete!"
        """
    }
}
