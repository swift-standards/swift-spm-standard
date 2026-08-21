extension Package.Manifest {

    internal struct _SourceControlRecord: Codable {
        let identity: Swift.String
        let location: _Location
        let requirement: _RequirementWire
    }
}
