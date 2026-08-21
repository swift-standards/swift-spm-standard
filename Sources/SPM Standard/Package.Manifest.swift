extension Package {

    public struct Manifest: Swift.Sendable, Swift.Hashable {

        public let name: Package.Name

        public let toolsVersion: Version.Tools

        public let dependencies: [Package.Dependency]

        public let products: [Manifest.Product]

        public let targets: [Manifest.Target]

        public let platforms: [SupportedPlatform]?

        public init(
            name: Package.Name,
            toolsVersion: Version.Tools,
            dependencies: [Package.Dependency] = [],
            products: [Manifest.Product] = [],
            targets: [Manifest.Target] = [],
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
