public struct SupportedPlatform: Swift::Sendable, Swift::Hashable {

    public let platform: Platform

    public let version: Version.Tools

    public init(platform: Platform, version: Version.Tools) {
        self.platform = platform
        self.version = version
    }
}
