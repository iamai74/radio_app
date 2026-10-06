import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class CountriesService {
    private let api: RadioBrowserAPI
    private let dataStore: any FacetWriting

    init(api: RadioBrowserAPI, dataStore: any FacetWriting) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveCountries() async throws {
        let countries = try await api.countries.getResources()
        let entities = countries.map { CountryRecord(from: $0) }
        try await dataStore.saveCountries(entities)
    }

    func fetchAndSaveCountries(filter: String) async throws {
        let countries = try await api.countries.getResources(withFilter: filter)
        let entities = countries.map { CountryRecord(from: $0) }
        try await dataStore.saveCountries(entities)
    }
}
