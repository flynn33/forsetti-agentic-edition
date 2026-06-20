// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ForsettiGovernance",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "forsetti-governance", targets: ["ForsettiGovernanceCLI"]),
        .library(name: "GovernanceContracts", targets: ["GovernanceContracts"]),
        .library(name: "GovernanceCore", targets: ["GovernanceCore"]),
        .library(name: "GovernanceApple", targets: ["GovernanceApple"])
    ],
    targets: [
        .target(name: "GovernanceContracts"),
        .target(
            name: "GovernanceCore",
            dependencies: ["GovernanceContracts"]
        ),
        .target(
            name: "GovernanceApple",
            dependencies: ["GovernanceContracts", "GovernanceCore"]
        ),
        .executableTarget(
            name: "ForsettiGovernanceCLI",
            dependencies: ["GovernanceContracts", "GovernanceCore", "GovernanceApple"]
        ),
        .testTarget(
            name: "GovernanceCoreTests",
            dependencies: ["GovernanceContracts", "GovernanceCore", "GovernanceApple"]
        )
    ]
)
