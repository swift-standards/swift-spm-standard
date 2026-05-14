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

extension Package.Manifest {
    /// Wire-format shim for one entry in a `sourceControl` dependency
    /// array within the `swift package dump-package` JSON.
    ///
    /// JSON shape:
    ///
    /// ```
    /// {
    ///   "identity": "swift-foo",
    ///   "location": { "remote": [ { "urlString": "https://..." } ] },
    ///   "requirement": <Requirement wire form>
    /// }
    /// ```
    ///
    /// The nested ``_Location`` and ``_Location/_Remote`` types live
    /// in their own files per `[API-IMPL-005]`.
    internal struct _SourceControlRecord: Codable {
        let identity: Swift.String
        let location: _Location
        let requirement: _RequirementWire
    }
}
