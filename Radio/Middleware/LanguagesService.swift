import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class LanguagesService {
    private let api: RadioBrowserAPI
    private let dataStore: any FacetWriting

    init(api: RadioBrowserAPI, dataStore: any FacetWriting) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveLanguages() async throws {
        let languages = try await api.languages.getResources()
        let entities = languages.map { LanguageAdapter(from: $0) }
        try await dataStore.saveLanguages(entities)
    }

    func fetchAndSaveLanguages(filter: String) async throws {
        let languages = try await api.languages.getResources(withFilter: filter)
        let entities = languages.map { LanguageAdapter(from: $0) }
        try await dataStore.saveLanguages(entities)
    }
}
