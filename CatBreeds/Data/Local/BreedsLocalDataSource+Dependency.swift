import ComposableArchitecture
import Foundation

private enum BreedsLocalDataSourceKey: DependencyKey {
    static var liveValue: any BreedsLocalDataSource {
        SwiftDataBreedsLocalDataSource(container: SwiftDataStack.shared)
    }
}

extension DependencyValues {
    var breedsLocalDataSource: any BreedsLocalDataSource {
        get { self[BreedsLocalDataSourceKey.self] }
        set { self[BreedsLocalDataSourceKey.self] = newValue }
    }
}
