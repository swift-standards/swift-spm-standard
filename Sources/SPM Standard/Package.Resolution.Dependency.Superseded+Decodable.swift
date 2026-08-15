// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-spm-standard open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-spm-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// See ``Package/Resolution`` for why this is Decodable-only.
//
// The superseded record's own state must be a source-control checkout. That is
// what all 91 observed superseded records carry, and it is the only shape this
// type can represent, so anything else is refused with a message naming it
// rather than narrowed silently. Note that a `basedOn` never nests: no observed
// record carries one inside another, which is why this type is not recursive.

#if !hasFeature(Embedded)
    extension Package.Resolution.Dependency.Superseded: Decodable {
        // One key enum spanning the record and its nested `state` object, for the
        // same reason as ``Package/Resolution/Dependency``'s.
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
