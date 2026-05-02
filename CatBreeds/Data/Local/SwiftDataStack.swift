import CatBreedsCore
import SwiftData

enum SwiftDataStack {
    @MainActor
    static let shared: ModelContainer = {
        let schema = Schema([
            FavoriteBreedEntity.self,
            CachedBreedEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Schema migration failure or corrupt store — attempt in-memory fallback
            // to keep the app functional rather than crashing immediately.
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            if let container = try? ModelContainer(for: schema, configurations: [fallback]) {
                return container
            }
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()
}
