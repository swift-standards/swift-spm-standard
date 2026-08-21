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
