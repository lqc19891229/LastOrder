class_name OrderSpec
extends Resource
## 编辑器中可调整的订单模板；运行状态保存在 DeliveryOrder 中。

@export var order_id: StringName
@export var meal_name: String
@export var pickup_id: StringName
@export var dropoff_id: StringName
@export_range(1, 10000, 1) var reward: int = 25
@export_range(0, 1000, 1) var contribution: int = 3
@export_range(1.0, 3600.0, 1.0) var time_limit: float = 150.0
