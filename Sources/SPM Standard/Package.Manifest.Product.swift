extension Package.Manifest {

    public struct Product: Swift.Sendable, Swift.Hashable {

        public let name: Package_Primitives.Product.Name

        public let kind: Package_Primitives.Product.Kind

        public let targets: [Package_Primitives.Target.Name]

        public init(
            name: Package_Primitives.Product.Name,
            kind: Package_Primitives.Product.Kind,
            targets: [Package_Primitives.Target.Name]
        ) {
            self.name = name
            self.kind = kind
            self.targets = targets
        }
    }
}
