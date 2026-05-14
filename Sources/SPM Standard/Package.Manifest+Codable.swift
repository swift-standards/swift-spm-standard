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
// Wire-format shape — mirrors `swift package dump-package`'s JSON
// output. Only the v0.2 surface (``name``, ``toolsVersion``,
// ``dependencies``) is decoded; richer fields (``products``,
// ``targets``, ``platforms``, ``packageKind``, etc.) are silently
// ignored per the structural-naming hold documented in
// ``Package/Manifest`` (lines 32–42).
//
// Top-level shape:
//
// ```
// {
//   "name": "swift-foo",
//   "toolsVersion": { "_version": "6.3.1" },
//   "dependencies": [ <Dependency wire form>, ... ],
//   ... (extras silently ignored)
// }
// ```
//
// Dependency wire form is a discriminated union per element — one of
// `fileSystem` / `sourceControl` / `registry`, each carrying an array
// of one inner record:
//
// ```
// {
//   "fileSystem": [{
//     "identity": "swift-foo",
//     "path": "/abs/path/to/swift-foo",
//     "productFilter": null,
//     "traits": [ ... ]
//   }]
// }
// ```
//
// ```
// {
//   "sourceControl": [{
//     "identity": "swift-foo",
//     "location": { "remote": [ { "urlString": "https://..." } ] },
//     "requirement": <Requirement wire form>,
//     "productFilter": null,
//     "traits": [ ... ]
//   }]
// }
// ```
//
// ```
// {
//   "registry": [{
//     "identity": "scope.name",
//     "requirement": <Requirement wire form>,
//     "productFilter": null,
//     "traits": [ ... ]
//   }]
// }
// ```
//
// Requirement wire form (discriminated by single key):
//
// ```
// {"exact": ["1.0.0"]}
// {"range": [{"lowerBound": "1.0.0", "upperBound": "2.0.0"}]}
// {"branch": ["main"]}
// {"revision": ["abc123"]}
// ```
//
// `Package.Dependency.products` is empty `[]` after decoding from a
// `dump-package` document — the per-target product references live
// under `targets[].dependencies[]`, not at the workspace dependency
// record. Consumers that need product binding combine the manifest
// with target-level data (out of v0.2 scope; see the structural-naming
// hold).

// swiftlint:disable no_any_protocol_existential typed_throws_required
#if !hasFeature(Embedded)
    extension Package.Manifest: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case name
            case toolsVersion
            case dependencies
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // `name` decoded as bare string — `Package.Name` is
            // `Tagged<Package, String>` and Tagged's auto-synthesised
            // Codable uses a keyed container (`{"underlying": "..."}`)
            // which does not match the dump-package wire shape.
            // Use `_unchecked:` to disambiguate from the optional
            // `LosslessStringConvertible` init that the
            // `Tagged Primitives Standard Library Integration` target
            // makes available.
            let nameString = try container.decode(Swift.String.self, forKey: .name)
            let name = Package.Name(_unchecked: nameString)
            let toolsWire = try container.decode(_ToolsVersionWire.self, forKey: .toolsVersion)
            let toolsVersion: Version.Tools
            do {
                toolsVersion = try Version.Tools(parsing: toolsWire._version)
            } catch {
                throw DecodingError.dataCorruptedError(
                    forKey: .toolsVersion,
                    in: container,
                    debugDescription: "Invalid tools-version string '\(toolsWire._version)': \(error)"
                )
            }
            let wireDependencies = try container.decode(
                [_DependencyWire].self, forKey: .dependencies
            )
            let dependencies = try wireDependencies.map { wire in
                try wire.toDependency()
            }
            self.init(name: name, toolsVersion: toolsVersion, dependencies: dependencies)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.name.underlying, forKey: .name)
            try container.encode(
                _ToolsVersionWire(_version: self.toolsVersion.description),
                forKey: .toolsVersion
            )
            let wireDependencies = self.dependencies.map { _DependencyWire(from: $0) }
            try container.encode(wireDependencies, forKey: .dependencies)
        }

        // MARK: - Wire-format shims

        private struct _ToolsVersionWire: Codable {
            let _version: Swift.String
        }

        private struct _DependencyWire: Codable {
            let fileSystem: [_FileSystemRecord]?
            let sourceControl: [_SourceControlRecord]?
            let registry: [_RegistryRecord]?

            init(
                fileSystem: [_FileSystemRecord]? = nil,
                sourceControl: [_SourceControlRecord]? = nil,
                registry: [_RegistryRecord]? = nil
            ) {
                self.fileSystem = fileSystem
                self.sourceControl = sourceControl
                self.registry = registry
            }

            init(from dependency: Package.Dependency) {
                switch dependency.source {
                case .path(let path):
                    self.init(fileSystem: [
                        _FileSystemRecord(identity: dependency.name.underlying, path: path)
                    ])
                case .url(let url, let requirement):
                    self.init(sourceControl: [
                        _SourceControlRecord(
                            identity: dependency.name.underlying,
                            location: .init(remote: [.init(urlString: url)]),
                            requirement: _RequirementWire(from: requirement)
                        )
                    ])
                case .registry(let identity, let requirement):
                    self.init(registry: [
                        _RegistryRecord(
                            identity: "\(identity.scope).\(identity.name)",
                            requirement: _RequirementWire(from: requirement)
                        )
                    ])
                }
            }

            func toDependency() throws -> Package.Dependency {
                if let record = fileSystem?.first {
                    return Package.Dependency(
                        source: .path(record.path),
                        name: Package.Name(_unchecked: record.identity),
                        products: []
                    )
                }
                if let record = sourceControl?.first {
                    let urlString = record.location.remote.first?.urlString ?? ""
                    let requirement = try record.requirement.toRequirement()
                    return Package.Dependency(
                        source: .url(urlString, requirement),
                        name: Package.Name(_unchecked: record.identity),
                        products: []
                    )
                }
                if let record = registry?.first {
                    let requirement = try record.requirement.toRequirement()
                    return Package.Dependency(
                        source: .registry(
                            try _parseIdentity(record.identity),
                            requirement
                        ),
                        name: Package.Name(_unchecked: record.identity),
                        products: []
                    )
                }
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Dependency record matched none of fileSystem/sourceControl/registry"
                    )
                )
            }
        }

        private struct _FileSystemRecord: Codable {
            let identity: Swift.String
            let path: Swift.String
        }

        private struct _SourceControlRecord: Codable {
            let identity: Swift.String
            let location: _Location
            let requirement: _RequirementWire

            struct _Location: Codable {
                let remote: [_Remote]

                struct _Remote: Codable {
                    let urlString: Swift.String
                }
            }
        }

        private struct _RegistryRecord: Codable {
            let identity: Swift.String
            let requirement: _RequirementWire
        }

        private struct _RequirementWire: Codable {
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

        private struct _RangeBounds: Codable {
            let lowerBound: Swift.String
            let upperBound: Swift.String
        }
    }

    // MARK: - Local parsing helpers

    private func _parseSemantic(_ string: Swift.String) throws -> Version.Semantic {
        do {
            return try Version.Semantic(parsing: string)
        } catch {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid semantic version '\(string)': \(error)"
                )
            )
        }
    }

    private func _parseIdentity(_ string: Swift.String) throws -> Package.Identity {
        // Registry identity is "scope.name" per SE-0292.
        guard let dot = string.firstIndex(of: ".") else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid registry identity '\(string)' — expected 'scope.name'"
                )
            )
        }
        let scope = Swift.String(string[..<dot])
        let name = Swift.String(string[string.index(after: dot)...])
        return Package.Identity(scope: scope, name: name)
    }
#endif
// swiftlint:enable no_any_protocol_existential typed_throws_required
