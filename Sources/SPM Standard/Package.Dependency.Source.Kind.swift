#if !hasFeature(Embedded)
    extension Package.Dependency.Source {
        enum Kind: Swift.String, Codable {
            case path
            case url
            case registry
        }
    }
#endif
