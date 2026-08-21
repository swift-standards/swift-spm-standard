extension Target {

    public enum Dependency: Swift.Sendable, Swift.Hashable {

        case product(name: Product.Name, package: Package.Name)

        case target(name: Target.Name)

        case byName(Swift.String)
    }
}
