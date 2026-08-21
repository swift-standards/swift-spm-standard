extension Package.Resolution.Dependency {

    public enum State: Swift.Sendable, Swift.Hashable {

        case sourceControlCheckout(Package.Resolution.Checkout)

        case fileSystem(path: Swift.String)

        case edited(path: Swift.String, basedOn: Package.Resolution.Dependency.Superseded?)
    }
}

extension Package.Resolution.Dependency.State {

    public var checkout: Package.Resolution.Checkout? {
        switch self {
        case .sourceControlCheckout(let checkout): checkout
        case .fileSystem, .edited: nil
        }
    }

    public var path: Swift.String? {
        switch self {
        case .fileSystem(let path), .edited(let path, _): path
        case .sourceControlCheckout: nil
        }
    }

    public var superseded: Package.Resolution.Dependency.Superseded? {
        switch self {
        case .edited(_, let superseded): superseded
        case .sourceControlCheckout, .fileSystem: nil
        }
    }
}
