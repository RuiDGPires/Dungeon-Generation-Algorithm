extends Node

class_name Map

var matrix: Array
var rooms: Array

var size: Vector2


func _init(size: Vector2, rooms: Array) -> void:
	self.size = size
	self.rooms = rooms
	
	setupMatrix(rooms)

func setupMatrix(rooms: Array) -> void:
	self.matrix = []
	for i in range(size.y):
		var aux = []
		for j in range(size.x):
			aux.append(0)
		self.matrix.append(aux)

			
	for room in rooms:
		for j in range(room.position.x, room.position.x + room.size.x):
			for i in range(room.position.y, room.position.y + room.size.y):
				self.matrix[i][j] = 1

func setAsHallway(pos: Vector2) -> void:
	if self.matrix[pos.y][pos.x] != 1:
		self.matrix[pos.y][pos.x] = 2
