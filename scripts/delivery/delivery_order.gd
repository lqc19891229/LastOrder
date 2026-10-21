class_name DeliveryOrder
extends RefCounted

enum Status { AVAILABLE, ACCEPTED, PICKED_UP, DELIVERED, FAILED, CANCELLED }

var spec: OrderSpec
var status: Status = Status.AVAILABLE
var remaining: float

func _init(template: OrderSpec) -> void:
	spec = template
	remaining = template.time_limit

func is_active() -> bool:
	return status == Status.ACCEPTED or status == Status.PICKED_UP

func status_text() -> String:
	match status:
		Status.AVAILABLE: return "可接单"
		Status.ACCEPTED: return "待取餐"
		Status.PICKED_UP: return "配送中"
		Status.DELIVERED: return "已送达"
		Status.FAILED: return "已超时"
		Status.CANCELLED: return "已取消"
	return ""

func destination_id() -> StringName:
	return spec.dropoff_id if status == Status.PICKED_UP else spec.pickup_id
