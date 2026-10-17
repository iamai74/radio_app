import Testing
import Foundation
@testable import ImageStorage

@Suite("ImageStorage Key Validation")
struct KeyValidationTests {
    @Test
    func validKey_passesValidation() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        #expect(await storage.exists(forKey: "testKey") == false)
        
        try await storage.store(Data([0x89, 0x50, 0x4E, 0x47]), forKey: "testKey")
        
        #expect(await storage.exists(forKey: "testKey") == true)
    }

    @Test
    func emptyKey_throwsInvalidKey() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        await #throws(by: ImageStorageError.self) {
            try await storage.store(Data(), forKey: "")
        }
    }

    @Test
    func keyWithSlash_throwsInvalidKey() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        await #throws(by: ImageStorageError.self) {
            try await storage.store(Data(), forKey: "../escape")
        }
    }
}

@Suite("ImageStorage Lifecycle")
struct ImageStorageLifecycleTests {
    @Test
    func storeAndRetrieve_dataMatches() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        let imageData = Data([0xFF, 0xD8, 0xFF, 0xE0])
        try await storage.store(imageData, forKey: "stationIcon")
        
        let retrieved = try await storage.data(forKey: "stationIcon")
        #expect(retrieved == imageData)
    }

    @Test
    func storeAndGetURL_returnsValidURL() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        try await storage.store(Data([1, 2, 3]), forKey: "flag")
        
        let url = try await storage.url(forKey: "flag")
        #expect(url.pathExtension == "jpg")
        #expect(url.lastPathComponent == "flag.jpg")
    }

    @Test
    func nonExistent_keyThrowsFileNotFound() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        await #throws(by: ImageStorageError.self) {
            try await storage.url(forKey: "missingKey")
        }
    }

    @Test
    func delete_existingFile_returnsTrue() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        try await storage.store(Data([1, 2]), forKey: "img")
        #expect(await storage.exists(forKey: "img") == true)
        
        let deleted = try await storage.delete(forKey: "img")
        #expect(deleted == true)
        #expect(await storage.exists(forKey: "img") == false)
    }

    @Test
    func delete_nonExistentFile_returnsFalse() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        let deleted = try await storage.delete(forKey: "nope")
        #expect(deleted == false)
    }

    @Test
    func clearCache_removesAllFiles() async throws {
        let tempDir = createTempDirectory()
        let fileManager = MemoryFileManager(baseDirectory: tempDir)
        let storage = TestableImageStorage(fileManager: fileManager, baseDirectory: tempDir)
        
        try await storage.store(Data([1]), forKey: "a")
        try await storage.store(Data([2]), forKey: "b")
        
        try await storage.clearCache()
        
        #expect(await storage.exists(forKey: "a") == false)
        #expect(await storage.exists(forKey: "b") == false)
    }
}

// MARK: - Helpers

private func createTempDirectory() -> URL {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    return tempDir
}
