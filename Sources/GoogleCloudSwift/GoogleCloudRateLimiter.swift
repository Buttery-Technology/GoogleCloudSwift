//
//  GoogleCloudRateLimiter.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation

/// A token bucket rate limiter for controlling API request rates.
///
/// This implementation uses the token bucket algorithm to limit the rate of requests
/// to Google Cloud APIs. Tokens are added to the bucket at a fixed rate, and each
/// request consumes one token. If the bucket is empty, requests will wait until
/// tokens become available.
///
/// ## Example Usage
/// ```swift
/// // Create a rate limiter allowing 100 requests per second
/// let limiter = TokenBucketRateLimiter(
///     tokensPerSecond: 100,
///     bucketSize: 100
/// )
///
/// // Before making a request, acquire a token
/// try await limiter.acquire()
/// // Make the API request...
///
/// // Or acquire multiple tokens for batch operations
/// try await limiter.acquire(tokens: 10)
/// ```
///
/// ## Thread Safety
/// This rate limiter is implemented as an actor and is safe for concurrent access
/// from multiple tasks.
public actor TokenBucketRateLimiter: Sendable {
    /// Configuration for the rate limiter.
    public struct Configuration: Sendable {
        /// Number of tokens added per second.
        public let tokensPerSecond: Double

        /// Maximum tokens the bucket can hold.
        public let bucketSize: Double

        /// Initial number of tokens (defaults to bucket size).
        public let initialTokens: Double?

        /// Maximum time to wait for tokens in seconds (nil = wait indefinitely).
        public let maxWaitTime: TimeInterval?

        /// Create a rate limiter configuration.
        /// - Parameters:
        ///   - tokensPerSecond: Number of tokens added per second.
        ///   - bucketSize: Maximum tokens the bucket can hold.
        ///   - initialTokens: Initial number of tokens (defaults to bucket size).
        ///   - maxWaitTime: Maximum time to wait for tokens (nil = indefinite).
        public init(
            tokensPerSecond: Double,
            bucketSize: Double,
            initialTokens: Double? = nil,
            maxWaitTime: TimeInterval? = nil
        ) {
            self.tokensPerSecond = tokensPerSecond
            self.bucketSize = bucketSize
            self.initialTokens = initialTokens
            self.maxWaitTime = maxWaitTime
        }

        /// Default configuration: 100 requests/second, bucket size 100.
        public static let `default` = Configuration(
            tokensPerSecond: 100,
            bucketSize: 100
        )

        /// Conservative configuration: 10 requests/second.
        public static let conservative = Configuration(
            tokensPerSecond: 10,
            bucketSize: 20
        )

        /// Aggressive configuration: 500 requests/second.
        public static let aggressive = Configuration(
            tokensPerSecond: 500,
            bucketSize: 500
        )

        /// Configuration for Compute Engine API (default quota: 20/sec).
        public static let computeEngine = Configuration(
            tokensPerSecond: 15,
            bucketSize: 30
        )

        /// Configuration for Cloud Storage API (default quota: 5000/sec for reads).
        public static let cloudStorage = Configuration(
            tokensPerSecond: 1000,
            bucketSize: 1000
        )

        /// Configuration for Cloud Logging API (default quota: 60/sec writes).
        public static let cloudLogging = Configuration(
            tokensPerSecond: 50,
            bucketSize: 100
        )
    }

    private let tokensPerSecond: Double
    private let bucketSize: Double
    private let maxWaitTime: TimeInterval?
    private var tokens: Double
    private var lastRefillTime: Date

    /// Create a token bucket rate limiter.
    /// - Parameters:
    ///   - tokensPerSecond: Number of tokens added per second.
    ///   - bucketSize: Maximum tokens the bucket can hold.
    ///   - initialTokens: Initial number of tokens (defaults to bucket size).
    ///   - maxWaitTime: Maximum time to wait for tokens (nil = indefinite).
    public init(
        tokensPerSecond: Double,
        bucketSize: Double,
        initialTokens: Double? = nil,
        maxWaitTime: TimeInterval? = nil
    ) {
        self.tokensPerSecond = tokensPerSecond
        self.bucketSize = bucketSize
        self.maxWaitTime = maxWaitTime
        self.tokens = initialTokens ?? bucketSize
        self.lastRefillTime = Date()
    }

    /// Create a rate limiter from a configuration.
    /// - Parameter configuration: The rate limiter configuration.
    public init(configuration: Configuration) {
        self.tokensPerSecond = configuration.tokensPerSecond
        self.bucketSize = configuration.bucketSize
        self.maxWaitTime = configuration.maxWaitTime
        self.tokens = configuration.initialTokens ?? configuration.bucketSize
        self.lastRefillTime = Date()
    }

    /// Acquire one token, waiting if necessary.
    /// - Throws: `RateLimiterError.timeout` if max wait time is exceeded.
    public func acquire() async throws {
        try await acquire(tokens: 1)
    }

    /// Acquire multiple tokens, waiting if necessary.
    /// - Parameter tokens: Number of tokens to acquire.
    /// - Throws: `RateLimiterError.timeout` if max wait time is exceeded,
    ///           `RateLimiterError.exceedsBucketSize` if requesting more than bucket size.
    public func acquire(tokens requestedTokens: Double) async throws {
        guard requestedTokens <= bucketSize else {
            throw RateLimiterError.exceedsBucketSize(requested: requestedTokens, bucketSize: bucketSize)
        }

        let startTime = Date()

        while true {
            try Task.checkCancellation()

            refill()

            if tokens >= requestedTokens {
                tokens -= requestedTokens
                return
            }

            // Check if we've exceeded max wait time
            if let maxWait = maxWaitTime {
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed >= maxWait {
                    throw RateLimiterError.timeout(waited: elapsed, requested: requestedTokens)
                }
            }

            // Calculate how long to wait for enough tokens
            let tokensNeeded = requestedTokens - tokens
            let waitTime = tokensNeeded / tokensPerSecond

            // Wait for tokens to accumulate (with a small minimum wait)
            let actualWait = max(0.001, min(waitTime, 1.0)) // Cap at 1 second per iteration
            try await Task.sleep(nanoseconds: UInt64(actualWait * 1_000_000_000))
        }
    }

    /// Try to acquire tokens without waiting.
    /// - Parameter tokens: Number of tokens to acquire.
    /// - Returns: `true` if tokens were acquired, `false` otherwise.
    public func tryAcquire(tokens requestedTokens: Double = 1) -> Bool {
        refill()

        if tokens >= requestedTokens {
            tokens -= requestedTokens
            return true
        }
        return false
    }

    /// Get the current number of available tokens.
    public var availableTokens: Double {
        refill()
        return tokens
    }

    /// Get the current fill ratio (0.0 to 1.0).
    public var fillRatio: Double {
        refill()
        return tokens / bucketSize
    }

    /// Reset the bucket to full.
    public func reset() {
        tokens = bucketSize
        lastRefillTime = Date()
    }

    /// Drain the bucket (set to 0 tokens).
    public func drain() {
        tokens = 0
        lastRefillTime = Date()
    }

    // MARK: - Private Methods

    private func refill() {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastRefillTime)
        let tokensToAdd = timePassed * tokensPerSecond

        tokens = min(bucketSize, tokens + tokensToAdd)
        lastRefillTime = now
    }
}

/// Errors that can occur during rate limiting.
public enum RateLimiterError: Error, Sendable, LocalizedError {
    /// Timed out waiting for tokens.
    case timeout(waited: TimeInterval, requested: Double)
    /// Requested more tokens than the bucket size.
    case exceedsBucketSize(requested: Double, bucketSize: Double)

    public var errorDescription: String? {
        switch self {
        case .timeout(let waited, let requested):
            return "Rate limiter timeout: waited \(String(format: "%.2f", waited))s for \(requested) tokens"
        case .exceedsBucketSize(let requested, let bucketSize):
            return "Requested \(requested) tokens but bucket size is only \(bucketSize)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .timeout:
            return "Try again later or reduce request frequency"
        case .exceedsBucketSize:
            return "Request fewer tokens at a time or increase bucket size"
        }
    }
}

// MARK: - Rate Limited HTTP Client

/// A wrapper around GoogleCloudHTTPClient that applies rate limiting.
///
/// ## Example Usage
/// ```swift
/// let rateLimiter = TokenBucketRateLimiter(configuration: .cloudStorage)
/// let rateLimitedClient = RateLimitedHTTPClient(
///     client: httpClient,
///     rateLimiter: rateLimiter
/// )
///
/// // All requests through this client will be rate limited
/// let response: GoogleCloudAPIResponse<Bucket> = try await rateLimitedClient.get(
///     path: "/storage/v1/b/my-bucket"
/// )
/// ```
public actor RateLimitedHTTPClient {
    private let client: GoogleCloudHTTPClient
    private let rateLimiter: TokenBucketRateLimiter

    /// Create a rate-limited HTTP client.
    /// - Parameters:
    ///   - client: The underlying HTTP client.
    ///   - rateLimiter: The rate limiter to apply.
    public init(client: GoogleCloudHTTPClient, rateLimiter: TokenBucketRateLimiter) {
        self.client = client
        self.rateLimiter = rateLimiter
    }

    /// Perform a GET request with rate limiting.
    public func get<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await rateLimiter.acquire()
        return try await client.get(path: path, queryParameters: queryParameters)
    }

    /// Perform a POST request with rate limiting.
    public func post<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await rateLimiter.acquire()
        return try await client.post(path: path, body: body, queryParameters: queryParameters)
    }

    /// Perform a POST request without a body with rate limiting.
    public func post<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await rateLimiter.acquire()
        return try await client.post(path: path, queryParameters: queryParameters)
    }

    /// Perform a PUT request with rate limiting.
    public func put<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await rateLimiter.acquire()
        return try await client.put(path: path, body: body, queryParameters: queryParameters)
    }

    /// Perform a PATCH request with rate limiting.
    public func patch<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await rateLimiter.acquire()
        return try await client.patch(path: path, body: body, queryParameters: queryParameters)
    }

    /// Perform a DELETE request with rate limiting.
    public func delete<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await rateLimiter.acquire()
        return try await client.delete(path: path, queryParameters: queryParameters)
    }

    /// Perform a DELETE request with no content with rate limiting.
    public func deleteNoContent(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws {
        try await rateLimiter.acquire()
        try await client.deleteNoContent(path: path, queryParameters: queryParameters)
    }

    /// Perform a raw GET request with rate limiting.
    public func getRaw(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> Data {
        try await rateLimiter.acquire()
        return try await client.getRaw(path: path, queryParameters: queryParameters)
    }

    /// Perform a raw POST request with rate limiting.
    public func postRaw(
        path: String,
        data: Data,
        contentType: String,
        queryParameters: [String: String]? = nil
    ) async throws -> Data {
        try await rateLimiter.acquire()
        return try await client.postRaw(path: path, data: data, contentType: contentType, queryParameters: queryParameters)
    }

    /// Get the current rate limiter stats.
    public func stats() async -> (availableTokens: Double, fillRatio: Double) {
        let available = await rateLimiter.availableTokens
        let ratio = await rateLimiter.fillRatio
        return (available, ratio)
    }
}

// MARK: - Composite Rate Limiter

/// A rate limiter that applies multiple limits (e.g., per-second and per-minute).
///
/// ## Example Usage
/// ```swift
/// let limiter = CompositeRateLimiter(limiters: [
///     TokenBucketRateLimiter(tokensPerSecond: 100, bucketSize: 100),  // Per-second limit
///     TokenBucketRateLimiter(tokensPerSecond: 1000/60, bucketSize: 1000)  // Per-minute limit
/// ])
/// ```
public actor CompositeRateLimiter: Sendable {
    private let limiters: [TokenBucketRateLimiter]

    /// Create a composite rate limiter.
    /// - Parameter limiters: The rate limiters to apply.
    public init(limiters: [TokenBucketRateLimiter]) {
        self.limiters = limiters
    }

    /// Acquire tokens from all limiters.
    /// - Parameter tokens: Number of tokens to acquire from each limiter.
    public func acquire(tokens: Double = 1) async throws {
        for limiter in limiters {
            try await limiter.acquire(tokens: tokens)
        }
    }

    /// Try to acquire tokens from all limiters without waiting.
    /// - Parameter tokens: Number of tokens to acquire.
    /// - Returns: `true` if all limiters had tokens available.
    public func tryAcquire(tokens: Double = 1) async -> Bool {
        // First check if all limiters have tokens
        for limiter in limiters {
            if await !limiter.tryAcquire(tokens: tokens) {
                return false
            }
        }
        return true
    }

    /// Reset all limiters.
    public func reset() async {
        for limiter in limiters {
            await limiter.reset()
        }
    }
}
