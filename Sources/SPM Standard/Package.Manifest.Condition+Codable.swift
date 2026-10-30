#if !hasFeature(Embedded)
    extension Package.Manifest.Condition: Codable {
        private enum CodingKeys: Swift::String, CodingKey {
            case platformNames
            case traits
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.init(
                platforms: try container.decodeIfPresent(
                    [Swift::String].self,
                    forKey: .platformNames
                ) ?? [],
                traits: try container.decodeIfPresent(
                    Swift::Set<Swift::String>.self,
                    forKey: .traits
                )
            )
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.platforms, forKey: .platformNames)
            try container.encodeIfPresent(self.traits?.sorted(), forKey: .traits)
        }
    }
#endif
