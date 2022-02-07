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
            name: "PaystackSDK/Transactions",
            targets: ["Paystack/Transactions"]),
        .library(
            name: "PaystackSDK/Checkout",
            targets: ["Paystack/Checkout"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Paystack",
            dependencies: [],
            path: "Sources/PaystackSDK/Core"),
        .target(
            name: "Paystack/Transactions",
            dependencies: ["Paystack"],
            path: "Sources/PaystackSDK/API/Transactions"),
        .target(
            name: "Paystack/Checkout",
            dependencies: ["Paystack"],
            path: "Sources/PaystackSDK/API/Checkout"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["Paystack", "Paystack/Transactions", "Paystack/Checkout"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json")
            ])
    ]
)
