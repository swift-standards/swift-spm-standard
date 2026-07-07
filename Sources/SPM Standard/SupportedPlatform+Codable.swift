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
// Wire-format shape — matches `swift package dump-package`'s
// `platforms[]` element shape:
//
// ```
// {"options": [], "platformName": "macos", "version": "26.0"}
// ```
//
// The `options` array is currently always empty in dump-package
// output and is decoded-and-discarded. The ``Platform`` raw value
// matches the lowercase wire token.

#if !hasFeature(Embedded)
  extension SupportedPlatform: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
      case platformName
      case version
      case options
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let raw = try container.decode(Swift.String.self, forKey: .platformName)
      guard let platform = Platform(rawValue: raw) else {
        throw DecodingError.dataCorruptedError(
          forKey: .platformName,
          in: container,
          debugDescription: "unknown platform name '\(raw)'"
        )
      }
      let version = try container.decode(Swift.String.self, forKey: .version)
      self.init(platform: platform, version: version)
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.platform.rawValue, forKey: .platformName)
      try container.encode(self.version, forKey: .version)
      // Emit an empty `options` array to match the
      // dump-package wire shape verbatim.
      try container.encode([Swift.String](), forKey: .options)
    }
  }
#endif
