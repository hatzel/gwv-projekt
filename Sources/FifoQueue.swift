class Element<T> {
    let data: T
    var next: Element<T>?
    init(input: T) {
        data = input
        next = nil
    }
}

class FifoQueue<T> {
    var first: Element<T>?
    var last: Element<T>?
    func push(data: T) {
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
    }

    func pop() -> T? {
        guard first != nil else {
            return nil
        }
        let data = first!.data
        first = first!.next
        return data
    }
}
