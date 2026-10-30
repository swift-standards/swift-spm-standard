extension Package.Manifest {

    /// The `condition:` of a target dependency or of a trait a dependency requests: the platforms
    /// and the package's own traits under which it applies.
    public struct Condition: Swift::Sendable, Swift::Hashable {

        /// The platforms the condition is limited to; empty when it applies on every platform.
        public let platforms: [Swift::String]

        /// The package's traits of which at least one must be enabled; `nil` when the condition
        /// names no traits.
        public let traits: Swift::Set<Swift::String>?

        public init(
            platforms: [Swift::String] = [],
            traits: Swift::Set<Swift::String>? = nil
        ) {
            self.platforms = platforms
            self.traits = traits
        }
    }
}
