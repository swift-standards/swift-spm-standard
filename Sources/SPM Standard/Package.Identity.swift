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

extension Package {
    /// Registry-form identity per SE-0292: a `<scope>.<name>`
    /// composite identifying a package in the Swift Package
    /// Registry.
    ///
    /// Used as the registry-form ``Package/Dependency/Source``
    /// associated value. Today's Institute ecosystem does not yet
    /// resolve dependencies via the registry; the type is
    /// specified ahead of adoption so consumers (analyzers,
    /// graph builders) can pattern-match the case without
    /// rework when registry-form deps appear in the wild.
    public struct Identity: Swift.Sendable, Swift.Hashable {
        /// The registry scope (the package authority namespace).
        public let scope: Swift.String

        /// The package name within the scope.
        public let name: Swift.String

        public init(scope: Swift.String, name: Swift.String) {
            self.scope = scope
            self.name = name
        }
    }
}
