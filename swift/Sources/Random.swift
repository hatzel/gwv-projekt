import Glibc


// this file contains implementations of the algorithms described
// and implemented (in c) on http://xorshift.di.unimi.it/

class SplitMix64Generator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

class Xorshift128PlusGenerator {
    private let state = UnsafeMutablePointer<UInt64>.alloc(2)

    init(seed: (UInt64, UInt64)) {
        state[0] = seed.0
        state[1] = seed.1
    }

    init(seed: UInt64) {
        let g = SplitMix64Generator(seed: seed)
        state[0] = g.next()
        state[1] = g.next()
    }

    deinit {
        state.destroy()
    }

    func next() -> UInt64 {
        var s1 = state[0]
        let s0 = state[1]
        state[0] = s0
        s1 ^= s1 << 23
        state[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5)

        return state[1] &+ s0
    }
}

class Xorshift1024StarGenerator {
    private let state = UnsafeMutablePointer<UInt64>.alloc(16)
    private var p: Int = 0

    init(seed: UInt64) {
        let g = SplitMix64Generator(seed: seed)

        for i in 0..<16 {
            state[i] = g.next()
        }
    }

    deinit {
        state.destroy()
    }

    func next() -> UInt64 {
        let s0 = state[p]
        p = (p &+ 1) & 15
        var s1 = state[p]
        s1 ^= s1 << 31
        state[p] = s1 ^ s0 ^ (s1 >> 11) ^ (s0 >> 30)
        return state[p] &* 1181783497276652981
    }
}

class Random {

    private let generator: Xorshift1024StarGenerator

    init(seed: UInt64) {
        generator = Xorshift1024StarGenerator(seed: seed)
    }

    convenience init() {
        var t = timespec()
        clock_gettime(CLOCK_REALTIME, &t)
        self.init(seed: UInt64(t.tv_sec) + UInt64(t.tv_nsec))
    }

    func next() -> UInt64 {
        return generator.next()
    }

    func sample<C where C: CollectionType, C.Index.Distance == Int>(collection: C) -> C.Generator.Element {
        let num = UInt64(collection.count)
        let excess = (UInt64.max % num) + 1
        let max = UInt64.max - excess

        var sample: UInt64 = 0

        repeat {
            sample = next()
        } while sample > max

        let pos = Int(sample % num)
        let index = collection.startIndex.advancedBy(pos)

        return collection[index]
    }

    static var defaultGenerator = Random()

}
