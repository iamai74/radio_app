import Foundation
import RadioBrowserAPI

/// Mock implementation of CountriesEndpointProtocol for testing purposes.
final class MockCountriesEndpoint: CountriesEndpointProtocol {
    private let countries: [Country]
    private let error: Error?
    
    /// Initializes the mock countries endpoint with specific data and potential error.
    /// - Parameters:
    ///   - countries: The countries to return from fetch operations, or empty array if no countries.
    ///   - error: The error to throw from fetch operations, or nil if no error.
    init(countries: [Country] = [], error: Error? = nil) {
        self.countries = countries
        self.error = error
    }

    /// Answers every route with the fixture this mock was built with.
    /// - Parameters:
    ///   - endpoint: The route that was requested; the mock answers all of them alike.
    ///   - queryItems: The query items of the request, ignored by the mock.
    /// - Returns: The countries this mock was built with.
    /// - Throws: The configured error, if any.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Country] {
        if let error {
            throw error
        }

        return countries
    }
}
