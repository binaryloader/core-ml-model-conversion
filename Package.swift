// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CoreMLDemo",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CoreMLDemo",
            targets: ["CoreMLDemo"]
        )
    ],
    targets: [
        .target(
            name: "CoreMLDemo",
            path: "Sources/CoreMLDemo"
        ),
        .testTarget(
            name: "CoreMLDemoTests",
            dependencies: ["CoreMLDemo"],
            path: "Tests/CoreMLDemoTests"
        )
    ]
)
