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

// Decodable conformance is excluded from Embedded Swift — it depends on
// stdlib protocols and runtime infrastructure that Embedded does not ship.
//
// `Decodable`'s protocol requirement forces an existential decoder parameter
// and untyped `throws`; both rules are deliberately exempted for this file.
//
// **Decodable, not Codable.** An evaluation is an *observation* of what the
// installed SwiftPM printed. Nothing in this ecosystem needs to synthesise
// that output, and an honest encoder is not currently possible: `products` is
// back-filled from target edges rather than carried on the dependency record,
// so an element-level round trip could not be faithful. The encoding surface
// is therefore not offered rather than offered lossily. Test fixtures are
// authored as JSON literals, so no internal encoder is needed either.
//
// This is a **dedicated decode path**. It does not replace, wrap, or
// reinterpret ``Package/Manifest``'s decoder, whose public behaviour is
// unchanged: that decoder continues to model the portable declaration and
// continues to accept only `sourceControl.location.remote`.
//
// The two paths share the requirement shim (``Package/Manifest/_RequirementWire``),
// the remote-record shim, the registry-identity parser, the tools-version shim,
// and the manifest-level product/target/platform values. They deliberately do
// not share the dependency or location shims, because the evaluation wire
// admits shapes the declaration wire does not.
//
// Ignore-extras strategy: unknown top-level and record-level keys are decoded
// and discarded, matching ``Package/Manifest``. The exceptions are the
// *required discriminators* — the dependency kind and the source-control
// location — where an absent, ambiguous, empty, or multi-element array is
// rejected rather than guessed.

#if !hasFeature(Embedded)
    extension Package.Manifest.Evaluation: Decodable {
        private enum CodingKeys: Swift.String, CodingKey {
            case name
            case toolsVersion
            case dependencies
            case products
            case targets
            case platforms
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // `name` decoded as a bare string for the same reason as
            // ``Package/Manifest``: `Package.Name` is `Tagged<Package, String>` and
            // Tagged's synthesised Codable uses a keyed container that does not
            // match the dump-package wire shape.
            let nameString = try container.decode(Swift.String.self, forKey: .name)
            let name = Package.Name(_unchecked: nameString)

            let toolsWire = try container.decode(
                Package.Manifest._ToolsVersionWire.self,
                forKey: .toolsVersion
            )
            let toolsVersion: Version.Tools
            do throws(Version.Tools.Error) {
                toolsVersion = try Version.Tools(parsing: toolsWire._version)
            } catch {
                throw DecodingError.dataCorruptedError(
                    forKey: .toolsVersion,
                    in: container,
                    debugDescription:
                        "Invalid tools-version string '\(toolsWire._version)': \(error)"
                )
            }

            let wireDependencies = try container.decode(
                [Package.Manifest.Evaluation._DependencyWire].self,
                forKey: .dependencies
            )
            // [IMPL-109]: an explicit loop rather than `map { try … }`, which would
            // route the typed throw through a stdlib `rethrows` shim and erase it.
            var baseDependencies: [Package.Dependency.Evaluation] = []
            baseDependencies.reserveCapacity(wireDependencies.count)
            for wire in wireDependencies {
                baseDependencies.append(try Package.Dependency.Evaluation(wire))
            }

            let products =
                try container.decodeIfPresent(
                    [Package.Manifest.Product].self,
                    forKey: .products
                ) ?? []
            let targets =
                try container.decodeIfPresent(
                    [Package.Manifest.Target].self,
                    forKey: .targets
                ) ?? []
            let platforms = try container.decodeIfPresent(
                [SupportedPlatform].self,
                forKey: .platforms
            )

            self.init(
                name: name,
                toolsVersion: toolsVersion,
                dependencies: Self._backfillProducts(
                    dependencies: baseDependencies,
                    targets: targets
                ),
                products: products,
                targets: targets,
                platforms: platforms
            )
        }
    }

    // MARK: - Local helpers

    extension Package.Manifest.Evaluation {
        /// A `DecodingError.dataCorrupted` carrying `message`.
        ///
        /// Every rejection on this decode path routes through here so a malformed
        /// evaluation always fails loudly and never falls back to an empty string,
        /// an empty `URI`, or a fabricated `file://` URL.
        internal static func _corrupt(_ message: Swift.String) -> DecodingError {
            DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: message)
            )
        }

        /// Require a wire union array to hold exactly one element.
        ///
        /// The installed wire contract emits single-element arrays for every
        /// discriminator. Taking `.first` would silently discard extra records and
        /// make the claim of losslessness false, so both zero and two-or-more are
        /// rejected.
        internal static func _exactlyOne<Element>(
            _ array: [Element]?,
            _ label: Swift.String
        ) throws(DecodingError) -> Element {
            guard let array else {
                throw _corrupt("\(label) is absent")
            }
            guard array.count == 1 else {
                throw _corrupt(
                    "\(label) must contain exactly one element, found \(array.count)"
                )
            }
            return array[0]
        }

        /// Validate and wrap an emitted identity token.
        internal static func _identity(
            _ token: Swift.String,
            _ label: Swift.String
        ) throws(DecodingError) -> Package.Dependency.Evaluation.Identity {
            guard !token.isEmpty else {
                throw _corrupt("\(label).identity is empty")
            }
            return .init(token)
        }

        /// Project the per-dependency `traits` array.
        internal static func _traits(
            _ wire: [_TraitWire]?
        ) -> [Package.Dependency.Evaluation.Trait] {
            (wire ?? []).map { .init(name: $0.name) }
        }

        /// Adapt the shared requirement shim's untyped throw to `DecodingError`.
        ///
        /// ``Package/Manifest/_RequirementWire/toRequirement()`` predates this
        /// decode path and throws untyped; this is the single adaptation point, so
        /// every declaration this path owns stays typed per `[API-ERR-001]`. The
        /// concrete `DecodingError` is preserved rather than re-wrapped.
        internal static func _requirement(
            _ wire: Package.Manifest._RequirementWire,
            _ label: Swift.String
        ) throws(DecodingError) -> Package.Requirement {
            do {
                return try wire.toRequirement()
            } catch let error as DecodingError {
                throw error
            } catch {
                throw _corrupt("\(label).requirement is invalid: \(error)")
            }
        }

        /// Adapt the shared registry-identity parser's untyped throw, as above.
        internal static func _registry(
            _ token: Swift.String
        ) throws(DecodingError) -> Package.Identity {
            do {
                return try Package.Manifest._parseIdentity(token)
            } catch let error as DecodingError {
                throw error
            } catch {
                throw _corrupt("registry.identity '\(token)' is invalid: \(error)")
            }
        }

        /// Back-fill each evaluated dependency's `products` from the
        /// target-dependency edges.
        ///
        /// The evaluation wire emits dependencies without their consumed product
        /// names; that information lives in `targets[].dependencies[]` as
        /// `.product([productName, packageIdentity, ...])`. This walks those
        /// edges, keyed on the *emitted identity token* rather than on a manifest
        /// name, and rebuilds each dependency with its product list populated.
        /// Order is deterministic — first occurrence in target order.
        internal static func _backfillProducts(
            dependencies: [Package.Dependency.Evaluation],
            targets: [Package.Manifest.Target]
        ) -> [Package.Dependency.Evaluation] {
            var ordered: [Swift.String: [Package_Primitives.Product.Name]] = [:]
            var seen: [Swift.String: Swift.Set<Package_Primitives.Product.Name>] = [:]
            for target in targets {
                for edge in target.dependencies {
                    guard case .product(let productName, let packageName) = edge else {
                        continue
                    }
                    let token = packageName.underlying
                    if seen[token, default: []].insert(productName).inserted {
                        ordered[token, default: []].append(productName)
                    }
                }
            }
            return dependencies.map {
                (dependency: Package.Dependency.Evaluation) -> Package.Dependency.Evaluation in
                let token = dependency.identity.underlying
                guard let products = ordered[token], !products.isEmpty else {
                    return dependency
                }
                return Package.Dependency.Evaluation(
                    source: dependency.source,
                    products: products,
                    traits: dependency.traits
                )
            }
        }
    }
#endif
