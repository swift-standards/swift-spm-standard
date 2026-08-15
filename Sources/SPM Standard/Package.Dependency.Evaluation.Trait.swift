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

extension Package.Dependency.Evaluation {
    /// One entry of the per-dependency `traits` array SwiftPM emits during
    /// manifest evaluation.
    ///
    /// JSON shape: `{ "name": "default" }`.
    ///
    /// Only the `name` field has been observed on the Swift 6.3.3 wire. The
    /// value is preserved so evaluation is not lossy for the observed shape;
    /// no trait *semantics* are modelled here.
    public struct Trait: Swift.Sendable, Swift.Hashable {
        /// The trait's name as emitted.
        public let name: Swift.String

        public init(name: Swift.String) {
            self.name = name
        }
    }
}
