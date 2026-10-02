import Foundation
import NeedleFoundation
import RadioBrowserAPI
import Storage

typealias ComponentAppDependency = AppDependency

@MainActor
public class AppComponent: BootstrapComponent {
    
    let appDependency: ComponentAppDependency
    
    init(appDependency: ComponentAppDependency) {
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
