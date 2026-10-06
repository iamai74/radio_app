import Foundation
import Combine

public protocol DependencyResolver {
    func resolve<T>(_ type: T.Type) -> T?
}

public protocol DependencyProvider: AnyObject {
    associatedtype Resolver: DependencyResolver
    var resolver: Resolver { get }
}

public protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}

public protocol ViewProtocol: AnyObject {
    associatedtype ViewModelType: ViewModelProtocol
    var viewModel: ViewModelType { get set }
}

public protocol NavigatorProtocol: AnyObject {
    func push<V: ViewProtocol>(view: V)
    func present<V: ViewProtocol>(view: V)
    func pop()
}

public protocol CoordinatorProtocol: AnyObject {
    var navigator: NavigatorProtocol { get set }
    func start()
}
