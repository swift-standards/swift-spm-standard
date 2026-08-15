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

extension Package.Manifest.Evaluation._SourceControlRecord {
    /// Wire-format shim for the `location` object of an evaluated
    /// `sourceControl` dependency.
    ///
    /// The object is a union with exactly one populated key, whose array holds
    /// exactly one element:
    ///
    /// ```
    /// { "remote": [ { "urlString": "https://github.com/org/repo.git" } ] }
    /// { "local":  [ "/fixture/checkouts/repo" ] }
    /// ```
    ///
    /// Both keys are optional so the projection can reject the ambiguous,
    /// absent, empty, and multi-element forms with a precise diagnostic rather
    /// than a generic synthesised key error. Reusing the existing
    /// ``Package/Manifest/_SourceControlRecord/_Location/_Remote`` avoids a
    /// second spelling of the same one-field record.
    ///
    /// The projection onto ``Package/Dependency/Evaluation/Source/Location``
    /// lives on the target type as `init(_:)` per `[PATTERN-012]`.
    internal struct _Location: Decodable {
        let remote: [Package.Manifest._SourceControlRecord._Location._Remote]?
        let local: [Swift.String]?
    }
}
