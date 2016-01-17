import FastRNG

extension Array {
    func chunksOfSize(size: Int) -> [ArraySlice<Element>] {
        return 0.stride(to: count, by: size).map {
            self[$0..<$0.advancedBy(size, limit: count)]
        }
    }
}

extension Array where Element: Hashable {
    var hashValue: Int {
        get {
            var hash = 5381

            for el in self {
                hash = ((hash << 5) &+ hash) &+ el.hashValue
            }

            return hash
        }
    }
}

func ~= <T: Equatable>(lhs: [T], rhs: T) -> Bool { return lhs.contains(rhs) }

struct BoardState: CustomStringConvertible, Hashable {
    enum MoveDirection {
        case Up, Down, Left, Right

        static var allDirections: [MoveDirection] = [.Up, .Down, .Left, .Right]

        var description: String {
            get {
                switch self {
                    case .Up:
                        return "up"
                    case .Down:
                        return "down"
                    case .Left:
                        return "left"
                    case .Right:
                        return "right"
                }
            }
        }

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

    mutating func moveEmptyTile(direction: MoveDirection) throws {
        let point = indexToPoint(indexOfEmpty)
        let mov: Int
        switch (direction, point) {
        case (.Up, (_, 1...3)):
            mov = -4
        case (.Down, (_, 0...2)):
            mov = 4
        case (.Left, (1...3, _)):
            mov = -1
        case (.Right, (0...1, _)):
            mov = 1
        default:
            throw MoveError.OutOfBounds
        }

        swap(&array[indexOfEmpty], &array[indexOfEmpty + mov])
    }

    func movingEmptyTile(direction: MoveDirection) throws -> BoardState {
        var other = self
        try other.moveEmptyTile(direction)
        return other
    }


    func permutingBoard(steps steps: Int, random: RandomGenerator) -> BoardState {
        var board = self
        for _ in 0..<steps {
            let d = random.sample(BoardState.MoveDirection.allDirections)
            do {
                try board.moveEmptyTile(d)
            } catch {}
        }
        return board
    }

    private func indexToPoint(idx: Int) -> (Int, Int) {
        let x = idx % 4
        let y = (idx - x) / 4
        return (x, y)
    }

    private func manhattanDistance(from from: (Int, Int), to: (Int, Int)) -> Int {
        return abs(from.0 - to.0) + abs(from.1 - to.1)
    }

    func sumOfManhattanDistancesTo(other: BoardState) -> Int {
        var sum = 0
        for (idx, tile) in array.enumerate() {
            let thisPos = indexToPoint(idx)
            let otherPos = indexToPoint(other.array.indexOf(tile)!)
            sum += manhattanDistance(from: thisPos, to: otherPos)
        }
        return sum
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

    var hashValue: Int {
        return array.hashValue
    }
}

func == (lhs: BoardState, rhs: BoardState) -> Bool {
    return lhs.array == rhs.array
}
