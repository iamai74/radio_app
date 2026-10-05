import Foundation
import Combine

@MainActor
final class LanguageStorageImpl: FacetStorageImpl<LanguageEntityImpl>, LanguageStorage {
    var languagesPublisher: AnyPublisher<[any LanguageEntity], Never> {
        publisher.map { $0 as [any LanguageEntity] }.eraseToAnyPublisher()
    }

    func filteredPublisher(filter: LanguageFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any LanguageEntity] }
            .eraseToAnyPublisher()
    }
}
