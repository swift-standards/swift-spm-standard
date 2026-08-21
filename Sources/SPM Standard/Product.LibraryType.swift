extension Product {

    public enum LibraryType: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {

        case `static`

        case `dynamic`

        case automatic
    }
}
