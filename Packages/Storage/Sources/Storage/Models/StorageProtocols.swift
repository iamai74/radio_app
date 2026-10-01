import Foundation
import SwiftData
import Combine

@MainActor
public protocol StorageProtocol: AnyObject {
    associatedtype Entity: PersistentModel & Hashable
    
    var publisher: AnyPublisher<[Entity], Never> { get }
    
    func save(_ entities: [Entity]) throws
    func deleteAll() throws
}

@MainActor
protocol StationStorage: StorageProtocol where Entity == StationEntityImpl {
    var stationsPublisher: AnyPublisher<[any StationEntity], Never> { get }
    func filteredPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never>
}

@MainActor
protocol CountryStorage: StorageProtocol where Entity == CountryEntityImpl {
    var countriesPublisher: AnyPublisher<[any CountryEntity], Never> { get }
    func filteredPublisher(filter: CountryFilter) -> AnyPublisher<[any CountryEntity], Never>
}

@MainActor
protocol TagStorage: StorageProtocol where Entity == TagEntityImpl {
    var tagsPublisher: AnyPublisher<[any TagEntity], Never> { get }
    func filteredPublisher(filter: TagFilter) -> AnyPublisher<[any TagEntity], Never>
}

@MainActor
protocol LanguageStorage: StorageProtocol where Entity == LanguageEntityImpl {
    var languagesPublisher: AnyPublisher<[any LanguageEntity], Never> { get }
    func filteredPublisher(filter: LanguageFilter) -> AnyPublisher<[any LanguageEntity], Never>
}

@MainActor
protocol CodecStorage: StorageProtocol where Entity == CodecEntityImpl {
    var codecsPublisher: AnyPublisher<[any CodecEntity], Never> { get }
    func filteredPublisher(filter: CodecFilter) -> AnyPublisher<[any CodecEntity], Never>
}
