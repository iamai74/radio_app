import Foundation
import Architecture
import NeedleFoundation

public protocol ModuleFactory: AnyObject {
    associatedtype Component: NeedleFoundation.Component
    func makeCoordinator<M: Module>(for moduleType: M.Type, component: Component) -> M.CoordinatorType where M.Component == Component
}

public class NeedleModuleFactory<C: NeedleFoundation.Component>: ModuleFactory {
    public typealias Component = C
    
    public init() {}
    
    public func makeCoordinator<M: Module>(for moduleType: M.Type, component: C) -> M.CoordinatorType where M.Component == C {
        // This implementation assumes the Module is also resolvable via Needle.
        // We use Needle's resolve method to find the module and then call its makeCoordinator.
        guard let module = component.resolve(M.self) as? M else {
            fatalError("Module \(M.self) not found in Component")
        }
        return module.makeCoordinator(component: component)
    }
}
