import SwiftUI
import Architecture
import Resources
import UILibrary

struct MainView: ViewProtocol {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let station = viewModel.selectedStation {
                PlayerView(
                    station: station,
                    isPlaying: false,
                    layout: .horizontal
                )
                .padding(.horizontal)
                .padding(.top)
            }

            StationsListView(
                stations: viewModel.stations,
                onStationSelected: { [weak viewModel] station in
                    viewModel?.selectedStation = station
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    MainView(viewModel: .preview)
}
#endif
