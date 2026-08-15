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
    /// A typed Swift package dependency declaration.
    ///
    /// Represents a single `.package(...)` clause from a SwiftPM
    /// `Package.swift` manifest: a ``Source`` (path / url with
    /// `Requirement` / registry-form identity with `Requirement`)
    /// plus the typed ``Name`` and the typed
    /// ``Product/Name`` list a consuming target depends on.
    ///
    /// SwiftPM-flavored — owns the wire-format representation of
    /// SwiftPM's `.package(...)` clause. Consumers needing a
    /// cross-ecosystem dependency abstraction stay at L1
    /// `Package_Primitives` (which owns the universal typed
    /// identifiers).
    public struct Dependency: Swift.Sendable, Swift.Hashable {
        /// The SwiftPM package source shape.
        ///
        /// Three variants matching the SwiftPM `Package.swift`
        /// dependency forms:
        ///
        /// - ``path(_:)`` — `.package(path: "...")` for sibling-disk
        ///   dependencies.
        ///
        /// - ``url(_:_:)`` — `.package(url: "...", ...)` for
        ///   git-URL dependencies with a ``Requirement`` constraint.
        ///
        /// - ``registry(_:_:)`` — registry-form dependencies per
        ///   SE-0292, with a ``Package/Identity`` and a
        ///   ``Requirement`` constraint.
        public enum Source: Swift.Sendable, Swift.Hashable {
            /// Path-form: `.package(path: "...")`. The associated
            /// value is SwiftPM's path string. Validation, resolution, and
            /// rewriting from a particular filesystem vantage belong to an
            /// operational foundation.
            case path(Swift.String)

            /// URL-form with a typed version constraint:
            /// `.package(url: "...", ...)`. The URL is the typed
            /// ``URI`` per RFC 3986; the requirement is the typed
            /// shape per ``Package/Requirement``.
            case url(URI, Package.Requirement)

            /// Registry-form per SE-0292:
            /// `.package(id: "scope.name", ...)`. The identity is
            /// the typed registry scope.name composite per
            /// ``Package/Identity``; the requirement is the typed
            /// shape per ``Package/Requirement``.
            case registry(Package.Identity, Package.Requirement)
        }

        /// The dependency's source.
        public let source: Source

        /// The SwiftPM package name — the value of the dependency
        /// package's `Package(name:)` field.
        ///
        /// For path-form and url-form dependencies the consumer
        /// typically does not write the name in the `.package(...)`
        /// clause; it is derived from the package at that path or
        /// URL. Tools that emit `.product(name:package:)` references
        /// need this typed name to bind product to package.
        public let name: Package.Name

        /// The typed product names this dependency exposes to the
        /// consuming target. One `.product(name:package:)` entry is
        /// emitted per element when materializing a target's
        /// `dependencies:` list.
        public let products: [Product.Name]

        public init(source: Source, name: Package.Name, products: [Product.Name]) {
            self.source = source
            self.name = name
            self.products = products
        }
    }
}
