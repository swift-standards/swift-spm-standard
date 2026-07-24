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

extension Package.Resolution.Dependency {
  /// What SwiftPM produced for a dependency, with exactly the facts that
  /// outcome carries.
  ///
  /// **A sum type, not a struct of optionals.** The state name fully determines
  /// the payload, with zero exceptions across 27,003 observed records:
  ///
  /// | state | carries `path` | carries `checkoutState` |
  /// |---|---|---|
  /// | `sourceControlCheckout` | no | **yes** |
  /// | `fileSystem` | **yes** | no |
  /// | `edited` | **yes** | no |
  ///
  /// `path` and `checkoutState` are perfectly disjoint and jointly exhaustive.
  /// Modelling them as two optionals on one struct would make three
  /// unrepresentable states representable.
  ///
  /// ## Why `registryDownload` and `custom` are absent
  ///
  /// SwiftPM's own model carries both. Neither appears in any observed file, so
  /// **their JSON encoding has not been seen** — and inventing a spelling for a
  /// shape no evidence describes is exactly the fabrication this layer refuses.
  /// Decoding an unrecognised state therefore fails loudly, naming the state, so
  /// the first real instance is reported rather than silently mis-decoded. Note
  /// the converse trap: their absence here is *unsampled*, not impossible.
  public enum State: Swift.Sendable, Swift.Hashable {
    /// A managed source-control checkout — SwiftPM cloned the package and
    /// checked out a pinned revision. **The compiled tree is under the scratch
    /// directory, not at the reference's location.**
    case sourceControlCheckout(Package.Resolution.Checkout)

    /// A local package used in place, as a `.package(path:)` declaration
    /// resolves. The path is the compiled tree itself — no checkout intervenes.
    case fileSystem(path: Swift.String)

    /// A dependency replaced by a working copy for top-of-tree development.
    ///
    /// Carries a path and, critically, **no revision** — the wire supplies no
    /// `checkoutState` for this case. The editable workflow is retired at the
    /// coordinator, but the state format still carries the case and live
    /// records exist, so a reader that treats it as impossible fails on real
    /// state.
    ///
    /// ``Superseded`` is the record's `basedOn`, which is non-null for exactly
    /// and only the edited records observed. It is `Optional` nonetheless:
    /// SwiftPM's own model permits an edit with no prior managed dependency,
    /// and zero such records having been seen is unsampled rather than
    /// impossible.
    case edited(path: Swift.String, basedOn: Package.Resolution.Dependency.Superseded?)
  }
}

// [API-IMPL-008]: projections live in an extension, not the type body.

extension Package.Resolution.Dependency.State {
  /// The checkout, for the one case that has one.
  public var checkout: Package.Resolution.Checkout? {
    switch self {
    case .sourceControlCheckout(let checkout): checkout
    case .fileSystem, .edited: nil
    }
  }

  /// The recorded path, for the two cases that carry one.
  ///
  /// This is the path SwiftPM stored, **not** a claim about what the build
  /// compiles. For ``fileSystem(path:)`` and ``edited(path:)`` they coincide;
  /// for ``sourceControlCheckout(_:)`` there is no path here at all and the
  /// compiled tree must be derived.
  public var path: Swift.String? {
    switch self {
    case .fileSystem(let path), .edited(let path, _): path
    case .sourceControlCheckout: nil
    }
  }

  /// The managed checkout this state displaced, for the one case that can have
  /// displaced anything.
  public var superseded: Package.Resolution.Dependency.Superseded? {
    switch self {
    case .edited(_, let superseded): superseded
    case .sourceControlCheckout, .fileSystem: nil
    }
  }
}
