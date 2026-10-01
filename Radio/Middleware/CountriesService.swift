import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class CountriesService {
    private let api: RadioBrowserAPI
    private let dataStore: DataStore

    init(api: RadioBrowserAPI, dataStore: DataStore) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveCountries() async throws {
        let countries = try await api.countries.getCountries()
        let entities = countries.map { CountryAdapter(from: $0) }
        try dataStore.saveCountries(entities)
    }

    func fetchAndSaveCountries(filter: String) async throws {
        let countries = try await api.countries.getCountries(withFilter: filter)
        let entities = countries.map { CountryAdapter(from: $0) }
        try dataStore.saveCountries(entities)
    }
}
