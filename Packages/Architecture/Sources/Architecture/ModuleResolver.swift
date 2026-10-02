import Foundation
import Architecture
import NeedleFoundation

public class ModuleResolver<C: NeedleFoundation.Component> {
    private let component: C

    public init(component: C) {
        self.component = component
    }

    public func resolve<M: Module>() -> M.CoordinatorType? where M.Component == C {
        guard let module = component.resolve(M.self) as? M else {
            return nil
        }
        return module.makeCoordinator(component: component)
    }
}
