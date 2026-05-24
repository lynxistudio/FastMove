import SwiftUI
import Combine
import UniformTypeIdentifiers

final class MoverViewModel: ObservableObject {
    @Published var sourceItems: [FileItem] = []
    @Published var targetFolder: URL?

    let rsyncService = RsyncService()

    private var cancellables = Set<AnyCancellable>()

    init() {
        rsyncService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed

    var totalSourceSize: Int64 {
        sourceItems.reduce(0) { $0 + $1.fileSize }
    }

    var totalSourceCount: Int {
        sourceItems.count
    }

    var canStart: Bool {
        !sourceItems.isEmpty && targetFolder != nil && rsyncService.status != .running
    }

    var isRunning: Bool {
        rsyncService.status == .running
    }

    // MARK: - Source Management

    func addSourceItems(_ urls: [URL]) {
        for url in urls {
            let item = FileItem(url: url)
            if !sourceItems.contains(where: { $0.url == url }) {
                sourceItems.append(item)
            }
        }
    }

    func removeSourceItem(_ item: FileItem) {
        sourceItems.removeAll { $0.id == item.id }
    }

    func removeAllSourceItems() {
        sourceItems.removeAll()
    }

    func setTargetFolder(_ url: URL) {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir),
              isDir.boolValue else { return }
        targetFolder = url
    }

    func clearTargetFolder() {
        targetFolder = nil
    }

    // MARK: - Actions

    func startMoving() {
        guard canStart, let target = targetFolder else { return }
        let sources = sourceItems.map { $0.url }
        rsyncService.moveFiles(sources: sources, destination: target)
    }

    func cancelMoving() {
        rsyncService.cancel()
    }
}