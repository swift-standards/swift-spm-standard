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

// Decodable conformance is excluded from Embedded Swift — it depends on stdlib
// protocols and runtime infrastructure that Embedded does not ship.
//
// **Decodable, not Codable.** Resolved state is an *observation* of what the
// installed SwiftPM wrote. SwiftPM owns that file exclusively; nothing in this
// ecosystem may synthesise it, and offering an encoder would invite exactly the
// hand-editing of resolver state that is forbidden. The encoding surface is
// therefore not offered at all rather than offered and warned against.
//
// **The schema version is checked, not ignored.** Every observed file carries
// `7`. The field exists because that can change, so a mismatch is rejected with
// a message naming both versions rather than decoded on the hope that the
// layout still matches.
//
// `artifacts` and `prebuilts` are present in every file and are deliberately
// not modelled. `artifacts` is empty in all of them. `prebuilts` is a
// toolchain-keyed build cache — every observed record is the prebuilt
// `swift-syntax` macro-support library, its path keyed by the exact toolchain
// build — which describes no dependency's source and must never take part in
// deriving a materialized path. Both are ignored rather than decoded so that a
// future change to either cannot break resolution reading.

#if !hasFeature(Embedded)
    extension Package.Resolution: Decodable {
        // One key enum spanning both levels of the envelope. A keyed container is
        // indifferent to cases it does not use, so nesting reuses this type rather
        // than declaring a second one — which would put two type declarations in a
        // file that must hold one.
        private enum CodingKeys: Swift.String, CodingKey {
            case version
            case object
            case dependencies
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let version = try container.decode(Swift.Int.self, forKey: .version)

            guard version == Package.Resolution.supportedVersion else {
                throw DecodingError.dataCorruptedError(
                    forKey: .version,
                    in: container,
                    debugDescription: """
                        Unsupported workspace-state schema version \(version); \
                        this package models version \(Package.Resolution.supportedVersion). \
                        Refusing to decode rather than risk misreading a changed layout.
                        """
                )
            }

            let object = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .object)
            self.init(
                dependencies: try object.decode(
                    [Package.Resolution.Dependency].self,
                    forKey: .dependencies
                )
            )
        }
    }
#endif
