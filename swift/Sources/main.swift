import FastRNG

let r: RandomGenerator

var solvedBoard = BoardState()

var startBoard = solvedBoard


// Commandline seed
if Process.arguments.count > 1 {
    r = Xorshift1024StarGenerator(seed: UInt64(Process.arguments[1], radix: 36)!)
    print("Using seed: \(Process.arguments[1])")
} else {
    r = FastRNG.defaultGenerator
}

let directions: [BoardState.MoveDirection] = [.Up, .Down, .Left, .Right]
for i in 0..<50000 {
    let d = r.sample(directions)
    do {
        try startBoard.moveEmptyTile(d)
    } catch {
    }
}

print("--- target ---")
print(solvedBoard)
print("--- start ---")
print(startBoard)
print("--- distance ---")
let initialDistance = startBoard.sumOfManhattanDistancesTo(solvedBoard)
print(initialDistance)


struct SearchNode {
    let prio: Int
    let state: BoardState
    let path: [BoardState.MoveDirection]
}

func < (lhs: SearchNode, rhs: SearchNode) -> Bool { return lhs.prio < rhs.prio }
func == (lhs: SearchNode, rhs: SearchNode) -> Bool { return lhs.prio == rhs.prio }

extension SearchNode: Comparable {}


var q = PriorityQueue(ascending: true, startingValues: [SearchNode(prio: initialDistance, state: startBoard, path: [])])

var visited: Set<BoardState> = [startBoard]


enum SearchResult {
    case Found([BoardState.MoveDirection])
    case NotFound
}

var result: SearchResult = .NotFound
queueLoop: while !q.isEmpty {
    let node = q.pop()!
    let state = node.state
    // print(">>> processing state:")
    // print(state)
    for dir in directions {
        do {
            let next = try state.movingEmptyTile(dir)
            guard !visited.contains(next) else { continue }
            visited.insert(next)

            let path = node.path + [dir]
            guard next != solvedBoard else {
                result = .Found(path)
                break queueLoop
            }
            let dist = next.sumOfManhattanDistancesTo(solvedBoard)
            // print(Repeat(count: dist, repeatedValue: "█").joinWithSeparator("") + " - \(dist)")
            q.push(SearchNode(prio: dist + path.count, state: next, path: path))
        } catch { }
    }
}
switch result {
    case .Found(let path):
        print("found path of length \(path.count)")
        let strings: [String] = path.map{String($0)}
        print("Move Sequence: " + strings.joinWithSeparator(", ") + ".")
    default:
        print("not found")
}
