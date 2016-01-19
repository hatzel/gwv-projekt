import FastRNG
import Glibc

private struct SearchNode {
    let prio: Int
    let state: BoardState
    let path: [BoardState.MoveDirection]
}

private func < (lhs: SearchNode, rhs: SearchNode) -> Bool { return lhs.prio < rhs.prio }
private func == (lhs: SearchNode, rhs: SearchNode) -> Bool { return lhs.prio == rhs.prio }

extension SearchNode: Comparable {}

public class BoardSolver {
    let startBoard: BoardState
    let targetBoard: BoardState

    var visitedNodes = 0

    public init(startBoard: BoardState, targetBoard: BoardState = BoardState()) {
        self.startBoard = startBoard
        self.targetBoard = targetBoard
    }


    public enum SearchResult {
        case NotFound
        case Found([BoardState.MoveDirection])
    }


    public func solve() -> SearchResult {
        guard startBoard != targetBoard else {
            return .Found([])
        }

        let initialDistance = startBoard.sumOfManhattanDistancesTo(targetBoard)
        var q = PriorityQueue(ascending: true, startingValues: [SearchNode(prio: initialDistance, state: startBoard, path: [])])
        var visited: Set<BoardState> = [startBoard]

        print("tested nodes: 1", terminator: "")

        queueLoop: while !q.isEmpty {
            let node = q.pop()!
            let state = node.state

            for dir in BoardState.MoveDirection.allDirections {
                do {
                    let next = try state.movingEmptyTile(dir)
                    
                    guard !visited.contains(next) else { continue }
                    visited.insert(next)

                    guard next != targetBoard else {
                        return .Found(node.path + [dir])
                    }

                    visitedNodes += 1
                    if visitedNodes % 10000 == 0 {
                        print("\u{1b}[2K\rtested nodes: \(visitedNodes)", terminator: "")
                        fflush(stdout)
                    }

                    let path = node.path + [dir]
                    let dist = next.sumOfManhattanDistancesTo(targetBoard)
                    // print(Repeat(count: dist, repeatedValue: "█").joinWithSeparator("") + " - \(dist)")
                    q.push(SearchNode(prio: dist + path.count, state: next, path: path))
                } catch { }
            }
        }

        return .NotFound
    }
}
