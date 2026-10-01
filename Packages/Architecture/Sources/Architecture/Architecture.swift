import Foundation
import Combine
import NeedleFoundation

/// Protocol for a ViewModel in MVVM
public protocol ViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}

/// Protocol for a View in MVVM
public protocol View: AnyObject {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType { get set }
}

/// Protocol for a Coordinator in MVVM+C
public protocol Coordinator: AnyObject {
    var navigationController: Any { get } // Will be cast to platform-specific navigator
    func start()
}

/// Protocol for a Navigator to abstract platform-specific navigation
public protocol Navigator: AnyObject {
    func push<V: View>(view: V) where V.ViewModelType: ViewModel
    func present<V: View>(view: V) where V.ViewModelType: ViewModel
    func pop()
}

/// Protocol for a DI Container using Needle
public protocol DependencyContainer: AnyObject {
    associatedtype Component: NeedleFoundation.Component
    var component: Component { get }
}
