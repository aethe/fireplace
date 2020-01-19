// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hearth",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "Hearth",
            targets: ["Hearth"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Hearth",
            dependencies: []
        )
    ]
)
