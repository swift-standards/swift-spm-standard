#if !hasFeature(Embedded)
    extension Package.Manifest.Target {

        /// A target dependency as `dump-package` writes it: the dependency, followed in the same
        /// array by its condition (`product: [name, package, moduleAliases, condition]`,
        /// `target: [name, condition]`, `byName: [name, condition]`).
        internal struct _DependencyWire: Codable {
            let dependency: Package::Target.Dependency
            let condition: Package.Manifest.Condition?

            private enum CodingKeys: Swift::String, CodingKey {
                case product
                case target
                case byName
            }

            init(dependency: Package::Target.Dependency, condition: Package.Manifest.Condition?) {
                self.dependency = dependency
                self.condition = condition
            }

            init(from decoder: any Decoder) throws {
                self.dependency = try Package::Target.Dependency(from: decoder)
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let key: CodingKeys
                let leading: Swift::Int
                switch self.dependency {
                case .product: (key, leading) = (.product, 3)
                case .target: (key, leading) = (.target, 1)
                case .byName: (key, leading) = (.byName, 1)
                }
                var arm = try container.nestedUnkeyedContainer(forKey: key)
                for _ in 0..<leading where !arm.isAtEnd {
                    _ = try arm.decodeIfPresent(_Skipped.self)
                }
                self.condition = arm.isAtEnd ? nil : try arm.decodeIfPresent(Package.Manifest.Condition.self)
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self.dependency {
                case .product(let name, let package):
                    var arm = container.nestedUnkeyedContainer(forKey: .product)
                    try arm.encode(name.underlying)
                    try arm.encode(package.underlying)
                    try arm.encodeNil()
                    try self.encode(condition: &arm)

                case .target(let name):
                    var arm = container.nestedUnkeyedContainer(forKey: .target)
                    try arm.encode(name.underlying)
                    try self.encode(condition: &arm)

                case .byName(let name):
                    var arm = container.nestedUnkeyedContainer(forKey: .byName)
                    try arm.encode(name)
                    try self.encode(condition: &arm)
                }
            }

            private func encode(condition arm: inout any UnkeyedEncodingContainer) throws {
                if let condition = self.condition {
                    try arm.encode(condition)
                } else {
                    try arm.encodeNil()
                }
            }

            /// Any JSON value in a position the wire does not model (`moduleAliases`).
            private struct _Skipped: Decodable {
                init(from decoder: any Decoder) throws {}
            }
        }
    }
#endif
