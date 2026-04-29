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
                NavigationStack {
                    BreedsListView(
                        store: store.scope(
                            state: \.breedsList,
                            action: AppFeature.Action.breedsList
                        )
                    )
                }
                .tabItem {
                    Label("Breeds", systemImage: "cat")
                }
                .tag(AppTab.breeds)

                NavigationStack {
                    FavoritesView(
                        store: store.scope(
                            state: \.favorites,
                            action: AppFeature.Action.favorites
                        )
                    )
                }
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
                .tag(AppTab.favorites)
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}
