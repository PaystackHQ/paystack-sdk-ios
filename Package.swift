// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PaystackSDK",
    platforms: [.iOS(.v12), .macOS(.v10_15)],
    products: [
        .library(
            name: "PaystackSDK",
            targets: ["Paystack"]),
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
            name: "Paystack",
            dependencies: [],
            path: "Sources/PaystackSDK/Core"),
        .target(
            name: "Transactions",
            dependencies: ["Paystack"],
            path: "Sources/PaystackSDK/API/Transactions"),
        .target(
            name: "Checkout",
            dependencies: ["Paystack"],
            path: "Sources/PaystackSDK/API/Checkout"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["Paystack", "Transactions", "Checkout"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json")
            ])
    ]
)
