import Foundation
@preconcurrency import Combine

public struct StorageSequence<Element: Sendable>: AsyncSequence, @unchecked Sendable {
    public typealias Element = [Element]

    private let values: AnyPublisher<[Element], Never>
    private let failures: AnyPublisher<StorageError, Never>

    public init(values: AnyPublisher<[Element], Never>, failures: AnyPublisher<StorageError, Never>) {
        self.values = values
        self.failures = failures
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(state: State(
            values: values,
            failures: failures
        ))
    }

    public func map<Other>(_ transform: @escaping @Sendable ([Element]) -> [Other]) -> StorageSequence<Other> {
        StorageSequence<Other>(
            values: values.map(transform).eraseToAnyPublisher(),
            failures: failures
        )
    }

    public struct Iterator: AsyncIteratorProtocol {
        public typealias Failure = StorageError
        private let state: State<[Element]>

        init(state: State<[Element]>) {
            self.state = state
        }

        public mutating func next() async throws -> [Element]? {
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
