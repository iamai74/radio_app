import NeedleFoundation
import Architecture

final class LaunchComponent: Component<EmptyDependency> {
    private let navigator: NavigatorProtocol

    init(parent: Scope, navigator: NavigatorProtocol) {
        self.navigator = navigator
        super.init(parent: parent)
    }

    @MainActor
    var coordinator: LaunchCoordinator {
        LaunchCoordinator(navigator: navigator)
    }
}
