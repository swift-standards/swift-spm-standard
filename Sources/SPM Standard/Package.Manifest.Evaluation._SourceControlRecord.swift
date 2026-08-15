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

extension Package.Manifest.Evaluation {
    /// Wire-format shim for one entry in a `sourceControl` dependency array
    /// of an evaluated manifest.
    ///
    /// JSON shape:
    ///
    /// ```
    /// {
    ///   "identity": "swift-paths",
    ///   "location": { "local": [ "/fixture/checkouts/swift-paths" ] },
    ///   "productFilter": null,
    ///   "requirement": { "branch": [ "main" ] },
    ///   "traits": [ { "name": "default" } ]
    /// }
    /// ```
    ///
    /// `requirement` is non-optional: the installed wire contract emits one for
    /// every source-control dependency, whether the location is remote or
    /// mirror-substituted. A record missing it is rejected.
    ///
    /// The nested ``_Location`` lives in its own file per `[API-IMPL-005]`.
    internal struct _SourceControlRecord: Decodable {
        let identity: Swift.String
        let location: _Location
        let requirement: Package.Manifest._RequirementWire
        let productFilter: [Swift.String]?
        let traits: [_TraitWire]?
    }
}
