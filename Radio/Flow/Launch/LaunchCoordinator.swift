import Architecture
import Foundation
import Combine

@MainActor
final class LaunchCoordinator: CoordinatorProtocol {
    var navigator: NavigatorProtocol

    private var cancellables: Set<AnyCancellable> = []

    init(navigator: NavigatorProtocol) {
        self.navigator = navigator
    }

    func start() {
        let viewModel = LaunchViewModel()

        viewModel
            .transform(input: Empty<LaunchViewModel.Input, Never>().eraseToAnyPublisher())
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .navigateToMain:
                    MainCoordinator(navigator: self.navigator).start()
                }
            }
            .store(in: &cancellables)

        navigator.setRoot(view: LaunchView(viewModel: viewModel))
    }
}
