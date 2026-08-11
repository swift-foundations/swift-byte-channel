// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-byte-channel",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "Byte Chunk", targets: ["Byte Chunk"]),
        .library(name: "Byte Channel", targets: ["Byte Channel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-async-primitives.git", revision: "dbfcf6a3c61e72fe98580a7ef1f5384c59898cc4"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-linear-primitives.git", revision: "3eead6eb2b440d417338929c60da94cc18fd3386"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Byte Chunk",
            dependencies: [
                .product(name: "Buffer Linear Primitives", package: "swift-buffer-linear-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
        .target(
            name: "Byte Channel",
            dependencies: [
                "Byte Chunk",
                .product(name: "Async Channel Primitives", package: "swift-async-primitives"),
                .product(name: "Async Semaphore Primitives", package: "swift-async-primitives"),
                .product(name: "Buffer Protocol Primitives", package: "swift-buffer-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
        .testTarget(
            name: "Byte Channel Tests",
            dependencies: ["Byte Channel"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
    ]
}
