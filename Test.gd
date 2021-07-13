extends Node2D

const map_size = Vector2(14,14)

var dun: Dungeon
var random_room_points: Array
var lines: Array 

var n= -1


func _ready():
	var rooms = []
	
	rooms.append(Room.new(Rect2(Vector2(0,0), Vector2(3,2))))
	rooms.append(Room.new(Rect2(Vector2(6,0), Vector2(3,4))))
	rooms.append(Room.new(Rect2(Vector2(1,5), Vector2(5,3))))
	rooms.append(Room.new(Rect2(Vector2(7,4), Vector2(2,2))))
	rooms.append(Room.new(Rect2(Vector2(9,6), Vector2(4,5))))
	rooms.append(Room.new(Rect2(Vector2(2,9), Vector2(4,4))))

	
	
	dun = Dungeon.new(map_size, rooms)
	random_room_points = dun.getRandomRoomPoints("__SEED1__")
	
	lines = []
	for edge in dun.edges:
		lines.append(dun.connectPoints(random_room_points[edge[0]], random_room_points[edge[1]]))
		
	update()
	

func _draw():
	var colors = [Color(0,0,0), Color(0, 0.98, 0.32), Color(0.88, 0.78, 0)]
	
	if n >= 0: # ROOMS
		for x in range(map_size.x):
			for y in range(map_size.y):
				draw_rect(Rect2(pointToScreen(Vector2(x, y)), Vector2(50, 50)), colors[dun.map.matrix[y][x]])
	
	if n >= 1 and n <= 3: # CENTER OF ROOMS
		for center in dun.room_centers:
			draw_circle(pointToScreen(center), 4.7, Color(0, 0.4, 0.97))
		
	if n >= 2 and n <= 3:
		for i in range(dun.list.size()/3):
			draw_line(pointToScreen(dun.room_centers[dun.list[i*3]]), pointToScreen(dun.room_centers[dun.list[i*3+1]]), Color(0.1, 0.5, 1, 0.85), 1.9)
			draw_line(pointToScreen(dun.room_centers[dun.list[i*3+1]]), pointToScreen(dun.room_centers[dun.list[i*3+2]]), Color(0.1, 0.5, 1, 0.85), 1.9)
			draw_line(pointToScreen(dun.room_centers[dun.list[i*3]]), pointToScreen(dun.room_centers[dun.list[i*3+2]]), Color(0.1, 0.5, 1, 0.85), 1.9)
	if n == 3:
		for edge in dun.edges:
			draw_line(pointToScreen(dun.room_centers[edge[0]]), pointToScreen(dun.room_centers[edge[1]]), Color(0.9, 0.98, 1), 8)
		
	if n >= 4: # RANDOM POINTS
		for point in random_room_points:
			draw_circle(pointToScreen(point),4, Color(0.8,0.1,0.08))

	if n >= 5: # HALLWAYS
		for line in lines:
			for i in range(line.size() - 1):
				draw_line(pointToScreen(line[i]), pointToScreen(line[i+1]), Color(1,0.09,0), 5.6)

func pointToScreen(point: Vector2) -> Vector2:
	var offset = Vector2(260, 70)
	var size = 50
	
	return offset + point*size

func _input(event):
	if event.is_action_pressed("ui_accept"):
		n += 1
		update()
