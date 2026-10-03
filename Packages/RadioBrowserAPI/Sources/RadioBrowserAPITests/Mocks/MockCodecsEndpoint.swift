import Foundation
import RadioBrowserAPI

/// Mock implementation of CodecsEndpointProtocol for testing purposes.
final class MockCodecsEndpoint: CodecsEndpointProtocol {
    private let codecs: [Codec]
    private let error: Error?
    
    /// Initializes the mock codecs endpoint with specific data and potential error.
    /// - Parameters:
    ///   - codecs: The codecs to return from fetch operations, or empty array if no codecs.
    ///   - error: The error to throw from fetch operations, or nil if no error.
    init(codecs: [Codec] = [], error: Error? = nil) {
        self.codecs = codecs
        self.error = error
    }
    
    /// Fetches a list of all audio codecs.
    /// - Returns: Array of Codec objects representing all audio codecs.
    /// - Throws: APIError if request fails.
    func getAudioCodecs() async throws -> [any Codec] {
        if let error = error {
            throw error
        }
        return codecs
    }
}
