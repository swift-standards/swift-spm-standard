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

extension Package {
  /// A SwiftPM package's typed manifest — the structural data
  /// `swift package dump-package` emits as JSON, modeled as a
  /// pure-data record.
  ///
  /// Mirrors the SwiftPM `PackageDescription` DSL surface.
  ///
  /// Consumers (graph builders, audit tools, release-readiness
  /// checks, version-bump propagation) read `Package.Manifest`
  /// values instead of re-parsing `Package.swift` themselves.
  ///
  /// Loading a manifest from disk is a Foundation concern
  /// (subprocess invocation + JSON decode) and lives outside
  /// swift-spm-standard — typically in `swift-package-graph` or
  /// a future `swift-package-manager` foundation per the
  /// L1/L2 split research doc.
  ///
  /// v0.3 surface (this revision): in addition to ``name``,
  /// ``toolsVersion``, ``dependencies`` (the v0.2 minimum for
  /// reverse-dependency graph construction), the manifest now
  /// carries ``products``, ``targets``, and ``platforms`` per
  /// the L1/L2 split research doc Q4 (status: APPROVED,
  /// 2026-05-14).
  ///
  /// The structural-naming question raised in v0.2 — that
  /// nesting `extension Package.Manifest { struct Product ... }`
  /// shadows the top-level ``Product`` namespace — is resolved
  /// via a per-file `private typealias` to the outer namespaces
  /// (one isolated alias per shadow-bearing file). The public
  /// surface continues to read `Product.Name`, `Product.Kind`,
  /// `Target.Name`, `Target.Kind`, `Target.Dependency` without
  /// rename suffixes.
  ///
  /// Per-target settings, resources, plugin usages, swift /
  /// C / C++ language modes, and registry-form package kinds
  /// are deferred to later additive versions.
  public struct Manifest: Swift.Sendable, Swift.Hashable {
    /// The package's name — the value of the `Package(name:)`
    /// field in `Package.swift`. Tagged for cross-package
    /// product binding.
    public let name: Package.Name

    /// The swift-tools-version declared by the leading
    /// `// swift-tools-version:` comment in `Package.swift`.
    public let toolsVersion: Version.Tools

    /// The package's declared dependencies — one element per
    /// `.package(...)` clause in the consumer's `Package.swift`.
    public let dependencies: [Package.Dependency]

    /// The package's declared products — one element per
    /// `.library` / `.executable` / `.plugin` factory in the
    /// `products:` argument of `Package(...)`.
    public let products: [Manifest.Product]

    /// The package's declared targets — one element per
    /// `.target` / `.executableTarget` / `.testTarget` / and similar.
    ///
    /// factory in the `targets:` argument of `Package(...)`.
    public let targets: [Manifest.Target]

    /// The package's declared supported platforms — one
    /// element per entry in the `platforms:` argument of
    /// `Package(...)`. `nil` when the manifest did not
    /// declare a `platforms:` clause (SwiftPM falls back to
    /// platform defaults).
    public let platforms: [SupportedPlatform]?

    public init(
      name: Package.Name,
      toolsVersion: Version.Tools,
      dependencies: [Package.Dependency] = [],
      products: [Manifest.Product] = [],
      targets: [Manifest.Target] = [],
      platforms: [SupportedPlatform]? = nil
    ) {
      self.name = name
      self.toolsVersion = toolsVersion
      self.dependencies = dependencies
      self.products = products
      self.targets = targets
      self.platforms = platforms
    }
  }
}
