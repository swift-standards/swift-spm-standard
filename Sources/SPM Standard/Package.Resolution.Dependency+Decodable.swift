#if !hasFeature(Embedded)
    extension Package.Resolution.Dependency: Decodable {

        private enum CodingKeys: Swift.String, CodingKey {
            case packageRef
            case state
            case subpath
            case basedOn
            case name
            case path
            case checkoutState
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let state = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .state)
            let name = try state.decode(Swift.String.self, forKey: .name)

            let superseded = try container.decodeIfPresent(
                Package.Resolution.Dependency.Superseded.self,
                forKey: .basedOn
            )

            let resolved: Package.Resolution.Dependency.State
            switch name {
            case "sourceControlCheckout":
                resolved = .sourceControlCheckout(
                    try state.decode(Package.Resolution.Checkout.self, forKey: .checkoutState)
                )

            case "fileSystem":
                resolved = .fileSystem(path: try state.decode(Swift.String.self, forKey: .path))

            case "edited":
                resolved = .edited(
                    path: try state.decode(Swift.String.self, forKey: .path),
                    basedOn: superseded
                )

            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .name,
                    in: state,
                    debugDescription: """
                        Unrecognised managed-dependency state '\(name)'. This package models \
                        sourceControlCheckout, fileSystem, and edited. SwiftPM also declares \
                        registryDownload and custom, whose wire encoding has not been \
                        observed and is therefore not modelled rather than guessed.
                        """
                )
            }

            if superseded != nil, name != "edited" {
                throw DecodingError.dataCorruptedError(
                    forKey: .basedOn,
                    in: container,
                    debugDescription: """
                        A '\(name)' dependency carries 'basedOn'. Only an edited dependency \
                        supersedes a managed checkout; every one of the 91 observed \
                        non-null 'basedOn' values sits on an edited record.
                        """
                )
            }

            self.init(
                reference: try container.decode(
                    Package.Resolution.Reference.self,
                    forKey: .packageRef
                ),
                state: resolved,
                subpath: try container.decode(Swift.String.self, forKey: .subpath)
            )
        }
    }
#endif
