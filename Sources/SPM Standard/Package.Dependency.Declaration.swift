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

extension Package.Dependency {
  /// One `.package(...)` call found in a manifest.
  public enum Declaration: Equatable, Sendable {
    case url(Swift.String, line: Swift.Int)
    case path(Swift.String?, line: Swift.Int)
    case registry(Swift.String?, line: Swift.Int)
    case malformed(Swift.String, line: Swift.Int)
  }
}

extension Package.Dependency.Declaration {
  public var line: Swift.Int {
    switch self {
    case .url(_, let line), .path(_, let line), .registry(_, let line),
      .malformed(_, let line):
      line
    }
  }
}
