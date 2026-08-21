extension Package.Resolution {

    public struct Checkout: Swift.Sendable, Swift.Hashable {

        public let revision: Swift.String

        public let pin: Package.Resolution.Checkout.Pin

        public init(revision: Swift.String, pin: Package.Resolution.Checkout.Pin) {
            self.revision = revision
            self.pin = pin
        }
    }
}
