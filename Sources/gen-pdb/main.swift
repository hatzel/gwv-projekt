import SlidingPuzzle
import Commander

class RelevantElements {
    static let fringe = Array<UInt8>([0,1,2,3,4,8,12])
    static let corner = Array<UInt8>([0,1,2,3,5,6,7])
}

let main = command(
    Option("size", 100_000),
    VaradicArgument<String>("patterns", description: "Space seperated pattern names to generate")
) { size, pattern_strings in
    var patterns: [[UInt8]] = []
    if pattern_strings.count == 0 {
        patterns.append(RelevantElements.fringe)
    }
    for p in pattern_strings {
        switch p {
            case "fringe":
                patterns.append(RelevantElements.fringe)
            case "corner":
                patterns.append(RelevantElements.corner)
            default:
                continue
        }
    }
    let pf = PatternFinder(startBoard: BoardState())
    pf.search(size, patternDefinitions: patterns)
}

main.run()
