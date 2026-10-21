class_name Courier
extends CharacterBody2D
## 原生 2D 像素角色。脚底是原点，图形与碰撞分开；素材可替换为 AnimatedSprite2D。

@export var walk_speed := 72.0
@export var run_speed := 108.0
var controls_enabled := true
var facing := Vector2.DOWN
var _walk_time := 0.0
var _moving := false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if controls_enabled:
		direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := run_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity = direction * speed
	move_and_slide()
	_moving = direction.length_squared() > 0.01
	if _moving:
		_walk_time += delta * (12.0 if speed == run_speed else 8.0)
		facing = Vector2(direction.x, 0) if absf(direction.x) > absf(direction.y) else Vector2(0, direction.y)
	else:
		_walk_time = 0.0
	queue_redraw()

func _pixel_rect(at: Vector2, dimensions: Vector2, color: String) -> void:
	draw_rect(Rect2(at, dimensions), Color(color))

func _draw() -> void:
	var stride := 1.0 if _moving and int(_walk_time) % 2 == 0 else 0.0
	var bob := -1.0 if _moving and int(_walk_time) % 2 == 0 else 0.0
	_pixel_rect(Vector2(-7, -2), Vector2(14, 4), "111725aa")
	_pixel_rect(Vector2(-5, -6), Vector2(4, 6 - stride), "1a2237")
	_pixel_rect(Vector2(2, -6), Vector2(4, 5 + stride), "1a2237")
	_pixel_rect(Vector2(-5, -1 - stride), Vector2(4, 2), "8293a0")
	_pixel_rect(Vector2(2, stride), Vector2(4, 2), "8293a0")
	_pixel_rect(Vector2(-5, -14 + bob), Vector2(11, 9), "c45f4c")
	_pixel_rect(Vector2(-4, -14 + bob), Vector2(8, 6), "ec9770")
	_pixel_rect(Vector2(-7, -13 + bob + stride), Vector2(2, 7), "e2ae83")
	_pixel_rect(Vector2(6, -13 + bob - stride), Vector2(2, 7), "e2ae83")
	if facing == Vector2.UP:
		_pixel_rect(Vector2(-7, -15 + bob), Vector2(14, 11), "9a603f")
		_pixel_rect(Vector2(-6, -15 + bob), Vector2(12, 9), "e2b659")
		_pixel_rect(Vector2(-4, -13 + bob), Vector2(8, 2), "ffe4a0")
		_pixel_rect(Vector2(-1, -11 + bob), Vector2(2, 4), "4b8b83")
	elif facing.x != 0:
		var bag_x := -9.0 if facing.x > 0 else 5.0
		_pixel_rect(Vector2(bag_x, -15 + bob), Vector2(5, 10), "deb05c")
		_pixel_rect(Vector2(bag_x, -14 + bob), Vector2(5, 2), "ffe4a0")
	else:
		_pixel_rect(Vector2(-7, -14 + bob), Vector2(2, 8), "deb05c")
		_pixel_rect(Vector2(6, -14 + bob), Vector2(2, 8), "deb05c")
	_pixel_rect(Vector2(-4, -22 + bob), Vector2(9, 9), "293349")
	if facing != Vector2.UP:
		_pixel_rect(Vector2(-3, -19 + bob), Vector2(7, 6), "e2ae83")
		var eye_x := 2.0 if facing.x > 0 else (-3.0 if facing.x < 0 else -2.0)
		_pixel_rect(Vector2(eye_x, -17 + bob), Vector2(1, 1), "293349")
		if facing.x == 0:
			_pixel_rect(Vector2(2, -17 + bob), Vector2(1, 1), "293349")
	_pixel_rect(Vector2(-5, -23 + bob), Vector2(11, 4), "517f8a")
	_pixel_rect(Vector2(-5, -20 + bob), Vector2(12, 2), "78c0bc")
