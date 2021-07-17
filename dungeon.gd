extends Node

class_name Dungeon

var map: Map


const PERCENTAGE_OF_NEW_EDGES = 6

func _init(min_world_size: Vector2, max_world_size: Vector2, number_of_rooms: int, min_room_size: Vector2, max_room_size: Vector2, rng: RandomNumberGenerator = RandomNumberGenerator.new()) -> void:	
	assert(max_world_size.x * max_world_size.y > min_room_size.x * min_room_size.y * number_of_rooms)
	"""
	Checking the size of the world is important so one can fit the requested
	number of rooms in there
	"""
	if max_world_size.x < (min_room_size.x + max_room_size.x)/3  * number_of_rooms:
		print("X Size is not advisable")
		assert(max_world_size.x > min_room_size.x*0.22 * number_of_rooms)
	
	if max_world_size.y < (min_room_size.y + max_room_size.y)/3  * number_of_rooms:
		print("Y Size is not advisable")
		assert(max_world_size.y > min_room_size.y*0.22 * number_of_rooms)

	map = createMap(min_world_size, max_world_size, number_of_rooms, min_room_size, max_room_size, rng)
	
	var list = Geometry.triangulate_delaunay_2d(map.room_centers)
	
	var graph = triangleIndexToGraph(list, map.room_centers)

	var mst_edges = primMst(graph)
	
	var all_edges = getEdgesFromGraph(graph)
	var bad_edges = getBadEdges(map, all_edges)

	for edge in all_edges:
		var bad_edge_weight = 1
		if bad_edges[edge[0]][edge[1]] > 0:
			print(edge[0]," ", edge[1])
			bad_edge_weight += bad_edges[edge[0]][edge[1]]*2
		
		var inverted = [edge[1], edge[0]]
		
		if not mst_edges.has(edge) and not mst_edges.has(inverted):
			if rng.randi()%100 <= PERCENTAGE_OF_NEW_EDGES/bad_edge_weight:
				mst_edges.append(edge)


	for edge in mst_edges:
		edgeToHallway(edge, rng)
	

func createMap(min_world_size: Vector2, max_world_size: Vector2, number_of_rooms: int, min_room_size: Vector2, max_room_size: Vector2, rng: RandomNumberGenerator = RandomNumberGenerator.new()) -> Map:
	var n = 0
	var rooms = []
	var world_size = min_world_size	
	
	var tries = 0
	while n < number_of_rooms:
		tries += 1
		assert(tries <= number_of_rooms*800)

		if tries > 100 and world_size.x < max_world_size.x and world_size.y < max_world_size.y:
			world_size.x = int(lerp(world_size.x, max_world_size.x, 0.25))
			world_size.y = int(lerp(world_size.y, max_world_size.y, 0.25))
			tries = 0
		
		var room = Room.new(Rect2(Vector2(rng.randi()%int(world_size.x-2) +1, rng.randi()%int(world_size.y-2)+1), Vector2(rng.randi_range(min_room_size.x, max_room_size.x), rng.randi_range(min_room_size.y, max_room_size.y))))
		
		var placeable = true
		
		if room.position.x + room.size.x >  world_size.x:
			continue
		if room.position.y + room.size.y >  world_size.y:
			continue
		

		for other in rooms:
			if room.intersects(other):
				placeable = false
				break
		
		if placeable:
			rooms.append(room)
			n += 1

	return Map.new(world_size, rooms)

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
	

func getBadEdges(map: Map, all_edges: Array) -> Array:
	var bad_edges = []
	for i in range(len(map.rooms)):
		var aux = []
		for j in range(len(map.rooms)):
			aux.append(-2)
		bad_edges.append(aux)
		

	for edge in all_edges:
		for room in map.rooms:
			if room.lineIntersects(map.room_centers[edge[0]], map.room_centers[edge[1]]):
				bad_edges[edge[0]][edge[1]] += 1
				bad_edges[edge[1]][edge[0]] += 1
	
	return bad_edges
	
func Vect2FToI(v: Vector2):
	return Vector2(int(v.x), int(v.y))

"""
connectPoints(Vector2, Vector2) returns an array of points that make up a line that connects the two given points

For example:
	
var a = connectPoints(p1, p2)

a -> [p1, a1, a2, p2]

to draw this line simply connect the points of the array like so:
	
p1 -> a1 | a1 -> a2 | a2 -> p2

"""
const BASE_LINE_THRESHOLD: int = 300
const NEW_THRESHOLD_PERC: float = 10.5

func connectPoints(p1: Vector2, p2: Vector2, threshold:int = BASE_LINE_THRESHOLD) -> Array:
	var line_list = []
	var dist = p1.distance_squared_to(p2)
	var dir = p2 - p1
	
	if dist < threshold: # Short -> L lines
		line_list.append(p1)
		if abs(dir.x) > abs(dir.y):
			line_list.append(Vector2(p2.x, p1.y))
		else:
			line_list.append(Vector2(p1.x, p2.y))
		line_list.append(p2)
	else: # Long -> S lines
		line_list.append_array(connectPoints(p1, Vect2FToI((p1 + p2)/2), threshold*NEW_THRESHOLD_PERC))
		line_list.append_array(connectPoints(Vect2FToI((p1 + p2)/2), p2, threshold*NEW_THRESHOLD_PERC))
	
	return line_list

func edgeToHallway(edge: Array, rng: RandomNumberGenerator = null) -> void:
	var line: Array
	
	if not is_instance_valid(rng):
		line = connectPoints(map.room_centers[edge[0]], map.room_centers[edge[1]])
	else:
		line = connectPoints(self.map.rooms[edge[0]].getRandomPoint(rng), self.map.rooms[edge[1]].getRandomPoint(rng))
	
	var was_inside_room = true

	for i in range(len(line) - 1):
		var _y_sign = sign(line[i+1].y - line[i].y)
		var _x_sign = sign(line[i+1].x - line[i].x)

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
