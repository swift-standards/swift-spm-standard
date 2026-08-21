extension Package.Dependency {

    public enum Declaration: Equatable, Sendable {
        case url(Swift.String, line: Swift.Int)
        case path(Swift.String?, line: Swift.Int)
        case registry(Swift.String?, line: Swift.Int)
        case malformed(Swift.String, line: Swift.Int)
    }
}

extension Package.Dependency.Declaration {
    public var line: Swift.Int {
        switch self {
        case .url(_, let line), .path(_, let line), .registry(_, let line),
            .malformed(_, let line):
            line
        }
    }
}
