import Foundation
import UniformTypeIdentifiers

struct FileItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let isDirectory: Bool

    var sizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    static func fromURL(_ url: URL) -> FileItem? {
        let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
        return FileItem(
            url: url,
            name: url.lastPathComponent,
            size: Int64(resourceValues?.fileSize ?? 0),
            isDirectory: resourceValues?.isDirectory ?? false
        )
    }
}
