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

extension Package.Resolution {
  /// Which package a resolved record refers to, and in what form SwiftPM
  /// fetches it.
  ///
  /// Wire shape — the `packageRef` object, always exactly these four keys:
  ///
  /// ```json
  /// {
  ///   "identity": "swift-paths",
  ///   "kind": "localSourceControl",
  ///   "location": "/…/swift-paths",
  ///   "name": "swift-paths"
  /// }
  /// ```
  ///
  /// ``location`` is where SwiftPM *fetches from*. It is emphatically not the
  /// tree a build compiles: for a source-control checkout the compiled tree
  /// lives under the scratch directory, and the mutable worktree at this
  /// location routinely diverges from it. Treating a mirror target as the
  /// compiled source is the specific error this whole model exists to prevent.
  public struct Reference: Swift.Sendable, Swift.Hashable {
    /// The identity token SwiftPM computed for this package.
    public let identity: Package.Resolution.Reference.Identity

    /// The form SwiftPM fetches this package in. See ``Kind``.
    public let kind: Package.Resolution.Reference.Kind

    /// Where SwiftPM fetches from — a URL or an absolute path, depending on
    /// ``kind`` and on how any mirror target was spelled. Preserved verbatim.
    public let location: Swift.String

    /// The name SwiftPM recorded alongside the identity.
    ///
    /// Observed equal to `identity` in all 27,003 records, and equal to the
    /// location's basename — but that is an observation about this machine's
    /// configuration, not a guarantee, so the two are kept as separate fields
    /// rather than one derived from the other.
    public let name: Swift.String

    public init(
      identity: Package.Resolution.Reference.Identity,
      kind: Package.Resolution.Reference.Kind,
      location: Swift.String,
      name: Swift.String
    ) {
      self.identity = identity
      self.kind = kind
      self.location = location
      self.name = name
    }
  }
}
