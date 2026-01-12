import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Token Bucket Rate Limiter Tests

@Test func testTokenBucketInitialization() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 50,
        initialTokens: 25
    )

    let available = await limiter.availableTokens
    #expect(available >= 25) // May have accumulated more by now
}

@Test func testTokenBucketInitialFull() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100
    )

    let available = await limiter.availableTokens
    #expect(available == 100)
}

@Test func testTryAcquireSuccess() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100
    )

    let success = await limiter.tryAcquire(tokens: 1)
    #expect(success)

    let remaining = await limiter.availableTokens
    // Use approximate comparison to account for token refill during execution
    #expect(remaining >= 98.9 && remaining <= 100)
}

@Test func testTryAcquireMultiple() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100
    )

    let success = await limiter.tryAcquire(tokens: 50)
    #expect(success)

    let remaining = await limiter.availableTokens
    // Use approximate comparison to account for token refill during execution
    #expect(remaining >= 49.9 && remaining <= 51)
}

@Test func testTryAcquireFailsWhenEmpty() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 10,
        initialTokens: 5
    )

    // Try to acquire more than available
    let success = await limiter.tryAcquire(tokens: 10)
    #expect(!success)
}

@Test func testAcquireWaitsForTokens() async throws {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100,
        initialTokens: 0 // Start empty
    )

    let startTime = Date()

    // This should wait for tokens to accumulate
    try await limiter.acquire(tokens: 10)

    let elapsed = Date().timeIntervalSince(startTime)

    // Should have waited at least ~100ms for 10 tokens at 100/sec
    #expect(elapsed >= 0.05) // Allow some tolerance
}

@Test func testAcquireExceedsBucketSize() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 50
    )

    do {
        try await limiter.acquire(tokens: 100) // More than bucket size
        #expect(Bool(false), "Should have thrown")
    } catch let error as RateLimiterError {
        if case .exceedsBucketSize(let requested, let size) = error {
            #expect(requested == 100)
            #expect(size == 50)
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testAcquireTimeout() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 1, // Very slow
        bucketSize: 100,
        initialTokens: 0,
        maxWaitTime: 0.1 // 100ms timeout
    )

    do {
        try await limiter.acquire(tokens: 50) // Would need 50 seconds
        #expect(Bool(false), "Should have timed out")
    } catch let error as RateLimiterError {
        if case .timeout = error {
            // Expected
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testReset() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100
    )

    // Drain some tokens
    _ = await limiter.tryAcquire(tokens: 80)
    let beforeReset = await limiter.availableTokens
    // Use approximate comparison to account for token refill during execution
    #expect(beforeReset >= 19.9 && beforeReset <= 21)

    // Reset to full
    await limiter.reset()
    let afterReset = await limiter.availableTokens
    #expect(afterReset == 100)
}

@Test func testDrain() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100
    )

    await limiter.drain()
    let available = await limiter.availableTokens
    // Use approximate comparison - tokens may have refilled slightly
    #expect(available < 0.01)
}

@Test func testFillRatio() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 100,
        bucketSize: 100
    )

    let fullRatio = await limiter.fillRatio
    #expect(fullRatio == 1.0)

    _ = await limiter.tryAcquire(tokens: 50)
    let halfRatio = await limiter.fillRatio
    #expect(halfRatio == 0.5)
}

@Test func testTokenRefill() async throws {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 1000, // Fast refill
        bucketSize: 100,
        initialTokens: 0
    )

    // Wait a bit for tokens to accumulate
    try await Task.sleep(nanoseconds: 100_000_000) // 100ms

    let available = await limiter.availableTokens
    // Should have accumulated ~100 tokens in 100ms at 1000/sec
    #expect(available >= 50) // Allow some tolerance
}

// MARK: - Configuration Tests

@Test func testDefaultConfiguration() {
    let config = TokenBucketRateLimiter.Configuration.default

    #expect(config.tokensPerSecond == 100)
    #expect(config.bucketSize == 100)
}

@Test func testConservativeConfiguration() {
    let config = TokenBucketRateLimiter.Configuration.conservative

    #expect(config.tokensPerSecond == 10)
    #expect(config.bucketSize == 20)
}

@Test func testComputeEngineConfiguration() {
    let config = TokenBucketRateLimiter.Configuration.computeEngine

    #expect(config.tokensPerSecond == 15)
    #expect(config.bucketSize == 30)
}

@Test func testConfigurationInitFromConfig() async {
    let config = TokenBucketRateLimiter.Configuration(
        tokensPerSecond: 50,
        bucketSize: 200,
        initialTokens: 100
    )

    let limiter = TokenBucketRateLimiter(configuration: config)
    let available = await limiter.availableTokens

    // Use approximate comparison to account for token refill during execution
    #expect(available >= 100 && available <= 101)
}

// MARK: - Rate Limiter Error Tests

@Test func testTimeoutErrorDescription() {
    let error = RateLimiterError.timeout(waited: 5.5, requested: 10)

    #expect(error.errorDescription?.contains("5.50") == true)
    #expect(error.errorDescription?.contains("10") == true)
    #expect(error.recoverySuggestion?.contains("Try again") == true)
}

@Test func testExceedsBucketSizeErrorDescription() {
    let error = RateLimiterError.exceedsBucketSize(requested: 100, bucketSize: 50)

    #expect(error.errorDescription?.contains("100") == true)
    #expect(error.errorDescription?.contains("50") == true)
    #expect(error.recoverySuggestion?.contains("fewer") == true)
}

// MARK: - Composite Rate Limiter Tests

@Test func testCompositeRateLimiterAcquire() async throws {
    let limiter1 = TokenBucketRateLimiter(tokensPerSecond: 100, bucketSize: 100)
    let limiter2 = TokenBucketRateLimiter(tokensPerSecond: 50, bucketSize: 50)

    let composite = CompositeRateLimiter(limiters: [limiter1, limiter2])

    try await composite.acquire(tokens: 10)

    // Both limiters should have consumed tokens
    // Use approximate comparison to account for token refill during execution
    let available1 = await limiter1.availableTokens
    let available2 = await limiter2.availableTokens

    #expect(available1 >= 89.9 && available1 <= 91)
    #expect(available2 >= 39.9 && available2 <= 41)
}

@Test func testCompositeRateLimiterTryAcquire() async {
    let limiter1 = TokenBucketRateLimiter(tokensPerSecond: 100, bucketSize: 100)
    let limiter2 = TokenBucketRateLimiter(tokensPerSecond: 100, bucketSize: 10)

    let composite = CompositeRateLimiter(limiters: [limiter1, limiter2])

    // Should succeed (both have enough)
    let success1 = await composite.tryAcquire(tokens: 5)
    #expect(success1)

    // Should fail (limiter2 doesn't have enough after first acquire)
    let success2 = await composite.tryAcquire(tokens: 10)
    #expect(!success2)
}

@Test func testCompositeRateLimiterReset() async {
    let limiter1 = TokenBucketRateLimiter(tokensPerSecond: 100, bucketSize: 100, initialTokens: 50)
    let limiter2 = TokenBucketRateLimiter(tokensPerSecond: 100, bucketSize: 100, initialTokens: 25)

    let composite = CompositeRateLimiter(limiters: [limiter1, limiter2])

    await composite.reset()

    let available1 = await limiter1.availableTokens
    let available2 = await limiter2.availableTokens

    #expect(available1 == 100)
    #expect(available2 == 100)
}

// MARK: - Concurrent Access Tests

@Test func testConcurrentTryAcquire() async {
    let limiter = TokenBucketRateLimiter(
        tokensPerSecond: 1000,
        bucketSize: 100
    )

    // Launch multiple concurrent tasks trying to acquire tokens
    await withTaskGroup(of: Bool.self) { group in
        for _ in 0..<50 {
            group.addTask {
                await limiter.tryAcquire(tokens: 1)
            }
        }

        var successCount = 0
        for await success in group {
            if success {
                successCount += 1
            }
        }

        // All 50 should succeed since we started with 100 tokens
        #expect(successCount == 50)
    }

    // Should have ~50 tokens remaining (accounting for high refill rate of 1000/sec)
    let remaining = await limiter.availableTokens
    #expect(remaining >= 45 && remaining <= 100) // Allow more variance due to fast refill rate
}
