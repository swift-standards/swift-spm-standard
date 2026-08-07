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
  public enum Error: Swift.Error, Equatable, Sendable {
    case invalidUTF8
    case unterminatedBlockComment(line: Swift.Int)
    case unterminatedString(line: Swift.Int)
  }
}

extension Package.Dependency.Declaration.Parser.Error: CustomStringConvertible {
  public var description: Swift.String {
    switch self {
    case .invalidUTF8:
      "manifest is not UTF-8"

    case .unterminatedBlockComment(let line):
      "unterminated block comment beginning at line \(line)"

    case .unterminatedString(let line):
      "unterminated string literal beginning at line \(line)"
    }
  }
}
