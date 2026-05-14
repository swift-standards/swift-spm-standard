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

extension Package.Manifest._SourceControlRecord._Location {
    /// Wire-format shim for one entry in the `remote` array of a
    /// ``_Location``.
    ///
    /// JSON shape: `{ "urlString": "https://..." }`.
    internal struct _Remote: Codable {
        let urlString: Swift.String
    }
}
