import Byte
import Testing

@testable import SPM_Standard

extension `SPM Standard Tests` {
    @Suite struct `Manifest Recognition` {}
}

extension `SPM Standard Tests`.`Manifest Recognition` {
    private static func recognizes(_ source: Swift::String) -> Swift::Bool {
        Package.Manifest.recognizes(Array(utf8: source))
    }

    @Test func `a manifest importing PackageDescription is recognized`() {
        #expect(Self.recognizes("// swift-tools-version: 6.4\nimport PackageDescription\nlet package = Package(name: \"x\")\n"))
    }

    @Test func `a package binding to a Package call is recognized without the import`() {
        #expect(Self.recognizes("let package = Package(name: \"x\")\n"))
        #expect(Self.recognizes("var package: Package = Package(name: \"x\")\n"))
    }

    @Test func `an import inside conditional compilation is recognized`() {
        #expect(Self.recognizes("#if os(macOS)\nimport PackageDescription\n#endif\n"))
    }

    @Test func `a production Package namespace is not a manifest`() {
        #expect(!Self.recognizes("public enum Package: Swift.Sendable {}\n"))
    }

    @Test func `a tools-version line alone is not a manifest`() {
        #expect(!Self.recognizes("// swift-tools-version: 6.3\n"))
    }

    @Test func `markers inside comments and strings do not count`() {
        #expect(!Self.recognizes("// import PackageDescription\n/* let package = Package( */\n"))
        #expect(!Self.recognizes("let text = \"import PackageDescription\"\n"))
    }
}
