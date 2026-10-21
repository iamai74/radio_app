import Combine
import Architecture
import UILibrary

@MainActor
final class MainViewModel: ViewModelProtocol, ObservableObject {
    enum Input {
        case selectStation(any UILibrary.Station)
    }

    enum Output {
        case none
    }

    private let service: StationsService
    private var cancellables: Set<AnyCancellable> = []

    @Published var stations: [any UILibrary.Station] = []
    @Published var selectedStation: (any UILibrary.Station)?
    @Published var isLoading: Bool = true

    init(service: StationsService) {
        self.service = service
        subscribeToStations()
        Task { [weak self] in
            await self?.loadStations()
        }
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .map { input -> Output in
                switch input {
                case .selectStation(let station):
                    self.selectedStation = station
                    return Output.none
                }
            }
            .eraseToAnyPublisher()
    }

    private func subscribeToStations() {
        service.stationsPublisher()
            .sink { [weak self] stations in
                self?.stations = stations
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    private func loadStations() async {
        do {
            try await service.fetchAndSaveStations(limit: 100, offset: 0)
        } catch {
            isLoading = false
        }
    }
}
