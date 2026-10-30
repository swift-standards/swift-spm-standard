extension Package.Manifest {

    /// A trait the package declares. The trait named `default` lists the package's default traits.
    public struct Trait: Swift::Sendable, Swift::Hashable {

        public let name: Swift::String

        /// The other traits of the package that this trait enables.
        public let enabledTraits: [Swift::String]

        public init(name: Swift::String, enabledTraits: [Swift::String] = []) {
            self.name = name
            self.enabledTraits = enabledTraits
        }
    }
}
