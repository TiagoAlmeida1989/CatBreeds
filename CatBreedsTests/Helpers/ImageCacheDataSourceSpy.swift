@testable import CatBreeds

final class ImageCacheDataSourceSpy: ImageCacheDataSource {
    private(set) var removeAllCallCount = 0

    func removeAll() {
        removeAllCallCount += 1
    }
}
