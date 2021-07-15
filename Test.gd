extends Node2D

const map_size = Vector2(14,14)

var dun: Dungeon

var rooms: Array

var n= -1


func _ready():
	rooms = []
	rooms.append(Room.new(Rect2(Vector2(0,0), Vector2(3,2))))
	rooms.append(Room.new(Rect2(Vector2(6,0), Vector2(3,4))))
	rooms.append(Room.new(Rect2(Vector2(1,5), Vector2(5,3))))
	rooms.append(Room.new(Rect2(Vector2(7,4), Vector2(2,2))))
	rooms.append(Room.new(Rect2(Vector2(9,6), Vector2(4,5))))
	rooms.append(Room.new(Rect2(Vector2(2,9), Vector2(4,4))))

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	dun = Dungeon.new(map_size, rooms, rng)
	
	update()
	

func _draw():
	var colors = [Color(0,0,0), Color(0, 0.98, 0.32), Color(0.88, 0.78, 0)]

	for x in range(map_size.x):
		for y in range(map_size.y):
			draw_rect(Rect2(pointToScreen(Vector2(x, y)), Vector2(50, 50)), colors[dun.map.matrix[y][x]])

			
func pointToScreen(point: Vector2) -> Vector2:
	var offset = Vector2(260, 70)
	var size = 50
	
	return offset + point*size

func _input(event):
	if event.is_action_pressed("ui_accept"):
		n += 1
		update()
	elif event.is_action_pressed("restart"):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		dun = Dungeon.new(map_size, rooms, rng)
		
		update()
