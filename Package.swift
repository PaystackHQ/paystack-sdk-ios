// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PaystackSDK",
    platforms: [.iOS(.v12), .macOS(.v10_15)],
    products: [
        .library(
            name: "PaystackSDK",
            targets: ["PaystackSDK"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PaystackSDK",
            dependencies: [],
            path: "Sources/PaystackSDK"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["PaystackSDK"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json")
            ])
    ]
)
