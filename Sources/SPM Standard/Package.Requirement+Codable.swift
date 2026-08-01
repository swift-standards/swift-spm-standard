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

// Codable conformance is excluded from Embedded Swift — `Codable`
// depends on stdlib protocols and runtime infrastructure that the
// Embedded mode does not ship.
//
// `Codable`'s protocol requirements force existential coder
// parameters and untyped `throws`; both rules are deliberately
// exempted for this file's conformance block.
//
// Wire-format shape — discriminated union via "kind" key.
// Each case carries the typed values inline:
//
// ```
// {"kind":"from","version":"1.2.3"}
// {"kind":"upToNextMajor","version":"1.2.3"}
// {"kind":"upToNextMinor","version":"1.2.3"}
// {"kind":"exact","version":"1.2.3"}
// {"kind":"range","lower":"1.0.0","lowerInclusive":true,"upper":"2.0.0","upperInclusive":false}
// {"kind":"branch","branch":"main"}
// {"kind":"revision","revision":"abc123"}
// ```
//
// `Version.Range<Version.Semantic>` is NOT Codable upstream;
// this file inlines the range's bounds rather than nesting a
// Version.Range encoder. v0.2 may refine the wire shape to match
// `swift package dump-package` output exactly.

#if !hasFeature(Embedded)
  extension Package.Requirement: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
      case kind
      case version
      case lower
      case lowerInclusive
      case upper
      case upperInclusive
      case branch
      case revision
    }


    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let kind = try container.decode(Kind.self, forKey: .kind)
      switch kind {
      case .from:
        let version = try container.decode(Version.Semantic.self, forKey: .version)
        self = .from(version)
      case .upToNextMajor:
        let version = try container.decode(Version.Semantic.self, forKey: .version)
        self = .upToNextMajor(from: version)
      case .upToNextMinor:
        let version = try container.decode(Version.Semantic.self, forKey: .version)
        self = .upToNextMinor(from: version)
      case .range:
        let lower = try container.decode(Version.Semantic.self, forKey: .lower)
        let lowerInclusive = try container.decode(Swift.Bool.self, forKey: .lowerInclusive)
        let upper = try container.decode(Version.Semantic.self, forKey: .upper)
        let upperInclusive = try container.decode(Swift.Bool.self, forKey: .upperInclusive)
        let lowerBound: Version.Range<Version.Semantic>.Bound =
          lowerInclusive
          ? .inclusive(lower) : .exclusive(lower)
        let upperBound: Version.Range<Version.Semantic>.Bound =
          upperInclusive
          ? .inclusive(upper) : .exclusive(upper)
        self = .range(Version.Range(lowerBound: lowerBound, upperBound: upperBound))
      case .exact:
        let version = try container.decode(Version.Semantic.self, forKey: .version)
        self = .exact(version)
      case .branch:
        let branch = try container.decode(Swift.String.self, forKey: .branch)
        self = .branch(branch)
      case .revision:
        let revision = try container.decode(Swift.String.self, forKey: .revision)
        self = .revision(revision)
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .from(let version):
        try container.encode(Kind.from, forKey: .kind)
        try container.encode(version, forKey: .version)
      case .upToNextMajor(from: let version):
        try container.encode(Kind.upToNextMajor, forKey: .kind)
        try container.encode(version, forKey: .version)
      case .upToNextMinor(from: let version):
        try container.encode(Kind.upToNextMinor, forKey: .kind)
        try container.encode(version, forKey: .version)
      case .range(let range):
        try container.encode(Kind.range, forKey: .kind)
        try Self.encodeBound(
          range.lowerBound, into: &container, value: .lower, flag: .lowerInclusive)
        try Self.encodeBound(
          range.upperBound, into: &container, value: .upper, flag: .upperInclusive)
      case .exact(let version):
        try container.encode(Kind.exact, forKey: .kind)
        try container.encode(version, forKey: .version)
      case .branch(let branch):
        try container.encode(Kind.branch, forKey: .kind)
        try container.encode(branch, forKey: .branch)
      case .revision(let revision):
        try container.encode(Kind.revision, forKey: .kind)
        try container.encode(revision, forKey: .revision)
      }
    }

    private static func encodeBound(
      _ bound: Version.Range<Version.Semantic>.Bound,
      into container: inout KeyedEncodingContainer<CodingKeys>,
      value valueKey: CodingKeys,
      flag flagKey: CodingKeys
    ) throws {
      switch bound {
      case .inclusive(let version):
        try container.encode(version, forKey: valueKey)
        try container.encode(true, forKey: flagKey)
      case .exclusive(let version):
        try container.encode(version, forKey: valueKey)
        try container.encode(false, forKey: flagKey)
      case .unbounded:
        // v0.1: range deps from SwiftPM are always bounded;
        // unbounded bounds are not part of the dump-package
        // wire format. Surface as a data-corruption issue
        // for callers reaching this branch.
        throw EncodingError.invalidValue(
          bound,
          EncodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "unbounded range bounds are not part of the SwiftPM wire format"
          )
        )
      }
    }
  }
#endif
