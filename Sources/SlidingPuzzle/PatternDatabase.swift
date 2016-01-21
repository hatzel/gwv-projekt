import Foundation

public struct Pattern: Hashable {
    var state: [UInt8]
    var cost: UInt8?

    public init(boardState: BoardState, relevantElements: [Int]) {
        self.state = []
        for x in relevantElements {
            state.append(boardState.array[x])
        }
        self.cost = nil
    }

    // init()

    public func serialize(cost: UInt8? = nil) -> UInt64 {
        let pointer = UnsafeMutablePointer<UInt8>.alloc(8)
        for (i, x) in self.state.enumerate() {
            pointer[i] = x
        }
        let long_pointer = UnsafeMutablePointer<UInt64>(pointer)
        defer { long_pointer.dealloc(1) }
        return UInt64(cost ?? self.cost ?? 0) | long_pointer[0] >> 8
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


public class PatternDatabase {
    var dataArray: [UInt64]

    public init(filename: String) throws {
        let data = try NSData(contentsOfFile: filename, options: NSDataReadingOptions.DataReadingMappedAlways)
        dataArray = [UInt64](count: data.length / sizeof(UInt64),  repeatedValue: 0)
        data.getBytes(&dataArray, length: data.length)
    }

    public func search(pattern: Pattern) -> UInt8? {
        return binarySearch(pattern: pattern.serialize(), slice: self.dataArray[0..<dataArray.count])
    }

    public func testSearch(pattern: UInt64) -> UInt8? {
        return binarySearch(pattern: pattern, slice: self.dataArray[0..<dataArray.count])
    }

    private func binarySearch(pattern inPattern: UInt64, slice: ArraySlice<UInt64>) -> UInt8? {
        if slice.count == 0 {
            return nil
        }
        let middleValue = slice[slice.startIndex + slice.count / 2]
        let pattern = inPattern >> 8
        let compareValue = middleValue >> 8
        if compareValue == pattern {
            return UInt8(truncatingBitPattern: middleValue)
        }
        else if compareValue > pattern{
            return binarySearch(pattern: inPattern, slice: slice[slice.startIndex..<slice.startIndex + (slice.count / 2)])
        }
        else {
            return binarySearch(pattern: inPattern, slice: slice[slice.startIndex + (slice.count / 2) + 1..<slice.startIndex + slice.count])
        }
    }
}
