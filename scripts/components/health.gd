extends Node
class_name HealthComponent
## 生命值组件（HealthComponent）
##
## 一个可复用的“组件式”示例：把它作为子节点挂到任意实体上，
## 即可获得受伤、治疗、死亡逻辑，无需修改实体本体代码。
## 这是模板推荐的组合（组合优于继承）写法，可按需删除或扩展。

signal damaged(amount: float, current: float)
signal healed(amount: float, current: float)
signal died

@export var max_health: float = 100.0

var current_health: float


func _ready() -> void:
	current_health = max_health


## 造成伤害。amount 应为正数。
func take_damage(amount: float) -> void:
	if amount <= 0.0 or is_dead():
		return
	current_health = maxf(current_health - amount, 0.0)
	damaged.emit(amount, current_health)
	if current_health == 0.0:
		died.emit()


## 治疗。amount 应为正数。
func heal(amount: float) -> void:
	if amount <= 0.0 or is_dead():
		return
	current_health = minf(current_health + amount, max_health)
	healed.emit(amount, current_health)


func is_dead() -> bool:
	return current_health <= 0.0


## 当前生命值百分比（0.0~1.0）。
func get_ratio() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0
