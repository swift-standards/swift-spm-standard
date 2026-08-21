extension Package.Manifest {

    internal struct _RegistryRecord: Codable {
        let identity: Swift.String
        let requirement: _RequirementWire
    }
}
