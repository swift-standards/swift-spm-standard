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

extension Package.Manifest._SourceControlRecord {
  /// Wire-format shim for the `location` field of a
  /// ``_SourceControlRecord``.
  ///
  /// JSON shape: `{ "remote": [ { "urlString": "..." } ] }`. The
  /// nested ``_Remote`` carries the URL itself.
  internal struct _Location: Codable {
    let remote: [_Remote]
  }
}
