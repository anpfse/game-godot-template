extends Node
class_name StateMachine
## 有限状态机（StateMachine）
##
## 把若干 State 子节点组织起来，按当前状态转发 process / physics_process /
## input，并响应状态发出的 transitioned 信号完成切换。
##
## 用法：
##   - 作为某个角色节点的子节点，名为 "StateMachine"
##   - 把各 State 脚本挂到它的子节点上
##   - 在检视面板把 initial_state 指向初始状态节点

## 初始状态节点。
@export var initial_state: State

## 当前激活的状态。
var current_state: State


func _ready() -> void:
	# 等父节点就绪，避免状态 enter() 时访问尚未初始化的成员。
	await owner.ready

	for child in get_children():
		if child is State:
			child.transitioned.connect(_on_state_transitioned)

	if initial_state != null:
		current_state = initial_state
		current_state.enter()


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)


## 响应状态切换请求。
func _on_state_transitioned(state: State, new_state_name: String) -> void:
	# 只接受当前状态发起的切换。
	if state != current_state:
		return
	var new_state := get_node_or_null(NodePath(new_state_name)) as State
	if new_state == null:
		push_error("StateMachine 找不到目标状态：%s" % new_state_name)
		return
	current_state.exit()
	current_state = new_state
	current_state.enter()
