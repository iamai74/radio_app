import Foundation
import Combine

@MainActor
final class CountryStorageImpl: FacetStorageImpl<CountryEntityImpl>, CountryStorage {
    var countriesPublisher: AnyPublisher<[any CountryEntity], Never> {
        publisher.map { $0 as [any CountryEntity] }.eraseToAnyPublisher()
    }

    func filteredPublisher(filter: CountryFilter) -> AnyPublisher<[any CountryEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any CountryEntity] }
            .eraseToAnyPublisher()
    }
}
