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
  /// Wire-format shim for one entry in a `registry` dependency array of an
  /// evaluated manifest.
  ///
  /// JSON shape:
  ///
  /// ```
  /// {
  ///   "identity": "scope.name",
  ///   "requirement": { "exact": [ "1.0.0" ] },
  ///   "productFilter": null,
  ///   "traits": [ { "name": "default" } ]
  /// }
  /// ```
  ///
  /// Registry identity is `"scope.name"` per SE-0292 — the one evaluated kind
  /// whose emitted token genuinely is a ``Package/Identity``.
  internal struct _RegistryRecord: Decodable {
    let identity: Swift.String
    let requirement: Package.Manifest._RequirementWire
    let productFilter: [Swift.String]?
    let traits: [_TraitWire]?
  }
}
