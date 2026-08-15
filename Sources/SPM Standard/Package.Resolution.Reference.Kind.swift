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

extension Package.Resolution.Reference {
    /// The form in which SwiftPM fetches a package.
    ///
    /// **This is a fetch category, not a statement about machine storage.** The
    /// same directory on the same disk resolves as ``localSourceControl`` when a
    /// mirror target is spelled as a bare path and as ``remoteSourceControl``
    /// when it is spelled `file://…`, because SwiftPM classifies by whether the
    /// mapped location parses a scheme. Any check that infers locality from this
    /// value alone is unsound; it must read ``Package/Resolution/Reference/location``
    /// too.
    ///
    /// It is likewise not a statement about mutability. ``localSourceControl``
    /// still produces a pinned clone under the scratch directory — the local
    /// location is where SwiftPM *fetched from*, and the compiled tree is
    /// elsewhere.
    ///
    /// Three of these five are observed on the reference machine
    /// (`localSourceControl` 24,912, `remoteSourceControl` 1,808, `fileSystem`
    /// 283). ``root`` and ``registry`` are carried because SwiftPM's own model
    /// declares them; their absence here is **unsampled, not impossible**, and a
    /// model omitting them would fail on the first registry dependency anyone
    /// adds.
    public enum Kind: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {
        /// A root package of the resolution.
        case root

        /// A non-root local package, used in place.
        case fileSystem

        /// A source-control package fetched from a filesystem location.
        case localSourceControl

        /// A source-control package fetched from a URL.
        case remoteSourceControl

        /// A package from a registry, per SE-0292.
        case registry
    }
}
