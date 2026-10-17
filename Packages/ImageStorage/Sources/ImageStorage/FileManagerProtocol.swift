import Foundation

/// Lightweight abstraction over ``FileManager`` for testability.
public protocol FileManagerProtocol {
    var documentsDirectory: URL { get }
    func createDirectoryIfNeeded(_ directory: URL) throws
    func fileExists(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
    func removeAllItems(in directory: URL) throws
}

/// Default ``FileManagerProtocol`` backed by the shared ``FileManager``.
extension FileManager: FileManagerProtocol {
    public var documentsDirectory: URL {
        guard let url = urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Documents directory unavailable")
        }
        return url
    }
    
    public func createDirectoryIfNeeded(_ directory: URL) throws {
        guard !fileExists(atPath: directory.path) else {
            return
        }
        try createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func removeAllItems(in directory: URL) throws {
        let contents = try contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        for itemURL in contents {
            try removeItem(at: itemURL)
        }
    }
}
