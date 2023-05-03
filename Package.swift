// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PaystackSDK",
    platforms: [.iOS(.v12), .macOS(.v11)],
    products: [
        .library(
            name: "PaystackCore",
            targets: ["PaystackCore"]),
        .library(
            name: "PaystackUI",
            targets: ["PaystackUI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PaystackCore",
            dependencies: [],
            path: "Sources/PaystackSDK",
            resources: [
                .process("Versioning/versions.plist")
            ]),
        .target(
            name: "PaystackUI",
            dependencies: ["PaystackCore"],
            path: "Sources/PaystackUI"),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["PaystackCore", "PaystackUI"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Checkout/Resources/RequestInline.json"),
                .copy("API/Charge/Resources/ChargeAuthenticationResponse.json")
            ])
    ]
)
