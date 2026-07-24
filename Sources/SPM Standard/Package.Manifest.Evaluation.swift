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

extension Package.Manifest {
  /// A whole `swift package dump-package` evaluation.
  ///
  /// ``Package/Manifest`` models the manifest a developer wrote; this models
  /// what the installed SwiftPM printed when it evaluated that manifest on a
  /// particular machine. The distinction is load-bearing rather than
  /// pedantic: with a mirror configured, the evaluation's dependency
  /// locations are paths the manifest never mentioned, so a value decoded
  /// from this wire cannot honestly be presented as the declaration.
  ///
  /// The manifest-level fields — name, tools version, products, targets,
  /// platforms — are unaffected by machine configuration and reuse the
  /// existing ``Package/Manifest`` nested values rather than duplicating
  /// them. Only ``dependencies`` differs, because only dependencies are
  /// rewritten during evaluation.
  public struct Evaluation: Swift.Sendable, Swift.Hashable {
    /// The package's `Package(name:)` field.
    public let name: Package.Name

    /// The declared `swift-tools-version`.
    public let toolsVersion: Version.Tools

    /// Dependencies as evaluated. See ``Package/Dependency/Evaluation``.
    public let dependencies: [Package.Dependency.Evaluation]

    /// Declared products, reusing ``Package/Manifest/Product``.
    public let products: [Package.Manifest.Product]

    /// Declared targets, reusing ``Package/Manifest/Target``.
    public let targets: [Package.Manifest.Target]

    /// Declared platforms, reusing ``SupportedPlatform``. `nil` when the
    /// manifest declares none.
    public let platforms: [SupportedPlatform]?

    public init(
      name: Package.Name,
      toolsVersion: Version.Tools,
      dependencies: [Package.Dependency.Evaluation] = [],
      products: [Package.Manifest.Product] = [],
      targets: [Package.Manifest.Target] = [],
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
