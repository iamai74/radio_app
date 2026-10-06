import Testing
import Foundation
import Combine
@testable import Storage

@MainActor
@Test
func asyncSequenceReplaysCurrentValueToLateSubscribers() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagDTO.fixture(name: "replayed")])

    var iterator = store.tagsSequence(filter: .empty).makeAsyncIterator()
    let first = try await iterator.next()

    #expect(first?.map { $0.name } == ["replayed"])
}

@MainActor
@Test
func asyncSequenceDeliversLaterUpdates() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagDTO.fixture(name: "first")])

    let sequence = store.tagsSequence(filter: .empty)
    let task = Task { () -> [String] in
        var names: [String] = []
        for try await tags in sequence {
            names = tags.map(\.name)
            if names.count == 2 { break }
        }
        return names
    }

    try await store.saveTags([TagDTO.fixture(name: "second", stationCount: 1)])

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

    failures.send(.fetchFailed(details: "simulated"))

    do {
        _ = try await iterator.next()
        Issue.record("expected the failure to surface as a thrown StorageError")
    } catch let error as StorageError {
        #expect(error == .fetchFailed(details: "simulated"))
    }
}

@MainActor
@Test
func deletingEverythingClearsPublishedResults() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagDTO.fixture(name: "gone")])

    var iterator = store.tagsSequence(filter: .empty).makeAsyncIterator()
    #expect(try await iterator.next()?.isEmpty == false)

    try await store.deleteAllTags()

    #expect(try await iterator.next()?.isEmpty == true)
}

// MARK: - Cancellation semantics

/// Cancelling while waiting for the next update must end the iteration
/// cleanly — no hang, no crash — because `StorageSequence.State` cancels its
/// Combine subscriptions and `AsyncStream` ends iteration for a cancelled
/// consuming task.
@MainActor
@Test
func cancellingAnInFlightSequenceReturnsCleanly() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagDTO.fixture(name: "a")])

    let task = Task { () -> Bool in
        var iterator = store.tagsSequence(filter: .empty).makeAsyncIterator()
        _ = try await iterator.next()
        _ = try await iterator.next()
        return true
    }

    await Task.yield()
    task.cancel()

    #expect(try await task.value)
}

/// Rapid cancel-during-iteration churn must not deadlock or trip the weak
/// registry; every dropped iterator releases its cache.
@MainActor
@Test
func rapidCancellationCyclesDoNotLeakFilterCaches() async throws {
    let store = try Storage.DataStore.makeInMemoryStore()
    try await store.saveTags([TagDTO.fixture(name: "a")])

    for _ in 0..<25 {
        let task = Task { () -> Void in
            var iterator = store.tagsSequence(filter: .empty).makeAsyncIterator()
            _ = try await iterator.next()
            _ = try await iterator.next()
        }
        await Task.yield()
        task.cancel()
        try await task.value
    }

    #expect(store.cachedFilterCount == 0)
}
