// GoogleCloudArmor.swift
// Cloud Armor API models for WAF and DDoS protection

import Foundation

// MARK: - Security Policy

/// Represents a Cloud Armor security policy
public struct GoogleCloudSecurityPolicy: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let description: String?
    public let type: PolicyType
    public let rules: [SecurityPolicyRule]
    public let adaptiveProtectionConfig: AdaptiveProtectionConfig?
    public let advancedOptionsConfig: AdvancedOptionsConfig?
    public let ddosProtectionConfig: DDoSProtectionConfig?
    public let recaptchaOptionsConfig: RecaptchaOptionsConfig?
    public let labels: [String: String]

    /// Policy type
    public enum PolicyType: String, Codable, Sendable, Equatable {
        case cloudArmor = "CLOUD_ARMOR"
        case cloudArmorEdge = "CLOUD_ARMOR_EDGE"
        case cloudArmorNetwork = "CLOUD_ARMOR_NETWORK"
    }

    /// Adaptive protection configuration
    public struct AdaptiveProtectionConfig: Codable, Sendable, Equatable {
        public let layer7DdosDefenseConfig: Layer7DdosDefenseConfig?

        public struct Layer7DdosDefenseConfig: Codable, Sendable, Equatable {
            public let enable: Bool
            public let ruleVisibility: RuleVisibility?

            public enum RuleVisibility: String, Codable, Sendable, Equatable {
                case standard = "STANDARD"
                case premium = "PREMIUM"
            }

            public init(enable: Bool, ruleVisibility: RuleVisibility? = nil) {
                self.enable = enable
                self.ruleVisibility = ruleVisibility
            }
        }

        public init(layer7DdosDefenseConfig: Layer7DdosDefenseConfig?) {
            self.layer7DdosDefenseConfig = layer7DdosDefenseConfig
        }
    }

    /// Advanced options configuration
    public struct AdvancedOptionsConfig: Codable, Sendable, Equatable {
        public let jsonParsing: JSONParsing?
        public let jsonCustomConfig: JSONCustomConfig?
        public let logLevel: LogLevel?
        public let userIpRequestHeaders: [String]

        public enum JSONParsing: String, Codable, Sendable, Equatable {
            case disabled = "DISABLED"
            case standard = "STANDARD"
            case standardWithGraphql = "STANDARD_WITH_GRAPHQL"
        }

        public struct JSONCustomConfig: Codable, Sendable, Equatable {
            public let contentTypes: [String]

            public init(contentTypes: [String]) {
                self.contentTypes = contentTypes
            }
        }

        public enum LogLevel: String, Codable, Sendable, Equatable {
            case normal = "NORMAL"
            case verbose = "VERBOSE"
        }

        public init(
            jsonParsing: JSONParsing? = nil,
            jsonCustomConfig: JSONCustomConfig? = nil,
            logLevel: LogLevel? = nil,
            userIpRequestHeaders: [String] = []
        ) {
            self.jsonParsing = jsonParsing
            self.jsonCustomConfig = jsonCustomConfig
            self.logLevel = logLevel
            self.userIpRequestHeaders = userIpRequestHeaders
        }
    }

    /// DDoS protection configuration
    public struct DDoSProtectionConfig: Codable, Sendable, Equatable {
        public let ddosProtection: DDoSProtection

        public enum DDoSProtection: String, Codable, Sendable, Equatable {
            case standard = "STANDARD"
            case advanced = "ADVANCED"
        }

        public init(ddosProtection: DDoSProtection) {
            self.ddosProtection = ddosProtection
        }
    }

    /// reCAPTCHA options configuration
    public struct RecaptchaOptionsConfig: Codable, Sendable, Equatable {
        public let redirectSiteKey: String?

        public init(redirectSiteKey: String?) {
            self.redirectSiteKey = redirectSiteKey
        }
    }

    public init(
        name: String,
        projectID: String,
        description: String? = nil,
        type: PolicyType = .cloudArmor,
        rules: [SecurityPolicyRule] = [],
        adaptiveProtectionConfig: AdaptiveProtectionConfig? = nil,
        advancedOptionsConfig: AdvancedOptionsConfig? = nil,
        ddosProtectionConfig: DDoSProtectionConfig? = nil,
        recaptchaOptionsConfig: RecaptchaOptionsConfig? = nil,
        labels: [String: String] = [:]
    ) {
        self.name = name
        self.projectID = projectID
        self.description = description
        self.type = type
        self.rules = rules
        self.adaptiveProtectionConfig = adaptiveProtectionConfig
        self.advancedOptionsConfig = advancedOptionsConfig
        self.ddosProtectionConfig = ddosProtectionConfig
        self.recaptchaOptionsConfig = recaptchaOptionsConfig
        self.labels = labels
    }

    /// Full resource name
    public var resourceName: String {
        "projects/\(projectID)/global/securityPolicies/\(name)"
    }

    /// gcloud command to create the security policy
    public var createCommand: String {
        var cmd = "gcloud compute security-policies create \(name)"
        cmd += " --project=\(projectID)"

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        if type != .cloudArmor {
            cmd += " --type=\(type.rawValue)"
        }

        return cmd
    }

    /// gcloud command to delete the security policy
    public var deleteCommand: String {
        "gcloud compute security-policies delete \(name) --project=\(projectID) --quiet"
    }

    /// gcloud command to describe the security policy
    public var describeCommand: String {
        "gcloud compute security-policies describe \(name) --project=\(projectID)"
    }

    /// gcloud command to update the security policy
    public func updateCommand(
        enableAdaptiveProtection: Bool? = nil,
        logLevel: AdvancedOptionsConfig.LogLevel? = nil,
        jsonParsing: AdvancedOptionsConfig.JSONParsing? = nil
    ) -> String {
        var cmd = "gcloud compute security-policies update \(name)"
        cmd += " --project=\(projectID)"

        if let enable = enableAdaptiveProtection {
            cmd += " --enable-layer7-ddos-defense=\(enable)"
        }

        if let level = logLevel {
            cmd += " --log-level=\(level.rawValue)"
        }

        if let parsing = jsonParsing {
            cmd += " --json-parsing=\(parsing.rawValue)"
        }

        return cmd
    }

    /// gcloud command to list security policies
    public static func listCommand(projectID: String) -> String {
        "gcloud compute security-policies list --project=\(projectID)"
    }

    /// gcloud command to export the policy to YAML
    public var exportCommand: String {
        "gcloud compute security-policies export \(name) --project=\(projectID) --file-name=\(name)-policy.yaml"
    }

    /// gcloud command to import the policy from YAML
    public static func importCommand(name: String, projectID: String, fileName: String) -> String {
        "gcloud compute security-policies import \(name) --project=\(projectID) --file-name=\(fileName)"
    }
}

// MARK: - Security Policy Rule

/// Represents a rule within a security policy
public struct SecurityPolicyRule: Codable, Sendable, Equatable {
    public let priority: Int
    public let description: String?
    public let match: Match
    public let action: Action
    public let preview: Bool
    public let rateLimitOptions: RateLimitOptions?
    public let redirectOptions: RedirectOptions?
    public let headerAction: HeaderAction?

    /// Match condition
    public struct Match: Codable, Sendable, Equatable {
        public let versionedExpr: VersionedExpr?
        public let expr: Expr?
        public let config: Config?

        public enum VersionedExpr: String, Codable, Sendable, Equatable {
            case srcIpsV1 = "SRC_IPS_V1"
        }

        public struct Expr: Codable, Sendable, Equatable {
            public let expression: String

            public init(expression: String) {
                self.expression = expression
            }
        }

        public struct Config: Codable, Sendable, Equatable {
            public let srcIpRanges: [String]

            public init(srcIpRanges: [String]) {
                self.srcIpRanges = srcIpRanges
            }
        }

        public init(
            versionedExpr: VersionedExpr? = nil,
            expr: Expr? = nil,
            config: Config? = nil
        ) {
            self.versionedExpr = versionedExpr
            self.expr = expr
            self.config = config
        }

        /// Create a match for IP ranges
        public static func ipRanges(_ ranges: [String]) -> Match {
            Match(versionedExpr: .srcIpsV1, config: .init(srcIpRanges: ranges))
        }

        /// Create a match using CEL expression
        public static func expression(_ expr: String) -> Match {
            Match(expr: .init(expression: expr))
        }
    }

    /// Rule action
    public enum Action: String, Codable, Sendable, Equatable {
        case allow = "allow"
        case deny403 = "deny(403)"
        case deny404 = "deny(404)"
        case deny502 = "deny(502)"
        case redirect = "redirect"
        case rateBased = "rate_based_ban"
        case throttle = "throttle"
    }

    /// Rate limiting options
    public struct RateLimitOptions: Codable, Sendable, Equatable {
        public let rateLimitThreshold: RateLimitThreshold?
        public let conformAction: String?
        public let exceedAction: String?
        public let exceedRedirectOptions: RedirectOptions?
        public let enforceOnKey: EnforceOnKey?
        public let enforceOnKeyName: String?
        public let enforceOnKeyConfigs: [EnforceOnKeyConfig]
        public let banThreshold: RateLimitThreshold?
        public let banDurationSec: Int?

        public struct RateLimitThreshold: Codable, Sendable, Equatable {
            public let count: Int
            public let intervalSec: Int

            public init(count: Int, intervalSec: Int) {
                self.count = count
                self.intervalSec = intervalSec
            }
        }

        public enum EnforceOnKey: String, Codable, Sendable, Equatable {
            case all = "ALL"
            case ip = "IP"
            case httpHeader = "HTTP_HEADER"
            case xffIP = "XFF_IP"
            case httpCookie = "HTTP_COOKIE"
            case httpPath = "HTTP_PATH"
            case sni = "SNI"
            case regionCode = "REGION_CODE"
        }

        public struct EnforceOnKeyConfig: Codable, Sendable, Equatable {
            public let enforceOnKeyType: EnforceOnKey
            public let enforceOnKeyName: String?

            public init(enforceOnKeyType: EnforceOnKey, enforceOnKeyName: String? = nil) {
                self.enforceOnKeyType = enforceOnKeyType
                self.enforceOnKeyName = enforceOnKeyName
            }
        }

        public init(
            rateLimitThreshold: RateLimitThreshold? = nil,
            conformAction: String? = nil,
            exceedAction: String? = nil,
            exceedRedirectOptions: RedirectOptions? = nil,
            enforceOnKey: EnforceOnKey? = nil,
            enforceOnKeyName: String? = nil,
            enforceOnKeyConfigs: [EnforceOnKeyConfig] = [],
            banThreshold: RateLimitThreshold? = nil,
            banDurationSec: Int? = nil
        ) {
            self.rateLimitThreshold = rateLimitThreshold
            self.conformAction = conformAction
            self.exceedAction = exceedAction
            self.exceedRedirectOptions = exceedRedirectOptions
            self.enforceOnKey = enforceOnKey
            self.enforceOnKeyName = enforceOnKeyName
            self.enforceOnKeyConfigs = enforceOnKeyConfigs
            self.banThreshold = banThreshold
            self.banDurationSec = banDurationSec
        }
    }

    /// Redirect options
    public struct RedirectOptions: Codable, Sendable, Equatable {
        public let type: RedirectType
        public let target: String?

        public enum RedirectType: String, Codable, Sendable, Equatable {
            case externalRedirect302 = "EXTERNAL_302"
            case googleRecaptcha = "GOOGLE_RECAPTCHA"
        }

        public init(type: RedirectType, target: String? = nil) {
            self.type = type
            self.target = target
        }
    }

    /// Header action
    public struct HeaderAction: Codable, Sendable, Equatable {
        public let requestHeadersToAdds: [RequestHeader]

        public struct RequestHeader: Codable, Sendable, Equatable {
            public let headerName: String
            public let headerValue: String

            public init(headerName: String, headerValue: String) {
                self.headerName = headerName
                self.headerValue = headerValue
            }
        }

        public init(requestHeadersToAdds: [RequestHeader]) {
            self.requestHeadersToAdds = requestHeadersToAdds
        }
    }

    public init(
        priority: Int,
        description: String? = nil,
        match: Match,
        action: Action,
        preview: Bool = false,
        rateLimitOptions: RateLimitOptions? = nil,
        redirectOptions: RedirectOptions? = nil,
        headerAction: HeaderAction? = nil
    ) {
        self.priority = priority
        self.description = description
        self.match = match
        self.action = action
        self.preview = preview
        self.rateLimitOptions = rateLimitOptions
        self.redirectOptions = redirectOptions
        self.headerAction = headerAction
    }

    /// gcloud command to add this rule to a policy
    public func addRuleCommand(policyName: String, projectID: String) -> String {
        var cmd = "gcloud compute security-policies rules create \(priority)"
        cmd += " --security-policy=\(policyName)"
        cmd += " --project=\(projectID)"
        cmd += " --action=\(action.rawValue)"

        if let desc = description {
            cmd += " --description=\"\(desc)\""
        }

        // Handle match conditions
        if let config = match.config {
            cmd += " --src-ip-ranges=\(config.srcIpRanges.joined(separator: ","))"
        } else if let expr = match.expr {
            cmd += " --expression=\"\(expr.expression)\""
        }

        if preview {
            cmd += " --preview"
        }

        return cmd
    }

    /// gcloud command to update this rule
    public func updateRuleCommand(policyName: String, projectID: String) -> String {
        var cmd = "gcloud compute security-policies rules update \(priority)"
        cmd += " --security-policy=\(policyName)"
        cmd += " --project=\(projectID)"
        cmd += " --action=\(action.rawValue)"

        if let config = match.config {
            cmd += " --src-ip-ranges=\(config.srcIpRanges.joined(separator: ","))"
        } else if let expr = match.expr {
            cmd += " --expression=\"\(expr.expression)\""
        }

        return cmd
    }

    /// gcloud command to delete this rule
    public func deleteRuleCommand(policyName: String, projectID: String) -> String {
        "gcloud compute security-policies rules delete \(priority) --security-policy=\(policyName) --project=\(projectID) --quiet"
    }
}

// MARK: - WAF Rules (Preconfigured)

/// Preconfigured WAF rule expressions
public enum WAFRule: String, Codable, Sendable, Equatable {
    // OWASP ModSecurity Core Rule Set
    case sqli = "evaluatePreconfiguredExpr('sqli-v33-stable')"
    case sqliCanary = "evaluatePreconfiguredExpr('sqli-v33-canary')"
    case xss = "evaluatePreconfiguredExpr('xss-v33-stable')"
    case xssCanary = "evaluatePreconfiguredExpr('xss-v33-canary')"
    case lfi = "evaluatePreconfiguredExpr('lfi-v33-stable')"
    case lfiCanary = "evaluatePreconfiguredExpr('lfi-v33-canary')"
    case rfi = "evaluatePreconfiguredExpr('rfi-v33-stable')"
    case rfiCanary = "evaluatePreconfiguredExpr('rfi-v33-canary')"
    case rce = "evaluatePreconfiguredExpr('rce-v33-stable')"
    case rceCanary = "evaluatePreconfiguredExpr('rce-v33-canary')"
    case methodEnforcement = "evaluatePreconfiguredExpr('methodenforcement-v33-stable')"
    case scannerDetection = "evaluatePreconfiguredExpr('scannerdetection-v33-stable')"
    case protocolAttack = "evaluatePreconfiguredExpr('protocolattack-v33-stable')"
    case php = "evaluatePreconfiguredExpr('php-v33-stable')"
    case sessionFixation = "evaluatePreconfiguredExpr('sessionfixation-v33-stable')"
    case java = "evaluatePreconfiguredExpr('java-v33-stable')"
    case nodejs = "evaluatePreconfiguredExpr('nodejs-v33-stable')"

    // CVE rules
    case cve202144228 = "evaluatePreconfiguredExpr('cve-canary', ['owasp-crs-v030301-id044228-cve'])" // Log4j
    case cve202145046 = "evaluatePreconfiguredExpr('cve-canary', ['owasp-crs-v030301-id044229-cve'])" // Log4j

    // JSON-based attacks
    case jsonSqli = "evaluatePreconfiguredExpr('json-sqli-canary')"
    case jsonXss = "evaluatePreconfiguredExpr('json-xss-canary')"

    /// Human-readable description
    public var description: String {
        switch self {
        case .sqli, .sqliCanary:
            return "SQL Injection protection"
        case .xss, .xssCanary:
            return "Cross-Site Scripting (XSS) protection"
        case .lfi, .lfiCanary:
            return "Local File Inclusion protection"
        case .rfi, .rfiCanary:
            return "Remote File Inclusion protection"
        case .rce, .rceCanary:
            return "Remote Code Execution protection"
        case .methodEnforcement:
            return "HTTP Method Enforcement"
        case .scannerDetection:
            return "Scanner/Bot Detection"
        case .protocolAttack:
            return "Protocol Attack protection"
        case .php:
            return "PHP Injection protection"
        case .sessionFixation:
            return "Session Fixation protection"
        case .java:
            return "Java Attack protection"
        case .nodejs:
            return "Node.js Attack protection"
        case .cve202144228, .cve202145046:
            return "Log4j CVE protection"
        case .jsonSqli:
            return "JSON SQL Injection protection"
        case .jsonXss:
            return "JSON XSS protection"
        }
    }

    /// Recommended sensitivity level (1-4, higher = more sensitive)
    public var recommendedSensitivity: Int {
        switch self {
        case .sqli, .xss, .rce, .cve202144228, .cve202145046:
            return 1 // High priority, enable at level 1
        case .lfi, .rfi, .php, .java:
            return 2
        case .protocolAttack, .sessionFixation, .nodejs:
            return 3
        case .sqliCanary, .xssCanary, .lfiCanary, .rfiCanary, .rceCanary:
            return 4 // Canary rules, use for testing
        case .methodEnforcement, .scannerDetection, .jsonSqli, .jsonXss:
            return 3
        }
    }
}

// MARK: - Common CEL Expressions

/// Common CEL (Common Expression Language) patterns for security rules
public enum SecurityExpressions {
    /// Block requests from specific countries
    public static func blockCountries(_ countryCodes: [String]) -> String {
        let codes = countryCodes.map { "'\($0)'" }.joined(separator: ", ")
        return "origin.region_code in [\(codes)]"
    }

    /// Allow only specific countries
    public static func allowOnlyCountries(_ countryCodes: [String]) -> String {
        let codes = countryCodes.map { "'\($0)'" }.joined(separator: ", ")
        return "!(origin.region_code in [\(codes)])"
    }

    /// Block requests to specific paths
    public static func blockPaths(_ paths: [String]) -> String {
        let pathExprs = paths.map { "request.path.matches('\($0)')" }.joined(separator: " || ")
        return pathExprs
    }

    /// Block requests with specific user agents
    public static func blockUserAgents(_ patterns: [String]) -> String {
        let uaExprs = patterns.map { "request.headers['user-agent'].matches('\($0)')" }.joined(separator: " || ")
        return uaExprs
    }

    /// Block known bad bots
    public static var blockBadBots: String {
        "request.headers['user-agent'].matches('.*(?i)(bot|crawl|spider|scrape).*') && !request.headers['user-agent'].matches('.*(?i)(googlebot|bingbot|yandexbot).*')"
    }

    /// Block requests without user agent
    public static var blockEmptyUserAgent: String {
        "!has(request.headers['user-agent']) || request.headers['user-agent'] == ''"
    }

    /// Block requests from Tor exit nodes (requires IP list)
    public static var blockTorExitNodes: String {
        "inIpRange(origin.ip, '0.0.0.0/0')" // Placeholder - use actual Tor exit node IP list
    }

    /// Rate limit by IP
    public static var allTraffic: String {
        "true"
    }

    /// Match specific HTTP methods
    public static func matchMethods(_ methods: [String]) -> String {
        let methodExprs = methods.map { "request.method == '\($0)'" }.joined(separator: " || ")
        return methodExprs
    }

    /// Block requests with suspicious headers
    public static var blockSuspiciousHeaders: String {
        "has(request.headers['x-forwarded-host']) || has(request.headers['x-original-url']) || has(request.headers['x-rewrite-url'])"
    }

    /// Match requests to API paths
    public static func matchAPIPaths(prefix: String = "/api") -> String {
        "request.path.startsWith('\(prefix)')"
    }

    /// Combine WAF rules with AND
    public static func combineWAFRules(_ rules: [WAFRule]) -> String {
        rules.map { $0.rawValue }.joined(separator: " || ")
    }
}

// MARK: - Cloud Armor Operations

/// Cloud Armor operations and utility commands
public enum CloudArmorOperations {
    /// Enable Cloud Armor API
    public static func enableAPICommand(projectID: String) -> String {
        "gcloud services enable compute.googleapis.com --project=\(projectID)"
    }

    /// Attach security policy to backend service
    public static func attachToBackendService(
        policyName: String,
        backendServiceName: String,
        projectID: String,
        global: Bool = true
    ) -> String {
        var cmd = "gcloud compute backend-services update \(backendServiceName)"
        cmd += " --project=\(projectID)"
        cmd += " --security-policy=\(policyName)"
        if global {
            cmd += " --global"
        }
        return cmd
    }

    /// Detach security policy from backend service
    public static func detachFromBackendService(
        backendServiceName: String,
        projectID: String,
        global: Bool = true
    ) -> String {
        var cmd = "gcloud compute backend-services update \(backendServiceName)"
        cmd += " --project=\(projectID)"
        cmd += " --security-policy="
        if global {
            cmd += " --global"
        }
        return cmd
    }

    /// Attach edge security policy to backend service
    public static func attachEdgePolicy(
        policyName: String,
        backendServiceName: String,
        projectID: String
    ) -> String {
        var cmd = "gcloud compute backend-services update \(backendServiceName)"
        cmd += " --project=\(projectID)"
        cmd += " --edge-security-policy=\(policyName)"
        cmd += " --global"
        return cmd
    }

    /// List security policy rules
    public static func listRulesCommand(policyName: String, projectID: String) -> String {
        "gcloud compute security-policies rules list --security-policy=\(policyName) --project=\(projectID)"
    }

    /// Describe a specific rule
    public static func describeRuleCommand(
        priority: Int,
        policyName: String,
        projectID: String
    ) -> String {
        "gcloud compute security-policies rules describe \(priority) --security-policy=\(policyName) --project=\(projectID)"
    }

    /// View security policy logs
    public static func viewLogsCommand(
        projectID: String,
        policyName: String? = nil,
        limit: Int = 100
    ) -> String {
        var filter = "resource.type=\"http_load_balancer\""
        if let policy = policyName {
            filter += " AND jsonPayload.enforcedSecurityPolicy.name=\"\(policy)\""
        }
        return "gcloud logging read '\(filter)' --project=\(projectID) --limit=\(limit) --format=json"
    }

    /// View blocked requests
    public static func viewBlockedRequestsCommand(projectID: String, limit: Int = 100) -> String {
        let filter = "resource.type=\"http_load_balancer\" AND jsonPayload.enforcedSecurityPolicy.outcome=\"DENY\""
        return "gcloud logging read '\(filter)' --project=\(projectID) --limit=\(limit) --format=json"
    }

    /// Create a rate limiting rule
    public static func createRateLimitRule(
        policyName: String,
        projectID: String,
        priority: Int,
        requestsPerInterval: Int,
        intervalSec: Int,
        enforceOnKey: SecurityPolicyRule.RateLimitOptions.EnforceOnKey = .ip,
        exceedAction: String = "deny(429)",
        banDurationSec: Int? = nil
    ) -> String {
        var cmd = "gcloud compute security-policies rules create \(priority)"
        cmd += " --security-policy=\(policyName)"
        cmd += " --project=\(projectID)"
        cmd += " --action=throttle"
        cmd += " --rate-limit-threshold-count=\(requestsPerInterval)"
        cmd += " --rate-limit-threshold-interval-sec=\(intervalSec)"
        cmd += " --conform-action=allow"
        cmd += " --exceed-action=\(exceedAction)"
        cmd += " --enforce-on-key=\(enforceOnKey.rawValue)"

        if let ban = banDurationSec {
            cmd += " --ban-duration-sec=\(ban)"
        }

        cmd += " --expression=\"true\""

        return cmd
    }

    /// Add a preconfigured WAF rule
    public static func addWAFRule(
        policyName: String,
        projectID: String,
        priority: Int,
        wafRule: WAFRule,
        action: SecurityPolicyRule.Action = .deny403,
        preview: Bool = false
    ) -> String {
        var cmd = "gcloud compute security-policies rules create \(priority)"
        cmd += " --security-policy=\(policyName)"
        cmd += " --project=\(projectID)"
        cmd += " --action=\(action.rawValue)"
        cmd += " --expression=\"\(wafRule.rawValue)\""

        if preview {
            cmd += " --preview"
        }

        return cmd
    }
}

// MARK: - DAIS Cloud Armor Templates

/// Pre-configured Cloud Armor templates for DAIS deployments
public enum DAISCloudArmorTemplate {
    /// Create a security policy with OWASP protection
    public static func securityPolicy(
        projectID: String,
        deploymentName: String
    ) -> GoogleCloudSecurityPolicy {
        GoogleCloudSecurityPolicy(
            name: "\(deploymentName)-security-policy",
            projectID: projectID,
            description: "Security policy for \(deploymentName) DAIS deployment",
            type: .cloudArmor,
            adaptiveProtectionConfig: .init(
                layer7DdosDefenseConfig: .init(enable: true, ruleVisibility: .standard)
            ),
            advancedOptionsConfig: .init(
                jsonParsing: .standard,
                logLevel: .normal
            ),
            labels: ["deployment": deploymentName, "managed-by": "dais"]
        )
    }

    /// Default allow rule (lowest priority)
    public static func defaultAllowRule() -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: 2147483647,
            description: "Default allow rule",
            match: .ipRanges(["*"]),
            action: .allow
        )
    }

    /// Block common attack patterns (SQLi, XSS, etc.)
    public static func owaspProtectionRule(priority: Int = 1000) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "OWASP Core Rule Set - SQLi and XSS protection",
            match: .expression("\(WAFRule.sqli.rawValue) || \(WAFRule.xss.rawValue)"),
            action: .deny403
        )
    }

    /// Block remote code execution attempts
    public static func rceProtectionRule(priority: Int = 1100) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "Remote Code Execution protection",
            match: .expression("\(WAFRule.rce.rawValue) || \(WAFRule.lfi.rawValue) || \(WAFRule.rfi.rawValue)"),
            action: .deny403
        )
    }

    /// Log4j CVE protection
    public static func log4jProtectionRule(priority: Int = 900) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "Log4j CVE-2021-44228 protection",
            match: .expression(WAFRule.cve202144228.rawValue),
            action: .deny403
        )
    }

    /// Rate limiting rule for API endpoints
    public static func apiRateLimitRule(
        priority: Int = 2000,
        requestsPerMinute: Int = 100
    ) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "API rate limiting - \(requestsPerMinute) requests/minute",
            match: .expression(SecurityExpressions.matchAPIPaths()),
            action: .throttle,
            rateLimitOptions: .init(
                rateLimitThreshold: .init(count: requestsPerMinute, intervalSec: 60),
                conformAction: "allow",
                exceedAction: "deny(429)",
                enforceOnKey: .ip
            )
        )
    }

    /// Block suspicious countries (configurable)
    public static func geoBlockRule(
        priority: Int = 500,
        blockedCountries: [String]
    ) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "Block traffic from specified countries",
            match: .expression(SecurityExpressions.blockCountries(blockedCountries)),
            action: .deny403
        )
    }

    /// Allow only specific countries
    public static func geoAllowRule(
        priority: Int = 500,
        allowedCountries: [String]
    ) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "Allow traffic only from specified countries",
            match: .expression(SecurityExpressions.allowOnlyCountries(allowedCountries)),
            action: .deny403
        )
    }

    /// Block bad bots
    public static func botProtectionRule(priority: Int = 1500) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "Block malicious bots and scrapers",
            match: .expression(SecurityExpressions.blockBadBots),
            action: .deny403
        )
    }

    /// Aggressive rate limiting for login endpoints
    public static func loginRateLimitRule(
        priority: Int = 1800,
        loginPath: String = "/login",
        requestsPerMinute: Int = 10,
        banDurationSec: Int = 600
    ) -> SecurityPolicyRule {
        SecurityPolicyRule(
            priority: priority,
            description: "Login rate limiting with ban",
            match: .expression("request.path.matches('\(loginPath)')"),
            action: .rateBased,
            rateLimitOptions: .init(
                rateLimitThreshold: .init(count: requestsPerMinute, intervalSec: 60),
                conformAction: "allow",
                exceedAction: "deny(429)",
                enforceOnKey: .ip,
                banThreshold: .init(count: requestsPerMinute * 2, intervalSec: 60),
                banDurationSec: banDurationSec
            )
        )
    }

    /// Complete setup script for DAIS deployment
    public static func setupScript(
        projectID: String,
        deploymentName: String,
        backendServiceName: String,
        enableGeoBlocking: Bool = false,
        blockedCountries: [String] = []
    ) -> String {
        var script = """
        #!/bin/bash
        set -e

        # DAIS Cloud Armor Setup Script
        # Project: \(projectID)
        # Deployment: \(deploymentName)

        POLICY_NAME="\(deploymentName)-security-policy"

        echo "Creating Cloud Armor security policy..."
        gcloud compute security-policies create $POLICY_NAME \\
            --project=\(projectID) \\
            --description="Security policy for \(deploymentName) DAIS deployment"

        echo "Enabling adaptive protection..."
        gcloud compute security-policies update $POLICY_NAME \\
            --project=\(projectID) \\
            --enable-layer7-ddos-defense

        echo "Adding OWASP protection rules..."

        # Log4j protection (highest priority)
        gcloud compute security-policies rules create 900 \\
            --security-policy=$POLICY_NAME \\
            --project=\(projectID) \\
            --action=deny-403 \\
            --expression="\(WAFRule.cve202144228.rawValue)" \\
            --description="Log4j CVE protection"

        # SQL Injection and XSS protection
        gcloud compute security-policies rules create 1000 \\
            --security-policy=$POLICY_NAME \\
            --project=\(projectID) \\
            --action=deny-403 \\
            --expression="\(WAFRule.sqli.rawValue) || \(WAFRule.xss.rawValue)" \\
            --description="SQLi and XSS protection"

        # Remote Code Execution protection
        gcloud compute security-policies rules create 1100 \\
            --security-policy=$POLICY_NAME \\
            --project=\(projectID) \\
            --action=deny-403 \\
            --expression="\(WAFRule.rce.rawValue) || \(WAFRule.lfi.rawValue) || \(WAFRule.rfi.rawValue)" \\
            --description="RCE/LFI/RFI protection"

        """

        if enableGeoBlocking && !blockedCountries.isEmpty {
            let countryCodes = blockedCountries.map { "'\($0)'" }.joined(separator: ", ")
            script += """

            # Geo-blocking
            gcloud compute security-policies rules create 500 \\
                --security-policy=$POLICY_NAME \\
                --project=\(projectID) \\
                --action=deny-403 \\
                --expression="origin.region_code in [\(countryCodes)]" \\
                --description="Block traffic from specified countries"

            """
        }

        script += """

        # API rate limiting
        gcloud compute security-policies rules create 2000 \\
            --security-policy=$POLICY_NAME \\
            --project=\(projectID) \\
            --action=throttle \\
            --rate-limit-threshold-count=100 \\
            --rate-limit-threshold-interval-sec=60 \\
            --conform-action=allow \\
            --exceed-action=deny-429 \\
            --enforce-on-key=IP \\
            --expression="request.path.startsWith('/api')" \\
            --description="API rate limiting"

        echo "Attaching policy to backend service..."
        gcloud compute backend-services update \(backendServiceName) \\
            --project=\(projectID) \\
            --security-policy=$POLICY_NAME \\
            --global

        echo ""
        echo "Cloud Armor Setup Complete!"
        echo ""
        echo "Security Policy: $POLICY_NAME"
        echo "Protected Backend: \(backendServiceName)"
        echo ""
        echo "View policy: gcloud compute security-policies describe $POLICY_NAME --project=\(projectID)"
        echo "View logs: gcloud logging read 'resource.type=\\"http_load_balancer\\"' --project=\(projectID) --limit=10"
        """

        return script
    }

    /// Teardown script
    public static func teardownScript(
        projectID: String,
        deploymentName: String,
        backendServiceName: String
    ) -> String {
        """
        #!/bin/bash
        set -e

        # DAIS Cloud Armor Teardown Script

        POLICY_NAME="\(deploymentName)-security-policy"

        echo "Detaching security policy from backend service..."
        gcloud compute backend-services update \(backendServiceName) \\
            --project=\(projectID) \\
            --security-policy= \\
            --global || true

        echo "Deleting security policy..."
        gcloud compute security-policies delete $POLICY_NAME \\
            --project=\(projectID) \\
            --quiet || true

        echo "Cloud Armor teardown complete!"
        """
    }

    /// Generate comprehensive security policy YAML
    public static func policyYAML(
        projectID: String,
        deploymentName: String,
        enableAdaptiveProtection: Bool = true,
        enableWAF: Bool = true,
        enableRateLimiting: Bool = true,
        rateLimit: Int = 100
    ) -> String {
        var yaml = """
        # Cloud Armor Security Policy for \(deploymentName)
        # Generated by GoogleCloudSwift

        name: \(deploymentName)-security-policy
        description: "Comprehensive security policy for \(deploymentName) DAIS deployment"

        adaptiveProtectionConfig:
          layer7DdosDefenseConfig:
            enable: \(enableAdaptiveProtection)
            ruleVisibility: STANDARD

        advancedOptionsConfig:
          jsonParsing: STANDARD
          logLevel: NORMAL

        rules:
        """

        if enableWAF {
            yaml += """

          # Log4j CVE Protection
          - priority: 900
            action: deny(403)
            match:
              expr:
                expression: "\(WAFRule.cve202144228.rawValue)"
            description: "Log4j CVE-2021-44228 protection"

          # SQL Injection Protection
          - priority: 1000
            action: deny(403)
            match:
              expr:
                expression: "\(WAFRule.sqli.rawValue)"
            description: "SQL Injection protection"

          # XSS Protection
          - priority: 1001
            action: deny(403)
            match:
              expr:
                expression: "\(WAFRule.xss.rawValue)"
            description: "Cross-Site Scripting protection"

          # RCE Protection
          - priority: 1100
            action: deny(403)
            match:
              expr:
                expression: "\(WAFRule.rce.rawValue)"
            description: "Remote Code Execution protection"

          # LFI/RFI Protection
          - priority: 1101
            action: deny(403)
            match:
              expr:
                expression: "\(WAFRule.lfi.rawValue) || \(WAFRule.rfi.rawValue)"
            description: "Local/Remote File Inclusion protection"

        """
        }

        if enableRateLimiting {
            yaml += """

          # API Rate Limiting
          - priority: 2000
            action: throttle
            match:
              expr:
                expression: "request.path.startsWith('/api')"
            description: "API rate limiting"
            rateLimitOptions:
              rateLimitThreshold:
                count: \(rateLimit)
                intervalSec: 60
              conformAction: allow
              exceedAction: deny(429)
              enforceOnKey: IP

        """
        }

        yaml += """

          # Default Allow Rule
          - priority: 2147483647
            action: allow
            match:
              versionedExpr: SRC_IPS_V1
              config:
                srcIpRanges:
                  - "*"
            description: "Default allow rule"
        """

        return yaml
    }
}
