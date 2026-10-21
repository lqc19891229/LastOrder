extends SceneTree
## 无外部测试插件。覆盖边界、结算幂等和跨订单行为。

var _checks := 0
var _failures := 0
var _completed_signals := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FAIL: " + description)

func _template(id: StringName, pickup: StringName = &"shop", dropoff: StringName = &"home", duration := 60.0) -> OrderSpec:
	var result := OrderSpec.new()
	result.order_id = id
	result.meal_name = "测试餐品"
	result.pickup_id = pickup
	result.dropoff_id = dropoff
	result.time_limit = duration
	result.reward = 30
	result.contribution = 4
	return result

func _run() -> void:
	var service := DeliveryService.new()
	service.clock_running = false
	root.add_child(service)
	service.order_completed.connect(func(_id: StringName) -> void: _completed_signals += 1)
	var templates: Array[OrderSpec] = [_template(&"a"), _template(&"b", &"other", &"home2"), _template(&"c")]
	service.configure(templates)
	_check(not service.accept(&"missing"), "无效编号不能接单")
	_check(service.accept(&"a"), "可接订单进入待取餐")
	_check(not service.accept(&"a"), "不能重复接单")
	_check(not service.deliver_at(&"home"), "未取餐不能交付")
	_check(not service.pickup_at(&"wrong"), "错误餐馆不能取餐")
	_check(service.accept(&"b"), "允许同时接两单")
	_check(not service.accept(&"c"), "超过上限时拒绝接单")
	service.advance_time(12.5)
	_check(is_equal_approx(service.find_order(&"a").remaining, 47.5), "接单后真实倒计时")
	_check(is_equal_approx(service.find_order(&"c").remaining, 60.0), "未接订单不倒计时")
	_check(service.pickup_at(&"shop"), "正确餐馆可以取餐")
	_check(service.find_order(&"a").status == DeliveryOrder.Status.PICKED_UP, "取餐后进入配送中")
	_check(service.find_order(&"b").status == DeliveryOrder.Status.ACCEPTED, "取餐不影响其他餐馆订单")
	_check(not service.pickup_at(&"shop"), "同一餐品不能重复取餐")
	_check(not service.deliver_at(&"wrong"), "错误地址不能交付")
	_check(service.deliver_at(&"home"), "正确地址可以结算")
	_check(service.money == 30 and service.contribution == 4, "报酬和贡献按订单结算")
	_check(not service.deliver_at(&"home"), "不能重复结算")
	_check(_completed_signals == 1, "完成信号只发送一次")
	_check(not service.cancel(&"a"), "终态订单不能取消")
	_check(service.accept(&"c"), "完成订单释放接单名额")
	_check(service.cancel(&"c"), "进行中订单可以取消")
	_check(not service.accept(&"c"), "已取消订单本轮不可重接")
	service.advance_time(100.0)
	_check(service.find_order(&"b").status == DeliveryOrder.Status.FAILED, "超时进入失败终态")
	_check(service.active_orders().is_empty(), "超时释放名额")
	_check(not service.pickup_at(&"other"), "超时订单不能继续取餐")
	_check(service.money == 30, "取消或超时不发奖励")
	_check(service.find_order(&"a").status == DeliveryOrder.Status.DELIVERED, "时间推进不改变已完成订单")
	# 同店取两单及同址交付；一次交互分别结算，避免批量漏单。
	var batch: Array[OrderSpec] = [_template(&"x"), _template(&"y")]
	service.configure(batch)
	_check(service.money == 0 and service.contribution == 0, "重置清空本轮收入")
	service.accept(&"x")
	service.accept(&"y")
	_check(service.pickup_at(&"shop"), "支持同店批量取餐")
	_check(service.find_order(&"x").status == DeliveryOrder.Status.PICKED_UP and service.find_order(&"y").status == DeliveryOrder.Status.PICKED_UP, "两单均装入配送状态")
	_check(service.deliver_at(&"home"), "支持同址批量交付")
	_check(service.money == 60 and service.contribution == 8, "批量结算总额准确")
	_check(service.completed_count() == 2, "送达数量准确")
	# 到截止时间即失败，已取餐也不能绕过截止状态。
	var expiry: Array[OrderSpec] = [_template(&"late", &"shop", &"home", 1.0)]
	service.configure(expiry)
	service.accept(&"late")
	service.pickup_at(&"shop")
	service.advance_time(1.0)
	_check(service.find_order(&"late").remaining == 0.0, "倒计时不小于零")
	_check(not service.deliver_at(&"home"), "已取餐订单超时也不能结算")
	_check(service.money == 0, "超时交付不产生收入")
	service.advance_time(-4.0)
	_check(service.find_order(&"late").remaining == 0.0, "负时间不回拨计时")
	print("DELIVERY TESTS: %d checks, %d failures" % [_checks, _failures])
	service.queue_free()
	await process_frame
	quit(0 if _failures == 0 else 1)
