import Testing
import Foundation
@testable import ImageStorage

final class MemoryFileManager: FileManagerProtocol, @unchecked Sendable {
    private var fileSystem: [URL: Data] = [:]
    private let lock = NSLock()
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
        let keys = lockedKeys()
        return keys.contains(where: { $0.path == path })
    }
    
    public func removeItem(at url: URL) throws {
        lock.lock()
        _ = fileSystem.removeValue(forKey: url)
        lock.unlock()
    }
    
    public func removeAllItems(in directory: URL) throws {
        lock.lock()
        let keysToRemove = fileSystem.keys.filter { $0.path.starts(with: directory.path) }
        for key in keysToRemove {
            fileSystem.removeValue(forKey: key)
        }
        lock.unlock()
    }
    
    public func store(_ data: Data, at url: URL) {
        lock.lock()
        fileSystem[url] = data
        lock.unlock()
    }
    
    public func read(at url: URL) -> Data? {
        lock.lock()
        let data = fileSystem[url]
        lock.unlock()
        return data
    }
    
    private func lockedKeys() -> [URL] {
        lock.lock()
        let keys = Array(fileSystem.keys)
        lock.unlock()
        return keys
    }
}
