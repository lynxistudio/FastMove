import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MoverViewModel()

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left: Source Panel
                SourcePanel(viewModel: viewModel)
                    .frame(width: max(280, geometry.size.width * 0.38))

                Divider()

                // Right: Target + Progress + Log
                VStack(spacing: 0) {
                    TargetPanel(viewModel: viewModel)
                        .frame(height: 90)

                    Divider()

                    ProgressPanel(viewModel: viewModel)
                        .frame(height: 130)

                    Divider()

                    LogView(viewModel: viewModel)
                }
                .frame(width: max(400, geometry.size.width * 0.62))
            }
        }
        .frame(minWidth: 800, minHeight: 550)
    }
}