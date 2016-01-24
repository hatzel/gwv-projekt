struct Stack<T> {
    var array: Array<T>
    init() {
        array = Array<T>()
    }
    mutating func push(element: T) {
        array.append(element)
    }

    mutating func pop() -> T? {
        if array.count > 0 {
            return array.removeLast()
        }
        else {
            return nil
        }
    }

    var count: Int {
        get {
            return array.count
        }
    }

    var isEmpty: Bool {
        get {
            return array.count == 0
        }
    }
}
