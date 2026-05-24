import SwiftUI
import UniformTypeIdentifiers

struct SourcePanel: View {
    @ObservedObject var viewModel: MoverViewModel
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Drop zone or file list
            if viewModel.sourceItems.isEmpty {
                dropZoneView
            } else {
                fileListView
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Label("Source Files", systemImage: "tray.full")
                .font(.headline)
            Spacer()
            if !viewModel.sourceItems.isEmpty {
                Button(L10n.t("clearAll")) {
                    viewModel.removeAllSourceItems()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Drop Zone

    private var dropZoneView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("Drop files or folders here")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Supports images, videos, documents, folders")
                .font(.caption)
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
                .padding(12)
        )
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    // MARK: - File List

    private var fileListView: some View {
        VStack(spacing: 0) {
            // Stats bar
            statsBar

            Divider()

            // List
            List {
                ForEach(viewModel.sourceItems) { item in
                    FileRowView(item: item) {
                        viewModel.removeSourceItem(item)
                    }
                }
                if !viewModel.sourceItems.isEmpty {
                    dropHintRow
                }
            }
            .listStyle(.plain)
        }
        .onDrop(of: [.fileURL], isTargeted: .constant(false)) { providers in
            handleDrop(providers: providers)
        }
    }

    private var statsBar: some View {
        HStack {
            Text("\(viewModel.totalSourceCount) item\(viewModel.totalSourceCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("·")
                .foregroundColor(.secondary)
            Text(viewModel.totalSourceSize.formattedFileSize)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    private var dropHintRow: some View {
        HStack {
            Spacer()
            Image(systemName: "plus.circle")
                .font(.caption)
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            Text("Drop more files here to add")
                .font(.caption2)
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Drop Handler

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
                guard let urlData = data as? Data,
                      let path = String(data: urlData, encoding: .utf8),
                      let url = URL(string: path) else { return }
                DispatchQueue.main.async {
                    viewModel.addSourceItems([url])
                }
            }
        }
        return true
    }
}

// MARK: - File Row

struct FileRowView: View {
    let item: FileItem
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.iconName)
                .foregroundColor(item.isDirectory ? .blue : .secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(item.fileSize.formattedFileSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("Remove from list")
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
}