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
    /// Wire-format shim for one element of the `dependencies[]` array of an
    /// evaluated manifest. A discriminated union — exactly one of
    /// `fileSystem`, `sourceControl`, or `registry` is present, and its array
    /// holds exactly one record.
    ///
    /// The projection onto ``Package/Dependency/Evaluation`` lives on the
    /// target type as `init(_:)` per `[PATTERN-012]`, not as a `to…()` method
    /// here.
    internal struct _DependencyWire: Decodable {
        let fileSystem: [_FileSystemRecord]?
        let sourceControl: [_SourceControlRecord]?
        let registry: [_RegistryRecord]?
    }
}
