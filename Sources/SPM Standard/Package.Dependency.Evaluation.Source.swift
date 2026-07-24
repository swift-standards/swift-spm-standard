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

extension Package.Dependency.Evaluation {
  /// The evaluated dependency kind together with exactly the facts that kind
  /// carries.
  ///
  /// This is the evaluation-side counterpart of ``Package/Dependency/Source``,
  /// which models the portable *declaration*. The two are deliberately
  /// separate types: under an active mirror a URL declaration evaluates to a
  /// filesystem location, and the declared URL survives nowhere in the output.
  ///
  /// **Invalid combinations are unrepresentable.** The requirement lives
  /// inside the cases that have one, so a filesystem dependency cannot carry a
  /// requirement and a source-control or registry dependency cannot lack one.
  /// Registry stores only its ``Package/Identity``; the emitted `scope.name`
  /// token is *derived* from it by ``identity``, so the two cannot disagree.
  public enum Source: Swift.Sendable, Swift.Hashable {
    /// A filesystem dependency — what a `.package(path:)` declaration
    /// evaluates to. Carries no requirement, because the wire emits none.
    case fileSystem(identity: Package.Dependency.Evaluation.Identity, path: Swift.String)

    /// A source-control dependency, reported either remotely or — after
    /// mirror substitution — locally. Always carries a requirement.
    case sourceControl(
      identity: Package.Dependency.Evaluation.Identity,
      location: Location,
      requirement: Package.Requirement
    )

    /// A registry dependency per SE-0292. The associated identity is the
    /// `scope.name` composite — the one evaluated kind whose emitted token
    /// genuinely is a ``Package/Identity``. Always carries a requirement.
    case registry(identity: Package.Identity, requirement: Package.Requirement)
  }
}

// [API-IMPL-008]: projections live in an extension, not the type body.

extension Package.Dependency.Evaluation.Source {
    /// The identity token SwiftPM emitted, from a single source of truth.
    ///
    /// For filesystem and source-control dependencies this is the stored
    /// opaque token. For registry dependencies it is *derived* from the stored
    /// ``Package/Identity`` as `"\(scope).\(name)"`, which is exactly the
    /// spelling SwiftPM emits — so no hand-constructed value can hold a token
    /// that disagrees with its parsed identity.
    public var identity: Package.Dependency.Evaluation.Identity {
      switch self {
      case .fileSystem(let identity, _): identity
      case .sourceControl(let identity, _, _): identity
      case .registry(let identity, _): .init("\(identity.scope).\(identity.name)")
      }
    }

    /// The dependency requirement, or `nil` for a filesystem dependency.
    ///
    /// This is a projection, not storage: the requirement is held by the cases
    /// that carry one.
    public var requirement: Package.Requirement? {
      switch self {
      case .fileSystem: nil
      case .sourceControl(_, _, let requirement): requirement
      case .registry(_, let requirement): requirement
      }
    }
}
