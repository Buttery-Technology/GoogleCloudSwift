// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloudSwift",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "GoogleCloudSwift",
            targets: ["GoogleCloudSwift"]
        ),
    ],
    targets: [
        .target(name: "GoogleCloudSwift"),
        .testTarget(
            name: "GoogleCloudSwiftTests",
            dependencies: ["GoogleCloudSwift"]
        ),
    ]
)
