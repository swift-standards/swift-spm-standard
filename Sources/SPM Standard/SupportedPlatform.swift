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

/// One element of a SwiftPM `platforms:` clause — a platform with
/// a minimum-deployment version.
///
/// Mirrors `PackageDescription.SupportedPlatform`:
///
/// ```swift
/// platforms: [
///     .macOS(.v26),  .iOS(.v26),  .tvOS(.v26),  .watchOS(.v26)
/// ]
/// ```
///
/// On the `swift package dump-package` wire each element is:
///
/// ```
/// {"options": [], "platformName": "macos", "version": "26.0"}
/// ```
///
/// The `version` field is preserved as a literal `String` because
/// SwiftPM emits raw strings (`"26.0"`, not a structured semantic
/// version). Consumers needing typed comparison parse it via
/// `Version.Semantic` or platform-specific predicates themselves.
public struct SupportedPlatform: Swift.Sendable, Swift.Hashable {
    /// The platform — typed via the SwiftPM-mirrored ``Platform``
    /// enum.
    public let platform: Platform

    /// The minimum deployment version as the literal string
    /// SwiftPM emits (e.g. `"26.0"`).
    public let version: Swift.String

    public init(platform: Platform, version: Swift.String) {
        self.platform = platform
        self.version = version
    }
}
