extends Node

class_name Room

var position: Vector2
var size: Vector2

func _init(rect: Rect2):
	self.position = rect.position
	self.size = rect.size

func getCenter():
	return position + size/2

func getRandomPoint(_seed: String):
	var rng = RandomNumberGenerator.new()
	rng.set_seed(hash(_seed + "__ROOM_RANDOM_POINT__"))
	return position + Vector2(rng.randi()%int(size.x), rng.randi()%int(size.y))
