import Foundation

// MARK: - API Gateway

/// Represents a Google Cloud API Gateway API definition
public struct GoogleCloudAPIGatewayAPI: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let displayName: String?
    public let managedService: String?
    public let labels: [String: String]?
    public let createTime: Date?
    public let updateTime: Date?
    public let state: APIState?

    public enum APIState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case active = "ACTIVE"
        case failed = "FAILED"
        case deleting = "DELETING"
        case updating = "UPDATING"
    }

    public init(
        name: String,
        projectID: String,
        displayName: String? = nil,
        managedService: String? = nil,
        labels: [String: String]? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil,
        state: APIState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.displayName = displayName
        self.managedService = managedService
        self.labels = labels
        self.createTime = createTime
        self.updateTime = updateTime
        self.state = state
    }

    /// Resource name in the format projects/{project}/locations/global/apis/{api}
    public var resourceName: String {
        "projects/\(projectID)/locations/global/apis/\(name)"
    }

    /// Command to create the API
    public var createCommand: String {
        var cmd = "gcloud api-gateway apis create \(name) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }
        return cmd
    }

    /// Command to delete the API
    public var deleteCommand: String {
        "gcloud api-gateway apis delete \(name) --project=\(projectID) --quiet"
    }

    /// Command to describe the API
    public var describeCommand: String {
        "gcloud api-gateway apis describe \(name) --project=\(projectID)"
    }

    /// Command to update the API
    public var updateCommand: String {
        var cmd = "gcloud api-gateway apis update \(name) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }
        return cmd
    }
}

// MARK: - API Gateway Config

/// Represents an API Gateway configuration (OpenAPI spec)
public struct GoogleCloudAPIGatewayConfig: Codable, Sendable, Equatable {
    public let name: String
    public let apiName: String
    public let projectID: String
    public let displayName: String?
    public let gatewayServiceAccount: String?
    public let labels: [String: String]?
    public let openAPIDocuments: [OpenAPIDocument]?
    public let grpcServices: [GRPCServiceDefinition]?
    public let serviceConfigID: String?
    public let state: ConfigState?
    public let createTime: Date?
    public let updateTime: Date?

    public struct OpenAPIDocument: Codable, Sendable, Equatable {
        public let path: String
        public let contents: String?

        public init(path: String, contents: String? = nil) {
            self.path = path
            self.contents = contents
        }
    }

    public struct GRPCServiceDefinition: Codable, Sendable, Equatable {
        public let fileDescriptorSet: String
        public let source: [String]

        public init(fileDescriptorSet: String, source: [String]) {
            self.fileDescriptorSet = fileDescriptorSet
            self.source = source
        }
    }

    public enum ConfigState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case active = "ACTIVE"
        case failed = "FAILED"
        case deleting = "DELETING"
        case updating = "UPDATING"
        case activating = "ACTIVATING"
    }

    public init(
        name: String,
        apiName: String,
        projectID: String,
        displayName: String? = nil,
        gatewayServiceAccount: String? = nil,
        labels: [String: String]? = nil,
        openAPIDocuments: [OpenAPIDocument]? = nil,
        grpcServices: [GRPCServiceDefinition]? = nil,
        serviceConfigID: String? = nil,
        state: ConfigState? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.apiName = apiName
        self.projectID = projectID
        self.displayName = displayName
        self.gatewayServiceAccount = gatewayServiceAccount
        self.labels = labels
        self.openAPIDocuments = openAPIDocuments
        self.grpcServices = grpcServices
        self.serviceConfigID = serviceConfigID
        self.state = state
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name for the config
    public var resourceName: String {
        "projects/\(projectID)/locations/global/apis/\(apiName)/configs/\(name)"
    }

    /// Command to create the config
    public func createCommand(openAPISpec: String) -> String {
        var cmd = "gcloud api-gateway api-configs create \(name) --api=\(apiName) --project=\(projectID) --openapi-spec=\(openAPISpec)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let sa = gatewayServiceAccount {
            cmd += " --backend-auth-service-account=\(sa)"
        }
        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }
        return cmd
    }

    /// Command to create the config with gRPC
    public func createGRPCCommand(protoDescriptor: String, serviceConfig: String) -> String {
        var cmd = "gcloud api-gateway api-configs create \(name) --api=\(apiName) --project=\(projectID)"
        cmd += " --grpc-files=\(protoDescriptor),\(serviceConfig)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let sa = gatewayServiceAccount {
            cmd += " --backend-auth-service-account=\(sa)"
        }
        return cmd
    }

    /// Command to delete the config
    public var deleteCommand: String {
        "gcloud api-gateway api-configs delete \(name) --api=\(apiName) --project=\(projectID) --quiet"
    }

    /// Command to describe the config
    public var describeCommand: String {
        "gcloud api-gateway api-configs describe \(name) --api=\(apiName) --project=\(projectID)"
    }
}

// MARK: - API Gateway Gateway

/// Represents an API Gateway gateway resource
public struct GoogleCloudAPIGatewayGateway: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let apiConfig: String
    public let displayName: String?
    public let labels: [String: String]?
    public let defaultHostname: String?
    public let state: GatewayState?
    public let createTime: Date?
    public let updateTime: Date?

    public enum GatewayState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case creating = "CREATING"
        case active = "ACTIVE"
        case failed = "FAILED"
        case deleting = "DELETING"
        case updating = "UPDATING"
    }

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        apiConfig: String,
        displayName: String? = nil,
        labels: [String: String]? = nil,
        defaultHostname: String? = nil,
        state: GatewayState? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.apiConfig = apiConfig
        self.displayName = displayName
        self.labels = labels
        self.defaultHostname = defaultHostname
        self.state = state
        self.createTime = createTime
        self.updateTime = updateTime
    }

    /// Resource name for the gateway
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/gateways/\(name)"
    }

    /// Command to create the gateway
    public var createCommand: String {
        var cmd = "gcloud api-gateway gateways create \(name) --api-config=\(apiConfig) --location=\(location) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }
        return cmd
    }

    /// Command to delete the gateway
    public var deleteCommand: String {
        "gcloud api-gateway gateways delete \(name) --location=\(location) --project=\(projectID) --quiet"
    }

    /// Command to describe the gateway
    public var describeCommand: String {
        "gcloud api-gateway gateways describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to update the gateway
    public func updateCommand(newApiConfig: String) -> String {
        var cmd = "gcloud api-gateway gateways update \(name) --api-config=\(newApiConfig) --location=\(location) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name='\(displayName)'"
        }
        return cmd
    }

    /// The public URL of the gateway
    public var publicURL: String {
        if let hostname = defaultHostname {
            return "https://\(hostname)"
        }
        return "https://\(name)-\(projectID.hashValue.magnitude % 10000000).gateway.\(location).cloud.goog"
    }
}

// MARK: - OpenAPI Spec Builder

/// Helper for building OpenAPI 2.0 specifications for API Gateway
public struct OpenAPISpecBuilder: Sendable {
    public let title: String
    public let description: String?
    public let version: String
    public var host: String
    public var basePath: String
    public var schemes: [String]
    public var consumes: [String]
    public var produces: [String]
    public var securityDefinitions: [String: SecurityDefinition]
    public var paths: [String: PathItem]
    public var definitions: [String: SchemaDefinition]

    public struct SecurityDefinition: Sendable {
        public let type: SecurityType
        public let name: String?
        public let `in`: String?
        public let authorizationURL: String?
        public let flow: String?
        public let issuer: String?
        public let jwksURI: String?
        public let audiences: [String]?

        public enum SecurityType: String, Sendable {
            case apiKey = "apiKey"
            case oauth2 = "oauth2"
            case jwt = "jwt"
        }

        public init(
            type: SecurityType,
            name: String? = nil,
            in: String? = nil,
            authorizationURL: String? = nil,
            flow: String? = nil,
            issuer: String? = nil,
            jwksURI: String? = nil,
            audiences: [String]? = nil
        ) {
            self.type = type
            self.name = name
            self.in = `in`
            self.authorizationURL = authorizationURL
            self.flow = flow
            self.issuer = issuer
            self.jwksURI = jwksURI
            self.audiences = audiences
        }
    }

    public struct PathItem: Sendable {
        public var get: Operation?
        public var post: Operation?
        public var put: Operation?
        public var delete: Operation?
        public var patch: Operation?
        public var options: Operation?

        public init(
            get: Operation? = nil,
            post: Operation? = nil,
            put: Operation? = nil,
            delete: Operation? = nil,
            patch: Operation? = nil,
            options: Operation? = nil
        ) {
            self.get = get
            self.post = post
            self.put = put
            self.delete = delete
            self.patch = patch
            self.options = options
        }
    }

    public struct Operation: Sendable {
        public let operationId: String
        public let summary: String?
        public let description: String?
        public let parameters: [Parameter]?
        public let responses: [String: Response]
        public let security: [[String: [String]]]?
        public let backendAddress: String
        public let backendPathTranslation: PathTranslation?
        public let deadline: Double?
        public let disableAuth: Bool?

        public enum PathTranslation: String, Sendable {
            case appendPathToAddress = "APPEND_PATH_TO_ADDRESS"
            case constantAddress = "CONSTANT_ADDRESS"
        }

        public init(
            operationId: String,
            summary: String? = nil,
            description: String? = nil,
            parameters: [Parameter]? = nil,
            responses: [String: Response] = ["200": Response(description: "Success")],
            security: [[String: [String]]]? = nil,
            backendAddress: String,
            backendPathTranslation: PathTranslation? = nil,
            deadline: Double? = nil,
            disableAuth: Bool? = nil
        ) {
            self.operationId = operationId
            self.summary = summary
            self.description = description
            self.parameters = parameters
            self.responses = responses
            self.security = security
            self.backendAddress = backendAddress
            self.backendPathTranslation = backendPathTranslation
            self.deadline = deadline
            self.disableAuth = disableAuth
        }
    }

    public struct Parameter: Sendable {
        public let name: String
        public let `in`: ParameterLocation
        public let description: String?
        public let required: Bool
        public let type: String?
        public let schema: String?

        public enum ParameterLocation: String, Sendable {
            case query
            case path
            case header
            case body
        }

        public init(
            name: String,
            in location: ParameterLocation,
            description: String? = nil,
            required: Bool = false,
            type: String? = nil,
            schema: String? = nil
        ) {
            self.name = name
            self.in = location
            self.description = description
            self.required = required
            self.type = type
            self.schema = schema
        }
    }

    public struct Response: Sendable {
        public let description: String
        public let schema: String?

        public init(description: String, schema: String? = nil) {
            self.description = description
            self.schema = schema
        }
    }

    public struct SchemaDefinition: Sendable {
        public let type: String
        public let properties: [String: PropertyDefinition]?
        public let required: [String]?

        public init(type: String = "object", properties: [String: PropertyDefinition]? = nil, required: [String]? = nil) {
            self.type = type
            self.properties = properties
            self.required = required
        }
    }

    public struct PropertyDefinition: Sendable {
        public let type: String
        public let description: String?
        public let format: String?

        public init(type: String, description: String? = nil, format: String? = nil) {
            self.type = type
            self.description = description
            self.format = format
        }
    }

    public init(
        title: String,
        description: String? = nil,
        version: String = "1.0.0",
        host: String = "${API_GATEWAY_HOSTNAME}",
        basePath: String = "/",
        schemes: [String] = ["https"],
        consumes: [String] = ["application/json"],
        produces: [String] = ["application/json"]
    ) {
        self.title = title
        self.description = description
        self.version = version
        self.host = host
        self.basePath = basePath
        self.schemes = schemes
        self.consumes = consumes
        self.produces = produces
        self.securityDefinitions = [:]
        self.paths = [:]
        self.definitions = [:]
    }

    /// Add API key authentication
    public mutating func addAPIKeyAuth(name: String = "api_key", header: String = "x-api-key") {
        securityDefinitions[name] = SecurityDefinition(
            type: .apiKey,
            name: header,
            in: "header"
        )
    }

    /// Add JWT authentication
    public mutating func addJWTAuth(name: String = "jwt_auth", issuer: String, jwksURI: String, audiences: [String]) {
        securityDefinitions[name] = SecurityDefinition(
            type: .jwt,
            issuer: issuer,
            jwksURI: jwksURI,
            audiences: audiences
        )
    }

    /// Add Firebase Auth
    public mutating func addFirebaseAuth(name: String = "firebase", projectID: String) {
        securityDefinitions[name] = SecurityDefinition(
            type: .jwt,
            issuer: "https://securetoken.google.com/\(projectID)",
            jwksURI: "https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com",
            audiences: [projectID]
        )
    }

    /// Add a path with a single operation
    public mutating func addPath(_ path: String, method: String, operation: Operation) {
        var pathItem = paths[path] ?? PathItem()
        switch method.uppercased() {
        case "GET": pathItem.get = operation
        case "POST": pathItem.post = operation
        case "PUT": pathItem.put = operation
        case "DELETE": pathItem.delete = operation
        case "PATCH": pathItem.patch = operation
        case "OPTIONS": pathItem.options = operation
        default: break
        }
        paths[path] = pathItem
    }

    /// Build the OpenAPI YAML specification
    public func build() -> String {
        var yaml = """
        swagger: "2.0"
        info:
          title: "\(title)"
          version: "\(version)"
        """

        if let desc = description {
            yaml += "\n  description: \"\(desc)\""
        }

        yaml += """

        host: "\(host)"
        basePath: "\(basePath)"
        schemes:
        """
        for scheme in schemes {
            yaml += "\n  - \(scheme)"
        }

        yaml += "\nconsumes:"
        for consume in consumes {
            yaml += "\n  - \(consume)"
        }

        yaml += "\nproduces:"
        for produce in produces {
            yaml += "\n  - \(produce)"
        }

        // Security definitions
        if !securityDefinitions.isEmpty {
            yaml += "\nsecurityDefinitions:"
            for (name, def) in securityDefinitions {
                yaml += "\n  \(name):"
                if def.type == .jwt {
                    yaml += "\n    authorizationUrl: \"\""
                    yaml += "\n    flow: \"implicit\""
                    yaml += "\n    type: \"oauth2\""
                    yaml += "\n    x-google-issuer: \"\(def.issuer ?? "")\""
                    yaml += "\n    x-google-jwks_uri: \"\(def.jwksURI ?? "")\""
                    if let audiences = def.audiences {
                        yaml += "\n    x-google-audiences: \"\(audiences.joined(separator: ","))\""
                    }
                } else if def.type == .apiKey {
                    yaml += "\n    type: \"apiKey\""
                    yaml += "\n    name: \"\(def.name ?? "x-api-key")\""
                    yaml += "\n    in: \"\(def.in ?? "header")\""
                }
            }
        }

        // Paths
        if !paths.isEmpty {
            yaml += "\npaths:"
            for (path, pathItem) in paths.sorted(by: { $0.key < $1.key }) {
                yaml += "\n  \(path):"
                if let get = pathItem.get {
                    yaml += buildOperation("get", get)
                }
                if let post = pathItem.post {
                    yaml += buildOperation("post", post)
                }
                if let put = pathItem.put {
                    yaml += buildOperation("put", put)
                }
                if let delete = pathItem.delete {
                    yaml += buildOperation("delete", delete)
                }
                if let patch = pathItem.patch {
                    yaml += buildOperation("patch", patch)
                }
                if let options = pathItem.options {
                    yaml += buildOperation("options", options)
                }
            }
        }

        return yaml
    }

    private func buildOperation(_ method: String, _ op: Operation) -> String {
        var yaml = "\n    \(method):"
        yaml += "\n      operationId: \"\(op.operationId)\""

        if let summary = op.summary {
            yaml += "\n      summary: \"\(summary)\""
        }

        if let desc = op.description {
            yaml += "\n      description: \"\(desc)\""
        }

        // Backend configuration
        yaml += "\n      x-google-backend:"
        yaml += "\n        address: \"\(op.backendAddress)\""
        if let translation = op.backendPathTranslation {
            yaml += "\n        path_translation: \(translation.rawValue)"
        }
        if let deadline = op.deadline {
            yaml += "\n        deadline: \(deadline)"
        }
        if let disableAuth = op.disableAuth, disableAuth {
            yaml += "\n        disable_auth: true"
        }

        // Parameters
        if let params = op.parameters, !params.isEmpty {
            yaml += "\n      parameters:"
            for param in params {
                yaml += "\n        - name: \"\(param.name)\""
                yaml += "\n          in: \"\(param.in.rawValue)\""
                yaml += "\n          required: \(param.required)"
                if let type = param.type {
                    yaml += "\n          type: \"\(type)\""
                }
                if let desc = param.description {
                    yaml += "\n          description: \"\(desc)\""
                }
            }
        }

        // Responses
        yaml += "\n      responses:"
        for (code, response) in op.responses.sorted(by: { $0.key < $1.key }) {
            yaml += "\n        \(code):"
            yaml += "\n          description: \"\(response.description)\""
        }

        // Security
        if let security = op.security, !security.isEmpty {
            yaml += "\n      security:"
            for secItem in security {
                for (name, scopes) in secItem {
                    if scopes.isEmpty {
                        yaml += "\n        - \(name): []"
                    } else {
                        yaml += "\n        - \(name):"
                        for scope in scopes {
                            yaml += "\n            - \(scope)"
                        }
                    }
                }
            }
        }

        return yaml
    }
}

// MARK: - API Gateway Operations

/// Helper operations for API Gateway
public struct APIGatewayOperations: Sendable {

    /// Command to list APIs
    public static func listAPIsCommand(projectID: String) -> String {
        "gcloud api-gateway apis list --project=\(projectID)"
    }

    /// Command to list API configs
    public static func listConfigsCommand(apiName: String, projectID: String) -> String {
        "gcloud api-gateway api-configs list --api=\(apiName) --project=\(projectID)"
    }

    /// Command to list gateways
    public static func listGatewaysCommand(projectID: String, location: String? = nil) -> String {
        var cmd = "gcloud api-gateway gateways list --project=\(projectID)"
        if let loc = location {
            cmd += " --location=\(loc)"
        }
        return cmd
    }

    /// Command to enable API Gateway APIs
    public static var enableAPIsCommand: String {
        "gcloud services enable apigateway.googleapis.com servicemanagement.googleapis.com servicecontrol.googleapis.com"
    }

    /// Command to get the gateway URL
    public static func getGatewayURLCommand(gateway: String, location: String, projectID: String) -> String {
        "gcloud api-gateway gateways describe \(gateway) --location=\(location) --project=\(projectID) --format='value(defaultHostname)'"
    }

    /// Command to view API gateway logs
    public static func viewLogsCommand(gateway: String, projectID: String) -> String {
        "gcloud logging read 'resource.type=\"apigateway.googleapis.com/Gateway\" AND resource.labels.gateway_id=\"\(gateway)\"' --project=\(projectID) --limit=100"
    }

    /// Command to get API gateway metrics
    public static func getMetricsCommand(gateway: String, projectID: String) -> String {
        "gcloud monitoring metrics list --filter='metric.type=\"apigateway.googleapis.com/gateway\"' --project=\(projectID)"
    }
}

// MARK: - DAIS API Gateway Template

/// Production-ready API Gateway templates for DAIS systems
public struct DAISAPIGatewayTemplate: Sendable {
    public let projectID: String
    public let location: String
    public let apiName: String
    public let serviceAccountEmail: String?
    public let backendURL: String

    public init(
        projectID: String,
        location: String = "us-central1",
        apiName: String = "dais-api",
        serviceAccountEmail: String? = nil,
        backendURL: String
    ) {
        self.projectID = projectID
        self.location = location
        self.apiName = apiName
        self.serviceAccountEmail = serviceAccountEmail
        self.backendURL = backendURL
    }

    /// Create the API resource
    public var api: GoogleCloudAPIGatewayAPI {
        GoogleCloudAPIGatewayAPI(
            name: apiName,
            projectID: projectID,
            displayName: "DAIS API",
            labels: ["app": "dais", "managed-by": "googlecloudswift"]
        )
    }

    /// Create an API config
    public func config(version: String = "v1") -> GoogleCloudAPIGatewayConfig {
        GoogleCloudAPIGatewayConfig(
            name: "\(apiName)-config-\(version)",
            apiName: apiName,
            projectID: projectID,
            displayName: "DAIS API Config \(version)",
            gatewayServiceAccount: serviceAccountEmail,
            labels: ["version": version]
        )
    }

    /// Create a gateway
    public func gateway(configVersion: String = "v1") -> GoogleCloudAPIGatewayGateway {
        GoogleCloudAPIGatewayGateway(
            name: "\(apiName)-gateway",
            projectID: projectID,
            location: location,
            apiConfig: "projects/\(projectID)/locations/global/apis/\(apiName)/configs/\(apiName)-config-\(configVersion)",
            displayName: "DAIS API Gateway",
            labels: ["app": "dais"]
        )
    }

    /// Generate OpenAPI spec for DAIS API
    public var openAPISpec: String {
        var builder = OpenAPISpecBuilder(
            title: "DAIS API",
            description: "API for Distributed AI Systems",
            version: "1.0.0"
        )

        // Add JWT auth for Firebase or Google Cloud Identity
        builder.addJWTAuth(
            name: "google_id_token",
            issuer: "https://accounts.google.com",
            jwksURI: "https://www.googleapis.com/oauth2/v3/certs",
            audiences: [projectID]
        )

        // Health check endpoint (no auth)
        builder.addPath("/health", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "healthCheck",
            summary: "Health check endpoint",
            responses: ["200": OpenAPISpecBuilder.Response(description: "Service is healthy")],
            backendAddress: backendURL + "/health",
            disableAuth: true
        ))

        // API version endpoint
        builder.addPath("/version", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "getVersion",
            summary: "Get API version",
            responses: ["200": OpenAPISpecBuilder.Response(description: "Version information")],
            backendAddress: backendURL + "/version",
            disableAuth: true
        ))

        // Protected endpoints
        builder.addPath("/api/v1/nodes", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "listNodes",
            summary: "List all DAIS nodes",
            security: [["google_id_token": []]],
            backendAddress: backendURL + "/api/v1/nodes"
        ))

        builder.addPath("/api/v1/nodes/{nodeId}", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "getNode",
            summary: "Get a specific DAIS node",
            parameters: [
                OpenAPISpecBuilder.Parameter(name: "nodeId", in: .path, required: true, type: "string")
            ],
            security: [["google_id_token": []]],
            backendAddress: backendURL + "/api/v1/nodes/{nodeId}"
        ))

        builder.addPath("/api/v1/tasks", method: "POST", operation: OpenAPISpecBuilder.Operation(
            operationId: "createTask",
            summary: "Create a new task",
            security: [["google_id_token": []]],
            backendAddress: backendURL + "/api/v1/tasks"
        ))

        builder.addPath("/api/v1/tasks/{taskId}", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "getTask",
            summary: "Get task status",
            parameters: [
                OpenAPISpecBuilder.Parameter(name: "taskId", in: .path, required: true, type: "string")
            ],
            security: [["google_id_token": []]],
            backendAddress: backendURL + "/api/v1/tasks/{taskId}"
        ))

        builder.addPath("/api/v1/models", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "listModels",
            summary: "List available models",
            security: [["google_id_token": []]],
            backendAddress: backendURL + "/api/v1/models"
        ))

        builder.addPath("/api/v1/inference", method: "POST", operation: OpenAPISpecBuilder.Operation(
            operationId: "runInference",
            summary: "Run model inference",
            security: [["google_id_token": []]],
            backendAddress: backendURL + "/api/v1/inference",
            deadline: 60.0
        ))

        return builder.build()
    }

    /// Generate OpenAPI spec with API key authentication
    public var openAPISpecWithAPIKey: String {
        var builder = OpenAPISpecBuilder(
            title: "DAIS API",
            description: "API for Distributed AI Systems",
            version: "1.0.0"
        )

        builder.addAPIKeyAuth(name: "api_key", header: "x-api-key")

        // Health check (no auth)
        builder.addPath("/health", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "healthCheck",
            summary: "Health check endpoint",
            backendAddress: backendURL + "/health",
            disableAuth: true
        ))

        // Protected endpoints with API key
        builder.addPath("/api/v1/nodes", method: "GET", operation: OpenAPISpecBuilder.Operation(
            operationId: "listNodes",
            summary: "List all DAIS nodes",
            security: [["api_key": []]],
            backendAddress: backendURL + "/api/v1/nodes"
        ))

        builder.addPath("/api/v1/inference", method: "POST", operation: OpenAPISpecBuilder.Operation(
            operationId: "runInference",
            summary: "Run model inference",
            security: [["api_key": []]],
            backendAddress: backendURL + "/api/v1/inference",
            deadline: 60.0
        ))

        return builder.build()
    }

    /// Setup script to deploy the API Gateway
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        API_NAME="\(apiName)"
        \(serviceAccountEmail.map { "SERVICE_ACCOUNT=\"\($0)\"" } ?? "SERVICE_ACCOUNT=\"\"")

        echo "Enabling API Gateway APIs..."
        gcloud services enable apigateway.googleapis.com --project=$PROJECT_ID
        gcloud services enable servicemanagement.googleapis.com --project=$PROJECT_ID
        gcloud services enable servicecontrol.googleapis.com --project=$PROJECT_ID

        echo "Creating API definition..."
        gcloud api-gateway apis create $API_NAME \\
            --project=$PROJECT_ID \\
            --display-name="DAIS API" \\
            --labels=app=dais,managed-by=googlecloudswift || true

        echo "Creating OpenAPI spec..."
        cat > /tmp/openapi-spec.yaml << 'SPEC_EOF'
        \(openAPISpec)
        SPEC_EOF

        echo "Creating API config..."
        CONFIG_NAME="$API_NAME-config-v1"
        gcloud api-gateway api-configs create $CONFIG_NAME \\
            --api=$API_NAME \\
            --openapi-spec=/tmp/openapi-spec.yaml \\
            --project=$PROJECT_ID \\
            ${SERVICE_ACCOUNT:+--backend-auth-service-account=$SERVICE_ACCOUNT} \\
            --display-name="DAIS API Config v1" || true

        echo "Creating gateway..."
        GATEWAY_NAME="$API_NAME-gateway"
        gcloud api-gateway gateways create $GATEWAY_NAME \\
            --api-config=$CONFIG_NAME \\
            --api=$API_NAME \\
            --location=$LOCATION \\
            --project=$PROJECT_ID \\
            --display-name="DAIS API Gateway" \\
            --labels=app=dais

        echo ""
        echo "API Gateway setup complete!"
        echo ""
        echo "Gateway URL:"
        gcloud api-gateway gateways describe $GATEWAY_NAME \\
            --location=$LOCATION \\
            --project=$PROJECT_ID \\
            --format='value(defaultHostname)'
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        API_NAME="\(apiName)"

        echo "Deleting API Gateway resources..."

        # Delete gateway first
        echo "Deleting gateway..."
        gcloud api-gateway gateways delete $API_NAME-gateway \\
            --location=$LOCATION \\
            --project=$PROJECT_ID \\
            --quiet || true

        # Delete all configs
        echo "Deleting API configs..."
        for config in $(gcloud api-gateway api-configs list --api=$API_NAME --project=$PROJECT_ID --format='value(name)'); do
            config_name=$(basename $config)
            gcloud api-gateway api-configs delete $config_name \\
                --api=$API_NAME \\
                --project=$PROJECT_ID \\
                --quiet || true
        done

        # Delete API
        echo "Deleting API..."
        gcloud api-gateway apis delete $API_NAME \\
            --project=$PROJECT_ID \\
            --quiet || true

        echo "API Gateway teardown complete!"
        """
    }
}
