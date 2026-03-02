// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloudSwift",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "GoogleCloudSwift",
            targets: ["GoogleCloudSwift"]
        ),
        .library(
            name: "GoogleCloudSwiftSSH",
            targets: ["GoogleCloudSwiftSSH"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "3.0.0" ..< "5.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssh.git", from: "0.12.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.81.0"),
    ],
    targets: [
        .target(
            name: "GoogleCloudSwift",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "_CryptoExtras", package: "swift-crypto"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            exclude: [
                "GoogleCloudSSHClient.swift",
                "GoogleCloudSSHKeyManager.swift",
                "GoogleCloudSSHProtocol.swift",
                "GoogleCloudSSHErrors.swift",
                "GoogleCloudComputeSSH.swift",
            ]
        ),
        .target(
            name: "GoogleCloudSwiftSSH",
            dependencies: [
                "GoogleCloudSwift",
                .product(name: "NIOSSH", package: "swift-nio-ssh"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            path: "Sources/GoogleCloudSwiftSSH"
        ),
        .testTarget(
            name: "GoogleCloudSwiftTests",
            dependencies: ["GoogleCloudSwift"]
        ),
    ]
)
