extension Package.Manifest {

    internal struct _RequirementWire: Codable {
        let exact: [Swift::String]?
        let range: [_RangeBounds]?
        let branch: [Swift::String]?
        let revision: [Swift::String]?

        init(
            exact: [Swift::String]? = nil,
            range: [_RangeBounds]? = nil,
            branch: [Swift::String]? = nil,
            revision: [Swift::String]? = nil
        ) {
            self.exact = exact
            self.range = range
            self.branch = branch
            self.revision = revision
        }

        init(from requirement: Package.Requirement) throws(EncodingError) {
            switch requirement {
            case .exact(let version):
                self.init(exact: [version.description])

            case .range(let r):
                guard case .inclusive(let lower) = r.lowerBound,
                    case .exclusive(let upper) = r.upperBound
                else {
                    throw EncodingError.invalidValue(
                        requirement,
                        EncodingError.Context(
                            codingPath: [],
                            debugDescription:
                                "a manifest range is lower-inclusive and upper-exclusive; unbounded, exclusive lower and inclusive upper bounds are not part of the SwiftPM wire format"
                        )
                    )
                }
                self.init(
                    range: [_RangeBounds(lowerBound: lower.description, upperBound: upper.description)]
                )

            case .branch(let name):
                self.init(branch: [name])

            case .revision(let sha):
                self.init(revision: [sha])

            case .from(let v), .upToNextMajor(from: let v):
                let upper = "\(v.major.underlying + 1).0.0"
                self.init(range: [_RangeBounds(lowerBound: v.description, upperBound: upper)])

            case .upToNextMinor(from: let v):
                let upper = "\(v.major.underlying).\(v.minor.underlying + 1).0"

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

    }
}
