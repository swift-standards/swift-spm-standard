#if !hasFeature(Embedded)
    extension Package.Manifest.Target: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case name
            case type
            case dependencies
            case path
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let nameString = try container.decode(Swift.String.self, forKey: .name)
            let kindRaw = try container.decode(Swift.String.self, forKey: .type)
            guard let kind = Package_Primitives.Target.Kind(rawValue: kindRaw) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "unknown target type '\(kindRaw)'"
                )
            }
            let dependencies =
                try container.decodeIfPresent(
                    [Package_Primitives.Target.Dependency].self,
                    forKey: .dependencies
                ) ?? []
            let path = try container.decodeIfPresent(Swift.String.self, forKey: .path)
            self.init(
                name: Package_Primitives.Target.Name(_unchecked: nameString),
                kind: kind,
                dependencies: dependencies,
                path: path
            )
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.name.underlying, forKey: .name)

            try container.encode(self.kind.rawValue, forKey: .type)
            try container.encode(self.dependencies, forKey: .dependencies)
            try container.encodeIfPresent(self.path, forKey: .path)
        }
    }
#endif
