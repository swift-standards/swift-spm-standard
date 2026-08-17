// swift-tools-version: 6.3.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-spm-standard",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27")
    ],
    products: [
        .library(
            name: "SPM Standard",
            targets: ["SPM Standard"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-package-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-version-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-uri-standard.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SPM Standard",
            dependencies: [
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
                .product(name: "Package Primitives", package: "swift-package-primitives"),
                .product(name: "Version Primitives", package: "swift-version-primitives"),
                .product(name: "Version Primitives Standard Library Integration", package: "swift-version-primitives"),
                .product(name: "URI Standard", package: "swift-uri-standard"),
                .product(name: "URI Standard Library Integration", package: "swift-uri-standard")
            ]
        ),
        .testTarget(
            name: "SPM Standard Tests",
            dependencies: [
                "SPM Standard"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
