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

// JSON Decoder is Foundation-bound and uses untyped throws via the Decodable
// protocol — both rules are deliberately exempted across this file.
import Foundation
import Testing

@testable import SPM_Standard

// Every fixture path in this file is the artificial `/fixture/checkouts/<name>`
// form. No machine, home, or temporary directory appears in any fixture: the
// shapes are what matter, not where a particular checkout happened to live.

extension `SPM Standard Tests` {
  @Suite struct Evaluation {}
}

extension `SPM Standard Tests`.Evaluation {

  // MARK: - Helpers

  private func decodeDependency(_ json: Swift.String) throws -> Package.Dependency.Evaluation {
    let data = try #require(json.data(using: .utf8))
    return try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
  }

  private func decodeManifest(_ json: Swift.String) throws -> Package.Manifest.Evaluation {
    let data = try #require(json.data(using: .utf8))
    return try JSONDecoder().decode(Package.Manifest.Evaluation.self, from: data)
  }

  // MARK: - Remote source control

  @Test
  func `remote source control preserves identity, URI, and branch requirement`() throws {
    let evaluation = try decodeDependency(
      """
      {
        "sourceControl": [
          {
            "identity": "swift-package-manager",
            "location": {
              "remote": [
                {"urlString": "https://github.com/swift-foundations/swift-package-manager.git"}
              ]
            },
            "productFilter": null,
            "requirement": {"branch": ["main"]},
            "traits": [{"name": "default"}]
          }
        ]
      }
      """
    )

    #expect(evaluation.identity.underlying == "swift-package-manager")
    #expect(evaluation.requirement == .branch("main"))
    #expect(evaluation.traits == [.init(name: "default")])

    guard case .sourceControl(_, let location, let requirement) = evaluation.source else {
      Issue.record("expected .sourceControl, got \(evaluation.source)")
      return
    }
    #expect(requirement == .branch("main"))
    guard case .remote(let uri) = location else {
      Issue.record("expected .remote, got \(location)")
      return
    }
    #expect(uri.value == "https://github.com/swift-foundations/swift-package-manager.git")

    // It is neither of the other two evaluated kinds.
    if case .fileSystem = evaluation.source { Issue.record("decoded as fileSystem") }
    if case .registry = evaluation.source { Issue.record("decoded as registry") }
    if case .local = location { Issue.record("decoded as local source control") }
  }

  // MARK: - Mirror-transformed local source control

  @Test
  func `mirror-transformed local source control preserves path and requirement`() throws {
    let evaluation = try decodeDependency(
      """
      {
        "sourceControl": [
          {
            "identity": "swift-paths",
            "location": {"local": ["/fixture/checkouts/swift-paths"]},
            "productFilter": null,
            "requirement": {"branch": ["main"]},
            "traits": [{"name": "default"}]
          }
        ]
      }
      """
    )

    #expect(evaluation.identity.underlying == "swift-paths")
    // The requirement survives mirror substitution — this is what
    // `Package.Dependency.Source.path` could not carry.
    #expect(evaluation.requirement == .branch("main"))

    guard case .sourceControl(_, let location, _) = evaluation.source else {
      Issue.record("expected .sourceControl, got \(evaluation.source)")
      return
    }
    guard case .local(let path) = location else {
      Issue.record("expected .local, got \(location)")
      return
    }
    #expect(path == "/fixture/checkouts/swift-paths")

    // It remains source control and is not projected onto a filesystem
    // dependency.
    if case .fileSystem = evaluation.source { Issue.record("projected to fileSystem") }

    // No empty URI, and no fabricated `file://` — the local arm produces no
    // URI at all.
    if case .remote(let uri) = location {
      Issue.record("fabricated a URI '\(uri.value)' for a local location")
    }
    #expect(!path.hasPrefix("file://"))
  }

  // MARK: - Genuine filesystem dependency

  @Test
  func `filesystem dependency preserves path and invents no requirement`() throws {
    let evaluation = try decodeDependency(
      """
      {
        "fileSystem": [
          {
            "identity": "swift-css",
            "path": "/fixture/checkouts/swift-css",
            "productFilter": null,
            "traits": [{"name": "default"}]
          }
        ]
      }
      """
    )

    #expect(evaluation.identity.underlying == "swift-css")
    guard case .fileSystem(_, let path) = evaluation.source else {
      Issue.record("expected .fileSystem, got \(evaluation.source)")
      return
    }
    #expect(path == "/fixture/checkouts/swift-css")
    // The wire carries no requirement for a filesystem dependency and the
    // decoder must not invent one.
    #expect(evaluation.requirement == nil)
    if case .sourceControl = evaluation.source { Issue.record("decoded as source control") }
  }

  @Test
  func `filesystem and local source control for the same basename are not equal`() throws {
    let fileSystem = try decodeDependency(
      """
      {
        "fileSystem": [
          {"identity": "swift-paths", "path": "/fixture/checkouts/swift-paths",
           "productFilter": null, "traits": []}
        ]
      }
      """
    )
    let sourceControl = try decodeDependency(
      """
      {
        "sourceControl": [
          {"identity": "swift-paths",
           "location": {"local": ["/fixture/checkouts/swift-paths"]},
           "productFilter": null, "requirement": {"branch": ["main"]}, "traits": []}
        ]
      }
      """
    )

    // Same identity token, same path string, different evaluated kind.
    #expect(fileSystem.identity == sourceControl.identity)
    #expect(fileSystem != sourceControl)
    #expect(fileSystem.source != sourceControl.source)
    #expect(fileSystem.requirement == nil)
    #expect(sourceControl.requirement == .branch("main"))
  }

  // MARK: - Invariants encoded in the public type

  /// The requirement lives inside the cases that have one, so these are the
  /// only values the public API can express. There is no initialiser that
  /// pairs a filesystem source with a requirement, or a source-control or
  /// registry source without one — those combinations are unrepresentable
  /// rather than merely rejected at encode time.
  @Test
  func `public construction cannot express a filesystem requirement`() {
    let source = Package.Dependency.Evaluation.Source.fileSystem(
      identity: "swift-css", path: "/fixture/checkouts/swift-css"
    )
    #expect(source.requirement == nil)
    #expect(Package.Dependency.Evaluation(source: source).requirement == nil)
  }

  @Test
  func `public construction cannot express source control without a requirement`() {
    let source = Package.Dependency.Evaluation.Source.sourceControl(
      identity: "swift-paths",
      location: .local(path: "/fixture/checkouts/swift-paths"),
      requirement: .branch("main")
    )
    #expect(source.requirement == .branch("main"))
  }

  @Test
  func `public construction cannot express registry without a requirement`() {
    let source = Package.Dependency.Evaluation.Source.registry(
      identity: Package.Identity(scope: "apple", name: "swift-argument-parser"),
      requirement: .exact("1.2.3")
    )
    #expect(source.requirement == .exact("1.2.3"))
  }

  /// Registry stores only its `Package.Identity`; the emitted `scope.name`
  /// token is derived from it. A hand-constructed value therefore cannot hold
  /// a token that disagrees with its parsed identity.
  @Test
  func `registry identity has one coherent source of truth`() throws {
    let identity = Package.Identity(scope: "apple", name: "swift-argument-parser")
    let source = Package.Dependency.Evaluation.Source.registry(
      identity: identity, requirement: .exact("1.2.3")
    )
    #expect(source.identity.underlying == "apple.swift-argument-parser")

    let decoded = try decodeDependency(
      """
      {
        "registry": [
          {"identity": "apple.swift-argument-parser", "productFilter": null,
           "requirement": {"exact": ["1.2.3"]}, "traits": []}
        ]
      }
      """
    )
    #expect(decoded.source == source)
    #expect(decoded.identity.underlying == "apple.swift-argument-parser")
    guard case .registry(let decodedIdentity, _) = decoded.source else {
      Issue.record("expected .registry, got \(decoded.source)")
      return
    }
    #expect(decodedIdentity == identity)
  }

  // MARK: - Invalid source-control locations

  @Test(
    arguments: [
      (
        "neither remote nor local",
        #"{"location": {}, "requirement": {"branch": ["main"]}}"#
      ),
      (
        "both remote and local",
        """
        {"location": {"remote": [{"urlString": "https://example.com/r.git"}], \
        "local": ["/fixture/checkouts/r"]}, "requirement": {"branch": ["main"]}}
        """
      ),
      (
        "empty remote array",
        #"{"location": {"remote": []}, "requirement": {"branch": ["main"]}}"#
      ),
      (
        "empty local array",
        #"{"location": {"local": []}, "requirement": {"branch": ["main"]}}"#
      ),
      (
        "two remote locations",
        """
        {"location": {"remote": [{"urlString": "https://example.com/a.git"}, \
        {"urlString": "https://example.com/b.git"}]}, "requirement": {"branch": ["main"]}}
        """
      ),
      (
        "two local locations",
        """
        {"location": {"local": ["/fixture/checkouts/a", "/fixture/checkouts/b"]}, \
        "requirement": {"branch": ["main"]}}
        """
      ),
      (
        "empty urlString",
        #"{"location": {"remote": [{"urlString": ""}]}, "requirement": {"branch": ["main"]}}"#
      ),
      (
        "missing urlString",
        #"{"location": {"remote": [{}]}, "requirement": {"branch": ["main"]}}"#
      ),
      (
        "missing requirement",
        #"{"location": {"remote": [{"urlString": "https://example.com/r.git"}]}}"#
      ),
      (
        "empty local path",
        #"{"location": {"local": [""]}, "requirement": {"branch": ["main"]}}"#
      ),
      (
        "malformed remote URI",
        #"{"location": {"remote": [{"urlString": "https://exa mple.com/r.git"}]}, "requirement": {"branch": ["main"]}}"#
      ),
    ]
  )
  func `invalid source-control location is rejected`(
    label: Swift.String, body: Swift.String
  ) throws {
    let json = Self.sourceControlEnvelope(body)
    let data = try #require(json.data(using: .utf8))
    #expect(throws: (any Swift.Error).self, "\(label) must be rejected") {
      _ = try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
    }
  }

  /// Shared envelope for the rejection cases above, so each case supplies only
  /// the part under test.
  private static func sourceControlEnvelope(_ body: Swift.String) -> Swift.String {
    #"{"sourceControl": [{"identity": "swift-broken", "# + Swift.String(body.dropFirst()) + "]}"
  }

  /// Positive control for the eleven rejection cases above.
  ///
  /// Those cases assert only that decoding *throws*. If the shared envelope
  /// produced malformed JSON, every one of them would throw a syntax error and
  /// pass for the wrong reason. This decodes a **valid** body through the
  /// identical envelope, so a broken envelope fails here.
  @Test
  func `the rejection-case envelope produces decodable JSON for a valid body`() throws {
    let json = Self.sourceControlEnvelope(
      #"{"location": {"remote": [{"urlString": "https://example.com/r.git"}]}, "requirement": {"branch": ["main"]}}"#
    )
    let data = try #require(json.data(using: .utf8))
    let evaluation = try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
    #expect(evaluation.identity.underlying == "swift-broken")
    #expect(evaluation.requirement == .branch("main"))
  }

  // MARK: - Discriminator cardinality

  @Test(
    arguments: [
      (
        "two fileSystem records",
        """
        {"fileSystem": [
          {"identity": "a", "path": "/fixture/checkouts/a", "productFilter": null, "traits": []},
          {"identity": "b", "path": "/fixture/checkouts/b", "productFilter": null, "traits": []}
        ]}
        """
      ),
      (
        "two sourceControl records",
        """
        {"sourceControl": [
          {"identity": "a", "location": {"local": ["/fixture/checkouts/a"]},
           "productFilter": null, "requirement": {"branch": ["main"]}, "traits": []},
          {"identity": "b", "location": {"local": ["/fixture/checkouts/b"]},
           "productFilter": null, "requirement": {"branch": ["main"]}, "traits": []}
        ]}
        """
      ),
      (
        "two registry records",
        """
        {"registry": [
          {"identity": "apple.a", "productFilter": null, "requirement": {"exact": ["1.0.0"]}, "traits": []},
          {"identity": "apple.b", "productFilter": null, "requirement": {"exact": ["1.0.0"]}, "traits": []}
        ]}
        """
      ),
      ("empty fileSystem array", #"{"fileSystem": []}"#),
      ("empty sourceControl array", #"{"sourceControl": []}"#),
      ("empty registry array", #"{"registry": []}"#),
    ]
  )
  func `a discriminator array must hold exactly one record`(
    label: Swift.String, json: Swift.String
  ) throws {
    let data = try #require(json.data(using: .utf8))
    #expect(throws: (any Swift.Error).self, "\(label) must be rejected") {
      _ = try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
    }
  }

  @Test
  func `ambiguous dependency discriminator is rejected`() throws {
    let json = """
      {
        "fileSystem": [
          {"identity": "a", "path": "/fixture/checkouts/a", "productFilter": null, "traits": []}
        ],
        "sourceControl": [
          {"identity": "a", "location": {"local": ["/fixture/checkouts/a"]},
           "productFilter": null, "requirement": {"branch": ["main"]}, "traits": []}
        ]
      }
      """
    let data = try #require(json.data(using: .utf8))
    #expect(throws: (any Swift.Error).self) {
      _ = try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
    }
  }

  @Test
  func `absent dependency discriminator is rejected`() throws {
    let data = Data(#"{"productFilter": null}"#.utf8)
    #expect(throws: (any Swift.Error).self) {
      _ = try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
    }
  }

  // MARK: - Identity validation

  @Test(
    arguments: [
      (
        "fileSystem",
        #"{"fileSystem": [{"identity": "", "path": "/fixture/checkouts/a", "productFilter": null, "traits": []}]}"#
      ),
      (
        "sourceControl",
        """
        {"sourceControl": [{"identity": "", "location": {"local": ["/fixture/checkouts/a"]}, \
        "productFilter": null, "requirement": {"branch": ["main"]}, "traits": []}]}
        """
      ),
      (
        "registry",
        #"{"registry": [{"identity": "", "productFilter": null, "requirement": {"exact": ["1.0.0"]}, "traits": []}]}"#
      ),
    ]
  )
  func `an empty evaluated identity is rejected`(
    kind: Swift.String, json: Swift.String
  ) throws {
    let data = try #require(json.data(using: .utf8))
    #expect(throws: (any Swift.Error).self, "empty \(kind) identity must be rejected") {
      _ = try JSONDecoder().decode(Package.Dependency.Evaluation.self, from: data)
    }
  }

  // MARK: - Full manifest evaluation

  /// Exercises the evaluation decoder end to end on a fixture carrying all
  /// three evaluated dependency kinds — including a mirror-transformed local
  /// source-control location — plus products, targets, and platforms, and the
  /// target-dependency edges the product back-fill walks.
  @Test
  func `manifest evaluation preserves products, targets, platforms, and back-fill`() throws {
    let evaluation = try decodeManifest(
      """
      {
        "cLanguageStandard": null,
        "cxxLanguageStandard": null,
        "defaultLocalization": null,
        "dependencies": [
          {
            "sourceControl": [
              {"identity": "swift-paths",
               "location": {"local": ["/fixture/checkouts/swift-paths"]},
               "productFilter": null,
               "requirement": {"branch": ["main"]},
               "traits": [{"name": "default"}]}
            ]
          },
          {
            "sourceControl": [
              {"identity": "swift-package-manager",
               "location": {"remote": [{"urlString": "https://github.com/swift-foundations/swift-package-manager.git"}]},
               "productFilter": null,
               "requirement": {"branch": ["main"]},
               "traits": [{"name": "default"}]}
            ]
          },
          {
            "fileSystem": [
              {"identity": "swift-css",
               "path": "/fixture/checkouts/swift-css",
               "productFilter": null,
               "traits": [{"name": "default"}]}
            ]
          },
          {
            "fileSystem": [
              {"identity": "swift-unreferenced",
               "path": "/fixture/checkouts/swift-unreferenced",
               "productFilter": null,
               "traits": []}
            ]
          }
        ],
        "name": "swift-evaluation-fixture",
        "packageKind": {"root": ["/fixture/checkouts/swift-evaluation-fixture"]},
        "pkgConfig": null,
        "platforms": [
          {"options": [], "platformName": "macos", "version": "26.0"},
          {"options": [], "platformName": "ios", "version": "26.0"}
        ],
        "products": [
          {"name": "Evaluation Fixture",
           "settings": [],
           "targets": ["Evaluation Fixture"],
           "type": {"library": ["automatic"]}}
        ],
        "targets": [
          {
            "dependencies": [
              {"product": ["Paths", "swift-paths", null, null]},
              {"product": ["Package Manager", "swift-package-manager", null, null]},
              {"product": ["CSS", "swift-css", null, null]},
              {"product": ["CSS Theming", "swift-css", null, null]},
              {"target": ["Support", null]}
            ],
            "exclude": [],
            "name": "Evaluation Fixture",
            "packageAccess": true,
            "resources": [],
            "settings": [],
            "type": "regular"
          },
          {
            "dependencies": [],
            "exclude": [],
            "name": "Support",
            "packageAccess": true,
            "resources": [],
            "settings": [],
            "type": "regular"
          }
        ],
        "toolsVersion": {"_version": "6.3.3"},
        "traits": []
      }
      """
    )

    // Manifest-level facts.
    #expect(evaluation.name == "swift-evaluation-fixture")
    #expect(evaluation.toolsVersion == Version.Tools("6.3.3"))
    #expect(evaluation.products.count == 1)
    #expect(evaluation.products[0].name == "Evaluation Fixture")
    #expect(evaluation.targets.count == 2)
    #expect(evaluation.targets.map(\.name) == ["Evaluation Fixture", "Support"])
    #expect(evaluation.platforms?.count == 2)
    #expect(evaluation.dependencies.count == 4)

    let byToken = Swift.Dictionary(
      uniqueKeysWithValues: evaluation.dependencies.map { ($0.identity.underlying, $0) }
    )

    let paths = try #require(byToken["swift-paths"])
    #expect(
      paths.source
        == .sourceControl(
          identity: "swift-paths",
          location: .local(path: "/fixture/checkouts/swift-paths"),
          requirement: .branch("main")
        )
    )

    let manager = try #require(byToken["swift-package-manager"])
    #expect(
      manager.source
        == .sourceControl(
          identity: "swift-package-manager",
          location: .remote(
            URI("https://github.com/swift-foundations/swift-package-manager.git")
          ),
          requirement: .branch("main")
        )
    )

    let css = try #require(byToken["swift-css"])
    #expect(
      css.source == .fileSystem(identity: "swift-css", path: "/fixture/checkouts/swift-css")
    )
    #expect(css.requirement == nil)

    // Product back-fill, keyed on the emitted identity token.
    #expect(paths.products == ["Paths"])
    #expect(manager.products == ["Package Manager"])
    #expect(css.products == ["CSS", "CSS Theming"])  // deterministic, target order
    let unreferenced = try #require(byToken["swift-unreferenced"])
    #expect(unreferenced.products.isEmpty)
  }
}
