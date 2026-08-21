import Foundation
import Testing

@testable import SPM_Standard

extension `SPM Standard Tests`.`Codable Round-Trip` {
    @Test
    func `Manifest.Target regular round-trips through JSON`() throws {
        let target = Package.Manifest.Target(
            name: "SPM Standard",
            kind: .regular,
            dependencies: [
                .product(name: "Package Primitives", package: "swift-package-primitives"),
                .target(name: "Helpers"),
                .byName("LooseLiteral"),
            ],
            path: nil
        )
        let encoded = try JSONEncoder().encode(target)
        let decoded = try JSONDecoder().decode(
            Package.Manifest.Target.self,
            from: encoded
        )
        #expect(decoded == target)
    }

    @Test
    func `Manifest.Target executable round-trips through JSON`() throws {
        let target = Package.Manifest.Target(
            name: "Linter CLI",
            kind: .executable,
            dependencies: [.target(name: "Linter")]
        )
        let encoded = try JSONEncoder().encode(target)
        let decoded = try JSONDecoder().decode(
            Package.Manifest.Target.self,
            from: encoded
        )
        #expect(decoded == target)
    }

    @Test
    func `Manifest.Target test round-trips through JSON`() throws {
        let target = Package.Manifest.Target(
            name: "Foo Tests",
            kind: .test,
            dependencies: [.byName("Foo")]
        )
        let encoded = try JSONEncoder().encode(target)
        let decoded = try JSONDecoder().decode(
            Package.Manifest.Target.self,
            from: encoded
        )
        #expect(decoded == target)
    }

    @Test
    func `Manifest.Target macro round-trips through JSON`() throws {
        let target = Package.Manifest.Target(
            name: "MyMacro",
            kind: .macro,
            dependencies: []
        )
        let encoded = try JSONEncoder().encode(target)
        let decoded = try JSONDecoder().decode(
            Package.Manifest.Target.self,
            from: encoded
        )
        #expect(decoded == target)
    }

    @Test
    func `Manifest.Target with custom path round-trips through JSON`() throws {
        let target = Package.Manifest.Target(
            name: "Custom",
            kind: .regular,
            dependencies: [],
            path: "Sources/Custom/Override"
        )
        let encoded = try JSONEncoder().encode(target)
        let decoded = try JSONDecoder().decode(
            Package.Manifest.Target.self,
            from: encoded
        )
        #expect(decoded == target)
        #expect(decoded.path == "Sources/Custom/Override")
    }

    @Test
    func `Manifest.Target decodes dump-package wire shape ignoring extras`() throws {
        let json = """
            {
              "dependencies": [
                {"product": ["Package Primitives", "swift-package-primitives", null, null]},
                {"target": ["SiblingTarget", null]},
                {"byName": ["LooseLiteral", null]}
              ],
              "exclude": [],
              "name": "SPM Standard",
              "packageAccess": true,
              "resources": [],
              "settings": [],
              "type": "regular"
            }
            """
        let data = try #require(json.data(using: .utf8))
        let target = try JSONDecoder().decode(
            Package.Manifest.Target.self,
            from: data
        )
        #expect(target.name == "SPM Standard")
        #expect(target.kind == .regular)
        #expect(target.dependencies.count == 3)

        guard case .product(let pName, let pkgName) = target.dependencies[0] else {
            Issue.record("expected .product dependency")
            return
        }
        #expect(pName == "Package Primitives")
        #expect(pkgName == "swift-package-primitives")

        guard case .target(let tName) = target.dependencies[1] else {
            Issue.record("expected .target dependency")
            return
        }
        #expect(tName == "SiblingTarget")

        guard case .byName(let name) = target.dependencies[2] else {
            Issue.record("expected .byName dependency")
            return
        }
        #expect(name == "LooseLiteral")
    }
}

extension `SPM Standard Tests`.`Codable Round-Trip` {
    @Test
    func `Target.Dependency.product round-trips through JSON`() throws {
        let dependency: Target.Dependency = .product(
            name: "ArgumentParser",
            package: "swift-argument-parser"
        )
        let encoded = try JSONEncoder().encode(dependency)
        let decoded = try JSONDecoder().decode(
            Target.Dependency.self,
            from: encoded
        )
        #expect(decoded == dependency)
    }

    @Test
    func `Target.Dependency.target round-trips through JSON`() throws {
        let dependency: Target.Dependency = .target(name: "SiblingTarget")
        let encoded = try JSONEncoder().encode(dependency)
        let decoded = try JSONDecoder().decode(
            Target.Dependency.self,
            from: encoded
        )
        #expect(decoded == dependency)
    }

    @Test
    func `Target.Dependency.byName round-trips through JSON`() throws {
        let dependency: Target.Dependency = .byName("Foo")
        let encoded = try JSONEncoder().encode(dependency)
        let decoded = try JSONDecoder().decode(
            Target.Dependency.self,
            from: encoded
        )
        #expect(decoded == dependency)
    }
}

extension `SPM Standard Tests`.Unit {
    @Test
    func `Target.Kind has all seven SwiftPM kinds`() {

        #expect(Target.Kind.allCases.count == 7)
        #expect(Target.Kind.allCases.contains(.regular))
        #expect(Target.Kind.allCases.contains(.executable))
        #expect(Target.Kind.allCases.contains(.test))
        #expect(Target.Kind.allCases.contains(.plugin))
        #expect(Target.Kind.allCases.contains(.binary))
        #expect(Target.Kind.allCases.contains(.system))
        #expect(Target.Kind.allCases.contains(.macro))
    }

    @Test
    func `Product.LibraryType has three SwiftPM link kinds`() {
        #expect(Product.LibraryType.allCases.count == 3)
        #expect(Product.LibraryType.static.rawValue == "static")
        #expect(Product.LibraryType.dynamic.rawValue == "dynamic")
        #expect(Product.LibraryType.automatic.rawValue == "automatic")
    }
}
