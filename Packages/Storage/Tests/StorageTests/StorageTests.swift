import Testing
import SwiftData
@testable import Storage

@MainActor
@Test
func canCreateInMemoryDataStore() async throws {
    let container = try StorageContainer.create(isInMemory: true)
    let di = DIContainer.shared
    di.register(modelContainer: container)
    let store = di.dataStore
    _ = store
}
