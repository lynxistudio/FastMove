import SwiftUI

struct TargetPanel: View {
    @ObservedObject var viewModel: MoverViewModel
    @State private var targetHighlight = false

    var body: some View {
        VStack(spacing: 0) {
            // Header - matches SourcePanel style
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 12)

            Divider()
                .padding(.top, 8)

            // Drop zone
            targetDropArea
                .padding(.horizontal, 16)
                .padding(.top, 8)

            Divider()
                .padding(.vertical, 8)

            // Favorites
            favoritesSection
                .padding(.horizontal, 16)

            Divider()
                .padding(.vertical, 8)

            // Recent
            recentSection
                .padding(.horizontal, 16)

            // Progress / Completion area
            if viewModel.isMoving {
                Divider().padding(.vertical, 8)
                MoveProgressView(viewModel: viewModel)
                    .padding(.horizontal, 16)
            } else if !viewModel.moveHistory.isEmpty {
                Divider().padding(.vertical, 8)
                moveHistorySection
                    .padding(.horizontal, 16)
            }

            Spacer()

            Divider()

            startButtonArea
                .padding(12)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            Text(L10n.t("targetFolder"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            Spacer()
            if !viewModel.targetPath.isEmpty {
                Button(action: { viewModel.clearTarget() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary.opacity(0.6))
            }
        }
    }

    // MARK: - Drop Zone

    var targetDropArea: some View {
        Group {
            if viewModel.targetPath.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 13))
                        .foregroundColor(targetHighlight ? .accentColor : .secondary.opacity(0.5))
                    Text(L10n.t("dropTargetHere"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: { browseTarget() }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(targetHighlight
                            ? Color.accentColor.opacity(0.1)
                            : Color(NSColor.quaternaryLabelColor).opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(
                            targetHighlight ? Color.accentColor : Color(NSColor.separatorColor).opacity(0.35),
                            style: StrokeStyle(lineWidth: 1.5,
                                dash: targetHighlight ? [] : [6, 3])
                        )
                )
                .onTapGesture { browseTarget() }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(URL(fileURLWithPath: viewModel.targetPath).lastPathComponent)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(1)
                        Text(viewModel.targetPath)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Button(action: { browseTarget() }) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .help(L10n.t("changeTarget"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.accentColor.opacity(0.05))
                )
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $targetHighlight) { providers in
            resolveTarget(from: providers)
            return true
        }
    }

    // MARK: - Move History

    var moveHistorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(viewModel.moveHistory) { record in
                historyRow(record)
            }
        }
    }

    func historyRow(_ record: MoveRecord) -> some View {
        let successCount = record.result.success.count
        let failedCount = record.result.failed.count
        let targetName = URL(fileURLWithPath: record.targetPath).lastPathComponent

        return HStack(spacing: 6) {
            if record.undone {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else if failedCount == 0 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            } else if successCount > 0 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(record.undone
                    ? "\(L10n.t("undone")) — \(successCount) \(L10n.t("items")) → \(targetName)"
                    : "\(successCount) \(L10n.t("items")) → \(targetName)")
                    .font(.system(size: 12, weight: .medium))
                    .strikethrough(record.undone)
                    .foregroundColor(record.undone ? .secondary : .primary)
                if failedCount > 0 && !record.undone {
                    Text("\(failedCount) \(L10n.t("failed"))")
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }
            }

            Spacer()

            if !record.undone {
                Button(action: { viewModel.undoMove(record) }) {
                    Label(L10n.t("undo"), systemImage: "arrow.uturn.backward")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(NSColor.quaternaryLabelColor).opacity(record.undone ? 0 : 0.3))
        )
    }

    // MARK: - Favorites

    var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.yellow)
                Text(L10n.t("favorites"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                if !viewModel.targetPath.isEmpty {
                    Button(action: { viewModel.toggleFavorite(path: viewModel.targetPath) }) {
                        Image(systemName: FavoriteService.shared.isFavorite(path: viewModel.targetPath)
                            ? "star.slash" : "star")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary.opacity(0.5))
                }
            }

            if viewModel.favorites.isEmpty {
                Text(L10n.t("noFavorites"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            } else {
                ForEach(viewModel.favorites) { fav in
                    favoriteRow(fav)
                }
            }
        }
    }

    func favoriteRow(_ fav: FavoriteFolder) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "folder")
                .font(.system(size: 12))
                .foregroundColor(.accentColor)
            Text(fav.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            if viewModel.targetPath == fav.path {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(viewModel.targetPath == fav.path
                    ? Color.accentColor.opacity(0.12)
                    : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture { viewModel.setTarget(fav.path) }
    }

    // MARK: - Recent

    var recentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(L10n.t("recent"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            if viewModel.recentPaths.isEmpty {
                Text(L10n.t("noRecent"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            } else {
                ForEach(viewModel.recentPaths, id: \.self) { path in
                    recentRow(path)
                }
            }
        }
    }

    func recentRow(_ path: String) -> some View {
        let name = URL(fileURLWithPath: path).lastPathComponent
        return HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(name)
                .font(.system(size: 12))
                .lineLimit(1)
            Spacer()
            if viewModel.targetPath == path {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onTapGesture { viewModel.setTarget(path) }
    }

    // MARK: - Start Button

    var startButtonArea: some View {
        HStack {
            Spacer()
            Button(action: { viewModel.startMove() }) {
                Label(L10n.t("startMoving"), systemImage: "arrow.right")
                    .font(.system(size: 13, weight: .medium))
                    .frame(minWidth: 80)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.files.isEmpty || viewModel.targetPath.isEmpty || viewModel.isMoving)
        }
    }

    // MARK: - Actions

    func browseTarget() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = L10n.t("selectTargetFolder")
        panel.begin { response in
            if response == .OK, let url = panel.url {
                viewModel.setTarget(url.path)
            }
        }
    }

    func resolveTarget(from providers: [NSItemProvider]) {
        guard let first = providers.first else { return }
        _ = first.loadObject(ofClass: URL.self) { url, _ in
            guard let url = url else { return }
            let path = url.path
            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            let targetPath = (exists && isDir.boolValue) ? path : url.deletingLastPathComponent().path
            Task { @MainActor in viewModel.setTarget(targetPath) }
        }
    }
}
