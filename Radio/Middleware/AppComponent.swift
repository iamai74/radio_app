import Foundation
import NeedleFoundation
import RadioBrowserAPI
import Storage

@MainActor
public protocol AppDependency: Dependency {
    var networkClient: NetworkClientProtocol { get }
    var dataStore: Storage.DataStore { get }
}

@MainActor
public class AppComponent: BootstrapComponent {
    
    let appDependency: AppDependency
    
    public init(appDependency: AppDependency) {
        self.appDependency = appDependency
        super.init()
    }
    
    var api: RadioBrowserAPI {
        RadioBrowserAPI(networkClient: appDependency.networkClient)
    }
    
    var stationsService: StationsService {
        StationsService(
            api: api,
            dataStore: appDependency.dataStore
        )
    }
    
    var countriesService: CountriesService {
        CountriesService(
            api: api,
            dataStore: appDependency.dataStore
        )
    }
    
    var languagesService: LanguagesService {
        LanguagesService(
            api: api,
            dataStore: appDependency.dataStore
        )
    }
    
    var tagsService: TagsService {
        TagsService(
            api: api,
            dataStore: appDependency.dataStore
        )
    }
    
    var codecsService: CodecsService {
        CodecsService(
            api: api,
            dataStore: appDependency.dataStore
        )
    }
}
