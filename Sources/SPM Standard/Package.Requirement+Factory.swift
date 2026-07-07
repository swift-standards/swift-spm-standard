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

// Half-open range literal → `Package.Requirement.range(...)` lift.
//
// The standard library's `..<` operator on `Comparable` returns
// `Swift.Range<Self>`. Adding a sibling overload here returning
// `Package.Requirement` lets the half-open literal lift directly
// to the typed requirement value under contextual typing:
//
//     let requirement: Package.Requirement = "1.0.0"..<"2.0.0"
//
//     source: .url("https://…", "1.0.0"..<"2.0.0")    // case payload is Package.Requirement
//
// Pattern matching is unchanged — `case .range(let r)` always
// binds to the typed `Version.Range`. The bare `..<` literal at
// non-Requirement contexts still returns `Swift.Range<Version.Semantic>`
// via the stdlib overload (Swift picks by result-type context).

/// `..<` overload returning `Package.Requirement.range(...)`.
///
/// Wraps the half-open `lower..<upper` range produced by the
/// stdlib operator into the typed `Version.Range` payload, then
/// the `.range(_)` case.
///
/// Declared at module scope rather than as a member operator on
/// `Package.Requirement` because Swift requires member operators
/// to take at least one parameter of the enclosing type; here
/// both operands are `Version.Semantic` and only the return type
/// is `Package.Requirement`.
@inlinable
public func ..< (
  lower: Version.Semantic,
  upper: Version.Semantic
) -> Package.Requirement {
  .range(
    Version.Range(
      lowerBound: .inclusive(lower),
      upperBound: .exclusive(upper)
    ))
}
