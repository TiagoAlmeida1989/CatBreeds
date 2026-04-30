import Foundation
import Nuke

enum ImagePipelineClient {
    static func configure() {
        ImagePipeline.shared = ImagePipeline {
            $0.dataCache = try? DataCache(name: "cat-breeds-images")
            $0.imageCache = ImageCache()
            $0.isTaskCoalescingEnabled = true
            $0.isRateLimiterEnabled = true
        }
    }
}
