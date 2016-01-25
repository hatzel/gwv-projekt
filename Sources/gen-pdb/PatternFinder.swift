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

func createPatternDefinition(array: Array<UInt8>) -> UInt64{
    let pointer = UnsafeMutablePointer<UInt8>.alloc(8)
    for (i, x) in array[0...6].enumerate() {
        pointer[i] = x
    }
    return UnsafeMutablePointer<UInt64>(pointer)[0]
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

    private func writeToFile(sortedResults: Array<UInt64>, filename: String, patternDefinition: Array<UInt8>) {
        let res = [0x504442464f524d00, createPatternDefinition(patternDefinition)] + sortedResults
        res.withUnsafeBufferPointer({ (data: UnsafeBufferPointer<UInt64>) in
            let dataObject = NSData(bytesNoCopy: UnsafeMutablePointer<UInt64>(data.baseAddress), length: data.count * sizeof(UInt64))
            do {
                try dataObject.writeToFile(filename, options: [NSDataWritingOptions.DataWritingWithoutOverwriting])
            } catch {
                fatalError("Can't write Pattern Database to File")
            }
        })
    }

    public func search(size: Int, patternDefinitions: Array<Array<UInt8>>=[[0,1,2,3,4,8,12]]) {
        var q = FifoQueue<PatternSearchNode>()
        q.push(PatternSearchNode(cost: 0, state: self.startBoard.packed))
        var visited: Set<PackedBoardState> = [startBoard.packed]
        var results: Array<Dictionary<PackedPattern, UInt8>> = Array(count: patternDefinitions.count, repeatedValue: [:])
        var i = 0
        queueLoop: while !q.isEmpty {
            let node = q.pop()!
            let state = BoardState(packed: node.state)
            let cost = node.cost
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
        var packed_results: [[UInt64]]? = results.map({ $0.map({(pattern: PackedPattern, cost: UInt8)-> UInt64 in
            return UInt64(cost) | pattern
        })})
        let sorted_results = packed_results!.map({ $0.sort() })
        //save some memory, we don't need them now as we have the sorted ones
        packed_results = nil
        for (i, sorted) in sorted_results.enumerate() {
            writeToFile(sorted, filename: "pattern-\(i).pdb", patternDefinition: patternDefinitions[i])
        }
    }
}
