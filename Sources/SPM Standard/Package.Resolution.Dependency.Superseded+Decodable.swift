#if !hasFeature(Embedded)
    extension Package.Resolution.Dependency.Superseded: Decodable {

        private enum CodingKeys: Swift.String, CodingKey {
            case packageRef
            case state
            case subpath
            case name
            case checkoutState
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let state = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .state)
            let name = try state.decode(Swift.String.self, forKey: .name)

            guard name == "sourceControlCheckout" else {
                throw DecodingError.dataCorruptedError(
                    forKey: .name,
                    in: state,
                    debugDescription: """
                        A superseded dependency has state '\(name)'; only \
                        'sourceControlCheckout' is representable here, and it is what all \
                        91 observed superseded records carry. An edit displacing anything \
                        else is a shape this model has not seen and will not guess at.
                        """
                )
            }

            self.init(
                reference: try container.decode(
                    Package.Resolution.Reference.self,
                    forKey: .packageRef
                ),
                checkout: try state.decode(
                    Package.Resolution.Checkout.self,
                    forKey: .checkoutState
                ),
                subpath: try container.decode(Swift.String.self, forKey: .subpath)
            )
        }
    }
#endif
