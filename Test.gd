extends Node2D

var dun: Dungeon

var rooms: Array

const min_size = Vector2(50, 50)
const max_size = Vector2(100, 100)
const number_of_rooms = 11
const min_room_size = Vector2(8,8)
const max_room_size = Vector2(14,15)


func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	dun = Dungeon.new(min_size, max_size, number_of_rooms, min_room_size, max_room_size, rng)
	
	update()
	

const cell_size = 11
const offset = Vector2(110, 50)

func _draw():
	var colors = [Color(0,0,0), Color(0, 0.98, 0.32), Color(0.88, 0.78, 0), Color(0.9, 0.9, 0.14)]

	for x in range(dun.map.size.x):
		for y in range(dun.map.size.y):
			draw_rect(Rect2(pointToScreen(Vector2(x, y)), Vector2(cell_size, cell_size)), colors[dun.map.matrix[y][x]])

			
func pointToScreen(point: Vector2) -> Vector2:
	return offset + point*cell_size

func _input(event):
	if event.is_action_pressed("restart"):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		dun = Dungeon.new(min_size, max_size, number_of_rooms, min_room_size, max_room_size, rng)
		
		update()
