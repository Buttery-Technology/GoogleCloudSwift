import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Circuit Breaker Tests

@Test func testCircuitBreakerInitialState() async {
    let breaker = CircuitBreaker(name: "test-service")
    let state = await breaker.state
    #expect(state == .closed)
}

@Test func testCircuitBreakerSuccessfulExecution() async throws {
    let breaker = CircuitBreaker(name: "test-service")

    let result = try await breaker.execute {
        return 42
    }

    #expect(result == 42)

    let stats = await breaker.statistics
    #expect(stats.totalRequests == 1)
    #expect(stats.successfulRequests == 1)
    #expect(stats.failedRequests == 0)
}

@Test func testCircuitBreakerOpensAfterFailures() async {
    let config = CircuitBreakerConfiguration(
        failureThreshold: 3,
        successThreshold: 2,
        openDuration: 30,
        halfOpenMaxRequests: 2,
        failureWindow: 60
    )

    let breaker = CircuitBreaker(name: "test-service", configuration: config)

    // Cause failures
    for _ in 0..<3 {
        do {
            _ = try await breaker.execute {
                throw TestError.simulated
            }
        } catch {
            // Expected
        }
    }

    let state = await breaker.state
    #expect(state == .open)

    // Next request should be rejected
    do {
        _ = try await breaker.execute {
            return "should not execute"
        }
        #expect(Bool(false), "Should have thrown")
    } catch let error as CircuitBreakerError {
        if case .circuitOpen(let service, _) = error {
            #expect(service == "test-service")
        } else {
            #expect(Bool(false), "Wrong error type")
        }
    } catch {
        #expect(Bool(false), "Wrong error type")
    }
}

@Test func testCircuitBreakerTransitionsToHalfOpen() async throws {
    let config = CircuitBreakerConfiguration(
        failureThreshold: 2,
        successThreshold: 2,
        openDuration: 0.1, // Very short for testing
        halfOpenMaxRequests: 2,
        failureWindow: 60
    )

    let breaker = CircuitBreaker(name: "test-service", configuration: config)

    // Open the circuit
    for _ in 0..<2 {
        do {
            _ = try await breaker.execute {
                throw TestError.simulated
            }
        } catch {
            // Expected
        }
    }

    #expect(await breaker.state == .open)

    // Wait for open duration
    try await Task.sleep(nanoseconds: 150_000_000) // 150ms

    // Next request should be allowed (half-open)
    let result = try await breaker.execute {
        return "success"
    }

    #expect(result == "success")
    #expect(await breaker.state == .halfOpen)
}

@Test func testCircuitBreakerClosesAfterSuccesses() async throws {
    let config = CircuitBreakerConfiguration(
        failureThreshold: 2,
        successThreshold: 2,
        openDuration: 0.05,
        halfOpenMaxRequests: 5,
        failureWindow: 60
    )

    let breaker = CircuitBreaker(name: "test-service", configuration: config)

    // Open the circuit
    for _ in 0..<2 {
        do {
            _ = try await breaker.execute { throw TestError.simulated }
        } catch {}
    }

    // Wait for transition to half-open
    try await Task.sleep(nanoseconds: 60_000_000)

    // Succeed twice to close
    for _ in 0..<2 {
        _ = try await breaker.execute { return "ok" }
    }

    #expect(await breaker.state == .closed)
}

@Test func testCircuitBreakerReset() async throws {
    let config = CircuitBreakerConfiguration(failureThreshold: 2)
    let breaker = CircuitBreaker(name: "test-service", configuration: config)

    // Open the circuit
    for _ in 0..<2 {
        do {
            _ = try await breaker.execute { throw TestError.simulated }
        } catch {}
    }

    #expect(await breaker.state == .open)

    // Reset
    await breaker.reset()

    #expect(await breaker.state == .closed)
}

@Test func testCircuitBreakerManualTrip() async {
    let breaker = CircuitBreaker(name: "test-service")

    await breaker.trip()

    #expect(await breaker.state == .open)
}

@Test func testCircuitBreakerStatistics() async throws {
    let breaker = CircuitBreaker(name: "test-service")

    // Perform some operations
    for _ in 0..<5 {
        _ = try await breaker.execute { return "ok" }
    }

    for _ in 0..<2 {
        do {
            _ = try await breaker.execute { throw TestError.simulated }
        } catch {}
    }

    let stats = await breaker.statistics
    #expect(stats.name == "test-service")
    #expect(stats.totalRequests == 7)
    #expect(stats.successfulRequests == 5)
    #expect(stats.failedRequests == 2)
    #expect(stats.successRate > 0.7)
}

// MARK: - Circuit Breaker Configuration Tests

@Test func testCircuitBreakerDefaultConfiguration() {
    let config = CircuitBreakerConfiguration.default

    #expect(config.failureThreshold == 5)
    #expect(config.successThreshold == 3)
    #expect(config.openDuration == 30)
}

@Test func testCircuitBreakerAggressiveConfiguration() {
    let config = CircuitBreakerConfiguration.aggressive

    #expect(config.failureThreshold == 3)
    #expect(config.successThreshold == 2)
    #expect(config.openDuration == 15)
}

@Test func testCircuitBreakerConservativeConfiguration() {
    let config = CircuitBreakerConfiguration.conservative

    #expect(config.failureThreshold == 10)
    #expect(config.successThreshold == 5)
    #expect(config.openDuration == 60)
}

// MARK: - Circuit Breaker Registry Tests

@Test func testCircuitBreakerRegistryGetOrCreate() async {
    let registry = CircuitBreakerRegistry()

    let breaker1 = await registry.breaker(for: "service-a")
    let breaker2 = await registry.breaker(for: "service-a")

    // Should return the same instance
    let name1 = await breaker1.name
    let name2 = await breaker2.name
    #expect(name1 == name2)
}

@Test func testCircuitBreakerRegistryDifferentServices() async {
    let registry = CircuitBreakerRegistry()

    let breaker1 = await registry.breaker(for: "service-a")
    let breaker2 = await registry.breaker(for: "service-b")

    let name1 = await breaker1.name
    let name2 = await breaker2.name

    #expect(name1 == "service-a")
    #expect(name2 == "service-b")
}

@Test func testCircuitBreakerRegistryResetAll() async throws {
    let registry = CircuitBreakerRegistry(
        defaultConfiguration: CircuitBreakerConfiguration(failureThreshold: 2)
    )

    let breakerA = await registry.breaker(for: "service-a")
    let breakerB = await registry.breaker(for: "service-b")

    // Trip both circuits
    await breakerA.trip()
    await breakerB.trip()

    #expect(await breakerA.state == .open)
    #expect(await breakerB.state == .open)

    // Reset all
    await registry.resetAll()

    #expect(await breakerA.state == .closed)
    #expect(await breakerB.state == .closed)
}

@Test func testCircuitBreakerRegistryOpenCircuits() async {
    let registry = CircuitBreakerRegistry()

    let breakerA = await registry.breaker(for: "service-a")
    let breakerB = await registry.breaker(for: "service-b")

    await breakerA.trip()

    let open = await registry.openCircuits()
    #expect(open.contains("service-a"))
    #expect(!open.contains("service-b"))
}

@Test func testCircuitBreakerRegistryIsHealthy() async {
    let registry = CircuitBreakerRegistry()

    let breaker = await registry.breaker(for: "service-a")

    #expect(await registry.isHealthy("service-a"))
    #expect(await registry.isHealthy("unknown-service")) // Unknown services are healthy

    await breaker.trip()

    #expect(await registry.isHealthy("service-a") == false)
}

// MARK: - Circuit Breaker Error Tests

@Test func testCircuitOpenErrorDescription() {
    let error = CircuitBreakerError.circuitOpen(service: "test", remainingTime: 15.5)

    #expect(error.errorDescription?.contains("test") == true)
    #expect(error.errorDescription?.contains("15.5") == true)
}

@Test func testTooManyFailuresErrorDescription() {
    let error = CircuitBreakerError.tooManyFailures(service: "test", failureCount: 10)

    #expect(error.errorDescription?.contains("test") == true)
    #expect(error.errorDescription?.contains("10") == true)
}

// MARK: - Helper Types

enum TestError: Error {
    case simulated
}
