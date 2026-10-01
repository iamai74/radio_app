import Foundation
import Combine
import NeedleFoundation

public protocol Coordinator: AnyObject {
    func start()
}

public protocol Navigator: AnyObject {
    func push<V: View>(view: V) where V.ViewModelType: ViewModel
    func present<V: View>(view: V) where V.ViewModelType: ViewModel
    func pop()
}

public protocol ViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}

public protocol View: AnyObject {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType { get set }
}

public protocol DependencyContainer: AnyObject {
    associatedtype Component: NeedleFoundation.Component
    var component: Component { get }
}
