// swift-tools-version:5.9
// The swift-tools-version declares the minimum Swift version supported by this package.

import PackageDescription

let package = Package(
    name: "KepubifyMacApp",
    platforms: [
        .macOS(".v12")
    ],
    products: [
        .executable(
            name: "KepubifyMacApp",
            targets: ["KepubifyMacApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KepubifyMacApp",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "KepubifyMacAppTests",
            dependencies: ["KepubifyMacApp"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
