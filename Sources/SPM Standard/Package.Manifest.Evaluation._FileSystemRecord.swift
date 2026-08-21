extension Package.Manifest.Evaluation {

    internal struct _FileSystemRecord: Decodable {
        let identity: Swift.String
        let path: Swift.String
        let productFilter: [Swift.String]?
        let traits: [_TraitWire]?
    }
}
