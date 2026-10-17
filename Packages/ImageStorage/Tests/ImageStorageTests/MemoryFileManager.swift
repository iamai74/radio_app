import Testing
import Foundation
@testable import ImageStorage

final class MemoryFileManager: FileManagerProtocol {
    private var fileSystem: [URL: Data] = [:]
    private let baseDirectory: URL
    
    init(baseDirectory: URL) {
        self.baseDirectory = baseDirectory
    }
    
    public var documentsDirectory: URL {
        baseDirectory
    }
    
    public func createDirectoryIfNeeded(_ directory: URL) throws {
        // No-op for in-memory FS
    }
    
    public func fileExists(atPath path: String) -> Bool {
        fileKeys.contains(where: { $0.path == path })
    }
    
    public func removeItem(at url: URL) throws {
        _ = fileSystem.removeValue(forKey: url)
    }
    
    public func removeAllItems(in directory: URL) throws {
        let keysToRemove = fileKeys.filter { $0.path.starts(with: directory.path) }
        for key in keysToRemove {
            fileSystem.removeValue(forKey: key)
        }
    }
    
    public func store(_ data: Data, at url: URL) {
        fileSystem[url] = data
    }
    
    public func read(at url: URL) -> Data? {
        fileSystem[url]
    }
    
    private var fileKeys: [URL] {
        fileSystem.keys
    }
}
