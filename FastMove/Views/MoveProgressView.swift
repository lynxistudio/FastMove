import SwiftUI

struct MoveProgressView: View {
    @ObservedObject var viewModel: MoverViewModel

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: max(viewModel.moveProgress, 0.005))
                .progressViewStyle(.linear)
                .tint(.accentColor)

            HStack {
                Text(viewModel.currentMovingFile)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Text(String(format: "%.0f%%", viewModel.moveProgress * 100))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 8)
    }
}
