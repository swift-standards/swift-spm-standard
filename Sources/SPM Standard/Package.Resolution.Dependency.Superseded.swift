extension Package.Resolution.Dependency {

    public struct Superseded: Swift.Sendable, Swift.Hashable {

        public let reference: Package.Resolution.Reference

        public let checkout: Package.Resolution.Checkout

        public let subpath: Swift.String

        public init(
            reference: Package.Resolution.Reference,
            checkout: Package.Resolution.Checkout,
            subpath: Swift.String
        ) {
            self.reference = reference
            self.checkout = checkout
            self.subpath = subpath
        }
    }
}
