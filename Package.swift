// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PaystackSDK",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "PaystackCore",
            targets: ["PaystackCore"]),
        .library(
            name: "PaystackUI",
            targets: ["PaystackUI"])
    ],
    dependencies: [.package(url: "https://github.com/pusher/pusher-websocket-swift.git", from: "10.1.0")],
    targets: [
        .target(
            name: "PaystackCore",
            dependencies: [.product(name: "PusherSwift", package: "pusher-websocket-swift")],
            path: "Sources/PaystackSDK",
            resources: [
                .process("Versioning/versions.plist")
            ]),
        .target(
            name: "PaystackUI",
            dependencies: ["PaystackCore"],
            path: "Sources/PaystackUI",
            resources: [.process("Design/FontAssets")]),
        .testTarget(
            name: "PaystackSDKTests",
            dependencies: ["PaystackCore", "PaystackUI"],
            resources: [
                .copy("API/Transactions/Resources/VerifyAccessCode.json"),
                .copy("API/Charge/Resources/ChargeAuthenticationResponse.json"),
                .copy("API/Other/Resources/AddressStatesResponse.json")
            ])
    ]
)
