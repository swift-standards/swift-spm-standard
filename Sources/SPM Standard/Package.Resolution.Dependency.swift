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

extension Package.Resolution {
    /// One resolved dependency record.
    ///
    /// Every record observed carries exactly four keys — `packageRef`, `state`,
    /// `subpath`, `basedOn` — with no optionality at the record level, so nothing
    /// here is modelled as absent.
    ///
    /// Only three appear as stored properties. The wire's `basedOn` is folded
    /// into ``State/edited(path:basedOn:)`` rather than sitting alongside
    /// ``state``, because it is non-null for exactly and only the edited records
    /// — 91 of 27,003, a perfect correspondence. Keeping it at record level would
    /// let a caller construct a `fileSystem` dependency that claims to supersede
    /// a checkout, which the wire never expresses. See ``State/Superseded``.
    ///
    /// ## `reference.kind` and `state` are independent facts
    ///
    /// They co-vary without being redundant, and **neither recovers the other**.
    /// Across 27,003 observed records only 4 of the 9 possible pairings occur,
    /// and both source-control kinds collapse onto a single state name:
    ///
    /// | `kind` | `state` | count |
    /// |---|---|---|
    /// | `localSourceControl` | `sourceControlCheckout` | 24,821 |
    /// | `remoteSourceControl` | `sourceControlCheckout` | 1,808 |
    /// | `fileSystem` | `fileSystem` | 283 |
    /// | `localSourceControl` | `edited` | 91 |
    ///
    /// Anything needing both facts must read both fields. In particular,
    /// ``Reference/Kind`` describes *where SwiftPM fetches from* and cannot be
    /// read as "local versus remote machine storage": a mirror target spelled as
    /// a bare path yields `localSourceControl` while the same directory spelled
    /// `file://…` yields `remoteSourceControl`.
    public struct Dependency: Swift.Sendable, Swift.Hashable {
        /// Which package this record resolves, and in what form SwiftPM fetches it.
        public let reference: Package.Resolution.Reference

        /// What SwiftPM produced for it. See ``State``.
        public let state: Package.Resolution.Dependency.State

        /// The checkout directory name, **relative to the workspace checkouts
        /// directory** — not a usable path on its own.
        ///
        /// Deriving the compiled source tree requires this plus a scratch path, and
        /// that derivation belongs to the operational layer, not here.
        public let subpath: Swift.String

        public init(
            reference: Package.Resolution.Reference,
            state: Package.Resolution.Dependency.State,
            subpath: Swift.String
        ) {
            self.reference = reference
            self.state = state
            self.subpath = subpath
        }
    }
}

// [API-IMPL-008]: projections live in an extension, not the type body.

extension Package.Resolution.Dependency {
    /// The revision SwiftPM recorded, or `nil` when the state carries none.
    ///
    /// `nil` is a **fact, not a gap to fill by inference**. An edited dependency
    /// has no recorded revision at all — 91 such records exist on the reference
    /// machine — so any planned-versus-resolved comparison must be able to say
    /// "the revision is genuinely unknown" rather than defaulting it.
    public var revision: Swift.String? { state.checkout?.revision }
}
