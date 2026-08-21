extension Package.Dependency.Declaration.Parser {
    struct Token: Equatable, Sendable {
        let kind: Kind
        let line: Swift.Int
        let offset: Swift.Int
    }
}
