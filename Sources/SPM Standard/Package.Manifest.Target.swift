extension Package.Manifest {

    public struct Target: Swift.Sendable, Swift.Hashable {

        public let name: Package_Primitives.Target.Name

        public let kind: Package_Primitives.Target.Kind

        public let dependencies: [Package_Primitives.Target.Dependency]

        public let path: Swift.String?

        public init(
            name: Package_Primitives.Target.Name,
            kind: Package_Primitives.Target.Kind,
            dependencies: [Package_Primitives.Target.Dependency] = [],
            path: Swift.String? = nil
        ) {
            self.name = name
            self.kind = kind
            self.dependencies = dependencies
            self.path = path
        }
    }
}
