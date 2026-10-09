import Foundation
import NeedleFoundation
import RadioBrowserAPI
import Storage

/// Wiring scope for the root dependency values.
///
/// The app component is main-actor isolated, so its values are handed to this
/// nonisolated scope at construction. Package containers resolve them from
/// here, which keeps generated Needle providers free of main-actor access.
final class RootValuesComponent: Component<EmptyDependency> {

    public let networkClient: NetworkClientProtocol
    public let dataStore: Storage.DataStore

    init(
        parent: Scope,
        networkClient: NetworkClientProtocol,
        dataStore: Storage.DataStore
    ) {
        self.networkClient = networkClient
        self.dataStore = dataStore
        super.init(parent: parent)
    }

    var apiComponent: ApiComponent {
        ApiComponent(parent: self)
    }

    var storageComponent: StorageComponent {
        StorageComponent(parent: self)
    }
}
