import Foundation
@testable import RadioBrowserAPI

/// Test double for `NetworkClientProtocol`.
///
/// It replays a canned outcome (payload or error) and records every request it is asked
/// to perform, so tests can assert how endpoints build their URLs.
final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    /// What the double returns from `fetch(request:)`.
    enum Outcome {
        case success(Data)
        case failure(Error)
    }

    private let outcome: Outcome
    private let lock = NSLock()
    private var recordedRequests: [URLRequest] = []

    /// Creates a double replaying `data` for every request.
    init(data: Data) {
        outcome = .success(data)
    }

    /// Creates a double throwing `error` for every request.
    init(error: Error) {
        outcome = .failure(error)
    }

    /// Requests received so far, in order.
    var requests: [URLRequest] {
        lock.withLock { recordedRequests }
    }

    /// The most recent request, or `nil` when nothing has been requested yet.
    var lastRequest: URLRequest? {
        requests.last
    }

    func fetch(request: URLRequest) async throws -> Data {
        lock.withLock { recordedRequests.append(request) }

        switch outcome {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
