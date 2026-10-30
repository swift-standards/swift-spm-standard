extension Package.Manifest {

    public struct Target: Swift::Sendable, Swift::Hashable {

        public let name: Package::Target.Name

        public let kind: Package::Target.Kind

        public let dependencies: [Package::Target.Dependency]

        public let path: Swift::String?

        /// The conditions of those `dependencies` that apply only on some platforms or under some of
        /// the package's traits.
        public let conditions: [Package::Target.Dependency: Package.Manifest.Condition]

        public init(
            name: Package::Target.Name,
            kind: Package::Target.Kind,
            dependencies: [Package::Target.Dependency] = [],
            path: Swift::String? = nil,
            conditions: [Package::Target.Dependency: Package.Manifest.Condition] = [:]
        ) {
            self.name = name
            self.kind = kind
            self.dependencies = dependencies
            self.path = path
            self.conditions = conditions
        }
    }
}
