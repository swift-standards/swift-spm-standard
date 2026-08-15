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
    /// Wire-format shim for one entry in a `registry` dependency
    /// array within the `swift package dump-package` JSON.
    ///
    /// JSON shape:
    ///
    /// ```
    /// {
    ///   "identity": "scope.name",
    ///   "requirement": <Requirement wire form>
    /// }
    /// ```
    ///
    /// Registry identity is `"scope.name"` per SE-0292; the dot
    /// separator is parsed into ``Package/Identity`` (scope, name).
    internal struct _RegistryRecord: Codable {
        let identity: Swift.String
        let requirement: _RequirementWire
    }
}
