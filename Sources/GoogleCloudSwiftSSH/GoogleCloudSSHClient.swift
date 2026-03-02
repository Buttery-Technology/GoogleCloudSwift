import Foundation
import NIOCore
import NIOPosix
import NIOSSH
import Crypto

// MARK: - SSH Client

/// SSH client actor wrapping swift-nio-ssh for executing commands and transferring files.
public actor GoogleCloudSSHClient: GoogleCloudSSHClientProtocol {

    private let eventLoopGroup: EventLoopGroup
    private let ownsEventLoopGroup: Bool

    /// Initialize with an existing event loop group.
    /// - Parameter eventLoopGroup: The NIO event loop group to use. The caller is responsible for lifecycle.
    public init(eventLoopGroup: EventLoopGroup) {
        self.eventLoopGroup = eventLoopGroup
        self.ownsEventLoopGroup = false
    }

    /// Initialize with a new internal event loop group.
    public init() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.ownsEventLoopGroup = true
    }

    deinit {
        if ownsEventLoopGroup {
            try? (eventLoopGroup as? MultiThreadedEventLoopGroup)?.syncShutdownGracefully()
        }
    }

    // MARK: - Command Execution

    public func executeCommand(
        _ command: String,
        host: String,
        port: Int = 22,
        username: String,
        privateKey: NIOSSHPrivateKey,
        timeout: TimeInterval = 30
    ) async throws -> SSHCommandResult {
        let channel = try await connect(host: host, port: port, username: username, privateKey: privateKey)
        defer { channel.close(mode: .all, promise: nil) }

        let resultHandler = SSHCommandHandler()

        // Get the NIOSSHHandler from the pipeline
        let sshHandler = try await channel.pipeline.handler(type: NIOSSHHandler.self).get()

        // Create child channel via promise
        let childChannelPromise: EventLoopPromise<Channel> = channel.eventLoop.makePromise()
        sshHandler.createChannel(childChannelPromise) { childChannel, channelType in
            guard channelType == .session else {
                return channel.eventLoop.makeFailedFuture(GoogleCloudSSHError.channelFailed("Unexpected channel type"))
            }
            return childChannel.pipeline.addHandlers([resultHandler])
        }
        let childChannel = try await childChannelPromise.futureResult.get()

        // Request exec
        let execRequest = SSHChannelRequestEvent.ExecRequest(command: command, wantReply: true)
        try await childChannel.triggerUserOutboundEvent(execRequest).get()

        // Wait for completion with timeout
        let result = try await withThrowingTaskGroup(of: SSHCommandResult.self) { group in
            group.addTask {
                try await resultHandler.waitForResult()
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw GoogleCloudSSHError.timeout(timeout)
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }

        return result
    }

    // MARK: - File Transfer

    public func uploadFile(
        localData: Data,
        remotePath: String,
        host: String,
        port: Int = 22,
        username: String,
        privateKey: NIOSSHPrivateKey,
        permissions: String = "0644"
    ) async throws {
        let base64 = localData.base64EncodedString()
        let escapedPath = shellEscape(remotePath)
        let escapedPerms = shellEscape(permissions)
        let command = "echo '\(base64)' | base64 -d > \(escapedPath) && chmod \(escapedPerms) \(escapedPath)"
        let result = try await executeCommand(
            command,
            host: host,
            port: port,
            username: username,
            privateKey: privateKey,
            timeout: 60
        )
        guard result.succeeded else {
            throw GoogleCloudSSHError.transferFailed("Upload failed: \(result.stderr)")
        }
    }

    public func downloadFile(
        remotePath: String,
        host: String,
        port: Int = 22,
        username: String,
        privateKey: NIOSSHPrivateKey
    ) async throws -> Data {
        let escapedPath = shellEscape(remotePath)
        let result = try await executeCommand(
            "base64 \(escapedPath)",
            host: host,
            port: port,
            username: username,
            privateKey: privateKey,
            timeout: 60
        )
        guard result.succeeded else {
            throw GoogleCloudSSHError.transferFailed("Download failed: \(result.stderr)")
        }
        guard let data = Data(base64Encoded: result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw GoogleCloudSSHError.transferFailed("Failed to decode base64 response")
        }
        return data
    }

    /// Shell-escape a string by wrapping in single quotes and escaping internal single quotes.
    private func shellEscape(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    // MARK: - Connection

    private func connect(
        host: String,
        port: Int,
        username: String,
        privateKey: NIOSSHPrivateKey
    ) async throws -> Channel {
        let bootstrap = ClientBootstrap(group: eventLoopGroup)
            .channelInitializer { channel in
                let clientConfig = SSHClientConfiguration(
                    userAuthDelegate: PrivateKeyAuthDelegate(
                        username: username,
                        privateKey: privateKey
                    ),
                    serverAuthDelegate: AcceptAllHostKeysDelegate()
                )
                return channel.pipeline.addHandler(
                    NIOSSHHandler(
                        role: .client(clientConfig),
                        allocator: channel.allocator,
                        inboundChildChannelInitializer: nil
                    )
                )
            }
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .connectTimeout(.seconds(Int64(30)))

        do {
            return try await bootstrap.connect(host: host, port: port).get()
        } catch {
            throw GoogleCloudSSHError.connectionFailed("Could not connect to \(host):\(port): \(error)")
        }
    }
}

// MARK: - Auth Delegate

/// Private key authentication delegate for NIO SSH.
final class PrivateKeyAuthDelegate: NIOSSHClientUserAuthenticationDelegate, @unchecked Sendable {
    private let username: String
    private let privateKey: NIOSSHPrivateKey
    private var attemptedKey = false

    init(username: String, privateKey: NIOSSHPrivateKey) {
        self.username = username
        self.privateKey = privateKey
    }

    func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        if !attemptedKey && availableMethods.contains(.publicKey) {
            attemptedKey = true
            nextChallengePromise.succeed(.init(
                username: username,
                serviceName: "",
                offer: .privateKey(.init(privateKey: privateKey))
            ))
        } else {
            nextChallengePromise.succeed(nil)
        }
    }
}

// MARK: - Host Key Delegate

/// Accepts all host keys — appropriate for ephemeral cloud VMs.
final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate, @unchecked Sendable {
    func validateHostKey(
        hostKey: NIOSSHPublicKey,
        validationCompletePromise: EventLoopPromise<Void>
    ) {
        validationCompletePromise.succeed(())
    }
}

// MARK: - Command Handler

/// Channel handler that collects stdout, stderr, and exit status from an SSH exec session.
final class SSHCommandHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = SSHChannelData
    typealias OutboundIn = SSHChannelData
    typealias OutboundOut = SSHChannelData

    private var stdoutBuffer = Data()
    private var stderrBuffer = Data()
    private var exitCode: Int?
    private var continuation: CheckedContinuation<SSHCommandResult, Error>?
    private var completedResult: Result<SSHCommandResult, Error>?
    private let lock = NSLock()

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = unwrapInboundIn(data)

        guard case .byteBuffer(var buffer) = channelData.data,
              let bytes = buffer.readBytes(length: buffer.readableBytes) else {
            return
        }

        switch channelData.type {
        case .channel:
            lock.lock()
            stdoutBuffer.append(contentsOf: bytes)
            lock.unlock()
        case .stdErr:
            lock.lock()
            stderrBuffer.append(contentsOf: bytes)
            lock.unlock()
        default:
            break
        }
    }

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if event is ChannelSuccessEvent {
            // Channel success - the exec request was accepted
        } else if let event = event as? SSHChannelRequestEvent.ExitStatus {
            lock.lock()
            exitCode = event.exitStatus
            lock.unlock()
        }
        context.fireUserInboundEventTriggered(event)
    }

    func channelInactive(context: ChannelHandlerContext) {
        lock.lock()
        // If errorCaught already recorded a result, don't overwrite it
        if completedResult != nil && continuation == nil {
            lock.unlock()
            context.fireChannelInactive()
            return
        }
        let result = SSHCommandResult(
            exitCode: exitCode ?? -1,
            stdout: String(data: stdoutBuffer, encoding: .utf8) ?? "",
            stderr: String(data: stderrBuffer, encoding: .utf8) ?? ""
        )
        if let cont = continuation {
            continuation = nil
            lock.unlock()
            cont.resume(returning: result)
        } else {
            completedResult = .success(result)
            lock.unlock()
        }
        context.fireChannelInactive()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        lock.lock()
        if let cont = continuation {
            continuation = nil
            lock.unlock()
            cont.resume(throwing: error)
        } else {
            completedResult = .failure(error)
            lock.unlock()
        }
        context.close(promise: nil)
    }

    func waitForResult() async throws -> SSHCommandResult {
        try await withCheckedThrowingContinuation { cont in
            lock.lock()
            if let result = completedResult {
                completedResult = nil
                lock.unlock()
                cont.resume(with: result)
            } else {
                continuation = cont
                lock.unlock()
            }
        }
    }
}
