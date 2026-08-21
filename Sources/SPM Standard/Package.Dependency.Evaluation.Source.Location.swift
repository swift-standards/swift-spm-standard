extension Package.Dependency.Evaluation.Source {

    public enum Location: Swift.Sendable, Swift.Hashable {

        case remote(URI)

        case local(path: Swift.String)
    }
}
