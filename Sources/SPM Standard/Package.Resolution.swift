extension Package {

    public struct Resolution: Swift.Sendable, Swift.Hashable {

        public let dependencies: [Package.Resolution.Dependency]

        public init(dependencies: [Package.Resolution.Dependency] = []) {
            self.dependencies = dependencies
        }
    }
}

extension Package.Resolution {

    public static var supportedVersion: Swift.Int { 7 }

    public func dependency(
        for identity: Package.Resolution.Reference.Identity
    ) -> Package.Resolution.Dependency? {
        dependencies.first { $0.reference.identity == identity }
    }
}
