import Foundation
import UniformTypeIdentifiers

struct FileItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let url: URL

    var name: String { url.lastPathComponent }

    var fileSize: Int64 {
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attrs[.size] as? Int64 {
            return size
        }
        return 0
    }

    var isDirectory: Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }

    var iconName: String {
        isDirectory ? "folder" : "doc"
    }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Int64 {
    var formattedFileSize: String {
        let fmt = ByteCountFormatter()
        fmt.countStyle = .file
        return fmt.string(fromByteCount: self)
    }
}