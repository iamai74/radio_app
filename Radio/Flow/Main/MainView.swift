import SwiftUI
import Architecture
import Resources
import UILibrary

struct MainView: ViewProtocol {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private static let wideLayoutMinimumWidth: CGFloat = 600
    private static let playerColumnRatio: CGFloat = 0.42
    private static let playerColumnMinimumWidth: CGFloat = 280
    private static let playerColumnMaximumWidth: CGFloat = 400

    var body: some View {
        GeometryReader { proxy in
            layout(for: proxy.size)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func layout(for size: CGSize) -> some View {
        if isWideLayout(size: size) {
            sideBySideLayout(for: size)
        } else {
            stackedLayout
        }
    }

    private var stackedLayout: some View {
        VStack(spacing: 0) {
            playerView(layout: .horizontal)

            stationsList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sideBySideLayout(for size: CGSize) -> some View {
        HStack(spacing: 0) {
            if viewModel.selectedStation != nil {
                playerView(layout: .vertical)
                    .frame(width: playerColumnWidth(for: size))
            }
            stationsList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func isWideLayout(size: CGSize) -> Bool {
        horizontalSizeClass == .regular || size.width >= Self.wideLayoutMinimumWidth
    }

    private func playerColumnWidth(for size: CGSize) -> CGFloat {
        let width = size.width * Self.playerColumnRatio
        return min(max(width, Self.playerColumnMinimumWidth), Self.playerColumnMaximumWidth)
    }

    @ViewBuilder
    private func playerView(layout: PlayerLayout) -> some View {
        if let station = viewModel.selectedStation {
            PlayerView(
                station: station,
                isPlaying: false,
                layout: layout
            )
            .padding(.horizontal)
            .padding(.top)
        }
    }

    private var stationsList: some View {
        StationsListView(
            stations: viewModel.stations,
            onStationSelected: { [weak viewModel] station in
                viewModel?.selectedStation = station
            }
        )
    }
}

#if DEBUG
#Preview {
    MainView(viewModel: .preview)
}
#endif
