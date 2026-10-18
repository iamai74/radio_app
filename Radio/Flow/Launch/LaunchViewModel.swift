import Combine
import Architecture
import Foundation

@MainActor
final class LaunchViewModel: ViewModelProtocol {
    enum Input {}

    enum Output {
        case navigateToMain
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .first()
            .map { _ in Output.navigateToMain }
            .eraseToAnyPublisher()
    }
}
