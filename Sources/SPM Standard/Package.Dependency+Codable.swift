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
