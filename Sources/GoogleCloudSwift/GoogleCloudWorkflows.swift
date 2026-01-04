import Foundation

// MARK: - Cloud Workflows

/// Represents a Google Cloud Workflow for serverless workflow orchestration
public struct GoogleCloudWorkflow: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let description: String?
    public let labels: [String: String]?
    public let serviceAccount: String?
    public let sourceContents: String?
    public let createTime: Date?
    public let updateTime: Date?
    public let revisionID: String?
    public let state: WorkflowState?
    public let callLogLevel: CallLogLevel?
    public let cryptoKeyName: String?

    public enum WorkflowState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case active = "ACTIVE"
        case unavailable = "UNAVAILABLE"
    }

    public enum CallLogLevel: String, Codable, Sendable, Equatable {
        case callLogLevelUnspecified = "CALL_LOG_LEVEL_UNSPECIFIED"
        case logAllCalls = "LOG_ALL_CALLS"
        case logErrorsOnly = "LOG_ERRORS_ONLY"
        case logNone = "LOG_NONE"
    }

    public init(
        name: String,
        projectID: String,
        location: String = "us-central1",
        description: String? = nil,
        labels: [String: String]? = nil,
        serviceAccount: String? = nil,
        sourceContents: String? = nil,
        createTime: Date? = nil,
        updateTime: Date? = nil,
        revisionID: String? = nil,
        state: WorkflowState? = nil,
        callLogLevel: CallLogLevel? = nil,
        cryptoKeyName: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.description = description
        self.labels = labels
        self.serviceAccount = serviceAccount
        self.sourceContents = sourceContents
        self.createTime = createTime
        self.updateTime = updateTime
        self.revisionID = revisionID
        self.state = state
        self.callLogLevel = callLogLevel
        self.cryptoKeyName = cryptoKeyName
    }

    /// Resource name in the format projects/{project}/locations/{location}/workflows/{workflow}
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/workflows/\(name)"
    }

    /// Command to create the workflow
    public var createCommand: String {
        var cmd = "gcloud workflows deploy \(name) --location=\(location)"
        if let desc = description {
            cmd += " --description='\(desc)'"
        }
        if let sa = serviceAccount {
            cmd += " --service-account=\(sa)"
        }
        if let logLevel = callLogLevel {
            let level = logLevel.rawValue.replacingOccurrences(of: "_", with: "-").lowercased()
            cmd += " --call-log-level=\(level)"
        }
        if let labels = labels, !labels.isEmpty {
            let labelStr = labels.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            cmd += " --labels=\(labelStr)"
        }
        return cmd
    }

    /// Command to update the workflow
    public var updateCommand: String {
        createCommand  // deploy command handles both create and update
    }

    /// Command to delete the workflow
    public var deleteCommand: String {
        "gcloud workflows delete \(name) --location=\(location) --quiet"
    }

    /// Command to describe the workflow
    public var describeCommand: String {
        "gcloud workflows describe \(name) --location=\(location)"
    }

    /// Command to list workflow revisions
    public var listRevisionsCommand: String {
        "gcloud workflows revisions list --workflow=\(name) --location=\(location)"
    }

    /// Command to execute the workflow
    public func executeCommand(data: String? = nil) -> String {
        var cmd = "gcloud workflows run \(name) --location=\(location)"
        if let data = data {
            cmd += " --data='\(data)'"
        }
        return cmd
    }
}

// MARK: - Workflow Execution

/// Represents an execution of a Cloud Workflow
public struct GoogleCloudWorkflowExecution: Codable, Sendable, Equatable {
    public let name: String
    public let workflowName: String
    public let projectID: String
    public let location: String
    public let argument: String?
    public let result: String?
    public let error: ExecutionError?
    public let startTime: Date?
    public let endTime: Date?
    public let duration: String?
    public let state: ExecutionState?
    public let callLogLevel: GoogleCloudWorkflow.CallLogLevel?
    public let labels: [String: String]?

    public struct ExecutionError: Codable, Sendable, Equatable {
        public let payload: String?
        public let context: String?
        public let stackTrace: StackTrace?

        public struct StackTrace: Codable, Sendable, Equatable {
            public let elements: [StackTraceElement]?

            public struct StackTraceElement: Codable, Sendable, Equatable {
                public let step: String?
                public let routine: String?
                public let position: Position?

                public struct Position: Codable, Sendable, Equatable {
                    public let line: Int?
                    public let column: Int?
                    public let length: Int?
                }
            }
        }
    }

    public enum ExecutionState: String, Codable, Sendable, Equatable {
        case stateUnspecified = "STATE_UNSPECIFIED"
        case active = "ACTIVE"
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
        case cancelled = "CANCELLED"
        case unavailable = "UNAVAILABLE"
        case queued = "QUEUED"
    }

    public init(
        name: String,
        workflowName: String,
        projectID: String,
        location: String = "us-central1",
        argument: String? = nil,
        result: String? = nil,
        error: ExecutionError? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        duration: String? = nil,
        state: ExecutionState? = nil,
        callLogLevel: GoogleCloudWorkflow.CallLogLevel? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.workflowName = workflowName
        self.projectID = projectID
        self.location = location
        self.argument = argument
        self.result = result
        self.error = error
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.state = state
        self.callLogLevel = callLogLevel
        self.labels = labels
    }

    /// Resource name for the execution
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/workflows/\(workflowName)/executions/\(name)"
    }

    /// Command to describe this execution
    public var describeCommand: String {
        "gcloud workflows executions describe \(name) --workflow=\(workflowName) --location=\(location)"
    }

    /// Command to cancel this execution
    public var cancelCommand: String {
        "gcloud workflows executions cancel \(name) --workflow=\(workflowName) --location=\(location)"
    }

    /// Command to wait for execution completion
    public var waitCommand: String {
        "gcloud workflows executions wait \(name) --workflow=\(workflowName) --location=\(location)"
    }
}

// MARK: - Workflow YAML Builder

/// Helper for building workflow YAML definitions
public struct WorkflowYAMLBuilder: Sendable {
    private var steps: [(String, WorkflowStep)]

    public init() {
        self.steps = []
    }

    public init(steps: [(String, WorkflowStep)]) {
        self.steps = steps
    }

    /// Add a step to the workflow
    public mutating func addStep(_ name: String, _ step: WorkflowStep) {
        steps.append((name, step))
    }

    /// Build the workflow YAML
    public func build() -> String {
        var yaml = "main:\n  steps:\n"
        for (name, step) in steps {
            yaml += "    - \(name):\n"
            yaml += step.toYAML(indent: 8)
        }
        return yaml
    }
}

/// Represents a step in a workflow
public enum WorkflowStep: Sendable {
    case assign(variables: [(String, String)])
    case call(url: String, method: String, body: [String: String]?, result: String?)
    case callConnector(connector: String, method: String, args: [String: String], result: String?)
    case httpGet(url: String, result: String?)
    case httpPost(url: String, body: [String: String], result: String?)
    case `return`(value: String)
    case returnMap(values: [String: String])
    case log(text: String, severity: String?)
    case condition(condition: String, thenSteps: [(String, WorkflowStep)], elseSteps: [(String, WorkflowStep)]?)
    case parallel(branches: [String: [(String, WorkflowStep)]], shared: [String]?)
    case `try`(trySteps: [(String, WorkflowStep)], except: String?, exceptSteps: [(String, WorkflowStep)]?)
    case forLoop(variable: String, `in`: String, steps: [(String, WorkflowStep)])
    case raise(error: String)
    case sleep(seconds: Int)

    func toYAML(indent: Int) -> String {
        let ind = String(repeating: " ", count: indent)
        let ind2 = String(repeating: " ", count: indent + 4)
        let ind3 = String(repeating: " ", count: indent + 8)

        switch self {
        case .assign(let variables):
            var yaml = "\(ind)assign:\n"
            for (name, value) in variables {
                yaml += "\(ind2)- \(name): \(value)\n"
            }
            return yaml

        case .call(let url, let method, let body, let result):
            var yaml = "\(ind)call: http.request\n"
            yaml += "\(ind)args:\n"
            yaml += "\(ind2)url: \(url)\n"
            yaml += "\(ind2)method: \(method)\n"
            if let body = body, !body.isEmpty {
                yaml += "\(ind2)body:\n"
                for (key, value) in body {
                    yaml += "\(ind3)\(key): \(value)\n"
                }
            }
            if let result = result {
                yaml += "\(ind)result: \(result)\n"
            }
            return yaml

        case .callConnector(let connector, let method, let args, let result):
            var yaml = "\(ind)call: \(connector).\(method)\n"
            if !args.isEmpty {
                yaml += "\(ind)args:\n"
                for (key, value) in args {
                    yaml += "\(ind2)\(key): \(value)\n"
                }
            }
            if let result = result {
                yaml += "\(ind)result: \(result)\n"
            }
            return yaml

        case .httpGet(let url, let result):
            var yaml = "\(ind)call: http.get\n"
            yaml += "\(ind)args:\n"
            yaml += "\(ind2)url: \(url)\n"
            if let result = result {
                yaml += "\(ind)result: \(result)\n"
            }
            return yaml

        case .httpPost(let url, let body, let result):
            var yaml = "\(ind)call: http.post\n"
            yaml += "\(ind)args:\n"
            yaml += "\(ind2)url: \(url)\n"
            if !body.isEmpty {
                yaml += "\(ind2)body:\n"
                for (key, value) in body {
                    yaml += "\(ind3)\(key): \(value)\n"
                }
            }
            if let result = result {
                yaml += "\(ind)result: \(result)\n"
            }
            return yaml

        case .return(let value):
            return "\(ind)return: \(value)\n"

        case .returnMap(let values):
            var yaml = "\(ind)return:\n"
            for (key, value) in values {
                yaml += "\(ind2)\(key): \(value)\n"
            }
            return yaml

        case .log(let text, let severity):
            var yaml = "\(ind)call: sys.log\n"
            yaml += "\(ind)args:\n"
            yaml += "\(ind2)text: \(text)\n"
            if let severity = severity {
                yaml += "\(ind2)severity: \(severity)\n"
            }
            return yaml

        case .condition(let condition, let thenSteps, let elseSteps):
            var yaml = "\(ind)switch:\n"
            yaml += "\(ind2)- condition: \(condition)\n"
            yaml += "\(ind2)  steps:\n"
            for (name, step) in thenSteps {
                yaml += "\(ind3)- \(name):\n"
                yaml += step.toYAML(indent: indent + 16)
            }
            if let elseSteps = elseSteps {
                yaml += "\(ind2)- condition: true\n"
                yaml += "\(ind2)  steps:\n"
                for (name, step) in elseSteps {
                    yaml += "\(ind3)- \(name):\n"
                    yaml += step.toYAML(indent: indent + 16)
                }
            }
            return yaml

        case .parallel(let branches, let shared):
            var yaml = "\(ind)parallel:\n"
            if let shared = shared, !shared.isEmpty {
                yaml += "\(ind2)shared: [\(shared.joined(separator: ", "))]\n"
            }
            yaml += "\(ind2)branches:\n"
            for (branchName, branchSteps) in branches {
                yaml += "\(ind3)- \(branchName):\n"
                yaml += "\(ind3)  steps:\n"
                for (stepName, step) in branchSteps {
                    yaml += "\(String(repeating: " ", count: indent + 16))- \(stepName):\n"
                    yaml += step.toYAML(indent: indent + 20)
                }
            }
            return yaml

        case .try(let trySteps, let except, let exceptSteps):
            var yaml = "\(ind)try:\n"
            yaml += "\(ind2)steps:\n"
            for (name, step) in trySteps {
                yaml += "\(ind3)- \(name):\n"
                yaml += step.toYAML(indent: indent + 12)
            }
            if let except = except {
                yaml += "\(ind)except:\n"
                yaml += "\(ind2)as: \(except)\n"
                if let exceptSteps = exceptSteps {
                    yaml += "\(ind2)steps:\n"
                    for (name, step) in exceptSteps {
                        yaml += "\(ind3)- \(name):\n"
                        yaml += step.toYAML(indent: indent + 12)
                    }
                }
            }
            return yaml

        case .forLoop(let variable, let inValue, let loopSteps):
            var yaml = "\(ind)for:\n"
            yaml += "\(ind2)value: \(variable)\n"
            yaml += "\(ind2)in: \(inValue)\n"
            yaml += "\(ind2)steps:\n"
            for (name, step) in loopSteps {
                yaml += "\(ind3)- \(name):\n"
                yaml += step.toYAML(indent: indent + 12)
            }
            return yaml

        case .raise(let error):
            return "\(ind)raise: \(error)\n"

        case .sleep(let seconds):
            var yaml = "\(ind)call: sys.sleep\n"
            yaml += "\(ind)args:\n"
            yaml += "\(ind2)seconds: \(seconds)\n"
            return yaml
        }
    }
}

// MARK: - Workflow Operations

/// Helper operations for Cloud Workflows
public struct WorkflowOperations: Sendable {

    /// Command to list workflows
    public static func listCommand(location: String = "us-central1") -> String {
        "gcloud workflows list --location=\(location)"
    }

    /// Command to list all workflows across all locations
    public static var listAllCommand: String {
        "gcloud workflows list --location=-"
    }

    /// Command to list executions for a workflow
    public static func listExecutionsCommand(workflow: String, location: String = "us-central1", limit: Int? = nil) -> String {
        var cmd = "gcloud workflows executions list --workflow=\(workflow) --location=\(location)"
        if let limit = limit {
            cmd += " --limit=\(limit)"
        }
        return cmd
    }

    /// Command to run a workflow with JSON data
    public static func runWithJSONCommand(workflow: String, location: String = "us-central1", jsonFile: String) -> String {
        "gcloud workflows run \(workflow) --location=\(location) --data-file=\(jsonFile)"
    }

    /// Command to get workflow execution logs
    public static func getExecutionLogsCommand(workflow: String, executionID: String, location: String = "us-central1") -> String {
        "gcloud logging read 'resource.type=\"workflows.googleapis.com/Workflow\" AND resource.labels.workflow_id=\"\(workflow)\" AND labels.execution_id=\"\(executionID)\"' --limit=100"
    }

    /// Command to enable Workflows API
    public static var enableAPICommand: String {
        "gcloud services enable workflows.googleapis.com"
    }

    /// Command to enable Workflow Executions API
    public static var enableExecutionsAPICommand: String {
        "gcloud services enable workflowexecutions.googleapis.com"
    }
}

// MARK: - Workflow Connectors

/// Pre-built connectors for common Google Cloud services
public struct WorkflowConnectors: Sendable {

    /// BigQuery connector
    public struct BigQuery: Sendable {
        /// Query data from BigQuery
        public static func query(query: String, projectID: String) -> WorkflowStep {
            .callConnector(
                connector: "googleapis.bigquery.v2.jobs",
                method: "query",
                args: [
                    "projectId": projectID,
                    "body": "{ \"query\": \"\(query)\", \"useLegacySql\": false }"
                ],
                result: "queryResult"
            )
        }
    }

    /// Cloud Storage connector
    public struct Storage: Sendable {
        /// List objects in a bucket
        public static func listObjects(bucket: String) -> WorkflowStep {
            .callConnector(
                connector: "googleapis.storage.v1.objects",
                method: "list",
                args: ["bucket": bucket],
                result: "objects"
            )
        }

        /// Get object metadata
        public static func getObject(bucket: String, object: String) -> WorkflowStep {
            .callConnector(
                connector: "googleapis.storage.v1.objects",
                method: "get",
                args: ["bucket": bucket, "object": object],
                result: "objectMetadata"
            )
        }
    }

    /// Pub/Sub connector
    public struct PubSub: Sendable {
        /// Publish a message to a topic
        public static func publish(topic: String, message: String) -> WorkflowStep {
            .callConnector(
                connector: "googleapis.pubsub.v1.projects.topics",
                method: "publish",
                args: [
                    "topic": topic,
                    "body": "{ \"messages\": [{ \"data\": \"\(message)\" }] }"
                ],
                result: "publishResult"
            )
        }
    }

    /// Cloud Run connector
    public struct CloudRun: Sendable {
        /// Invoke a Cloud Run service
        public static func invoke(url: String, method: String = "GET", body: [String: String]? = nil) -> WorkflowStep {
            .call(url: url, method: method, body: body, result: "cloudRunResponse")
        }
    }

    /// Cloud Functions connector
    public struct Functions: Sendable {
        /// Call a Cloud Function
        public static func call(name: String, projectID: String, region: String, body: [String: String]? = nil) -> WorkflowStep {
            let url = "https://\(region)-\(projectID).cloudfunctions.net/\(name)"
            return .httpPost(url: url, body: body ?? [:], result: "functionResponse")
        }
    }

    /// Secret Manager connector
    public struct SecretManager: Sendable {
        /// Access a secret version
        public static func accessSecret(secret: String, version: String = "latest") -> WorkflowStep {
            .callConnector(
                connector: "googleapis.secretmanager.v1.projects.secrets.versions",
                method: "access",
                args: ["name": "\(secret)/versions/\(version)"],
                result: "secretValue"
            )
        }
    }

    /// Firestore connector
    public struct Firestore: Sendable {
        /// Get a document
        public static func getDocument(database: String, document: String) -> WorkflowStep {
            .callConnector(
                connector: "googleapis.firestore.v1.projects.databases.documents",
                method: "get",
                args: ["name": "\(database)/documents/\(document)"],
                result: "document"
            )
        }

        /// Create a document
        public static func createDocument(database: String, collectionId: String, documentId: String, fields: [String: String]) -> WorkflowStep {
            let fieldsJSON = fields.map { "\"\($0.key)\": { \"stringValue\": \"\($0.value)\" }" }.joined(separator: ", ")
            return .callConnector(
                connector: "googleapis.firestore.v1.projects.databases.documents",
                method: "createDocument",
                args: [
                    "parent": "\(database)/documents",
                    "collectionId": collectionId,
                    "documentId": documentId,
                    "body": "{ \"fields\": { \(fieldsJSON) } }"
                ],
                result: "createdDocument"
            )
        }
    }
}

// MARK: - DAIS Workflow Template

/// Production-ready workflow templates for DAIS systems
public struct DAISWorkflowsTemplate: Sendable {
    public let projectID: String
    public let location: String
    public let serviceAccountEmail: String?

    public init(
        projectID: String,
        location: String = "us-central1",
        serviceAccountEmail: String? = nil
    ) {
        self.projectID = projectID
        self.location = location
        self.serviceAccountEmail = serviceAccountEmail
    }

    /// Data processing workflow
    public var dataProcessingWorkflow: GoogleCloudWorkflow {
        let yaml = """
        main:
          params: [input]
          steps:
            - init:
                assign:
                  - projectId: \(projectID)
                  - bucket: ${input.bucket}
                  - inputFile: ${input.file}
            - validateInput:
                switch:
                  - condition: ${bucket == null OR inputFile == null}
                    steps:
                      - raiseError:
                          raise: "Missing required input: bucket and file"
            - readData:
                call: googleapis.storage.v1.objects.get
                args:
                  bucket: ${bucket}
                  object: ${inputFile}
                result: objectData
            - processData:
                call: http.post
                args:
                  url: https://\(location)-\(projectID).cloudfunctions.net/process-data
                  body:
                    data: ${objectData}
                result: processedData
            - writeResults:
                call: googleapis.storage.v1.objects.insert
                args:
                  bucket: ${bucket}
                  name: processed/${inputFile}
                  body: ${processedData.body}
                result: writeResult
            - returnResult:
                return:
                  status: "success"
                  outputFile: processed/${inputFile}
        """

        return GoogleCloudWorkflow(
            name: "dais-data-processing",
            projectID: projectID,
            location: location,
            description: "DAIS data processing workflow",
            labels: ["app": "dais", "component": "data-processing"],
            serviceAccount: serviceAccountEmail,
            sourceContents: yaml,
            callLogLevel: .logErrorsOnly
        )
    }

    /// Event-driven workflow for handling Cloud Storage events
    public var storageEventWorkflow: GoogleCloudWorkflow {
        let yaml = """
        main:
          params: [event]
          steps:
            - extractEvent:
                assign:
                  - bucket: ${event.data.bucket}
                  - name: ${event.data.name}
                  - contentType: ${event.data.contentType}
            - logEvent:
                call: sys.log
                args:
                  text: ${"Processing file: " + name + " from bucket: " + bucket}
                  severity: "INFO"
            - checkFileType:
                switch:
                  - condition: ${text.match_regex(contentType, "image/.*")}
                    steps:
                      - processImage:
                          call: http.post
                          args:
                            url: https://\(location)-\(projectID).cloudfunctions.net/process-image
                            body:
                              bucket: ${bucket}
                              file: ${name}
                          result: imageResult
                  - condition: ${text.match_regex(contentType, "application/json")}
                    steps:
                      - processJSON:
                          call: http.post
                          args:
                            url: https://\(location)-\(projectID).cloudfunctions.net/process-json
                            body:
                              bucket: ${bucket}
                              file: ${name}
                          result: jsonResult
                  - condition: true
                    steps:
                      - logUnsupported:
                          call: sys.log
                          args:
                            text: ${"Unsupported file type: " + contentType}
                            severity: "WARNING"
            - returnStatus:
                return:
                  processed: true
                  file: ${name}
        """

        return GoogleCloudWorkflow(
            name: "dais-storage-event-handler",
            projectID: projectID,
            location: location,
            description: "DAIS storage event handler workflow",
            labels: ["app": "dais", "component": "event-handler"],
            serviceAccount: serviceAccountEmail,
            sourceContents: yaml,
            callLogLevel: .logAllCalls
        )
    }

    /// Batch processing workflow with parallel execution
    public var batchProcessingWorkflow: GoogleCloudWorkflow {
        let yaml = """
        main:
          params: [input]
          steps:
            - init:
                assign:
                  - items: ${input.items}
                  - results: []
            - validateItems:
                switch:
                  - condition: ${len(items) == 0}
                    steps:
                      - emptyReturn:
                          return:
                            status: "no items to process"
                            results: []
            - processInParallel:
                parallel:
                  shared: [results]
                  for:
                    value: item
                    in: ${items}
                    steps:
                      - processItem:
                          call: http.post
                          args:
                            url: https://\(location)-\(projectID).cloudfunctions.net/process-item
                            body:
                              item: ${item}
                          result: itemResult
                      - collectResult:
                          assign:
                            - results: ${list.concat(results, itemResult.body)}
            - returnResults:
                return:
                  status: "success"
                  processedCount: ${len(results)}
                  results: ${results}
        """

        return GoogleCloudWorkflow(
            name: "dais-batch-processing",
            projectID: projectID,
            location: location,
            description: "DAIS batch processing workflow with parallel execution",
            labels: ["app": "dais", "component": "batch-processing"],
            serviceAccount: serviceAccountEmail,
            sourceContents: yaml,
            callLogLevel: .logErrorsOnly
        )
    }

    /// Retry workflow with exponential backoff
    public var retryWorkflow: GoogleCloudWorkflow {
        let yaml = """
        main:
          params: [input]
          steps:
            - init:
                assign:
                  - maxRetries: 5
                  - retryCount: 0
                  - baseDelay: 1
                  - maxDelay: 60
            - retryLoop:
                try:
                  steps:
                    - callService:
                        call: http.post
                        args:
                          url: ${input.url}
                          body: ${input.body}
                          timeout: 30
                        result: response
                    - checkResponse:
                        switch:
                          - condition: ${response.code >= 200 AND response.code < 300}
                            steps:
                              - successReturn:
                                  return:
                                    status: "success"
                                    response: ${response.body}
                          - condition: true
                            steps:
                              - raiseHTTPError:
                                  raise: ${"HTTP error: " + string(response.code)}
                except:
                  as: e
                  steps:
                    - incrementRetry:
                        assign:
                          - retryCount: ${retryCount + 1}
                    - checkMaxRetries:
                        switch:
                          - condition: ${retryCount >= maxRetries}
                            steps:
                              - failReturn:
                                  return:
                                    status: "failed"
                                    error: ${e}
                                    attempts: ${retryCount}
                    - calculateDelay:
                        assign:
                          - delay: ${int(math.min(baseDelay * math.pow(2, retryCount - 1), maxDelay))}
                    - logRetry:
                        call: sys.log
                        args:
                          text: ${"Retry " + string(retryCount) + " after " + string(delay) + "s"}
                          severity: "WARNING"
                    - waitBeforeRetry:
                        call: sys.sleep
                        args:
                          seconds: ${delay}
                    - goToRetry:
                        next: retryLoop
        """

        return GoogleCloudWorkflow(
            name: "dais-retry-workflow",
            projectID: projectID,
            location: location,
            description: "DAIS retry workflow with exponential backoff",
            labels: ["app": "dais", "component": "retry"],
            serviceAccount: serviceAccountEmail,
            sourceContents: yaml,
            callLogLevel: .logAllCalls
        )
    }

    /// Approval workflow for human-in-the-loop processes
    public var approvalWorkflow: GoogleCloudWorkflow {
        let yaml = """
        main:
          params: [request]
          steps:
            - init:
                assign:
                  - requestId: ${request.id}
                  - requestor: ${request.requestor}
                  - details: ${request.details}
                  - approvalTimeout: 86400  # 24 hours
            - createApprovalRequest:
                call: http.post
                args:
                  url: https://\(location)-\(projectID).cloudfunctions.net/create-approval
                  body:
                    requestId: ${requestId}
                    requestor: ${requestor}
                    details: ${details}
                result: approvalCreated
            - notifyApprovers:
                call: http.post
                args:
                  url: https://\(location)-\(projectID).cloudfunctions.net/notify-approvers
                  body:
                    requestId: ${requestId}
                    approvalUrl: ${approvalCreated.body.approvalUrl}
            - waitForApproval:
                call: googleapis.workflowexecutions.v1.projects.locations.workflows.executions.callbacks.await
                args:
                  callbackId: ${requestId}
                  timeout: ${approvalTimeout}
                result: callbackResponse
            - processDecision:
                switch:
                  - condition: ${callbackResponse.approved == true}
                    steps:
                      - executeApprovedAction:
                          call: http.post
                          args:
                            url: https://\(location)-\(projectID).cloudfunctions.net/execute-approved
                            body:
                              requestId: ${requestId}
                              approvedBy: ${callbackResponse.approver}
                          result: executionResult
                      - approvedReturn:
                          return:
                            status: "approved"
                            executionResult: ${executionResult.body}
                  - condition: true
                    steps:
                      - rejectedReturn:
                          return:
                            status: "rejected"
                            rejectedBy: ${callbackResponse.approver}
                            reason: ${callbackResponse.reason}
        """

        return GoogleCloudWorkflow(
            name: "dais-approval-workflow",
            projectID: projectID,
            location: location,
            description: "DAIS human-in-the-loop approval workflow",
            labels: ["app": "dais", "component": "approval"],
            serviceAccount: serviceAccountEmail,
            sourceContents: yaml,
            callLogLevel: .logAllCalls
        )
    }

    /// Setup script to deploy all DAIS workflows
    public var setupScript: String {
        """
        #!/bin/bash
        set -euo pipefail

        PROJECT_ID="\(projectID)"
        LOCATION="\(location)"
        \(serviceAccountEmail.map { "SERVICE_ACCOUNT=\"\($0)\"" } ?? "")

        echo "Enabling Workflows APIs..."
        gcloud services enable workflows.googleapis.com --project=$PROJECT_ID
        gcloud services enable workflowexecutions.googleapis.com --project=$PROJECT_ID

        echo "Creating DAIS data processing workflow..."
        cat > /tmp/data-processing-workflow.yaml << 'WORKFLOW_EOF'
        \(dataProcessingWorkflow.sourceContents ?? "")
        WORKFLOW_EOF

        gcloud workflows deploy dais-data-processing \\
            --location=$LOCATION \\
            --source=/tmp/data-processing-workflow.yaml \\
            --description="DAIS data processing workflow" \\
            --labels=app=dais,component=data-processing \\
            \(serviceAccountEmail.map { "--service-account=\($0)" } ?? "") \\
            --project=$PROJECT_ID

        echo "Creating DAIS storage event handler workflow..."
        cat > /tmp/storage-event-workflow.yaml << 'WORKFLOW_EOF'
        \(storageEventWorkflow.sourceContents ?? "")
        WORKFLOW_EOF

        gcloud workflows deploy dais-storage-event-handler \\
            --location=$LOCATION \\
            --source=/tmp/storage-event-workflow.yaml \\
            --description="DAIS storage event handler workflow" \\
            --labels=app=dais,component=event-handler \\
            \(serviceAccountEmail.map { "--service-account=\($0)" } ?? "") \\
            --project=$PROJECT_ID

        echo "Creating DAIS batch processing workflow..."
        cat > /tmp/batch-processing-workflow.yaml << 'WORKFLOW_EOF'
        \(batchProcessingWorkflow.sourceContents ?? "")
        WORKFLOW_EOF

        gcloud workflows deploy dais-batch-processing \\
            --location=$LOCATION \\
            --source=/tmp/batch-processing-workflow.yaml \\
            --description="DAIS batch processing workflow with parallel execution" \\
            --labels=app=dais,component=batch-processing \\
            \(serviceAccountEmail.map { "--service-account=\($0)" } ?? "") \\
            --project=$PROJECT_ID

        echo "Creating DAIS retry workflow..."
        cat > /tmp/retry-workflow.yaml << 'WORKFLOW_EOF'
        \(retryWorkflow.sourceContents ?? "")
        WORKFLOW_EOF

        gcloud workflows deploy dais-retry-workflow \\
            --location=$LOCATION \\
            --source=/tmp/retry-workflow.yaml \\
            --description="DAIS retry workflow with exponential backoff" \\
            --labels=app=dais,component=retry \\
            \(serviceAccountEmail.map { "--service-account=\($0)" } ?? "") \\
            --project=$PROJECT_ID

        echo "Creating DAIS approval workflow..."
        cat > /tmp/approval-workflow.yaml << 'WORKFLOW_EOF'
        \(approvalWorkflow.sourceContents ?? "")
        WORKFLOW_EOF

        gcloud workflows deploy dais-approval-workflow \\
            --location=$LOCATION \\
            --source=/tmp/approval-workflow.yaml \\
            --description="DAIS human-in-the-loop approval workflow" \\
            --labels=app=dais,component=approval \\
            \(serviceAccountEmail.map { "--service-account=\($0)" } ?? "") \\
            --project=$PROJECT_ID

        echo ""
        echo "DAIS Workflows setup complete!"
        echo ""
        echo "Deployed workflows:"
        gcloud workflows list --location=$LOCATION --project=$PROJECT_ID
        """
    }
}
