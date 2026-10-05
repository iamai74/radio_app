import Testing
import Foundation
import Combine
@testable import Storage

@MainActor
@Test
func asyncSequenceReplaysCurrentValueToLateSubscribers() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagEntityImpl.fixture(name: "replayed")])

    var iterator = store.tagsSequence(filter: .empty).makeAsyncIterator()
    let first = try await iterator.next()

    #expect(first?.map { $0.name } == ["replayed"])
}

@MainActor
@Test
func asyncSequenceDeliversLaterUpdates() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagEntityImpl.fixture(name: "first")])

    let sequence = store.tagsSequence(filter: .empty)
    let task = Task { () -> [String] in
        var names: [String] = []
        for try await tags in sequence {
            names = tags.map(\.name)
            if names.count == 2 { break }
        }
        return names
    }

    try await store.saveTags([TagEntityImpl.fixture(name: "second", stationCount: 1)])

    #expect(try await task.value == ["first", "second"])
}

@MainActor
@Test
func asyncSequenceReportsFailuresAsStorageError() async throws {
    let values = CurrentValueSubject<[String], Never>(["ok"])
    let failures = PassthroughSubject<StorageError, Never>()
    let sequence = StorageSequence(values: values.eraseToAnyPublisher(),
                                   failures: failures.eraseToAnyPublisher())

    var iterator = sequence.makeAsyncIterator()
    #expect(try await iterator.next() == ["ok"])

    failures.send(.fetchFailed("simulated"))

    do {
        _ = try await iterator.next()
        Issue.record("expected the failure to surface as a thrown StorageError")
    } catch let error as StorageError {
        #expect(error == .fetchFailed("simulated"))
    }
}

@MainActor
@Test
func deletingEverythingClearsPublishedResults() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagEntityImpl.fixture(name: "gone")])

    var iterator = store.tagsSequence(filter: .empty).makeAsyncIterator()
    #expect(try await iterator.next()?.isEmpty == false)

    try await store.deleteAllTags()

    #expect(try await iterator.next()?.isEmpty == true)
}
