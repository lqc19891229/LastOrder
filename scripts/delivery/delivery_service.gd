class_name DeliveryService
extends Node
## 外卖领域逻辑，不依赖玩家、地图或 HUD。所有状态变更必须经过这里。

signal orders_changed
signal balance_changed(money: int, contribution: int)
signal feedback(message: String, success: bool)
signal order_completed(order_id: StringName)

const MAX_ACTIVE := 2
var orders: Array[DeliveryOrder] = []
var money: int = 0
var contribution: int = 0
var clock_running := true
var _by_id: Dictionary[StringName, DeliveryOrder] = {}

func configure(templates: Array[OrderSpec]) -> void:
	orders.clear()
	_by_id.clear()
	money = 0
	contribution = 0
	for template in templates:
		if template == null or template.order_id == &"" or _by_id.has(template.order_id):
			push_error("订单编号为空或重复，已跳过无效模板。")
			continue
		if template.pickup_id == &"" or template.dropoff_id == &"" or template.time_limit <= 0.0:
			push_error("订单取送点或时限无效，已跳过模板。")
			continue
		var order := DeliveryOrder.new(template)
		orders.append(order)
		_by_id[template.order_id] = order
	orders_changed.emit()
	balance_changed.emit(money, contribution)

func _process(delta: float) -> void:
	if clock_running:
		advance_time(delta)

func advance_time(seconds: float) -> void:
	if seconds <= 0.0:
		return
	var changed := false
	for order in orders:
		if order.is_active():
			order.remaining = maxf(0.0, order.remaining - seconds)
			if order.remaining <= 0.0:
				order.status = DeliveryOrder.Status.FAILED
				changed = true
				feedback.emit("订单 %s 已超时，本单不结算。" % order.spec.order_id, false)
	if changed:
		orders_changed.emit()

func find_order(order_id: StringName) -> DeliveryOrder:
	return _by_id.get(order_id) as DeliveryOrder

func active_orders() -> Array[DeliveryOrder]:
	var result: Array[DeliveryOrder] = []
	for order in orders:
		if order.is_active():
			result.append(order)
	return result

func completed_count() -> int:
	var result := 0
	for order in orders:
		if order.status == DeliveryOrder.Status.DELIVERED:
			result += 1
	return result

func accept(order_id: StringName) -> bool:
	var order := find_order(order_id)
	if order == null:
		return _say("找不到这笔订单。", false)
	if order.status != DeliveryOrder.Status.AVAILABLE:
		return _say("这笔订单已经处理过了。", false)
	if active_orders().size() >= MAX_ACTIVE:
		return _say("最多同时接两单，请先完成或取消现有订单。", false)
	order.status = DeliveryOrder.Status.ACCEPTED
	order.remaining = order.spec.time_limit
	orders_changed.emit()
	return _say("已接单 %s，请前往餐馆取餐。" % order_id, true)

func pickup_at(point_id: StringName) -> bool:
	var picked := 0
	for order in orders:
		if order.status == DeliveryOrder.Status.ACCEPTED and order.spec.pickup_id == point_id:
			order.status = DeliveryOrder.Status.PICKED_UP
			picked += 1
	if picked == 0:
		return _say("这里没有已接的待取订单。", false)
	orders_changed.emit()
	return _say("已取餐 %d 单，请送往对应地址。" % picked, true)

func deliver_at(point_id: StringName) -> bool:
	var delivered := 0
	var earned := 0
	var points := 0
	var ids: Array[StringName] = []
	for order in orders:
		if order.status == DeliveryOrder.Status.PICKED_UP and order.spec.dropoff_id == point_id:
			# 先写终态再发通知，重复交互不能重复领取奖励。
			order.status = DeliveryOrder.Status.DELIVERED
			earned += order.spec.reward
			points += order.spec.contribution
			delivered += 1
			ids.append(order.spec.order_id)
	if delivered == 0:
		return _say("这里没有可交付的餐品，请确认地址并先取餐。", false)
	money += earned
	contribution += points
	orders_changed.emit()
	balance_changed.emit(money, contribution)
	for order_id in ids:
		order_completed.emit(order_id)
	return _say("送达 %d 单！收入 +%d，贡献 +%d。" % [delivered, earned, points], true)

func cancel(order_id: StringName) -> bool:
	var order := find_order(order_id)
	if order == null or not order.is_active():
		return _say("这笔订单无法取消。", false)
	order.status = DeliveryOrder.Status.CANCELLED
	orders_changed.emit()
	return _say("已取消 %s，本单无收益。" % order_id, true)

func _say(message: String, success: bool) -> bool:
	feedback.emit(message, success)
	return success
