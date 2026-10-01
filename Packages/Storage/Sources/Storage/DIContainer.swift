import Foundation
import SwiftData

@MainActor
public final class DIContainer {
    public static let shared = DIContainer()
    
    private var _modelContainer: ModelContainer?
    private var _dataStore: DataStore?
    
    private init() {}
    
    public func register(modelContainer: ModelContainer) {
        self._modelContainer = modelContainer
        self._dataStore = nil
    }
    
    public var modelContainer: ModelContainer {
        if let container = _modelContainer {
            return container
        }
        let container = try! StorageContainer.create()
        _modelContainer = container
        return container
    }
    
    public var dataStore: DataStore {
        if let store = _dataStore {
            return store
        }
        let store = DataStore(di: self)
        _dataStore = store
        return store
    }
}
