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

    /// Answers every route with the fixture this mock was built with.
    /// - Parameters:
    ///   - endpoint: The route that was requested; the mock answers all of them alike.
    ///   - queryItems: The query items of the request, ignored by the mock.
    /// - Returns: The languages this mock was built with.
    /// - Throws: The configured error, if any.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Language] {
        if let error {
            throw error
        }

        return languages
    }
}
