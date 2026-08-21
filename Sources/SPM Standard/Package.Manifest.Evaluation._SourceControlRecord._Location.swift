extension Package.Manifest.Evaluation._SourceControlRecord {

    internal struct _Location: Decodable {
        let remote: [Package.Manifest._SourceControlRecord._Location._Remote]?
        let local: [Swift.String]?
    }
}
