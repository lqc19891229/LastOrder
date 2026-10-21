@tool
class_name PixelCity
extends Node2D
## 代码绘制的像素街区地面，坐标和碰撞使用同一套 2D 像素单位。

const BOUNDS := Rect2(-576, -448, 1152, 896)

func _draw() -> void:
	draw_rect(BOUNDS, Color("182532"))
	# 方砖、人行道与道路，细节保持整数坐标。
	for y in range(-448, 448, 16):
		for x in range(-576, 576, 16):
			var shade := Color("243746") if (absi(x / 16) + absi(y / 16)) % 3 == 0 else Color("21313f")
			draw_rect(Rect2(x, y, 15, 15), shade)
	_road(Rect2(-576, 84, 1152, 112), false)
	_road(Rect2(-64, -448, 128, 896), true)
	_road(Rect2(-576, -208, 1152, 96), false)
	for x in range(-544, 576, 48):
		if abs(x) > 96:
			draw_rect(Rect2(x, 138, 18, 2), Color("b9ad8c"))
			draw_rect(Rect2(x, -162, 18, 2), Color("657e88"))
	for y in range(-408, 424, 40):
		if (y < -224 or y > -96) and (y < 68 or y > 208):
			draw_rect(Rect2(-1, y, 2, 14), Color("b9ad8c"))
	# 斑马线与检修井，作为路口和位置记忆点。
	for n in range(6):
		draw_rect(Rect2(-57 + n * 20, 64, 11, 12), Color("9aaca5"))
		draw_rect(Rect2(76, 92 + n * 16, 12, 8), Color("9aaca5"))
	for at in [Vector2(100, 140), Vector2(-120, -160), Vector2(0, 280)]:
		draw_rect(Rect2(at - Vector2(7, 5), Vector2(14, 10)), Color("293b48"))
		draw_rect(Rect2(at - Vector2(5, 3), Vector2(10, 6)), Color("121d2a"))
		for dx in [-3, 0, 3]:
			draw_line(at + Vector2(dx, -2), at + Vector2(dx, 2), Color("526979"))
	# 克制的反光与路边小物。
	for at in [Vector2(-220, 150), Vector2(210, -145), Vector2(-34, 290), Vector2(355, 155)]:
		draw_rect(Rect2(at, Vector2(36, 3)), Color("39606c"))
		draw_rect(Rect2(at + Vector2(8, 4), Vector2(22, 2)), Color("2b4657"))
	for at in [Vector2(-110, 40), Vector2(108, -260), Vector2(-420, 246), Vector2(420, -280)]:
		_planter(at)
	for at in [Vector2(-128, 210), Vector2(126, 228), Vector2(120, -96)]:
		_lamp(at)
	# 地图外沿有可见矮墙，对应主场景中的边界碰撞。
	for edge in [Rect2(-576, -448, 1152, 8), Rect2(-576, 440, 1152, 8), Rect2(-576, -448, 8, 896), Rect2(568, -448, 8, 896)]:
		draw_rect(edge, Color("4b6270"))

func _road(rect: Rect2, vertical: bool) -> void:
	draw_rect(rect.grow(6), Color("52626a"))
	draw_rect(rect.grow(3), Color("3c4e5b"))
	draw_rect(rect, Color("101d2b"))
	if vertical:
		for y in range(int(rect.position.y), int(rect.end.y), 24):
			draw_rect(Rect2(rect.position.x + 4, y + 2, 1, 8), Color("263c4a"))
	else:
		for x in range(int(rect.position.x), int(rect.end.x), 32):
			draw_rect(Rect2(x + 2, rect.position.y + 4, 12, 1), Color("263c4a"))

func _planter(at: Vector2) -> void:
	draw_rect(Rect2(at + Vector2(0, 4), Vector2(21, 14)), Color("152230"))
	draw_rect(Rect2(at, Vector2(20, 14)), Color("657d80"))
	draw_rect(Rect2(at + Vector2(2, 1), Vector2(16, 5)), Color("152932"))
	for offset in [Vector2(3, -4), Vector2(8, -6), Vector2(13, -3)]:
		draw_rect(Rect2(at + offset, Vector2(5, 8)), Color("4c8a79"))
		draw_rect(Rect2(at + offset, Vector2(3, 3)), Color("85ad86"))

func _lamp(at: Vector2) -> void:
	draw_rect(Rect2(at + Vector2(-10, -6), Vector2(28, 18)), Color("e7be6710"))
	draw_rect(Rect2(at + Vector2(0, -27), Vector2(3, 30)), Color("1a2634"))
	draw_rect(Rect2(at + Vector2(0, -28), Vector2(14, 3)), Color("627c83"))
	draw_rect(Rect2(at + Vector2(8, -25), Vector2(8, 3)), Color("efd49b"))
