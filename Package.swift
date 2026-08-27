// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-spm-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27)
    ],
    products: [
        .library(
            name: "SPM Standard",
            targets: ["SPM Standard"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-package.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-version.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-uri-standard.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SPM Standard",
            dependencies: [
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Package", package: "swift-package"),
                .product(name: "Version", package: "swift-version"),
                .product(name: "Version Standard Library Integration", package: "swift-version"),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
