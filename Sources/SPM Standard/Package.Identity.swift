extension Package {

    public struct Identity: Swift.Sendable, Swift.Hashable {

        public let scope: Swift.String

        public let name: Swift.String

        public init(scope: Swift.String, name: Swift.String) {
            self.scope = scope
            self.name = name
        }
    }
}
