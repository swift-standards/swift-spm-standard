extension Target {

    public enum Kind: Swift.String, Swift.Sendable, Swift.Hashable, Swift.CaseIterable {

        case regular

        case executable

        case test

        case plugin

        case binary

        case system

        case macro
    }
}
