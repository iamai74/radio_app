import Foundation
import Combine

@MainActor
final class TagStorageImpl: FacetStorageImpl<TagEntityImpl>, TagStorage {
    var tagsPublisher: AnyPublisher<[any TagEntity], Never> {
        publisher.map { $0 as [any TagEntity] }.eraseToAnyPublisher()
    }

    func filteredPublisher(filter: TagFilter) -> AnyPublisher<[any TagEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any TagEntity] }
            .eraseToAnyPublisher()
    }
}
