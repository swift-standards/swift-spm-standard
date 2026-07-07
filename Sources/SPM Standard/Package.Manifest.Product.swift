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

// Shadow-resolution per the L1/L2 split research doc (2026-05-14
// "Approved", Wave 1A): inside `extension Package.Manifest`, the
// unqualified name `Product` rebinds to the inner struct, so
// `Product.Name` does NOT resolve to the outer L1 namespace. The
// field types are written module-qualified —
// `Package_Primitives.Product.Name`,
// `Package_Primitives.Product.Kind`,
// `Package_Primitives.Target.Name` — to bypass the shadow without
// renaming the nested struct. (Typealias-based resolutions fail
// because Swift access control rejects a `private` / `internal`
// typealias appearing in a public declaration.)
//
// `Product.Kind` (declared at this L2 layer) lives on
// `Package_Primitives.Product` via cross-module extension, so the
// module-qualified path also resolves to the L2 nested type.

extension Package.Manifest {
  /// A typed Swift package product description — one element of
  /// the `products[]` array a SwiftPM `Package.swift` declares.
  ///
  /// Mirrors `PackageDescription.Product` factories:
  ///
  /// ```swift
  /// .library(name: "X", type: .static, targets: [...])
  /// .executable(name: "X", targets: [...])
  /// .plugin(name: "X", capability: ..., targets: [...])
  /// ```
  ///
  /// Carries the typed product ``Product/Name``, the
  /// ``Product/Kind`` (with library link kind preserved), and
  /// the typed ``Target/Name`` list the product compiles
  /// against.
  ///
  /// Nested under ``Package/Manifest`` because the description
  /// is meaningful only as part of a manifest. The standalone
  /// L1 ``Product`` namespace owns the universal `Product.Name`
  /// identifier; this nested type owns the SwiftPM-specific
  /// description shape.
  public struct Product: Swift.Sendable, Swift.Hashable {
    /// The product name — the value of the
    /// `.library(name:)` / `.executable(name:)` /
    /// `.plugin(name:)` field in `Package.swift`.
    public let name: Package_Primitives.Product.Name

    /// The product kind — library / executable / plugin —
    /// with library link kind preserved for the library arm.
    public let kind: Package_Primitives.Product.Kind

    /// The targets the product compiles against — the
    /// `targets:` argument of the corresponding factory.
    public let targets: [Package_Primitives.Target.Name]

    public init(
      name: Package_Primitives.Product.Name,
      kind: Package_Primitives.Product.Kind,
      targets: [Package_Primitives.Target.Name]
    ) {
      self.name = name
      self.kind = kind
      self.targets = targets
    }
  }
}
