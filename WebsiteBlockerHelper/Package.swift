// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "WebsiteBlockerHelper",
    platforms: [.macOS(.v12)],
    products: [
    	.executable(name: "WebsiteBlockerHelper", targets: ["WebsiteBlockerHelper"])
    ],
    targets: [
        .executableTarget(name: "WebsiteBlockerHelper",dependencies: [])
    ]
)
