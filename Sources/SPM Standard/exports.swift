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

// Re-export ecosystem modules referenced by SPM Standard's public surface so
// consumers can use the type ergonomically:
//
// - `Package_Primitives` — the L1 `Package` / `Product` / `Target` namespaces
//   and typed identifiers (`Package.Name`, `Product.Name`, `Target.Name`) on
//   which SPM Standard re-extends `Package` with `Dependency` / `Requirement`
//   / `Identity`.
// - `Version_Primitives` — `Version.Semantic` / `Version.Range` carry the
//   typed values for `Package.Requirement` variants.
// - `Paths` — `Paths.Path` carries the typed value for the
//   `Package.Dependency.Source.path` variant. Re-exported so consumers
//   can write `.path("../swift-bar")` literals via
//   `Path: ExpressibleByStringLiteral`.
// - `URI_Standard` + `URI_Standard_Library_Integration` — `URI` carries
//   the typed value for the `Package.Dependency.Source.url` variant. The
//   SLI provides `ExpressibleByStringLiteral` so consumers can write
//   `.url("https://…", from: "1.0.0")` literals.

@_exported public import Package_Primitives
@_exported public import Version_Primitives
@_exported public import Version_Primitives_Standard_Library_Integration
@_exported public import Paths
@_exported public import URI_Standard
@_exported public import URI_Standard_Library_Integration
