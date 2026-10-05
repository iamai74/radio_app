import Foundation
import Combine

/// Async view over a storage publisher.
///
/// Replays the current value to every new consumer and then delivers live
/// updates, so a task that starts late still sees current state without an
/// extra fetch. Failures arrive as `StorageError` instead of being logged and
/// dropped.
///
/// `Combine` remains available for callers that want it, but it is the adapter
/// here, not the other way round: both views are fed by the same reload path,
/// so they cannot disagree.
public struct StorageSequence<Entity>: AsyncSequence {
    public typealias Element = [Entity]
    public typealias Failure = StorageError

    private let values: AnyPublisher<[Entity], Never>
    private let failures: AnyPublisher<StorageError, Never>

    init(values: AnyPublisher<[Entity], Never>, failures: AnyPublisher<StorageError, Never>) {
        self.values = values
        self.failures = failures
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(state: State(values: values, failures: failures))
    }

    /// Element-wise transform, used to lift a concrete entity type to the public
    /// DTO existential that `DataStore` hands out.
    public func map<Other>(_ transform: @escaping ([Entity]) -> [Other]) -> StorageSequence<Other> {
        StorageSequence<Other>(
            values: values.map(transform).eraseToAnyPublisher(),
            failures: failures
        )
    }

    public struct Iterator: AsyncIteratorProtocol {
        public typealias Failure = StorageError

        private let state: State

        fileprivate init(state: State) {
            self.state = state
        }

        public mutating func next() async throws -> [Entity]? {
            let event = await withTaskCancellationHandler {
                await state.next()
            } onCancel: {
                state.cancel()
            }

            switch event {
            case .none:
                state.cancel()
                return nil
            case let .success(value):
                return value
            case let .failure(error):
                throw error
            }
        }
    }

    /// Owns one iterator's Combine subscriptions and its element buffer.
    ///
    /// A class because the task cancellation handler cannot reach the
    /// iterator's own storage. Elements arrive on the main actor, the same
    /// isolation the publisher delivers on, so the buffer needs no lock; it is
    /// marked `@unchecked Sendable` only so the cancellation handler can call
    /// `cancel()`.
    fileprivate final class State: @unchecked Sendable {
        private var iterator: AsyncStream<Result<[Entity], StorageError>>.AsyncIterator
        private var cancellables = Set<AnyCancellable>()

        init(values: AnyPublisher<[Entity], Never>, failures: AnyPublisher<StorageError, Never>) {
            let (stream, continuation) = AsyncStream<Result<[Entity], StorageError>>.makeStream()
            values.sink { continuation.yield(.success($0)) }.store(in: &cancellables)
            failures.sink { continuation.yield(.failure($0)) }.store(in: &cancellables)
            self.iterator = stream.makeAsyncIterator()
        }

        func next() async -> Result<[Entity], StorageError>? {
            await iterator.next()
        }

        func cancel() {
            cancellables.removeAll()
        }

        deinit {
            cancel()
        }
    }
}
