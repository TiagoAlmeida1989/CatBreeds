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
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()
}
