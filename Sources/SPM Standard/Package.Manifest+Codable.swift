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
// ``Package/Manifest``.
//
// The wire-format shim types (``_ToolsVersionWire``,
// ``_DependencyWire``, ``_FileSystemRecord``, ``_SourceControlRecord``
// + its nested ``_Location``/``_Remote``, ``_RegistryRecord``,
// ``_RequirementWire``, ``_RangeBounds``) each live in their own
// `.swift` file per `[API-IMPL-005]`. The local parsing helpers
// (``_parseSemantic``, ``_parseIdentity``) live at the bottom of
// this file as `internal static` methods on ``Package/Manifest``.

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
    }

    // MARK: - Local parsing helpers

    extension Package.Manifest {
        /// Parse a `"X.Y.Z"` SemVer string from a dump-package wire
        /// record into ``Version/Semantic``. Throws a
        /// `DecodingError.dataCorrupted` if the parse fails.
        internal static func _parseSemantic(
            _ string: Swift.String
        ) throws -> Version.Semantic {
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

        /// Parse a `"scope.name"` registry identity from a
        /// dump-package wire record into ``Package/Identity``.
        /// Throws a `DecodingError.dataCorrupted` if the format
        /// does not match SE-0292 `scope.name`.
        internal static func _parseIdentity(
            _ string: Swift.String
        ) throws -> Package.Identity {
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
    }
#endif
// swiftlint:enable no_any_protocol_existential typed_throws_required
