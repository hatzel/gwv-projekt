import Foundation

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

public struct Pattern: Hashable {
    var state: [UInt8]
    var cost: UInt8?

    init(boardState: BoardState, relevantElements: [Int]) {
        self.state = []
        for x in relevantElements {
            state.append(boardState.array[x])
        }
        self.cost = nil
    }

    // init()

    func serialize(cost: UInt8? = nil) -> UInt64 {
        let pointer = UnsafeMutablePointer<UInt64>.alloc(1)
        defer { pointer.dealloc(1) }
        let smallp = UnsafeMutablePointer<UInt8>(pointer)
        smallp[0] = cost ?? self.cost ?? 0
        return pointer[0]
    }

    public var hashValue: Int {
        get {
            return state.hashValue
        }
    }
}

public func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    return lhs.state == rhs.state
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

    public func search() -> Dictionary<Pattern, UInt8> {
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
                    if i % 10000 == 0 {
                        print("iteration: \(i), queue size: \(q.count), Patterns found \(results.count)")
                        if results.count > 10000 {
                            break queueLoop
                        }
                    }
                    let next = try state.movingEmptyTile(dir)
                    guard !visited.contains(next) else { continue }
                    visited.insert(next)

                    let pattern = Pattern(boardState: next, relevantElements: [3,7,11,12,13,14,15])
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

        return results
    }
}

// let pf = PatternFinder(startBoard: BoardState())
// pf.search()
