import Nuke

protocol ImageCacheDataSource {
    func removeAll()
}

struct NukeImageCacheDataSource: ImageCacheDataSource {
    func removeAll() {
        ImagePipeline.shared.cache.removeAll()
    }
}
