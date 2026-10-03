import Foundation
import RadioBrowserAPI

/// Mock implementation of LanguagesEndpointProtocol for testing purposes.
final class MockLanguagesEndpoint: LanguagesEndpointProtocol {
    private let languages: [Language]
    private let error: Error?
    
    /// Initializes the mock languages endpoint with specific data and potential error.
    /// - Parameters:
    ///   - languages: The languages to return from fetch operations, or empty array if no languages.
    ///   - error: The error to throw from fetch operations, or nil if no error.
    init(languages: [Language] = [], error: Error? = nil) {
        self.languages = languages
        self.error = error
    }
    
    /// Fetches a list of all languages.
    /// - Returns: Array of Language objects representing all languages.
    /// - Throws: APIError if request fails.
    func getLanguages() async throws -> [any Language] {
        if let error = error {
            throw error
        }
        return languages
    }
    
    /// Fetches languages that match the given filter.
    /// - Parameter filter: The filter to apply (e.g. by name or code)
    /// - Returns: Array of Language objects matching the filter
    /// - Throws: APIError if request fails
    func getLanguages(withFilter filter: String) async throws -> [any Language] {
        if let error = error {
            throw error
        }
        return languages
    }
}
