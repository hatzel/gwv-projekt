import SlidingPuzzle
import Commander

let main = command(
    Option("size", 100_000),
    Option("depth", 0)
) { size, depth in
    let pf = PatternFinder(startBoard: BoardState())
    pf.search(size, depth: depth)
    }

main.run()
