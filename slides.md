# Solving 15-Puzzles
### Project for gwv in WiSe 15/16



## Structure
* Algorithms
* Implementation
* Pattern Databases
* Parralelism
* Outlook/Conclusion



## Algorithms
* BFS
* A*
* IDA*


## BFS
* Very slow


##  A*
* Could be faster with heuristics
* Choose a good heuristic
  * "Dumb" heuristic
  * Pattern DB


## IDA*
* Slower than A*
* Less space complexity
* Potential for parallelism



## Implementation
* We chose Swift over Python
  * Faste
  * not as memory-hungry
* No prallelism



## Optimizations
* First measure: Algorithms
* Build options
  * Release builds get us a speedup of ~10
* micro optimizations
  * 'packing' board states


## Board State Representation
* Create Objects for abstraction
* 'packing' board states
  * One board state is an integer (64-bit)
  * This way we save a lot of memory



## Parallelize
* A* not really fitting for parallelization
* IDA however is easy to parallelize
  * Have different threads calculate different levels
  * We have not implemented this yet
* Issues:
  * Memory usage
  * Locking due to shared data-structures
