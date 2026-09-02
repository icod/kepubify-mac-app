// swift-tools-version:5.9
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
        .target(
            name: "KepubifyMacApp",
            dependencies: [],
            path: "Sources",
            exclude: [],
            resources: [],
            publicHeadersPath: "",
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ],
            linkerSettings: nil
        ),
        .testTarget(
            name: "KepubifyMacAppTests",
            dependencies: ["KepubifyMacApp"],
            path: "Tests",
            exclude: [],
            resources: [],
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ],
            linkerSettings: nil
        )
    ],
    swiftLanguageModes: [.v5]
)
