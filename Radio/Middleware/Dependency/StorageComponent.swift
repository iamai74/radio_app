import Foundation
import NeedleFoundation
import Storage

/// Dependency contract for the Storage container.
/// Satisfied by the ancestor component that owns the persistence layer.
protocol StorageDependency: Dependency {
    var dataStore: Storage.DataStore { get }
}

/// Container for the Storage package.
/// Exposes the storage layer to the scope subtree rooted at the app component.
final class StorageComponent: Component<StorageDependency> {

    var dataStore: Storage.DataStore {
        dependency.dataStore
    }
}
