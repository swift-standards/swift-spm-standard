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
  /// The typed version-requirement variants SwiftPM's
  /// `Package.swift` accepts in a `.package(url:...)` or
  /// `.package(id:...)` clause.
  ///
  /// Mirrors PackageDescription's requirement enum exactly:
  ///
  /// | Case | PackageDescription clause |
  /// |---|---|
  /// | ``from(_:)`` | `.package(url:..., from: "X.Y.Z")` |
  /// | ``upToNextMajor(from:)`` | `.upToNextMajor(from: "X.Y.Z")` |
  /// | ``upToNextMinor(from:)`` | `.upToNextMinor(from: "X.Y.Z")` |
  /// | ``range(_:)`` | half-open `"lo"..<"hi"` |
  /// | ``exact(_:)`` | `.exact("X.Y.Z")` |
  /// | ``branch(_:)`` | `.package(url:..., branch: "...")` |
  /// | ``revision(_:)`` | `.package(url:..., revision: "...")` |
  ///
  /// The version-bearing cases carry typed
  /// ``Version/Semantic`` values; the range case carries a
  /// typed ``Version/Range`` over semantic versions. The
  /// branch / revision cases carry raw strings — they identify
  /// git refs that SwiftPM does not parse further.
  public enum Requirement: Swift.Sendable, Swift.Hashable {
    /// `.package(url:..., from: "X.Y.Z")` — pin to a minimum
    /// version with up-to-next-major semantics implied.
    case from(Version.Semantic)

    /// `.upToNextMajor(from: "X.Y.Z")` — explicit form of
    /// `from:` semantics.
    case upToNextMajor(from: Version.Semantic)

    /// `.upToNextMinor(from: "X.Y.Z")` — pin within the same
    /// minor.
    case upToNextMinor(from: Version.Semantic)

    /// Half-open semantic range: `"lo"..<"hi"`.
    case range(Version.Range<Version.Semantic>)

    /// `.exact("X.Y.Z")` — pin to a single version.
    case exact(Version.Semantic)

    /// `.package(url:..., branch: "...")` — track a git branch
    /// ref. The associated string is the branch name as
    /// written in the consumer's `Package.swift`.
    case branch(Swift.String)

    /// `.package(url:..., revision: "...")` — pin to a git
    /// revision (commit SHA, tag). The associated string is
    /// the revision as written in the consumer's
    /// `Package.swift`.
    case revision(Swift.String)
  }
}
