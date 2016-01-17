import FastRNG

private struct SearchNode {
    let prio: Int
    let state: BoardState
    let path: [BoardState.MoveDirection]
}

private func < (lhs: SearchNode, rhs: SearchNode) -> Bool { return lhs.prio < rhs.prio }
private func == (lhs: SearchNode, rhs: SearchNode) -> Bool { return lhs.prio == rhs.prio }

extension SearchNode: Comparable {}

class BoardSolver {
    let startBoard: BoardState
    let targetBoard: BoardState

    init(startBoard: BoardState, targetBoard: BoardState = BoardState()) {
        self.startBoard = startBoard
        self.targetBoard = targetBoard
    }


    enum SearchResult {
        case NotFound
        case Found([BoardState.MoveDirection])
    }


    func solve() -> SearchResult {
        let initialDistance = startBoard.sumOfManhattanDistancesTo(targetBoard)
        var q = PriorityQueue(ascending: true, startingValues: [SearchNode(prio: initialDistance, state: startBoard, path: [])])
        var visited: Set<BoardState> = [startBoard]

        var result: SearchResult = .NotFound
        queueLoop: while !q.isEmpty {
            let node = q.pop()!
            let state = node.state
            // print(">>> processing state:")
            // print(state)
            for dir in BoardState.MoveDirection.allDirections {
                do {
                    let next = try state.movingEmptyTile(dir)
                    guard !visited.contains(next) else { continue }
                    visited.insert(next)

                    let path = node.path + [dir]
                    guard next != targetBoard else {
                        result = .Found(path)
                        break queueLoop
                    }
                    let dist = next.sumOfManhattanDistancesTo(targetBoard)
                    // print(Repeat(count: dist, repeatedValue: "█").joinWithSeparator("") + " - \(dist)")
                    q.push(SearchNode(prio: dist + path.count, state: next, path: path))
                } catch { }
            }
        }

        return result
    }
}
