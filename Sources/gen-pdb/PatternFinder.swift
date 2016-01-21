import Foundation
import SlidingPuzzle
import Glibc

struct PatternSearchNode: Hashable {
    let cost: UInt8
    let state: BoardState

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

    public func search() {
        var q = FifoQueue<PatternSearchNode>()
        q.push(PatternSearchNode(cost: 0, state: self.startBoard))
        var visited: Set<BoardState> = [startBoard]
        var results: Dictionary<Pattern, UInt8> = [:]
        var i = 0
        queueLoop: while !q.isEmpty {
            let node = q.pop()!
            let state = node.state
            let cost = node.cost
            // print(">>> processing state:")
            // print(state)
            // print(node)
            for dir in BoardState.MoveDirection.allDirections {
                do {
                    i += 1
                    if i % 100_000 == 0 {
                        if results.count > 100_000 {
                            break queueLoop
                        }
                        print("\u{1b}[2K\rIteration: \(i), Queue size: \(q.count), Patterns found: \(results.count)", terminator: "")
                        fflush(stdout)
                    }
                    let next = try state.movingEmptyTile(dir)
                    guard !visited.contains(next) else { continue }
                    visited.insert(next)

                    let pattern = Pattern(boardState: next, relevantElements: [0,1,2,3,4,8,12])
                    if let currentMin = results[pattern] {
                        results[pattern] = min(currentMin, cost + 1)
                    } else {
                        results[pattern] = cost + 1
                    }

                    q.push(PatternSearchNode(cost: cost + 1, state: next))
                } catch { }
            }
        }
        var packed_results = results.map {(pattern: Pattern, cost: UInt8)-> UInt64 in
            return pattern.serialize(cost)
        }
        packed_results = packed_results.sort()
        packed_results.withUnsafeMutableBufferPointer({ (inout data: UnsafeMutableBufferPointer<UInt64>) in
            let dataObject = NSData(bytesNoCopy: data.baseAddress, length: data.count * sizeof(UInt64))
            do {
                try dataObject.writeToFile("test.data", options: NSDataWritingOptions.DataWritingWithoutOverwriting)
            } catch {
                fatalError("Can't write Pattern Database to File")
            }
        })
    }
}
