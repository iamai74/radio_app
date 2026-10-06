import Foundation

/// Loads the JSON fixtures bundled with the test target.
///
/// The fixtures live in `Mocks/Data` and are declared as a processed resource of the
/// test target in `Package.swift`, so they are resolved through `Bundle.module`.
enum MockData {
    /// Raised when a fixture is not part of the compiled test bundle.
    enum LoadError: Error, CustomStringConvertible {
        case missingResource(String)

        var description: String {
            switch self {
            case .missingResource(let name):
                return "Test resource '\(name).json' is missing from \(Bundle.module.bundlePath)"
            }
        }
    }

    /// Returns the raw JSON of the `name` fixture.
    ///
    /// - Parameter name: File name of the fixture without the `json` extension.
    /// - Returns: The bytes of the bundled fixture.
    /// - Throws: `LoadError.missingResource` when the fixture is not bundled.
    static func json(named name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw LoadError.missingResource(name)
        }

        return try Data(contentsOf: url)
    }
}
