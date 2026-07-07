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

// JSON Encoder/Decoder are Foundation-bound and use untyped throws via the
// Codable protocol — both rules are deliberately exempted across this file.
import Foundation
import Testing

@testable import SPM_Standard

// MARK: - Package.Manifest Codable round-trips

extension `SPM Standard Tests`.`Codable Round-Trip` {
  // MARK: Decode of real `swift package dump-package` output

  /// Golden fixture: the actual JSON `swift package dump-package` emits
  /// for a workspace with one path-form dependency. The fixture is
  /// realistic — carries the full extras footprint
  /// (`cLanguageStandard`, `cxxLanguageStandard`, `defaultLocalization`,
  /// `packageKind`, `pkgConfig`, `platforms`, `products`, `targets`,
  /// `traits`) to exercise the ignore-extras strategy.
  @Test
  func `decodes dump-package output ignoring extras (path-form dep)`() throws {
    let json = """
      {
        "cLanguageStandard": null,
        "cxxLanguageStandard": null,
        "defaultLocalization": null,
        "dependencies": [
          {
            "fileSystem": [
              {
                "identity": "swift-graph-primitives",
                "path": "/Users/coen/Developer/swift-primitives/swift-graph-primitives",
                "productFilter": null,
                "traits": [{"name": "default"}]
              }
            ]
          }
        ],
        "name": "swift-package-graph",
        "packageKind": {
          "root": ["/Users/coen/Developer/swift-foundations/swift-package-graph"]
        },
        "pkgConfig": null,
        "platforms": [
          {"options": [], "platformName": "macos", "version": "26.0"}
        ],
        "products": [],
        "targets": [],
        "toolsVersion": {"_version": "6.3.1"},
        "traits": []
      }
      """
    let data = try #require(json.data(using: .utf8))
    let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)

    #expect(manifest.name == "swift-package-graph")
    #expect(manifest.toolsVersion == (try Version.Tools("6.3.1")))
    #expect(manifest.dependencies.count == 1)

    let dep = manifest.dependencies[0]
    #expect(dep.name == "swift-graph-primitives")
    guard case .path(let path) = dep.source else {
      Issue.record("expected .path source")
      return
    }
    #expect(path == "/Users/coen/Developer/swift-primitives/swift-graph-primitives")
  }

  @Test
  func `decodes dump-package output with sourceControl url + exact requirement`() throws {
    let json = """
      {
        "name": "swift-effect",
        "toolsVersion": {"_version": "6.3.1"},
        "dependencies": [
          {
            "sourceControl": [
              {
                "identity": "swift-syntax",
                "location": {
                  "remote": [{"urlString": "https://github.com/swiftlang/swift-syntax.git"}]
                },
                "productFilter": null,
                "requirement": {"exact": ["602.0.0"]},
                "traits": [{"name": "default"}]
              }
            ]
          }
        ]
      }
      """
    let data = try #require(json.data(using: .utf8))
    let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)

    #expect(manifest.dependencies.count == 1)
    let dep = manifest.dependencies[0]
    guard case .url(let url, let requirement) = dep.source else {
      Issue.record("expected .url source, got \(dep.source)")
      return
    }
    #expect(url == "https://github.com/swiftlang/swift-syntax.git")
    guard case .exact(let version) = requirement else {
      Issue.record("expected .exact requirement, got \(requirement)")
      return
    }
    #expect(version == (try Version.Semantic(parsing: "602.0.0")))
  }

  @Test
  func `decodes dump-package output with sourceControl + range requirement`() throws {
    let json = """
      {
        "name": "swift-foo",
        "toolsVersion": {"_version": "6.3.1"},
        "dependencies": [
          {
            "sourceControl": [
              {
                "identity": "xctest-dynamic-overlay",
                "location": {
                  "remote": [{"urlString": "https://github.com/pointfreeco/xctest-dynamic-overlay"}]
                },
                "productFilter": null,
                "requirement": {
                  "range": [{"lowerBound": "1.8.0", "upperBound": "2.0.0"}]
                },
                "traits": [{"name": "default"}]
              }
            ]
          }
        ]
      }
      """
    let data = try #require(json.data(using: .utf8))
    let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)

    let dep = manifest.dependencies[0]
    guard case .url(_, let requirement) = dep.source else {
      Issue.record("expected .url source")
      return
    }
    guard case .range(let r) = requirement else {
      Issue.record("expected .range requirement, got \(requirement)")
      return
    }
    switch r.lowerBound {
    case .inclusive(let v): #expect(v == (try Version.Semantic(parsing: "1.8.0")))
    default: Issue.record("expected inclusive lower bound")
    }
    switch r.upperBound {
    case .exclusive(let v): #expect(v == (try Version.Semantic(parsing: "2.0.0")))
    default: Issue.record("expected exclusive upper bound")
    }
  }

  @Test
  func `decodes dump-package output with branch requirement`() throws {
    let json = """
      {
        "name": "swift-foo",
        "toolsVersion": {"_version": "6.3.1"},
        "dependencies": [
          {
            "sourceControl": [
              {
                "identity": "swift-bar",
                "location": {"remote": [{"urlString": "https://example.com/swift-bar.git"}]},
                "productFilter": null,
                "requirement": {"branch": ["main"]},
                "traits": []
              }
            ]
          }
        ]
      }
      """
    let data = try #require(json.data(using: .utf8))
    let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)
    guard case .url(_, let requirement) = manifest.dependencies[0].source else {
      Issue.record("expected .url source")
      return
    }
    guard case .branch(let name) = requirement else {
      Issue.record("expected .branch requirement, got \(requirement)")
      return
    }
    #expect(name == "main")
  }

  @Test
  func `decodes dump-package output with registry-form dep`() throws {
    let json = """
      {
        "name": "swift-foo",
        "toolsVersion": {"_version": "6.3.1"},
        "dependencies": [
          {
            "registry": [
              {
                "identity": "apple.swift-argument-parser",
                "productFilter": null,
                "requirement": {"exact": ["1.5.0"]},
                "traits": []
              }
            ]
          }
        ]
      }
      """
    let data = try #require(json.data(using: .utf8))
    let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)
    let dep = manifest.dependencies[0]
    guard case .registry(let identity, let requirement) = dep.source else {
      Issue.record("expected .registry source")
      return
    }
    #expect(identity.scope == "apple")
    #expect(identity.name == "swift-argument-parser")
    guard case .exact(let v) = requirement else {
      Issue.record("expected .exact requirement")
      return
    }
    #expect(v == (try Version.Semantic(parsing: "1.5.0")))
  }

  @Test
  func `decodes dump-package output with multiple deps in all three forms`() throws {
    let json = """
      {
        "name": "swift-mixed",
        "toolsVersion": {"_version": "6.3.1"},
        "dependencies": [
          {
            "fileSystem": [
              {"identity": "swift-local", "path": "/abs/swift-local",
               "productFilter": null, "traits": []}
            ]
          },
          {
            "sourceControl": [
              {"identity": "swift-remote",
               "location": {"remote": [{"urlString": "https://example.com/swift-remote.git"}]},
               "productFilter": null,
               "requirement": {"exact": ["1.0.0"]},
               "traits": []}
            ]
          },
          {
            "registry": [
              {"identity": "apple.swift-something",
               "productFilter": null,
               "requirement": {"branch": ["main"]},
               "traits": []}
            ]
          }
        ]
      }
      """
    let data = try #require(json.data(using: .utf8))
    let manifest = try JSONDecoder().decode(Package.Manifest.self, from: data)
    #expect(manifest.dependencies.count == 3)

    if case .path(let p) = manifest.dependencies[0].source {
      #expect(p == "/abs/swift-local")
    } else {
      Issue.record("dep 0 expected path")
    }
    if case .url(let u, _) = manifest.dependencies[1].source {
      #expect(u == "https://example.com/swift-remote.git")
    } else {
      Issue.record("dep 1 expected url")
    }
    if case .registry(let id, _) = manifest.dependencies[2].source {
      #expect(id.scope == "apple")
      #expect(id.name == "swift-something")
    } else {
      Issue.record("dep 2 expected registry")
    }
  }

  // MARK: Round-trip (encode → decode equality)

  @Test
  func `Package.Manifest minimal round-trips through JSON`() throws {
    let manifest = Package.Manifest(
      name: "swift-leaf",
      toolsVersion: try Version.Tools("6.3.1")
    )
    let encoded = try JSONEncoder().encode(manifest)
    let decoded = try JSONDecoder().decode(Package.Manifest.self, from: encoded)
    #expect(decoded == manifest)
  }

  @Test
  func `Package.Manifest with path-form dep round-trips through JSON`() throws {
    let manifest = Package.Manifest(
      name: "swift-foo",
      toolsVersion: try Version.Tools("6.3.1"),
      dependencies: [
        Package.Dependency(
          source: .path("/abs/swift-bar"),
          name: "swift-bar",
          products: []
        )
      ]
    )
    let encoded = try JSONEncoder().encode(manifest)
    let decoded = try JSONDecoder().decode(Package.Manifest.self, from: encoded)
    #expect(decoded == manifest)
  }

  @Test
  func `Package.Manifest with url-form dep round-trips through JSON`() throws {
    let manifest = Package.Manifest(
      name: "swift-foo",
      toolsVersion: try Version.Tools("6.3.1"),
      dependencies: [
        Package.Dependency(
          source: .url(
            "https://github.com/swiftlang/swift-syntax.git",
            .exact("602.0.0")
          ),
          name: "swift-syntax",
          products: []
        )
      ]
    )
    let encoded = try JSONEncoder().encode(manifest)
    let decoded = try JSONDecoder().decode(Package.Manifest.self, from: encoded)
    #expect(decoded == manifest)
  }

  @Test
  func `Package.Manifest with all three dep forms round-trips through JSON`() throws {
    let manifest = Package.Manifest(
      name: "swift-mixed",
      toolsVersion: try Version.Tools("6.3.1"),
      dependencies: [
        Package.Dependency(
          source: .path("/abs/swift-local"),
          name: "swift-local",
          products: []
        ),
        Package.Dependency(
          source: .url("https://example.com/swift-remote.git", .exact("1.0.0")),
          name: "swift-remote",
          products: []
        ),
        Package.Dependency(
          source: .registry(
            Package.Identity(scope: "apple", name: "swift-something"),
            .branch("main")
          ),
          name: "apple.swift-something",
          products: []
        ),
      ]
    )
    let encoded = try JSONEncoder().encode(manifest)
    let decoded = try JSONDecoder().decode(Package.Manifest.self, from: encoded)
    #expect(decoded == manifest)
  }
}
