extends CanvasLayer
## 暂停菜单（PauseMenu）
##
## 由关卡场景实例化并常驻。监听 "pause" 动作切换暂停状态。
## 暂停时设置 get_tree().paused 并发出 EventBus.game_paused。
## process_mode 设为 ALWAYS，确保暂停时仍能响应输入与按钮。

const MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const SETTINGS_MENU := preload("res://scenes/ui/settings_menu.tscn")

var _panel: Control


func _ready() -> void:
	layer = 64
	process_mode = Node.PROCESS_MODE_ALWAYS

	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(220, 0)
	vbox.add_theme_constant_override("separation", 12)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "已暂停"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	_add_button(vbox, "继续", _on_resume_pressed)
	_add_button(vbox, "保存游戏", _on_save_pressed)
	_add_button(vbox, "设置", _on_settings_pressed)
	_add_button(vbox, "返回主菜单", _on_main_menu_pressed)

	_panel.visible = false


func _add_button(parent: Node, text: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(callback)
	parent.add_child(b)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()


## 切换暂停/恢复。
func toggle() -> void:
	var paused := not _panel.visible
	_panel.visible = paused
	get_tree().paused = paused
	EventBus.game_paused.emit(paused)


func _on_resume_pressed() -> void:
	toggle()


func _on_save_pressed() -> void:
	# 委托给当前关卡（若实现了 save_progress）。
	var level := get_tree().current_scene
	if level != null and level.has_method("save_progress"):
		level.save_progress()


func _on_settings_pressed() -> void:
	_panel.add_child(SETTINGS_MENU.instantiate())


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene(MAIN_MENU)
