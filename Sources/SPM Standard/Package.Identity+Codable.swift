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

#if !hasFeature(Embedded)
    extension Package.Identity: Codable {
        private enum CodingKeys: Swift.String, CodingKey {
            case scope
            case name
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let scope = try container.decode(Swift.String.self, forKey: .scope)
            let name = try container.decode(Swift.String.self, forKey: .name)
            self.init(scope: scope, name: name)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.scope, forKey: .scope)
            try container.encode(self.name, forKey: .name)
        }
    }
#endif
