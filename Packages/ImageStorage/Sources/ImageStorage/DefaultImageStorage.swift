import Foundation

/// Concrete implementation of ``ImageStorageProtocol`` that stores
/// images in the app's Documents directory.
public final class DefaultImageStorage: ImageStorageProtocol, @unchecked Sendable {
    
    private let storageDirectory: URL
    
    /// Creates a new image storage backed by the Documents directory.
    public init() {
        self.storageDirectory = FileManager.default.documentsDirectory
    }
    
    // MARK: - ImageStorageProtocol
    
    public func store(_ data: Data, forKey key: String) async throws {
        guard isValidKey(key) else {
            throw ImageStorageError.invalidKey
        }
        
        let fileURL = fileURL(forKey: key)
        
        do {
            try FileManager.default.createDirectoryIfNeeded(storageDirectory)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw ImageStorageError.writeFailed(key)
        }
    }
    
    public func url(forKey key: String) async throws -> URL {
        let fileURL = fileURL(forKey: key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw ImageStorageError.fileNotFound(key)
        }
        
        return fileURL
    }
    
    public func exists(forKey key: String) async -> Bool {
        let fileURL = fileURL(forKey: key)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    public func data(forKey key: String) async throws -> Data {
        let fileURL = fileURL(forKey: key)
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            throw ImageStorageError.readFailed(key)
        }
    }
    
    @discardableResult
    public func delete(forKey key: String) async throws -> Bool {
        let fileURL = fileURL(forKey: key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            throw ImageStorageError.deleteFailed(key)
        }
    }
    
    public func clearCache() async throws {
        do {
            try FileManager.default.removeAllItems(in: storageDirectory)
        } catch {
            throw ImageStorageError.deleteFailed("cache")
        }
    }
    
    // MARK: - Private
    
    private func fileURL(forKey key: String) -> URL {
        storageDirectory.appendingPathComponent(key).appendingPathExtension("jpg")
    }
    
    private func isValidKey(_ key: String) -> Bool {
        !key.isEmpty && !key.contains("/") && !key.contains("\\") && !key.contains("\n") && !key.contains("\r") && !key.hasPrefix(".")
    }
}
