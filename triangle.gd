extends Node

class_name Triangle

var points: Array

func _init(p1: Vector2, p2: Vector2, p3: Vector2):
	points = []
	points.append(p1)
	points.append(p2)
	points.append(p3)

func getArea():
	return abs((points[0].x * (points[1].y - points[2].y) + points[1].x * (points[2].y - points[0].y)
				+ points[2].x * (points[0].y - points[1].y)) / 2.0)
 

func _to_string():
	return str(points)

