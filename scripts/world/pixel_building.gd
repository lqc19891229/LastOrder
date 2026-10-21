@tool
class_name PixelBuilding
extends Node2D
## 像素建筑占位。脚底原点用于 Y 排序，场景内碰撞只覆盖地面占地。

@export var title := "回声面馆":
	set(value):
		title = value
		queue_redraw()
@export_range(96, 224, 16) var building_width := 160:
	set(value):
		building_width = value
		queue_redraw()
@export_range(80, 192, 16) var building_height := 112:
	set(value):
		building_height = value
		queue_redraw()
@export_enum("餐馆", "住区", "维修站", "诊所", "普通建筑") var kind := 0:
	set(value):
		kind = value
		queue_redraw()
var _font: Font

func _ready() -> void:
	_font = load("res://assets/fonts/LastOrderCN.otf") as Font
	queue_redraw()

func _draw() -> void:
	var w := float(building_width)
	var h := float(building_height)
	var x := -w / 2.0
	var accent := Color("81c8bd") if kind == 0 else Color("e5ba74")
	if kind == 3:
		accent = Color("c199c6")
	draw_rect(Rect2(x + 5, -28, w + 12, 36), Color("101724aa"))
	draw_rect(Rect2(x, -h, w, h), Color("131e2c"))
	draw_rect(Rect2(x + 3, -h + 3, w - 6, h - 4), Color("3c5564"))
	# 屋顶与朝街立面。
	draw_rect(Rect2(x + 3, -h + 3, w - 6, 40), Color("566c77"))
	draw_rect(Rect2(x + 7, -h + 7, w - 14, 30), Color("304858"))
	draw_rect(Rect2(x + 7, -h + 7, w - 14, 2), Color("7b9094"))
	for dx in range(12, building_width - 12, 12):
		draw_rect(Rect2(x + dx, -h + 10, 1, 23), Color("3e5968"))
	# 空调、通风叶片与屋顶管线。
	draw_rect(Rect2(x + 16, -h + 12, 28, 18), Color("202f41"))
	draw_rect(Rect2(x + 17, -h + 10, 26, 16), Color("799092"))
	for n in range(5):
		draw_rect(Rect2(x + 20 + n * 4, -h + 12, 2, 11), Color("3f5964"))
	draw_rect(Rect2(x + 48, -h + 18, w - 68, 2), Color("263949"))
	draw_rect(Rect2(x + 48, -h + 17, w - 68, 1), Color("81999a"))
	for level in range(int(-h + 50), -42, 22):
		for col in range(14, building_width - 20, 28):
			draw_rect(Rect2(x + col, level, 16, 13), Color("1c2f40"))
			draw_rect(Rect2(x + col + 2, level + 2, 12, 8), Color("d5bd87") if col % 3 != 0 else Color("6fa0a7"))
			draw_rect(Rect2(x + col + 7, level + 2, 1, 9), Color("405c68"))
	# 招牌不烘焙文字，方便改店名与本地化。
	draw_rect(Rect2(x - 3, -44, w + 6, 21), Color("142432"))
	draw_rect(Rect2(x - 3, -44, w + 6, 2), accent)
	draw_rect(Rect2(x - 3, -25, w + 6, 2), accent.darkened(0.35))
	if _font != null:
		var text_width := _font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		draw_string(_font, Vector2(-text_width / 2.0, -29), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, accent)
	# 店面、门窗、台阶。
	draw_rect(Rect2(-12, -21, 24, 21), Color("152331"))
	draw_rect(Rect2(-9, -19, 18, 17), Color("829a9a"))
	draw_rect(Rect2(-7, -18, 14, 13), Color("2b4d5c"))
	draw_rect(Rect2(4, -10, 2, 2), Color("e7c994"))
	for side in [-1, 1]:
		var wx := float(side * 40 - 14)
		draw_rect(Rect2(wx, -20, 28, 15), Color("142635"))
		draw_rect(Rect2(wx + 2, -18, 24, 11), accent.darkened(0.35))
		draw_rect(Rect2(wx + 4, -16, 20, 2), accent)
	draw_rect(Rect2(-17, 0, 34, 3), Color("667c84"))
	draw_rect(Rect2(-20, 3, 40, 3), Color("344c5b"))
	if kind == 0:
		for dx in [-1, 1]:
			draw_rect(Rect2(dx * 64 - 4, -24, 8, 12), Color("e68d69"))
			draw_rect(Rect2(dx * 64 - 2, -23, 4, 10), Color("f6cd87"))
	if kind == 2:
		draw_rect(Rect2(x + 6, -20, 9, 18), Color("9d794b"))
		for n in range(4):
			draw_rect(Rect2(x + 6, -20 + n * 5, 9, 2), Color("f0c273"))
	if kind == 3:
		draw_rect(Rect2(w / 2 - 18, -h + 13, 4, 16), accent)
		draw_rect(Rect2(w / 2 - 24, -h + 19, 16, 4), accent)
