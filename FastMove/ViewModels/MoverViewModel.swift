import SwiftUI
import AppKit

struct MoveRecord: Identifiable {
    let id = UUID()
    let sourceURLs: [URL]
    let targetPath: String
    var result: RsyncService.MoveResult
    let timestamp: Date
    var undone = false
}

@MainActor
class MoverViewModel: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var targetPath: String = ""
    @Published var isMoving = false
    @Published var showDropHighlight = false
    @Published var toastMessage: String = ""
    @Published var showToast = false
    @Published var favorites: [FavoriteFolder] = []
    @Published var recentPaths: [String] = []
    @Published var moveProgress: Double = 0.0
    @Published var currentMovingFile: String = ""
    @Published var moveHistory: [MoveRecord] = []

    private var toastTimer: Timer?

    var moveCompleted: Bool { !moveHistory.isEmpty }

    init() {
        favorites = FavoriteService.shared.load()
        recentPaths = RecentService.shared.load()
    }

    // MARK: - Source Files

    var totalFileCount: Int { files.count }
    var totalSize: Int64 { files.reduce(0) { $0 + $1.size } }
    var totalSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    func addFiles(_ urls: [URL]) {
        var added = 0
        var addedFolders = 0
        for url in urls {
            if let item = FileItem.fromURL(url), !files.contains(where: { $0.url == url }) {
                files.append(item)
                if item.isDirectory { addedFolders += 1 } else { added += 1 }
            }
        }
        var parts: [String] = []
        if added > 0 { parts.append("\(L10n.t("added")) \(added) \(L10n.t("files"))") }
        if addedFolders > 0 { parts.append("\(L10n.t("added")) \(addedFolders) \(L10n.t("folders"))") }
        if !parts.isEmpty {
            showToastMessage(parts.joined(separator: ", "))
        }
    }

    func removeFile(_ item: FileItem) {
        files.removeAll { $0.id == item.id }
    }

    func clearAll() {
        files.removeAll()
    }

    // MARK: - Target

    func setTarget(_ path: String) {
        targetPath = path
    }

    func clearTarget() {
        targetPath = ""
    }

    func setDropHighlight(_ active: Bool) {
        withAnimation(.easeInOut(duration: 0.15)) {
            showDropHighlight = active
        }
    }

    // MARK: - Toast

    func showToastMessage(_ msg: String) {
        toastMessage = msg
        showToast = true
        toastTimer?.invalidate()
        toastTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.showToast = false
            }
        }
    }

    // MARK: - Move

    func startMove() {
        guard !files.isEmpty, !targetPath.isEmpty else { return }
        isMoving = true
        moveProgress = 0.0
        currentMovingFile = ""

        let destURL = URL(fileURLWithPath: targetPath)
        let urls = files.map { $0.url }
        let sourceURLs = urls
        let total = Double(urls.count)
        let fileNames = files.map { $0.name }

        Task.detached { [weak self] in
            var success: [URL] = []
            var failed: [(URL, String)] = []
            let fm = FileManager.default

            for (i, source) in urls.enumerated() {
                await MainActor.run {
                    self?.currentMovingFile = fileNames[i]
                    self?.moveProgress = Double(i) / total
                }
                let target = destURL.appendingPathComponent(source.lastPathComponent)
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

            RecentService.shared.add(path: destURL.path)

            let moveResult = RsyncService.MoveResult(success: success, failed: failed)
            let record = MoveRecord(sourceURLs: sourceURLs, targetPath: destURL.path,
                                     result: moveResult, timestamp: Date())

            await MainActor.run {
                self?.moveProgress = 1.0
                self?.moveHistory.append(record)
                self?.isMoving = false
                self?.files.removeAll()
            }
        }
    }

    func retryFailed() {
        guard let lastRecord = moveHistory.last, !lastRecord.result.failed.isEmpty else { return }
        isMoving = true
        moveProgress = 0.0

        let failedItems = lastRecord.result.failed
        let total = Double(failedItems.count)
        let destURL = URL(fileURLWithPath: lastRecord.targetPath)

        Task.detached { [weak self] in
            var success: [URL] = []
            var failed: [(URL, String)] = []
            let fm = FileManager.default

            for (i, item) in failedItems.enumerated() {
                let source = item.0
                await MainActor.run {
                    self?.currentMovingFile = source.lastPathComponent
                    self?.moveProgress = Double(i) / total
                }
                let target = destURL.appendingPathComponent(source.lastPathComponent)
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

            // Merge results: keep previous success + retry success
            let merged = RsyncService.MoveResult(
                success: lastRecord.result.success + success,
                failed: failed
            )

            await MainActor.run {
                self?.moveProgress = 1.0
                if let idx = self?.moveHistory.lastIndex(where: { $0.id == lastRecord.id }) {
                    self?.moveHistory[idx].result = merged
                }
                self?.isMoving = false
            }
        }
    }

    // MARK: - Undo

    func undoMove(_ record: MoveRecord) {
        guard !record.undone, let idx = moveHistory.firstIndex(where: { $0.id == record.id }) else { return }
        moveHistory[idx].undone = true

        let destURL = URL(fileURLWithPath: record.targetPath)
        let fm = FileManager.default

        for source in record.result.success {
            let movedFile = destURL.appendingPathComponent(source.lastPathComponent)
            // Ensure parent directory exists at original location
            let sourceParent = source.deletingLastPathComponent()
            if !fm.fileExists(atPath: sourceParent.path) {
                try? fm.createDirectory(at: sourceParent, withIntermediateDirectories: true)
            }
            // Remove any existing file at source (shouldn't exist, but be safe)
            if fm.fileExists(atPath: source.path) {
                try? fm.removeItem(at: source)
            }
            do {
                try fm.moveItem(at: movedFile, to: source)
            } catch {
                // If undo fails, mark as not undone
                moveHistory[idx].undone = false
                self.showToastMessage("\(L10n.t("undoFailed")): \(source.lastPathComponent)")
                return
            }
        }
        showToastMessage(L10n.t("undoCompleted"))
    }

    func reset() {
        files = []
        isMoving = false
        moveProgress = 0.0
        currentMovingFile = ""
    }

    // MARK: - Favorites

    func toggleFavorite(path: String) {
        if FavoriteService.shared.isFavorite(path: path) {
            favorites = FavoriteService.shared.remove(path: path)
        } else {
            let name = URL(fileURLWithPath: path).lastPathComponent
            favorites = FavoriteService.shared.add(name: name, path: path)
        }
    }

    func removeFavorite(_ folder: FavoriteFolder) {
        favorites = FavoriteService.shared.remove(path: folder.path)
    }

    // MARK: - Recent

    func loadRecents() {
        recentPaths = RecentService.shared.load()
    }

    func clearRecent(path: String) {
        RecentService.shared.remove(path: path)
        recentPaths = RecentService.shared.load()
    }
}
