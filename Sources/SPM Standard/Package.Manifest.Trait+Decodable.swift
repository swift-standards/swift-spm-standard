#if !hasFeature(Embedded)
    extension Package.Manifest.Trait: Decodable {
        private enum CodingKeys: Swift::String, CodingKey {
            case name
            case enabledTraits
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.init(
                name: try container.decode(Swift::String.self, forKey: .name),
                enabledTraits: try container.decodeIfPresent(
                    [Swift::String].self,
                    forKey: .enabledTraits
                ) ?? []
            )
        }
    }
#endif
