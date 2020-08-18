// swift-tools-version:5.2

import PackageDescription
import Foundation

let package = Package(
    name: "Backendless",
    products: [
        .library(name: "Backendless", targets: ["SwiftSDK"]),
    ],
    dependencies: [
        .package(name: "SocketIO", url: "https://github.com/socketio/socket.io-client-swift", from: "15.2.0")
    ],
    targets: [
        .target(name: "SwiftSDK", dependencies: ["SocketIO"]),
        .testTarget(name: "SwiftSDKTests", dependencies: ["SwiftSDK"]),
    ]
)
