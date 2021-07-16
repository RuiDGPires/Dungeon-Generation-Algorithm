# Dungeon Generation Algorithm


Randomly generates rooms by trial and checking (bad and inefficient solution, to be replaced later)

Generates the triangle mesh result from Delaunay's Triangulation on the rooms' centers

Transforms the triangle mesh into a weighted graph

Applies Prim's Algorithm to get a Minimum Spanning Tree

Randomly adds other edges to the MST

Creates simple hallways to connect the random points in the rooms following the edges selected

--------

## How to use

For now, usage is quite rudimentary:

Copying the GDScript files (\*.gd) should give acess to the *Dungeon* class. Then, just attatch a script to a node2D, create a RandomNumberGenerator to use as parameter and generate a new Dungeon like so:

```gdscript
var rng = RandomNumberGenerator.new()
rng.randomize()

dun = Dungeon.new(min_size, max_size, number_of_rooms, min_room_size, max_room_size, rng)
```

Then, *dun.map.matrix* will be a matrix (with **size**: min_size ≤ **size** ≤ max_size) of integers that correspond to what there is in a given position (x,y) on the grid. This value can be:

- 0: nothing
- 1: Room
- 2: Hallway
- 3: Door



--


## Examples

### Hallway calculation
![example.gif](images_and_gifs/example.gif)

### Hallway examples with fixed rooms
![example2.gif](images_and_gifs/example2.gif)

### Full dungeon generation
![example3.gif](images_and_gifs/example3.gif)
