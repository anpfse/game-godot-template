extends State
## 玩家“移动”状态：有输入时移动，无输入时切回 Idle。

@onready var player: Player = owner as Player


func physics_update(_delta: float) -> void:
	if player.input_direction == Vector2.ZERO:
		transitioned.emit(self, "Idle")
