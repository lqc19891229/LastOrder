@tool
class_name DeliveryPoint
extends Node2D

@export var point_id: StringName
@export var display_name: String
@export var is_pickup := false
var active := false
var _elapsed := 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()

func _draw() -> void:
	var color := Color("80cbc0") if is_pickup else Color("ecc47a")
	var offset := 2.0 if active and int(_elapsed * 3.0) % 2 == 0 else 0.0
	draw_rect(Rect2(-10, -5, 20, 10), Color("11192999"))
	for side in [-1.0, 1.0]:
		var x: float = side * (11.0 + offset)
		draw_line(Vector2(x, -6), Vector2(x, 6), color, 1.0)
		draw_line(Vector2(x, -6), Vector2(x - side * 4, -6), color, 1.0)
		draw_line(Vector2(x, 6), Vector2(x - side * 4, 6), color, 1.0)
	draw_rect(Rect2(-2, -2, 4, 4), color)
	if active:
		draw_rect(Rect2(-2, -13 - offset, 4, 3), color)
