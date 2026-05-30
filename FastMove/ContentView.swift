import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MoverViewModel()

    var body: some View {
        ZStack {
            HSplitView {
                SourcePanel(viewModel: viewModel)
                    .frame(minWidth: 280)

                TargetPanel(viewModel: viewModel)
                    .frame(minWidth: 320)
            }

            // Toast overlay
            if viewModel.showToast {
                VStack {
                    Spacer()
                    Text(viewModel.toastMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.8))
                        )
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.25), value: viewModel.showToast)
            }
        }
    }
}
