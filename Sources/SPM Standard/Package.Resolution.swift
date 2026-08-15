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
    /// SwiftPM's resolved workspace state — the contents of `workspace-state.json`.
    ///
    /// This is the third of four lifecycle-distinct facts about a dependency, and
    /// it is not interchangeable with either of the two above it:
    ///
    /// - ``Package/Dependency/Source`` models the portable *declaration*.
    /// - ``Package/Manifest/Evaluation`` models what SwiftPM *evaluated* on this
    ///   machine, after normalisation and mirror substitution.
    /// - `Package.Resolution` models what SwiftPM *resolved* — which packages it
    ///   fetched, in what form, and at which revision.
    /// - The source tree a build actually *compiles* is derived from this value
    ///   plus a scratch path, and is neither stored here nor equal to any
    ///   location it carries.
    ///
    /// The name deliberately avoids `Workspace`: SwiftPM calls this file
    /// "workspace state", but `Package.Workspace` is already the package-discovery
    /// type in `swift-package-graph`, and Workspace is separately the name of the
    /// Layer-5 application. Reusing it would collide on import.
    ///
    /// ## Wire shape
    ///
    /// ```json
    /// { "version": 7, "object": { "artifacts": [], "dependencies": [ … ], "prebuilts": [] } }
    /// ```
    ///
    /// `artifacts` and `prebuilts` are decoded-and-discarded. `prebuilts` is a
    /// toolchain-keyed build cache — every observed record is the prebuilt
    /// `swift-syntax` macro-support library, and its path is keyed by the exact
    /// toolchain build. It describes no dependency's source and must never
    /// participate in deriving a materialized path.
    /// The schema version is a **precondition, not a fact worth carrying.** It is
    /// read and checked during decoding — a mismatch is refused outright — so any
    /// successfully decoded value is by construction a ``supportedVersion`` one.
    /// Storing it would offer callers a number that can only ever hold that
    /// single value.
    public struct Resolution: Swift.Sendable, Swift.Hashable {
        /// The resolved dependency records, in the order the file lists them.
        public let dependencies: [Package.Resolution.Dependency]

        public init(dependencies: [Package.Resolution.Dependency] = []) {
            self.dependencies = dependencies
        }
    }
}

// [API-IMPL-008]: projections live in an extension, not the type body.

extension Package.Resolution {
    /// The only schema version this package has been verified against.
    ///
    /// Established by reading every `workspace-state.json` present on the
    /// reference machine: 483 files, 483 carrying `version: 7`, no other value.
    public static var supportedVersion: Swift.Int { 7 }

    /// The record for `identity`, or `nil` when the resolution does not carry one.
    ///
    /// A linear scan. The wire is a list, not a map, and resolutions are small
    /// enough that building an index would cost more than it saves.
    public func dependency(
        for identity: Package.Resolution.Reference.Identity
    ) -> Package.Resolution.Dependency? {
        dependencies.first { $0.reference.identity == identity }
    }
}
