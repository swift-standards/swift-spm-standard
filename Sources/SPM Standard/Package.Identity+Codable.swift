#if !hasFeature(Embedded)
    extension Package.Identity: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case scope
            case name
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let scope = try container.decode(Swift.String.self, forKey: .scope)
            let name = try container.decode(Swift.String.self, forKey: .name)
            self.init(scope: scope, name: name)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.scope, forKey: .scope)
            try container.encode(self.name, forKey: .name)
        }
    }
#endif
