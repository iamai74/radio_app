import Foundation
import NeedleFoundation
import RadioBrowserAPI

/// Dependency contract for the RadioBrowserAPI container.
/// Satisfied by the ancestor component that owns the transport.
protocol ApiDependency: Dependency {
    var networkClient: NetworkClientProtocol { get }
}

/// Container for the RadioBrowserAPI package.
/// Owns the API instance for its scope instead of constructing one per access.
final class ApiComponent: Component<ApiDependency> {

    var api: RadioBrowserAPI {
        shared { RadioBrowserAPI(networkClient: dependency.networkClient) }
    }
}
