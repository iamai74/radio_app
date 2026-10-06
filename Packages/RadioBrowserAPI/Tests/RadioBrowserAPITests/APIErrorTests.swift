import Foundation
import Testing
@testable import RadioBrowserAPI

/// The contract the failover relies on: which failures are worth retrying, how status codes
/// surface, and how two failures compare.
struct APIErrorTests {

    @Test(arguments: [
        (APIError.invalidURL, nil),
        (APIError.invalidResponse, nil),
        (APIError.httpError(404), 404),
        (APIError.httpError(503), 503),
        (APIError.decodingFailed(URLError(.badURL)), nil)
    ] as [(APIError, Int?)])
    func statusCodeOnlyReportsHttpErrors(error: APIError, expected: Int?) {
        #expect(error.statusCode == expected)
    }

    @Test(arguments: [
        (APIError.invalidURL, false),
        (APIError.invalidResponse, true),
        (APIError.decodingFailed(URLError(.badURL)), false),
        (APIError.undetermined(URLError(.badURL)), false),
        (APIError.httpError(404), false),
        (APIError.httpError(408), true),
        (APIError.httpError(429), true),
        (APIError.httpError(500), true),
        (APIError.httpError(599), true),
        (APIError.httpError(600), false),
        (APIError.networkFailed(URLError(.timedOut)), true),
        (APIError.networkFailed(CancellationError()), false),
        (APIError.networkFailed(URLError(.cancelled)), false)
    ] as [(APIError, Bool)])
    func retryabilityTellsWhetherAnotherAttemptCanSucceed(error: APIError, expected: Bool) {
        #expect(error.isRetryable == expected)
    }

    @Test
    func equalCasesCompareEqual() {
        #expect(APIError.invalidURL == .invalidURL)
        #expect(APIError.httpError(503) == .httpError(503))
        #expect(APIError.decodingFailed(URLError(.badURL)) == .decodingFailed(URLError(.badURL)))
    }

    @Test
    func differentCasesNeverCompareEqual() {
        #expect(APIError.httpError(503) != .httpError(504))
        #expect(APIError.httpError(503) != .invalidURL)
        #expect(APIError.networkFailed(URLError(.timedOut)) != .undetermined(URLError(.timedOut)))
    }

    @Test(arguments: [
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.decodingFailed(URLError(.badURL)),
        APIError.networkFailed(URLError(.timedOut)),
        APIError.undetermined(URLError(.badURL)),
        APIError.httpError(500)
    ])
    func everyFailureCarriesADescription(error: APIError) {
        #expect(!(error.errorDescription ?? "").isEmpty)
    }
}
