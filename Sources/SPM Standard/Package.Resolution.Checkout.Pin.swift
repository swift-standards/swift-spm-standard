extension Package.Resolution.Checkout {

    public enum Pin: Swift.Sendable, Swift.Hashable {

        case branch(Swift.String)

        case version(Version.Semantic)
    }
}
