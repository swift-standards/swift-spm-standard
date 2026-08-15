// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-spm-standard open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-spm-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// JSON Encoder/Decoder are Foundation-bound and use untyped throws via the
// Codable protocol — both rules are deliberately exempted across this file.
import Foundation
import Testing

@testable import SPM_Standard

// MARK: - Second-pass `Package.Dependency.products` back-fill

extension `SPM Standard Tests`.`Codable Round-Trip` {
    /// The Phase 3 follow-up arc gap: `swift package dump-package`
    /// emits dependencies and target dependencies in separate
    /// arrays. v0.2 left `Package.Dependency.products` empty after
    /// decode because the `dependencies[]` array carries no
    /// product references. v0.3 walks `targets[].dependencies[]`,
    /// collects every `(packageIdentity → productName)` pair, and
    /// rebuilds each `Package.Dependency` with its `products` set
    /// populated.
    @Test
    func `Package.Manifest decode populates Dependency.products from target edges`() throws {
        let json = """
            {
              "name": "swift-consumer",
              "toolsVersion": {"_version": "6.3.1"},
              "dependencies": [
                {
                  "fileSystem": [
                    {"identity": "swift-package-primitives",
                     "path": "/abs/swift-package-primitives",
                     "productFilter": null,
                     "traits": []}
                  ]
                },
                {
                  "sourceControl": [
                    {"identity": "swift-syntax",
                     "location": {"remote": [{"urlString": "https://github.com/swiftlang/swift-syntax.git"}]},
                     "productFilter": null,
                     "requirement": {"exact": ["602.0.0"]},
                     "traits": []}
                  ]
                },
                {
                  "fileSystem": [
                    {"identity": "swift-unused",
                     "path": "/abs/swift-unused",
                     "productFilter": null,
                     "traits": []}
                  ]
                }
              ],
              "products": [],
              "targets": [
                {
                  "name": "Consumer",
                  "type": "regular",
                  "dependencies": [
                    {"product": ["Package Primitives", "swift-package-primitives", null, null]},
                    {"product": ["SwiftSyntax", "swift-syntax", null, null]},
                    {"product": ["SwiftSyntaxBuilder", "swift-syntax", null, null]},
                    {"target": ["LocalSibling", null]},
                    {"byName": ["LooseLiteral", null]}
                  ]
                },
                {
                  "name": "ConsumerTests",
                  "type": "test",
                  "dependencies": [
                    {"product": ["SwiftSyntax", "swift-syntax", null, null]},
                    {"target": ["Consumer", null]}
                  ]
                }
              ]
            }
            """
        let data = try #require(json.data(using: .utf8))
        let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)

        #expect(manifest.name == "swift-consumer")
        #expect(manifest.dependencies.count == 3)

        // swift-package-primitives → ["Package Primitives"]
        let pkgPrimitivesDep = try #require(
            manifest.dependencies.first { $0.name == "swift-package-primitives" }
        )
        #expect(pkgPrimitivesDep.products == ["Package Primitives"])

        // swift-syntax → ["SwiftSyntax", "SwiftSyntaxBuilder"] — order
        // preserved (first-occurrence in target order); deduped across
        // the test target's repeat reference.
        let swiftSyntaxDep = try #require(
            manifest.dependencies.first { $0.name == "swift-syntax" }
        )
        #expect(swiftSyntaxDep.products == ["SwiftSyntax", "SwiftSyntaxBuilder"])

        // swift-unused → [] (no target references it; v0.2 behaviour
        // preserved for the unreferenced case).
        let unusedDep = try #require(
            manifest.dependencies.first { $0.name == "swift-unused" }
        )
        #expect(unusedDep.products == [])
    }

    @Test
    func `Package.Manifest decode preserves product-order across multiple targets`() throws {
        // Same dep referenced by three targets in different orders;
        // the back-fill should preserve first-occurrence-in-target-
        // order across all `.product` edges.
        let json = """
            {
              "name": "swift-multi",
              "toolsVersion": {"_version": "6.3.1"},
              "dependencies": [
                {
                  "fileSystem": [
                    {"identity": "swift-bundle", "path": "/abs/swift-bundle",
                     "productFilter": null, "traits": []}
                  ]
                }
              ],
              "products": [],
              "targets": [
                {
                  "name": "FirstTarget", "type": "regular",
                  "dependencies": [
                    {"product": ["Beta",  "swift-bundle", null, null]},
                    {"product": ["Alpha", "swift-bundle", null, null]}
                  ]
                },
                {
                  "name": "SecondTarget", "type": "regular",
                  "dependencies": [
                    {"product": ["Gamma", "swift-bundle", null, null]},
                    {"product": ["Beta",  "swift-bundle", null, null]}
                  ]
                }
              ]
            }
            """
        let data = try #require(json.data(using: .utf8))
        let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)
        let dep = try #require(manifest.dependencies.first)
        // First occurrence: Beta (FirstTarget), Alpha (FirstTarget),
        // Gamma (SecondTarget). Second-target Beta is deduped.
        #expect(dep.products == ["Beta", "Alpha", "Gamma"])
    }
}

// MARK: - Manifest with products / targets / platforms — full pipeline

extension `SPM Standard Tests`.`Codable Round-Trip` {
    /// Decode the synthetic equivalent of swift-spm-standard's own
    /// `dump-package` output — exercises products[], targets[],
    /// platforms[] together with the back-fill.
    @Test
    func `Package.Manifest decodes a full dump-package output (products + targets + platforms)`()
        throws
    {
        let json = """
            {
              "cLanguageStandard": null,
              "cxxLanguageStandard": null,
              "defaultLocalization": null,
              "dependencies": [
                {
                  "fileSystem": [
                    {"identity": "swift-package-primitives",
                     "path": "/abs/swift-package-primitives",
                     "productFilter": null,
                     "traits": [{"name": "default"}]}
                  ]
                }
              ],
              "name": "swift-spm-standard",
              "packageKind": {"root": ["/abs/swift-spm-standard"]},
              "pkgConfig": null,
              "platforms": [
                {"options": [], "platformName": "macos", "version": "26.0"},
                {"options": [], "platformName": "ios", "version": "26.0"}
              ],
              "products": [
                {"name": "SPM Standard", "settings": [], "targets": ["SPM Standard"],
                 "type": {"library": ["automatic"]}}
              ],
              "targets": [
                {
                  "name": "SPM Standard", "type": "regular",
                  "dependencies": [
                    {"product": ["Package Primitives", "swift-package-primitives", null, null]}
                  ],
                  "exclude": [], "resources": [], "settings": [], "packageAccess": true
                },
                {
                  "name": "SPM Standard Tests", "type": "test",
                  "dependencies": [{"byName": ["SPM Standard", null]}],
                  "exclude": [], "resources": [], "settings": [], "packageAccess": true
                }
              ],
              "toolsVersion": {"_version": "6.3.1"},
              "traits": []
            }
            """
        let data = try #require(json.data(using: .utf8))
        let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)

        #expect(manifest.name == "swift-spm-standard")

        // Products
        #expect(manifest.products.count == 1)
        #expect(manifest.products[0].name == "SPM Standard")
        guard case .library(let linkKind) = manifest.products[0].kind else {
            Issue.record("expected .library")
            return
        }
        #expect(linkKind == .automatic)
        #expect(manifest.products[0].targets == ["SPM Standard"])

        // Targets
        #expect(manifest.targets.count == 2)
        #expect(manifest.targets[0].name == "SPM Standard")
        #expect(manifest.targets[0].kind == .regular)
        #expect(manifest.targets[1].name == "SPM Standard Tests")
        #expect(manifest.targets[1].kind == .test)

        // Platforms
        let platforms = try #require(manifest.platforms)
        #expect(platforms.count == 2)
        #expect(platforms[0].platform == .macOS)
        #expect(platforms[1].platform == .iOS)

        // Back-fill
        #expect(manifest.dependencies.count == 1)
        #expect(manifest.dependencies[0].products == ["Package Primitives"])
    }

    @Test
    func `Package.Manifest with products and targets round-trips through JSON`() throws {
        let manifest = Package.Manifest(
            name: "swift-foo",
            toolsVersion: try Version.Tools("6.3.1"),
            dependencies: [
                Package.Dependency(
                    source: .path("/abs/swift-bar"),
                    name: "swift-bar",
                    products: ["Bar"]
                )
            ],
            products: [
                Package.Manifest.Product(
                    name: "Foo",
                    kind: .library(.automatic),
                    targets: ["Foo"]
                )
            ],
            targets: [
                Package.Manifest.Target(
                    name: "Foo",
                    kind: .regular,
                    dependencies: [
                        .product(name: "Bar", package: "swift-bar")
                    ]
                )
            ],
            platforms: [
                SupportedPlatform(platform: .macOS, version: "26.0")
            ]
        )
        let encoded = try JSONEncoder().encode(manifest)
        let decoded = try JSONDecoder().decode(Package.Manifest.self, from: encoded)
        #expect(decoded == manifest)
    }
}
