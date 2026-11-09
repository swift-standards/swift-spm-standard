extension Package.Manifest {

    internal struct _DependencyWire: Codable {
        let fileSystem: [_FileSystemRecord]?
        let sourceControl: [_SourceControlRecord]?
        let registry: [_RegistryRecord]?

        init(
            fileSystem: [_FileSystemRecord]? = nil,
            sourceControl: [_SourceControlRecord]? = nil,
            registry: [_RegistryRecord]? = nil
        ) {
            self.fileSystem = fileSystem
            self.sourceControl = sourceControl
            self.registry = registry
        }

        init(from dependency: Package.Dependency) throws(EncodingError) {
            switch dependency.source {
            case .path(let path):
                self.init(fileSystem: [
                    _FileSystemRecord(identity: dependency.name.underlying, path: path)
                ])

            case .url(let url, let requirement):
                self.init(sourceControl: [
                    _SourceControlRecord(
                        identity: dependency.name.underlying,
                        location: .init(remote: [.init(urlString: url.value)]),
                        requirement: try _RequirementWire(from: requirement)
                    )
                ])

            case .registry(let identity, let requirement):

                self.init(registry: [
                    _RegistryRecord(
                        identity: "\(identity.scope).\(identity.name)",
                        requirement: try _RequirementWire(from: requirement)
                    )
                ])
            }
        }

    }
}
