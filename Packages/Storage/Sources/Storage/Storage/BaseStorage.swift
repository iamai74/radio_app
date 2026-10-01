import Foundation
import SwiftData
import Combine

@MainActor
class BaseStorage<Entity: PersistentModel & Hashable, Filter: Hashable>: AnyObject {
    let modelContext: ModelContext
    let subject: CurrentValueSubject<[Entity], Never>
    let filteredSubjects: CurrentValueSubject<[Filter: [Entity]], Never>
    private let sortKeyPath: KeyPath<Entity, String>

    var publisher: AnyPublisher<[Entity], Never> {
        subject.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, sortKeyPath: KeyPath<Entity, String>, initial: [Entity] = []) {
        self.modelContext = modelContext
        self.subject = CurrentValueSubject(initial)
        self.filteredSubjects = CurrentValueSubject([:])
        self.sortKeyPath = sortKeyPath
    }

    func save(_ entities: [Entity]) throws {
        for entity in entities {
            modelContext.insert(entity)
        }
        try modelContext.save()
        reload()
    }

    func applyFilter(_ filter: Filter, to results: inout [Entity]) throws {}

    func filteredPublisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        filteredSubjects
            .map { $0[filter] ?? [] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func reload() {
        let descriptor = FetchDescriptor<Entity>(sortBy: [SortDescriptor(sortKeyPath)])
        
        if let results = try? modelContext.fetch(descriptor) {
            subject.send(results)
        }
        
        if let allResults = try? modelContext.fetch(FetchDescriptor<Entity>()) {
            var current = filteredSubjects.value
            for filter in current.keys {
                var filtered = allResults
                try? applyFilter(filter, to: &filtered)
                current[filter] = filtered
            }
            filteredSubjects.send(current)
        }
    }

    func deleteAll() throws {
        try modelContext.delete(model: Entity.self)
        try modelContext.save()
        subject.send([])
        filteredSubjects.send([:])
    }
}
