import Foundation
import NeedleFoundation
import RadioBrowserAPI
import Storage
import ImageStorage

/// Wiring scope for the root dependency values.
///
/// The app component is main-actor isolated, so its values are handed to this
/// nonisolated scope at construction. Package containers resolve them from
/// here, which keeps generated Needle providers free of main-actor access.
final class RootValuesComponent: Component<EmptyDependency>, ApiDependency, StorageDependency, ImageStorageDependency {

    public let networkClient: NetworkClientProtocol
    public let dataStore: Storage.DataStore
    public let imageStorage: ImageStorage.ImageStorageProtocol

    init(
        parent: Scope,
        networkClient: NetworkClientProtocol,
        dataStore: Storage.DataStore,
        imageStorage: ImageStorage.ImageStorageProtocol
    ) {
        self.networkClient = networkClient
        self.dataStore = dataStore
        self.imageStorage = imageStorage
        super.init(parent: parent)
    }

    var apiComponent: ApiComponent {
        ApiComponent(parent: self)
    }

    var storageComponent: StorageComponent {
        StorageComponent(parent: self)
    }

    var imageStorageComponent: ImageStorageComponent {
        ImageStorageComponent(parent: self)
    }
}
