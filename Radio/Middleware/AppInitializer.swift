import Foundation
import RadioBrowserAPI
import Storage
import NeedleFoundation

@MainActor
public protocol AppDependency: Dependency {
    var networkClient: NetworkClientProtocol { get }
    var dataStore: Storage.DataStore { get }
}

@MainActor
public class AppInitializer {
    public static func initialize() async throws -> AppDependency {
        let modelContainer = try StorageContainer.create()
        let networkClient = DefaultNetworkClient()
        let dataStore = Storage.DataStore(modelContainer: modelContainer)

        return AppDependencyImpl(
            networkClient: networkClient,
            dataStore: dataStore
        )
    }
}

@MainActor
internal final class AppDependencyImpl: AppDependency {
    let networkClient: NetworkClientProtocol
    let dataStore: Storage.DataStore

    init(networkClient: NetworkClientProtocol, dataStore: Storage.DataStore) {
        self.networkClient = networkClient
        self.dataStore = dataStore
    }
}
