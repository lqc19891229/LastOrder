extends SceneTree
## 真实主场景集成检查：输入、移动、空间交互和 UI 更新。

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FAIL: " + description)

func _press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	root.push_input(event)
	await process_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	root.push_input(event)
	await process_frame

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	scene.service.clock_running = false
	_check(scene is Node2D and scene.player is CharacterBody2D, "场景与角色均为原生 2D")
	_check(scene.get_node("Camera2D") is Camera2D, "使用 2D 跟随相机")
	_check(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "开启整倍数像素缩放")
	_check(scene.service.orders.size() == 6, "加载六笔实际资源订单")
	_check(scene.points.size() == 5, "地图包含全部取送点")
	_check(scene.hud.app_open, "初次进入显示接单终端")
	_check(not scene.player.controls_enabled, "终端打开时禁止角色移动")
	# 走真实 UI 按钮的回调，而不是通过测试直接改状态。
	var accept_buttons = scene.hud._app_list.find_children("*", "Button", true, false)
	_check(not accept_buttons.is_empty(), "终端真实生成可接单按钮")
	accept_buttons[0].pressed.emit()
	scene.hud._navigate(&"A01")
	_check(scene.hud.target_id() == &"noodle", "接单后导航指向取餐点")
	await _press("interact")
	_check(scene.service.find_order(&"A01").status == DeliveryOrder.Status.ACCEPTED, "远离取餐点时按交互无效")
	var old_position: Vector2 = scene.player.global_position
	Input.action_press("move_left")
	for frame in range(30):
		await physics_frame
	Input.action_release("move_left")
	_check(scene.player.global_position.x < old_position.x - 20.0, "2D 物理移动输入实际有效")
	# 到店并从输入层触发 E；随后检查目标自动切换。
	scene.player.global_position = scene.points[&"noodle"].global_position + Vector2(25, 0)
	scene.player.velocity = Vector2.ZERO
	await physics_frame
	await _press("interact")
	_check(scene.service.find_order(&"A01").status == DeliveryOrder.Status.ACCEPTED, "超过 24 像素交互半径不能取餐")
	scene.player.global_position = scene.points[&"noodle"].global_position + Vector2(0, 16)
	scene.player.velocity = Vector2.ZERO
	await physics_frame
	await _press("interact")
	_check(scene.service.find_order(&"A01").status == DeliveryOrder.Status.PICKED_UP, "到店通过 E 完成取餐")
	_check(scene.hud.target_id() == &"residence", "取餐后导航切换到顾客")
	Input.action_press("move_forward")
	for frame in range(80):
		await physics_frame
	Input.action_release("move_forward")
	_check(scene.player.global_position.y >= 71.0, "建筑实体碰撞阻止角色穿墙")
	scene.player.global_position = scene.points[&"workshop"].global_position + Vector2(0, 16)
	scene.player.velocity = Vector2.ZERO
	await physics_frame
	await _press("interact")
	_check(scene.service.money == 0, "错误地址不能交付")
	scene.player.global_position = scene.points[&"residence"].global_position + Vector2(0, 16)
	scene.player.velocity = Vector2.ZERO
	await physics_frame
	await _press("interact")
	_check(scene.service.money == 28 and scene.service.contribution == 3, "真实场景完成一次取送结算")
	_check(scene.service.active_orders().is_empty(), "交付后清空进行中订单")
	await _press("interact")
	_check(scene.service.money == 28, "场景重复交互不重复发钱")
	# 打开终端也不能暂停订单计时。
	scene.hud.set_app_open(true)
	scene.hud._accept(&"A02")
	scene.hud._ask_cancel(&"A02")
	_check(scene.hud._cancel_dialog.visible, "取消订单前显示确认窗口")
	scene.hud._cancel_dialog.confirmed.emit()
	scene.hud._cancel_dialog.hide()
	_check(scene.service.find_order(&"A02").status == DeliveryOrder.Status.CANCELLED, "确认窗口连接正确订单并取消")
	scene.hud._accept(&"A03")
	scene.service.advance_time(200.0)
	_check(scene.service.find_order(&"A03").status == DeliveryOrder.Status.FAILED, "终端打开时超时仍正常处理")
	_check(scene.hud.target_id() == &"", "失败后清理导航目标")
	await _press("terminal")
	_check(not scene.hud.app_open and scene.player.controls_enabled, "终端快捷键关闭 UI 并恢复移动")
	await _press("terminal")
	_check(scene.hud.app_open and not scene.player.controls_enabled, "终端快捷键打开 UI 并停止移动")
	await _press("restart_shift")
	await process_frame
	var restarted := current_scene
	_check(restarted != null and restarted != scene, "重置快捷键重新加载场景")
	_check(restarted.service.money == 0 and restarted.service.active_orders().is_empty(), "重新开始清空本轮收入和订单")
	print("SCENE TESTS: %d checks, %d failures" % [_checks, _failures])
	restarted.queue_free()
	await process_frame
	quit(0 if _failures == 0 else 1)
