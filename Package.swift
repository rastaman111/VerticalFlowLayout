// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VerticalFlowLayout",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "VerticalFlowLayout", targets: ["VerticalFlowLayout"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VerticalFlowLayout",
            dependencies: [],
            path: "Sources")
    ]
)
