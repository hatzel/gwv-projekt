class Element<T> {
    let data: T
    var next: Element<T>?
    init(input: T) {
        data = input
    }

    deinit {
        // try to avoid deep recursion in deinit by tearing down the rest of the
        // list ourselves if it's uniquely referenced
        while isUniquelyReferencedNonObjC(&next) {
            // we hold the only pointer to next, lets tear it down
            let temp = next
            next = temp?.next
            temp?.next = nil
            // temp no longer has a tail, so when it deinits it won't recurse
            // and if our new next is still uniquely referenced, we'll keep
            // tearing it down. Otherwise, we'll break, next will be released,
            // but it won't recurse because something else will be keeping it
            // alive.
        }
    }
}

struct FifoQueue<T> {
    private var first: Element<T>?
    private var last: Element<T>?
    mutating func push(data: T) {
        guard first != nil else {
            first = Element(input: data)
            return
        }
        guard last != nil else {
            last = Element(input: data)
            first!.next = last!
            return
        }
        let append = Element(input: data)
        last!.next = append
        self.last = append
    }

    func getlast() -> Element<T>? {
        return self.last
    }
    mutating func pop() -> T? {
        guard first != nil else {return nil}
        let data = first!.data
        first = first!.next
        return data
    }

    var isEmpty: Bool {
        get {
            return first == nil
        }
    }

    var count: Int {
        get {
            guard first != nil else {return 0}
            guard last != nil else {return 1}
            var i = 2
            var current = first!
            while current.next !== self.last {
                guard current.next != nil else {return i}
                i += 1
                current = current.next!
            }
            return i
        }
    }
}

// var q = FifoQueue<Int>()
// q.push(1)
// q.push(2)
// q.push(3)
// q.push(4)
// q.push(5)
// q.push(6)
// print(q.getlast()!)
// print("Size: \(q.count)")
// for i in 1...6 {
//     print(q.pop()!)
// }
//
