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
    /// The pinned state of a managed source-control checkout.
    ///
    /// Wire shape — the `state.checkoutState` object:
    ///
    /// ```json
    /// { "revision": "9bbec44787745de50bc80ed8191d055ba51ed2b5", "branch": "main" }
    /// { "revision": "cf1d6e3a1f2b…", "version": "602.0.0" }
    /// ```
    ///
    /// `revision` is always present. The remainder is a genuine either-or, not
    /// two optional fields: across 26,631 observed checkout records, **0 carry
    /// both `branch` and `version` and 0 carry neither**. Modelling it as two
    /// optionals would make three unrepresentable states representable, so it is
    /// a required ``Pin`` instead.
    public struct Checkout: Swift.Sendable, Swift.Hashable {
        /// The exact Git revision SwiftPM checked out.
        ///
        /// A raw `Swift.String` rather than a typed object ID: `swift-git-standard`
        /// owns `Git.Object.ID`, and this Layer-2 package must not take an upward
        /// dependency to reach it. Adopting a typed revision is recorded as
        /// semantic-type follow-up, not resolved here.
        public let revision: Swift.String

        /// What the revision was resolved *from* — a branch or a version.
        public let pin: Package.Resolution.Checkout.Pin

        public init(revision: Swift.String, pin: Package.Resolution.Checkout.Pin) {
            self.revision = revision
            self.pin = pin
        }
    }
}
