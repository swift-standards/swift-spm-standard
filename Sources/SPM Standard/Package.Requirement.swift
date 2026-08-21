extension Package {

    public enum Requirement: Swift.Sendable, Swift.Hashable {

        case from(Version.Semantic)

        case upToNextMajor(from: Version.Semantic)

        case upToNextMinor(from: Version.Semantic)

        case range(Version.Range<Version.Semantic>)

        case exact(Version.Semantic)

        case branch(Swift.String)

        case revision(Swift.String)
    }
}
