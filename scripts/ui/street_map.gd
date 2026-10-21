class_name StreetMap
extends Control

var player: Node2D
var points: Dictionary[StringName, DeliveryPoint] = {}
var target_id: StringName

func _ready() -> void:
	custom_minimum_size = Vector2(116, 62)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	queue_redraw()

func project_point(world: Vector2) -> Vector2:
	return Vector2((world.x + 576.0) / 1152.0 * size.x, (world.y + 448.0) / 896.0 * size.y).round()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("111e2c"))
	var street := Color("304955")
	draw_line(project_point(Vector2(-568, 140)), project_point(Vector2(568, 140)), street, 6)
	draw_line(project_point(Vector2(0, -440)), project_point(Vector2(0, 440)), street, 8)
	draw_line(project_point(Vector2(-568, -160)), project_point(Vector2(568, -160)), street, 5)
	if is_instance_valid(player) and points.has(target_id):
		draw_dashed_line(project_point(player.global_position), project_point(points[target_id].global_position), Color("94b7bc"), 1.0, 3.0)
	for point in points.values():
		var pos := project_point(point.global_position)
		var color := Color("80cbc0") if point.is_pickup else Color("ecc47a")
		draw_rect(Rect2(pos - Vector2(2, 2), Vector2(4, 4)), color)
		if point.point_id == target_id:
			draw_rect(Rect2(pos - Vector2(4, 4), Vector2(8, 8)), Color.WHITE, false)
	if is_instance_valid(player):
		var pos := project_point(player.global_position)
		draw_rect(Rect2(pos - Vector2(2, 2), Vector2(4, 4)), Color.WHITE)
