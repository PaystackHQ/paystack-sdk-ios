// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PaystackSDK",
    platforms: [.iOS(.v12), .macOS(.v10_15)],
    products: [
        .library(
            name: "PaystackSDK",
            targets: ["PaystackSDK"]),
        .library(
            name: "PaystackUI",
            targets: ["PaystackUI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PaystackSDK",
            dependencies: [],
            path: "Sources/PaystackSDK"),
        .target(
            name: "PaystackUI",
            dependencies: ["PaystackSDK"],
            path: "Sources/PaystackUI"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["PaystackSDK", "PaystackUI"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json")
            ])
    ]
)
