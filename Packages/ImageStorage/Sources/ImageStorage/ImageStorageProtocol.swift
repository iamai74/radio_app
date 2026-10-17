import Foundation

/// Protocol for file-based image storage in the Documents directory.
///
/// Stores images keyed by a string identifier and returns
/// file URLs for retrieval. Suitable for caching station icons,
/// country flags, and other images fetched over the network.
public protocol ImageStorageProtocol: Sendable {
    /// Store the given data under the specified key.
    ///
    /// - Parameters:
    ///   - data: Image data to persist.
    ///   - key: Unique identifier for this image.
    func store(_ data: Data, forKey key: String) async throws

    /// Retrieve the file URL for a previously stored image.
    ///
    /// - Parameter key: Identifier of the stored image.
    /// - Returns: File URL pointing to the cached image.
    /// - Throws: ``ImageStorageError/fileNotFound(_:)`` if the file does not exist.
    func url(forKey key: String) async throws -> URL

    /// Check whether an image exists for the given key.
    ///
    /// - Parameter key: Identifier to check.
    /// - Returns: `true` if the file exists on disk.
    func exists(forKey key: String) async -> Bool

    /// Read the stored data for the given key.
    ///
    /// - Parameter key: Identifier of the stored image.
    /// - Returns: The persisted ``Data``.
    /// - Throws: ``ImageStorageError/readFailed(_:)`` if the file cannot be read.
    func data(forKey key: String) async throws -> Data

    /// Delete a stored image.
    ///
    /// - Parameter key: Identifier of the image to remove.
    /// - Returns: `true` if the file was deleted, `false` if it did not exist.
    @discardableResult
    func delete(forKey key: String) async throws -> Bool

    /// Delete all stored images.
    func clearCache() async throws
}
