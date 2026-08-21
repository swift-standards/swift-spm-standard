extension Package.Dependency.Evaluation {

    public struct Trait: Swift.Sendable, Swift.Hashable {

        public let name: Swift.String

        public init(name: Swift.String) {
            self.name = name
        }
    }
}
