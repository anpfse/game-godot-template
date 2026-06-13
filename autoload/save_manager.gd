extends Node
## 存档管理器（SaveManager）
##
## 以 JSON 形式把游戏数据写入 user://saves/slot_{n}.json，支持多存档槽。
## 每个存档包含版本号（便于未来做数据迁移）、时间戳与游戏数据。
##
## 约定：需要持久化的节点自行实现
##   func save_data() -> Dictionary
##   func load_data(data: Dictionary) -> void
## 由具体游戏逻辑收集这些数据后调用 save_game()。

const SAVE_DIR := "user://saves"
const SAVE_VERSION := 1


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


## 写入一个存档槽。data 为任意可 JSON 序列化的字典。
func save_game(slot: int, data: Dictionary) -> bool:
	var payload := {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"data": data,
	}
	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("无法写入存档：%s" % _slot_path(slot))
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	EventBus.save_completed.emit(slot)
	return true


## 读取一个存档槽的游戏数据；失败返回空字典。
func load_game(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("存档解析失败：%s" % _slot_path(slot))
		return {}

	# 这里可按 parsed.version 做版本迁移。
	var data: Dictionary = parsed.get("data", {})
	EventBus.load_completed.emit(slot, data)
	return data


## 指定槽位是否存在存档。
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


## 删除指定槽位的存档。
func delete_save(slot: int) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(_slot_path(slot))


## 列出全部已有存档的槽位编号（升序）。
func list_saves() -> Array[int]:
	var slots: Array[int] = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return slots
	for file_name in dir.get_files():
		if file_name.begins_with("slot_") and file_name.ends_with(".json"):
			var num_str := file_name.trim_prefix("slot_").trim_suffix(".json")
			if num_str.is_valid_int():
				slots.append(num_str.to_int())
	slots.sort()
	return slots
