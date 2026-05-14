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
// swiftlint:disable no_foundation_import_warning typed_throws_required
import Foundation
import Testing
@testable import SPM_Standard

@Suite
struct `SPM Standard Tests` {
    @Suite struct Unit {}
    @Suite struct `Codable Round-Trip` {}
}

// MARK: - Codable round-trips

extension `SPM Standard Tests`.`Codable Round-Trip` {
    @Test
    func `Package.Identity round-trips through JSON`() throws {
        let identity = Package.Identity(scope: "apple", name: "swift-argument-parser")
        let encoded = try JSONEncoder().encode(identity)
        let decoded = try JSONDecoder().decode(Package.Identity.self, from: encoded)
        #expect(decoded == identity)
    }

    @Test
    func `Package.Requirement.from round-trips through JSON`() throws {
        let requirement: Package.Requirement = .from("1.5.0")
        let encoded = try JSONEncoder().encode(requirement)
        let decoded = try JSONDecoder().decode(Package.Requirement.self, from: encoded)
        #expect(decoded == requirement)
    }

    @Test
    func `Package.Requirement.range round-trips through JSON`() throws {
        let requirement: Package.Requirement = "602.0.0"..<"603.0.0"
        let encoded = try JSONEncoder().encode(requirement)
        let decoded = try JSONDecoder().decode(Package.Requirement.self, from: encoded)
        #expect(decoded == requirement)
    }

    @Test
    func `Package.Requirement.exact round-trips through JSON`() throws {
        let requirement: Package.Requirement = .exact("1.0.0")
        let encoded = try JSONEncoder().encode(requirement)
        let decoded = try JSONDecoder().decode(Package.Requirement.self, from: encoded)
        #expect(decoded == requirement)
    }

    @Test
    func `Package.Requirement.branch round-trips through JSON`() throws {
        let requirement = Package.Requirement.branch("main")
        let encoded = try JSONEncoder().encode(requirement)
        let decoded = try JSONDecoder().decode(Package.Requirement.self, from: encoded)
        #expect(decoded == requirement)
    }

    @Test
    func `Package.Requirement.revision round-trips through JSON`() throws {
        let requirement = Package.Requirement.revision("abc123")
        let encoded = try JSONEncoder().encode(requirement)
        let decoded = try JSONDecoder().decode(Package.Requirement.self, from: encoded)
        #expect(decoded == requirement)
    }

    @Test
    func `Package.Dependency path-form round-trips through JSON`() throws {
        let dependency = Package.Dependency(
            source: .path("../../swift-primitives/swift-package-primitives"),
            name: "swift-package-primitives",
            products: ["Package Primitives"]
        )
        let encoded = try JSONEncoder().encode(dependency)
        let decoded = try JSONDecoder().decode(Package.Dependency.self, from: encoded)
        #expect(decoded == dependency)
    }

    @Test
    func `Package.Dependency url-form with from round-trips through JSON`() throws {
        let dependency = Package.Dependency(
            source: .url(
                "https://github.com/apple/swift-argument-parser.git",
                from: "1.5.0"
            ),
            name: "swift-argument-parser",
            products: ["ArgumentParser"]
        )
        let encoded = try JSONEncoder().encode(dependency)
        let decoded = try JSONDecoder().decode(Package.Dependency.self, from: encoded)
        #expect(decoded == dependency)
    }

    @Test
    func `Package.Dependency registry-form round-trips through JSON`() throws {
        let dependency = Package.Dependency(
            source: .registry(
                Package.Identity(scope: "apple", name: "swift-argument-parser"),
                from: "1.5.0"
            ),
            name: "swift-argument-parser",
            products: ["ArgumentParser"]
        )
        let encoded = try JSONEncoder().encode(dependency)
        let decoded = try JSONDecoder().decode(Package.Dependency.self, from: encoded)
        #expect(decoded == dependency)
    }
}

// MARK: - Unit

extension `SPM Standard Tests`.Unit {
    @Test
    func `Package.Identity has scope and name`() {
        let identity = Package.Identity(scope: "apple", name: "swift-argument-parser")
        #expect(identity.scope == "apple")
        #expect(identity.name == "swift-argument-parser")
    }

    @Test
    func `Package.Dependency.Source path carries literal string`() {
        let source = Package.Dependency.Source.path("/tmp/swift-foo")
        switch source {
        case .path(let path):
            #expect(path == "/tmp/swift-foo")
        default:
            Issue.record("expected .path case")
        }
    }
}
