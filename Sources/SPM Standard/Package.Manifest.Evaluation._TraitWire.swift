extension Package.Manifest.Evaluation {

    internal struct _TraitWire: Decodable {
        let name: Swift::String
        let condition: Package.Manifest.Condition?
    }
}
