import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: \.selectedTab,
                    send: AppFeature.Action.selectedTabChanged
                )
            ) {
                Text("Breeds")
                    .tabItem {
                        Label("Breeds", systemImage: "cat")
                    }
                    .tag(AppTab.breeds)

                Text("Favorites")
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }
                    .tag(AppTab.favorites)
            }
        }
    }
}
