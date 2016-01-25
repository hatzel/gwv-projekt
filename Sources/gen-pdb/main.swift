import SlidingPuzzle
import Commander

let main = command(
    Option("size", Int.max),
    Option("depth", 0)
) { size, depth in
    let pf = PatternFinder(startBoard: BoardState())
    pf.search(size, depth: depth)
    }

main.run()
// 16: 23.61
// 17: 99.18
// 18: 447
