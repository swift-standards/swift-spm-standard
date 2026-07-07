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
  /// Wire-format shim for the `toolsVersion` field in the
  /// `swift package dump-package` JSON output.
  ///
  /// The JSON shape is `{"_version": "X.Y.Z"}`; this struct
  /// captures the literal field name as it appears on the wire.
  ///
  /// Translated to/from ``Version/Tools`` by ``Package/Manifest``
  /// Codable.
  internal struct _ToolsVersionWire: Codable {
    let _version: Swift.String
  }
}
