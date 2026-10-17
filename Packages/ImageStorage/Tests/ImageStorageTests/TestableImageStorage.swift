import Foundation
@testable import ImageStorage

final class TestableImageStorage: ImageStorageProtocol {
    private let fileManager: MemoryFileManager
    private let baseDirectory: URL
    
    init(fileManager: MemoryFileManager, baseDirectory: URL) {
        self.fileManager = fileManager
        self.baseDirectory = baseDirectory
    }
    
    func store(_ data: Data, forKey key: String) async throws {
        guard key.isValidKey else {
            throw ImageStorageError.invalidKey
        }
        let fileURL = fileURL(forKey: key)
        fileManager.store(data, at: fileURL)
    }
    
    func url(forKey key: String) async throws -> URL {
        let fileURL = fileURL(forKey: key)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw ImageStorageError.fileNotFound(key)
        }
        return fileURL
    }
    
    func exists(forKey key: String) async -> Bool {
        let fileURL = fileURL(forKey: key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func data(forKey key: String) async throws -> Data {
        let fileURL = fileURL(forKey: key)
        guard let data = fileManager.read(at: fileURL) else {
            throw ImageStorageError.readFailed(key)
        }
        return data
    }
    
    @discardableResult
    func delete(forKey key: String) async throws -> Bool {
        let fileURL = fileURL(forKey: key)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return false
        }
        try fileManager.removeItem(at: fileURL)
        return true
    }
    
    func clearCache() async throws {
        try fileManager.removeAllItems(in: baseDirectory)
    }
    
    private func fileURL(forKey key: String) -> URL {
        baseDirectory.appendingPathComponent(key).appendingPathExtension("jpg")
    }
}

private extension String {
    var isValidKey: Bool {
        !isEmpty && !contains("/") && !contains("\\") && !contains("\n") && !contains("\r") && !hasPrefix(".")
    }
}
