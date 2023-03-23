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
            name: "Transactions",
            targets: ["Transactions"]),
        .library(
            name: "Checkout",
            targets: ["Checkout"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PaystackSDK",
            dependencies: [],
            path: "Sources/PaystackSDK/Core"),
        .target(
            name: "Transactions",
            dependencies: ["PaystackSDK"],
            path: "Sources/PaystackSDK/API/Transactions"),
        .target(
            name: "Checkout",
            dependencies: ["PaystackSDK"],
            path: "Sources/PaystackSDK/API/Checkout"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["PaystackSDK", "Transactions", "Checkout"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json")
            ])
    ]
)
