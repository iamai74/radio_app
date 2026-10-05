import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class LanguagesService {
    private let api: RadioBrowserAPI
    private let dataStore: DataStore

    init(api: RadioBrowserAPI, dataStore: DataStore) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveLanguages() async throws {
        let languages = try await api.languages.getLanguages()
        let entities = languages.map { LanguageAdapter(from: $0) }
        try await dataStore.saveLanguages(entities)
    }

    func fetchAndSaveLanguages(filter: String) async throws {
        let languages = try await api.languages.getLanguages(withFilter: filter)
        let entities = languages.map { LanguageAdapter(from: $0) }
        try await dataStore.saveLanguages(entities)
    }
}
