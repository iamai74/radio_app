import Combine
import Architecture

@MainActor
final class LaunchViewModel: ViewModelProtocol {
    enum Input {}

    enum Output {}

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        Empty().eraseToAnyPublisher()
    }
}
