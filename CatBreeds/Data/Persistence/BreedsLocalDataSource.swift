import Foundation
import SwiftData

protocol BreedsLocalDataSource {
    func saveBreeds(_ breeds: [Breed], page: Int) async throws
    func fetchBreeds(page: Int) async throws -> [Breed]
}

struct SwiftDataBreedsLocalDataSource: BreedsLocalDataSource {
    func saveBreeds(_ breeds: [Breed], page: Int) async throws {
        try await MainActor.run {
            let context = ModelContext(SwiftDataStack.shared)

            let descriptor = FetchDescriptor<CachedBreedEntity>(
                predicate: #Predicate { $0.page == page }
            )

            let existing = try context.fetch(descriptor)
            existing.forEach { context.delete($0) }

            breeds.forEach {
                context.insert(CachedBreedEntity(breed: $0, page: page))
            }

            try context.save()
        }
    }

    func fetchBreeds(page: Int) async throws -> [Breed] {
        try await MainActor.run {
            let context = ModelContext(SwiftDataStack.shared)

            let descriptor = FetchDescriptor<CachedBreedEntity>(
                predicate: #Predicate { $0.page == page },
                sortBy: [SortDescriptor(\.name)]
            )

            return try context.fetch(descriptor).map(\.domainModel)
        }
    }
}
