extends CharacterBody2D
class_name Player
## 通用玩家（Player）
##
## 模板自带的最小化玩家示例：俯视角八方向移动，由 StateMachine（Idle/Move）
## 驱动动画切换。**这是占位演示，开新项目时可直接删除或替换**为你自己的
## 角色控制器（平台跳跃、刚体等）。
##
## 同时演示了存档协议：实现 save_data() / load_data() 即可被 SaveManager 持久化。

@export var speed: float = 200.0
## 加速/减速的插值速率（越大越灵敏）。
@export var acceleration: float = 12.0

## 由状态读取的当前输入方向（单位向量）。
var input_direction: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := input_direction * speed
	velocity = velocity.lerp(target, minf(acceleration * delta, 1.0))
	move_and_slide()


# --- 存档协议（供 SaveManager 收集/恢复）---

func save_data() -> Dictionary:
	return {"x": global_position.x, "y": global_position.y}


func load_data(data: Dictionary) -> void:
	global_position = Vector2(data.get("x", global_position.x), data.get("y", global_position.y))
