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
// Wire-format shape — matches one element of
// `swift package dump-package`'s `targets[]` array:
//
// ```
// {
//   "name": "SPM Standard",
//   "type": "regular",
//   "dependencies": [
//     {"product": ["X", "swift-x", null, null]},
//     {"target":  ["LocalTarget", null]},
//     {"byName":  ["SomeName", null]}
//   ],
//   "path": "Sources/Custom",   // optional
//   "exclude": [], "resources": [], "settings": [], "packageAccess": true
// }
// ```
//
// Decoded fields: name, type, dependencies, path (optional).
// Other fields (exclude / resources / settings / packageAccess /
// publicHeadersPath / pluginUsages / etc.) are decoded-and-discarded
// under the v0.3 ignore-extras strategy.

// Shadow-resolution: module-qualified `Package_Primitives.Target`
// references resolve to L1's outer `Target` namespace inside
// `extension Package.Manifest.Target` where the unqualified
// `Target` would rebind to the nested struct.

#if !hasFeature(Embedded)
  extension Package.Manifest.Target: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
      case name
      case type
      case dependencies
      case path
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let nameString = try container.decode(Swift.String.self, forKey: .name)
      let kindRaw = try container.decode(Swift.String.self, forKey: .type)
      guard let kind = Package_Primitives.Target.Kind(rawValue: kindRaw) else {
        throw DecodingError.dataCorruptedError(
          forKey: .type,
          in: container,
          debugDescription: "unknown target type '\(kindRaw)'"
        )
      }
      let dependencies =
        try container.decodeIfPresent(
          [Package_Primitives.Target.Dependency].self, forKey: .dependencies
        ) ?? []
      let path = try container.decodeIfPresent(Swift.String.self, forKey: .path)
      self.init(
        name: Package_Primitives.Target.Name(_unchecked: nameString),
        kind: kind,
        dependencies: dependencies,
        path: path
      )
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.name.underlying, forKey: .name)
      try container.encode(self.kind.rawValue, forKey: .type)
      try container.encode(self.dependencies, forKey: .dependencies)
      try container.encodeIfPresent(self.path, forKey: .path)
    }
  }
#endif
