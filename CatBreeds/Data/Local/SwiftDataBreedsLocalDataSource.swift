import CatBreedsCore
import Foundation
import SwiftData

struct SwiftDataBreedsLocalDataSource: BreedsLocalDataSource {
    private let container: ModelContainer
    private let imageCache: ImageCacheDataSource

    init(
        container: ModelContainer,
        imageCache: ImageCacheDataSource = NukeImageCacheDataSource()
    ) {
        self.container = container
        self.imageCache = imageCache
    }

    func saveBreeds(_ breeds: [Breed], page: Int) async throws {
        try await MainActor.run {
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<CachedBreedEntity>(
                predicate: #Predicate { $0.page == page }
            )

            let existing = try context.fetch(descriptor)
            existing.forEach { context.delete($0) }

            for (index, breed) in breeds.enumerated() {
                context.insert(
                    CachedBreedEntity(
                        breed: breed,
                        page: page,
                        position: index
                    )
                )
            }

            try context.save()
        }
    }

    func fetchBreeds(page: Int) async throws -> [Breed] {
        try await MainActor.run {
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<CachedBreedEntity>(
                predicate: #Predicate { $0.page == page },
                sortBy: [SortDescriptor(\.position)]
            )

            return try context.fetch(descriptor).map(\.domainModel)
        }
    }

    func deleteAllBreeds() async throws {
        try await MainActor.run {
            let context = ModelContext(container)
            try context.delete(model: CachedBreedEntity.self)
            try context.save()
        }
        imageCache.removeAll()
    }
}
