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
// `Codable`'s protocol requirements force existential coder
// parameters and untyped `throws`; both rules are deliberately
// exempted for this file's conformance block.
//
// Wire-format shape — mirrors `swift package dump-package`'s JSON
// output. The v0.3 surface decodes ``name``, ``toolsVersion``,
// ``dependencies``, ``products``, ``targets``, and ``platforms``.
// Other fields (`cLanguageStandard`, `cxxLanguageStandard`,
// `defaultLocalization`, `packageKind`, `pkgConfig`, `traits`,
// `swiftLanguageVersions`, ...) are decoded-and-discarded per the
// ignore-extras strategy.
//
// **Second-pass `Package.Dependency.products` back-fill**: the
// `dependencies[]` array on the dump-package wire emits each
// `Package.Dependency` without enumerating which products of that
// dependency the consumer targets actually reference — that
// information lives instead inside `targets[].dependencies[]` as
// `.product([productName, packageIdentity, ...])` entries. After
// decoding both arrays, the decoder walks the target-dependency
// edges, collects every `(packageIdentity → productName)` pair,
// and rebuilds each `Package.Dependency` with its `products` set
// populated.
//
// The wire-format shim types (``_ToolsVersionWire``,
// ``_DependencyWire``, ``_FileSystemRecord``, ``_SourceControlRecord``
// + its nested ``_Location``/``_Remote``, ``_RegistryRecord``,
// ``_RequirementWire``, ``_RangeBounds``) each live in their own
// `.swift` file per `[API-IMPL-005]`. The local parsing helpers
// (``_parseSemantic``, ``_parseIdentity``) live at the bottom of
// this file as `internal static` methods on ``Package/Manifest``.
//
// Shadow-resolution: module-qualified `Package_Primitives.Product`
// references resolve to L1's outer `Product` namespace inside
// the `_backfillProducts` helper where the unqualified `Product`
// could collide with a same-named nested type.

#if !hasFeature(Embedded)
  extension Package.Manifest: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
      case name
      case toolsVersion
      case dependencies
      case products
      case targets
      case platforms
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      // `name` decoded as bare string — `Package.Name` is
      // `Tagged<Package, String>` and Tagged's auto-synthesised
      // Codable uses a keyed container (`{"underlying": "..."}`)
      // which does not match the dump-package wire shape.
      // Use `_unchecked:` to disambiguate from the optional
      // `LosslessStringConvertible` init that the
      // `Tagged Primitives Standard Library Integration` target
      // makes available.
      let nameString = try container.decode(Swift.String.self, forKey: .name)
      let name = Package.Name(_unchecked: nameString)
      let toolsWire = try container.decode(_ToolsVersionWire.self, forKey: .toolsVersion)
      let toolsVersion: Version.Tools
      do {
        toolsVersion = try Version.Tools(parsing: toolsWire._version)
      } catch {
        throw DecodingError.dataCorruptedError(
          forKey: .toolsVersion,
          in: container,
          debugDescription: "Invalid tools-version string '\(toolsWire._version)': \(error)"
        )
      }
      let wireDependencies = try container.decode(
        [_DependencyWire].self, forKey: .dependencies
      )
      let baseDependencies = try wireDependencies.map { wire in
        try wire.toDependency()
      }
      let products =
        try container.decodeIfPresent(
          [Self.Product].self, forKey: .products
        ) ?? []
      let targets =
        try container.decodeIfPresent(
          [Self.Target].self, forKey: .targets
        ) ?? []
      let platforms = try container.decodeIfPresent(
        [SupportedPlatform].self, forKey: .platforms
      )

      // Second-pass `Package.Dependency.products` back-fill:
      // walk every target's dependency edges, collect each
      // `(packageIdentity → productName)` pair, then rebuild
      // each `Package.Dependency` with its `products` set
      // populated. Per the L1/L2 split research doc Q4 + the
      // Phase 3 follow-up arc.
      let dependencies = Self._backfillProducts(
        dependencies: baseDependencies,
        targets: targets
      )

      self.init(
        name: name,
        toolsVersion: toolsVersion,
        dependencies: dependencies,
        products: products,
        targets: targets,
        platforms: platforms
      )
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.name.underlying, forKey: .name)
      try container.encode(
        _ToolsVersionWire(_version: self.toolsVersion.description),
        forKey: .toolsVersion
      )
      let wireDependencies = self.dependencies.map { _DependencyWire(from: $0) }
      try container.encode(wireDependencies, forKey: .dependencies)
      try container.encode(self.products, forKey: .products)
      try container.encode(self.targets, forKey: .targets)
      try container.encodeIfPresent(self.platforms, forKey: .platforms)
    }
  }

  // MARK: - Local parsing helpers

  extension Package.Manifest {
    /// Parse a `"X.Y.Z"` SemVer string from a dump-package wire
    /// record into ``Version/Semantic``. Throws a
    /// `DecodingError.dataCorrupted` if the parse fails.
    internal static func _parseSemantic(
      _ string: Swift.String
    ) throws -> Version.Semantic {
      do {
        return try Version.Semantic(parsing: string)
      } catch {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: [],
            debugDescription: "Invalid semantic version '\(string)': \(error)"
          )
        )
      }
    }

    /// Parse a `"scope.name"` registry identity from a
    /// dump-package wire record into ``Package/Identity``.
    ///
    /// Throws a `DecodingError.dataCorrupted` if the format
    /// does not match SE-0292 `scope.name`.
    internal static func _parseIdentity(
      _ string: Swift.String
    ) throws -> Package.Identity {
      // Registry identity is "scope.name" per SE-0292.
      guard let dot = string.firstIndex(of: ".") else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: [],
            debugDescription: "Invalid registry identity '\(string)' — expected 'scope.name'"
          )
        )
      }
      let scope = Swift.String(string[..<dot])
      let name = Swift.String(string[string.index(after: dot)...])
      return Package.Identity(scope: scope, name: name)
    }

    /// Walk every target's `.product` dependency edge and
    /// back-fill each `Package.Dependency.products` with the
    /// product names that name the dependency's identity.
    ///
    /// The dump-package wire format emits dependencies and
    /// target-dependency edges in separate arrays:
    ///
    /// - `dependencies[]` carries the typed `Package.Dependency`
    ///   (source + name) without product references.
    ///
    /// - `targets[].dependencies[]` carries `.product([name,
    ///   packageIdentity, ...])` entries that bind a product
    ///   name to a dependency's identity.
    ///
    /// This helper bridges the two: it builds a map from
    /// dependency identity to the set of distinct product names
    /// targets reference, then replaces each input dependency
    /// with a copy whose `products` reflects that map. Product
    /// order is deterministic (first-occurrence in target order).
    internal static func _backfillProducts(
      dependencies: [Package.Dependency],
      targets: [Self.Target]
    ) -> [Package.Dependency] {
      // Build (identity-string → ordered, deduplicated
      // product-name list) by walking every `.product` edge.
      var ordered: [Swift.String: [Package_Primitives.Product.Name]] = [:]
      var seen: [Swift.String: Swift.Set<Package_Primitives.Product.Name>] = [:]
      for target in targets {
        for edge in target.dependencies {
          guard case .product(let productName, let packageName) = edge else {
            continue
          }
          let identity = packageName.underlying
          if seen[identity, default: []].insert(productName).inserted {
            ordered[identity, default: []].append(productName)
          }
        }
      }
      // Rebuild each dependency with the back-filled product
      // list (empty if the dependency is referenced by no
      // target — preserves the v0.2 behavior for that case).
      //
      // Annotate the closure's input/output explicitly so the
      // call resolves to `Array.map` rather than any
      // re-exported parser-DSL overload.
      return dependencies.map {
        (dependency: Package.Dependency) -> Package.Dependency in
        let identity = dependency.name.underlying
        guard let products = ordered[identity], !products.isEmpty else {
          return dependency
        }
        return Package.Dependency(
          source: dependency.source,
          name: dependency.name,
          products: products
        )
      }
    }
  }
#endif
