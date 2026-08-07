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
import Foundation
import Testing

@testable import SPM_Standard

// MARK: - Toolchain wire-format canary

extension `SPM Standard Tests` {
  /// Forward-looking canary against `swift package dump-package`
  /// JSON shape drift. The static golden-fixture tests in
  /// ``SPM Standard Tests/Codable Round-Trip`` freeze the wire
  /// shape at authoring time — they cannot detect a future
  /// SwiftPM that ships a wire-format change (for example, renaming
  /// `toolsVersion._version` → `toolsVersion.version`).
  ///
  /// The canary writes a SYNTHETIC Package.swift to a fresh temp
  /// directory and invokes the toolchain's `swift package
  /// dump-package` against it. Running against a synthetic
  /// fixture (instead of swift-spm-standard's own Package.swift)
  /// avoids SwiftPM's package-lock contention when the canary
  /// runs from inside `swift test` on the very package whose
  /// manifest it would otherwise be dumping.
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

    // Drain pipes synchronously so the subprocess cannot block
    // on a full pipe buffer.
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
    #expect(manifest.name == "canary-fixture")
  }

  /// Writes a self-contained, dependency-free SwiftPM package at a
  /// fresh temp directory and returns its URL. The fixture is
  /// minimal enough that `swift package dump-package` resolves it
  /// without consulting any external source — no network, no
  /// dependency-graph chatter, no contention with whatever outer
  /// `swift test` invocation may be holding a lock on the
  /// surrounding workspace.
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
      atomically: true, encoding: .utf8
    )

    let manifest = """
      // swift-tools-version: 6.3.1
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
      atomically: true, encoding: .utf8
    )

    return root
  }

  /// Locates the `swift` executable via `PATH`.
  ///
  /// `/usr/bin/env swift` (the POSIX shortcut) does not exist on Windows, and the
  /// gating `Windows (Swift 6.3, debug)` CI leg failed exactly there
  /// (`NSCocoaErrorDomain Code=260 "The file doesn't exist."`, `WindowsError Code=2`)
  /// before this canary ever reached `swift package dump-package`. Walk `PATH`
  /// (`Path` on Windows) ourselves instead of relying on a POSIX-only shim.
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
