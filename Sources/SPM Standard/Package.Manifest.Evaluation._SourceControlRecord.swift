extension Package.Manifest.Evaluation {

    internal struct _SourceControlRecord: Decodable {
        let identity: Swift.String
        let location: _Location
        let requirement: Package.Manifest._RequirementWire
        let productFilter: [Swift.String]?
        let traits: [_TraitWire]?
    }
}
