extension Package.Manifest {

    public struct Product: Swift.Sendable, Swift.Hashable {

        public let name: Package.Product.Name

        public let kind: Package.Product.Kind

        public let targets: [Package.Target.Name]

        public init(
            name: Package.Product.Name,
            kind: Package.Product.Kind,
            targets: [Package.Target.Name]
        ) {
            self.name = name
            self.kind = kind
            self.targets = targets
        }
    }
}
