// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "skip-xml",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipXML", type: .dynamic, targets: ["SkipXML"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.9.4"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "0.7.0"),
    ],
    targets: [
        .target(name: "SkipXML", dependencies: [
            .product(name: "SkipFoundation", package: "skip-foundation")
        ], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipXMLTests", dependencies: [
            "SkipXML",
            .product(name: "SkipTest", package: "skip")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
