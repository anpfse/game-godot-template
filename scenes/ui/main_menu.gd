extends Control
## 主菜单（MainMenu）
##
## 提供：开始新游戏 / 继续 / 设置 / 退出。
## UI 在代码中构建以保证模板开箱即用；你可改为在编辑器里可视化搭建。

const DEMO_LEVEL := "res://scenes/game/demo_level.tscn"
const SETTINGS_MENU := preload("res://scenes/ui/settings_menu.tscn")
const SAVE_SLOT := 0

var _continue_button: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.custom_minimum_size = Vector2(260, 0)
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "Godot 2D 模板"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)

	_add_button(vbox, "开始新游戏", _on_start_pressed)
	_continue_button = _add_button(vbox, "继续", _on_continue_pressed)
	_continue_button.disabled = not SaveManager.has_save(SAVE_SLOT)
	_add_button(vbox, "设置", _on_settings_pressed)
	_add_button(vbox, "退出", _on_quit_pressed)


func _add_button(parent: Node, text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(callback)
	parent.add_child(b)
	return b


func _on_start_pressed() -> void:
	# 新游戏：清掉旧存档再进入关卡。
	SaveManager.delete_save(SAVE_SLOT)
	SceneManager.change_scene(DEMO_LEVEL)


func _on_continue_pressed() -> void:
	SceneManager.change_scene(DEMO_LEVEL)


func _on_settings_pressed() -> void:
	add_child(SETTINGS_MENU.instantiate())


func _on_quit_pressed() -> void:
	get_tree().quit()
