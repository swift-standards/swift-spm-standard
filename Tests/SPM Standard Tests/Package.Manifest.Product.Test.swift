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

// MARK: - Package.Manifest.Product round-trips

extension `SPM Standard Tests`.`Codable Round-Trip` {
  @Test
  func `Manifest.Product library(automatic) round-trips through JSON`() throws {
    let product = Package.Manifest.Product(
      name: "SPM Standard",
      kind: .library(.automatic),
      targets: ["SPM Standard"]
    )
    let encoded = try JSONEncoder().encode(product)
    let decoded = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: encoded
    )
    #expect(decoded == product)
  }

  @Test
  func `Manifest.Product library(static) round-trips through JSON`() throws {
    let product = Package.Manifest.Product(
      name: "Static Lib",
      kind: .library(.static),
      targets: ["Static Lib"]
    )
    let encoded = try JSONEncoder().encode(product)
    let decoded = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: encoded
    )
    #expect(decoded == product)
  }

  @Test
  func `Manifest.Product library(dynamic) round-trips through JSON`() throws {
    let product = Package.Manifest.Product(
      name: "Dynamic Lib",
      kind: .library(.dynamic),
      targets: ["Dynamic Lib"]
    )
    let encoded = try JSONEncoder().encode(product)
    let decoded = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: encoded
    )
    #expect(decoded == product)
  }

  @Test
  func `Manifest.Product executable round-trips through JSON`() throws {
    let product = Package.Manifest.Product(
      name: "swift-linter",
      kind: .executable,
      targets: ["Linter CLI"]
    )
    let encoded = try JSONEncoder().encode(product)
    let decoded = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: encoded
    )
    #expect(decoded == product)
  }

  @Test
  func `Manifest.Product plugin round-trips through JSON`() throws {
    let product = Package.Manifest.Product(
      name: "Build Plugin",
      kind: .plugin,
      targets: ["Build Plugin Impl"]
    )
    let encoded = try JSONEncoder().encode(product)
    let decoded = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: encoded
    )
    #expect(decoded == product)
  }

  @Test
  func `Manifest.Product decodes dump-package library(automatic) wire shape`() throws {
    let json = """
      {
        "name": "SPM Standard",
        "settings": [],
        "targets": ["SPM Standard"],
        "type": {"library": ["automatic"]}
      }
      """
    let data = try #require(json.data(using: .utf8))
    let product = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: data
    )
    #expect(product.name == "SPM Standard")
    #expect(product.targets == ["SPM Standard"])
    guard case .library(let linkKind) = product.kind else {
      Issue.record("expected .library kind")
      return
    }
    #expect(linkKind == .automatic)
  }

  @Test
  func `Manifest.Product decodes dump-package executable wire shape`() throws {
    let json = """
      {
        "name": "swift-linter",
        "settings": [],
        "targets": ["Linter CLI"],
        "type": {"executable": null}
      }
      """
    let data = try #require(json.data(using: .utf8))
    let product = try JSONDecoder().decode(
      Package.Manifest.Product.self, from: data
    )
    #expect(product.name == "swift-linter")
    #expect(product.kind == .executable)
  }
}
