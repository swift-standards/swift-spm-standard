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

extension Package.Resolution.Checkout {
    /// What a checkout's revision was resolved from.
    ///
    /// Exactly one of the two, always — see ``Package/Resolution/Checkout`` for
    /// the exhaustive counts.
    ///
    /// ## The discriminator is the key, never the value
    ///
    /// A branch name may look exactly like a version. Among the nine distinct
    /// branch names observed on the reference machine, **four are version-shaped**
    /// — `1.6.1`, `1.10.1`, `1.1.6`, `3.12.5` — alongside `main` and
    /// `release/6.3`. Any reader that sniffs the string to decide which case it
    /// is will classify those four wrongly. The JSON key is the only sound
    /// discriminator, and decoding relies on it exclusively.
    public enum Pin: Swift.Sendable, Swift.Hashable {
        /// Resolved from a branch. Carried as a raw `Swift.String`: it is a Git ref
        /// name, whose typed owner is `swift-git-standard`, one layer up.
        case branch(Swift.String)

        /// Resolved from a version tag. Typed, because this package already owns
        /// ``Version/Semantic`` and every one of the 53 distinct version strings
        /// observed parses strictly.
        case version(Version.Semantic)
    }
}
