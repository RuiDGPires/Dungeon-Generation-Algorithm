extends Node

class_name Map

enum CellType{VOID, ROOM, HALLWAY, WALL}

var matrix: Array
var rooms: Array
var room_matrix: Array
var room_centers: Array
var size: Vector2


func _init(size: Vector2, rooms: Array) -> void:
	self.size = size
	self.rooms = rooms
	self.room_centers = getRoomCenters(rooms)
	
	setupMatrixes(rooms)

func setupMatrixes(rooms: Array) -> void:
	self.matrix = []
	self.room_matrix = []
	for i in range(size.y):
		var aux = []
		var aux2= []
		for j in range(size.x):
			aux.append(CellType.VOID)
			aux2.append(-1)
		
		self.matrix.append(aux)
		self.room_matrix.append(aux2)
			
	var n = 0
	for room in rooms:
		for j in range(room.position.x, room.position.x + room.size.x):
			for i in range(room.position.y, room.position.y + room.size.y):
				self.matrix[i][j] = CellType.ROOM
				self.room_matrix[i][j] = n
		n += 1

# Returns if position is inside room area
func setAsHallway(pos: Vector2, previous: Vector2) -> void:
	if matrix[pos.y][pos.x] != CellType.ROOM:
		matrix[pos.y][pos.x] = CellType.HALLWAY
		
		
func getRoomCenters(rooms: Array) -> Array:
	var point_list = []
	
	for room in rooms:
		point_list.append(room.getCenter())
	
	return point_list

func buildWalls() -> void:
	for room in rooms:
		for y in range(room.position.y, room.position.y + room.size.y):
			if y == room.position.y or y == room.position.y + room.size.y - 1:
				for x in range(room.position.x, room.position.x + room.size.x):
					self.matrix[y][x] = CellType.VOID
			else:
				self.matrix[y][room.position.x] = CellType.VOID
				self.matrix[y][room.position.x + room.size.x - 1] = CellType.VOID

func cleanUp() -> void:
	var ok = false
	for x in range(size.x):
		for y in range(size.y):
			ok = false
			if matrix[y][x] == CellType.VOID:
				for i in range(-1,2):
					for j in range(-1, 2):
						if x + i >= 0 and x + i < size.x and y + j < size.y and y + j >= 0 and (i != 0 or j != 0):
							if matrix[y+j][x+i] != CellType.VOID and matrix[y+j][x+i] != CellType.WALL :
								ok = true
				if ok:
					 matrix[y][x] = CellType.WALL
