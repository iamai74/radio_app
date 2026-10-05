import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class CodecsService {
    private let api: RadioBrowserAPI
    private let dataStore: DataStore

    init(api: RadioBrowserAPI, dataStore: DataStore) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveCodecs() async throws {
        let codecs = try await api.codecs.getAudioCodecs()
        let entities = codecs.map { CodecAdapter(from: $0) }
        try await dataStore.saveCodecs(entities)
    }
}
