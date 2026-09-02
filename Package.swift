// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KepubifyMacApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "KepubifyMacApp",
            targets: ["KepubifyMacApp"]
        )
    ],
    targets: [
        .target(
            name: "KepubifyMacApp",
            dependencies: [],
            path: "Sources",
            exclude: [],
            resources: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "KepubifyMacAppTests",
            dependencies: ["KepubifyMacApp"],
            path: "Tests",
            exclude: [],
            resources: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
