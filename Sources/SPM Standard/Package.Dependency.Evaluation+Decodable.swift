#if !hasFeature(Embedded)
    extension Package.Dependency.Evaluation: Decodable {
        public init(from decoder: any Decoder) throws {
            self = try .init(Package.Manifest.Evaluation._DependencyWire(from: decoder))
        }
    }

    extension Package.Dependency.Evaluation {

        internal init(
            _ wire: Package.Manifest.Evaluation._DependencyWire
        ) throws(DecodingError) {
            let present =
                [wire.fileSystem != nil, wire.sourceControl != nil, wire.registry != nil]
                .filter { $0 }
                .count
            guard present == 1 else {
                throw Package.Manifest.Evaluation._corrupt(
                    present == 0
                        ? "Dependency record matched none of fileSystem/sourceControl/registry"
                        : "Dependency record is ambiguous — \(present) discriminators are present"
                )
            }

            if let records = wire.fileSystem {
                let record = try Package.Manifest.Evaluation._exactlyOne(records, "fileSystem")
                guard !record.path.isEmpty else {
                    throw Package.Manifest.Evaluation._corrupt("fileSystem.path is empty")
                }
                self.init(
                    source: .fileSystem(
                        identity: try Package.Manifest.Evaluation._identity(
                            record.identity,
                            "fileSystem"
                        ),
                        path: record.path
                    ),
                    traits: Package.Manifest.Evaluation._traits(record.traits)
                )
                return
            }
            if let records = wire.sourceControl {
                let record = try Package.Manifest.Evaluation._exactlyOne(records, "sourceControl")
                self.init(
                    source: .sourceControl(
                        identity: try Package.Manifest.Evaluation._identity(
                            record.identity,
                            "sourceControl"
                        ),
                        location: try .init(record.location),
                        requirement: try Package.Manifest.Evaluation._requirement(
                            record.requirement,
                            "sourceControl"
                        )
                    ),
                    traits: Package.Manifest.Evaluation._traits(record.traits)
                )
                return
            }
            let record = try Package.Manifest.Evaluation._exactlyOne(wire.registry, "registry")
            guard !record.identity.isEmpty else {
                throw Package.Manifest.Evaluation._corrupt("registry.identity is empty")
            }
            self.init(
                source: .registry(
                    identity: try Package.Manifest.Evaluation._registry(record.identity),
                    requirement: try Package.Manifest.Evaluation._requirement(
                        record.requirement,
                        "registry"
                    )
                ),
                traits: Package.Manifest.Evaluation._traits(record.traits)
            )
        }
    }
#endif
