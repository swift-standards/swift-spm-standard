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

extension Target {
  /// A single dependency declaration inside a SwiftPM target's
  /// `dependencies:` list.
  ///
  /// Mirrors the three SwiftPM target-dependency forms accepted
  /// in `PackageDescription.Target.Dependency`:
  ///
  /// ```swift
  /// dependencies: [
  ///     .product(name: "ArgumentParser", package: "swift-argument-parser"),
  ///     .target(name: "OtherTarget"),
  ///     "ByNameForm",
  /// ]
  /// ```
  ///
  /// The `.byName` form is a string literal that SwiftPM
  /// resolves at build time to either a sibling target or a
  /// product from a dependency (whichever matches). The typed
  /// `.product` and `.target` forms are unambiguous; `.byName`
  /// requires resolution against the package's full target +
  /// dependency set.
  ///
  /// Nested under L1's ``Target`` namespace per
  /// `[API-NAME-001]` / `[API-NAME-002]` — `Target.Dependency`,
  /// not the compound `TargetDependency`. The extension is
  /// supplied at L2 because the form set is SwiftPM-specific.
  public enum Dependency: Swift.Sendable, Swift.Hashable {
    /// `.product(name: "X", package: "Y")` — typed reference
    /// to a product `X` exported by dependency package `Y`.
    case product(name: Product.Name, package: Package.Name)

    /// `.target(name: "X")` — typed reference to a sibling
    /// target within the same package.
    case target(name: Target.Name)

    /// String-literal form (`"Foo"`) — SwiftPM resolves at
    /// build time to either a sibling target or a product
    /// from a dependency. The associated string is the
    /// literal name as written in the manifest.
    case byName(Swift.String)
  }
}
