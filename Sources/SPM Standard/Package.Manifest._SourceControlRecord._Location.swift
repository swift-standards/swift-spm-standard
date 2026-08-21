extension Package.Manifest._SourceControlRecord {

    internal struct _Location: Codable {
        let remote: [_Remote]
    }
}
