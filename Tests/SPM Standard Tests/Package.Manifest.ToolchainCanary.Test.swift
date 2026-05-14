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

// Foundation `Process`/`Pipe`/`URL` and untyped `throws` from
// `JSONDecoder.decode` and `Process.run` are deliberately exempted
// across this file.
// swiftlint:disable no_foundation_import_warning typed_throws_required
import Foundation
import Testing
@testable import SPM_Standard

// MARK: - Toolchain wire-format canary

extension `SPM Standard Tests` {
    /// Forward-looking canary against `swift package dump-package`
    /// JSON shape drift. The static golden-fixture tests in
    /// ``SPM Standard Tests/Codable Round-Trip`` freeze the wire
    /// shape at authoring time — they cannot detect a future
    /// SwiftPM that ships a wire-format change (e.g. renaming
    /// `toolsVersion._version` → `toolsVersion.version`).
    ///
    /// This suite invokes the toolchain's actual `swift package
    /// dump-package` as a subprocess and feeds its stdout to the
    /// ``Package/Manifest`` Codable decoder. If a future toolchain
    /// breaks the wire format, this canary fails IMMEDIATELY rather
    /// than letting `Workspace.discover` throw `invalidManifestJSON`
    /// at first real use, possibly months after the breaking
    /// toolchain landed.
    @Suite struct `Toolchain Canary` {}
}

extension `SPM Standard Tests`.`Toolchain Canary` {
    @Test
    func `swift package dump-package output decodes via Package.Manifest Codable`() throws {
        let packageRoot = try Self._locatePackageRoot()

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "package", "dump-package"]
        process.currentDirectoryURL = packageRoot

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        // Drain pipes off the run loop while waiting so the
        // subprocess cannot block on a full pipe buffer.
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
            Package.Manifest.self, from: stdoutData
        )
        #expect(manifest.name == "swift-spm-standard")
    }

    /// Walks upward from this test file (`#filePath`) until it finds
    /// a directory containing `Package.swift`. Hard-coded absolute
    /// paths are forbidden — the test must work from any clone
    /// location.
    private static func _locatePackageRoot(
        filePath: Swift.String = #filePath
    ) throws -> URL {
        var url = URL(fileURLWithPath: filePath).deletingLastPathComponent()
        let fm = FileManager.default
        // Walk up at most 16 levels — anything deeper indicates
        // something is structurally wrong.
        for _ in 0..<16 {
            let candidate = url.appendingPathComponent("Package.swift")
            if fm.fileExists(atPath: candidate.path) {
                return url
            }
            let parent = url.deletingLastPathComponent()
            if parent.path == url.path {
                break
            }
            url = parent
        }
        Issue.record(
            "Could not locate Package.swift walking up from '\(filePath)'"
        )
        throw _CanaryError.packageRootNotFound
    }

    private enum _CanaryError: Swift.Error {
        case packageRootNotFound
    }
}
// swiftlint:enable no_foundation_import_warning typed_throws_required
