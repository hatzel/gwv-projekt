import FastRNG

let r: RandomGenerator

// Commandline seed
if Process.arguments.count > 1 {
    r = Xorshift1024StarGenerator(seed: UInt64(Process.arguments[1], radix: 36)!)
    print("Using seed: \(Process.arguments[1])")
} else {
    r = FastRNG.defaultGenerator
}

var solvedBoard = BoardState()
var startBoard = solvedBoard.permutingBoard(steps: 50000, random: r)

print("--- target ---")
print(solvedBoard)
print("--- start ---")
print(startBoard)
print("--- distance ---")
let initialDistance = startBoard.sumOfManhattanDistancesTo(solvedBoard)
print(initialDistance)

let solver = BoardSolver(startBoard: startBoard, targetBoard: solvedBoard)

switch solver.solve() {
    case .Found(let path):
        print("found path of length \(path.count)")
        let strings: [String] = path.map{String($0)}
        print("Move Sequence: " + strings.joinWithSeparator(", ") + ".")
    default:
        print("not found")
}
