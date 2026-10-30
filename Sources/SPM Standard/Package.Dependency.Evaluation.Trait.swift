extension Package.Dependency.Evaluation {

    public struct Trait: Swift::Sendable, Swift::Hashable {

        public let name: Swift::String

        /// The traits of the requesting package under which this trait is requested; `nil` when it
        /// is requested unconditionally.
        public let condition: Package.Manifest.Condition?

        public init(name: Swift::String, condition: Package.Manifest.Condition? = nil) {
            self.name = name
            self.condition = condition
        }
    }
}
