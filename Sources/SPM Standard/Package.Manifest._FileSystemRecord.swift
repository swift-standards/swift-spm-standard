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
  /// Wire-format shim for one entry in a `fileSystem` dependency
  /// array within the `swift package dump-package` JSON.
  ///
  /// JSON shape:
  ///
  /// ```
  /// { "identity": "swift-foo", "path": "/abs/path/to/swift-foo" }
  /// ```
  internal struct _FileSystemRecord: Codable {
    let identity: Swift.String
    let path: Swift.String
  }
}
