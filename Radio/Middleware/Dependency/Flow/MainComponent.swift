import NeedleFoundation
import Architecture

final class MainComponent: Component<EmptyDependency> {
    private let navigator: NavigatorProtocol
    private let stationsService: StationsService

    init(parent: Scope, navigator: NavigatorProtocol, stationsService: StationsService) {
        self.navigator = navigator
        self.stationsService = stationsService
        super.init(parent: parent)
    }

    @MainActor
    var coordinator: MainCoordinator {
        MainCoordinator(navigator: navigator, service: stationsService)
    }
}
