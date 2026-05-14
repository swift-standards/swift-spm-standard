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

import Testing
@testable import SPM_Standard

// MARK: - Package.Manifest

extension `SPM Standard Tests`.Unit {
    @Test
    func `Package.Manifest stores name, toolsVersion, dependencies`() throws {
        let manifest = Package.Manifest(
            name: "swift-foo",
            toolsVersion: try Version.Tools("6.3"),
            dependencies: [
                Package.Dependency(
                    source: .path("../swift-bar"),
                    name: "swift-bar",
                    products: ["Bar"]
                )
            ]
        )
        #expect(manifest.name == "swift-foo")
        #expect(manifest.toolsVersion == (try Version.Tools("6.3")))
        #expect(manifest.dependencies.count == 1)
        #expect(manifest.dependencies[0].name == "swift-bar")
    }

    @Test
    func `Package.Manifest accepts empty dependencies by default`() throws {
        let manifest = Package.Manifest(
            name: "swift-leaf",
            toolsVersion: try Version.Tools("6.3")
        )
        #expect(manifest.dependencies.isEmpty)
    }

    @Test
    func `Package.Manifest equality reflects all fields`() throws {
        let toolsVersion = try Version.Tools("6.3")
        let a = Package.Manifest(name: "swift-foo", toolsVersion: toolsVersion)
        let b = Package.Manifest(name: "swift-foo", toolsVersion: toolsVersion)
        let c = Package.Manifest(name: "swift-bar", toolsVersion: toolsVersion)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Target.Dependency

extension `SPM Standard Tests`.Unit {
    @Test
    func `Target.Dependency.product carries name and package`() {
        let dependency: Target.Dependency = .product(name: "Bar", package: "swift-bar")
        guard case .product(let name, let package) = dependency else {
            Issue.record("expected .product case")
            return
        }
        #expect(name == "Bar")
        #expect(package == "swift-bar")
    }

    @Test
    func `Target.Dependency.target carries name`() {
        let dependency: Target.Dependency = .target(name: "OtherTarget")
        guard case .target(let name) = dependency else {
            Issue.record("expected .target case")
            return
        }
        #expect(name == "OtherTarget")
    }

    @Test
    func `Target.Dependency.byName carries literal string`() {
        let dependency: Target.Dependency = .byName("LooseLiteralForm")
        guard case .byName(let literal) = dependency else {
            Issue.record("expected .byName case")
            return
        }
        #expect(literal == "LooseLiteralForm")
    }

    @Test
    func `Target.Dependency cases differ via equality`() {
        let viaProduct: Target.Dependency = .product(name: "Foo", package: "swift-foo")
        let viaTarget: Target.Dependency = .target(name: "Foo")
        let viaByName: Target.Dependency = .byName("Foo")
        #expect(viaProduct != viaTarget)
        #expect(viaTarget != viaByName)
        #expect(viaProduct != viaByName)
    }
}
