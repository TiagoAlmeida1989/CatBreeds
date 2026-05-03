import CatBreedsCore
import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        TabView(
            selection: Binding(
                get: { store.selectedTab },
                set: { store.send(.selectedTabChanged($0)) }
            )
        ) {
            BreedsListView(
                store: store.scope(state: \.breedsList, action: \.breedsList)
            )
            .tabItem {
                Label("Breeds", systemImage: "cat")
            }
            .tag(AppTab.breeds)

            FavoritesView(
                store: store.scope(state: \.favorites, action: \.favorites)
            )
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
            .tag(AppTab.favorites)
        }
        .tint(.brown)
        .task {
            await store.send(.task).finish()
        }
    }
}
