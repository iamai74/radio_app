import Foundation
import SwiftData
import Storage

@Model
final class CountryEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var iso31661: String
    var stationCount: Int

    init(name: String, iso31661: String, stationCount: Int = 0) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }

    typealias DTO = CountryEntity
    var storageKey: String { name }

    static func persist(_ dto: CountryEntity) -> CountryEntityImpl {
        CountryEntityImpl(name: dto.name, iso31661: dto.iso31661, stationCount: dto.stationCount)
    }

    func apply(from dto: CountryEntity) {
        name = dto.name
        iso31661 = dto.iso31661
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: CountryEntityImpl) {
        name = other.name
        iso31661 = other.iso31661
        stationCount = other.stationCount
    }

    func toDTO() -> CountryEntity {
        CountryDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CountryEntityImpl> {
        #Predicate { country in keys.contains(country.name) }
    }
}

struct CountryDTO: CountryEntity, Equatable {
    let name: String
    let iso31661: String
    let stationCount: Int

    static func from(_ impl: CountryEntityImpl) -> CountryDTO {
        CountryDTO(name: impl.name, iso31661: impl.iso31661, stationCount: impl.stationCount)
    }
}

@Model
final class TagEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }

    typealias DTO = TagEntity
    var storageKey: String { name }

    static func persist(_ dto: TagEntity) -> TagEntityImpl {
        TagEntityImpl(name: dto.name, stationCount: dto.stationCount)
    }

    func apply(from dto: TagEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: TagEntityImpl) {
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> TagEntity {
        TagDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<TagEntityImpl> {
        #Predicate { tag in keys.contains(tag.name) }
    }
}

struct TagDTO: TagEntity, Equatable {
    let name: String
    let stationCount: Int

    static func from(_ impl: TagEntityImpl) -> TagDTO {
        TagDTO(name: impl.name, stationCount: impl.stationCount)
    }
}

@Model
final class LanguageEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }

    typealias DTO = LanguageEntity
    var storageKey: String { name }

    static func persist(_ dto: LanguageEntity) -> LanguageEntityImpl {
        LanguageEntityImpl(name: dto.name, stationCount: dto.stationCount)
    }

    func apply(from dto: LanguageEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: LanguageEntityImpl) {
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> LanguageEntity {
        LanguageDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<LanguageEntityImpl> {
        #Predicate { language in keys.contains(language.name) }
    }
}

struct LanguageDTO: LanguageEntity, Equatable {
    let name: String
    let stationCount: Int

    static func from(_ impl: LanguageEntityImpl) -> LanguageDTO {
        LanguageDTO(name: impl.name, stationCount: impl.stationCount)
    }
}

@Model
final class CodecEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }

    typealias DTO = CodecEntity
    var storageKey: String { name }

    static func persist(_ dto: CodecEntity) -> CodecEntityImpl {
        CodecEntityImpl(name: dto.name, stationCount: dto.stationCount)
    }

    func apply(from dto: CodecEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: CodecEntityImpl) {
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> CodecEntity {
        CodecDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CodecEntityImpl> {
        #Predicate { codec in keys.contains(codec.name) }
    }
}

struct CodecDTO: CodecEntity, Equatable {
    let name: String
    let stationCount: Int

    static func from(_ impl: CodecEntityImpl) -> CodecDTO {
        CodecDTO(name: impl.name, stationCount: impl.stationCount)
    }
}
