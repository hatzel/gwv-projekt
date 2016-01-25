import Foundation
import SlidingPuzzle
import Glibc
import SimpleQueue

struct PatternSearchNode: Hashable {
    let cost: UInt8
    let state: PackedBoardState

    var hashValue: Int {
        get {
            return state.hashValue
        }
    }
}

func ==(lhs: PatternSearchNode, rhs: PatternSearchNode) -> Bool {
    return lhs.state == rhs.state && lhs.cost == rhs.cost
}


public class PatternFinder {
    let startBoard: BoardState

    public init(startBoard: BoardState) {
        self.startBoard = startBoard
    }


    enum SearchResult {
        case NotFound
        case Found([BoardState.MoveDirection])
    }

    private func writeToFile(sortedResults: Array<UInt64>, filename: String) {
        sortedResults.withUnsafeBufferPointer({ (data: UnsafeBufferPointer<UInt64>) in
            let dataObject = NSData(bytesNoCopy: UnsafeMutablePointer<UInt64>(data.baseAddress), length: data.count * sizeof(UInt64))
            do {
                try dataObject.writeToFile(filename, options: [NSDataWritingOptions.DataWritingWithoutOverwriting])
            } catch {
                fatalError("Can't write Pattern Database to File")
            }
        })
    }

    public func search(size: Int, patternDefinitions: Array<Array<Int>>=[[0,1,2,3,4,8,12]]) {
        var q = FifoQueue<PatternSearchNode>()
        q.push(PatternSearchNode(cost: 0, state: self.startBoard.packed))
        var visited: Set<PackedBoardState> = [startBoard.packed]
        var results: Array<Dictionary<PackedPattern, UInt8>> = Array(count: patternDefinitions.count, repeatedValue: [:])
        var i = 0
        queueLoop: while !q.isEmpty {
            let node = q.pop()!
            let state = BoardState(packed: node.state)
            let cost = node.cost
            // print(">>> processing state:")
            // print(state)
            // print(node)
            for dir in BoardState.MoveDirection.allDirections {
                do {
                    i += 1
                    if i % 100_000 == 0 {
                        var greater = true
                        for r in results {
                            if r.count < size {
                                greater = false
                            }
                        }
                        if greater {
                            break queueLoop
                        }
                        print("\u{1b}[2K\rIteration: \(i), Queue size: \(q.count) Patterns found: \(results[0].count), Visited: \(visited.count), CurrentDepth: \(cost)", terminator: "")
                        fflush(stdout)
                    }
                    let next = try state.movingEmptyTile(dir)
                    guard !visited.contains(next.packed) else { continue }
                    visited.insert(next.packed)

                    for (i, els) in patternDefinitions.enumerate() {
                        let pattern = Pattern(boardState: next, relevantElements: els).packed
                        results[i][pattern] = min(results[i][pattern] ?? UInt8.max, cost)
                    }

                    q.push(PatternSearchNode(cost: cost + 1, state: next.packed))
                } catch { }
            }
        }
        let packed_results = results.map({ $0.map({(pattern: PackedPattern, cost: UInt8)-> UInt64 in
            return UInt64(cost) | pattern
        })})
        let sorted_results = packed_results.map({ $0.sort() })
        for (i, sorted) in sorted_results.enumerate() {
            writeToFile(sorted, filename: "\(i)-fringe.data")
        }
    }
}
