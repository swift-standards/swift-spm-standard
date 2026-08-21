extension Package.Manifest.Evaluation {

    internal struct _DependencyWire: Decodable {
        let fileSystem: [_FileSystemRecord]?
        let sourceControl: [_SourceControlRecord]?
        let registry: [_RegistryRecord]?
    }
}
