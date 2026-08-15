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
    /// Wire-format shim for one entry of a dependency's `traits` array.
    ///
    /// JSON shape: `{ "name": "default" }`.
    internal struct _TraitWire: Decodable {
        let name: Swift.String
    }
}
