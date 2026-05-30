import SwiftUI
import UniformTypeIdentifiers

struct SourcePanel: View {
    @ObservedObject var viewModel: MoverViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 12)

            Divider()
                .padding(.top, 8)

            bodyContent
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            Image(systemName: "tray.full")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            Text(L10n.t("sourceFiles"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            Spacer()
            if !viewModel.files.isEmpty {
                Button(action: { viewModel.clearAll() }) {
                    Label(L10n.t("clearAll"), systemImage: "trash")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Body

    @ViewBuilder
    var bodyContent: some View {
        if viewModel.files.isEmpty {
            dropZoneView
        } else {
            fileListWithDropView
        }
    }

    // MARK: - Empty Drop Zone

    var dropZoneView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(viewModel.showDropHighlight
                    ? Color.accentColor.opacity(0.08)
                    : Color(NSColor.quaternaryLabelColor).opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            viewModel.showDropHighlight
                                ? Color.accentColor
                                : Color(NSColor.separatorColor).opacity(0.4),
                            style: StrokeStyle(lineWidth: 1.5,
                                dash: viewModel.showDropHighlight ? [] : [6, 3])
                        )
                )

            VStack(spacing: 10) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(viewModel.showDropHighlight ? .accentColor : .secondary.opacity(0.6))
                Text(L10n.t("dropFilesHere"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .onDrop(of: [.fileURL], isTargeted: $viewModel.showDropHighlight) { providers in
            loadURLs(from: providers) { urls in viewModel.addFiles(urls) }
            return true
        }
        .onTapGesture {
            openFilePicker()
        }
    }

    // MARK: - File List With Drop

    var fileListWithDropView: some View {
        VStack(spacing: 0) {
            // Stats bar
            HStack {
                Text("\(viewModel.totalFileCount) \(L10n.t("items"))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Text("•")
                    .foregroundColor(.secondary.opacity(0.5))
                Text(viewModel.totalSizeFormatted)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            // File rows with drop target
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.files) { item in
                        fileRow(item)
                        Divider().padding(.leading, 36)
                    }
                }
            }
            .overlay(dropOverlay)
        }
        .onDrop(of: [.fileURL], isTargeted: $viewModel.showDropHighlight) { providers in
            loadURLs(from: providers) { urls in viewModel.addFiles(urls) }
            return true
        }
    }

    // Drag highlight overlay
    @ViewBuilder
    var dropOverlay: some View {
        if viewModel.showDropHighlight {
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2.5))
                .background(Color.accentColor.opacity(0.06))
        }
    }

    // MARK: - File Row

    func fileRow(_ item: FileItem) -> some View {
        HStack(spacing: 8) {
            Image(systemName: item.isDirectory ? "folder" : "doc")
                .font(.system(size: 14))
                .foregroundColor(item.isDirectory ? .accentColor : .secondary)
                .frame(width: 20)

            Text(item.name)
                .font(.system(size: 13))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Text(item.sizeFormatted)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Button(action: { viewModel.removeFile(item) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .opacity(0.6)
            }
            .buttonStyle(.plain)
            .help(L10n.t("remove"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    func loadURLs(from providers: [NSItemProvider], completion: @escaping ([URL]) -> Void) {
        var urls: [URL] = []
        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url { urls.append(url) }
                group.leave()
            }
        }
        group.notify(queue: .main) { completion(urls) }
    }

    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.begin { response in
            if response == .OK {
                viewModel.addFiles(panel.urls)
            }
        }
    }
}
