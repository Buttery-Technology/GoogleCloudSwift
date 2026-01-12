import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - In-Memory Cache Tests

@Test func testCacheSetAndGet() {
    let cache = InMemoryCache<String, String>(configuration: .default)

    cache.set("key1", value: "value1")
    let retrieved = cache.get("key1")

    #expect(retrieved == "value1")
}

@Test func testCacheMiss() {
    let cache = InMemoryCache<String, String>(configuration: .default)

    let retrieved = cache.get("nonexistent")

    #expect(retrieved == nil)
}

@Test func testCacheExpiration() async throws {
    let config = CacheConfiguration(
        defaultTTL: 0.1, // 100ms TTL
        maxEntries: 100
    )

    let cache = InMemoryCache<String, String>(configuration: config)

    cache.set("key1", value: "value1")

    // Should be available immediately
    #expect(cache.get("key1") == "value1")

    // Wait for expiration
    try await Task.sleep(nanoseconds: 150_000_000) // 150ms

    // Should be expired
    #expect(cache.get("key1") == nil)
}

@Test func testCacheContains() {
    let cache = InMemoryCache<String, String>(configuration: .default)

    cache.set("key1", value: "value1")

    #expect(cache.contains("key1"))
    #expect(cache.contains("key2") == false)
}

@Test func testCacheRemove() {
    let cache = InMemoryCache<String, String>(configuration: .default)

    cache.set("key1", value: "value1")
    let removed = cache.remove("key1")

    #expect(removed == "value1")
    #expect(cache.get("key1") == nil)
}

@Test func testCacheClear() {
    let cache = InMemoryCache<String, String>(configuration: .default)

    cache.set("key1", value: "value1")
    cache.set("key2", value: "value2")

    cache.clear()

    #expect(cache.count == 0)
    #expect(cache.get("key1") == nil)
    #expect(cache.get("key2") == nil)
}

@Test func testCacheGetOrFetch() async throws {
    let cache = InMemoryCache<String, Int>(configuration: .default)

    let counter = Counter()

    // First call should fetch
    let result1 = try await cache.getOrFetch("key1") {
        await counter.increment()
        return 42
    }

    // Second call should use cache
    let result2 = try await cache.getOrFetch("key1") {
        await counter.increment()
        return 99
    }

    #expect(result1 == 42)
    #expect(result2 == 42)
    #expect(await counter.value == 1)
}

/// Thread-safe counter for tests
actor Counter {
    var value = 0
    func increment() { value += 1 }
}

@Test func testCacheEvictionLRU() {
    let config = CacheConfiguration(
        defaultTTL: 3600,
        maxEntries: 3,
        evictionPolicy: .lru
    )

    let cache = InMemoryCache<String, String>(configuration: config)

    cache.set("key1", value: "value1")
    cache.set("key2", value: "value2")
    cache.set("key3", value: "value3")

    // Access key1 to make it recently used
    _ = cache.get("key1")

    // Add another entry, should evict key2 (least recently used)
    cache.set("key4", value: "value4")

    #expect(cache.get("key1") != nil)
    #expect(cache.get("key2") == nil) // Evicted
    #expect(cache.get("key3") != nil)
    #expect(cache.get("key4") != nil)
}

@Test func testCacheEvictionFIFO() {
    let config = CacheConfiguration(
        defaultTTL: 3600,
        maxEntries: 3,
        evictionPolicy: .fifo
    )

    let cache = InMemoryCache<String, String>(configuration: config)

    cache.set("key1", value: "value1")
    cache.set("key2", value: "value2")
    cache.set("key3", value: "value3")

    // Add another entry, should evict key1 (oldest)
    cache.set("key4", value: "value4")

    #expect(cache.get("key1") == nil) // Evicted
    #expect(cache.get("key2") != nil)
    #expect(cache.get("key3") != nil)
    #expect(cache.get("key4") != nil)
}

@Test func testCacheStatistics() {
    let cache = InMemoryCache<String, String>(configuration: .default)

    cache.set("key1", value: "value1")

    // Cause hits
    _ = cache.get("key1")
    _ = cache.get("key1")

    // Cause misses
    _ = cache.get("key2")
    _ = cache.get("key3")

    let stats = cache.statistics
    #expect(stats.hits == 2)
    #expect(stats.misses == 2)
    #expect(stats.entryCount == 1)
    #expect(stats.hitRate == 0.5)
}

@Test func testCacheCleanup() async throws {
    let config = CacheConfiguration(
        defaultTTL: 0.05, // 50ms TTL
        maxEntries: 100
    )

    let cache = InMemoryCache<String, String>(configuration: config)

    cache.set("key1", value: "value1")
    cache.set("key2", value: "value2")

    // Wait for expiration
    try await Task.sleep(nanoseconds: 60_000_000) // 60ms

    // Add fresh entry
    cache.set("key3", value: "value3", ttl: 3600)

    // Run cleanup
    cache.cleanup()

    // Expired entries should be gone
    #expect(cache.count == 1)
    #expect(cache.get("key3") == "value3")
}

// MARK: - Response Cache Tests

@Test func testResponseCacheSetAndGet() {
    let cache = GoogleCloudResponseCache()

    let testData = TestCacheData(name: "test", value: 42)
    cache.set(testData, forKey: .custom("test-key"))

    let retrieved: TestCacheData? = cache.get(.custom("test-key"))
    #expect(retrieved?.name == "test")
    #expect(retrieved?.value == 42)
}

@Test func testResponseCacheKeyStringValues() {
    let bucketKey = ResponseCacheKey.bucket("my-bucket")
    #expect(bucketKey.stringValue == "storage:bucket:my-bucket")

    let instanceKey = ResponseCacheKey.instance(project: "proj", zone: "us-central1-a", instance: "vm-1")
    #expect(instanceKey.stringValue == "compute:instance:proj:us-central1-a:vm-1")

    let secretKey = ResponseCacheKey.secret(project: "proj", secret: "my-secret")
    #expect(secretKey.stringValue == "secretmanager:secret:proj:my-secret")
}

@Test func testResponseCacheInvalidatePrefix() {
    let cache = GoogleCloudResponseCache()

    cache.set("bucket1", forKey: .bucket("bucket1"))
    cache.set("bucket2", forKey: .bucket("bucket2"))
    cache.set("instance1", forKey: .instance(project: "proj", zone: "zone", instance: "vm1"))

    // Invalidate all storage entries
    cache.invalidatePrefix("storage:")

    #expect(cache.get(.bucket("bucket1"), as: String.self) == nil)
    #expect(cache.get(.bucket("bucket2"), as: String.self) == nil)
    #expect(cache.get(.instance(project: "proj", zone: "zone", instance: "vm1"), as: String.self) == "instance1")
}

@Test func testResponseCacheInvalidateService() {
    let cache = GoogleCloudResponseCache()

    cache.set("bucket1", forKey: .bucket("bucket1"))
    cache.set("secret1", forKey: .secret(project: "proj", secret: "secret1"))

    cache.invalidateService("storage")

    #expect(cache.get(.bucket("bucket1"), as: String.self) == nil)
    #expect(cache.get(.secret(project: "proj", secret: "secret1"), as: String.self) == "secret1")
}

// MARK: - Cache Configuration Tests

@Test func testDefaultCacheConfiguration() {
    let config = CacheConfiguration.default

    #expect(config.defaultTTL == 300)
    #expect(config.maxEntries == 1000)
    #expect(config.evictionPolicy == .lru)
}

@Test func testShortLivedCacheConfiguration() {
    let config = CacheConfiguration.shortLived

    #expect(config.defaultTTL == 30)
    #expect(config.maxEntries == 500)
}

@Test func testLongLivedCacheConfiguration() {
    let config = CacheConfiguration.longLived

    #expect(config.defaultTTL == 3600)
    #expect(config.maxEntries == 5000)
}

// MARK: - Cache Entry Tests

@Test func testCacheEntryExpiration() {
    let entry = CacheEntry(value: "test", ttl: 10)

    #expect(!entry.isExpired)
    #expect(entry.timeToLive > 9 && entry.timeToLive <= 10)
}

@Test func testCacheEntryWithAccess() {
    let entry = CacheEntry(value: "test", ttl: 60)
    let accessed = entry.withAccess()

    #expect(accessed.accessCount == 1)
    #expect(accessed.value == "test")
}

// MARK: - Cache Statistics Tests

@Test func testCacheStatisticsHitRate() {
    let stats = CacheStatistics(
        hits: 75,
        misses: 25,
        entryCount: 100,
        evictions: 10,
        expirations: 5
    )

    #expect(stats.hitRate == 0.75)
    #expect(stats.missRate == 0.25)
}

@Test func testCacheStatisticsZeroRequests() {
    let stats = CacheStatistics(
        hits: 0,
        misses: 0,
        entryCount: 0,
        evictions: 0,
        expirations: 0
    )

    #expect(stats.hitRate == 0.0)
    #expect(stats.missRate == 1.0)
}

// MARK: - Request Coalescing Tests

@Test func testCacheGetOrFetchCoalescing() async throws {
    let config = CacheConfiguration(
        defaultTTL: 300,
        maxEntries: 100,
        coalesceFetches: true
    )
    let cache = InMemoryCache<String, Int>(configuration: config)
    let fetchCounter = Counter()

    // Launch multiple concurrent requests for the same key
    let results = try await withThrowingTaskGroup(of: Int.self) { group in
        for _ in 0..<10 {
            group.addTask {
                try await cache.getOrFetch("shared-key") {
                    // Add small delay to ensure coalescing
                    try await Task.sleep(nanoseconds: 50_000_000)
                    await fetchCounter.increment()
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

    // Only one fetch should have occurred due to coalescing
    #expect(await fetchCounter.value == 1)
}

@Test func testCacheGetOrFetchNoCoalescing() async throws {
    let config = CacheConfiguration(
        defaultTTL: 300,
        maxEntries: 100,
        coalesceFetches: false
    )
    let cache = InMemoryCache<String, Int>(configuration: config)
    let fetchCounter = Counter()

    // Without coalescing, each request fetches independently
    // But since one will complete first and cache, others should use cache
    let result1 = try await cache.getOrFetch("key1") {
        await fetchCounter.increment()
        return 42
    }

    let result2 = try await cache.getOrFetch("key1") {
        await fetchCounter.increment()
        return 99
    }

    #expect(result1 == 42)
    #expect(result2 == 42) // Uses cached value
    #expect(await fetchCounter.value == 1) // Only first fetch
}

// MARK: - Cache Observer Tests

@Test func testCacheObserverHitMiss() {
    let observer = TestCacheObserver()
    let cache = InMemoryCache<String, String>(configuration: .default, observer: observer)

    cache.set("key1", value: "value1")

    // Should emit set event
    #expect(observer.setCount == 1)

    // Hit
    _ = cache.get("key1")
    #expect(observer.hitCount == 1)

    // Miss
    _ = cache.get("nonexistent")
    #expect(observer.missCount == 1)
}

@Test func testCacheObserverEviction() {
    let config = CacheConfiguration(
        defaultTTL: 300,
        maxEntries: 2
    )
    let observer = TestCacheObserver()
    let cache = InMemoryCache<String, String>(configuration: config, observer: observer)

    cache.set("key1", value: "value1")
    cache.set("key2", value: "value2")
    cache.set("key3", value: "value3") // Should evict one

    #expect(observer.evictedCount == 1)
}

@Test func testCacheObserverRemove() {
    let observer = TestCacheObserver()
    let cache = InMemoryCache<String, String>(configuration: .default, observer: observer)

    cache.set("key1", value: "value1")
    _ = cache.remove("key1")

    #expect(observer.removedCount == 1)
}

// MARK: - Coalesce Fetches Configuration Test

@Test func testCoalesceFetchesConfiguration() {
    let config = CacheConfiguration.default
    #expect(config.coalesceFetches == true)

    let customConfig = CacheConfiguration(coalesceFetches: false)
    #expect(customConfig.coalesceFetches == false)
}

@Test func testResponseCacheGetOrFetchCoalescing() async throws {
    let config = CacheConfiguration(
        defaultTTL: 300,
        maxEntries: 100,
        coalesceFetches: true
    )
    let cache = GoogleCloudResponseCache(configuration: config)
    let fetchCounter = Counter()

    // Launch multiple concurrent requests for the same key
    let results = try await withThrowingTaskGroup(of: Int.self) { group in
        for _ in 0..<10 {
            group.addTask {
                try await cache.getOrFetch(.custom("shared-key")) {
                    try await Task.sleep(nanoseconds: 50_000_000)
                    await fetchCounter.increment()
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

    // Only one fetch should have occurred due to coalescing
    #expect(await fetchCounter.value == 1)
}

@Test func testResponseCacheObserver() {
    let observer = TestCacheObserver()
    let cache = GoogleCloudResponseCache(observer: observer)

    cache.set("value1", forKey: .custom("key1"))
    #expect(observer.setCount == 1)

    let _: String? = cache.get(.custom("key1"))
    #expect(observer.hitCount == 1)

    let _: String? = cache.get(.custom("nonexistent"))
    #expect(observer.missCount == 1)
}

// MARK: - Helper Types

struct TestCacheData: Sendable, Equatable {
    let name: String
    let value: Int
}

/// Test observer for cache events
final class TestCacheObserver: CacheEventObserver, @unchecked Sendable {
    private let lock = NSLock()
    private var _hitCount = 0
    private var _missCount = 0
    private var _setCount = 0
    private var _removedCount = 0
    private var _evictedCount = 0
    private var _expiredCount = 0

    var hitCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _hitCount
    }

    var missCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _missCount
    }

    var setCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _setCount
    }

    var removedCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _removedCount
    }

    var evictedCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _evictedCount
    }

    var expiredCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _expiredCount
    }

    func cacheDidEmitEvent<Key: Sendable>(_ event: CacheEvent<Key>) {
        lock.lock()
        defer { lock.unlock() }

        switch event {
        case .hit:
            _hitCount += 1
        case .miss:
            _missCount += 1
        case .set:
            _setCount += 1
        case .removed:
            _removedCount += 1
        case .evicted:
            _evictedCount += 1
        case .expired:
            _expiredCount += 1
        }
    }
}
