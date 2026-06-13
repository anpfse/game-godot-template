extends State
## 玩家“待机”状态：无输入时停留，有输入时切换到 Move。

@onready var player: Player = owner as Player


func physics_update(_delta: float) -> void:
	if player.input_direction != Vector2.ZERO:
		transitioned.emit(self, "Move")
