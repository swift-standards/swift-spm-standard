extension Package.Dependency {

    public struct Evaluation: Swift.Sendable, Swift.Hashable {

        public let source: Source

        public let products: [Product.Name]

        public let traits: [Trait]

        public init(
            source: Source,
            products: [Product.Name] = [],
            traits: [Trait] = []
        ) {
            self.source = source
            self.products = products
            self.traits = traits
        }
    }
}

extension Package.Dependency.Evaluation {

    public var identity: Identity { source.identity }

    public var requirement: Package.Requirement? { source.requirement }
}
