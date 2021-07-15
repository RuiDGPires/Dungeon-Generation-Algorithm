extends Node

class_name Dungeon

var map: Map


const PERCENTAGE_OF_NEW_EDGES = 20

func _init(size: Vector2, rooms: Array = [], rng: RandomNumberGenerator = RandomNumberGenerator.new()) -> void:
	map = Map.new(size, rooms)
	
	var room_centers = getRoomCenters()
	
	var list = Geometry.triangulate_delaunay_2d(room_centers)
	
	var graph = triangleIndexToGraph(list, room_centers)

	var mst_edges = primMst(graph)
	
	var all_edges = getEdgesFromGraph(graph)

	print(all_edges)
	for edge in all_edges:
		var inverted = [edge[1], edge[0]]
		
		if not mst_edges.has(edge) and not mst_edges.has(inverted):
			if rng.randi()%100 <= PERCENTAGE_OF_NEW_EDGES:
				mst_edges.append(edge)


	for edge in mst_edges:
		edgeToHallway(edge, rng)
	

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
	
func triangleIndexToGraph(triangles: Array, list: Array) -> Array:
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

	selected[0] = true
	
	var edges = []
	while (no_edge < size - 1):
		var minimum = INF
		var x = 0
		var y = 0
		for i in range(size):
			if selected[i]:
				for j in range(size):
					if ((not selected[j]) and graph[i][j]):  
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
const LINE_THRESHOLD: int = 50
func Vect2FToI(v: Vector2):
	return Vector2(int(v.x), int(v.y))


func connectPoints(p1: Vector2, p2: Vector2) -> Array:
	var line_list = []
	var dist = p1.distance_squared_to(p2)
	var dir = p2 - p1
	
	if dist < LINE_THRESHOLD: # Short -> L lines
		line_list.append(p1)
		if abs(dir.x) > abs(dir.y):
			line_list.append(Vector2(p2.x, p1.y))
		else:
			line_list.append(Vector2(p1.x, p2.y))
		line_list.append(p2)
	else: # Long -> S lines
		line_list.append_array(connectPoints(p1, Vect2FToI((p1 + p2)/2)))
		line_list.append_array(connectPoints(Vect2FToI((p1 + p2)/2), p2))
	
	return line_list

func getSign(n: int):
	if n < 0:
		return -1
	else:
		return 1

func edgeToHallway(edge: Array, rng: RandomNumberGenerator = null) -> void:
	var line: Array
	
	if not is_instance_valid(rng):
		line = connectPoints(self.room_centers[edge[0]], self.room_centers[edge[1]])
	else:
		line = connectPoints(self.map.rooms[edge[0]].getRandomPoint(rng), self.map.rooms[edge[1]].getRandomPoint(rng))
	
	var was_inside_room = true

	for i in range(len(line) - 1):
		var _y_sign = getSign(line[i+1].y - line[i].y)
		var _x_sign = getSign(line[i+1].x - line[i].x)

		if line[i].x == line[i+1].x:
			for j in range(line[i].y, line[i+1].y + _y_sign, _y_sign):
				if j == line[i].y:
					was_inside_room = self.map.setAsHallway(Vector2(line[i].x, j), line[i], was_inside_room)
				else:
					was_inside_room = self.map.setAsHallway(Vector2(line[i].x, j), Vector2(line[i].x, j-_y_sign), was_inside_room)

		else:
			for j in range(line[i].x, line[i+1].x + _x_sign, _x_sign):
				if j == line[i].x:
					was_inside_room = self.map.setAsHallway(Vector2(j, line[i].y), line[i], was_inside_room)
				else:
					was_inside_room = self.map.setAsHallway(Vector2(j, line[i].y), Vector2(j-_x_sign, line[i].y), was_inside_room)

func getEdgesFromGraph(graph: Array) -> Array:
	var edges = []

	for i in range(1, len(graph)):
		for j in range(i):
			if graph[i][j] != 0:
				edges.append([j, i])

	return edges
