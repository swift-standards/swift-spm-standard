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

// MARK: - Platform unit

extension `SPM Standard Tests`.Unit {
  @Test
  func `Platform raw values match dump-package wire tokens (lowercase)`() {
    #expect(Platform.macOS.rawValue == "macos")
    #expect(Platform.iOS.rawValue == "ios")
    #expect(Platform.tvOS.rawValue == "tvos")
    #expect(Platform.watchOS.rawValue == "watchos")
    #expect(Platform.visionOS.rawValue == "visionos")
    #expect(Platform.macCatalyst.rawValue == "maccatalyst")
    #expect(Platform.driverKit.rawValue == "driverkit")
    #expect(Platform.linux.rawValue == "linux")
    #expect(Platform.android.rawValue == "android")
    #expect(Platform.windows.rawValue == "windows")
    #expect(Platform.wasi.rawValue == "wasi")
    #expect(Platform.freeBSD.rawValue == "freebsd")
    #expect(Platform.openBSD.rawValue == "openbsd")
  }
}

// MARK: - SupportedPlatform round-trips

extension `SPM Standard Tests`.`Codable Round-Trip` {
  @Test
  func `SupportedPlatform round-trips through JSON`() throws {
    let supported = SupportedPlatform(platform: .macOS, version: "26.0")
    let encoded = try JSONEncoder().encode(supported)
    let decoded = try JSONDecoder().decode(SupportedPlatform.self, from: encoded)
    #expect(decoded == supported)
  }

  @Test
  func `SupportedPlatform decodes dump-package wire shape`() throws {
    let json = """
      {"options": [], "platformName": "macos", "version": "26.0"}
      """
    let data = try #require(json.data(using: .utf8))
    let supported = try JSONDecoder().decode(SupportedPlatform.self, from: data)
    #expect(supported.platform == .macOS)
    #expect(supported.version == "26.0")
  }

  @Test
  func `SupportedPlatform array decodes from dump-package platforms[]`() throws {
    let json = """
      [
        {"options": [], "platformName": "macos", "version": "26.0"},
        {"options": [], "platformName": "ios", "version": "26.0"},
        {"options": [], "platformName": "linux", "version": "1.0"}
      ]
      """
    let data = try #require(json.data(using: .utf8))
    let platforms = try JSONDecoder().decode([SupportedPlatform].self, from: data)
    #expect(platforms.count == 3)
    #expect(platforms[0].platform == .macOS)
    #expect(platforms[1].platform == .iOS)
    #expect(platforms[2].platform == .linux)
  }
}
