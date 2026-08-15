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
// The state discriminator is `state.name`, and the payload is read according to
// it — never by probing which keys happen to be present. That matters because
// the three states are distinguished *only* by that name: `fileSystem` and
// `edited` carry an identical payload shape (a bare `path`), so a
// shape-sniffing decoder could not tell them apart at all.
//
// An unrecognised state name fails loudly, naming it. SwiftPM's own model also
// carries `registryDownload` and `custom`; neither appears in any observed file,
// so their JSON encoding is unknown and inventing one would be fabrication.
// Their absence is unsampled, not impossible — so the first real instance must
// surface as a clear error rather than as a silent misread.
//
// `basedOn` is read here, at record level where the wire puts it, and attached
// to the `edited` case where it belongs. A non-edited record carrying one is
// refused: it holds in every observed record, and a violation would mean the
// file describes something this model does not understand.

#if !hasFeature(Embedded)
    extension Package.Resolution.Dependency: Decodable {
        // One key enum spanning the record and its nested `state` object. A keyed
        // container ignores cases it is not asked for, so nesting reuses this type
        // rather than declaring a second one in a file that must hold one type.
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
