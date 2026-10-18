import CryptoKit
import Foundation
import ImageStorage
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
final class ImageDownloadService {
    private let imageStorage: ImageStorageProtocol

    init(imageStorage: ImageStorageProtocol) {
        self.imageStorage = imageStorage
    }

    func downloadAndStore(from url: URL) async throws -> String {
        let key = ImageDownloadService.storageKey(from: url)

        if await imageStorage.exists(forKey: key) {
            return key
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        try await imageStorage.store(data, forKey: key)

        return key
    }

    func loadImage(withKey key: String) async throws -> PlatformImageWrapper {
        let data = try await imageStorage.data(forKey: key)
        guard let image = PlatformImageWrapper(data: data) else {
            throw ImageStorageError.readFailed(key)
        }
        return image
    }

    func removeImage(withKey key: String) async throws {
        try await imageStorage.delete(forKey: key)
    }

    func clearCache() async throws {
        try await imageStorage.clearCache()
    }

    static func storageKey(from url: URL) -> String {
        let data = url.absoluteURL.absoluteString.data(using: .utf8) ?? Data()
        let digest = CryptoKit.Insecure.SHA1.hash(data: data)
        return digest.map { String(format: "%02.2hhx", $0) }.joined()
    }

    private static func dumpFormat<S: DataProtocol>(_ source: S) -> String {
        source.map { String(format: "%02.2hhx", $0) }.joined()
    }
}

enum PlatformImageWrapper {
    #if os(iOS)
    case ios(UIImage)
    #elseif os(macOS)
    case mac(NSImage)
    #endif

    init?(data: Data) {
        #if os(iOS)
        guard let uiImage = UIImage(data: data) else { return nil }
        self = .ios(uiImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        self = .mac(nsImage)
        #endif
    }
}
