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
// `swift package dump-package`'s `products[]` array:
//
// ```
// {
//   "name": "SPM Standard",
//   "type": {"library": ["automatic"]},  // or {"executable": null} / {"plugin": null}
//   "targets": ["SPM Standard"],
//   "settings": []
// }
// ```
//
// The `settings` array is decoded-and-discarded (v0.3 ignore-extras
// strategy); per-product settings can be added additively later.

// Shadow-resolution: module-qualified `Package_Primitives.Product`
// references resolve to L1's outer `Product` namespace inside
// `extension Package.Manifest.Product` where the unqualified
// `Product` would rebind to the nested struct.

#if !hasFeature(Embedded)
    extension Package.Manifest.Product: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case name
            case type
            case targets
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let nameString = try container.decode(Swift.String.self, forKey: .name)
            let kind = try container.decode(Package_Primitives.Product.Kind.self, forKey: .type)
            let targetNames = try container.decode([Swift.String].self, forKey: .targets)
            self.init(
                name: Package_Primitives.Product.Name(_unchecked: nameString),
                kind: kind,
                targets: targetNames.map { Target.Name(_unchecked: $0) }
            )
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.name.underlying, forKey: .name)
            try container.encode(self.kind, forKey: .type)
            try container.encode(self.targets.map { $0.underlying }, forKey: .targets)
        }
    }
#endif
