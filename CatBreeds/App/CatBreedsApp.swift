import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct CatBreedsApp: App {
    
    init() {
        ImagePipelineClient.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State()
                ) {
                    AppFeature()
                }
            )
        }
        .modelContainer(SwiftDataStack.shared)
    }
}
