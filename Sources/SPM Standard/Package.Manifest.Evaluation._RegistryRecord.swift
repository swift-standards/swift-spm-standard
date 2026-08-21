extension Package.Manifest.Evaluation {

    internal struct _RegistryRecord: Decodable {
        let identity: Swift.String
        let requirement: Package.Manifest._RequirementWire
        let productFilter: [Swift.String]?
        let traits: [_TraitWire]?
    }
}
