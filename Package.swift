// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ghostty-clip",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ghostty-clip",
            path: "Sources/GhosttyClip"
        ),
        .testTarget(
            name: "GhosttyClipTests",
            dependencies: ["ghostty-clip"],
            path: "Tests"
        )
    ]
)
