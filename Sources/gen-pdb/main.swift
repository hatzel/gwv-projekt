import SlidingPuzzle
import Commander


let main = command(
    Option("size", 100_000)
) { size in
    let pf = PatternFinder(startBoard: BoardState())
    pf.search(size)
    }

main.run()
