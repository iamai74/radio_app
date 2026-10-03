import Foundation

internal protocol RadioBrowserApiDependency {
    var networkClient: NetworkClientProtocol { get }
}

internal class RadioBrowserApiComponent {
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
