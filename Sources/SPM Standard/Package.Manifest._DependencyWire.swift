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

extension Package.Manifest {
  /// Wire-format shim for one entry in the `dependencies[]` array
  /// emitted by `swift package dump-package`. The element is a
  /// discriminated union — exactly one of `fileSystem`,
  /// `sourceControl`, or `registry` is non-`nil`. Each carries an
  /// array of one inner record.
  internal struct _DependencyWire: Codable {
    let fileSystem: [_FileSystemRecord]?
    let sourceControl: [_SourceControlRecord]?
    let registry: [_RegistryRecord]?

    init(
      fileSystem: [_FileSystemRecord]? = nil,
      sourceControl: [_SourceControlRecord]? = nil,
      registry: [_RegistryRecord]? = nil
    ) {
      self.fileSystem = fileSystem
      self.sourceControl = sourceControl
      self.registry = registry
    }

    init(from dependency: Package.Dependency) {
      switch dependency.source {
      case .path(let path):
        self.init(fileSystem: [
          _FileSystemRecord(identity: dependency.name.underlying, path: path.string)
        ])
      case .url(let url, let requirement):
        self.init(sourceControl: [
          _SourceControlRecord(
            identity: dependency.name.underlying,
            location: .init(remote: [.init(urlString: url.value)]),
            requirement: _RequirementWire(from: requirement)
          )
        ])
      case .registry(let identity, let requirement):
        self.init(registry: [
          _RegistryRecord(
            identity: "\(identity.scope).\(identity.name)",
            requirement: _RequirementWire(from: requirement)
          )
        ])
      }
    }

    func toDependency() throws -> Package.Dependency {
      if let record = fileSystem?.first {
        let path: Paths.Path
        do {
          path = try Paths.Path(record.path)
        } catch {
          throw DecodingError.dataCorrupted(
            DecodingError.Context(
              codingPath: [],
              debugDescription: "Invalid path '\(record.path)' in fileSystem dependency: \(error)"
            )
          )
        }
        return Package.Dependency(
          source: .path(path),
          name: Package.Name(_unchecked: record.identity),
          products: []
        )
      }
      if let record = sourceControl?.first {
        let urlString = record.location.remote.first?.urlString ?? ""
        let url: URI
        do {
          url = try URI(urlString)
        } catch {
          throw DecodingError.dataCorrupted(
            DecodingError.Context(
              codingPath: [],
              debugDescription: "Invalid URI '\(urlString)' in sourceControl dependency: \(error)"
            )
          )
        }
        let requirement = try record.requirement.toRequirement()
        return Package.Dependency(
          source: .url(url, requirement),
          name: Package.Name(_unchecked: record.identity),
          products: []
        )
      }
      if let record = registry?.first {
        let requirement = try record.requirement.toRequirement()
        return Package.Dependency(
          source: .registry(
            try _parseIdentity(record.identity),
            requirement
          ),
          name: Package.Name(_unchecked: record.identity),
          products: []
        )
      }
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Dependency record matched none of fileSystem/sourceControl/registry"
        )
      )
    }
  }
}
