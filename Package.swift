// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "composable-avplayer",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "ComposableAVPlayer",
            targets: ["ComposableAVPlayer"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "1.7.0"))
    ],
    targets: [
        .target(
            name: "ComposableAVPlayer",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "ComposableAVPlayerTests",
            dependencies: ["ComposableAVPlayer"]
        ),
    ]
)
