import Foundation
import Combine
import SwiftUI

public protocol DependencyResolver {
    func resolve<T>(_ type: T.Type) -> T?
}

public protocol DependencyProvider: AnyObject {
    associatedtype Resolver: DependencyResolver
    var resolver: Resolver { get }
}

@MainActor
public protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}

@MainActor
public protocol ViewProtocol: View {
    associatedtype ViewModelType: ViewModelProtocol
    var viewModel: ViewModelType { get }
}

@MainActor
public protocol NavigatorProtocol: AnyObject {
    func setRoot<V: ViewProtocol>(view: V)
    func push<V: ViewProtocol>(view: V)
    func present<V: ViewProtocol>(view: V)
    func pop()
}

@MainActor
public protocol CoordinatorProtocol: AnyObject {
    var navigator: NavigatorProtocol { get set }
    func start()
}
