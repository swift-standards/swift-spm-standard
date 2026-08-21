#if !hasFeature(Embedded)
    extension Package.Dependency.Evaluation.Source.Location {

        internal init(
            _ wire: Package.Manifest.Evaluation._SourceControlRecord._Location
        ) throws(DecodingError) {
            switch (wire.remote, wire.local) {
            case (nil, nil):
                throw Package.Manifest.Evaluation._corrupt(
                    "sourceControl.location has neither 'remote' nor 'local'"
                )

            case (.some, .some):
                throw Package.Manifest.Evaluation._corrupt(
                    "sourceControl.location is ambiguous — both 'remote' and 'local' are present"
                )

            case (.some(let remotes), nil):
                let record = try Package.Manifest.Evaluation._exactlyOne(
                    remotes,
                    "sourceControl.location.remote"
                )
                guard !record.urlString.isEmpty else {
                    throw Package.Manifest.Evaluation._corrupt(
                        "sourceControl.location.remote[0].urlString is empty"
                    )
                }
                let uri: URI
                do throws(RFC_3986.Error) {
                    uri = try URI(record.urlString)
                } catch {
                    throw Package.Manifest.Evaluation._corrupt(
                        "Invalid URI '\(record.urlString)' in sourceControl.location.remote: \(error)"
                    )
                }
                self = .remote(uri)

            case (nil, .some(let paths)):
                let path = try Package.Manifest.Evaluation._exactlyOne(
                    paths,
                    "sourceControl.location.local"
                )
                guard !path.isEmpty else {
                    throw Package.Manifest.Evaluation._corrupt(
                        "sourceControl.location.local[0] is an empty path"
                    )
                }
                self = .local(path: path)
            }
        }
    }
#endif
