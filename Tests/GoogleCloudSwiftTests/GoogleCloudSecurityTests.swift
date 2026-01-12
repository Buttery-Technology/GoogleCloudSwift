import Foundation
import Testing
@testable import GoogleCloudSwift

/// Thread-safe counter for tests
actor TestCounter {
    var value = 0
    func increment() { value += 1 }
}

// MARK: - Request Coalescer Tests

@Test func testRequestCoalescerSingleRequest() async throws {
    let coalescer = RequestCoalescer<String, Int>()

    let counter = TestCounter()
    let result = try await coalescer.coalesce(key: "test") {
        await counter.increment()
        return 42
    }

    #expect(result == 42)
    #expect(await counter.value == 1)
}

@Test func testRequestCoalescerCoalescesConcurrentRequests() async throws {
    let coalescer = RequestCoalescer<String, Int>()

    let counter = TestCounter()

    // Launch multiple concurrent requests for the same key
    let results = try await withThrowingTaskGroup(of: Int.self) { group in
        for _ in 0..<10 {
            group.addTask {
                try await coalescer.coalesce(key: "shared-key") {
                    // Add small delay to ensure coalescing
                    try await Task.sleep(nanoseconds: 50_000_000)
                    await counter.increment()
                    return 42
                }
            }
        }

        var results: [Int] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }

    // All results should be the same
    #expect(results.count == 10)
    #expect(results.allSatisfy { $0 == 42 })

    // Only one fetch should have occurred
    #expect(await counter.value == 1)
}

@Test func testRequestCoalescerDifferentKeys() async throws {
    let coalescer = RequestCoalescer<String, Int>()

    let counter = TestCounter()

    async let result1 = coalescer.coalesce(key: "key1") {
        await counter.increment()
        return 1
    }

    async let result2 = coalescer.coalesce(key: "key2") {
        await counter.increment()
        return 2
    }

    let (r1, r2) = try await (result1, result2)

    #expect(r1 == 1)
    #expect(r2 == 2)
    #expect(await counter.value == 2) // Different keys, so two fetches
}

@Test func testRequestCoalescerErrorPropagation() async {
    let coalescer = RequestCoalescer<String, Int>()

    do {
        _ = try await coalescer.coalesce(key: "error-key") {
            throw SecurityTestError.simulated
        }
        #expect(Bool(false), "Should have thrown")
    } catch {
        #expect(error is SecurityTestError)
    }
}

@Test func testRequestCoalescerHasInFlightRequest() async throws {
    let coalescer = RequestCoalescer<String, Int>()

    let task = Task {
        try await coalescer.coalesce(key: "slow-key") {
            try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            return 42
        }
    }

    // Give the task time to start
    try await Task.sleep(nanoseconds: 10_000_000) // 10ms

    let hasInFlight = await coalescer.hasInFlightRequest(for: "slow-key")
    #expect(hasInFlight)

    _ = try await task.value

    let hasInFlightAfter = await coalescer.hasInFlightRequest(for: "slow-key")
    #expect(!hasInFlightAfter)
}

// MARK: - Token Refresh Coalescer Tests

@Test func testTokenRefreshCoalescerBasic() async throws {
    let coalescer = TokenRefreshCoalescer()

    let token = try await coalescer.refreshToken(scope: "cloud-platform") {
        GoogleCloudAccessToken(
            token: "test-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
    }

    #expect(token.token == "test-token")
}

@Test func testTokenRefreshCoalescerCoalesces() async throws {
    let coalescer = TokenRefreshCoalescer()

    let counter = TestCounter()

    let results = try await withThrowingTaskGroup(of: GoogleCloudAccessToken.self) { group in
        for _ in 0..<5 {
            group.addTask {
                try await coalescer.refreshToken(scope: "cloud-platform") {
                    try await Task.sleep(nanoseconds: 50_000_000)
                    await counter.increment()
                    return GoogleCloudAccessToken(
                        token: "token-coalesced",
                        tokenType: "Bearer",
                        expiresAt: Date().addingTimeInterval(3600)
                    )
                }
            }
        }

        var tokens: [GoogleCloudAccessToken] = []
        for try await token in group {
            tokens.append(token)
        }
        return tokens
    }

    // All should have the same token (coalesced)
    #expect(results.count == 5)
    #expect(Set(results.map { $0.token }).count == 1)
    #expect(await counter.value == 1)
}

@Test func testTokenRefreshCoalescerIsRefreshing() async throws {
    let coalescer = TokenRefreshCoalescer()

    let task = Task {
        try await coalescer.refreshToken(scope: "test-scope") {
            try await Task.sleep(nanoseconds: 100_000_000)
            return GoogleCloudAccessToken(
                token: "token",
                tokenType: "Bearer",
                expiresAt: Date().addingTimeInterval(3600)
            )
        }
    }

    try await Task.sleep(nanoseconds: 10_000_000)

    let isRefreshing = await coalescer.isRefreshing(scope: "test-scope")
    #expect(isRefreshing)

    _ = try await task.value

    let isRefreshingAfter = await coalescer.isRefreshing(scope: "test-scope")
    #expect(!isRefreshingAfter)
}

// MARK: - Secure String Tests

@Test func testSecureStringFromString() {
    let secureStr = SecureString(string: "secret-value")

    #expect(secureStr.utf8String == "secret-value")
    #expect(secureStr.count == 12)
}

@Test func testSecureStringFromBytes() {
    let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
    let secureStr = SecureString(bytes: bytes)

    #expect(secureStr.utf8String == "Hello")
}

@Test func testSecureStringFromData() {
    let data = "TestData".data(using: .utf8)!
    let secureStr = SecureString(data: data)

    #expect(secureStr.utf8String == "TestData")
}

@Test func testSecureStringClear() {
    let secureStr = SecureString(string: "secret")

    #expect(!secureStr.isCleared)

    secureStr.clear()

    #expect(secureStr.isCleared)
    #expect(secureStr.count == 0)
}

@Test func testSecureStringWithUTF8String() {
    let secureStr = SecureString(string: "secret")

    let result = secureStr.withUTF8String { str in
        str.uppercased()
    }

    #expect(result == "SECRET")
}

@Test func testSecureStringWithBytes() {
    let secureStr = SecureString(string: "ABC")

    let result = secureStr.withBytes { bytes in
        bytes.count
    }

    #expect(result == 3)
}

@Test func testSecureStringData() {
    let secureStr = SecureString(string: "test")
    let data = secureStr.data

    #expect(data == "test".data(using: .utf8))
}

@Test func testSecureStringRawBytes() {
    let secureStr = SecureString(string: "Hi")
    let bytes = secureStr.rawBytes

    #expect(bytes == [0x48, 0x69]) // "Hi" in ASCII
}

// MARK: - Credential Validator Tests

@Test func testValidatorMissingProjectId() {
    let credentials = GoogleCloudServiceAccountCredentials(
        type: "service_account",
        projectId: "",
        privateKeyId: "key123",
        privateKey: "-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----",
        clientEmail: "test@project.iam.gserviceaccount.com",
        clientId: "123",
        authUri: "https://accounts.google.com/o/oauth2/auth",
        tokenUri: "https://oauth2.googleapis.com/token",
        authProviderX509CertUrl: "https://www.googleapis.com/oauth2/v1/certs",
        clientX509CertUrl: "https://www.googleapis.com/robot/v1/metadata/x509/test",
        universeDomain: nil
    )

    do {
        try CredentialValidator.validate(credentials)
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAuthError {
        if case .invalidCredentials(let message) = error {
            #expect(message.contains("project_id"))
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testValidatorMissingClientEmail() {
    let credentials = GoogleCloudServiceAccountCredentials(
        type: "service_account",
        projectId: "test-project",
        privateKeyId: "key123",
        privateKey: "-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----",
        clientEmail: "",
        clientId: "123",
        authUri: "https://accounts.google.com/o/oauth2/auth",
        tokenUri: "https://oauth2.googleapis.com/token",
        authProviderX509CertUrl: "https://www.googleapis.com/oauth2/v1/certs",
        clientX509CertUrl: "https://www.googleapis.com/robot/v1/metadata/x509/test",
        universeDomain: nil
    )

    do {
        try CredentialValidator.validate(credentials)
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAuthError {
        if case .invalidCredentials(let message) = error {
            #expect(message.contains("client_email"))
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testValidatorInvalidPrivateKeyFormat() {
    let credentials = GoogleCloudServiceAccountCredentials(
        type: "service_account",
        projectId: "test-project",
        privateKeyId: "key123",
        privateKey: "not-a-valid-key",
        clientEmail: "test@project.iam.gserviceaccount.com",
        clientId: "123",
        authUri: "https://accounts.google.com/o/oauth2/auth",
        tokenUri: "https://oauth2.googleapis.com/token",
        authProviderX509CertUrl: "https://www.googleapis.com/oauth2/v1/certs",
        clientX509CertUrl: "https://www.googleapis.com/robot/v1/metadata/x509/test",
        universeDomain: nil
    )

    do {
        try CredentialValidator.validate(credentials)
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAuthError {
        if case .invalidPrivateKey = error {
            // Expected
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testValidatorInvalidTokenUri() {
    let credentials = GoogleCloudServiceAccountCredentials(
        type: "service_account",
        projectId: "test-project",
        privateKeyId: "key123",
        privateKey: "-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----",
        clientEmail: "test@project.iam.gserviceaccount.com",
        clientId: "123",
        authUri: "https://accounts.google.com/o/oauth2/auth",
        tokenUri: "http://insecure.example.com/token", // HTTP, not HTTPS
        authProviderX509CertUrl: "https://www.googleapis.com/oauth2/v1/certs",
        clientX509CertUrl: "https://www.googleapis.com/robot/v1/metadata/x509/test",
        universeDomain: nil
    )

    do {
        try CredentialValidator.validate(credentials)
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAuthError {
        if case .invalidCredentials(let message) = error {
            #expect(message.contains("HTTPS"))
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testValidatorValidCredentials() {
    let credentials = GoogleCloudServiceAccountCredentials(
        type: "service_account",
        projectId: "test-project",
        privateKeyId: "key123",
        privateKey: "-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----",
        clientEmail: "test@project.iam.gserviceaccount.com",
        clientId: "123",
        authUri: "https://accounts.google.com/o/oauth2/auth",
        tokenUri: "https://oauth2.googleapis.com/token",
        authProviderX509CertUrl: "https://www.googleapis.com/oauth2/v1/certs",
        clientX509CertUrl: "https://www.googleapis.com/robot/v1/metadata/x509/test",
        universeDomain: nil
    )

    do {
        try CredentialValidator.validate(credentials)
        // Success
    } catch {
        #expect(Bool(false), "Should not have thrown: \(error)")
    }
}

// MARK: - Helper Types

enum SecurityTestError: Error {
    case simulated
}
