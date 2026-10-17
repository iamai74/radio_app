import Foundation
import RadioBrowserAPI
import Storage
import ImageStorage
import NeedleFoundation

@MainActor
public protocol AppDependency: Dependency {
    var networkClient: NetworkClientProtocol { get }
    var dataStore: Storage.DataStore { get }
    var imageStorage: ImageStorage.ImageStorageProtocol { get }
}

@MainActor
public class AppInitializer {
    public static func initialize() async throws -> AppDependency {
        let modelContainer = try StorageContainer.create()
        let networkClient = DefaultNetworkClient()
        let dataStore = Storage.DataStore(modelContainer: modelContainer)
        let imageStorage = ImageStorage.DefaultImageStorage()

        return AppDependencyImpl(
            networkClient: networkClient,
            dataStore: dataStore,
            imageStorage: imageStorage
        )
    }
}

@MainActor
internal final class AppDependencyImpl: AppDependency {
    let networkClient: NetworkClientProtocol
    let dataStore: Storage.DataStore
    let imageStorage: ImageStorage.ImageStorageProtocol

    init(networkClient: NetworkClientProtocol, dataStore: Storage.DataStore, imageStorage: ImageStorage.ImageStorageProtocol) {
        self.networkClient = networkClient
        self.dataStore = dataStore
        self.imageStorage = imageStorage
    }
}
