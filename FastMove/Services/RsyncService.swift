import Foundation
import Combine

enum RsyncStatus: Equatable {
    case idle
    case running
    case completed
    case failed(String)
    case cancelled
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
    let isError: Bool
}

final class RsyncService: ObservableObject {
    @Published var status: RsyncStatus = .idle
    @Published var logEntries: [LogEntry] = []
    @Published var completedCount: Int = 0
    @Published var failedCount: Int = 0
    @Published var currentFile: String = ""

    private var currentProcess: Process?
    private var isCancelled = false
    private let logQueue = DispatchQueue(label: "com.filemover.rsync.log", qos: .utility)

    // MARK: - Public

    func moveFiles(sources: [URL], destination: URL) {
        guard status != .running else { return }

        resetState()
        status = .running
        isCancelled = false

        let total = sources.count
        let destDir = destination.path.hasSuffix("/") ? destination.path : destination.path + "/"

        addLog("Target: \(destination.path)", isError: false)
        addLog("Total items to move: \(total)", isError: false)
        addLog("Starting rsync operations...\n", isError: false)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            for (index, source) in sources.enumerated() {
                if self.isCancelled {
                    DispatchQueue.main.async { self.status = .cancelled }
                    return
                }

                let sourcePath = source.path
                let displayName = source.lastPathComponent

                DispatchQueue.main.async {
                    self.currentFile = displayName
                }

                self.addLog("[\(index + 1)/\(total)] \(displayName)", isError: false)

                let result = self.runSingleRsync(source: sourcePath, destDir: destDir)

                DispatchQueue.main.async {
                    if result {
                        self.completedCount += 1
                        self.addLog("  OK  \(displayName)", isError: false)
                    } else {
                        self.failedCount += 1
                        self.addLog("  FAIL  \(displayName)", isError: true)
                    }
                }
            }

            DispatchQueue.main.async {
                if !self.isCancelled {
                    self.status = .completed
                    self.currentFile = ""
                    self.addLog(
                        "\n--- Done ---\nCompleted: \(self.completedCount)  Failed: \(self.failedCount)",
                        isError: self.failedCount > 0
                    )
                }
            }
        }
    }

    func cancel() {
        isCancelled = true
        currentProcess?.terminate()
        status = .cancelled
        addLog("Cancelled by user.", isError: true)
    }

    // MARK: - Private

    private func resetState() {
        completedCount = 0
        failedCount = 0
        currentFile = ""
        logEntries.removeAll()
    }

    private func runSingleRsync(source: String, destDir: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/rsync")
        task.arguments = [
            "-avh",
            "--remove-source-files",
            "--ignore-existing",
            source,
            destDir,
        ]

        currentProcess = task

        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe

        do {
            try task.run()
        } catch {
            addLog("  rsync launch error: \(error.localizedDescription)", isError: true)
            return false
        }

        // Read stderr line-by-line for progress
        let errHandle = errPipe.fileHandleForReading
        errHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty,
                  let str = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !str.isEmpty else { return }
            self?.addLog("  \(str)", isError: false)
        }

        task.waitUntilExit()

        errHandle.readabilityHandler = nil
        currentProcess = nil

        return task.terminationStatus == 0
    }

    private func addLog(_ message: String, isError: Bool) {
        logQueue.async { [weak self] in
            let entry = LogEntry(timestamp: Date(), message: message, isError: isError)
            DispatchQueue.main.async {
                self?.logEntries.append(entry)
            }
        }
    }
}