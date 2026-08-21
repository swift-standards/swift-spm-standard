extension Package.Dependency.Source {

    @inlinable
    public static func url(
        _ url: URI,
        from version: Version.Semantic
    ) -> Self {
        .url(url, .from(version))
    }

    @inlinable
    public static func url(
        _ url: URI,
        exact version: Version.Semantic
    ) -> Self {
        .url(url, .exact(version))
    }

    @inlinable
    public static func url(
        _ url: URI,
        branch: Swift.String
    ) -> Self {
        .url(url, .branch(branch))
    }

    @inlinable
    public static func url(
        _ url: URI,
        revision: Swift.String
    ) -> Self {
        .url(url, .revision(revision))
    }

    @inlinable
    public static func registry(
        _ identity: Package.Identity,
        from version: Version.Semantic
    ) -> Self {
        .registry(identity, .from(version))
    }

    @inlinable
    public static func registry(
        _ identity: Package.Identity,
        exact version: Version.Semantic
    ) -> Self {
        .registry(identity, .exact(version))
    }
}
