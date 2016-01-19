class Element<T> {
    let data: T
    var next: Element<T>?
    init(input: T) {
        data = input
        next = nil
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
