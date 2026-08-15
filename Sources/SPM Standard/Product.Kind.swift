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

extension Product {
    /// The kind of a SwiftPM product.
    ///
    /// Mirrors the three SwiftPM `PackageDescription.Product`
    /// factories:
    ///
    /// ```swift
    /// .library(name: "X", type: .static, targets: [...])
    /// .executable(name: "X", targets: [...])
    /// .plugin(name: "X", capability: ..., targets: [...])
    /// ```
    ///
    /// On the `swift package dump-package` wire, the value appears
    /// under the `type` field of a product entry:
    ///
    /// ```
    /// {"library":    ["static" | "dynamic" | "automatic"]}
    /// {"executable": null}
    /// {"plugin":     null}
    /// ```
    ///
    /// Carries ``LibraryType`` for ``library(_:)`` so the link kind
    /// is not lost when round-tripping the wire shape.
    public enum Kind: Swift.Sendable, Swift.Hashable {
        /// `.library(name:, type:, targets:)` — carries the library
        /// link kind (`static` / `dynamic` / `automatic`).
        case library(LibraryType)

        /// `.executable(name:, targets:)`.
        case executable

        /// `.plugin(name:, capability:, targets:)`.
        case plugin
    }
}
