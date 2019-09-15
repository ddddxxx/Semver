// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Semver",
    products: [
        .library(
            name: "Semver",
            targets: ["Semver"]),
    ],
    targets: [
        .target(
            name: "Semver",
            dependencies: []),
        .testTarget(
            name: "SemverTests",
            dependencies: ["Semver"]),
    ]
)
