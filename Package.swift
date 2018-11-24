// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ExampleResponseApp",
    products: [
        .executable(name: "ExampleResponseApp", targets: ["ExampleResponseApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/amzn/smoke-framework.git", .upToNextMajor(from: "0.6.0")),
    ],
    targets: [
        .target(
            name: "ExampleResponseApp",
            dependencies: ["SmokeOperationsHTTP1"]),
        .testTarget(
            name: "ExampleResponseAppTests",
            dependencies: ["ExampleResponseApp"]),
    ]
)
