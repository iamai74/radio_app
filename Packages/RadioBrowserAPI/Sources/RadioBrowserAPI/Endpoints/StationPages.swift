import Foundation

/// A lazy walk over a station result set, one page per iteration.
///
/// Nothing is requested before the first `next()`, one request is in flight per page, and
/// the walk stops as soon as the consumer stops iterating — a `break` costs no further
/// requests. Cancellation is the usual story: cancelling the task that iterates fails the
/// `await` in progress with `CancellationError`.
public struct StationPages: AsyncSequence, Sendable {
    public typealias Element = [any Station]

    private let source: any StationFetching
    private let query: StationQuery
    private let pageSize: Int

    /// - Parameters:
    ///   - source: The endpoint to walk.
    ///   - query: The criteria of the whole walk; its `limit` and `offset` are replaced
    ///     per page, every other criterion is kept.
    ///   - pageSize: The number of stations requested per page.
    init(source: any StationFetching, query: StationQuery, pageSize: Int) {
        precondition(pageSize > 0, "A page holds at least one station")

        self.source = source
        self.query = query
        self.pageSize = pageSize
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(source: source, query: query, pageSize: pageSize)
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let source: any StationFetching
        private let query: StationQuery
        private let pageSize: Int
        private var offset: Int
        private var isFinished = false

        init(source: any StationFetching, query: StationQuery, pageSize: Int) {
            self.source = source
            self.query = query
            self.pageSize = pageSize
            self.offset = query.offset
        }

        /// Requests the next page, or `nil` once the service reported the end of the set.
        ///
        /// The end is a page shorter than the requested size, which is how Radio Browser
        /// answers, or an empty page.
        public mutating func next() async throws -> [any Station]? {
            guard !isFinished else {
                return nil
            }

            var pageQuery = query
            pageQuery.limit = pageSize
            pageQuery.offset = offset

            let stations = try await source.getStations(matching: pageQuery)

            if stations.isEmpty {
                isFinished = true

                return nil
            }

            if stations.count < pageSize {
                isFinished = true
            } else {
                offset += stations.count
            }

            return stations
        }
    }
}
