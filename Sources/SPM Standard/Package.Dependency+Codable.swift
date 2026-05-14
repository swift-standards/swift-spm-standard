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
// Wire-format shape:
//
// ```
// {
//   "source": {"kind":"path","path":"../swift-foo"} | ... ,
//   "name": "swift-foo",
//   "products": ["Foo"]
// }
// ```
//
// `Package.Name` and `Product.Name` are `Tagged<*, String>` typed
// identifiers and code as their underlying String value via the
// Tagged ecosystem's stdlib integration. The `Source` enum's
// discriminated-union shape is encoded in
// ``Package/Dependency/Source+Codable``.

// swiftlint:disable no_any_protocol_existential typed_throws_required
#if !hasFeature(Embedded)
    extension Package.Dependency: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case source
            case name
            case products
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let source = try container.decode(Source.self, forKey: .source)
            let name = try container.decode(Package.Name.self, forKey: .name)
            let products = try container.decode([Product.Name].self, forKey: .products)
            self.init(source: source, name: name, products: products)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.source, forKey: .source)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.products, forKey: .products)
        }
    }
#endif
// swiftlint:enable no_any_protocol_existential typed_throws_required
