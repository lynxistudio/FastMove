import SwiftUI

struct ProgressPanel: View {
    @ObservedObject var viewModel: MoverViewModel

    private var service: RsyncService { viewModel.rsyncService }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Stats
            statsView

            // Action button
            actionButton
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Label("Progress", systemImage: "arrow.triangle.swap")
                .font(.headline)
            Spacer()
            statusBadge
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var statusBadge: some View {
        Group {
            switch service.status {
            case .idle:
                Text("Ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .running:
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 12, height: 12)
                    Text("Moving...")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            case .completed:
                Text("Done")
                    .font(.caption)
                    .foregroundColor(.green)
            case .failed(let msg):
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.red)
            case .cancelled:
                Text("Cancelled")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }

    // MARK: - Stats

    private var statsView: some View {
        HStack(spacing: 24) {
            StatItem(
                label: "Completed",
                value: "\(service.completedCount)",
                color: .green
            )
            StatItem(
                label: "Failed",
                value: "\(service.failedCount)",
                color: service.failedCount > 0 ? .red : .secondary
            )
            StatItem(
                label: "Pending",
                value: "\(max(0, viewModel.totalSourceCount - service.completedCount - service.failedCount))",
                color: .secondary
            )

            Spacer()

            if service.status == .running, !service.currentFile.isEmpty {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Current:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(service.currentFile)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 180, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        HStack {
            if service.status == .running {
                Button {
                    viewModel.cancelMoving()
                } label: {
                    Label("Cancel", systemImage: "stop.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
            } else {
                Button {
                    viewModel.startMoving()
                } label: {
                    Label("Start Moving", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.canStart)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}