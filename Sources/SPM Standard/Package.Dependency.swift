extension Package {
    public struct Dependency: Swift::Sendable, Swift::Hashable {
        public let source: Source

        public let name: Package.Name

        public let products: [Product.Name]

        public init(source: Source, name: Package.Name, products: [Product.Name]) {
            self.source = source
            self.name = name
            self.products = products
        }
    }
}

extension Package.Dependency {
    public enum Source: Swift::Sendable, Swift::Hashable {
        case path(Swift::String)

        case url(URI, Package.Requirement)

        case registry(Package.Identity, Package.Requirement)
    }
}
