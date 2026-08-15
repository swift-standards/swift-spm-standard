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

extension Target {
    /// The kind of a SwiftPM target.
    ///
    /// Mirrors the SwiftPM `PackageDescription.Target` factories
    /// and the `type` field emitted by `swift package dump-package`:
    ///
    /// ```
    /// "type": "regular"     // .target(...)
    /// "type": "executable"  // .executableTarget(...)
    /// "type": "test"        // .testTarget(...)
    /// "type": "plugin"      // .plugin(...)
    /// "type": "binary"      // .binaryTarget(...)
    /// "type": "system"      // .systemLibrary(...)
    /// "type": "macro"       // .macro(...)
    /// ```
    ///
    /// The `String` raw value matches the wire-format token verbatim
    /// (lowercase) so synthesised Codable handles both directions.
    public enum Kind: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {
        /// `.target(name:, ...)` — the default, builds a library
        /// module compiled into the consuming product.
        case regular

        /// `.executableTarget(name:, ...)` — builds an executable
        /// binary; bound by an `executable` product.
        case executable

        /// `.testTarget(name:, ...)` — runs under `swift test`.
        case test

        /// `.plugin(name:, capability:, ...)` — a SwiftPM build /
        /// command plugin.
        case plugin

        /// `.binaryTarget(name:, ...)` — pre-built binary artifact
        /// (XCFramework, zip, and similar).
        case binary

        /// `.systemLibrary(name:, ...)` — wraps a system-installed
        /// C library (modulemap-driven).
        case system

        /// `.macro(name:, ...)` — Swift macro implementation
        /// (compiler plugin).
        case macro
    }
}
