import Foundation

class RsyncService {
    static let shared = RsyncService()

    struct MoveResult {
        let success: [URL]
        let failed: [(URL, String)]
    }

    func move(files: [URL], to destination: URL) -> MoveResult {
        var success: [URL] = []
        var failed: [(URL, String)] = []

        let fm = FileManager.default
        for source in files {
            let target = destination.appendingPathComponent(source.lastPathComponent)
            do {
                if fm.fileExists(atPath: target.path) {
                    try fm.removeItem(at: target)
                }
                try fm.moveItem(at: source, to: target)
                success.append(source)
            } catch {
                failed.append((source, error.localizedDescription))
            }
        }

        RecentService.shared.add(path: destination.path)
        return MoveResult(success: success, failed: failed)
    }
}
