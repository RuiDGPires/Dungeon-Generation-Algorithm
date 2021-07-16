extends Node2D

var dun: Dungeon

export (Vector2) var min_size = Vector2(50, 50)
export (Vector2) var max_size = Vector2(100, 100)
export (int) var number_of_rooms = 11
export (Vector2) var min_room_size = Vector2(8,8)
export (Vector2) var max_room_size = Vector2(14,15)


func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	dun = Dungeon.new(min_size, max_size, number_of_rooms, min_room_size, max_room_size, rng)
	
	update()
	

var cell_size = 11
var base_offset = Vector2(20, 10)
var offset = base_offset

func _draw():
	var colors = [Color(0,0,0,0), Color(0, 0.98, 0.32), Color(0.88, 0.78, 0), Color(0.9, 0.9, 0.14)]

	for x in range(dun.map.size.x):
		for y in range(dun.map.size.y):
			draw_rect(Rect2(pointToScreen(Vector2(x, y)), Vector2(cell_size, cell_size)), colors[dun.map.matrix[y][x]])

			
func pointToScreen(point: Vector2) -> Vector2:
	return offset + point*cell_size

var dragging = false
var pos: Vector2

func _input(event):
	if event.is_action_pressed("restart"):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		dun = Dungeon.new(min_size, max_size, number_of_rooms, min_room_size, max_room_size, rng)
		
		update()
	
	
	if event.is_action_pressed("scroll_up") and event.control:
		cell_size += 1
		update()
	elif event.is_action_pressed("scroll_down") and event.control:
		cell_size -= 1
		update()


	if event.is_action_pressed("mouse_click"):
		dragging = true
		pos = event.position
	if event.is_action_released("mouse_click"):
		base_offset = offset
		dragging = false
		
func  _process(delta):
	if dragging:
		var current = get_viewport().get_mouse_position()

		offset = base_offset + current - pos
		update()
