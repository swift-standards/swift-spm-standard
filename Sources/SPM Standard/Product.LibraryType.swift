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
  /// The link kind of a SwiftPM library product.
  ///
  /// Mirrors the second positional argument of
  /// `PackageDescription.Product.library(name:type:targets:)`:
  ///
  /// ```swift
  /// .library(name: "X", type: .static,    targets: [...])
  /// .library(name: "X", type: .dynamic,   targets: [...])
  /// .library(name: "X",                   targets: [...])  // .automatic
  /// ```
  ///
  /// On the `swift package dump-package` wire, the value appears
  /// as a single-element string array under the `library` key:
  /// `{"library": ["static" | "dynamic" | "automatic"]}`.
  public enum LibraryType: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {
    /// Static library — `.library(name:, type: .static, targets:)`.
    case `static`

    /// Dynamic library — `.library(name:, type: .dynamic, targets:)`.
    case `dynamic`

    /// SwiftPM-chosen link kind — `.library(name:, targets:)` with
    /// no explicit `type:` argument. SwiftPM picks static or dynamic
    /// based on the consuming product graph.
    case automatic
  }
}
