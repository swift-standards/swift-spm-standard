extension Package.Dependency.Evaluation {

    public enum Source: Swift.Sendable, Swift.Hashable {

        case fileSystem(identity: Package.Dependency.Evaluation.Identity, path: Swift.String)

        case sourceControl(
            identity: Package.Dependency.Evaluation.Identity,
            location: Location,
            requirement: Package.Requirement
        )

        case registry(identity: Package.Identity, requirement: Package.Requirement)
    }
}

extension Package.Dependency.Evaluation.Source {

    public var identity: Package.Dependency.Evaluation.Identity {
        switch self {
        case .fileSystem(let identity, _): identity
        case .sourceControl(let identity, _, _): identity
        case .registry(let identity, _): .init("\(identity.scope).\(identity.name)")
        }
    }

    public var requirement: Package.Requirement? {
        switch self {
        case .fileSystem: nil
        case .sourceControl(_, _, let requirement): requirement
        case .registry(_, let requirement): requirement
        }
    }
}
