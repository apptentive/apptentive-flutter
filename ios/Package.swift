// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apptentive_flutter",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "apptentive-flutter", targets: ["apptentive_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/apptentive/apptentive-kit-ios", from: "7.1.0"),
    ],
    targets: [
        .target(
            name: "apptentive_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "ApptentiveKit", package: "apptentive-kit-ios"),
            ],
            path: "Classes"
        )
    ]
)
