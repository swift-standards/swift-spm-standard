import Foundation
import Testing

@testable import SPM_Standard

extension `SPM Standard Tests` {
    @Suite struct Resolution {}
}

extension `SPM Standard Tests`.Resolution {

    private func decode(_ json: Swift.String) throws -> Package.Resolution {
        let data = try #require(json.data(using: .utf8))
        return try JSONDecoder().decode(Package.Resolution.self, from: data)
    }

    private func envelope(_ records: Swift.String, version: Swift.Int = 7) -> Swift.String {
        """
        { "version": \(version),
          "object": { "artifacts": [], "prebuilts": [], "dependencies": [\(records)] } }
        """
    }

    private var checkoutRecord: Swift.String {
        """
        { "packageRef": { "identity": "swift-paths", "kind": "localSourceControl",
                          "location": "/fixture/checkouts/swift-paths", "name": "swift-paths" },
          "state": { "name": "sourceControlCheckout",
                     "checkoutState": { "revision": "9bbec44787745de50bc80ed8191d055ba51ed2b5",
                                        "branch": "main" } },
          "subpath": "swift-paths", "basedOn": null }
        """
    }

    @Test
    func `the supported schema version decodes`() throws {
        let resolution = try decode(
            envelope(checkoutRecord, version: Package.Resolution.supportedVersion)
        )
        #expect(resolution.dependencies.count == 1)
    }

    @Test
    func `an unsupported schema version is refused rather than decoded`() throws {

        #expect(throws: DecodingError.self) {
            _ = try decode(envelope(checkoutRecord, version: 8))
        }
    }

    @Test
    func `artifacts and prebuilts are tolerated without being modelled`() throws {

        let json = """
            { "version": 7, "object": {
                "artifacts": [],
                "prebuilts": [ { "identity": "swift-syntax", "libraryName": "MacroSupport",
                                 "version": "602.0.0", "cModules": [], "includePath": [],
                                 "products": [], "checkoutPath": "/fixture/checkouts/swift-syntax",
                                 "path": "/fixture/prebuilts/swift-syntax" } ],
                "dependencies": [\(checkoutRecord)] } }
            """
        let resolution = try decode(json)
        #expect(resolution.dependencies.count == 1)
    }

    @Test
    func `a source control checkout carries a revision and a branch pin`() throws {
        let resolution = try decode(envelope(checkoutRecord))
        let dependency = try #require(resolution.dependencies.first)
        guard case .sourceControlCheckout(let checkout) = dependency.state else {
            Issue.record("Expected .sourceControlCheckout, got \(dependency.state)")
            return
        }
        #expect(checkout.revision == "9bbec44787745de50bc80ed8191d055ba51ed2b5")
        #expect(checkout.pin == .branch("main"))
        #expect(dependency.state.path == nil)
        #expect(dependency.subpath == "swift-paths")
    }

    @Test
    func `a version pin decodes to a semantic version`() throws {
        let record = """
            { "packageRef": { "identity": "swift-syntax", "kind": "remoteSourceControl",
                              "location": "https://github.com/swiftlang/swift-syntax.git",
                              "name": "swift-syntax" },
              "state": { "name": "sourceControlCheckout",
                         "checkoutState": { "revision": "abc123", "version": "602.0.0" } },
              "subpath": "swift-syntax", "basedOn": null }
            """
        let dependency = try #require(try decode(envelope(record)).dependencies.first)
        #expect(
            dependency.state.checkout?.pin == .version(try Version.Semantic(parsing: "602.0.0"))
        )
    }

    @Test
    func `a version-shaped branch name stays a branch`() throws {

        let record = """
            { "packageRef": { "identity": "swift-dependencies", "kind": "localSourceControl",
                              "location": "/fixture/checkouts/swift-dependencies",
                              "name": "swift-dependencies" },
              "state": { "name": "sourceControlCheckout",
                         "checkoutState": { "revision": "def456", "branch": "1.6.1" } },
              "subpath": "swift-dependencies", "basedOn": null }
            """
        let dependency = try #require(try decode(envelope(record)).dependencies.first)
        #expect(dependency.state.checkout?.pin == .branch("1.6.1"))

        #expect(dependency.state.checkout?.pin != .version(try Version.Semantic(parsing: "1.6.1")))
    }

    @Test
    func `a filesystem dependency carries a path and no revision`() throws {
        let record = """
            { "packageRef": { "identity": "swift-css", "kind": "fileSystem",
                              "location": "/fixture/checkouts/swift-css", "name": "swift-css" },
              "state": { "name": "fileSystem", "path": "/fixture/checkouts/swift-css" },
              "subpath": "swift-css", "basedOn": null }
            """
        let dependency = try #require(try decode(envelope(record)).dependencies.first)
        #expect(dependency.state.path == "/fixture/checkouts/swift-css")
        #expect(dependency.state.checkout == nil)
        #expect(dependency.revision == nil)
    }

    @Test
    func `both branch and version present is refused`() throws {
        let record = """
            { "packageRef": { "identity": "x", "kind": "localSourceControl",
                              "location": "/fixture/checkouts/x", "name": "x" },
              "state": { "name": "sourceControlCheckout",
                         "checkoutState": { "revision": "r", "branch": "main", "version": "1.0.0" } },
              "subpath": "x", "basedOn": null }
            """
        #expect(throws: DecodingError.self) { _ = try decode(envelope(record)) }
    }

    @Test
    func `neither branch nor version present is refused`() throws {
        let record = """
            { "packageRef": { "identity": "x", "kind": "localSourceControl",
                              "location": "/fixture/checkouts/x", "name": "x" },
              "state": { "name": "sourceControlCheckout", "checkoutState": { "revision": "r" } },
              "subpath": "x", "basedOn": null }
            """
        #expect(throws: DecodingError.self) { _ = try decode(envelope(record)) }
    }

    @Test
    func `an unmodelled state name is refused rather than guessed`() throws {

        let record = """
            { "packageRef": { "identity": "x", "kind": "registry",
                              "location": "scope.x", "name": "x" },
              "state": { "name": "registryDownload", "version": "1.0.0" },
              "subpath": "x", "basedOn": null }
            """
        #expect(throws: DecodingError.self) { _ = try decode(envelope(record)) }
    }

    @Test
    func `an edited dependency decodes and reports no revision`() throws {

        let record = """
            { "packageRef": { "identity": "swift-parser-primitives", "kind": "localSourceControl",
                              "location": "/fixture/checkouts/swift-parser-primitives",
                              "name": "swift-parser-primitives" },
              "state": { "name": "edited", "path": "/fixture/edited/swift-parser-primitives" },
              "subpath": "swift-parser-primitives",
              "basedOn": { "packageRef": { "identity": "swift-parser-primitives",
                                           "kind": "localSourceControl",
                                           "location": "/fixture/checkouts/swift-parser-primitives",
                                           "name": "swift-parser-primitives" },
                           "state": { "name": "sourceControlCheckout",
                                      "checkoutState": { "revision": "aaa111", "branch": "main" } },
                           "subpath": "swift-parser-primitives", "basedOn": null } }
            """
        let dependency = try #require(try decode(envelope(record)).dependencies.first)
        guard case .edited(let path, let superseded) = dependency.state else {
            Issue.record("Expected .edited, got \(dependency.state)")
            return
        }
        #expect(path == "/fixture/edited/swift-parser-primitives")

        #expect(dependency.revision == nil)

        #expect(try #require(superseded).checkout.revision == "aaa111")
        #expect(try #require(superseded).checkout.pin == .branch("main"))
    }

    @Test
    func `a non-edited dependency may not supersede a checkout`() throws {

        let record = """
            { "packageRef": { "identity": "x", "kind": "fileSystem",
                              "location": "/fixture/checkouts/x", "name": "x" },
              "state": { "name": "fileSystem", "path": "/fixture/checkouts/x" },
              "subpath": "x",
              "basedOn": { "packageRef": { "identity": "x", "kind": "localSourceControl",
                                           "location": "/fixture/checkouts/x", "name": "x" },
                           "state": { "name": "sourceControlCheckout",
                                      "checkoutState": { "revision": "r", "branch": "main" } },
                           "subpath": "x", "basedOn": null } }
            """
        #expect(throws: DecodingError.self) { _ = try decode(envelope(record)) }
    }

    @Test
    func `kind does not determine state and state does not recover kind`() throws {

        let remote = """
            { "packageRef": { "identity": "a", "kind": "remoteSourceControl",
                              "location": "https://example.invalid/a.git", "name": "a" },
              "state": { "name": "sourceControlCheckout",
                         "checkoutState": { "revision": "r1", "branch": "main" } },
              "subpath": "a", "basedOn": null }
            """
        let local = """
            { "packageRef": { "identity": "b", "kind": "localSourceControl",
                              "location": "/fixture/checkouts/b", "name": "b" },
              "state": { "name": "sourceControlCheckout",
                         "checkoutState": { "revision": "r2", "branch": "main" } },
              "subpath": "b", "basedOn": null }
            """
        let resolution = try decode(envelope("\(remote), \(local)"))
        #expect(resolution.dependencies.count == 2)
        #expect(resolution.dependencies[0].reference.kind == .remoteSourceControl)
        #expect(resolution.dependencies[1].reference.kind == .localSourceControl)

        #expect(resolution.dependencies[0].state.checkout != nil)
        #expect(resolution.dependencies[1].state.checkout != nil)
    }

    @Test
    func `an unrecognised kind is refused`() throws {
        let record = """
            { "packageRef": { "identity": "x", "kind": "somethingNew",
                              "location": "/fixture/checkouts/x", "name": "x" },
              "state": { "name": "fileSystem", "path": "/fixture/checkouts/x" },
              "subpath": "x", "basedOn": null }
            """
        #expect(throws: DecodingError.self) { _ = try decode(envelope(record)) }
    }

    @Test
    func `lookup by identity finds the record`() throws {
        let resolution = try decode(envelope(checkoutRecord))
        #expect(resolution.dependency(for: "swift-paths") != nil)
        #expect(resolution.dependency(for: "absent") == nil)
    }
}
