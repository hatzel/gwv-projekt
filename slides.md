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



## Pattern Databases
* Used as improved heuristic for A*
* Minimum steps needed from a given set of nodes to get to goal node
  * Additive
  * Non additive

## Creation
* We search from goal node and store found patterns
* Creation is very space intensive
  * Optimization wouldn't enable us to use BFS
    * We managed to cut memory usage in half
    * Queue size was still getting to large
  * We chose to go with DFS up to a specified depth
    * Slower but takes less space

## Reading Databases
* A database containing 16!/9! ~ 57,000,000 items is ~450MB large
* We load the database into RAM at startup
* Binary Search to find the costs corresponding to a state



## Parallelize
* A* not really fitting for parallelization
* IDA however is easy to parallelize
  * Have different threads calculate different levels
  * We have not implemented this yet
* Issues:
  * Memory usage
  * Locking due to shared data-structures
