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

extension Package.Dependency {
    /// One dependency as SwiftPM reported it while evaluating a manifest.
    ///
    /// This is **not** ``Package/Dependency``. ``Package/Dependency`` and its
    /// ``Package/Dependency/Source`` model the portable *declaration* — the
    /// three forms a `Package.swift` can write. An evaluation is what the
    /// installed SwiftPM printed after normalising that declaration and applying
    /// this machine's configuration, and the two can disagree: under an active
    /// mirror a URL declaration evaluates to a filesystem location, and the
    /// declared URL does not survive anywhere in the output.
    ///
    /// It is also not a *resolution*. Nothing here describes a checkout, a
    /// pinned revision, or the source tree a build compiles.
    ///
    /// JSON shape — one element of the `dependencies[]` array:
    ///
    /// ```
    /// {
    ///   "sourceControl": [ {
    ///     "identity": "swift-paths",
    ///     "location": { "local": [ "/fixture/checkouts/swift-paths" ] },
    ///     "productFilter": null,
    ///     "requirement": { "branch": [ "main" ] },
    ///     "traits": [ { "name": "default" } ]
    ///   } ]
    /// }
    /// ```
    ///
    /// `productFilter` is decoded and discarded. Its authoritative encoding is
    /// `null` for `ProductFilter.everything` and a sorted `[String]` for
    /// `.specific` (SwiftPM `Sources/PackageModel/Product.swift`,
    /// `swift-6.3.3-RELEASE`) — so `null` is a *meaningful case*, not an absent
    /// value. Nothing in this layer consumes resolver product requests, and
    /// modelling that two-case semantics is deferred rather than guessed.
    public struct Evaluation: Swift.Sendable, Swift.Hashable {
        /// The evaluated kind, with exactly the facts that kind carries.
        public let source: Source

        /// Product names consuming targets reference from this dependency.
        ///
        /// The wire does not carry this on the dependency record; it lives in
        /// `targets[].dependencies[]`. ``Package/Manifest/Evaluation`` back-fills
        /// it after decoding both arrays. Empty when no target references it.
        public let products: [Product.Name]

        /// The per-dependency `traits` array, preserved as emitted.
        public let traits: [Trait]

        public init(
            source: Source,
            products: [Product.Name] = [],
            traits: [Trait] = []
        ) {
            self.source = source
            self.products = products
            self.traits = traits
        }
    }
}

// [API-IMPL-008]: projections live in an extension, not the type body.

extension Package.Dependency.Evaluation {
    /// The identity token SwiftPM emitted. See ``Source/identity``.
    public var identity: Identity { source.identity }

    /// The dependency requirement, or `nil` for a filesystem dependency.
    /// See ``Source/requirement``.
    public var requirement: Package.Requirement? { source.requirement }
}
