import SwiftUI
import UniformTypeIdentifiers

struct TargetPanel: View {
    @ObservedObject var viewModel: MoverViewModel
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Content
            if let target = viewModel.targetFolder {
                selectedFolderView(target: target)
            } else {
                dropTargetView
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Label("Target Folder", systemImage: "folder")
                .font(.headline)
            Spacer()
            if viewModel.targetFolder != nil {
                Button("Clear") {
                    viewModel.clearTargetFolder()
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

    // MARK: - Empty Drop Zone

    private var dropTargetView: some View {
        HStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            Text("Drop destination folder here")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.25),
                    style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                )
                .padding(8)
        )
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleTargetDrop(providers: providers)
        }
    }

    // MARK: - Selected Folder

    private func selectedFolderView(target: URL) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.system(size: 22))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(target.lastPathComponent)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)

                Text(target.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            // Allow re-drop to change target
            Text("Drop to replace")
                .font(.caption2)
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .onDrop(of: [.fileURL], isTargeted: .constant(false)) { providers in
            handleTargetDrop(providers: providers)
        }
    }

    // MARK: - Drop Handler

    private func handleTargetDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
            guard let urlData = data as? Data,
                  let path = String(data: urlData, encoding: .utf8),
                  let url = URL(string: path) else { return }
            DispatchQueue.main.async {
                viewModel.setTargetFolder(url)
            }
        }
        return true
    }
}