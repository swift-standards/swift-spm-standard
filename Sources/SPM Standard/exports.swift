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

@_exported public import Package_Primitives
@_exported public import Version_Primitives
@_exported public import Version_Primitives_Standard_Library_Integration
