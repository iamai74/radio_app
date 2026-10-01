import Foundation
import NeedleFoundation

public protocol RadioBrowserApiDependency: Dependency {
    var networkClient: NetworkClientProtocol { get }
}

public class RadioBrowserApiComponent: Component<RadioBrowserApiDependency> {
    var stations: StationsEndpointProtocol {
        StationsEndpoint(networkClient: dependency.networkClient)
    }

    var countries: CountriesEndpointProtocol {
        CountriesEndpoint(networkClient: dependency.networkClient)
    }

    var languages: LanguagesEndpointProtocol {
        LanguagesEndpoint(networkClient: dependency.networkClient)
    }

    var tags: TagsEndpointProtocol {
        TagsEndpoint(networkClient: dependency.networkClient)
    }

    var codecs: CodecsEndpointProtocol {
        CodecsEndpoint(networkClient: dependency.networkClient)
    }

    var radioBrowserAPI: RadioBrowserAPI {
        RadioBrowserAPI(component: self)
    }
}
