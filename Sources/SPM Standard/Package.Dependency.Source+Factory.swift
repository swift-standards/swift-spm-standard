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

// Labeled static factory overloads that mirror PackageDescription's
// labeled `.package(url:...)` and `.package(id:...)` call-site shape.
// Each factory wraps the corresponding `Package.Requirement` variant
// inside the existing `.url(_:_:)` / `.registry(_:_:)` case, so the
// case payload stays a typed `Package.Requirement` (pattern matching
// and Codable shape unchanged) while consumers can write the
// PackageDescription form directly:
//
//     .url("https://…", from: "1.5.0")             // .from(…)
//     .url("https://…", "1.0.0"..<"2.0.0")         // .range — via `..<` overload on Package.Requirement
//     .url("https://…", exact: "1.5.0")            // .exact(…)
//     .url("https://…", branch: "main")            // .branch(…)
//     .url("https://…", revision: "abc123")        // .revision(…)
//
// The positional half-open range form does NOT have a Swift.Range-
// taking factory here — it's served by the `..<` overload on
// `Package.Requirement` (see `Package.Requirement+Factory.swift`).
// Two overloads of `.url(_, _)` accepting both `Swift.Range` and
// `Package.Requirement` for the same literal would create ambiguity
// at the call site; the operator path is the single resolution.

extension Package.Dependency.Source {

  // MARK: - URL form

  /// `.package(url: "…", from: "X.Y.Z")` form.
  @inlinable
  public static func url(
    _ url: URI,
    from version: Version.Semantic
  ) -> Self {
    .url(url, .from(version))
  }

  /// `.package(url: "…", exact: "X.Y.Z")` form.
  @inlinable
  public static func url(
    _ url: URI,
    exact version: Version.Semantic
  ) -> Self {
    .url(url, .exact(version))
  }

  /// `.package(url: "…", branch: "…")` form.
  @inlinable
  public static func url(
    _ url: URI,
    branch: Swift.String
  ) -> Self {
    .url(url, .branch(branch))
  }

  /// `.package(url: "…", revision: "…")` form.
  @inlinable
  public static func url(
    _ url: URI,
    revision: Swift.String
  ) -> Self {
    .url(url, .revision(revision))
  }

  // MARK: - Registry form (SE-0292)

  /// `.package(id: "scope.name", from: "X.Y.Z")` form.
  @inlinable
  public static func registry(
    _ identity: Package.Identity,
    from version: Version.Semantic
  ) -> Self {
    .registry(identity, .from(version))
  }

  /// `.package(id: "scope.name", exact: "X.Y.Z")` form. Registry-form
  /// deps do not support `branch:` or `revision:` constraints in
  /// SwiftPM's PackageDescription; only the four version-bearing
  /// requirements (`from`, `upToNextMajor`, `upToNextMinor`,
  /// `range`, `exact`) apply. The two `from`-family `Requirement`
  /// constructors remain accessible via the existing case form
  /// `.registry(identity, .upToNextMajor(from: …))`.
  @inlinable
  public static func registry(
    _ identity: Package.Identity,
    exact version: Version.Semantic
  ) -> Self {
    .registry(identity, .exact(version))
  }
}
