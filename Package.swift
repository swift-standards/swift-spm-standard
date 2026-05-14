// swift-tools-version: 6.3.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-spm-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(
            name: "SPM Standard",
            targets: ["SPM Standard"]
        ),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-package-primitives"),
        .package(path: "../../swift-primitives/swift-version-primitives"),
        .package(path: "../../swift-foundations/swift-paths"),
        .package(path: "../swift-uri-standard")
    ],
    targets: [
        .target(
            name: "SPM Standard",
            dependencies: [
                .product(name: "Package Primitives", package: "swift-package-primitives"),
                .product(name: "Version Primitives", package: "swift-version-primitives"),
                .product(name: "Version Primitives Standard Library Integration", package: "swift-version-primitives"),
                .product(name: "Paths", package: "swift-paths"),
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
