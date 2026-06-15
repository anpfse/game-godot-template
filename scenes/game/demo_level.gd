extends Node2D
## 示例关卡（DemoLevel）
##
## 把各系统串联起来的演示场景：玩家移动、暂停菜单、存档/读档。
## **开新项目时整体替换为你的真实关卡即可。**
##
## 存档协议：本场景实现 save_progress() / load_progress()，
## 由暂停菜单的“保存游戏”按钮调用。
const SAVE_SLOT := 0
const PLAY_AREA := Rect2(0, 0, 1280, 720)
const GRID_SIZE := 64


func _draw() -> void:
	draw_rect(PLAY_AREA, Color("172033"))
	for x in range(0, int(PLAY_AREA.size.x) + 1, GRID_SIZE):
		draw_line(Vector2(x, 0), Vector2(x, PLAY_AREA.size.y), Color("263550"), 1.0)
	for y in range(0, int(PLAY_AREA.size.y) + 1, GRID_SIZE):
		draw_line(Vector2(0, y), Vector2(PLAY_AREA.size.x, y), Color("263550"), 1.0)
	draw_rect(PLAY_AREA, Color("61dafb"), false, 4.0)
	draw_circle(Vector2(240, 180), 36.0, Color("ffca5c"))
	draw_circle(Vector2(1040, 180), 36.0, Color("ff6b8a"))
	draw_circle(Vector2(240, 540), 36.0, Color("7ee787"))
	draw_circle(Vector2(1040, 540), 36.0, Color("bc8cff"))


func _ready() -> void:
	# 若已有存档（来自“继续”），读回进度。
	if SaveManager.has_save(SAVE_SLOT):
		load_progress()


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		player.global_position = player.global_position.clamp(PLAY_AREA.position, PLAY_AREA.end)


func _unhandled_input(event: InputEvent) -> void:
	# 演示：按 interact 键快速保存。
	if event.is_action_pressed("interact"):
		save_progress()


## 收集场景内需要持久化的数据并写入存档。
func save_progress() -> void:
	var data := {}
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("save_data"):
		data["player"] = player.save_data()
	SaveManager.save_game(SAVE_SLOT, data)


## 从存档恢复场景状态。
func load_progress() -> void:
	var data := SaveManager.load_game(SAVE_SLOT)
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("load_data") and data.has("player"):
		player.load_data(data["player"])
