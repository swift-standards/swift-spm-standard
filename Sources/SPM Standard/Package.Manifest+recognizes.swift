public import Byte

extension Package.Manifest {
    /// Whether `source` is a SwiftPM package manifest rather than an ordinary Swift
    /// file that happens to be named `Package.swift`.
    ///
    /// A manifest imports `PackageDescription` or binds `package` to a `Package(…)`
    /// call; comments and string literals do not count. A production source file such
    /// as `Sources/Package/Package.swift` declaring a `Package` namespace does neither,
    /// and SwiftPM compiles it as part of its target, so tools that skip nested
    /// packages must not skip the directory that holds it. Source discovery that
    /// prunes nested packages asks this one question, so its tools agree on which
    /// files they measure.
    public static func recognizes(_ source: [Byte]) -> Swift::Bool {
        let tokens: [Package.Dependency.Declaration.Parser.Token]
        do throws(Package.Dependency.Declaration.Parser.Error) {
            tokens = try Package.Dependency.Declaration.Parser().tokenize(source.map(\.underlying))
        } catch {
            return false
        }
        let kinds = tokens.map(\.kind)
        for index in kinds.indices {
            if kinds[index] == .identifier("import"),
                index + 1 < kinds.count,
                kinds[index + 1] == .identifier("PackageDescription")
            {
                return true
            }
            // The tokenizer keeps no `=`, so `let package = Package(` and
            // `let package: Package = Package(` arrive as `let package Package (`
            // and `let package : Package Package (`: a `Package (` call within
            // the next three tokens.
            guard kinds[index] == .identifier("let") || kinds[index] == .identifier("var"),
                index + 1 < kinds.count,
                kinds[index + 1] == .identifier("package")
            else { continue }
            let call = kinds.indices.dropFirst(index + 2).prefix(3)
            guard
                call.contains(where: { position in
                    kinds[position] == .identifier("Package")
                        && position + 1 < kinds.count
                        && kinds[position + 1] == .punctuation(0x28)
                })
            else { continue }
            return true
        }
        return false
    }
}
