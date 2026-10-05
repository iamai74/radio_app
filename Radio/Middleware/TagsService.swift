import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class TagsService {
    private let api: RadioBrowserAPI
    private let dataStore: DataStore

    init(api: RadioBrowserAPI, dataStore: DataStore) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveTags() async throws {
        let tags = try await api.tags.getTags()
        let entities = tags.map { TagAdapter(from: $0) }
        try await dataStore.saveTags(entities)
    }

    func fetchAndSaveTags(filter: String) async throws {
        let tags = try await api.tags.getTags(withFilter: filter)
        let entities = tags.map { TagAdapter(from: $0) }
        try await dataStore.saveTags(entities)
    }
}
