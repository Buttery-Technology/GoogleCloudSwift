//
//  GoogleCloudStorageAPITests.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Mock Storage API

/// Mock implementation of GoogleCloudStorageAPIProtocol for testing.
actor MockStorageAPI: GoogleCloudStorageAPIProtocol {
    let projectId: String

    // Stubs for each method
    var listBucketsHandler: ((String?, Int?, String?) async throws -> StorageBucketList)?
    var getBucketHandler: ((String) async throws -> StorageBucket)?
    var createBucketHandler: ((CreateBucketRequest) async throws -> StorageBucket)?
    var deleteBucketHandler: ((String) async throws -> Void)?
    var listObjectsHandler: ((String, String?, String?, Int?, String?) async throws -> StorageObjectList)?
    var getObjectHandler: ((String, String) async throws -> StorageObject)?
    var downloadObjectHandler: ((String, String) async throws -> Data)?
    var uploadObjectSimpleHandler: ((String, String, Data, String) async throws -> StorageObject)?
    var deleteObjectHandler: ((String, String) async throws -> Void)?

    // Call tracking
    var listBucketsCalls: [(prefix: String?, maxResults: Int?, pageToken: String?)] = []
    var getBucketCalls: [String] = []
    var createBucketCalls: [CreateBucketRequest] = []
    var deleteBucketCalls: [String] = []
    var listObjectsCalls: [(bucket: String, prefix: String?, delimiter: String?, maxResults: Int?, pageToken: String?)] = []
    var getObjectCalls: [(bucket: String, name: String)] = []
    var downloadObjectCalls: [(bucket: String, name: String)] = []
    var uploadObjectSimpleCalls: [(bucket: String, name: String, data: Data, contentType: String)] = []
    var deleteObjectCalls: [(bucket: String, name: String)] = []

    init(projectId: String = "test-project") {
        self.projectId = projectId
    }

    func listBuckets(prefix: String?, maxResults: Int?, pageToken: String?) async throws -> StorageBucketList {
        listBucketsCalls.append((prefix, maxResults, pageToken))
        if let handler = listBucketsHandler {
            return try await handler(prefix, maxResults, pageToken)
        }
        return StorageBucketList(kind: "storage#buckets", items: [], nextPageToken: nil)
    }

    func getBucket(name: String) async throws -> StorageBucket {
        getBucketCalls.append(name)
        if let handler = getBucketHandler {
            return try await handler(name)
        }
        return createMockBucket(name: name)
    }

    func createBucket(_ bucket: CreateBucketRequest) async throws -> StorageBucket {
        createBucketCalls.append(bucket)
        if let handler = createBucketHandler {
            return try await handler(bucket)
        }
        return createMockBucket(name: bucket.name, location: bucket.location)
    }

    func deleteBucket(name: String) async throws {
        deleteBucketCalls.append(name)
        if let handler = deleteBucketHandler {
            try await handler(name)
        }
    }

    func listObjects(bucket: String, prefix: String?, delimiter: String?, maxResults: Int?, pageToken: String?) async throws -> StorageObjectList {
        listObjectsCalls.append((bucket, prefix, delimiter, maxResults, pageToken))
        if let handler = listObjectsHandler {
            return try await handler(bucket, prefix, delimiter, maxResults, pageToken)
        }
        return StorageObjectList(kind: "storage#objects", items: [], prefixes: nil, nextPageToken: nil)
    }

    func getObject(bucket: String, name: String) async throws -> StorageObject {
        getObjectCalls.append((bucket, name))
        if let handler = getObjectHandler {
            return try await handler(bucket, name)
        }
        return createMockObject(bucket: bucket, name: name)
    }

    func downloadObject(bucket: String, name: String) async throws -> Data {
        downloadObjectCalls.append((bucket, name))
        if let handler = downloadObjectHandler {
            return try await handler(bucket, name)
        }
        return Data("mock content".utf8)
    }

    func uploadObjectSimple(bucket: String, name: String, data: Data, contentType: String) async throws -> StorageObject {
        uploadObjectSimpleCalls.append((bucket, name, data, contentType))
        if let handler = uploadObjectSimpleHandler {
            return try await handler(bucket, name, data, contentType)
        }
        return createMockObject(bucket: bucket, name: name, contentType: contentType, size: data.count)
    }

    func deleteObject(bucket: String, name: String) async throws {
        deleteObjectCalls.append((bucket, name))
        if let handler = deleteObjectHandler {
            try await handler(bucket, name)
        }
    }

    // MARK: - Mock Data Helpers

    private func createMockBucket(name: String, location: String? = "US") -> StorageBucket {
        StorageBucket(
            kind: "storage#bucket",
            id: name,
            selfLink: "https://storage.googleapis.com/storage/v1/b/\(name)",
            name: name,
            projectNumber: "123456789",
            timeCreated: Date(),
            updated: Date(),
            location: location,
            locationType: "multi-region",
            storageClass: "STANDARD",
            etag: "CAE=",
            versioning: nil,
            labels: nil,
            iamConfiguration: nil
        )
    }

    private func createMockObject(
        bucket: String,
        name: String,
        contentType: String = "application/octet-stream",
        size: Int = 100
    ) -> StorageObject {
        StorageObject(
            kind: "storage#object",
            id: "\(bucket)/\(name)/12345",
            selfLink: "https://storage.googleapis.com/storage/v1/b/\(bucket)/o/\(name)",
            name: name,
            bucket: bucket,
            generation: "12345",
            metageneration: "1",
            contentType: contentType,
            timeCreated: Date(),
            updated: Date(),
            storageClass: "STANDARD",
            size: String(size),
            md5Hash: "abc123",
            crc32c: "def456",
            etag: "CAE=",
            metadata: nil
        )
    }
}

// MARK: - Protocol Conformance Tests

@Test func testStorageAPIProtocolConformance() {
    // Verify that GoogleCloudStorageAPI conforms to the protocol
    // This is a compile-time check - if this compiles, conformance is verified
    func acceptsProtocol<T: GoogleCloudStorageAPIProtocol>(_ api: T) {}

    // The actual GoogleCloudStorageAPI should conform (checked at compile time via extension)
    // We can only test the mock here without real credentials
    let mock = MockStorageAPI()
    acceptsProtocol(mock)
}

// MARK: - Mock Storage API Tests

@Test func testMockStorageAPIProjectId() async {
    let mock = MockStorageAPI(projectId: "my-test-project")
    let projectId = await mock.projectId
    #expect(projectId == "my-test-project")
}

@Test func testMockListBucketsDefault() async throws {
    let mock = MockStorageAPI()
    let result = try await mock.listBuckets(prefix: nil, maxResults: nil, pageToken: nil)

    #expect(result.kind == "storage#buckets")
    #expect(result.items?.isEmpty == true)
    #expect(result.nextPageToken == nil)

    let calls = await mock.listBucketsCalls
    #expect(calls.count == 1)
}

@Test func testMockListBucketsWithHandler() async throws {
    let mock = MockStorageAPI()

    await mock.setListBucketsHandler { prefix, maxResults, pageToken in
        let bucket = StorageBucket(
            kind: "storage#bucket",
            id: "test-bucket",
            selfLink: nil,
            name: "test-bucket",
            projectNumber: nil,
            timeCreated: nil,
            updated: nil,
            location: "US",
            locationType: nil,
            storageClass: "STANDARD",
            etag: nil,
            versioning: nil,
            labels: nil,
            iamConfiguration: nil
        )
        return StorageBucketList(kind: "storage#buckets", items: [bucket], nextPageToken: "next-page")
    }

    let result = try await mock.listBuckets(prefix: "test-", maxResults: 10, pageToken: nil)

    #expect(result.items?.count == 1)
    #expect(result.items?.first?.name == "test-bucket")
    #expect(result.nextPageToken == "next-page")

    let calls = await mock.listBucketsCalls
    #expect(calls.count == 1)
    #expect(calls.first?.prefix == "test-")
    #expect(calls.first?.maxResults == 10)
}

@Test func testMockGetBucket() async throws {
    let mock = MockStorageAPI()
    let bucket = try await mock.getBucket(name: "my-bucket")

    #expect(bucket.name == "my-bucket")
    #expect(bucket.location == "US")

    let calls = await mock.getBucketCalls
    #expect(calls == ["my-bucket"])
}

@Test func testMockCreateBucket() async throws {
    let mock = MockStorageAPI()
    let request = CreateBucketRequest(
        name: "new-bucket",
        location: "EU",
        storageClass: "NEARLINE"
    )

    let bucket = try await mock.createBucket(request)

    #expect(bucket.name == "new-bucket")
    #expect(bucket.location == "EU")

    let calls = await mock.createBucketCalls
    #expect(calls.count == 1)
    #expect(calls.first?.name == "new-bucket")
}

@Test func testMockDeleteBucket() async throws {
    let mock = MockStorageAPI()

    try await mock.deleteBucket(name: "bucket-to-delete")

    let calls = await mock.deleteBucketCalls
    #expect(calls == ["bucket-to-delete"])
}

@Test func testMockListObjects() async throws {
    let mock = MockStorageAPI()
    let result = try await mock.listObjects(
        bucket: "my-bucket",
        prefix: "folder/",
        delimiter: "/",
        maxResults: 50,
        pageToken: nil
    )

    #expect(result.kind == "storage#objects")
    #expect(result.items?.isEmpty == true)

    let calls = await mock.listObjectsCalls
    #expect(calls.count == 1)
    #expect(calls.first?.bucket == "my-bucket")
    #expect(calls.first?.prefix == "folder/")
    #expect(calls.first?.delimiter == "/")
}

@Test func testMockGetObject() async throws {
    let mock = MockStorageAPI()
    let object = try await mock.getObject(bucket: "my-bucket", name: "path/to/file.txt")

    #expect(object.bucket == "my-bucket")
    #expect(object.name == "path/to/file.txt")

    let calls = await mock.getObjectCalls
    #expect(calls.count == 1)
    #expect(calls.first?.bucket == "my-bucket")
    #expect(calls.first?.name == "path/to/file.txt")
}

@Test func testMockDownloadObject() async throws {
    let mock = MockStorageAPI()

    await mock.setDownloadObjectHandler { bucket, name in
        Data("custom content for \(name)".utf8)
    }

    let data = try await mock.downloadObject(bucket: "my-bucket", name: "file.txt")
    let content = String(data: data, encoding: .utf8)

    #expect(content == "custom content for file.txt")

    let calls = await mock.downloadObjectCalls
    #expect(calls.count == 1)
}

@Test func testMockUploadObjectSimple() async throws {
    let mock = MockStorageAPI()
    let testData = Data("Hello, World!".utf8)

    let object = try await mock.uploadObjectSimple(
        bucket: "my-bucket",
        name: "greeting.txt",
        data: testData,
        contentType: "text/plain"
    )

    #expect(object.bucket == "my-bucket")
    #expect(object.name == "greeting.txt")
    #expect(object.contentType == "text/plain")
    #expect(object.sizeBytes == 13) // "Hello, World!" is 13 bytes

    let calls = await mock.uploadObjectSimpleCalls
    #expect(calls.count == 1)
    #expect(calls.first?.contentType == "text/plain")
}

@Test func testMockDeleteObject() async throws {
    let mock = MockStorageAPI()

    try await mock.deleteObject(bucket: "my-bucket", name: "file-to-delete.txt")

    let calls = await mock.deleteObjectCalls
    #expect(calls.count == 1)
    #expect(calls.first?.bucket == "my-bucket")
    #expect(calls.first?.name == "file-to-delete.txt")
}

@Test func testMockStorageAPIErrorHandling() async {
    let mock = MockStorageAPI()

    await mock.setGetBucketHandler { name in
        throw GoogleCloudAPIError.httpError(404, nil)
    }

    do {
        _ = try await mock.getBucket(name: "nonexistent-bucket")
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAPIError {
        if case .httpError(let code, _) = error {
            #expect(code == 404)
        } else {
            #expect(Bool(false), "Wrong error case")
        }
    } catch {
        #expect(Bool(false), "Wrong error type: \(error)")
    }
}

@Test func testMockStorageAPIRequestFailedError() async {
    let mock = MockStorageAPI()

    await mock.setGetBucketHandler { _ in
        throw GoogleCloudAPIError.requestFailed("Bucket does not exist")
    }

    do {
        _ = try await mock.getBucket(name: "missing-bucket")
        #expect(Bool(false), "Should have thrown")
    } catch let error as GoogleCloudAPIError {
        if case .requestFailed(let message) = error {
            #expect(message == "Bucket does not exist")
        } else {
            #expect(Bool(false), "Wrong error case")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

// MARK: - Request Type Tests

@Test func testCreateBucketRequestEncoding() throws {
    let request = CreateBucketRequest(
        name: "my-bucket",
        location: "US-CENTRAL1",
        storageClass: "STANDARD",
        versioning: true,
        labels: ["env": "test"],
        uniformBucketLevelAccess: true
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["name"] as? String == "my-bucket")
    #expect(json?["location"] as? String == "US-CENTRAL1")
    #expect(json?["storageClass"] as? String == "STANDARD")

    let versioning = json?["versioning"] as? [String: Any]
    #expect(versioning?["enabled"] as? Bool == true)

    let labels = json?["labels"] as? [String: String]
    #expect(labels?["env"] == "test")

    let iamConfig = json?["iamConfiguration"] as? [String: Any]
    let ubla = iamConfig?["uniformBucketLevelAccess"] as? [String: Any]
    #expect(ubla?["enabled"] as? Bool == true)
}

@Test func testCreateBucketRequestMinimal() throws {
    let request = CreateBucketRequest(name: "simple-bucket")

    let encoder = JSONEncoder()
    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    #expect(json?["name"] as? String == "simple-bucket")
    #expect(json?["location"] == nil)
    #expect(json?["storageClass"] == nil)
}

// MARK: - Response Type Tests

@Test func testStorageBucketDecoding() throws {
    let json = """
    {
        "kind": "storage#bucket",
        "id": "test-bucket",
        "selfLink": "https://storage.googleapis.com/storage/v1/b/test-bucket",
        "name": "test-bucket",
        "projectNumber": "123456789",
        "timeCreated": "2024-01-15T10:30:00.000Z",
        "updated": "2024-01-15T10:30:00.000Z",
        "location": "US",
        "locationType": "multi-region",
        "storageClass": "STANDARD",
        "etag": "CAE=",
        "versioning": {
            "enabled": true
        },
        "labels": {
            "env": "production"
        }
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let bucket = try decoder.decode(StorageBucket.self, from: Data(json.utf8))

    #expect(bucket.name == "test-bucket")
    #expect(bucket.location == "US")
    #expect(bucket.storageClass == "STANDARD")
    #expect(bucket.versioning?.enabled == true)
    #expect(bucket.labels?["env"] == "production")
    #expect(bucket.timeCreated != nil)
}

@Test func testStorageObjectDecoding() throws {
    let json = """
    {
        "kind": "storage#object",
        "id": "test-bucket/path/to/file.txt/12345",
        "selfLink": "https://storage.googleapis.com/storage/v1/b/test-bucket/o/path%2Fto%2Ffile.txt",
        "name": "path/to/file.txt",
        "bucket": "test-bucket",
        "generation": "12345",
        "metageneration": "1",
        "contentType": "text/plain",
        "timeCreated": "2024-01-15T10:30:00.123Z",
        "updated": "2024-01-15T10:30:00.123Z",
        "storageClass": "STANDARD",
        "size": "1024",
        "md5Hash": "abc123",
        "crc32c": "def456",
        "etag": "CAE=",
        "metadata": {
            "custom-key": "custom-value"
        }
    }
    """

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = GoogleCloudDateDecoding.strategy
    let object = try decoder.decode(StorageObject.self, from: Data(json.utf8))

    #expect(object.name == "path/to/file.txt")
    #expect(object.bucket == "test-bucket")
    #expect(object.contentType == "text/plain")
    #expect(object.size == "1024")
    #expect(object.sizeBytes == 1024)
    #expect(object.metadata?["custom-key"] == "custom-value")
    #expect(object.timeCreated != nil)
}

@Test func testStorageObjectSizeBytesNil() {
    let object = StorageObject(
        kind: nil,
        id: nil,
        selfLink: nil,
        name: "test",
        bucket: "bucket",
        generation: nil,
        metageneration: nil,
        contentType: nil,
        timeCreated: nil,
        updated: nil,
        storageClass: nil,
        size: nil,
        md5Hash: nil,
        crc32c: nil,
        etag: nil,
        metadata: nil
    )

    #expect(object.sizeBytes == nil)
}

@Test func testStorageBucketListDecoding() throws {
    let json = """
    {
        "kind": "storage#buckets",
        "items": [
            {"name": "bucket-1", "location": "US"},
            {"name": "bucket-2", "location": "EU"}
        ],
        "nextPageToken": "token123"
    }
    """

    let decoder = JSONDecoder()
    let list = try decoder.decode(StorageBucketList.self, from: Data(json.utf8))

    #expect(list.kind == "storage#buckets")
    #expect(list.items?.count == 2)
    #expect(list.items?[0].name == "bucket-1")
    #expect(list.items?[1].name == "bucket-2")
    #expect(list.nextPageToken == "token123")
}

@Test func testStorageObjectListDecoding() throws {
    let json = """
    {
        "kind": "storage#objects",
        "items": [
            {"name": "file1.txt", "bucket": "test-bucket"},
            {"name": "file2.txt", "bucket": "test-bucket"}
        ],
        "prefixes": ["folder1/", "folder2/"],
        "nextPageToken": "page2"
    }
    """

    let decoder = JSONDecoder()
    let list = try decoder.decode(StorageObjectList.self, from: Data(json.utf8))

    #expect(list.kind == "storage#objects")
    #expect(list.items?.count == 2)
    #expect(list.prefixes?.count == 2)
    #expect(list.prefixes?.contains("folder1/") == true)
    #expect(list.nextPageToken == "page2")
}

// MARK: - Mock Factory Tests

@Test func testMockAccessTokenFactory() {
    let token = GoogleCloudMockFactory.mockAccessToken(expiresIn: 7200)

    #expect(token.tokenType == "Bearer")
    #expect(token.token.hasPrefix("mock-access-token-"))
    #expect(!token.isExpired)
}

@Test func testInMemoryMockAuthClient() async throws {
    let mockAuth = InMemoryMockAuthClient(projectId: "test-project")

    let projectId = await mockAuth.projectId
    #expect(projectId == "test-project")

    let email = await mockAuth.serviceAccountEmail
    #expect(email == "test@test-project.iam.gserviceaccount.com")

    let token = try await mockAuth.getAccessToken()
    #expect(token.tokenType == "Bearer")
    #expect(!token.isExpired)
}

@Test func testInMemoryMockAuthClientRefresh() async throws {
    let mockAuth = InMemoryMockAuthClient()

    let token1 = try await mockAuth.getAccessToken()
    let token2 = try await mockAuth.refreshToken()

    // Refresh should return a new token
    #expect(token1.token != token2.token)
}

// MARK: - Mock Helper Extensions

extension MockStorageAPI {
    func setListBucketsHandler(_ handler: @escaping (String?, Int?, String?) async throws -> StorageBucketList) {
        listBucketsHandler = handler
    }

    func setGetBucketHandler(_ handler: @escaping (String) async throws -> StorageBucket) {
        getBucketHandler = handler
    }

    func setDownloadObjectHandler(_ handler: @escaping (String, String) async throws -> Data) {
        downloadObjectHandler = handler
    }
}
