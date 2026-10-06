import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class TagsService {
    private let api: RadioBrowserAPI
    private let dataStore: any FacetWriting

    init(api: RadioBrowserAPI, dataStore: any FacetWriting) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveTags() async throws {
        let tags = try await api.tags.getResources()
        let entities = tags.map { TagAdapter(from: $0) }
        try await dataStore.saveTags(entities)
    }

    func fetchAndSaveTags(filter: String) async throws {
        let tags = try await api.tags.getResources(withFilter: filter)
        let entities = tags.map { TagAdapter(from: $0) }
        try await dataStore.saveTags(entities)
    }
}
