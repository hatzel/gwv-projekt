# Solving 15-Puzzles
### Project for gwv in WiSe 15/16



## Structure
* Algorithms
* Implementation
* Pattern Databases
* Parallelism
* Outlook/Conclusion



## Algorithms
* BFS
* A*
* IDA*


## BFS
* Very slow
* Memory intensive


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
  * Faster
  * not as memory-hungry
  * No true parallelism in Python
  * Learn a fun new language!



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



## Pattern Databases (PDBs)
* Used as improved heuristic for A*
* Minimum steps needed from a given set of nodes to get to goal node
  * Additive
  * Non additive


## Creation
* We search from goal node and store found patterns
* Creation is very space intensive
  * Using BFS is very space intensive
  * DFS is way to slow

## Reading Databases
* A database containing 16!/9! ~ 57,000,000 items is ~450MB in size
* We load the database into RAM at startup
* Binary Search to find the costs corresponding to a state
  * Very fast
  * O(log(n))


## Outlook
* Parallelization
* Additive PDBs
* Larger PDBs


## Parallelize
* A* not really fitting for parallelization
* IDA however is easy to parallelize
  * Have different threads calculate different levels
  * We have not implemented this yet
* Issues:
  * Memory usage
  * Locking due to shared data-structures

## Benchmarks
* We solve puzzles in an average time of:
    TO BE DONE
