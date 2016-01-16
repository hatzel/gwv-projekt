extension Array {
    func chunksOfSize(size: Int) -> [ArraySlice<Element>] {
        return 0.stride(to: count, by: size).map {
            self[$0..<$0.advancedBy(size, limit: count)]
        }
    }
}

struct BoardState: CustomStringConvertible {
    private var array: [Int]

    init() {
        array = Array(0...15)
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
