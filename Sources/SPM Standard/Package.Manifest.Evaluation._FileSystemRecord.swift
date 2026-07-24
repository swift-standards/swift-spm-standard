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
  /// Wire-format shim for one entry in a `fileSystem` dependency array
  /// of an evaluated manifest.
  ///
  /// JSON shape:
  ///
  /// ```
  /// {
  ///   "identity": "swift-css",
  ///   "path": "/fixture/checkouts/swift-css",
  ///   "productFilter": null,
  ///   "traits": [ { "name": "default" } ]
  /// }
  /// ```
  ///
  /// There is deliberately no `requirement` field: a filesystem dependency
  /// carries none, and the decoder must not invent one.
  internal struct _FileSystemRecord: Decodable {
    let identity: Swift.String
    let path: Swift.String
    let productFilter: [Swift.String]?
    let traits: [_TraitWire]?
  }
}
