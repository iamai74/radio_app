import Architecture

@MainActor
final class MainCoordinator: CoordinatorProtocol {
    var navigator: NavigatorProtocol

    init(navigator: NavigatorProtocol) {
        self.navigator = navigator
    }

    func start() {
        navigator.setRoot(view: MainView(viewModel: MainViewModel()))
    }
}
