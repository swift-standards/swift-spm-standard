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

import Testing

@testable import SPM_Standard

extension `SPM Standard Tests` {
  @Suite struct `Declaration Parser` {}
}

extension `SPM Standard Tests`.`Declaration Parser` {
  @Test
  func `Parser preserves URL strings and ignores line and nested block comments`()
    throws(Package.Dependency.Declaration.Parser.Error)
  {
    let source = #"""
      let package = Package(
          dependencies: [
              // .package(url: "https://github.com/commented/line.git", branch: "main"),
              /*
               .package(url: "https://github.com/commented/block.git", branch: "main")
               /* .package(url: "https://github.com/commented/nested.git", branch: "main") */
               */
              .package(url: "https://github.com/swift-foundations/swift-json.git", branch: "main"),
          ]
      )
      """#

    let declarations = try Package.Dependency.Declaration.Parser().parse([Byte](source.utf8))

    #expect(
      declarations == [
        .url(
          "https://github.com/swift-foundations/swift-json.git",
          line: 8
        )
      ]
    )
  }

  @Test
  func `Parser covers every target kind and hoisted product declarations`()
    throws(Package.Dependency.Declaration.Parser.Error)
  {
    let source = #"""
      let hoisted: Target.Dependency = .product(name: "Support", package: "support")
      let package = Package(
          dependencies: [
              .package(url: "https://github.com/vendor/support.git", branch: "main"),
          ],
          targets: [
              .target(name: "Library", dependencies: [hoisted]),
              .testTarget(name: "Tests", dependencies: [hoisted]),
              .executableTarget(name: "Tool", dependencies: [hoisted]),
              .macro(name: "Macro", dependencies: [hoisted]),
              .plugin(name: "Plugin", capability: .buildTool(), dependencies: [hoisted]),
          ]
      )
      """#

    let declarations = try Package.Dependency.Declaration.Parser().parse([Byte](source.utf8))

    #expect(
      declarations == [
        .url("https://github.com/vendor/support.git", line: 4)
      ]
    )
  }

  @Test
  func `Parser reports path registry dynamic and noncanonical declarations explicitly`()
    throws(Package.Dependency.Declaration.Parser.Error)
  {
    let source = #"""
      .package(path: ".."),
      .package(id: "example.library", from: "1.0.0"),
      .package(url: endpoint, branch: "main"),
      .package(url: "https://github.com/vendor/no-suffix", branch: "main"),
      """#

    let declarations = try Package.Dependency.Declaration.Parser().parse([Byte](source.utf8))

    #expect(declarations[0] == .path("..", line: 1))
    #expect(declarations[1] == .registry("example.library", line: 2))
    #expect(
      declarations[2]
        == .malformed("package url is not a static string literal", line: 3)
    )
    #expect(
      declarations[3]
        == .url("https://github.com/vendor/no-suffix", line: 4)
    )
  }
}
