#if DEBUG
import CatBreedsCore
import SwiftUI
import SwiftData
import ComposableArchitecture

struct UITestingApp: App {

    init() {
        ImagePipelineClient.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                } withDependencies: {
                    $0.breedsClient = .uiTestingValue
                    $0.favoritesPersistenceClient = .uiTestingValue
                }
            )
        }
    }
}
#endif
