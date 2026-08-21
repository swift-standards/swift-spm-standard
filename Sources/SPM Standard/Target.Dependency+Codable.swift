#if !hasFeature(Embedded)
    extension Target.Dependency: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case product
            case target
            case byName
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.product) {
                var arm = try container.nestedUnkeyedContainer(forKey: .product)
                let productName = try arm.decode(Swift.String.self)
                let packageName = try arm.decode(Swift.String.self)

                self = .product(
                    name: Product.Name(_unchecked: productName),
                    package: Package.Name(_unchecked: packageName)
                )
                return
            }
            if container.contains(.target) {
                var arm = try container.nestedUnkeyedContainer(forKey: .target)
                let name = try arm.decode(Swift.String.self)
                self = .target(name: Target.Name(_unchecked: name))
                return
            }
            if container.contains(.byName) {
                var arm = try container.nestedUnkeyedContainer(forKey: .byName)
                let name = try arm.decode(Swift.String.self)
                self = .byName(name)
                return
            }
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Target dependency matched none of product/target/byName"
                )
            )
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .product(let name, let package):
                var arm = container.nestedUnkeyedContainer(forKey: .product)
                try arm.encode(name.underlying)
                try arm.encode(package.underlying)

                try arm.encodeNil()
                try arm.encodeNil()

            case .target(let name):
                var arm = container.nestedUnkeyedContainer(forKey: .target)
                try arm.encode(name.underlying)
                try arm.encodeNil()

            case .byName(let name):
                var arm = container.nestedUnkeyedContainer(forKey: .byName)
                try arm.encode(name)
                try arm.encodeNil()
            }
        }
    }
#endif
