import Testing
import SwiftData
@testable import Storage

@MainActor
@Test
func canCreateInMemoryDataStore() async throws {
    let container = try StorageContainer.create(isInMemory: true)
    let store = Storage.DataStore(modelContainer: container)
    _ = store
}

/// Previews and tests need stores that cannot see each other's rows.
@MainActor
@Test
func inMemoryStoresAreIsolatedFromEachOther() async throws {
    let first = Storage.DataStore(modelContainer: try StorageContainer.create(isInMemory: true))
    let second = Storage.DataStore(modelContainer: try StorageContainer.create(isInMemory: true))

    try await first.saveTags([TagDTO.fixture(name: "only-in-first")])

    #expect(try first.rowCount(TagEntityImpl.self) == 1)
    #expect(try second.rowCount(TagEntityImpl.self) == 0)
}

/// The default configuration is the on-disk one; nothing in the package should
/// silently switch production to in-memory.
@Test
func defaultContainerIsPersistent() throws {
    let container = try StorageContainer.create()
    let configuration = try #require(container.configurations.first)
    #expect(configuration.isStoredInMemoryOnly == false)
}
