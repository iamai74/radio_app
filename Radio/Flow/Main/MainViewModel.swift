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

    private let service: StationsService?
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

    static var preview: MainViewModel {
        let instance = MainViewModel.previewInit()
        instance.stations = MockStations.all
        instance.selectedStation = MockStations.jazzRadio
        instance.isLoading = false
        return instance
    }

    private static func previewInit() -> MainViewModel {
        MainViewModel()
    }

    private init() {
        self.service = nil
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
        guard let service = service else { return }
        service.stationsPublisher()
            .sink { [weak self] stations in
                self?.stations = stations
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    private func loadStations() async {
        guard let service = service else { return }
        do {
            try await service.fetchAndSaveStations(limit: 100, offset: 0)
        } catch {
            isLoading = false
        }
    }
}
