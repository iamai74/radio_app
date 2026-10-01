import Foundation
import Architecture
import NeedleFoundation

public protocol BaseDependencyProvider: NeedleFoundation.DependencyProvider {
    associatedtype Component: NeedleFoundation.Component
    var component: Component { get }
}

public protocol BaseCoordinator<Component>: Coordinator {
    associatedtype Component: NeedleFoundation.Component
    var component: Component { get }
}
