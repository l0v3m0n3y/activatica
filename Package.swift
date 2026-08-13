// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "activatica",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "activatica", targets: ["activatica"]),
    ],
    targets: [
        .target(
            name: "activatica",
            path: "src"
        ),
    ]
)
