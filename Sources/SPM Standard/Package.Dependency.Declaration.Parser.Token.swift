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

extension Package.Dependency.Declaration.Parser {
  struct Token: Equatable, Sendable {
    let kind: Kind
    let line: Swift.Int
    let offset: Swift.Int
  }
}
