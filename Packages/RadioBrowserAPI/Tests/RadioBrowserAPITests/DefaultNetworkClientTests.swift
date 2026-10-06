import Testing
import Foundation
@testable import RadioBrowserAPI

/// Tests for `DefaultNetworkClient`, driven by a `URLProtocol` stub so the production
/// session stack is exercised instead of a hand written double.
///
/// The stub keeps its state in static storage, because the session instantiates protocol
/// subclasses itself, so the suite is serialised to keep one test's stub out of another's way.
@Suite(.serialized)
struct DefaultNetworkClientTests {
    private var request: URLRequest {
        URLRequest(url: URL(string: "https://de2.api.radio-browser.info/json/stations") ?? URL(fileURLWithPath: "/"))
    }

    /// The user agent is no longer the client's concern — `RequestBuilder` attaches it
    /// before the transport sees the request; see `RequestBuilderTests`.
    @Test
    func successfulResponseReturnsBody() async throws {
        let client = makeClient()
        StubURLProtocol.stub(statusCode: 200, body: Data("[{\"stationuuid\": \"abc\"}]".utf8))

        let data = try await client.fetch(request: request)

        #expect(String(bytes: data, encoding: .utf8) == "[{\"stationuuid\": \"abc\"}]")
    }

    @Test(arguments: [400, 401, 404, 429, 500, 503])
    func nonSuccessStatusIsReportedAsHTTPError(statusCode: Int) async throws {
        let client = makeClient()
        StubURLProtocol.stub(statusCode: statusCode, body: Data("nope".utf8))

        do {
            _ = try await client.fetch(request: request)
            Issue.record("Expected status \(statusCode) to fail")
        } catch let error as APIError {
            guard case .httpError(let reported) = error else {
                Issue.record("Expected APIError.httpError, got \(error)")
                return
            }
            #expect(reported == statusCode)
        }
    }

    @Test
    func nonHTTPResponseIsReportedAsInvalidResponse() async throws {
        let client = makeClient()
        StubURLProtocol.stubNonHTTPResponse()

        do {
            _ = try await client.fetch(request: request)
            Issue.record("Expected a non HTTP response to fail")
        } catch let error as APIError {
            guard case .invalidResponse = error else {
                Issue.record("Expected APIError.invalidResponse, got \(error)")
                return
            }
        }
    }

    @Test
    func transportFailureIsReportedAsNetworkFailure() async throws {
        let client = makeClient()
        StubURLProtocol.stub(error: URLError(.notConnectedToInternet))

        do {
            _ = try await client.fetch(request: request)
            Issue.record("Expected the request to fail")
        } catch let error as APIError {
            guard case .networkFailed(let underlying) = error else {
                Issue.record("Expected APIError.networkFailed, got \(error)")
                return
            }
            #expect((underlying as? URLError)?.code == .notConnectedToInternet)
        }
    }

    @Test
    func endpointSurfacesHTTPErrorWithoutDecoding() async throws {
        let endpoint = StationsEndpoint(networkClient: makeClient())
        StubURLProtocol.stub(statusCode: 404, body: Data("<html>not found</html>".utf8))

        do {
            _ = try await endpoint.getStation(byID: "abc")
            Issue.record("Expected getStation(byID:) to fail on a 404")
        } catch let error as APIError {
            guard case .httpError(404) = error else {
                Issue.record("Expected APIError.httpError(404), got \(error)")
                return
            }
        }
    }

    @Test
    func endpointDecodesStationsOfASuccessfulResponse() async throws {
        let endpoint = StationsEndpoint(networkClient: makeClient())
        StubURLProtocol.stub(statusCode: 200, body: try MockData.json(named: "stations"))

        let stations = try await endpoint.getAllStations()

        #expect(stations.map(\.id) == ["7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60", "second-station-id", "third-station-id"])
        #expect(StubURLProtocol.lastRequest?.url?.path == "/json/stations")
    }

    // MARK: - Helpers

    private func makeClient() -> DefaultNetworkClient {
        StubURLProtocol.reset()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]

        return DefaultNetworkClient(session: URLSession(configuration: configuration))
    }
}

/// Intercepts the requests of the session under test and replays a canned outcome.
final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    /// Canned outcome replayed for every request.
    private enum Outcome {
        case response(statusCode: Int, body: Data)
        case nonHTTPResponse
        case failure(Error)
    }

    private static let lock = NSLock()
    private static var outcome: Outcome?
    private static var recordedRequest: URLRequest?

    /// Request the stub was asked to perform, or `nil` before the first call.
    static var lastRequest: URLRequest? {
        lock.withLock { recordedRequest }
    }

    /// Answers every subsequent request with `statusCode` and `body`.
    static func stub(statusCode: Int, body: Data) {
        lock.withLock { outcome = .response(statusCode: statusCode, body: body) }
    }

    /// Answers with a response that is not an `HTTPURLResponse`.
    static func stubNonHTTPResponse() {
        lock.withLock { outcome = .nonHTTPResponse }
    }

    /// Fails every subsequent request with `error`.
    static func stub(error: Error) {
        lock.withLock { outcome = .failure(error) }
    }

    /// Forgets the configured outcome and the recorded request.
    static func reset() {
        lock.withLock {
            outcome = nil
            recordedRequest = nil
        }
    }

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let current = Self.lock.withLock { () -> Outcome in
            Self.recordedRequest = request
            return Self.outcome ?? .failure(URLError(.unsupportedURL))
        }

        let url = request.url ?? URL(fileURLWithPath: "/")

        switch current {
        case .response(let statusCode, let body):
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        case .nonHTTPResponse:
            let response = URLResponse(
                url: url,
                mimeType: "application/json",
                expectedContentLength: 0,
                textEncodingName: nil
            )
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data())
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
