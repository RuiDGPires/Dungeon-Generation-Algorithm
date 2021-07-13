extends Node

class_name Dungeon

var map: Map
var edges: Array

func _init(size: Vector2, rooms: Array = []):
	map = Map.new(size, rooms)
	
	var room_centers = getRoomCenters()
	
	var list = Geometry.triangulate_delaunay_2d(room_centers)
	
	edges = primMst(triangleIndexToGraph(list, room_centers))
	
	

func getRoomCenters() -> Array:
	var point_list = []
	
	for room in map.rooms:
		point_list.append(room.getCenter())
	
	return point_list

func delaunayToTriangles(point_list: Array, td: Array) -> Array:
	var triangles = []
	
	for i in range(td.size()/3):
		triangles.append(Triangle.new(point_list[td[i*3]], point_list[td[i*3 + 1]], point_list[td[i*3 +2]]))
		
	return triangles
	
func triangleIndexToGraph(triangles: Array, list: Array):
	var graph = []
	for i in range(map.rooms.size()):
		var aux = []
		for j in range(map.rooms.size()):
			aux.append(0)
		graph.append(aux)
	
	for i in range(triangles.size()/3):
		var dist = list[triangles[i*3]].distance_squared_to(list[triangles[i*3 + 1]])
		graph[triangles[i*3]][triangles[i*3 + 1]] = dist
		graph[triangles[i*3 + 1]][triangles[i*3]] = dist
		
		dist = list[triangles[i*3 + 1]].distance_squared_to(list[triangles[i*3 + 2]])
		graph[triangles[i*3 + 1]][triangles[i*3 + 2]] = dist
		graph[triangles[i*3 + 2]][triangles[i*3 + 1]] = dist
		
		dist = list[triangles[i*3]].distance_squared_to(list[triangles[i*3 + 2]])
		graph[triangles[i*3]][triangles[i*3 + 2]] = dist
		graph[triangles[i*3 + 2]][triangles[i*3]] = dist
		
	return graph
	
func primMst(graph: Array) -> Array:
	var size = graph.size()
	var selected = []
	
	for i in range(size):
		selected.append(0)
	
	var no_edge = 0
	# the number of egde in minimum spanning tree will be
	# always less than(V - 1), where V is number of vertices in
	# graph
	# choose 0th vertex and make it true
	selected[0] = true
	
	var edges = []
	while (no_edge < size - 1):
		# For every vertex in the set S, find the all adjacent vertices
		#, calculate the distance from the vertex selected at step 1.
		# if the vertex is already in the set S, discard it otherwise
		# choose another vertex nearest to selected vertex  at step 1.
		var minimum = INF
		var x = 0
		var y = 0
		for i in range(size):
			if selected[i]:
				for j in range(size):
					if ((not selected[j]) and graph[i][j]):  
						# not in selected and there is an edge
						if minimum > graph[i][j]:
							minimum = graph[i][j]
							x = i
							y = j
		edges.append([x,y])
		selected[y] = true
		no_edge += 1
	return edges

func getRandomRoomPoints(_seed: String):
	var points = []
	
	var i = 0
	for room in map.rooms:
		points.append(room.getRandomPoint(_seed + str(i)))
		i += 1
		
	return points
	
"""
connectPoints(Vector2, Vector2) returns an array of points that make up a line that connects the two given points

For example:
	
var a = connectPoints(p1, p2)

a -> [p1, a1, a2, p2]

to draw this line simply connect the points of the array like so:
	
p1 -> a1 | a1 -> a2 | a2 -> p2

"""
func connectPoints(p1: Vector2, p2: Vector2) -> Array:
	var line_list = []
	var dist = p1.distance_squared_to(p2)
	var dir = p2 - p1
	
	if dist < 50: # Short -> L lines
		line_list.append(p1)
		if abs(dir.x) > abs(dir.y):
			line_list.append(Vector2(p2.x, p1.y))
		else:
			line_list.append(Vector2(p1.x, p2.y))
		line_list.append(p2)
	else: # Long -> S lines
		line_list.append_array(connectPoints(p1, (p1 + p2)/2))
		line_list.append_array(connectPoints((p1 + p2)/2, p2))
	
	return line_list

