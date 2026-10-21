import Architecture
import Foundation
import Combine

@MainActor
final class LaunchCoordinator: CoordinatorProtocol {
    var navigator: NavigatorProtocol

    private var cancellables: Set<AnyCancellable> = []
    private let mainCoordinator: MainCoordinator

    init(navigator: NavigatorProtocol, mainCoordinator: MainCoordinator) {
        self.navigator = navigator
        self.mainCoordinator = mainCoordinator
    }

    func start() {
        let viewModel = LaunchViewModel()

        viewModel
            .transform(input: Empty<LaunchViewModel.Input, Never>().eraseToAnyPublisher())
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .navigateToMain:
                    self.mainCoordinator.start()
                }
            }
            .store(in: &cancellables)

        navigator.setRoot(view: LaunchView(viewModel: viewModel))
    }
}
