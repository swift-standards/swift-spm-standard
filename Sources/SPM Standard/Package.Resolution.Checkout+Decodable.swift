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
// The pin is decided by **which key is present**, never by the shape of its
// value. Four of the nine branch names observed on the reference machine are
// version-shaped (`1.6.1`, `1.10.1`, `1.1.6`, `3.12.5`), so a decoder that
// sniffed the string would misclassify every one of them.
//
// Both keys present, or neither, is rejected. Neither occurs in 26,631 observed
// records, and both are unrepresentable in ``Package/Resolution/Checkout/Pin``
// by construction — so a wire that carried either would be describing something
// this model does not understand, and saying so is better than picking one.

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
