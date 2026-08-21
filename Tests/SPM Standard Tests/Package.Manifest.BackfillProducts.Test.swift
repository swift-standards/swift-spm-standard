import Foundation
import Testing

@testable import SPM_Standard

extension `SPM Standard Tests`.`Codable Round-Trip` {

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

        let pkgPrimitivesDep = try #require(
            manifest.dependencies.first { $0.name == "swift-package-primitives" }
        )
        #expect(pkgPrimitivesDep.products == ["Package Primitives"])

        let swiftSyntaxDep = try #require(
            manifest.dependencies.first { $0.name == "swift-syntax" }
        )
        #expect(swiftSyntaxDep.products == ["SwiftSyntax", "SwiftSyntaxBuilder"])

        let unusedDep = try #require(
            manifest.dependencies.first { $0.name == "swift-unused" }
        )
        #expect(unusedDep.products == [])
    }

    @Test
    func `Package.Manifest decode preserves product-order across multiple targets`() throws {

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

        #expect(dep.products == ["Beta", "Alpha", "Gamma"])
    }
}

extension `SPM Standard Tests`.`Codable Round-Trip` {

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

        #expect(manifest.products.count == 1)
        #expect(manifest.products[0].name == "SPM Standard")
        guard case .library(let linkKind) = manifest.products[0].kind else {
            Issue.record("expected .library")
            return
        }
        #expect(linkKind == .automatic)
        #expect(manifest.products[0].targets == ["SPM Standard"])

        #expect(manifest.targets.count == 2)
        #expect(manifest.targets[0].name == "SPM Standard")
        #expect(manifest.targets[0].kind == .regular)
        #expect(manifest.targets[1].name == "SPM Standard Tests")
        #expect(manifest.targets[1].kind == .test)

        let platforms = try #require(manifest.platforms)
        #expect(platforms.count == 2)
        #expect(platforms[0].platform == .macOS)
        #expect(platforms[1].platform == .iOS)

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
