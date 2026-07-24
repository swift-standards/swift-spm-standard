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

extension Package.Dependency.Evaluation.Source {
  /// Where SwiftPM reported a source-control dependency's sources during
  /// manifest evaluation.
  ///
  /// The two cases are the two shapes the `sourceControl.location` object
  /// takes, and they are **not** interchangeable:
  ///
  /// ```
  /// { "remote": [ { "urlString": "https://github.com/org/repo.git" } ] }
  /// { "local":  [ "/fixture/checkouts/repo" ] }
  /// ```
  ///
  /// ``local(path:)`` is emitted when a configured mirror maps the declared
  /// source-control location onto a filesystem path. It remains a
  /// *source-control* dependency — its enclosing case still carries a
  /// requirement — and is therefore distinct from
  /// ``Source/fileSystem(identity:path:)``, which is what a
  /// `.package(path:)` declaration evaluates to and which has no requirement
  /// to carry.
  public enum Location: Swift.Sendable, Swift.Hashable {
    /// A source-control location reported as a URL.
    case remote(URI)

    /// A source-control location reported as a filesystem path, which SwiftPM
    /// emits after applying a mirror. The path is preserved verbatim; it is
    /// never projected onto a filesystem dependency and never converted into
    /// a fabricated `file://` URI.
    case local(path: Swift.String)
  }
}
