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
public struct StorageSequence<Entity: Sendable>: AsyncSequence, @unchecked Sendable {
    public typealias Element = [Entity]

    private let values: AnyPublisher<[Entity], Never>
    private let failures: AnyPublisher<StorageError, Never>

    public init(values: AnyPublisher<[Entity], Never>, failures: AnyPublisher<StorageError, Never>) {
        self.values = values
        self.failures = failures
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(state: State(
            values: values,
            failures: failures
        ))
    }

    /// Element-wise transform, used to lift a concrete entity type to the public
    /// DTO existential that `DataStore` hands out.
    public func map<Other>(_ transform: @escaping @Sendable ([Entity]) -> [Other]) -> StorageSequence<Other> {
        StorageSequence<Other>(
            values: values.map(transform).eraseToAnyPublisher(),
            failures: failures
        )
    }

    public struct Iterator: AsyncIteratorProtocol {
        public typealias Failure = StorageError
        private let state: State<[Entity]>

        init(state: State<[Entity]>) {
            self.state = state
        }

        public mutating func next() async throws -> [Entity]? {
            let event = await state.next()
            switch event {
            case .none:
                return nil
            case let .success(value):
                return value
            case let .failure(error):
                throw error
            }
        }
    }

    /// Owns one iterator's Combine subscriptions and its element buffer.
    final class State<T: Sendable>: @unchecked Sendable {
        private let lock = NSLock()
        private var cancellables = Set<AnyCancellable>()
        private var iterator: AsyncStream<Result<T, StorageError>>.AsyncIterator
        private let continuation: AsyncStream<Result<T, StorageError>>.Continuation

        init(values: AnyPublisher<T, Never>, failures: AnyPublisher<StorageError, Never>) {
            let (strm, cont) = AsyncStream<Result<T, StorageError>>.makeStream()
            self.iterator = strm.makeAsyncIterator()
            self.continuation = cont
            store(values.sink { [weak self] value in
                self?.yield(.success(value))
            })
            store(failures.sink { [weak self] error in
                self?.yield(.failure(error))
            })
        }

        func next() async -> Result<T, StorageError>? {
            await iterator.next()
        }

        func yield(_ value: sending Result<T, StorageError>) {
            continuation.yield(value)
        }

        func cancel() {
            lock.lock()
            let toCancel = cancellables
            cancellables = []
            lock.unlock()
            toCancel.forEach { $0.cancel() }
            continuation.finish()
        }

        private func store(_ cancellable: AnyCancellable) {
            lock.lock()
            cancellables.insert(cancellable)
            lock.unlock()
        }

        deinit {
            cancel()
        }
    }
}
