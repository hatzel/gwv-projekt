import FastRNG
import Glibc

private struct SearchNode {
    let prio: Int
    let state: PackedBoardState
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


    public func solve(dbFiles: [String]) -> SearchResult {
        guard startBoard != targetBoard else {
            return .Found([])
        }

        let initialDistance = startBoard.sumOfManhattanDistancesTo(targetBoard)
        var q = PriorityQueue(ascending: true, startingValues: [SearchNode(prio: initialDistance, state: startBoard.packed, path: [])])
        var visited: Set<PackedBoardState> = [startBoard.packed]
        var pdbs: [PatternDatabase] = Array()
        var pdb_used = 0
        var manhatten_used = 0
        for db in dbFiles {
            do {
                 let pdb = try PatternDatabase(filename: db)
                 pdbs.append(pdb)
            } catch {
                fatalError("No Pattern Database exists")
            }
        }
        print("tested nodes: 1", terminator: "")

        queueLoop: while !q.isEmpty {
            let node = q.pop()!
            let state = BoardState(packed: node.state)

            for dir in BoardState.MoveDirection.allDirections {
                do {
                    let next = try state.movingEmptyTile(dir)

                    guard !visited.contains(next.packed) else { continue }
                    visited.insert(next.packed)

                    guard next != targetBoard else {
                        return .Found(node.path + [dir])
                    }

                    visitedNodes += 1
                    if visitedNodes % 10000 == 0 {
                        print("\u{1b}[2K\rtested nodes: \(visitedNodes), Manhatten usages: \(manhatten_used), PDB used: \(pdb_used)", terminator: "")
                        fflush(stdout)
                    }

                    let path = node.path + [dir]
                    let man = next.sumOfManhattanDistancesTo(targetBoard)
                    var dist: Int = man
                    for (i, pdb) in pdbs.enumerate() {
                        if let pdb_heuristic = pdb.search(Pattern(boardState: next, relevantElements: pdb.relevantElements)) {
                            dist = max(dist, Int(pdb_heuristic))
                            // print("Manhatten: \(dist), PDB-\(i): \(pdb_heuristic)")
                        }
                    }
                    if dist != man {
                        pdb_used += 1
                    } else {
                        manhatten_used += 1
                    }

                    q.push(SearchNode(prio: dist + path.count, state: next.packed, path: path))
                } catch { }
            }
        }

        return .NotFound
    }
}
