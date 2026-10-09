import Foundation
import SwiftData

@ModelActor
actor BackgroundStore {
    func saveStations(_ stations: [StationEntity]) async throws {
        let dtos = stations.map { StationEntityImpl.persist($0) }
        for dto in dtos {
            modelContext.insert(dto)
        }
        try modelContext.save()
    }

    func deleteAllStations() async throws {
        try modelContext.delete(model: StationEntityImpl.self)
        try modelContext.save()
    }

    func saveCountries(_ countries: [CountryEntity]) async throws {
        let dtos = countries.map { CountryEntityImpl.persist($0) }
        for dto in dtos {
            modelContext.insert(dto)
        }
        try modelContext.save()
    }

    func deleteAllCountries() async throws {
        try modelContext.delete(model: CountryEntityImpl.self)
        try modelContext.save()
    }

    func saveTags(_ tags: [TagEntity]) async throws {
        let dtos = tags.map { TagEntityImpl.persist($0) }
        for dto in dtos {
            modelContext.insert(dto)
        }
        try modelContext.save()
    }

    func deleteAllTags() async throws {
        try modelContext.delete(model: TagEntityImpl.self)
        try modelContext.save()
    }

    func saveLanguages(_ languages: [LanguageEntity]) async throws {
        let dtos = languages.map { LanguageEntityImpl.persist($0) }
        for dto in dtos {
            modelContext.insert(dto)
        }
        try modelContext.save()
    }

    func deleteAllLanguages() async throws {
        try modelContext.delete(model: LanguageEntityImpl.self)
        try modelContext.save()
    }

    func saveCodecs(_ codecs: [CodecEntity]) async throws {
        let dtos = codecs.map { CodecEntityImpl.persist($0) }
        for dto in dtos {
            modelContext.insert(dto)
        }
        try modelContext.save()
    }

    func deleteAllCodecs() async throws {
        try modelContext.delete(model: CodecEntityImpl.self)
        try modelContext.save()
    }

    func bulkImportStations(_ stations: [StationEntity], batchSize: Int = 500) async throws {
        let dtos = stations.map { StationEntityImpl.persist($0) }
        for (index, dto) in dtos.enumerated() {
            modelContext.insert(dto)
            if index % batchSize == 0 && index > 0 {
                try modelContext.save()
            }
        }
        try modelContext.save()
    }

    func fetchStationCount() async throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<StationEntityImpl>())
    }

    func fetchCountryCount() async throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<CountryEntityImpl>())
    }

    func fetchTagCount() async throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<TagEntityImpl>())
    }

    func fetchLanguageCount() async throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<LanguageEntityImpl>())
    }

    func fetchCodecCount() async throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<CodecEntityImpl>())
    }
}
