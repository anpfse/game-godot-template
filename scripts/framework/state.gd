extends Node
class_name State
## 状态基类（State）
##
## 配合 StateMachine 使用。每个具体状态继承本类并重写需要的虚方法。
## 通过发出 transitioned 信号请求切换到另一个状态。
##
## 示例：
##   func physics_update(delta):
##       if Input.is_action_just_pressed("jump"):
##           transitioned.emit(self, "Jump")

## 请求状态切换。state 为当前状态自身，new_state_name 为目标状态节点名。
signal transitioned(state: State, new_state_name: String)


## 进入该状态时调用一次。
func enter() -> void:
	pass


## 离开该状态时调用一次。
func exit() -> void:
	pass


## 每帧逻辑更新（对应 _process）。
func update(_delta: float) -> void:
	pass


## 每物理帧更新（对应 _physics_process）。
func physics_update(_delta: float) -> void:
	pass


## 处理未消费的输入事件（对应 _unhandled_input）。
func handle_input(_event: InputEvent) -> void:
	pass
