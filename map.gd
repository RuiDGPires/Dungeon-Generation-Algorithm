extends Node

class_name Map

enum CellType{VOID, ROOM, HALLWAY, DOOR}

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
func setAsHallway(pos: Vector2, previous: Vector2, was_inside_room: bool = false) -> bool:
	if self.matrix[pos.y][pos.x] != CellType.ROOM and self.matrix[pos.y][pos.x] != CellType.DOOR:
		if was_inside_room:
			self.matrix[previous.y][previous.x] = CellType.DOOR
		self.matrix[pos.y][pos.x] = CellType.HALLWAY
		return false
	else:
		if not was_inside_room:
			self.matrix[pos.y][pos.x] = CellType.DOOR
		return true
		
func getRoomCenters(rooms: Array) -> Array:
	var point_list = []
	
	for room in rooms:
		point_list.append(room.getCenter())
	
	return point_list
