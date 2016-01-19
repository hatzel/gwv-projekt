import PackageDescription

let package = Package(
    name: "SlidingPuzzleApp",
    targets: [
        Target(
            name: "puzzler",
            dependencies: [.Target(name: "SlidingPuzzle")]),
        Target(name: "SlidingPuzzle")
    ],
    dependencies: [
        .Package(url: "https://github.com/Ahti/FastRNG.git", majorVersion: 0),
        .Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0),
    ]
)
