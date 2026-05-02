import ComposableArchitecture
import Foundation

private enum FavoritesLocalDataSourceKey: DependencyKey {
    static var liveValue: any FavoritesLocalDataSource {
        SwiftDataFavoritesLocalDataSource(container: SwiftDataStack.shared)
    }
}

extension DependencyValues {
    var favoritesLocalDataSource: any FavoritesLocalDataSource {
        get { self[FavoritesLocalDataSourceKey.self] }
        set { self[FavoritesLocalDataSourceKey.self] = newValue }
    }
}
