#if !hasFeature(Embedded)
    extension Product.Kind: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case library
            case executable
            case plugin
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.library) {
                let raws = try container.decode([Swift.String].self, forKey: .library)
                guard let first = raws.first else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .library,
                        in: container,
                        debugDescription: "expected single-element [String] for library link kind"
                    )
                }
                guard let libraryType = Product.LibraryType(rawValue: first) else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .library,
                        in: container,
                        debugDescription: "unknown library link kind '\(first)'"
                    )
                }
                self = .library(libraryType)
                return
            }
            if container.contains(.executable) {
                self = .executable
                return
            }
            if container.contains(.plugin) {
                self = .plugin
                return
            }
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Product kind matched none of library/executable/plugin"
                )
            )
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .library(let linkKind):

                try container.encode([linkKind.rawValue], forKey: .library)

            case .executable:
                try container.encodeNil(forKey: .executable)

            case .plugin:
                try container.encodeNil(forKey: .plugin)
            }
        }
    }
#endif
