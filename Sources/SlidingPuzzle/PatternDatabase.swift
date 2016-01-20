import Foundation

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
        let pattern = inPattern << 8
        let compareValue = middleValue << 8
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
