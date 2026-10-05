import Foundation
import Combine

@MainActor
final class CodecStorageImpl: FacetStorageImpl<CodecEntityImpl>, CodecStorage {
    var codecsPublisher: AnyPublisher<[any CodecEntity], Never> {
        publisher.map { $0 as [any CodecEntity] }.eraseToAnyPublisher()
    }

    func filteredPublisher(filter: CodecFilter) -> AnyPublisher<[any CodecEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any CodecEntity] }
            .eraseToAnyPublisher()
    }
}
