extension Package.Resolution {

    public struct Reference: Swift.Sendable, Swift.Hashable {

        public let identity: Package.Resolution.Reference.Identity

        public let kind: Package.Resolution.Reference.Kind

        public let location: Swift.String

        public let name: Swift.String

        public init(
            identity: Package.Resolution.Reference.Identity,
            kind: Package.Resolution.Reference.Kind,
            location: Swift.String,
            name: Swift.String
        ) {
            self.identity = identity
            self.kind = kind
            self.location = location
            self.name = name
        }
    }
}
