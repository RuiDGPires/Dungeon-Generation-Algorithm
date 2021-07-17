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

func intersects(other: Room):
	return Rect2(position-Vector2(1,1), size+Vector2(2,2)).intersects(Rect2(other.position, other.size))

func direction(p1: Vector2, p2: Vector2, p3: Vector2):
	return (p3 - p1).cross(p2 - p1)
	
func lineIntersects(p1: Vector2, p2: Vector2) -> bool:
	var a = lineCrossesLine(p1, p2, position, position + Vector2(size.x, 0))
	var b = lineCrossesLine(p1, p2, position, position + Vector2(0, size.y))
	var c = lineCrossesLine(p1, p2, position + Vector2(size.x, 0), position + Vector2(size.x, size.y))
	var d = lineCrossesLine(p1, p2, position + Vector2(0, size.y), position + Vector2(size.x, size.y))
	
	return a or b or c or d
	
func lineCrossesLine(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 = direction(p3, p4, p1)
	var d2 = direction(p3, p4, p2)
	var d3 = direction(p1, p2, p3)
	var d4 = direction(p1, p2, p4)

	if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and \
		((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
		return true

	elif d1 == 0 and onSegment(p3, p4, p1):
		return true
	elif d2 == 0 and onSegment(p3, p4, p2):
		return true
	elif d3 == 0 and onSegment(p1, p2, p3):
		return true
	elif d4 == 0 and onSegment(p1, p2, p4):
		return true
	else:
		return false
		
func onSegment(p1: Vector2, p2: Vector2, p: Vector2):
	return min(p1.x, p2.x) <= p.x and p.x <= max(p1.x, p2.x) and min(p1.y, p2.y) <= p.y and p.y <= max(p1.y, p2.y)

