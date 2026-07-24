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
  /// The identity token SwiftPM emitted for this dependency while
  /// evaluating a manifest.
  ///
  /// `Package.Dependency.Evaluation.Identity` is
  /// `Tagged<Package.Dependency.Evaluation, Swift.String>` — the value is the
  /// bare string in the wire record's `identity` field.
  ///
  /// This is deliberately **not** ``Package/Identity``. That type models the
  /// SE-0292 registry `scope.name` composite, and only registry dependencies
  /// carry one. The token here is emitted for every evaluated dependency
  /// regardless of kind, and SwiftPM derives it from the *mapped* location:
  /// for a source-control dependency redirected to a filesystem path by a
  /// mirror, the token is derived from that path, not from the declared URL.
  ///
  /// It is also **not** ``Package/Name``. That models the manifest-level
  /// `Package(name:)` field of the package being described; this token
  /// identifies a dependency *of* that package and is not guaranteed to equal
  /// the dependency's own manifest name.
  ///
  /// The narrow tagged spelling is intentional: until the source-control
  /// identity question is separately adjudicated, the honest representation of
  /// this value is "the string SwiftPM printed", carried in a type that cannot
  /// be confused with either of the two identifiers it resembles.
  public typealias Identity = Tagged<Package.Dependency.Evaluation, Swift.String>
}
