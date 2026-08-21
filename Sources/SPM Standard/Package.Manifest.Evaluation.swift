extension Package.Manifest {

    public struct Evaluation: Swift.Sendable, Swift.Hashable {

        public let name: Package.Name

        public let toolsVersion: Version.Tools

        public let dependencies: [Package.Dependency.Evaluation]

        public let products: [Package.Manifest.Product]

        public let targets: [Package.Manifest.Target]

        public let platforms: [SupportedPlatform]?

        public init(
            name: Package.Name,
            toolsVersion: Version.Tools,
            dependencies: [Package.Dependency.Evaluation] = [],
            products: [Package.Manifest.Product] = [],
            targets: [Package.Manifest.Target] = [],
            platforms: [SupportedPlatform]? = nil
        ) {
            self.name = name
            self.toolsVersion = toolsVersion
            self.dependencies = dependencies
            self.products = products
            self.targets = targets
            self.platforms = platforms
        }
    }
}
