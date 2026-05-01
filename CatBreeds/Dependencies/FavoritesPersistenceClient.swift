import CatBreedsCore
import ComposableArchitecture
import Foundation
import SwiftData

enum PersistenceError: Error, Equatable {
    case failed
}

struct FavoritesPersistenceClient {
    var fetchFavorites: @Sendable () async throws -> [Breed]
    var saveFavorite: @Sendable (Breed) async throws -> Void
    var removeFavorite: @Sendable (Breed.ID) async throws -> Void
}

extension FavoritesPersistenceClient: DependencyKey {
    static let liveValue = FavoritesPersistenceClient(
        fetchFavorites: {
            try await MainActor.run {
                let context = ModelContext(SwiftDataStack.shared)
                let descriptor = FetchDescriptor<FavoriteBreedEntity>(
                    sortBy: [SortDescriptor(\.name)]
                )

                return try context
                    .fetch(descriptor)
                    .map(\.domainModel)
            }
        },
        saveFavorite: { breed in
            try await MainActor.run {
                let context = ModelContext(SwiftDataStack.shared)
                let id = breed.id

                var descriptor = FetchDescriptor<FavoriteBreedEntity>(
                    predicate: #Predicate { $0.id == id }
                )
                descriptor.fetchLimit = 1

                if let existing = try context.fetch(descriptor).first {
                    context.delete(existing)
                }

                context.insert(FavoriteBreedEntity(breed: breed))
                try context.save()
            }
        },
        removeFavorite: { id in
            try await MainActor.run {
                let context = ModelContext(SwiftDataStack.shared)

                var descriptor = FetchDescriptor<FavoriteBreedEntity>(
                    predicate: #Predicate { $0.id == id }
                )
                descriptor.fetchLimit = 1

                if let existing = try context.fetch(descriptor).first {
                    context.delete(existing)
                    try context.save()
                }
            }
        }
    )

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
