#if !hasFeature(Embedded)
    extension SupportedPlatform: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case platformName
            case version
            case options
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let raw = try container.decode(Swift.String.self, forKey: .platformName)
            guard let platform = Platform(rawValue: raw) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .platformName,
                    in: container,
                    debugDescription: "unknown platform name '\(raw)'"
                )
            }
            let version = try container.decode(Swift.String.self, forKey: .version)
            self.init(platform: platform, version: version)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.platform.rawValue, forKey: .platformName)
            try container.encode(self.version, forKey: .version)

            try container.encode([Swift.String](), forKey: .options)
        }
    }
#endif
