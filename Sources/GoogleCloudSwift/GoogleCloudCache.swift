//
//  GoogleCloudCache.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation

// MARK: - Cache Events

/// Events emitted by the cache for observability.
public enum CacheEvent<Key: Sendable>: Sendable {
    /// A cache hit occurred.
    case hit(key: Key)
    /// A cache miss occurred.
    case miss(key: Key)
    /// A value was stored in the cache.
    case set(key: Key)
    /// A value was removed from the cache.
    case removed(key: Key)
    /// A value was evicted due to capacity limits.
    case evicted(key: Key)
    /// A value expired and was removed.
    case expired(key: Key)
}

/// Protocol for receiving cache events.
///
/// Implement this protocol to monitor cache behavior for debugging,
/// metrics collection, or logging purposes.
///
/// ## Example Usage
/// ```swift
/// class MyCacheObserver: CacheEventObserver {
///     func cacheDidEmitEvent<Key>(_ event: CacheEvent<Key>) {
///         switch event {
///         case .hit(let key):
///             metrics.increment("cache.hit")
///         case .miss(let key):
///             metrics.increment("cache.miss")
///         default:
///             break
///         }
///     }
/// }
/// ```
public protocol CacheEventObserver: AnyObject, Sendable {
    /// Called when a cache event occurs.
    /// - Parameter event: The cache event that occurred.
    func cacheDidEmitEvent<Key: Sendable>(_ event: CacheEvent<Key>)
}

// MARK: - Cache Errors

/// Errors that can occur with caching.
public enum CacheError: Error, Sendable, LocalizedError {
    /// The requested item was not found in cache.
    case notFound(key: String)
    /// The cached item has expired.
    case expired(key: String)
    /// Failed to serialize the value.
    case serializationFailed(String)
    /// Failed to deserialize the value.
    case deserializationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notFound(let key):
            return "Cache miss: no entry found for key '\(key)'"
        case .expired(let key):
            return "Cache entry for '\(key)' has expired"
        case .serializationFailed(let message):
            return "Failed to serialize value: \(message)"
        case .deserializationFailed(let message):
            return "Failed to deserialize value: \(message)"
        }
    }
}

// MARK: - Cache Entry

/// A cached item with metadata.
public struct CacheEntry<T: Sendable>: Sendable {
    /// The cached value.
    public let value: T

    /// When the entry was created.
    public let createdAt: Date

    /// When the entry expires.
    public let expiresAt: Date

    /// Number of times this entry has been accessed.
    public let accessCount: Int

    /// Last time this entry was accessed.
    public let lastAccessedAt: Date

    /// Whether the entry has expired.
    public var isExpired: Bool {
        Date() >= expiresAt
    }

    /// Time remaining until expiration.
    public var timeToLive: TimeInterval {
        max(0, expiresAt.timeIntervalSince(Date()))
    }

    init(value: T, ttl: TimeInterval, accessCount: Int = 0) {
        self.value = value
        self.createdAt = Date()
        self.expiresAt = Date().addingTimeInterval(ttl)
        self.accessCount = accessCount
        self.lastAccessedAt = Date()
    }

    func withAccess() -> CacheEntry<T> {
        CacheEntry(
            value: value,
            createdAt: createdAt,
            expiresAt: expiresAt,
            accessCount: accessCount + 1,
            lastAccessedAt: Date()
        )
    }

    private init(value: T, createdAt: Date, expiresAt: Date, accessCount: Int, lastAccessedAt: Date) {
        self.value = value
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.accessCount = accessCount
        self.lastAccessedAt = lastAccessedAt
    }
}

// MARK: - Cache Configuration

/// Configuration for cache behavior.
public struct CacheConfiguration: Sendable {
    /// Default time-to-live for cache entries in seconds.
    public let defaultTTL: TimeInterval

    /// Maximum number of entries in the cache.
    public let maxEntries: Int

    /// Eviction policy when cache is full.
    public let evictionPolicy: CacheEvictionPolicy

    /// Whether to automatically clean up expired entries.
    public let autoCleanup: Bool

    /// Interval for automatic cleanup in seconds.
    public let cleanupInterval: TimeInterval

    /// Whether to coalesce concurrent fetch requests for the same key.
    public let coalesceFetches: Bool

    /// Default configuration.
    public static let `default` = CacheConfiguration(
        defaultTTL: 300, // 5 minutes
        maxEntries: 1000,
        evictionPolicy: .lru,
        autoCleanup: true,
        cleanupInterval: 60,
        coalesceFetches: true
    )

    /// Short-lived cache for frequently changing data.
    public static let shortLived = CacheConfiguration(
        defaultTTL: 30,
        maxEntries: 500,
        evictionPolicy: .lru,
        autoCleanup: true,
        cleanupInterval: 15,
        coalesceFetches: true
    )

    /// Long-lived cache for stable data.
    public static let longLived = CacheConfiguration(
        defaultTTL: 3600, // 1 hour
        maxEntries: 5000,
        evictionPolicy: .lru,
        autoCleanup: true,
        cleanupInterval: 300,
        coalesceFetches: true
    )

    /// Cache for rarely changing configuration data.
    public static let configuration = CacheConfiguration(
        defaultTTL: 86400, // 24 hours
        maxEntries: 100,
        evictionPolicy: .lru,
        autoCleanup: true,
        cleanupInterval: 3600,
        coalesceFetches: true
    )

    public init(
        defaultTTL: TimeInterval = 300,
        maxEntries: Int = 1000,
        evictionPolicy: CacheEvictionPolicy = .lru,
        autoCleanup: Bool = true,
        cleanupInterval: TimeInterval = 60,
        coalesceFetches: Bool = true
    ) {
        self.defaultTTL = defaultTTL
        self.maxEntries = maxEntries
        self.evictionPolicy = evictionPolicy
        self.autoCleanup = autoCleanup
        self.cleanupInterval = cleanupInterval
        self.coalesceFetches = coalesceFetches
    }
}

/// Cache eviction policy.
public enum CacheEvictionPolicy: String, Sendable {
    /// Least Recently Used - evict the entry that hasn't been accessed for the longest time.
    case lru
    /// Least Frequently Used - evict the entry with the fewest accesses.
    case lfu
    /// First In First Out - evict the oldest entry.
    case fifo
    /// Time To Live - evict entries closest to expiration.
    case ttl
}

// MARK: - Cache Statistics

/// Statistics about cache performance.
public struct CacheStatistics: Sendable {
    /// Total number of cache hits.
    public let hits: Int

    /// Total number of cache misses.
    public let misses: Int

    /// Total number of entries currently in cache.
    public let entryCount: Int

    /// Number of entries evicted.
    public let evictions: Int

    /// Number of entries that expired.
    public let expirations: Int

    /// Hit rate (0.0 to 1.0).
    public var hitRate: Double {
        let total = hits + misses
        return total > 0 ? Double(hits) / Double(total) : 0.0
    }

    /// Miss rate (0.0 to 1.0).
    public var missRate: Double {
        1.0 - hitRate
    }
}

// MARK: - In-Memory Cache

/// A thread-safe in-memory cache with TTL support.
///
/// ## Example Usage
/// ```swift
/// let cache = InMemoryCache<String, BucketMetadata>(configuration: .default)
///
/// // Store a value
/// cache.set("my-bucket", value: metadata)
///
/// // Retrieve a value
/// if let metadata = cache.get("my-bucket") {
///     print("Found: \(metadata)")
/// }
///
/// // Use get-or-fetch pattern (with automatic request coalescing)
/// let data = try await cache.getOrFetch("my-bucket") {
///     try await storageAPI.getBucket("my-bucket")
/// }
///
/// // Add an observer for metrics
/// cache.observer = myMetricsObserver
/// ```
public final class InMemoryCache<Key: Hashable & Sendable, Value: Sendable>: @unchecked Sendable {
    private var entries: [Key: CacheEntry<Value>] = [:]
    private let configuration: CacheConfiguration
    private var hits: Int = 0
    private var misses: Int = 0
    private var evictions: Int = 0
    private var expirations: Int = 0
    private var cleanupTask: Task<Void, Never>?
    private let lock = NSLock()

    /// In-flight fetch tasks for request coalescing.
    private var inFlightFetches: [Key: Task<Value, Error>] = [:]
    private let fetchLock = NSLock()

    /// Optional observer for cache events.
    /// Set this to receive notifications about cache hits, misses, evictions, etc.
    public weak var observer: CacheEventObserver?

    /// Create an in-memory cache.
    /// - Parameters:
    ///   - configuration: Cache configuration.
    ///   - observer: Optional observer for cache events.
    public init(configuration: CacheConfiguration = .default, observer: CacheEventObserver? = nil) {
        self.configuration = configuration
        self.observer = observer
        if configuration.autoCleanup {
            startAutoCleanup()
        }
    }

    deinit {
        cleanupTask?.cancel()
    }

    /// Start automatic cleanup.
    /// Called automatically during init if `autoCleanup` is enabled in configuration.
    /// Can also be called manually to start cleanup on a cache created with `autoCleanup: false`.
    public func startAutoCleanup() {
        lock.lock()
        defer { lock.unlock() }

        guard cleanupTask == nil else { return }

        cleanupTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(self?.configuration.cleanupInterval ?? 60) * 1_000_000_000)
                self?.cleanup()
            }
        }
    }

    /// Stop automatic cleanup.
    public func stopAutoCleanup() {
        lock.lock()
        defer { lock.unlock() }
        cleanupTask?.cancel()
        cleanupTask = nil
    }

    /// Get a value from the cache.
    /// - Parameter key: The cache key.
    /// - Returns: The cached value, or nil if not found or expired.
    public func get(_ key: Key) -> Value? {
        var events: [CacheEvent<Key>] = []
        let result: Value?

        lock.lock()
        if let entry = entries[key] {
            if entry.isExpired {
                entries.removeValue(forKey: key)
                expirations += 1
                misses += 1
                events.append(.expired(key: key))
                events.append(.miss(key: key))
                result = nil
            } else {
                entries[key] = entry.withAccess()
                hits += 1
                events.append(.hit(key: key))
                result = entry.value
            }
        } else {
            misses += 1
            events.append(.miss(key: key))
            result = nil
        }
        lock.unlock()

        // Emit events outside the lock to prevent deadlocks
        for event in events {
            emitEvent(event)
        }

        return result
    }

    /// Get a value or fetch it if not cached.
    ///
    /// When `coalesceFetches` is enabled in configuration (default), concurrent requests
    /// for the same key will share a single fetch operation, preventing thundering herd
    /// problems when multiple requests hit an empty or expired cache entry simultaneously.
    ///
    /// - Parameters:
    ///   - key: The cache key.
    ///   - ttl: Optional TTL override for this entry.
    ///   - fetch: Async closure to fetch the value if not cached.
    /// - Returns: The cached or fetched value.
    public func getOrFetch(
        _ key: Key,
        ttl: TimeInterval? = nil,
        fetch: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        // Check cache first
        if let cached = get(key) {
            return cached
        }

        // If coalescing is disabled, just fetch directly
        guard configuration.coalesceFetches else {
            let value = try await fetch()
            set(key, value: value, ttl: ttl)
            return value
        }

        // Atomically check for existing task or create new one
        let (task, isNewTask) = getOrCreateInFlightFetch(for: key, fetch: fetch)

        if !isNewTask {
            // Wait for existing fetch to complete
            return try await task.value
        }

        // We created a new task, so we're responsible for cleanup
        do {
            let value = try await task.value

            // Store in cache
            set(key, value: value, ttl: ttl)

            // Remove from in-flight
            removeInFlightFetch(for: key)

            return value
        } catch {
            // Remove from in-flight on error
            removeInFlightFetch(for: key)

            throw error
        }
    }

    // MARK: - In-Flight Fetch Management (synchronous helpers)

    /// Atomically get an existing in-flight fetch or create a new one.
    /// Returns the task and a boolean indicating if it was newly created.
    private func getOrCreateInFlightFetch(
        for key: Key,
        fetch: @escaping @Sendable () async throws -> Value
    ) -> (Task<Value, Error>, Bool) {
        fetchLock.lock()
        defer { fetchLock.unlock() }

        if let existingTask = inFlightFetches[key] {
            return (existingTask, false)
        }

        let task = Task<Value, Error> {
            try await fetch()
        }
        inFlightFetches[key] = task
        return (task, true)
    }

    private func removeInFlightFetch(for key: Key) {
        fetchLock.lock()
        defer { fetchLock.unlock() }
        inFlightFetches.removeValue(forKey: key)
    }

    /// Store a value in the cache.
    /// - Parameters:
    ///   - key: The cache key.
    ///   - value: The value to cache.
    ///   - ttl: Optional TTL override (uses default if not provided).
    public func set(_ key: Key, value: Value, ttl: TimeInterval? = nil) {
        var evictedKeys: [Key] = []

        lock.lock()
        // Evict if necessary
        while entries.count >= configuration.maxEntries {
            if let evictedKey = evictOneReturningKey() {
                evictedKeys.append(evictedKey)
            }
        }

        let entry = CacheEntry(value: value, ttl: ttl ?? configuration.defaultTTL)
        entries[key] = entry
        lock.unlock()

        // Emit events outside the lock
        for evictedKey in evictedKeys {
            emitEvent(.evicted(key: evictedKey))
        }
        emitEvent(.set(key: key))
    }

    /// Remove a value from the cache.
    /// - Parameter key: The cache key.
    /// - Returns: The removed value, or nil if not found.
    @discardableResult
    public func remove(_ key: Key) -> Value? {
        lock.lock()
        let entry = entries.removeValue(forKey: key)
        lock.unlock()

        if entry != nil {
            emitEvent(.removed(key: key))
        }
        return entry?.value
    }

    /// Check if a key exists in the cache (and is not expired).
    /// - Parameter key: The cache key.
    /// - Returns: `true` if the key exists and is not expired.
    public func contains(_ key: Key) -> Bool {
        var expiredKey: Key?

        lock.lock()
        let result: Bool
        if let entry = entries[key] {
            if entry.isExpired {
                entries.removeValue(forKey: key)
                expirations += 1
                expiredKey = key
                result = false
            } else {
                result = true
            }
        } else {
            result = false
        }
        lock.unlock()

        if let key = expiredKey {
            emitEvent(.expired(key: key))
        }
        return result
    }

    /// Clear all entries from the cache.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        entries.removeAll()
    }

    /// Remove all expired entries.
    public func cleanup() {
        lock.lock()
        let expiredKeys = entries.filter { $0.value.isExpired }.map { $0.key }
        for key in expiredKeys {
            entries.removeValue(forKey: key)
            expirations += 1
        }
        lock.unlock()

        // Emit events outside the lock
        for key in expiredKeys {
            emitEvent(.expired(key: key))
        }
    }

    /// Get cache statistics.
    public var statistics: CacheStatistics {
        lock.lock()
        defer { lock.unlock() }
        return CacheStatistics(
            hits: hits,
            misses: misses,
            entryCount: entries.count,
            evictions: evictions,
            expirations: expirations
        )
    }

    /// Get all keys in the cache.
    public var keys: [Key] {
        lock.lock()
        defer { lock.unlock() }
        return Array(entries.keys)
    }

    /// Get the number of entries in the cache.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return entries.count
    }

    // MARK: - Private Methods

    /// Evicts one entry and returns the evicted key (if any).
    /// Must be called while holding the lock.
    private func evictOneReturningKey() -> Key? {
        guard !entries.isEmpty else { return nil }

        let keyToEvict: Key?

        switch configuration.evictionPolicy {
        case .lru:
            keyToEvict = entries.min { $0.value.lastAccessedAt < $1.value.lastAccessedAt }?.key

        case .lfu:
            keyToEvict = entries.min { $0.value.accessCount < $1.value.accessCount }?.key

        case .fifo:
            keyToEvict = entries.min { $0.value.createdAt < $1.value.createdAt }?.key

        case .ttl:
            keyToEvict = entries.min { $0.value.expiresAt < $1.value.expiresAt }?.key
        }

        if let key = keyToEvict {
            entries.removeValue(forKey: key)
            evictions += 1
            return key
        }
        return nil
    }

    // MARK: - Private Helpers

    private func emitEvent(_ event: CacheEvent<Key>) {
        observer?.cacheDidEmitEvent(event)
    }
}

// MARK: - Response Cache

/// A specialized cache for Google Cloud API responses.
///
/// ## Example Usage
/// ```swift
/// let cache = GoogleCloudResponseCache()
///
/// // Cache a bucket response
/// await cache.set(bucket, forKey: .bucket("my-bucket"))
///
/// // Get cached bucket
/// let bucket: Bucket? = await cache.get(.bucket("my-bucket"))
///
/// // Invalidate related entries
/// await cache.invalidatePrefix("bucket:")
/// ```
public final class GoogleCloudResponseCache: @unchecked Sendable {
    private var cache: InMemoryCache<String, AnyCacheable>
    private let configuration: CacheConfiguration

    /// In-flight fetch tasks for request coalescing (keyed by ResponseCacheKey.stringValue).
    private var inFlightFetches: [String: Any] = [:]
    private let fetchLock = NSLock()

    /// Optional observer for cache events.
    /// Events will be forwarded from the underlying cache.
    public var observer: CacheEventObserver? {
        get { cache.observer }
        set { cache.observer = newValue }
    }

    /// Create a response cache.
    /// - Parameters:
    ///   - configuration: Cache configuration.
    ///   - observer: Optional observer for cache events.
    public init(configuration: CacheConfiguration = .default, observer: CacheEventObserver? = nil) {
        self.configuration = configuration
        self.cache = InMemoryCache(configuration: configuration, observer: observer)
    }

    /// Get a cached response.
    /// - Parameters:
    ///   - key: The cache key.
    ///   - type: The expected type of the cached value.
    /// - Returns: The cached value, or nil if not found.
    public func get<T: Sendable>(_ key: ResponseCacheKey, as type: T.Type = T.self) -> T? {
        guard let cached = cache.get(key.stringValue) else { return nil }
        return cached.value as? T
    }

    /// Cache a response.
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The cache key.
    ///   - ttl: Optional TTL override.
    public func set<T: Sendable>(_ value: T, forKey key: ResponseCacheKey, ttl: TimeInterval? = nil) {
        cache.set(key.stringValue, value: AnyCacheable(value), ttl: ttl)
    }

    /// Get a response or fetch it if not cached.
    ///
    /// When `coalesceFetches` is enabled in configuration (default), concurrent requests
    /// for the same key will share a single fetch operation.
    ///
    /// - Parameters:
    ///   - key: The cache key.
    ///   - ttl: Optional TTL override.
    ///   - fetch: Async closure to fetch the value.
    /// - Returns: The cached or fetched value.
    public func getOrFetch<T: Sendable>(
        _ key: ResponseCacheKey,
        ttl: TimeInterval? = nil,
        fetch: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        // Check cache first
        if let cached: T = get(key) {
            return cached
        }

        // If coalescing is disabled, just fetch directly
        guard configuration.coalesceFetches else {
            let value = try await fetch()
            set(value, forKey: key, ttl: ttl)
            return value
        }

        let keyString = key.stringValue

        // Atomically check for existing task or create new one
        let (task, isNewTask) = getOrCreateInFlightFetch(for: keyString, fetch: fetch)

        if !isNewTask {
            // Wait for existing fetch to complete
            return try await task.value
        }

        // We created a new task, so we're responsible for cleanup
        do {
            let value = try await task.value
            set(value, forKey: key, ttl: ttl)
            removeInFlightFetch(for: keyString)
            return value
        } catch {
            removeInFlightFetch(for: keyString)
            throw error
        }
    }

    // MARK: - In-Flight Fetch Management

    private func getOrCreateInFlightFetch<T: Sendable>(
        for key: String,
        fetch: @escaping @Sendable () async throws -> T
    ) -> (Task<T, Error>, Bool) {
        fetchLock.lock()
        defer { fetchLock.unlock() }

        if let existingTask = inFlightFetches[key] as? Task<T, Error> {
            return (existingTask, false)
        }

        let task = Task<T, Error> {
            try await fetch()
        }
        inFlightFetches[key] = task
        return (task, true)
    }

    private func removeInFlightFetch(for key: String) {
        fetchLock.lock()
        defer { fetchLock.unlock() }
        inFlightFetches.removeValue(forKey: key)
    }

    /// Remove a cached response.
    /// - Parameter key: The cache key.
    public func remove(_ key: ResponseCacheKey) {
        cache.remove(key.stringValue)
    }

    /// Invalidate all entries matching a key prefix.
    /// - Parameter prefix: The key prefix to match.
    public func invalidatePrefix(_ prefix: String) {
        let keysToRemove = cache.keys.filter { $0.hasPrefix(prefix) }
        for key in keysToRemove {
            cache.remove(key)
        }
    }

    /// Invalidate all entries for a specific service.
    /// - Parameter service: The service name.
    public func invalidateService(_ service: String) {
        invalidatePrefix("\(service):")
    }

    /// Clear the entire cache.
    public func clear() {
        cache.clear()
    }

    /// Get cache statistics.
    public var statistics: CacheStatistics {
        cache.statistics
    }
}

/// Type-erased wrapper for cacheable values.
struct AnyCacheable: @unchecked Sendable {
    let value: Any

    init<T: Sendable>(_ value: T) {
        self.value = value
    }
}

/// Keys for the response cache.
public enum ResponseCacheKey: Sendable, Hashable {
    // Storage
    case bucket(String)
    case bucketList(projectId: String)
    case object(bucket: String, object: String)
    case objectList(bucket: String, prefix: String?)

    // Compute
    case instance(project: String, zone: String, instance: String)
    case instanceList(project: String, zone: String)
    case machineTypeList(project: String, zone: String)
    case zone(project: String, zone: String)
    case zoneList(project: String)

    // IAM
    case serviceAccount(project: String, email: String)
    case serviceAccountList(project: String)
    case role(name: String)
    case roleList(parent: String)
    case iamPolicy(resource: String)

    // Secret Manager
    case secret(project: String, secret: String)
    case secretList(project: String)
    case secretVersion(project: String, secret: String, version: String)

    // Cloud Run
    case service(project: String, location: String, service: String)
    case serviceList(project: String, location: String)
    case revision(project: String, location: String, service: String, revision: String)

    // Logging
    case logSink(project: String, sink: String)
    case logSinkList(project: String)
    case logMetric(project: String, metric: String)

    // Custom
    case custom(String)

    /// String representation of the key.
    var stringValue: String {
        switch self {
        case .bucket(let name):
            return "storage:bucket:\(name)"
        case .bucketList(let projectId):
            return "storage:bucketList:\(projectId)"
        case .object(let bucket, let object):
            return "storage:object:\(bucket):\(object)"
        case .objectList(let bucket, let prefix):
            return "storage:objectList:\(bucket):\(prefix ?? "")"

        case .instance(let project, let zone, let instance):
            return "compute:instance:\(project):\(zone):\(instance)"
        case .instanceList(let project, let zone):
            return "compute:instanceList:\(project):\(zone)"
        case .machineTypeList(let project, let zone):
            return "compute:machineTypes:\(project):\(zone)"
        case .zone(let project, let zone):
            return "compute:zone:\(project):\(zone)"
        case .zoneList(let project):
            return "compute:zoneList:\(project)"

        case .serviceAccount(let project, let email):
            return "iam:serviceAccount:\(project):\(email)"
        case .serviceAccountList(let project):
            return "iam:serviceAccountList:\(project)"
        case .role(let name):
            return "iam:role:\(name)"
        case .roleList(let parent):
            return "iam:roleList:\(parent)"
        case .iamPolicy(let resource):
            return "iam:policy:\(resource)"

        case .secret(let project, let secret):
            return "secretmanager:secret:\(project):\(secret)"
        case .secretList(let project):
            return "secretmanager:secretList:\(project)"
        case .secretVersion(let project, let secret, let version):
            return "secretmanager:version:\(project):\(secret):\(version)"

        case .service(let project, let location, let service):
            return "run:service:\(project):\(location):\(service)"
        case .serviceList(let project, let location):
            return "run:serviceList:\(project):\(location)"
        case .revision(let project, let location, let service, let revision):
            return "run:revision:\(project):\(location):\(service):\(revision)"

        case .logSink(let project, let sink):
            return "logging:sink:\(project):\(sink)"
        case .logSinkList(let project):
            return "logging:sinkList:\(project)"
        case .logMetric(let project, let metric):
            return "logging:metric:\(project):\(metric)"

        case .custom(let key):
            return key
        }
    }
}

// MARK: - Cached HTTP Client

/// An HTTP client wrapper that caches responses.
///
/// ## Example Usage
/// ```swift
/// let client = CachedHTTPClient(
///     client: httpClient,
///     cache: cache,
///     defaultTTL: 300
/// )
///
/// // First call fetches from API
/// let bucket1: Bucket = try await client.get(
///     path: "/storage/v1/b/my-bucket",
///     cacheKey: .bucket("my-bucket")
/// )
///
/// // Second call returns cached response
/// let bucket2: Bucket = try await client.get(
///     path: "/storage/v1/b/my-bucket",
///     cacheKey: .bucket("my-bucket")
/// )
/// ```
public actor CachedHTTPClient: Sendable {
    private let client: GoogleCloudHTTPClient
    private let cache: GoogleCloudResponseCache
    private let defaultTTL: TimeInterval

    /// Create a cached HTTP client.
    /// - Parameters:
    ///   - client: The underlying HTTP client.
    ///   - cache: The response cache.
    ///   - defaultTTL: Default TTL for cached responses.
    public init(
        client: GoogleCloudHTTPClient,
        cache: GoogleCloudResponseCache,
        defaultTTL: TimeInterval = 300
    ) {
        self.client = client
        self.cache = cache
        self.defaultTTL = defaultTTL
    }

    /// Perform a GET request with caching.
    /// - Parameters:
    ///   - path: The API path.
    ///   - queryParameters: Optional query parameters.
    ///   - cacheKey: The cache key for this request.
    ///   - ttl: Optional TTL override.
    /// - Returns: The response (from cache or API).
    public func get<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil,
        cacheKey: ResponseCacheKey,
        ttl: TimeInterval? = nil
    ) async throws -> T {
        try await cache.getOrFetch(cacheKey, ttl: ttl ?? defaultTTL) {
            let response: GoogleCloudAPIResponse<T> = try await self.client.get(
                path: path,
                queryParameters: queryParameters
            )
            return response.data
        }
    }

    /// Perform a POST request (bypasses cache, invalidates related entries).
    /// - Parameters:
    ///   - path: The API path.
    ///   - body: The request body.
    ///   - queryParameters: Optional query parameters.
    ///   - invalidateKeys: Cache keys to invalidate after the request.
    /// - Returns: The API response.
    public func post<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil,
        invalidateKeys: [ResponseCacheKey] = []
    ) async throws -> GoogleCloudAPIResponse<T> {
        let response: GoogleCloudAPIResponse<T> = try await client.post(
            path: path,
            body: body,
            queryParameters: queryParameters
        )

        // Invalidate related cache entries
        for key in invalidateKeys {
            cache.remove(key)
        }

        return response
    }

    /// Perform a PUT request (bypasses cache, invalidates related entries).
    public func put<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil,
        invalidateKeys: [ResponseCacheKey] = []
    ) async throws -> GoogleCloudAPIResponse<T> {
        let response: GoogleCloudAPIResponse<T> = try await client.put(
            path: path,
            body: body,
            queryParameters: queryParameters
        )

        for key in invalidateKeys {
            cache.remove(key)
        }

        return response
    }

    /// Perform a PATCH request (bypasses cache, invalidates related entries).
    public func patch<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil,
        invalidateKeys: [ResponseCacheKey] = []
    ) async throws -> GoogleCloudAPIResponse<T> {
        let response: GoogleCloudAPIResponse<T> = try await client.patch(
            path: path,
            body: body,
            queryParameters: queryParameters
        )

        for key in invalidateKeys {
            cache.remove(key)
        }

        return response
    }

    /// Perform a DELETE request (bypasses cache, invalidates related entries).
    public func delete<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil,
        invalidateKeys: [ResponseCacheKey] = []
    ) async throws -> GoogleCloudAPIResponse<T> {
        let response: GoogleCloudAPIResponse<T> = try await client.delete(
            path: path,
            queryParameters: queryParameters
        )

        for key in invalidateKeys {
            cache.remove(key)
        }

        return response
    }

    /// Perform a DELETE request with no content (bypasses cache, invalidates related entries).
    public func deleteNoContent(
        path: String,
        queryParameters: [String: String]? = nil,
        invalidateKeys: [ResponseCacheKey] = []
    ) async throws {
        try await client.deleteNoContent(path: path, queryParameters: queryParameters)

        for key in invalidateKeys {
            cache.remove(key)
        }
    }

    /// Get cache statistics.
    public func statistics() -> CacheStatistics {
        cache.statistics
    }

    /// Clear the cache.
    public func clearCache() {
        cache.clear()
    }

    /// Invalidate specific cache entries.
    public func invalidate(_ keys: [ResponseCacheKey]) {
        for key in keys {
            cache.remove(key)
        }
    }

    /// Invalidate entries by prefix.
    public func invalidatePrefix(_ prefix: String) {
        cache.invalidatePrefix(prefix)
    }
}
