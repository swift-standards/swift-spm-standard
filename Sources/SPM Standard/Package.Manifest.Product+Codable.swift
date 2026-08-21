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
