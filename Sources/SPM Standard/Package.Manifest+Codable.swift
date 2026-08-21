#if !hasFeature(Embedded)
    extension Package.Manifest: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case name
            case toolsVersion
            case dependencies
            case products
            case targets
            case platforms
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let nameString = try container.decode(Swift.String.self, forKey: .name)
            let name = Package.Name(_unchecked: nameString)
            let toolsWire = try container.decode(_ToolsVersionWire.self, forKey: .toolsVersion)
            let toolsVersion: Version.Tools
            do {
                toolsVersion = try Version.Tools(parsing: toolsWire._version)
            } catch {
                throw DecodingError.dataCorruptedError(
                    forKey: .toolsVersion,
                    in: container,
                    debugDescription:
                        "Invalid tools-version string '\(toolsWire._version)': \(error)"
                )
            }
            let wireDependencies = try container.decode(
                [_DependencyWire].self,
                forKey: .dependencies
            )
            let baseDependencies = try wireDependencies.map { wire in
                try wire.toDependency()
            }
            let products =
                try container.decodeIfPresent(
                    [Self.Product].self,
                    forKey: .products
                ) ?? []
            let targets =
                try container.decodeIfPresent(
                    [Self.Target].self,
                    forKey: .targets
                ) ?? []
            let platforms = try container.decodeIfPresent(
                [SupportedPlatform].self,
                forKey: .platforms
            )

            let dependencies = Self._backfillProducts(
                dependencies: baseDependencies,
                targets: targets
            )

            self.init(
                name: name,
                toolsVersion: toolsVersion,
                dependencies: dependencies,
                products: products,
                targets: targets,
                platforms: platforms
            )
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.name.underlying, forKey: .name)
            try container.encode(
                _ToolsVersionWire(_version: self.toolsVersion.description),
                forKey: .toolsVersion
            )
            let wireDependencies = self.dependencies.map { _DependencyWire(from: $0) }
            try container.encode(wireDependencies, forKey: .dependencies)
            try container.encode(self.products, forKey: .products)
            try container.encode(self.targets, forKey: .targets)
            try container.encodeIfPresent(self.platforms, forKey: .platforms)
        }
    }

    extension Package.Manifest {

        internal static func _parseSemantic(
            _ string: Swift.String
        ) throws -> Version.Semantic {
            do {
                return try Version.Semantic(parsing: string)
            } catch {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Invalid semantic version '\(string)': \(error)"
                    )
                )
            }
        }

        internal static func _parseIdentity(
            _ string: Swift.String
        ) throws -> Package.Identity {

            guard let dot = string.firstIndex(of: ".") else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription:
                            "Invalid registry identity '\(string)' — expected 'scope.name'"
                    )
                )
            }
            let scope = Swift.String(string[..<dot])
            let name = Swift.String(string[string.index(after: dot)...])
            return Package.Identity(scope: scope, name: name)
        }

        internal static func _backfillProducts(
            dependencies: [Package.Dependency],
            targets: [Self.Target]
        ) -> [Package.Dependency] {

            var ordered: [Swift.String: [Package_Primitives.Product.Name]] = [:]
            var seen: [Swift.String: Swift.Set<Package_Primitives.Product.Name>] = [:]
            for target in targets {
                for edge in target.dependencies {
                    guard case .product(let productName, let packageName) = edge else {
                        continue
                    }
                    let identity = packageName.underlying
                    if seen[identity, default: []].insert(productName).inserted {
                        ordered[identity, default: []].append(productName)
                    }
                }
            }

            return dependencies.map {
                (dependency: Package.Dependency) -> Package.Dependency in
                let identity = dependency.name.underlying
                guard let products = ordered[identity], !products.isEmpty else {
                    return dependency
                }
                return Package.Dependency(
                    source: dependency.source,
                    name: dependency.name,
                    products: products
                )
            }
        }
    }
#endif
