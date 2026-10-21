import Architecture
import Foundation

@MainActor
final class MainCoordinator: CoordinatorProtocol {
    var navigator: NavigatorProtocol

    private let service: StationsService

    init(navigator: NavigatorProtocol, service: StationsService) {
        self.navigator = navigator
        self.service = service
    }

    func start() {
        navigator.setRoot(view: MainView(viewModel: MainViewModel(service: service)))
    }
}
