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
            targets: ["Paystack/Transactions"])
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
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["Paystack", "Paystack/Transactions"],
            resources: [
                .copy("API/Transactions/Resources/ChargeAuthorization.json"),
                .copy("API/Transactions/Resources/CheckAuthorization.json"),
                .copy("API/Transactions/Resources/ExportTransactions.json"),
                .copy("API/Transactions/Resources/FetchTransaction.json"),
                .copy("API/Transactions/Resources/InitializeTransaction.json"),
                .copy("API/Transactions/Resources/ListTransactions.json"),
                .copy("API/Transactions/Resources/PartialDebit.json"),
                .copy("API/Transactions/Resources/TransactionTotals.json"),
                .copy("API/Transactions/Resources/VerifyTransaction.json"),
                .copy("API/Transactions/Resources/ViewTransactionTimeline.json"),
            ])
    ]
)
