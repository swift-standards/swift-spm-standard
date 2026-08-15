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

// Codable conformance is excluded from Embedded Swift — `Codable`
// depends on stdlib protocols and runtime infrastructure that the
// Embedded mode does not ship.
//
// `Codable`'s protocol requirements force existential coder
// parameters and untyped `throws`; both rules are deliberately
// exempted for this file's conformance block.
//
// Wire-format shape — discriminated union via "kind" key:
//
// ```
// {"kind":"path","path":"../swift-foo"}
// {"kind":"url","url":"https://...","requirement":{...}}
// {"kind":"registry","identity":{"scope":"...","name":"..."},"requirement":{...}}
// ```

#if !hasFeature(Embedded)
    extension Package.Dependency.Source: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case kind
            case path
            case url
            case identity
            case requirement
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .kind)
            switch kind {
            case .path:
                self = .path(try container.decode(Swift.String.self, forKey: .path))

            case .url:
                let urlString = try container.decode(Swift.String.self, forKey: .url)
                let url: URI
                do {
                    url = try URI(urlString)
                } catch {
                    throw DecodingError.dataCorruptedError(
                        forKey: .url,
                        in: container,
                        debugDescription: "Invalid URI '\(urlString)': \(error)"
                    )
                }
                let requirement = try container.decode(
                    Package.Requirement.self,
                    forKey: .requirement
                )
                self = .url(url, requirement)

            case .registry:
                let identity = try container.decode(Package.Identity.self, forKey: .identity)
                let requirement = try container.decode(
                    Package.Requirement.self,
                    forKey: .requirement
                )
                self = .registry(identity, requirement)
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .path(let path):
                try container.encode(Kind.path, forKey: .kind)
                try container.encode(path, forKey: .path)

            case .url(let url, let requirement):
                try container.encode(Kind.url, forKey: .kind)
                try container.encode(url.value, forKey: .url)
                try container.encode(requirement, forKey: .requirement)

            case .registry(let identity, let requirement):
                try container.encode(Kind.registry, forKey: .kind)
                try container.encode(identity, forKey: .identity)
                try container.encode(requirement, forKey: .requirement)
            }
        }
    }
#endif
