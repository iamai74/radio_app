import Foundation
import NeedleFoundation
import RadioBrowserAPI
import Architecture

typealias ComponentAppDependency = AppDependency

@MainActor
public class AppComponent: BootstrapComponent {

    let appDependency: ComponentAppDependency
    let navigator: NavigatorProtocol

    init(appDependency: ComponentAppDependency, navigator: NavigatorProtocol) {
        self.appDependency = appDependency
        self.navigator = navigator
        super.init()
    }

    lazy var rootValuesComponent = RootValuesComponent(
        parent: self,
        networkClient: appDependency.networkClient,
        dataStore: appDependency.dataStore
    )

    lazy var apiComponent = rootValuesComponent.apiComponent

    lazy var storageComponent = rootValuesComponent.storageComponent

    lazy var launchComponent = LaunchComponent(parent: self, navigator: navigator)

    var api: RadioBrowserAPI {
        apiComponent.api
    }

    var stationsService: StationsService {
        StationsService(
            api: api,
            dataStore: storageComponent.dataStore
        )
    }

    var countriesService: CountriesService {
        CountriesService(
            api: api,
            dataStore: storageComponent.dataStore
        )
    }

    var languagesService: LanguagesService {
        LanguagesService(
            api: api,
            dataStore: storageComponent.dataStore
        )
    }

    var tagsService: TagsService {
        TagsService(
            api: api,
            dataStore: storageComponent.dataStore
        )
    }

    var codecsService: CodecsService {
        CodecsService(
            api: api,
            dataStore: storageComponent.dataStore
        )
    }
}
