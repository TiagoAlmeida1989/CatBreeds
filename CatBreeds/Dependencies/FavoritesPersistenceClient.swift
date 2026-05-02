import CatBreedsCore
import ComposableArchitecture
import Foundation

enum PersistenceError: Error, Equatable {
    case fetchFailed
    case saveFailed
    case deleteFailed
}

extension PersistenceError {
    var userMessage: String {
        switch self {
        case .fetchFailed:
            return "Could not load your favorites. Please try again."
        case .saveFailed:
            return "Could not save your favorite. Please try again."
        case .deleteFailed:
            return "Could not remove your favorite. Please try again."
        }
    }
}

struct FavoritesPersistenceClient {
    var fetchFavorites: @Sendable () async throws -> [Breed]
    var saveFavorite: @Sendable (Breed) async throws -> Void
    var removeFavorite: @Sendable (Breed.ID) async throws -> Void
}

extension FavoritesPersistenceClient: DependencyKey {
    static var liveValue: FavoritesPersistenceClient {
        @Dependency(\.favoritesLocalDataSource) var dataSource
        return FavoritesPersistenceClient(
            fetchFavorites: { try await dataSource.fetchFavorites() },
            saveFavorite: { try await dataSource.saveFavorite($0) },
            removeFavorite: { try await dataSource.removeFavorite(id: $0) }
        )
    }

    static let testValue = FavoritesPersistenceClient(
        fetchFavorites: { [] },
        saveFavorite: { _ in },
        removeFavorite: { _ in }
    )
}

extension DependencyValues {
    var favoritesPersistenceClient: FavoritesPersistenceClient {
        get { self[FavoritesPersistenceClient.self] }
        set { self[FavoritesPersistenceClient.self] = newValue }
    }
}
