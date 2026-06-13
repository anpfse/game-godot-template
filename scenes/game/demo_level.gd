extends Node2D
## 示例关卡（DemoLevel）
##
## 把各系统串联起来的演示场景：玩家移动、暂停菜单、存档/读档。
## **开新项目时整体替换为你的真实关卡即可。**
##
## 存档协议：本场景实现 save_progress() / load_progress()，
## 由暂停菜单的“保存游戏”按钮调用。
const SAVE_SLOT := 0


func _ready() -> void:
	# 若已有存档（来自“继续”），读回进度。
	if SaveManager.has_save(SAVE_SLOT):
		load_progress()


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
