import Foundation
import SwiftUI

@main
struct AppEntry {
    static func main() {
#if DEBUG
        if ProcessInfo.processInfo.environment["UI_TESTING"] == "1" {
            UITestingApp.main()
            return
        }
#endif
        CatBreedsApp.main()
    }
}
