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

// Codable conformance is excluded from Embedded Swift — `Codable`
// depends on stdlib protocols and runtime infrastructure that the
// Embedded mode does not ship.
//
// Wire-format shape — single-key discriminated union, where each
// arm is a JSON array. `swift package dump-package` emits:
//
// ```
// {"product": ["productName", "packageIdentity", condition|null, traits|null]}
// {"target":  ["targetName",  condition|null]}
// {"byName":  ["name",        condition|null]}
// ```
//
// The trailing `condition` (per-platform / config gating) and
// `traits` (SE-0450 trait gating) tuple slots are currently
// decoded-and-discarded — v0.3 surfaces only the name + package
// fields. Trait + condition surfaces can be added additively in
// later revisions.

#if !hasFeature(Embedded)
  extension Target.Dependency: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
      case product
      case target
      case byName
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if container.contains(.product) {
        var arm = try container.nestedUnkeyedContainer(forKey: .product)
        let productName = try arm.decode(Swift.String.self)
        let packageName = try arm.decode(Swift.String.self)
        // Remaining slots (condition, traits) are
        // intentionally not decoded; ignore-extras strategy.
        self = .product(
          name: Product.Name(_unchecked: productName),
          package: Package.Name(_unchecked: packageName)
        )
        return
      }
      if container.contains(.target) {
        var arm = try container.nestedUnkeyedContainer(forKey: .target)
        let name = try arm.decode(Swift.String.self)
        self = .target(name: Target.Name(_unchecked: name))
        return
      }
      if container.contains(.byName) {
        var arm = try container.nestedUnkeyedContainer(forKey: .byName)
        let name = try arm.decode(Swift.String.self)
        self = .byName(name)
        return
      }
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Target dependency matched none of product/target/byName"
        )
      )
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .product(let name, let package):
        var arm = container.nestedUnkeyedContainer(forKey: .product)
        try arm.encode(name.underlying)
        try arm.encode(package.underlying)
        // Emit `null` for the condition and traits slots
        // to match the dump-package wire shape verbatim.
        try arm.encodeNil()
        try arm.encodeNil()
      case .target(let name):
        var arm = container.nestedUnkeyedContainer(forKey: .target)
        try arm.encode(name.underlying)
        try arm.encodeNil()
      case .byName(let name):
        var arm = container.nestedUnkeyedContainer(forKey: .byName)
        try arm.encode(name)
        try arm.encodeNil()
      }
    }
  }
#endif
