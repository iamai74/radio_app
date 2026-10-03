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
    
    /// Fetches a list of all countries.
    /// - Returns: Array of Country objects representing all countries.
    /// - Throws: APIError if request fails.
    func getCountries() async throws -> [any Country] {
        if let error = error {
            throw error
        }
        return countries
    }
    
    /// Fetches countries with the given filter.
    /// - Parameter filter: The filter to apply (e.g. by name or code)
    /// - Returns: Array of Country objects matching the filter
    /// - Throws: APIError if request fails
    func getCountries(withFilter filter: String) async throws -> [any Country] {
        if let error = error {
            throw error
        }
        return countries
    }
}
