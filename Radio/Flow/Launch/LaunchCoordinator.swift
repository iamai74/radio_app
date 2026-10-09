import Architecture

@MainActor
final class LaunchCoordinator: CoordinatorProtocol {
    var navigator: NavigatorProtocol

    init(navigator: NavigatorProtocol) {
        self.navigator = navigator
    }

    func start() {
        navigator.setRoot(view: LaunchView(viewModel: LaunchViewModel()))
    }
}
