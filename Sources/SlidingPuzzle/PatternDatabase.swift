import Foundation

public typealias PackedPattern = UInt64

public struct Pattern: Hashable {
    var state: [UInt8]
    var cost: UInt8?

    public init(boardState: BoardState, relevantElements: [UInt8]) {
        self.state = []
        for x in relevantElements {
            state.append(boardState.array[Int(x)])
        }
        self.cost = nil
    }

    // init(pattern: PackedPattern) {
    //
    // }

    public func serialize(cost: UInt8? = nil) -> UInt64 {
        let pointer = UnsafeMutablePointer<UInt8>.alloc(8)
        for (i, x) in self.state.enumerate() {
            pointer[i + 1] = x
        }
        pointer[0] = UInt8(cost ?? self.cost ?? 0)
        let long_pointer = UnsafeMutablePointer<UInt64>(pointer)
        defer { long_pointer.dealloc(1) }
        // print("state: \(self.state), cost: \(cost!), serialized: \(UInt64(cost ?? self.cost ?? 0) | long_pointer[0] >> 8)")
        return long_pointer[0]
    }

    public var packed: PackedPattern {
        get {
            return self.serialize()
        }
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
    public var relevantElements: [UInt8]

    public init(filename: String) throws {
        let data = try NSData(contentsOfFile: filename, options: NSDataReadingOptions.DataReadingMappedAlways)
        dataArray = [UInt64](count: data.length / sizeof(UInt64),  repeatedValue: 0)
        // I dont understand why NSData copys more than it should, workaround below
        var rlElements: Array<UInt8> = Array(count: 20, repeatedValue: 0)
        rlElements.withUnsafeMutableBufferPointer({ (inout array: UnsafeMutableBufferPointer<UInt8>) in
            data.getBytes(array.baseAddress, range: NSMakeRange(8, 16))
        })
        // so this is a workaround
        relevantElements = Array(count: 7, repeatedValue: 0)
        for (i, x) in rlElements[0...6].enumerate() {
            relevantElements[i] = x;
        }
        dataArray.withUnsafeMutableBufferPointer({ (inout array: UnsafeMutableBufferPointer<UInt64>) in
            data.getBytes(array.baseAddress, range: NSMakeRange(16, data.length))
        })
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
        let pattern = (inPattern >> 8) << 8
        let compareValue = (middleValue >> 8) << 8
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
