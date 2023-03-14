// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PaystackSDK",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "PaystackSDK",
            targets: ["Paystack"]),
        .library(
            name: "PaystackSDKTransactions",
            targets: ["PaystackTransactions"]),
        .library(
            name: "PaystackSDKCheckout",
            targets: ["PaystackCheckout"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Paystack",
            dependencies: [],
            path: "Sources/PaystackSDK/Core"),
        .target(
            name: "PaystackTransactions",
            dependencies: ["Paystack"],
            path: "Sources/PaystackSDK/API/Transactions"),
        .target(
            name: "PaystackCheckout",
            dependencies: ["Paystack"],
            path: "Sources/PaystackSDK/API/Checkout"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["Paystack", "PaystackTransactions", "PaystackCheckout"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json")
            ])
    ]
)
