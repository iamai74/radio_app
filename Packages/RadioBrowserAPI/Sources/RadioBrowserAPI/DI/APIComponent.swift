import Foundation

internal protocol RadioBrowserApiDependency {
    var networkClient: NetworkClientProtocol { get }
}

package protocol RadioBrowserApiComponentProtocol {
    var stations: StationsEndpointProtocol { get }
    var countries: CountriesEndpointProtocol { get }
    var languages: LanguagesEndpointProtocol { get }
    var tags: TagsEndpointProtocol { get }
    var codecs: CodecsEndpointProtocol { get }
    var radioBrowserAPI: RadioBrowserAPI { get }
}

internal class RadioBrowserApiComponent: RadioBrowserApiComponentProtocol {
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

    private let dependency: RadioBrowserApiDependency

    init(dependency: RadioBrowserApiDependency) {
        self.dependency = dependency
    }
}
