#if !hasFeature(Embedded)
    extension Package.Resolution: Decodable {

        private enum CodingKeys: Swift.String, CodingKey {
            case version
            case object
            case dependencies
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let version = try container.decode(Swift.Int.self, forKey: .version)

            guard version == Package.Resolution.supportedVersion else {
                throw DecodingError.dataCorruptedError(
                    forKey: .version,
                    in: container,
                    debugDescription: """
                        Unsupported workspace-state schema version \(version); \
                        this package models version \(Package.Resolution.supportedVersion). \
                        Refusing to decode rather than risk misreading a changed layout.
                        """
                )
            }

            let object = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .object)
            self.init(
                dependencies: try object.decode(
                    [Package.Resolution.Dependency].self,
                    forKey: .dependencies
                )
            )
        }
    }
#endif
