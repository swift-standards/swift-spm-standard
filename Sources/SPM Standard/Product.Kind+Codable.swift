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
// Wire-format shape — single-key discriminated union, where the
// `library` arm carries a single-element string array of the
// link kind, and `executable` / `plugin` carry `null`:
//
// ```
// {"library":    ["static" | "dynamic" | "automatic"]}
// {"executable": null}
// {"plugin":     null}
// ```

#if !hasFeature(Embedded)
  extension Product.Kind: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
      case library
      case executable
      case plugin
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if container.contains(.library) {
        let raws = try container.decode([Swift.String].self, forKey: .library)
        guard let first = raws.first else {
          throw DecodingError.dataCorruptedError(
            forKey: .library,
            in: container,
            debugDescription: "expected single-element [String] for library link kind"
          )
        }
        guard let libraryType = Product.LibraryType(rawValue: first) else {
          throw DecodingError.dataCorruptedError(
            forKey: .library,
            in: container,
            debugDescription: "unknown library link kind '\(first)'"
          )
        }
        self = .library(libraryType)
        return
      }
      if container.contains(.executable) {
        self = .executable
        return
      }
      if container.contains(.plugin) {
        self = .plugin
        return
      }
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Product kind matched none of library/executable/plugin"
        )
      )
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .library(let linkKind):
        try container.encode([linkKind.rawValue], forKey: .library)
      case .executable:
        try container.encodeNil(forKey: .executable)
      case .plugin:
        try container.encodeNil(forKey: .plugin)
      }
    }
  }
#endif
