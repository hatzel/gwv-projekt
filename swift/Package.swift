import PackageDescription

let package = Package(
    name: "SlidingPuzzle",
    dependencies: [
        .Package(url: "https://github.com/Ahti/FastRNG.git", majorVersion: 0, minor: 0),
    ]
)
