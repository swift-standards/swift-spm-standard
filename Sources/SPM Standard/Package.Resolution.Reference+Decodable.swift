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

// See ``Package/Resolution`` for why this is Decodable-only.
//
// An unrecognised `kind` fails rather than falling back. The synthesised
// `RawRepresentable` decoding of ``Package/Resolution/Reference/Kind`` already
// produces a `DecodingError` naming the offending value, which is the desired
// behaviour: a kind this package has never seen is a fact to report, not one to
// paper over with a default.

#if !hasFeature(Embedded)
    extension Package.Resolution.Reference: Decodable {
        private enum CodingKeys: Swift.String, CodingKey {
            case identity
            case kind
            case location
            case name
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // `identity` decoded as a bare string: it is `Tagged`, whose synthesised
            // Codable uses a keyed container that does not match this wire shape.
            let identity = try container.decode(Swift.String.self, forKey: .identity)
            self.init(
                identity: .init(identity),
                kind: try container.decode(Package.Resolution.Reference.Kind.self, forKey: .kind),
                location: try container.decode(Swift.String.self, forKey: .location),
                name: try container.decode(Swift.String.self, forKey: .name)
            )
        }
    }

    extension Package.Resolution.Reference.Kind: Decodable {}
#endif
