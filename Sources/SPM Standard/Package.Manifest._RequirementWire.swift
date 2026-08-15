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

extension Package.Manifest {
    /// Wire-format shim for the `requirement` field of a `sourceControl`
    /// or `registry` dependency entry. Discriminated by single key
    /// among `exact`, `range`, `branch`, `revision`.
    ///
    /// JSON shapes:
    ///
    /// ```
    /// {"exact": ["1.0.0"]}
    /// {"range": [{"lowerBound": "1.0.0", "upperBound": "2.0.0"}]}
    /// {"branch": ["main"]}
    /// {"revision": ["abc123"]}
    /// ```
    internal struct _RequirementWire: Codable {
        let exact: [Swift.String]?
        let range: [_RangeBounds]?
        let branch: [Swift.String]?
        let revision: [Swift.String]?

        init(
            exact: [Swift.String]? = nil,
            range: [_RangeBounds]? = nil,
            branch: [Swift.String]? = nil,
            revision: [Swift.String]? = nil
        ) {
            self.exact = exact
            self.range = range
            self.branch = branch
            self.revision = revision
        }

        init(from requirement: Package.Requirement) {
            switch requirement {
            case .exact(let version):
                self.init(exact: [version.description])

            case .range(let r):
                let lower: Swift.String
                let upper: Swift.String
                switch r.lowerBound {
                case .inclusive(let v), .exclusive(let v): lower = v.description
                case .unbounded: lower = ""
                }
                switch r.upperBound {
                case .inclusive(let v), .exclusive(let v): upper = v.description
                case .unbounded: upper = ""
                }
                self.init(range: [_RangeBounds(lowerBound: lower, upperBound: upper)])

            case .branch(let name):
                self.init(branch: [name])

            case .revision(let sha):
                self.init(revision: [sha])

            case .from(let v), .upToNextMajor(from: let v):
                let upper = "\(v.major.underlying + 1).0.0"
                self.init(range: [_RangeBounds(lowerBound: v.description, upperBound: upper)])

            case .upToNextMinor(from: let v):
                let upper = "\(v.major.underlying).\(v.minor.underlying + 1).0"
                // REASON: DecodingError feeds the untyped Decodable path
                // swiftlint:disable typed_throws_required
                self.init(range: [_RangeBounds(lowerBound: v.description, upperBound: upper)])
            }
        }

        func toRequirement() throws -> Package.Requirement {
            if let v = exact?.first {
                return .exact(try _parseSemantic(v))
            }
            if let bounds = range?.first {
                let lower = try _parseSemantic(bounds.lowerBound)
                let upper = try _parseSemantic(bounds.upperBound)
                return lower..<upper
            }
            if let name = branch?.first {
                return .branch(name)
            }
            if let sha = revision?.first {
                return .revision(sha)
            }
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Requirement matched none of exact/range/branch/revision"
                )
            )
        }
        // swiftlint:enable typed_throws_required
    }
}
