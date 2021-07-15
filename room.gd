extends Node

class_name Room

var position: Vector2
var size: Vector2

func _init(rect: Rect2):
	self.position = rect.position
	self.size = rect.size

func getCenter():
	return position + size/2

func getRandomPoint(rng: RandomNumberGenerator = RandomNumberGenerator.new()):
	return position + Vector2(rng.randi()%int(size.x), rng.randi()%int(size.y))
