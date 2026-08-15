#if !hasFeature(Embedded)
    extension Package.Requirement {
        enum Kind: Swift.String, Codable {
            case from
            case upToNextMajor
            case upToNextMinor
            case range
            case exact
            case branch
            case revision
        }
    }
#endif
