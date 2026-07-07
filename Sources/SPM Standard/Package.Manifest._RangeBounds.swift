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
  /// Wire-format shim for the `range` requirement's bounds within
  /// the `swift package dump-package` JSON.
  ///
  /// JSON shape:
  ///
  /// ```
  /// { "lowerBound": "1.0.0", "upperBound": "2.0.0" }
  /// ```
  internal struct _RangeBounds: Codable {
    let lowerBound: Swift.String
    let upperBound: Swift.String
  }
}
