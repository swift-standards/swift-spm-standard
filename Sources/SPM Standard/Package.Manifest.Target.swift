extension Package.Manifest {

    public struct Target: Swift::Sendable, Swift::Hashable {

        public let name: Package::Target.Name

        public let kind: Package::Target.Kind

        public let dependencies: [Package::Target.Dependency]

        public let path: Swift::String?

        public init(
            name: Package::Target.Name,
            kind: Package::Target.Kind,
            dependencies: [Package::Target.Dependency] = [],
            path: Swift::String? = nil
        ) {
            self.name = name
            self.kind = kind
            self.dependencies = dependencies
            self.path = path
        }
    }
}
