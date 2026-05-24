import SwiftUI

struct LogView: View {
    @ObservedObject var viewModel: MoverViewModel

    private var service: RsyncService { viewModel.rsyncService }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Log content
            logContent
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Label("Log", systemImage: "list.bullet.rectangle")
                .font(.headline)
            Spacer()
            Text("\(service.logEntries.count) lines")
                .font(.caption)
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Log Content

    private var logContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if service.logEntries.isEmpty {
                        emptyLogPlaceholder
                    } else {
                        ForEach(service.logEntries) { entry in
                            LogRow(entry: entry)
                                .id(entry.id)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }
            .onChange(of: service.logEntries.count) {
                if let last = service.logEntries.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyLogPlaceholder: some View {
        Text("No output yet. Click \"Start Moving\" to begin.")
            .font(.caption)
            .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            .padding(.vertical, 8)
    }
}

// MARK: - Log Row

struct LogRow: View {
    let entry: LogEntry

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(Self.timeFormatter.string(from: entry.timestamp))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                .frame(width: 54, alignment: .trailing)

            Text(entry.message)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(entry.isError ? .red : .primary)
                .textSelection(.enabled)

            Spacer()
        }
        .padding(.vertical, 1)
    }
}