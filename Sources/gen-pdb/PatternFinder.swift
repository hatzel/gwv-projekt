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

    func fitsPattern(state: BoardState) -> Bool {
        return false
    }

    public func search(size: Int) {
        var q = FifoQueue<PatternSearchNode>()
        q.push(PatternSearchNode(cost: 0, state: self.startBoard.packed))
        var visited: Set<PackedBoardState> = [startBoard.packed]
        var results: Dictionary<PackedPattern, UInt8> = [:]
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
                        if results.count > size {
                            break queueLoop
                        }
                        print("\u{1b}[2K\rIteration: \(i), Queue size: \(q.count) Patterns found: \(results.count), Visited: \(visited.count), CurrentDepth: \(cost)", terminator: "")
                        fflush(stdout)
                    }
                    let next = try state.movingEmptyTile(dir)
                    guard !visited.contains(next.packed) else { continue }
                    visited.insert(next.packed)

                    let pattern = Pattern(boardState: next, relevantElements: [0,1,2,3,4,8,12]).packed
                    results[pattern] = min(results[pattern] ?? UInt8.max, cost)

                    q.push(PatternSearchNode(cost: cost + 1, state: next.packed))
                } catch { }
            }
        }
        var packed_results = results.map {(pattern: PackedPattern, cost: UInt8)-> UInt64 in
            return UInt64(cost) | pattern
        }
        var sorted_results = packed_results.sort()
        sorted_results.withUnsafeMutableBufferPointer({ (inout data: UnsafeMutableBufferPointer<UInt64>) in
            let dataObject = NSData(bytesNoCopy: data.baseAddress, length: data.count * sizeof(UInt64))
            do {
                try dataObject.writeToFile("fringe.data", options: [NSDataWritingOptions.DataWritingWithoutOverwriting])
            } catch {
                fatalError("Can't write Pattern Database to File")
            }
        })
    }
}
