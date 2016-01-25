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
        let pdb: PatternDatabase
        do {
             pdb = try PatternDatabase(filename: "fringe.data")
        } catch {
            print("No pdb found.")
            fatalError("No Pattern Database exists")
        }
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
                    let man = next.sumOfManhattanDistancesTo(targetBoard)
                    var dist: Int = man
                    if let pdb_heuristic = pdb.search(Pattern(boardState: next, relevantElements: [0,1,2,3,4,8,12])) {
                        // if Int(pdb_heuristic) > dist {
                        //     print("MD: \(dist), pdb: \(pdb_heuristic)")
                        // }
                        dist = max(man, Int(pdb_heuristic))
                    }
                    // print(Repeat(count: dist, repeatedValue: "█").joinWithSeparator("") + " - \(dist)")
                    q.push(SearchNode(prio: dist + path.count, state: next, path: path))
                } catch { }
            }
        }

        return .NotFound
    }
}
