import CatBreedsCore
import Foundation
import SwiftData

struct SwiftDataFavoritesLocalDataSource: FavoritesLocalDataSource {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetchFavorites() async throws -> [Breed] {
        try await MainActor.run {
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<FavoriteBreedEntity>(
                sortBy: [SortDescriptor(\.name)]
            )
            return try context.fetch(descriptor).map(\.domainModel)
        }
    }

    func saveFavorite(_ breed: Breed) async throws {
        try await MainActor.run {
            let context = ModelContext(container)
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
    }

    func removeFavorite(id: Breed.ID) async throws {
        try await MainActor.run {
            let context = ModelContext(container)

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
}
