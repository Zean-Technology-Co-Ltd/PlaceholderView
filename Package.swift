// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlaceholderView",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "PlaceholderView",
            targets: ["PlaceholderView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/Zean-Technology-Co-Ltd/FoundationEx.git", from: "1.0.0"),
    ],
    targets: [
       .target(
            name: "PlaceholderView",
            dependencies: [
                "SnapKit",
                "FoundationEx"
              ],
            path: "PlaceholderView"),
        .testTarget(
            name: "PlaceholderViewTests",
            dependencies: ["PlaceholderView"]),
    ]
)
