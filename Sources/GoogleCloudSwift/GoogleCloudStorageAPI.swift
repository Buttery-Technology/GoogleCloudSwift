//
//  GoogleCloudStorageAPI.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/9/26.
//

import AsyncHTTPClient
import Foundation
import NIOCore

/// REST API client for Google Cloud Storage.
///
/// Provides methods for managing buckets and objects via the JSON API.
///
/// ## Example Usage
/// ```swift
/// let storageAPI = await GoogleCloudStorageAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // List buckets
/// let buckets = try await storageAPI.listBuckets()
///
/// // Upload an object
/// try await storageAPI.uploadObject(
///     bucket: "my-bucket",
///     name: "path/to/file.txt",
///     data: fileData,
///     contentType: "text/plain"
/// )
///
/// // Download an object
/// let data = try await storageAPI.downloadObject(bucket: "my-bucket", name: "path/to/file.txt")
/// ```
public actor GoogleCloudStorageAPI {
    private let client: GoogleCloudHTTPClient
    private let _projectId: String

    /// The Google Cloud project ID this client operates on.
    public var projectId: String { _projectId }

    private static let baseURL = "https://storage.googleapis.com"

    /// Initialize the Cloud Storage API client.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - projectId: The Google Cloud project ID.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds (default: 120 for large uploads).
    public init(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        projectId: String,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 120
    ) {
        self._projectId = projectId
        self.client = GoogleCloudHTTPClient(
            authClient: authClient,
            httpClient: httpClient,
            baseURL: Self.baseURL,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    /// Create a Cloud Storage API client, inferring project ID from auth credentials.
    /// - Parameters:
    ///   - authClient: The authentication client for obtaining access tokens.
    ///   - httpClient: The underlying HTTP client.
    ///   - retryConfiguration: Configuration for retry behavior on transient failures.
    ///   - requestTimeout: Timeout for individual HTTP requests in seconds (default: 120).
    /// - Returns: A configured Cloud Storage API client.
    public static func create(
        authClient: GoogleCloudAuthClient,
        httpClient: HTTPClient,
        retryConfiguration: RetryConfiguration = .default,
        requestTimeout: TimeInterval = 120
    ) async -> GoogleCloudStorageAPI {
        let projectId = await authClient.projectId
        return GoogleCloudStorageAPI(
            authClient: authClient,
            httpClient: httpClient,
            projectId: projectId,
            retryConfiguration: retryConfiguration,
            requestTimeout: requestTimeout
        )
    }

    // MARK: - Buckets

    /// List all buckets in the project.
    /// - Parameters:
    ///   - prefix: Filter results to buckets whose names begin with this prefix.
    ///   - maxResults: Maximum number of buckets to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of buckets.
    public func listBuckets(
        prefix: String? = nil,
        maxResults: Int? = nil,
        pageToken: String? = nil
    ) async throws -> StorageBucketList {
        var params: [String: String] = ["project": _projectId]
        if let prefix = prefix { params["prefix"] = prefix }
        if let maxResults = maxResults { params["maxResults"] = String(maxResults) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<StorageBucketList> = try await client.get(
            path: "/storage/v1/b",
            queryParameters: params
        )
        return response.data
    }

    /// Get a pagination helper for listing all buckets.
    /// - Parameters:
    ///   - prefix: Filter results to buckets whose names begin with this prefix.
    ///   - maxResults: Maximum number of buckets per page.
    /// - Returns: A pagination helper.
    public func listAllBuckets(
        prefix: String? = nil,
        maxResults: Int? = nil
    ) -> PaginationHelper<StorageBucket> {
        PaginationHelper { pageToken in
            let response = try await self.listBuckets(
                prefix: prefix,
                maxResults: maxResults,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.items,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get metadata for a bucket.
    /// - Parameter name: The bucket name.
    /// - Returns: The bucket metadata.
    public func getBucket(name: String) async throws -> StorageBucket {
        let response: GoogleCloudAPIResponse<StorageBucket> = try await client.get(
            path: "/storage/v1/b/\(name)"
        )
        return response.data
    }

    /// Create a new bucket.
    /// - Parameter bucket: The bucket configuration.
    /// - Returns: The created bucket.
    public func createBucket(_ bucket: CreateBucketRequest) async throws -> StorageBucket {
        let response: GoogleCloudAPIResponse<StorageBucket> = try await client.post(
            path: "/storage/v1/b",
            body: bucket,
            queryParameters: ["project": _projectId]
        )
        return response.data
    }

    /// Delete a bucket.
    /// - Parameter name: The bucket name.
    public func deleteBucket(name: String) async throws {
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await client.delete(
            path: "/storage/v1/b/\(name)"
        )
    }

    // MARK: - Objects

    /// List objects in a bucket.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - prefix: Filter results to objects whose names begin with this prefix.
    ///   - delimiter: Returns results in a directory-like mode.
    ///   - maxResults: Maximum number of objects to return.
    ///   - pageToken: Token for pagination.
    /// - Returns: A list of objects.
    public func listObjects(
        bucket: String,
        prefix: String? = nil,
        delimiter: String? = nil,
        maxResults: Int? = nil,
        pageToken: String? = nil
    ) async throws -> StorageObjectList {
        var params: [String: String] = [:]
        if let prefix = prefix { params["prefix"] = prefix }
        if let delimiter = delimiter { params["delimiter"] = delimiter }
        if let maxResults = maxResults { params["maxResults"] = String(maxResults) }
        if let pageToken = pageToken { params["pageToken"] = pageToken }

        let response: GoogleCloudAPIResponse<StorageObjectList> = try await client.get(
            path: "/storage/v1/b/\(bucket)/o",
            queryParameters: params.isEmpty ? nil : params
        )
        return response.data
    }

    /// Get a pagination helper for listing all objects in a bucket.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - prefix: Filter results to objects whose names begin with this prefix.
    ///   - delimiter: Returns results in a directory-like mode.
    ///   - maxResults: Maximum number of objects per page.
    /// - Returns: A pagination helper.
    public func listAllObjects(
        bucket: String,
        prefix: String? = nil,
        delimiter: String? = nil,
        maxResults: Int? = nil
    ) -> PaginationHelper<StorageObject> {
        PaginationHelper { pageToken in
            let response = try await self.listObjects(
                bucket: bucket,
                prefix: prefix,
                delimiter: delimiter,
                maxResults: maxResults,
                pageToken: pageToken
            )
            return GoogleCloudListResponse(
                items: response.items,
                nextPageToken: response.nextPageToken
            )
        }
    }

    /// Get metadata for an object.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - name: The object name.
    /// - Returns: The object metadata.
    public func getObject(bucket: String, name: String) async throws -> StorageObject {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let response: GoogleCloudAPIResponse<StorageObject> = try await client.get(
            path: "/storage/v1/b/\(bucket)/o/\(encodedName)"
        )
        return response.data
    }

    /// Download an object's data.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - name: The object name.
    /// - Returns: The object data.
    public func downloadObject(bucket: String, name: String) async throws -> Data {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return try await client.getRaw(
            path: "/storage/v1/b/\(bucket)/o/\(encodedName)",
            queryParameters: ["alt": "media"]
        )
    }

    /// Upload an object.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - name: The object name (path within the bucket).
    ///   - data: The object data.
    ///   - contentType: The content type (MIME type) of the object.
    ///   - metadata: Optional additional metadata (note: use updateObjectMetadata to set metadata).
    /// - Returns: The created object metadata.
    public func uploadObject(
        bucket: String,
        name: String,
        data: Data,
        contentType: String,
        metadata: [String: String]? = nil
    ) async throws -> StorageObject {
        // Use simple upload - metadata can be set separately via PATCH if needed
        let result = try await uploadObjectSimple(
            bucket: bucket,
            name: name,
            data: data,
            contentType: contentType
        )

        // If metadata was provided, update the object with it
        if let metadata = metadata, !metadata.isEmpty {
            return try await updateObjectMetadata(
                bucket: bucket,
                name: name,
                metadata: metadata
            )
        }

        return result
    }

    /// Update an object's custom metadata.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - name: The object name.
    ///   - metadata: The metadata key-value pairs to set.
    /// - Returns: The updated object metadata.
    public func updateObjectMetadata(
        bucket: String,
        name: String,
        metadata: [String: String]
    ) async throws -> StorageObject {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let request = UpdateObjectMetadataRequest(metadata: metadata)
        let response: GoogleCloudAPIResponse<StorageObject> = try await client.patch(
            path: "/storage/v1/b/\(bucket)/o/\(encodedName)",
            body: request
        )
        return response.data
    }

    /// Upload object data directly (simple upload).
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - name: The object name.
    ///   - data: The object data.
    ///   - contentType: The content type.
    /// - Returns: The created object metadata.
    public func uploadObjectSimple(
        bucket: String,
        name: String,
        data: Data,
        contentType: String
    ) async throws -> StorageObject {
        // Don't encode name here - buildURL handles query parameter encoding
        let response: GoogleCloudAPIResponse<StorageObject> = try await client.postRawWithJSONResponse(
            path: "/upload/storage/v1/b/\(bucket)/o",
            data: data,
            contentType: contentType,
            queryParameters: [
                "uploadType": "media",
                "name": name
            ]
        )
        return response.data
    }

    /// Delete an object.
    /// - Parameters:
    ///   - bucket: The bucket name.
    ///   - name: The object name.
    public func deleteObject(bucket: String, name: String) async throws {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let _: GoogleCloudAPIResponse<EmptyResponse> = try await client.delete(
            path: "/storage/v1/b/\(bucket)/o/\(encodedName)"
        )
    }

    /// Copy an object.
    /// - Parameters:
    ///   - sourceBucket: The source bucket name.
    ///   - sourceName: The source object name.
    ///   - destinationBucket: The destination bucket name.
    ///   - destinationName: The destination object name.
    /// - Returns: The copied object metadata.
    public func copyObject(
        sourceBucket: String,
        sourceName: String,
        destinationBucket: String,
        destinationName: String
    ) async throws -> StorageObject {
        let encodedSource = sourceName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? sourceName
        let encodedDest = destinationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? destinationName

        let response: GoogleCloudAPIResponse<StorageObject> = try await client.post(
            path: "/storage/v1/b/\(sourceBucket)/o/\(encodedSource)/copyTo/b/\(destinationBucket)/o/\(encodedDest)",
            body: EmptyBody()
        )
        return response.data
    }
}

// MARK: - Request Types

/// Request to create a bucket.
public struct CreateBucketRequest: Encodable, Sendable {
    public let name: String
    public let location: String?
    public let storageClass: String?
    public let versioning: VersioningConfig?
    public let labels: [String: String]?
    public let iamConfiguration: IAMConfiguration?

    public init(
        name: String,
        location: String? = nil,
        storageClass: String? = nil,
        versioning: Bool? = nil,
        labels: [String: String]? = nil,
        uniformBucketLevelAccess: Bool? = nil
    ) {
        self.name = name
        self.location = location
        self.storageClass = storageClass
        self.versioning = versioning.map { VersioningConfig(enabled: $0) }
        self.labels = labels
        self.iamConfiguration = uniformBucketLevelAccess.map {
            IAMConfiguration(uniformBucketLevelAccess: UniformBucketLevelAccess(enabled: $0))
        }
    }

    public struct VersioningConfig: Encodable, Sendable {
        public let enabled: Bool
    }

    public struct IAMConfiguration: Encodable, Sendable {
        public let uniformBucketLevelAccess: UniformBucketLevelAccess
    }

    public struct UniformBucketLevelAccess: Encodable, Sendable {
        public let enabled: Bool
    }
}

/// Request body for object upload metadata.
struct UploadObjectRequest: Encodable, Sendable {
    let name: String
    let contentType: String
    let metadata: [String: String]?
}

/// Request body for updating object metadata.
struct UpdateObjectMetadataRequest: Encodable, Sendable {
    let metadata: [String: String]
}

// MARK: - Response Types

/// List of buckets.
public struct StorageBucketList: Codable, Sendable {
    public let kind: String?
    public let items: [StorageBucket]?
    public let nextPageToken: String?
}

/// Storage bucket metadata.
public struct StorageBucket: Codable, Sendable {
    public let kind: String?
    public let id: String?
    public let selfLink: String?
    public let name: String?
    public let projectNumber: String?
    public let timeCreated: Date?
    public let updated: Date?
    public let location: String?
    public let locationType: String?
    public let storageClass: String?
    public let etag: String?
    public let versioning: VersioningStatus?
    public let labels: [String: String]?
    public let iamConfiguration: IAMConfigurationResponse?

    public struct VersioningStatus: Codable, Sendable {
        public let enabled: Bool?
    }

    public struct IAMConfigurationResponse: Codable, Sendable {
        public let uniformBucketLevelAccess: UniformBucketLevelAccessResponse?

        public struct UniformBucketLevelAccessResponse: Codable, Sendable {
            public let enabled: Bool?
            public let lockedTime: Date?
        }
    }
}

/// List of objects.
public struct StorageObjectList: Codable, Sendable {
    public let kind: String?
    public let items: [StorageObject]?
    public let prefixes: [String]?
    public let nextPageToken: String?
}

/// Storage object metadata.
public struct StorageObject: Codable, Sendable {
    public let kind: String?
    public let id: String?
    public let selfLink: String?
    public let name: String?
    public let bucket: String?
    public let generation: String?
    public let metageneration: String?
    public let contentType: String?
    public let timeCreated: Date?
    public let updated: Date?
    public let storageClass: String?
    public let size: String?
    public let md5Hash: String?
    public let crc32c: String?
    public let etag: String?
    public let metadata: [String: String]?

    /// Size as integer bytes.
    public var sizeBytes: Int64? {
        size.flatMap { Int64($0) }
    }
}
