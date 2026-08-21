extension Package.Resolution.Reference {

    public enum Kind: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {

        case root

        case fileSystem

        case localSourceControl

        case remoteSourceControl

        case registry
    }
}
