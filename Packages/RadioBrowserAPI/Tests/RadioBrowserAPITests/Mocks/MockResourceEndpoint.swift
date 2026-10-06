import Foundation
import RadioBrowserAPI

/// Test double for the resource endpoints (countries, languages, tags and codecs).
///
/// One generic type replaces the four copies that used to differ only in their element
/// type: instantiate it with the resource the test needs — `MockResourceEndpoint<Country>`
/// for the country endpoint — and every capability answers from the same fixture.
struct MockResourceEndpoint<R: Sendable>: ResourceEndpointProtocol, ResourceFiltering, @unchecked Sendable {
    private let resources: [R]
    private let error: Error?

    /// `@unchecked` because `Error` existentials are not `Sendable`; the storage is
    /// immutable after `init`, so the value is shared across tasks without racing.

    /// - Parameters:
    ///   - resources: The fixture every list call answers with.
    ///   - error: The error every call throws, or `nil` for the fixture.
    init(resources: [R] = [], error: Error? = nil) {
        self.resources = resources
        self.error = error
    }

    func getResources() async throws -> [R] {
        try result()
    }

    func getResources(withFilter _: String) async throws -> [R] {
        try result()
    }

    private func result() throws -> [R] {
        if let error {
            throw error
        }

        return resources
    }
}
