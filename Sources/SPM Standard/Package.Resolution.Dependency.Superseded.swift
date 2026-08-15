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
    /// The managed checkout that an edit replaced, recorded so the edit can be
    /// undone.
    ///
    /// This is the wire's `basedOn`, and it is deliberately **not** a
    /// ``Package/Resolution/Dependency``, for two reasons.
    ///
    /// The first is factual. `basedOn` is non-null in exactly 91 of 27,003
    /// observed records — precisely the 91 whose state is `edited`, a perfect
    /// one-to-one correspondence — and the superseded record's own state is
    /// `sourceControlCheckout` in all 91. It is therefore not "another dependency
    /// record" in any general sense; it is specifically the managed checkout an
    /// edit displaced, and this type says exactly that.
    ///
    /// The second is structural. A `Dependency` holding an optional `Dependency`
    /// is a value type recursively containing itself, which Swift rejects. The
    /// honest fix is not to add indirection to express a recursion the data does
    /// not exhibit — **`basedOn` never nests: zero records carry a `basedOn`
    /// inside a `basedOn`** — but to model the shape the wire actually has.
    ///
    /// Note what this value does *not* carry: a path. The superseded record is a
    /// managed checkout, so the tree it referred to lives under the scratch
    /// directory and must be derived, exactly as for any other checkout.
    public struct Superseded: Swift.Sendable, Swift.Hashable {
        /// The package reference the displaced checkout resolved.
        public let reference: Package.Resolution.Reference

        /// The revision and pin the displaced checkout was at.
        public let checkout: Package.Resolution.Checkout

        /// The displaced checkout's directory name, relative to the checkouts
        /// directory.
        public let subpath: Swift.String

        public init(
            reference: Package.Resolution.Reference,
            checkout: Package.Resolution.Checkout,
            subpath: Swift.String
        ) {
            self.reference = reference
            self.checkout = checkout
            self.subpath = subpath
        }
    }
}
