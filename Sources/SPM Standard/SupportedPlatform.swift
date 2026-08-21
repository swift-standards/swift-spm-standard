public struct SupportedPlatform: Swift.Sendable, Swift.Hashable {

    public let platform: Platform

    public let version: Swift.String

    public init(platform: Platform, version: Swift.String) {
        self.platform = platform
        self.version = version
    }
}
