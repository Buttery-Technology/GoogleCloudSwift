//
//  GoogleCloudCircuitBreaker.swift
//  GoogleCloudSwift
//
//  Created by Claude on 1/11/26.
//

import Foundation

// MARK: - Circuit Breaker State

/// The current state of a circuit breaker.
public enum CircuitBreakerState: String, Sendable, CustomStringConvertible {
    /// Circuit is closed - requests are allowed through.
    case closed
    /// Circuit is open - requests are blocked.
    case open
    /// Circuit is half-open - limited requests are allowed to test recovery.
    case halfOpen

    public var description: String { rawValue }
}

// MARK: - Circuit Breaker Errors

/// Errors that can occur with circuit breakers.
public enum CircuitBreakerError: Error, Sendable, LocalizedError {
    /// The circuit is open and not accepting requests.
    case circuitOpen(service: String, remainingTime: TimeInterval)
    /// Too many failures occurred.
    case tooManyFailures(service: String, failureCount: Int)
    /// The operation timed out.
    case operationTimeout(service: String, timeout: TimeInterval)

    public var errorDescription: String? {
        switch self {
        case .circuitOpen(let service, let remainingTime):
            return "Circuit breaker for '\(service)' is open. Retry in \(String(format: "%.1f", remainingTime)) seconds."
        case .tooManyFailures(let service, let failureCount):
            return "Service '\(service)' has failed \(failureCount) times. Circuit breaker opened."
        case .operationTimeout(let service, let timeout):
            return "Operation on '\(service)' timed out after \(timeout) seconds."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .circuitOpen:
            return "Wait for the circuit to close or check the service health manually."
        case .tooManyFailures:
            return "Check the service status and investigate the root cause of failures."
        case .operationTimeout:
            return "Increase the timeout or check network connectivity."
        }
    }
}

// MARK: - Circuit Breaker Configuration

/// Configuration for circuit breaker behavior.
public struct CircuitBreakerConfiguration: Sendable {
    /// Number of consecutive failures before opening the circuit.
    public let failureThreshold: Int

    /// Number of successful calls required to close the circuit from half-open.
    public let successThreshold: Int

    /// Duration in seconds to keep the circuit open before transitioning to half-open.
    public let openDuration: TimeInterval

    /// Maximum number of requests allowed in half-open state.
    public let halfOpenMaxRequests: Int

    /// Time window in seconds for tracking failures (sliding window).
    public let failureWindow: TimeInterval

    /// Timeout for individual operations through the circuit breaker.
    public let operationTimeout: TimeInterval?

    /// Whether to count timeouts as failures.
    public let countTimeoutsAsFailures: Bool

    /// Default configuration.
    public static let `default` = CircuitBreakerConfiguration(
        failureThreshold: 5,
        successThreshold: 3,
        openDuration: 30,
        halfOpenMaxRequests: 3,
        failureWindow: 60,
        operationTimeout: nil,
        countTimeoutsAsFailures: true
    )

    /// Aggressive configuration - opens quickly, recovers quickly.
    public static let aggressive = CircuitBreakerConfiguration(
        failureThreshold: 3,
        successThreshold: 2,
        openDuration: 15,
        halfOpenMaxRequests: 2,
        failureWindow: 30,
        operationTimeout: nil,
        countTimeoutsAsFailures: true
    )

    /// Conservative configuration - tolerates more failures, longer recovery.
    public static let conservative = CircuitBreakerConfiguration(
        failureThreshold: 10,
        successThreshold: 5,
        openDuration: 60,
        halfOpenMaxRequests: 5,
        failureWindow: 120,
        operationTimeout: nil,
        countTimeoutsAsFailures: true
    )

    /// Configuration for critical services - very tolerant.
    public static let critical = CircuitBreakerConfiguration(
        failureThreshold: 20,
        successThreshold: 10,
        openDuration: 120,
        halfOpenMaxRequests: 5,
        failureWindow: 300,
        operationTimeout: nil,
        countTimeoutsAsFailures: false
    )

    public init(
        failureThreshold: Int = 5,
        successThreshold: Int = 3,
        openDuration: TimeInterval = 30,
        halfOpenMaxRequests: Int = 3,
        failureWindow: TimeInterval = 60,
        operationTimeout: TimeInterval? = nil,
        countTimeoutsAsFailures: Bool = true
    ) {
        self.failureThreshold = failureThreshold
        self.successThreshold = successThreshold
        self.openDuration = openDuration
        self.halfOpenMaxRequests = halfOpenMaxRequests
        self.failureWindow = failureWindow
        self.operationTimeout = operationTimeout
        self.countTimeoutsAsFailures = countTimeoutsAsFailures
    }
}

// MARK: - Circuit Breaker

/// A circuit breaker for protecting services from cascading failures.
///
/// The circuit breaker pattern prevents an application from repeatedly trying to execute
/// an operation that's likely to fail, allowing it to continue without waiting for the
/// fault to be fixed or wasting resources while determining that the fault is long-lasting.
///
/// ## States
/// - **Closed**: Normal operation. Requests flow through. Failures are counted.
/// - **Open**: Requests fail immediately. No calls are made to the protected service.
/// - **Half-Open**: Limited test requests are allowed to check if the service has recovered.
///
/// ## Example Usage
/// ```swift
/// let breaker = CircuitBreaker(
///     name: "storage-api",
///     configuration: .default
/// )
///
/// do {
///     let result = try await breaker.execute {
///         try await storageAPI.listBuckets()
///     }
/// } catch CircuitBreakerError.circuitOpen(_, let remaining) {
///     print("Service unavailable, retry in \(remaining) seconds")
/// }
/// ```
public actor CircuitBreaker: Sendable {
    /// The name/identifier for this circuit breaker.
    public let name: String

    /// The configuration for this circuit breaker.
    public let configuration: CircuitBreakerConfiguration

    /// Current state of the circuit breaker.
    public private(set) var state: CircuitBreakerState = .closed

    /// Timestamps of recent failures within the failure window.
    private var failures: [Date] = []

    /// Count of consecutive successes in half-open state.
    private var halfOpenSuccesses: Int = 0

    /// Count of requests in current half-open period.
    private var halfOpenRequests: Int = 0

    /// Timestamp when the circuit was opened.
    private var openedAt: Date?

    /// Total number of requests made through this circuit breaker.
    private var totalRequests: Int = 0

    /// Total number of successful requests.
    private var successfulRequests: Int = 0

    /// Total number of failed requests.
    private var failedRequests: Int = 0

    /// Total number of requests rejected due to open circuit.
    private var rejectedRequests: Int = 0

    /// Create a circuit breaker.
    /// - Parameters:
    ///   - name: A name to identify this circuit breaker.
    ///   - configuration: Configuration for the circuit breaker behavior.
    public init(name: String, configuration: CircuitBreakerConfiguration = .default) {
        self.name = name
        self.configuration = configuration
    }

    /// Execute an operation through the circuit breaker.
    /// - Parameter operation: The async throwing operation to execute.
    /// - Returns: The result of the operation.
    /// - Throws: `CircuitBreakerError.circuitOpen` if the circuit is open,
    ///           or the error from the operation.
    public func execute<T: Sendable>(
        _ operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        totalRequests += 1

        // Check if we should allow the request
        try checkState()

        do {
            let result: T

            // Apply timeout if configured
            if let timeout = configuration.operationTimeout {
                result = try await withTimeout(timeout) {
                    try await operation()
                }
            } else {
                result = try await operation()
            }

            recordSuccess()
            successfulRequests += 1
            return result
        } catch {
            // Check if this is a timeout error
            let isTimeout = error is TimeoutError

            // Record failure based on configuration
            if !isTimeout || configuration.countTimeoutsAsFailures {
                recordFailure()
                failedRequests += 1
            }

            throw error
        }
    }

    /// Execute an operation with a custom failure check.
    /// - Parameters:
    ///   - isFailure: A closure that determines if the result indicates a failure.
    ///   - operation: The async throwing operation to execute.
    /// - Returns: The result of the operation.
    public func execute<T: Sendable>(
        isFailure: @Sendable (T) -> Bool,
        _ operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        totalRequests += 1

        try checkState()

        do {
            let result: T

            if let timeout = configuration.operationTimeout {
                result = try await withTimeout(timeout) {
                    try await operation()
                }
            } else {
                result = try await operation()
            }

            if isFailure(result) {
                recordFailure()
                failedRequests += 1
            } else {
                recordSuccess()
                successfulRequests += 1
            }

            return result
        } catch {
            let isTimeout = error is TimeoutError
            if !isTimeout || configuration.countTimeoutsAsFailures {
                recordFailure()
                failedRequests += 1
            }
            throw error
        }
    }

    /// Get the current statistics for this circuit breaker.
    public var statistics: CircuitBreakerStatistics {
        CircuitBreakerStatistics(
            name: name,
            state: state,
            totalRequests: totalRequests,
            successfulRequests: successfulRequests,
            failedRequests: failedRequests,
            rejectedRequests: rejectedRequests,
            recentFailures: failures.count,
            halfOpenSuccesses: halfOpenSuccesses,
            openedAt: openedAt
        )
    }

    /// Manually reset the circuit breaker to closed state.
    public func reset() {
        state = .closed
        failures.removeAll()
        halfOpenSuccesses = 0
        halfOpenRequests = 0
        openedAt = nil
    }

    /// Manually trip the circuit breaker to open state.
    public func trip() {
        openCircuit()
    }

    /// Get the time remaining before the circuit transitions from open to half-open.
    public var remainingOpenTime: TimeInterval? {
        guard state == .open, let openedAt = openedAt else { return nil }
        let elapsed = Date().timeIntervalSince(openedAt)
        let remaining = configuration.openDuration - elapsed
        return remaining > 0 ? remaining : nil
    }

    // MARK: - Private Methods

    private func checkState() throws {
        cleanupOldFailures()

        switch state {
        case .closed:
            // Allow request
            return

        case .open:
            // Check if we should transition to half-open
            if let openedAt = openedAt {
                let elapsed = Date().timeIntervalSince(openedAt)
                if elapsed >= configuration.openDuration {
                    transitionToHalfOpen()
                    return
                }
            }

            // Circuit is still open, reject request
            rejectedRequests += 1
            let remaining = remainingOpenTime ?? 0
            throw CircuitBreakerError.circuitOpen(service: name, remainingTime: remaining)

        case .halfOpen:
            // Allow limited requests
            if halfOpenRequests >= configuration.halfOpenMaxRequests {
                rejectedRequests += 1
                throw CircuitBreakerError.circuitOpen(service: name, remainingTime: 0)
            }
            halfOpenRequests += 1
        }
    }

    private func recordSuccess() {
        switch state {
        case .closed:
            // Clear failures on success in closed state
            failures.removeAll()

        case .halfOpen:
            halfOpenSuccesses += 1
            if halfOpenSuccesses >= configuration.successThreshold {
                closeCircuit()
            }

        case .open:
            // Should not happen, but handle gracefully
            break
        }
    }

    private func recordFailure() {
        failures.append(Date())
        cleanupOldFailures()

        switch state {
        case .closed:
            if failures.count >= configuration.failureThreshold {
                openCircuit()
            }

        case .halfOpen:
            // Any failure in half-open state reopens the circuit
            openCircuit()

        case .open:
            // Should not happen
            break
        }
    }

    private func openCircuit() {
        state = .open
        openedAt = Date()
        halfOpenSuccesses = 0
        halfOpenRequests = 0
    }

    private func closeCircuit() {
        state = .closed
        failures.removeAll()
        halfOpenSuccesses = 0
        halfOpenRequests = 0
        openedAt = nil
    }

    private func transitionToHalfOpen() {
        state = .halfOpen
        halfOpenSuccesses = 0
        halfOpenRequests = 0
    }

    private func cleanupOldFailures() {
        let cutoff = Date().addingTimeInterval(-configuration.failureWindow)
        failures.removeAll { $0 < cutoff }
    }

    private func withTimeout<T: Sendable>(
        _ timeout: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TimeoutError()
            }

            guard let result = try await group.next() else {
                throw TimeoutError()
            }

            group.cancelAll()
            return result
        }
    }
}

/// Internal timeout error.
private struct TimeoutError: Error {}

// MARK: - Circuit Breaker Statistics

/// Statistics for a circuit breaker.
public struct CircuitBreakerStatistics: Sendable {
    /// The name of the circuit breaker.
    public let name: String

    /// Current state.
    public let state: CircuitBreakerState

    /// Total requests made.
    public let totalRequests: Int

    /// Successful requests.
    public let successfulRequests: Int

    /// Failed requests.
    public let failedRequests: Int

    /// Requests rejected due to open circuit.
    public let rejectedRequests: Int

    /// Number of failures in the current window.
    public let recentFailures: Int

    /// Successes in half-open state.
    public let halfOpenSuccesses: Int

    /// When the circuit was opened (if currently open).
    public let openedAt: Date?

    /// Success rate (0.0 to 1.0).
    public var successRate: Double {
        guard totalRequests > 0 else { return 1.0 }
        return Double(successfulRequests) / Double(totalRequests)
    }

    /// Failure rate (0.0 to 1.0).
    public var failureRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(failedRequests) / Double(totalRequests)
    }
}

// MARK: - Circuit Breaker Registry

/// A registry for managing multiple circuit breakers.
///
/// ## Example Usage
/// ```swift
/// let registry = CircuitBreakerRegistry.shared
///
/// // Get or create circuit breakers
/// let storageBreaker = await registry.breaker(for: "storage")
/// let computeBreaker = await registry.breaker(for: "compute", configuration: .aggressive)
///
/// // Check all circuit statuses
/// let statuses = await registry.allStatistics()
/// ```
public actor CircuitBreakerRegistry: Sendable {
    /// Shared registry instance.
    public static let shared = CircuitBreakerRegistry()

    private var breakers: [String: CircuitBreaker] = [:]
    private let defaultConfiguration: CircuitBreakerConfiguration

    /// Create a circuit breaker registry.
    /// - Parameter defaultConfiguration: Default configuration for new circuit breakers.
    public init(defaultConfiguration: CircuitBreakerConfiguration = .default) {
        self.defaultConfiguration = defaultConfiguration
    }

    /// Get or create a circuit breaker for a service.
    /// - Parameters:
    ///   - service: The service identifier.
    ///   - configuration: Optional configuration (uses default if not provided).
    /// - Returns: The circuit breaker for the service.
    public func breaker(
        for service: String,
        configuration: CircuitBreakerConfiguration? = nil
    ) -> CircuitBreaker {
        if let existing = breakers[service] {
            return existing
        }

        let breaker = CircuitBreaker(
            name: service,
            configuration: configuration ?? defaultConfiguration
        )
        breakers[service] = breaker
        return breaker
    }

    /// Remove a circuit breaker from the registry.
    /// - Parameter service: The service identifier.
    public func remove(_ service: String) {
        breakers.removeValue(forKey: service)
    }

    /// Get statistics for all circuit breakers.
    /// - Returns: Dictionary of service name to statistics.
    public func allStatistics() async -> [String: CircuitBreakerStatistics] {
        var stats: [String: CircuitBreakerStatistics] = [:]
        for (name, breaker) in breakers {
            stats[name] = await breaker.statistics
        }
        return stats
    }

    /// Reset all circuit breakers.
    public func resetAll() async {
        for breaker in breakers.values {
            await breaker.reset()
        }
    }

    /// Get all open circuits.
    /// - Returns: Array of service names with open circuits.
    public func openCircuits() async -> [String] {
        var open: [String] = []
        for (name, breaker) in breakers {
            if await breaker.state == .open {
                open.append(name)
            }
        }
        return open
    }

    /// Check if a service circuit is healthy (closed or half-open).
    /// - Parameter service: The service identifier.
    /// - Returns: `true` if the circuit is not open.
    public func isHealthy(_ service: String) async -> Bool {
        guard let breaker = breakers[service] else { return true }
        return await breaker.state != .open
    }
}

// MARK: - Circuit Breaker HTTP Client

/// An HTTP client wrapper that uses circuit breakers.
///
/// ## Example Usage
/// ```swift
/// let client = CircuitBreakerHTTPClient(
///     client: httpClient,
///     configuration: .default
/// )
///
/// // Requests are protected by automatic circuit breakers
/// let result: MyResponse = try await client.get(path: "/api/resource")
/// ```
public actor CircuitBreakerHTTPClient: Sendable {
    private let client: GoogleCloudHTTPClient
    private let breaker: CircuitBreaker

    /// Create a circuit breaker HTTP client.
    /// - Parameters:
    ///   - client: The underlying HTTP client.
    ///   - serviceName: Name for the circuit breaker (defaults to "http").
    ///   - configuration: Circuit breaker configuration.
    public init(
        client: GoogleCloudHTTPClient,
        serviceName: String = "http",
        configuration: CircuitBreakerConfiguration = .default
    ) {
        self.client = client
        self.breaker = CircuitBreaker(name: serviceName, configuration: configuration)
    }

    /// Create using an existing circuit breaker.
    /// - Parameters:
    ///   - client: The underlying HTTP client.
    ///   - breaker: The circuit breaker to use.
    public init(client: GoogleCloudHTTPClient, breaker: CircuitBreaker) {
        self.client = client
        self.breaker = breaker
    }

    /// Perform a GET request with circuit breaker protection.
    public func get<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await breaker.execute {
            try await self.client.get(path: path, queryParameters: queryParameters)
        }
    }

    /// Perform a POST request with circuit breaker protection.
    public func post<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await breaker.execute {
            try await self.client.post(path: path, body: body, queryParameters: queryParameters)
        }
    }

    /// Perform a POST request without body with circuit breaker protection.
    public func post<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await breaker.execute {
            try await self.client.post(path: path, queryParameters: queryParameters)
        }
    }

    /// Perform a PUT request with circuit breaker protection.
    public func put<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await breaker.execute {
            try await self.client.put(path: path, body: body, queryParameters: queryParameters)
        }
    }

    /// Perform a PATCH request with circuit breaker protection.
    public func patch<T: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await breaker.execute {
            try await self.client.patch(path: path, body: body, queryParameters: queryParameters)
        }
    }

    /// Perform a DELETE request with circuit breaker protection.
    public func delete<T: Decodable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> GoogleCloudAPIResponse<T> {
        try await breaker.execute {
            try await self.client.delete(path: path, queryParameters: queryParameters)
        }
    }

    /// Perform a DELETE request with no content with circuit breaker protection.
    public func deleteNoContent(
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws {
        try await breaker.execute {
            try await self.client.deleteNoContent(path: path, queryParameters: queryParameters)
        }
    }

    /// Get the circuit breaker statistics.
    public func statistics() async -> CircuitBreakerStatistics {
        await breaker.statistics
    }

    /// Get the circuit breaker state.
    public func state() async -> CircuitBreakerState {
        await breaker.state
    }

    /// Reset the circuit breaker.
    public func reset() async {
        await breaker.reset()
    }
}
