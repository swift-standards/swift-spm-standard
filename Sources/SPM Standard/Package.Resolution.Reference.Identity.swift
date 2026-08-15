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
    /// The identity token SwiftPM computed for a resolved package.
    ///
    /// `Package.Resolution.Reference.Identity` is
    /// `Tagged<Package.Resolution.Reference, Swift.String>` — the bare string in
    /// the record's `identity` field.
    ///
    /// SwiftPM derives it from the **mapped** location: where that location
    /// validates as an absolute path, the identity is the directory basename. So
    /// a mirror that redirects a canonical URL to a local directory determines
    /// the package's identity, and a renamed directory silently renames the
    /// package.
    ///
    /// This is deliberately **not** ``Package/Identity``, which models the
    /// SE-0292 registry `scope.name` composite that only registry dependencies
    /// carry.
    ///
    /// It is also a distinct type from ``Package/Dependency/Evaluation/Identity``,
    /// even though both are "the string SwiftPM printed" and both are derived the
    /// same way. They belong to different lifecycle phases — one to manifest
    /// evaluation, one to resolution — and keeping them distinct is what stops a
    /// caller from comparing an evaluated dependency to a resolved one without
    /// deciding, explicitly, that the comparison is meaningful. Comparing them
    /// today goes through their raw values; unifying them is deferred to the
    /// source-control identity adjudication rather than pre-empted here.
    public typealias Identity = Tagged<Package.Resolution.Reference, Swift.String>
}
