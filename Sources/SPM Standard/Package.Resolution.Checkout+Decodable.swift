#if !hasFeature(Embedded)
    extension Package.Resolution.Checkout: Decodable {
        private enum CodingKeys: Swift.String, CodingKey {
            case revision
            case branch
            case version
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let revision = try container.decode(Swift.String.self, forKey: .revision)

            let branch = try container.decodeIfPresent(Swift.String.self, forKey: .branch)
            let version = try container.decodeIfPresent(Swift.String.self, forKey: .version)

            switch (branch, version) {
            case (.some(let branch), .none):
                self.init(revision: revision, pin: .branch(branch))

            case (.none, .some(let version)):
                let semantic: Version.Semantic
                do throws(Version.Semantic.Error) {
                    semantic = try Version.Semantic(parsing: version)
                } catch {
                    throw DecodingError.dataCorruptedError(
                        forKey: .version,
                        in: container,
                        debugDescription: "Checkout version '\(version)' is not a semantic version."
                    )
                }
                self.init(revision: revision, pin: .version(semantic))

            case (.some, .some):
                throw DecodingError.dataCorruptedError(
                    forKey: .branch,
                    in: container,
                    debugDescription: """
                        Checkout state carries both 'branch' and 'version'. These are \
                        mutually exclusive in every observed record; a checkout pinned to \
                        both is not a state this model can represent.
                        """
                )

            case (.none, .none):
                throw DecodingError.dataCorruptedError(
                    forKey: .revision,
                    in: container,
                    debugDescription: """
                        Checkout state carries neither 'branch' nor 'version'. A revision \
                        alone does not record what it was resolved from.
                        """
                )
            }
        }
    }
#endif
