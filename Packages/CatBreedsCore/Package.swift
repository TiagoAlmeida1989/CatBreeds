// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CatBreedsCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "CatBreedsCore", targets: ["CatBreedsCore"]),
    ],
    targets: [
        .target(
            name: "CatBreedsCore",
            path: "Sources/CatBreedsCore"
        )
    ]
)
