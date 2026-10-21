import Foundation
import NeedleFoundation
import RadioBrowserAPI
import Architecture
import Storage

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
        dataStore: appDependency.dataStore,
        imageStorage: appDependency.imageStorage
    )

    lazy var apiComponent = rootValuesComponent.apiComponent

    lazy var storageComponent = rootValuesComponent.storageComponent

    lazy var mainComponent = MainComponent(
        parent: self,
        navigator: navigator,
        stationsService: stationsService
    )

    lazy var launchComponent = LaunchComponent(
        parent: self,
        navigator: navigator,
        mainCoordinator: mainComponent.coordinator
    )

    var api: RadioBrowserAPI {
        apiComponent.api
    }

    var stationsService: StationsService {
        StationsService(
            api: api,
            dataStore: storageComponent.dataStore,
            reader: storageComponent.dataStore
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
