import Foundation
import Testing

@testable import SPM_Standard

extension `SPM Standard Tests` {

    @Suite struct `Toolchain Canary` {}
}

extension `SPM Standard Tests`.`Toolchain Canary` {
    @Test
    func `swift package dump-package output decodes via Package.Manifest Codable`() throws {
        let fixtureRoot = try Self.writeCanaryFixture()
        defer { try? FileManager.default.removeItem(at: fixtureRoot) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: try Self.resolveSwiftExecutable())
        process.arguments = ["package", "dump-package"]
        process.currentDirectoryURL = fixtureRoot

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let deadline = Date().addingTimeInterval(60)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if process.isRunning {
            process.terminate()
            Issue.record("`swift package dump-package` timed out after 60s")
            return
        }

        guard process.terminationStatus == 0 else {
            let stderrString = String(data: stderrData, encoding: .utf8) ?? "<non-utf8>"
            Issue.record(
                "`swift package dump-package` exited \(process.terminationStatus): \(stderrString)"
            )
            return
        }

        let manifest = try JSONDecoder().decode(
            Package.Manifest.self,
            from: stdoutData
        )
        #expect(manifest.name == "canary-fixture")
    }

    private static func writeCanaryFixture() throws -> URL {
        let fm = FileManager.default
        let root = fm.temporaryDirectory
            .appendingPathComponent("spm-standard-canary-\(UUID().uuidString)")
        try fm.createDirectory(at: root, withIntermediateDirectories: true)

        let sourcesDir =
            root
            .appendingPathComponent("Sources")
            .appendingPathComponent("canary-fixture")
        try fm.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

        let placeholderSource = "public let canaryValue: Int = 1\n"
        try placeholderSource.write(
            to: sourcesDir.appendingPathComponent("Library.swift"),
            atomically: true,
            encoding: .utf8
        )

        let manifest = """
            // swift-tools-version: 6.4
            import PackageDescription

            let package = Package(
                name: "canary-fixture",
                products: [
                    .library(name: "canary-fixture", targets: ["canary-fixture"])
                ],
                targets: [
                    .target(name: "canary-fixture", path: "Sources/canary-fixture")
                ]
            )
            """
        try manifest.write(
            to: root.appendingPathComponent("Package.swift"),
            atomically: true,
            encoding: .utf8
        )

        return root
    }

    private static func resolveSwiftExecutable() throws -> String {
        #if os(Windows)
            let executableName = "swift.exe"
            let pathSeparator: Character = ";"
        #else
            let executableName = "swift"
            let pathSeparator: Character = ":"
        #endif

        let environment = ProcessInfo.processInfo.environment
        guard let pathVariable = environment["PATH"] ?? environment["Path"] else {
            throw ToolchainCanaryError.pathNotSet
        }

        let fm = FileManager.default
        for directory in pathVariable.split(separator: pathSeparator) {
            let candidate = URL(fileURLWithPath: String(directory)).appendingPathComponent(
                executableName
            )
            if fm.isExecutableFile(atPath: candidate.path) {
                return candidate.path
            }
        }
        throw ToolchainCanaryError.swiftExecutableNotFound
    }

    private enum ToolchainCanaryError: Swift.Error, CustomStringConvertible {
        case pathNotSet
        case swiftExecutableNotFound

        var description: String {
            switch self {
            case .pathNotSet:
                return "Neither PATH nor Path is set in the process environment."

            case .swiftExecutableNotFound:
                return "Could not locate a swift executable on PATH."
            }
        }
    }
}
