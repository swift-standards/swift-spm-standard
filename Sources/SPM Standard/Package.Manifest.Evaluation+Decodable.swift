#if !hasFeature(Embedded)
    extension Package.Manifest.Evaluation: Decodable {
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

            let toolsWire = try container.decode(
                Package.Manifest._ToolsVersionWire.self,
                forKey: .toolsVersion
            )
            let toolsVersion: Version.Tools
            do throws(Version.Tools.Error) {
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
                [Package.Manifest.Evaluation._DependencyWire].self,
                forKey: .dependencies
            )

            var baseDependencies: [Package.Dependency.Evaluation] = []
            baseDependencies.reserveCapacity(wireDependencies.count)
            for wire in wireDependencies {
                baseDependencies.append(try Package.Dependency.Evaluation(wire))
            }

            let products =
                try container.decodeIfPresent(
                    [Package.Manifest.Product].self,
                    forKey: .products
                ) ?? []
            let targets =
                try container.decodeIfPresent(
                    [Package.Manifest.Target].self,
                    forKey: .targets
                ) ?? []
            let platforms = try container.decodeIfPresent(
                [SupportedPlatform].self,
                forKey: .platforms
            )

            self.init(
                name: name,
                toolsVersion: toolsVersion,
                dependencies: Self._backfillProducts(
                    dependencies: baseDependencies,
                    targets: targets
                ),
                products: products,
                targets: targets,
                platforms: platforms
            )
        }
    }

    extension Package.Manifest.Evaluation {

        internal static func _corrupt(_ message: Swift.String) -> DecodingError {
            DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: message)
            )
        }

        internal static func _exactlyOne<Element>(
            _ array: [Element]?,
            _ label: Swift.String
        ) throws(DecodingError) -> Element {
            guard let array else {
                throw _corrupt("\(label) is absent")
            }
            guard array.count == 1 else {
                throw _corrupt(
                    "\(label) must contain exactly one element, found \(array.count)"
                )
            }
            return array[0]
        }

        internal static func _identity(
            _ token: Swift.String,
            _ label: Swift.String
        ) throws(DecodingError) -> Package.Dependency.Evaluation.Identity {
            guard !token.isEmpty else {
                throw _corrupt("\(label).identity is empty")
            }
            return .init(token)
        }

        internal static func _traits(
            _ wire: [_TraitWire]?
        ) -> [Package.Dependency.Evaluation.Trait] {
            (wire ?? []).map { .init(name: $0.name) }
        }

        internal static func _requirement(
            _ wire: Package.Manifest._RequirementWire,
            _ label: Swift.String
        ) throws(DecodingError) -> Package.Requirement {
            do {
                return try wire.toRequirement()
            } catch let error as DecodingError {
                throw error
            } catch {
                throw _corrupt("\(label).requirement is invalid: \(error)")
            }
        }

        internal static func _registry(
            _ token: Swift.String
        ) throws(DecodingError) -> Package.Identity {
            do {
                return try Package.Manifest._parseIdentity(token)
            } catch let error as DecodingError {
                throw error
            } catch {
                throw _corrupt("registry.identity '\(token)' is invalid: \(error)")
            }
        }

        internal static func _backfillProducts(
            dependencies: [Package.Dependency.Evaluation],
            targets: [Package.Manifest.Target]
        ) -> [Package.Dependency.Evaluation] {
            var ordered: [Swift.String: [Package_Primitives.Product.Name]] = [:]
            var seen: [Swift.String: Swift.Set<Package_Primitives.Product.Name>] = [:]
            for target in targets {
                for edge in target.dependencies {
                    guard case .product(let productName, let packageName) = edge else {
                        continue
                    }
                    let token = packageName.underlying
                    if seen[token, default: []].insert(productName).inserted {
                        ordered[token, default: []].append(productName)
                    }
                }
            }
            return dependencies.map {
                (dependency: Package.Dependency.Evaluation) -> Package.Dependency.Evaluation in
                let token = dependency.identity.underlying
                guard let products = ordered[token], !products.isEmpty else {
                    return dependency
                }
                return Package.Dependency.Evaluation(
                    source: dependency.source,
                    products: products,
                    traits: dependency.traits
                )
            }
        }
    }
#endif
