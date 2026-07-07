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

/// A SwiftPM-supported platform.
///
/// Mirrors `PackageDescription.Platform` — the set of OSes the
/// SwiftPM `platforms:` clause can name. Values:
///
/// ```swift
/// platforms: [
///     .macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26),
///     .visionOS(.v2), .macCatalyst(.v18), .driverKit(.v23),
///     .linux, .android(.v34), .windows, .wasi,
///     .freeBSD, .openBSD,
/// ]
/// ```
///
/// **Wire-format tokens are lowercase** in `swift package
/// dump-package` output (`"macos"`, `"ios"`, `"watchos"`, ...). The
/// raw value of each case carries the lowercase token so
/// synthesised Codable handles both directions; the case
/// identifier matches the camelCase form Apple's
/// `PackageDescription` uses.
///
/// Extends additively when SwiftPM extends. Refresh cadence:
/// re-check on each Swift toolchain bump per the L1/L2 split
/// research doc, Open Question 4.
public enum Platform: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {
  case macOS = "macos"
  case iOS = "ios"
  case tvOS = "tvos"
  case watchOS = "watchos"
  case visionOS = "visionos"
  case macCatalyst = "maccatalyst"
  case driverKit = "driverkit"
  case linux = "linux"
  case android = "android"
  case windows = "windows"
  case wasi = "wasi"
  case freeBSD = "freebsd"
  case openBSD = "openbsd"
}
