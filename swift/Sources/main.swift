let r = Random()

var board = BoardState()

let directions: [BoardState.MoveDirection] = [.Up, .Down, .Left, .Right]
for i in 0..<500 {
    let d = r.sample(directions)
    do {
        try board = board.movingEmptyTile(d)
    } catch {
        print("-- ignored invalid move --")
    }
    print("-- step \(i) --")
    print(board)
}
