// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Fit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "Fit",
            targets: ["Fit"]
        ),
    ],
    targets: [
        .target(
            name: "Fit"
        ),
        .testTarget(
            name: "FitTests",
            dependencies: ["Fit"]
        ),
    ]
)
