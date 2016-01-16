extension Array {
    func chunksOfSize(size: Int) -> [ArraySlice<Element>] {
        return 0.stride(to: count, by: size).map {
            self[$0..<$0.advancedBy(size, limit: count)]
        }
    }
}

func ~= <T: Equatable>(lhs: [T], rhs: T) -> Bool { return lhs.contains(rhs) }

struct BoardState: CustomStringConvertible {
    enum MoveDirection {
        case Up, Down, Left, Right
    }

    enum MoveError: ErrorType {
        case OutOfBounds
    }

    private var array: [Int]

    init() {
        array = Array(0...15)
    }

    private var indexOfEmpty: Int {
        get {
            guard let idx = array.indexOf(0)
                else { fatalError("where is my 0?!") }
            return idx
        }
    }

    func movingEmptyTile(direction: MoveDirection) throws -> BoardState {
        let idx = indexOfEmpty
        let mov: Int
        switch (direction, idx) {
        case (.Up, 4...15):
            mov = -4
        case (.Down, 0...11):
            mov = 4
        case (.Left, (0...15).filter { $0 % 4 != 0 }):
            mov = -1
        case (.Right, (0...15).filter { ($0 + 1) % 4 != 0 }):
            mov = 1
        default:
            throw MoveError.OutOfBounds
        }
        var next = self
        swap(&next.array[indexOfEmpty], &next.array[indexOfEmpty + mov])
        return next
    }

    var description: String {
        get {
            let chunks = array.chunksOfSize(4)
            let substrings = chunks.map { 
                $0.map { $0 != 0 ? String($0, radix: 16) : " " }.joinWithSeparator("")
            }
            return substrings.joinWithSeparator("\n")
        }
    }
}
