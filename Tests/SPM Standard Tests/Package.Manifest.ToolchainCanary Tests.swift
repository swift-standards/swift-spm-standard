import Foundation
import Testing

@testable import SPM_Standard

extension `SPM Standard Tests` {

    @Suite struct `Toolchain Canary` {}
}

extension `SPM Standard Tests`.`Toolchain Canary` {
    @Test
    func `captured swift package dump-package output decodes via Package.Manifest Codable`() throws {
        let manifest = try JSONDecoder().decode(
            Package.Manifest.self,
            from: Data(Self.capturedDumpPackage.utf8)
        )
        #expect(manifest.name == "canary-fixture")
    }

    private static let capturedDumpPackage = #"""
        {
          "cLanguageStandard": null,
          "cxxLanguageStandard": null,
          "defaultLocalization": null,
          "dependencies": [],
          "name": "canary-fixture",
          "packageKind": {
            "root": [
              "/fixture"
            ]
          },
          "pkgConfig": null,
          "platforms": [],
          "products": [
            {
              "name": "canary-fixture",
              "settings": [],
              "targets": [
                "canary-fixture"
              ],
              "type": {
                "library": [
                  "automatic"
                ]
              }
            }
          ],
          "providers": null,
          "swiftLanguageVersions": null,
          "targets": [
            {
              "dependencies": [],
              "exclude": [],
              "name": "canary-fixture",
              "packageAccess": true,
              "path": "Sources/canary-fixture",
              "resources": [],
              "settings": [],
              "type": "regular"
            }
          ],
          "toolsVersion": {
            "_version": "6.4.0"
          },
          "traits": []
        }
        """#
}
