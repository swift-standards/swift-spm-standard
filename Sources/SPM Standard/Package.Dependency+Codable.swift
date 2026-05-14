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
// shape per ``Source``'s discriminated-union encoder below.

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

    extension Package.Dependency.Source: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case kind
            case path
            case url
            case identity
            case requirement
        }

        private enum Kind: Swift.String, Codable {
            case path
            case url
            case registry
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .kind)
            switch kind {
            case .path:
                let path = try container.decode(Swift.String.self, forKey: .path)
                self = .path(path)
            case .url:
                let url = try container.decode(Swift.String.self, forKey: .url)
                let requirement = try container.decode(Package.Requirement.self, forKey: .requirement)
                self = .url(url, requirement)
            case .registry:
                let identity = try container.decode(Package.Identity.self, forKey: .identity)
                let requirement = try container.decode(Package.Requirement.self, forKey: .requirement)
                self = .registry(identity, requirement)
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .path(let path):
                try container.encode(Kind.path, forKey: .kind)
                try container.encode(path, forKey: .path)
            case .url(let url, let requirement):
                try container.encode(Kind.url, forKey: .kind)
                try container.encode(url, forKey: .url)
                try container.encode(requirement, forKey: .requirement)
            case .registry(let identity, let requirement):
                try container.encode(Kind.registry, forKey: .kind)
                try container.encode(identity, forKey: .identity)
                try container.encode(requirement, forKey: .requirement)
            }
        }
    }
#endif
// swiftlint:enable no_any_protocol_existential typed_throws_required
