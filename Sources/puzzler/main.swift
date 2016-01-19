import SlidingPuzzle
import Commander
import FastRNG

func preflightDebugOutput(target target: BoardState, start: BoardState) -> String {
    let dist = start.sumOfManhattanDistancesTo(target)
    var str = "--- target ---\n"
    str += String(target)
    str += "\n--- start ---\n"
    str += String(start)
    str += "\n--- distance ---\n"
    str += String(dist)
    return str
}

func resultOutputForResult(res: BoardSolver.SearchResult) -> String {
    switch res {
    case .Found(let path):
        let str = "found path of length \(path.count)"
        let strings: [String] = path.map { String($0) }
        return str + "\n" + "Move Sequence: " + strings.joinWithSeparator(", ") + "."
    default:
        return "not found"
    }
}

let main = command(
    Option("seed", "")
) { seed in
    let r: RandomGenerator

    switch seed {
    case "": r = FastRNG.defaultGenerator
    case let s: r = Xorshift1024StarGenerator(seed: UInt64(s, radix: 36)!)
    }

    var solvedBoard = BoardState()

    var startBoard = solvedBoard.permutingBoard(steps: 500, random: r)
    print(preflightDebugOutput(target: solvedBoard, start: startBoard))

    let solver = BoardSolver(startBoard: startBoard, targetBoard: solvedBoard)

    // print(resultOutputForResult(solver.solve()))


    let res = solver.solve()



    guard case .Found(let path) = res
        else { fatalError("No result found") }

    print(resultOutputForResult(res))

    var boardToSolve = startBoard

    for d in path {
        print(boardToSolve)
        print("--- \(d) ---")
        try! boardToSolve.moveEmptyTile(d)
    }
}

main.run()
