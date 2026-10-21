extends Node2D
## Godot 4.6 / 2D 俯视角。订单服务与视觉分离，坐标单位为像素。

const ORDER_FILES := ["a01", "a02", "a03", "a04", "a05", "a06"]
const INTERACTION_RADIUS := 24.0
const PIXELS_PER_METER := 16.0
var service: DeliveryService
var player: Courier
var hud: DeliveryHUD
var points: Dictionary[StringName, DeliveryPoint] = {}
@onready var _camera: Camera2D = $Camera2D

func _ready() -> void:
	_setup_input()
	service = $DeliveryService
	player = $Actors/Courier
	for child in $Points.get_children():
		if child is DeliveryPoint:
			points[child.point_id] = child
	var templates: Array[OrderSpec] = []
	for order_file in ORDER_FILES:
		var template := load("res://data/orders/%s.tres" % order_file) as OrderSpec
		if template != null:
			assert(points.has(template.pickup_id) and points.has(template.dropoff_id), "订单引用了不存在的取送点")
			templates.append(template)
	service.configure(templates)
	_camera.global_position = player.global_position.round()
	hud = DeliveryHUD.new()
	hud.name = "DeliveryHUD"
	hud.setup(service, player, points)
	add_child(hud)

func _setup_input() -> void:
	var bindings := {
		"move_forward": [KEY_W, KEY_UP], "move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"sprint": [KEY_SHIFT], "interact": [KEY_E],
		"terminal": [KEY_TAB, KEY_ESCAPE], "restart_shift": [KEY_F5]
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("terminal") and not event.is_echo():
		hud.set_app_open(not hud.app_open)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") and not event.is_echo():
		attempt_interaction()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart_shift") and not event.is_echo():
		get_tree().reload_current_scene()

func nearest_point() -> DeliveryPoint:
	var nearest: DeliveryPoint = null
	var distance := INTERACTION_RADIUS
	for point in points.values():
		var candidate := player.global_position.distance_to(point.global_position)
		if candidate <= distance:
			distance = candidate
			nearest = point
	return nearest

func attempt_interaction() -> bool:
	if hud.app_open:
		return false
	var point := nearest_point()
	if point == null:
		hud.show_toast("靠近地面标记后按 E。", false)
		return false
	return service.pickup_at(point.point_id) if point.is_pickup else service.deliver_at(point.point_id)

func _physics_process(_delta: float) -> void:
	if player != null:
		_camera.global_position = player.global_position.round()

func _process(_delta: float) -> void:
	if player == null or hud == null:
		return
	var point := nearest_point()
	if point != null and not hud.app_open:
		hud.set_interaction("E  %s · %s" % ["取餐" if point.is_pickup else "交付", point.display_name])
	else:
		hud.set_interaction("靠近标记按 E" if not service.active_orders().is_empty() else "Tab 打开城市通")
	for location in points.values():
		location.active = location.point_id == hud.target_id()
