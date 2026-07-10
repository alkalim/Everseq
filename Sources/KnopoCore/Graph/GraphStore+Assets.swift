import Foundation

extension GraphStore {
    public static let imageExtensions: Set<String> = [
        "png", "jpg", "jpeg", "gif", "webp", "heic", "heif", "tif", "tiff", "bmp", "svg",
        "avif", "jp2",
    ]

    public static func isImageFile(_ url: URL) -> Bool {
        imageExtensions.contains(url.pathExtension.lowercased())
    }

    /// Markdown for an imported asset. The src is written `../assets/<name>` —
    /// relative to the page file, the way Logseq and CommonMark tools (GitHub,
    /// Obsidian) resolve it — so pages stay portable; Knopo's own renderer
    /// resolves both this and a bare filename (§5.1).
    public static func imageMarkdown(assetNamed name: String, alt: String? = nil) -> String {
        let stem = URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent
        return "![\(alt ?? stem)](../assets/\(name))"
    }

    /// Copies a file into `assets/`, creating the directory on demand.
    @discardableResult
    public func importAsset(from source: URL) throws -> String {
        let source = source.standardizedFileURL
        if source.deletingLastPathComponent() == assetsDir.standardizedFileURL {
            return source.lastPathComponent
        }
        let name = Self.sanitizedAssetName(source.lastPathComponent)
        let destination = try uniqueAssetURL(named: name, matching: source)
        if destination.isExistingMatch { return destination.url.lastPathComponent }
        try FileManager.default.copyItem(at: source, to: destination.url)
        return destination.url.lastPathComponent
    }

    /// Writes raw asset bytes into `assets/`, creating the directory on demand.
    @discardableResult
    public func saveAsset(_ data: Data, preferredName: String) throws -> String {
        let name = Self.sanitizedAssetName(preferredName)
        let destination = try uniqueAssetURL(named: name, matching: data)
        if !destination.isExistingMatch {
            try data.write(to: destination.url, options: .atomic)
        }
        return destination.url.lastPathComponent
    }

    private static func sanitizedAssetName(_ name: String) -> String {
        let component = (name as NSString).lastPathComponent
        let forbidden = CharacterSet(charactersIn: "()[]/\\").union(.controlCharacters)
        let replaced = String(component.unicodeScalars.map { scalar -> Character in
            // Spaces become underscores (Logseq-style): CommonMark forbids
            // unescaped spaces in a link destination, so a spaced filename
            // would break the `![alt](src)` token outside Knopo.
            if scalar == " " { return "_" }
            return forbidden.contains(scalar) ? "-" : Character(scalar)
        })
        let stripped = replaced.drop(while: { $0 == "." })
        return stripped.isEmpty ? "image" : String(stripped)
    }

    private func uniqueAssetURL(named name: String, matching source: URL) throws
        -> (url: URL, isExistingMatch: Bool) {
        let data = try Data(contentsOf: source)
        return try uniqueAssetURL(named: name, matching: data)
    }

    private func uniqueAssetURL(named name: String, matching data: Data) throws
        -> (url: URL, isExistingMatch: Bool) {
        let fm = FileManager.default
        try fm.createDirectory(at: assetsDir, withIntermediateDirectories: true)

        let proposed = assetsDir.appendingPathComponent(name)
        if !fm.fileExists(atPath: proposed.path) {
            return (proposed, false)
        }
        if try Data(contentsOf: proposed) == data {
            return (proposed, true)
        }

        let nameURL = URL(fileURLWithPath: name)
        let ext = nameURL.pathExtension
        let stem = nameURL.deletingPathExtension().lastPathComponent
        var suffix = 1
        while true {
            let candidateName = ext.isEmpty ? "\(stem)-\(suffix)" : "\(stem)-\(suffix).\(ext)"
            let candidate = assetsDir.appendingPathComponent(candidateName)
            if !fm.fileExists(atPath: candidate.path) {
                return (candidate, false)
            }
            if try Data(contentsOf: candidate) == data {
                return (candidate, true)
            }
            suffix += 1
        }
    }
}
