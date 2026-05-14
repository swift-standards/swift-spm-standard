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
    /// v0.2 surface (this revision): the minimum fields needed by
    /// `swift-package-graph` for reverse-dependency graph
    /// construction — ``name``, ``toolsVersion``, ``dependencies``.
    ///
    /// Products, targets, supported platforms, and richer
    /// per-target settings are deferred. The `[Product]` / `[Target]`
    /// surface is held back pending a structural naming decision
    /// (cf. the L1/L2 split discussion 2026-05-14): nesting an
    /// `extension Package.Manifest { struct Product ... }` shadows
    /// the top-level ``Product`` namespace from within the nested
    /// type, and the institute principle rejects rename suffixes
    /// (`ProductDescription` / `Product.Spec` etc.) as workarounds.
    /// Lands in a later revision when both (a) a consumer beyond
    /// reverse-dep needs them and (b) the structural choice is
    /// settled.
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

        public init(
            name: Package.Name,
            toolsVersion: Version.Tools,
            dependencies: [Package.Dependency] = []
        ) {
            self.name = name
            self.toolsVersion = toolsVersion
            self.dependencies = dependencies
        }
    }
}
