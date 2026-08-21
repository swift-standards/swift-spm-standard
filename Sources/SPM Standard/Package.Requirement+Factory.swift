@inlinable
public func ..< (
    lower: Version.Semantic,
    upper: Version.Semantic
) -> Package.Requirement {
    .range(
        Version.Range(
            lowerBound: .inclusive(lower),
            upperBound: .exclusive(upper)
        )
    )
}
