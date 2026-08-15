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

// Shadow-resolution per the L1/L2 split research doc (2026-05-14
// "Approved", Wave 1A): inside `extension Package.Manifest`, the
// unqualified name `Target` rebinds to the inner struct, so
// `Target.Name` does NOT resolve to the outer L1 namespace. The
// field types are written module-qualified —
// `Package_Primitives.Target.Name`,
// `Package_Primitives.Target.Kind`,
// `Package_Primitives.Target.Dependency` — to bypass the shadow
// without renaming the nested struct. (Typealias-based resolutions
// fail because Swift access control rejects a `private` /
// `internal` typealias appearing in a public declaration.)
//
// `Target.Kind` and `Target.Dependency` (declared at this L2
// layer) live on `Package_Primitives.Target` via cross-module
// extension, so the module-qualified path also resolves to the
// L2 nested types.

extension Package.Manifest {
    /// A typed Swift package target description — one element of
    /// the `targets[]` array a SwiftPM `Package.swift` declares.
    ///
    /// Mirrors `PackageDescription.Target` factories:
    ///
    /// ```swift
    /// .target(name: "X", dependencies: [...], path: "Sources/X")
    /// .executableTarget(name: "X", dependencies: [...])
    /// .testTarget(name: "XTests", dependencies: [...])
    /// .plugin(name: "X", capability: ...)
    /// .binaryTarget(name: "X", path: ...)
    /// .systemLibrary(name: "X")
    /// .macro(name: "X")
    /// ```
    ///
    /// Carries the typed target ``Target/Name``, the
    /// ``Target/Kind``, and the typed dependency list using
    /// the existing ``Target/Dependency`` enum (top-level under
    /// the L1 `Target` namespace).
    ///
    /// Nested under ``Package/Manifest`` because the description
    /// is meaningful only as part of a manifest. The standalone
    /// L1 ``Target`` namespace owns the universal `Target.Name`
    /// identifier; this nested type owns the SwiftPM-specific
    /// description shape.
    public struct Target: Swift.Sendable, Swift.Hashable {
        /// The target name — the value of the
        /// `.target(name:)` / `.executableTarget(name:)` / and similar.
        ///
        /// field in `Package.swift`.
        public let name: Package_Primitives.Target.Name

        /// The target kind — `.regular`, `.executable`,
        /// `.test`, `.plugin`, `.binary`, `.system`, `.macro`.
        public let kind: Package_Primitives.Target.Kind

        /// The target's typed dependencies — `.product`,
        /// `.target`, or `.byName` form.
        public let dependencies: [Package_Primitives.Target.Dependency]

        /// The optional `path:` override. `nil` when the manifest
        /// did not declare an explicit path (SwiftPM auto-derives
        /// `Sources/<name>/`). Consumers needing the resolved path
        /// do their own derivation.
        public let path: Swift.String?

        public init(
            name: Package_Primitives.Target.Name,
            kind: Package_Primitives.Target.Kind,
            dependencies: [Package_Primitives.Target.Dependency] = [],
            path: Swift.String? = nil
        ) {
            self.name = name
            self.kind = kind
            self.dependencies = dependencies
            self.path = path
        }
    }
}
