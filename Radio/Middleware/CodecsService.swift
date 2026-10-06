import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class CodecsService {
    private let api: RadioBrowserAPI
    private let dataStore: any FacetWriting

    init(api: RadioBrowserAPI, dataStore: any FacetWriting) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveCodecs() async throws {
        let codecs = try await api.codecs.getResources()
        let entities = codecs.map { CodecAdapter(from: $0) }
        try await dataStore.saveCodecs(entities)
    }
}
