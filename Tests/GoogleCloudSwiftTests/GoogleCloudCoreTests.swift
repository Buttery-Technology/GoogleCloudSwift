import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Service Account Credentials Tests

@Test func testServiceAccountCredentialsLoadFromString() throws {
    let jsonString = """
    {
        "type": "service_account",
        "project_id": "test-project",
        "private_key_id": "key123",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIE...\\n-----END PRIVATE KEY-----\\n",
        "client_email": "test@test-project.iam.gserviceaccount.com",
        "client_id": "123456789",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test"
    }
    """

    let credentials = try GoogleCloudServiceAccountCredentials.loadFromString(jsonString)

    #expect(credentials.type == "service_account")
    #expect(credentials.projectId == "test-project")
    #expect(credentials.privateKeyId == "key123")
    #expect(credentials.clientEmail == "test@test-project.iam.gserviceaccount.com")
    #expect(credentials.clientId == "123456789")
    #expect(credentials.tokenUri == "https://oauth2.googleapis.com/token")
}

@Test func testServiceAccountCredentialsLoadFromData() throws {
    let jsonString = """
    {
        "type": "service_account",
        "project_id": "my-project",
        "private_key_id": "abc123",
        "private_key": "fake-key",
        "client_email": "sa@my-project.iam.gserviceaccount.com",
        "client_id": "987654321",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sa"
    }
    """
    let data = jsonString.data(using: .utf8)!

    let credentials = try GoogleCloudServiceAccountCredentials.load(from: data)

    #expect(credentials.projectId == "my-project")
    #expect(credentials.clientEmail == "sa@my-project.iam.gserviceaccount.com")
}

@Test func testServiceAccountCredentialsInvalidJSON() {
    let invalidJSON = "not valid json"

    #expect(throws: Error.self) {
        try GoogleCloudServiceAccountCredentials.loadFromString(invalidJSON)
    }
}

@Test func testServiceAccountCredentialsMissingFields() {
    let incompleteJSON = """
    {
        "type": "service_account",
        "project_id": "test"
    }
    """

    #expect(throws: Error.self) {
        try GoogleCloudServiceAccountCredentials.loadFromString(incompleteJSON)
    }
}

// MARK: - Access Token Tests

@Test func testAccessTokenNotExpired() {
    let token = GoogleCloudAccessToken(
        token: "test-token",
        tokenType: "Bearer",
        expiresAt: Date().addingTimeInterval(3600)
    )

    #expect(!token.isExpired)
}

@Test func testAccessTokenExpired() {
    let token = GoogleCloudAccessToken(
        token: "test-token",
        tokenType: "Bearer",
        expiresAt: Date().addingTimeInterval(-1)
    )

    #expect(token.isExpired)
}

@Test func testAccessTokenExpiringWithinBuffer() {
    // Token expiring in 30 seconds (within 60-second buffer)
    let token = GoogleCloudAccessToken(
        token: "test-token",
        tokenType: "Bearer",
        expiresAt: Date().addingTimeInterval(30)
    )

    #expect(token.isExpired)
}

// MARK: - Auth Error Tests

@Test func testAuthErrorDescriptions() {
    let invalidCredentials = GoogleCloudAuthError.invalidCredentials("Bad format")
    #expect(invalidCredentials.errorDescription?.contains("Invalid credentials") == true)

    let invalidPrivateKey = GoogleCloudAuthError.invalidPrivateKey("Parse failed")
    #expect(invalidPrivateKey.errorDescription?.contains("Invalid private key") == true)

    let tokenFailed = GoogleCloudAuthError.tokenRequestFailed("Server error")
    #expect(tokenFailed.errorDescription?.contains("Token request failed") == true)

    let httpError = GoogleCloudAuthError.httpError(401, "Unauthorized")
    #expect(httpError.errorDescription?.contains("401") == true)
}

@Test func testAuthErrorRecoverySuggestions() {
    let invalidCredentials = GoogleCloudAuthError.invalidCredentials("Bad format")
    #expect(invalidCredentials.recoverySuggestion?.contains("Verify") == true)

    let httpError = GoogleCloudAuthError.httpError(401, "Unauthorized")
    #expect(httpError.recoverySuggestion?.contains("service account") == true)

    let networkError = GoogleCloudAuthError.networkError("Connection failed")
    #expect(networkError.recoverySuggestion?.contains("network") == true)
}

// MARK: - API Error Tests

@Test func testAPIErrorDescriptions() {
    let requestFailed = GoogleCloudAPIError.requestFailed("Network issue")
    #expect(requestFailed.errorDescription?.contains("Request failed") == true)

    let httpError = GoogleCloudAPIError.httpError(404, nil)
    #expect(httpError.errorDescription?.contains("404") == true)

    let cancelled = GoogleCloudAPIError.cancelled
    #expect(cancelled.errorDescription?.contains("cancelled") == true)

    let timeout = GoogleCloudAPIError.timeout(30)
    #expect(timeout.errorDescription?.contains("30") == true)
}

@Test func testAPIErrorWithGoogleCloudResponse() {
    let errorResponse = GoogleCloudErrorResponse(
        error: GoogleCloudErrorDetails(
            code: 403,
            message: "Permission denied",
            status: "PERMISSION_DENIED",
            errors: nil
        )
    )

    let httpError = GoogleCloudAPIError.httpError(403, errorResponse)

    #expect(httpError.errorDescription?.contains("Permission denied") == true)
    #expect(httpError.failureReason == "Permission denied")
    #expect(httpError.recoverySuggestion?.contains("permissions") == true)
}

@Test func testAPIErrorRecoverySuggestions() {
    let error401 = GoogleCloudAPIError.httpError(401, nil)
    #expect(error401.recoverySuggestion?.contains("credentials") == true)

    let error429 = GoogleCloudAPIError.httpError(429, nil)
    #expect(error429.recoverySuggestion?.contains("Wait") == true)

    let error500 = GoogleCloudAPIError.httpError(500, nil)
    #expect(error500.recoverySuggestion?.contains("Retry") == true)
}

// MARK: - Retry Configuration Tests

@Test func testRetryConfigurationDefaults() {
    let config = RetryConfiguration.default

    #expect(config.maxRetries == 3)
    #expect(config.baseDelay == 1.0)
    #expect(config.maxDelay == 30.0)
    #expect(config.jitterFactor == 0.2)
}

@Test func testRetryConfigurationNoRetries() {
    let config = RetryConfiguration.none

    #expect(config.maxRetries == 0)
}

@Test func testRetryConfigurationDelayCalculation() {
    let config = RetryConfiguration(
        maxRetries: 5,
        baseDelay: 1.0,
        maxDelay: 60.0,
        jitterFactor: 0
    )

    // Without jitter, delay should be exponential
    let delay0 = config.delay(for: 0)
    let delay1 = config.delay(for: 1)
    let delay2 = config.delay(for: 2)

    #expect(delay0 == 1.0)
    #expect(delay1 == 2.0)
    #expect(delay2 == 4.0)
}

@Test func testRetryConfigurationDelayCapped() {
    let config = RetryConfiguration(
        maxRetries: 10,
        baseDelay: 1.0,
        maxDelay: 10.0,
        jitterFactor: 0
    )

    // Even at attempt 10, delay should be capped at maxDelay
    let delay = config.delay(for: 10)
    #expect(delay == 10.0)
}

@Test func testRetryConfigurationIsRetryable() {
    let config = RetryConfiguration.default

    #expect(config.isRetryable(statusCode: 429))
    #expect(config.isRetryable(statusCode: 500))
    #expect(config.isRetryable(statusCode: 502))
    #expect(config.isRetryable(statusCode: 503))
    #expect(config.isRetryable(statusCode: 504))

    #expect(!config.isRetryable(statusCode: 400))
    #expect(!config.isRetryable(statusCode: 401))
    #expect(!config.isRetryable(statusCode: 403))
    #expect(!config.isRetryable(statusCode: 404))
    #expect(!config.isRetryable(statusCode: 200))
}

// MARK: - List Response Tests

@Test func testListResponseEmpty() {
    let response = GoogleCloudListResponse<String>(items: nil, nextPageToken: nil)

    #expect(response.itemsOrEmpty.isEmpty)
    #expect(!response.hasMorePages)
}

@Test func testListResponseWithItems() {
    let response = GoogleCloudListResponse(
        items: ["item1", "item2", "item3"],
        nextPageToken: "next-token"
    )

    #expect(response.itemsOrEmpty.count == 3)
    #expect(response.hasMorePages)
}

@Test func testListResponseEmptyNextPageToken() {
    let response = GoogleCloudListResponse(
        items: ["item"],
        nextPageToken: ""
    )

    #expect(!response.hasMorePages)
}

// MARK: - Empty Response Tests

@Test func testEmptyResponseDecodable() throws {
    let json = "{}"
    let data = json.data(using: .utf8)!

    let response = try JSONDecoder().decode(EmptyResponse.self, from: data)
    #expect(response != nil)
}

@Test func testEmptyBodyEncodable() throws {
    let body = EmptyBody()
    let data = try JSONEncoder().encode(body)
    let json = String(data: data, encoding: .utf8)

    #expect(json == "{}")
}

// MARK: - Operation Tests

@Test func testOperationIsDone() {
    let pendingOp = GoogleCloudOperation(
        kind: "compute#operation",
        id: "123",
        name: "op-123",
        description: nil,
        operationType: "insert",
        status: "PENDING",
        statusMessage: nil,
        targetLink: nil,
        targetId: nil,
        user: nil,
        progress: 0,
        insertTime: nil,
        startTime: nil,
        endTime: nil,
        selfLink: nil,
        zone: nil,
        region: nil,
        httpErrorStatusCode: nil,
        httpErrorMessage: nil,
        error: nil,
        warnings: nil
    )

    #expect(!pendingOp.isDone)

    let doneOp = GoogleCloudOperation(
        kind: "compute#operation",
        id: "123",
        name: "op-123",
        description: nil,
        operationType: "insert",
        status: "DONE",
        statusMessage: nil,
        targetLink: nil,
        targetId: nil,
        user: nil,
        progress: 100,
        insertTime: nil,
        startTime: nil,
        endTime: nil,
        selfLink: nil,
        zone: nil,
        region: nil,
        httpErrorStatusCode: nil,
        httpErrorMessage: nil,
        error: nil,
        warnings: nil
    )

    #expect(doneOp.isDone)
}

@Test func testOperationHasError() {
    let successOp = GoogleCloudOperation(
        kind: "compute#operation",
        id: "123",
        name: "op-123",
        description: nil,
        operationType: "insert",
        status: "DONE",
        statusMessage: nil,
        targetLink: nil,
        targetId: nil,
        user: nil,
        progress: 100,
        insertTime: nil,
        startTime: nil,
        endTime: nil,
        selfLink: nil,
        zone: nil,
        region: nil,
        httpErrorStatusCode: nil,
        httpErrorMessage: nil,
        error: nil,
        warnings: nil
    )

    #expect(!successOp.hasError)

    let errorOp = GoogleCloudOperation(
        kind: "compute#operation",
        id: "123",
        name: "op-123",
        description: nil,
        operationType: "insert",
        status: "DONE",
        statusMessage: nil,
        targetLink: nil,
        targetId: nil,
        user: nil,
        progress: 100,
        insertTime: nil,
        startTime: nil,
        endTime: nil,
        selfLink: nil,
        zone: nil,
        region: nil,
        httpErrorStatusCode: 400,
        httpErrorMessage: "Bad request",
        error: nil,
        warnings: nil
    )

    #expect(errorOp.hasError)
    #expect(errorOp.errorMessage == "Bad request")
}

// MARK: - Date Decoding Tests

@Test func testDateDecodingWithFractionalSeconds() throws {
    let json = """
    {"timestamp": "2024-01-15T10:30:45.123456Z"}
    """

    struct TestStruct: Decodable {
        let timestamp: Date
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy

    let result = try decoder.decode(TestStruct.self, from: json.data(using: .utf8)!)

    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: result.timestamp)

    #expect(components.year == 2024)
    #expect(components.month == 1)
    #expect(components.day == 15)
    #expect(components.hour == 10)
    #expect(components.minute == 30)
    #expect(components.second == 45)
}

@Test func testDateDecodingWithoutFractionalSeconds() throws {
    let json = """
    {"timestamp": "2024-01-15T10:30:45Z"}
    """

    struct TestStruct: Decodable {
        let timestamp: Date
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy

    let result = try decoder.decode(TestStruct.self, from: json.data(using: .utf8)!)

    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: result.timestamp)

    #expect(components.year == 2024)
    #expect(components.month == 1)
    #expect(components.day == 15)
}
