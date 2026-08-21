extension Product {

    public enum Kind: Swift.Sendable, Swift.Hashable {

        case library(LibraryType)

        case executable

        case plugin
    }
}
