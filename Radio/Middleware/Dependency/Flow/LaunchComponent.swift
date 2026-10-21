import NeedleFoundation
import Architecture

final class LaunchComponent: Component<EmptyDependency> {
    private let navigator: NavigatorProtocol
    private let mainCoordinator: MainCoordinator

    init(parent: Scope, navigator: NavigatorProtocol, mainCoordinator: MainCoordinator) {
        self.navigator = navigator
        self.mainCoordinator = mainCoordinator
        super.init(parent: parent)
    }

    @MainActor
    var coordinator: LaunchCoordinator {
        LaunchCoordinator(navigator: navigator, mainCoordinator: mainCoordinator)
    }
}
