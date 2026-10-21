class_name DeliveryHUD
extends CanvasLayer

const INK := Color("e8e5ce")
const MUTED := Color("9aafb6")
const CYAN := Color("80cbc0")
const AMBER := Color("ecc47a")
var service: DeliveryService
var player: Courier
var points: Dictionary[StringName, DeliveryPoint] = {}
var selected_id: StringName
var app_open := false
var _app_tab := 0
var _root: Control
var _balance: Label
var _active: VBoxContainer
var _overlay: Control
var _app_list: VBoxContainer
var _tab_buttons: Array[Button] = []
var _timers: Dictionary[Label, DeliveryOrder] = {}
var _prompt: Label
var _navigation: Label
var _toast: Label
var _toast_time := 0.0
var _map: StreetMap
var _cancel_dialog: ConfirmationDialog

func setup(order_service: DeliveryService, courier: Courier, locations: Dictionary[StringName, DeliveryPoint]) -> void:
	service = order_service
	player = courier
	points = locations

func _ready() -> void:
	_build()
	service.orders_changed.connect(_refresh)
	service.balance_changed.connect(_update_balance)
	service.feedback.connect(show_toast)
	_update_balance(service.money, service.contribution)
	_refresh()
	set_app_open(true)

func _style(color: Color, border: Color = Color("4b6570")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _label(text: String, font_size := 12, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = 24
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_stylebox_override("normal", _style(Color("263f4c")))
	button.add_theme_stylebox_override("hover", _style(Color("355665"), CYAN))
	button.add_theme_stylebox_override("pressed", _style(Color("3e646c"), CYAN))
	button.add_theme_stylebox_override("disabled", _style(Color("192a37")))
	return button

func _panel(parent: Node, pos: Vector2, dimensions: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.size = dimensions
	panel.add_theme_stylebox_override("panel", _style(Color("142331ee")))
	parent.add_child(panel)
	return panel

func _build() -> void:
	_root = Control.new()
	var theme := Theme.new()
	var font := load("res://assets/fonts/LastOrderCN.otf") as FontFile
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	theme.default_font = font
	theme.default_font_size = 12
	_root.theme = theme
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var bar := ColorRect.new()
	bar.color = Color("101c2cef")
	bar.position = Vector2.ZERO
	bar.size = Vector2(640, 41)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bar)
	var brand := VBoxContainer.new()
	brand.position = Vector2(10, 4)
	brand.add_theme_constant_override("separation", 0)
	_root.add_child(brand)
	brand.add_child(_label("最后一单", 18))
	brand.add_child(_label("LAST ORDER / 旧城区", 9, CYAN))
	_balance = _label("", 11)
	_balance.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_balance.position = Vector2(-285, 12)
	_balance.size = Vector2(275, 20)
	_balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_root.add_child(_balance)
	var active_panel := _panel(_root, Vector2(8, 52), Vector2(166, 65))
	_active = VBoxContainer.new()
	_active.add_theme_constant_override("separation", 4)
	active_panel.add_child(_active)
	var map_panel := _panel(_root, Vector2.ZERO, Vector2(132, 98))
	map_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	map_panel.offset_left = 8
	map_panel.offset_right = 140
	map_panel.offset_top = -126
	map_panel.offset_bottom = -28
	var map_column := VBoxContainer.new()
	map_column.add_theme_constant_override("separation", 3)
	map_panel.add_child(map_column)
	map_column.add_child(_label("旧城 / 青取橙送", 10, MUTED))
	_map = StreetMap.new()
	_map.player = player
	_map.points = points
	_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_column.add_child(_map)
	_navigation = _label("打开终端接单", 12)
	_navigation.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_navigation.position = Vector2(-175, -68)
	_navigation.size = Vector2(350, 20)
	_navigation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(_navigation)
	_prompt = _label("", 11, CYAN)
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.position = Vector2(-175, -45)
	_prompt.size = Vector2(350, 18)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(_prompt)
	var controls := _label("WASD 移动  Shift 快走  E 交互  Tab 终端  F5 重置", 9, MUTED)
	controls.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	controls.position = Vector2(-300, -18)
	controls.size = Vector2(600, 14)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(controls)
	_toast = _label("", 11)
	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_toast.position = Vector2(-300, 43)
	_toast.size = Vector2(600, 18)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(_toast)
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.04, 0.08, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(dim)
	var app := PanelContainer.new()
	app.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	app.offset_left = -221
	app.offset_right = 221
	app.offset_top = -160
	app.offset_bottom = 160
	app.add_theme_stylebox_override("panel", _style(Color("142331"), Color("6e8a92")))
	_overlay.add_child(app)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	app.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	var title := _label("城市通 / 官方平台", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var close := _button("返回 Tab")
	close.pressed.connect(set_app_open.bind(false))
	top.add_child(close)
	column.add_child(_label("最多两单 · 接单后计时，打开终端时计时继续", 10, CYAN))
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	column.add_child(tabs)
	for index in range(3):
		var button := _button("")
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_set_tab.bind(index))
		_tab_buttons.append(button)
		tabs.add_child(button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_app_list = VBoxContainer.new()
	_app_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_app_list)
	column.add_child(_label("靠近标记按 E 取送 · 首轮六单 · F5 重置", 10, MUTED))
	_cancel_dialog = ConfirmationDialog.new()
	_cancel_dialog.theme = theme
	_cancel_dialog.title = "取消订单"
	_cancel_dialog.dialog_text = "取消后本单没有收益。\n本轮无法重新接取。"
	_cancel_dialog.ok_button_text = "确认取消"
	_cancel_dialog.cancel_button_text = "继续配送"
	_root.add_child(_cancel_dialog)

func _clear(container: Control) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _refresh() -> void:
	_timers.clear()
	var active := service.active_orders()
	var selected := service.find_order(selected_id)
	if selected == null or not selected.is_active():
		selected_id = active[0].spec.order_id if not active.is_empty() else &""
	_clear(_active)
	_active.add_child(_label("进行中  %d / %d" % [active.size(), service.MAX_ACTIVE], 11, CYAN))
	if active.is_empty():
		_active.add_child(_label("暂无配送任务\n按 Tab 打开城市通接单", 11, MUTED))
	for order in active:
		var timer := _label("", 10, AMBER)
		_timers[timer] = order
		_active.add_child(timer)
		var text := "%s  %s" % [order.spec.order_id, order.spec.meal_name]
		if order.spec.order_id == selected_id:
			text = "› " + text
		var button := _button(text)
		button.pressed.connect(_navigate.bind(order.spec.order_id))
		_active.add_child(button)
	_render_app()

func _render_app() -> void:
	_clear(_app_list)
	var counts := [0, 0, 0]
	for order in service.orders:
		if order.status == DeliveryOrder.Status.AVAILABLE:
			counts[0] += 1
		elif order.is_active():
			counts[1] += 1
		else:
			counts[2] += 1
	for index in range(3):
		_tab_buttons[index].text = "%s  %d" % [["待接订单", "进行中", "记录"][index], counts[index]]
		_tab_buttons[index].modulate = CYAN if index == _app_tab else Color.WHITE
	var shown := 0
	for order in service.orders:
		var category := 0 if order.status == DeliveryOrder.Status.AVAILABLE else (1 if order.is_active() else 2)
		if category != _app_tab:
			continue
		shown += 1
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _style(Color("182f3a")))
		_app_list.add_child(card)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 6)
		card.add_child(box)
		box.add_child(_label("%s   %s" % [order.spec.order_id, order.spec.meal_name], 13))
		box.add_child(_label("%s  →  %s" % [_point_name(order.spec.pickup_id), _point_name(order.spec.dropoff_id)], 11, MUTED))
		box.add_child(_label("收入 %d   ·   贡献 +%d   ·   限时 %d 秒" % [order.spec.reward, order.spec.contribution, int(order.spec.time_limit)], 10, AMBER))
		if order.is_active():
			var timer := _label("", 11, CYAN)
			_timers[timer] = order
			box.add_child(timer)
		var actions := HBoxContainer.new()
		box.add_child(actions)
		if order.status == DeliveryOrder.Status.AVAILABLE:
			var accept_button := _button("接取订单" if service.active_orders().size() < service.MAX_ACTIVE else "两单已满")
			accept_button.disabled = service.active_orders().size() >= service.MAX_ACTIVE
			accept_button.pressed.connect(_accept.bind(order.spec.order_id))
			actions.add_child(accept_button)
		elif order.is_active():
			var navigate := _button("设为目标并返回街区")
			navigate.pressed.connect(_navigate.bind(order.spec.order_id))
			actions.add_child(navigate)
			var cancel_button := _button("取消本单")
			cancel_button.pressed.connect(_ask_cancel.bind(order.spec.order_id))
			actions.add_child(cancel_button)
		else:
			box.add_child(_label(order.status_text(), 11, CYAN if order.status == DeliveryOrder.Status.DELIVERED else AMBER))
	if shown == 0:
		_app_list.add_child(_label("这里暂时没有订单。", 12, MUTED))

func _set_tab(index: int) -> void:
	_app_tab = index
	_refresh()

func _accept(order_id: StringName) -> void:
	service.accept(order_id)

func _ask_cancel(order_id: StringName) -> void:
	for callback in _cancel_dialog.confirmed.get_connections():
		_cancel_dialog.confirmed.disconnect(callback.callable)
	_cancel_dialog.confirmed.connect(_cancel.bind(order_id), CONNECT_ONE_SHOT)
	_cancel_dialog.popup_centered(Vector2i(300, 120))

func _cancel(order_id: StringName) -> void:
	service.cancel(order_id)

func _navigate(order_id: StringName) -> void:
	selected_id = order_id
	set_app_open(false)
	_refresh()

func set_app_open(value: bool) -> void:
	app_open = value
	_overlay.visible = value
	player.controls_enabled = not value
	if value:
		player.velocity = Vector2.ZERO
	_toast.position.y = 1 if value else 43
	if not value:
		_cancel_dialog.hide()

func _point_name(point_id: StringName) -> String:
	return points[point_id].display_name if points.has(point_id) else String(point_id)

func target_id() -> StringName:
	var order := service.find_order(selected_id)
	return order.destination_id() if order != null and order.is_active() else &""

func set_interaction(text: String) -> void:
	_prompt.text = text

func show_toast(message: String, success: bool) -> void:
	_toast.text = message
	_toast.add_theme_color_override("font_color", CYAN if success else AMBER)
	_toast_time = 4.0
	_toast.position.y = 1 if app_open else 43
	# 置于终端上方，接单时也能看到反馈。
	_root.move_child(_toast, _root.get_child_count() - 1)

func _update_balance(money: int, contribution: int) -> void:
	_balance.text = "收入 %d   /   贡献 %d   /   送达 %d" % [money, contribution, service.completed_count()]

func _process(delta: float) -> void:
	for label in _timers:
		if not is_instance_valid(label):
			continue
		var order := _timers[label]
		var seconds := int(ceil(order.remaining))
		label.text = "%02d:%02d  ·  %s" % [seconds / 60, seconds % 60, order.status_text()]
		label.add_theme_color_override("font_color", AMBER if seconds <= 30 else CYAN)
	_toast_time -= delta
	_toast.visible = _toast_time > 0.0
	var destination := target_id()
	_map.target_id = destination
	if points.has(destination):
		_navigation.text = "前往 %s   ·   %d m" % [_point_name(destination), int(player.global_position.distance_to(points[destination].global_position) / 16.0)]
	elif service.completed_count() > 0:
		_navigation.text = "已完成 %d 单，打开终端继续接单" % service.completed_count()
	else:
		_navigation.text = "打开终端，接取第一笔订单"
