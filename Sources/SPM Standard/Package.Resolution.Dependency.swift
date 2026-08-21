extension Package.Resolution {

    public struct Dependency: Swift.Sendable, Swift.Hashable {

        public let reference: Package.Resolution.Reference

        public let state: Package.Resolution.Dependency.State

        public let subpath: Swift.String

        public init(
            reference: Package.Resolution.Reference,
            state: Package.Resolution.Dependency.State,
            subpath: Swift.String
        ) {
            self.reference = reference
            self.state = state
            self.subpath = subpath
        }
    }
}

extension Package.Resolution.Dependency {

    public var revision: Swift.String? { state.checkout?.revision }
}
