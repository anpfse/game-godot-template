extends Control
## 设置菜单（SettingsMenu）
##
## 作为覆盖层实例化（被主菜单/暂停菜单 add_child）。提供：
##   - 窗口模式、分辨率
##   - Master / Music / SFX 音量
##   - 按键重映射（点击后按下任意键完成绑定）
##   - 恢复默认 / 返回
## 所有变更通过 SettingsManager 即时应用并持久化。

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080),
]

# 正在监听重绑定的动作名（为空表示未监听）。
var _listening_action: String = ""
var _listening_button: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# 半透明背景拦截下层输入。
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(420, 0)
	vbox.add_theme_constant_override("separation", 8)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "设置"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_build_window_mode(vbox)
	_build_resolution(vbox)
	_build_volume_slider(vbox, "主音量", SettingsManager.master_volume, _on_master_changed)
	_build_volume_slider(vbox, "音乐", SettingsManager.music_volume, _on_music_changed)
	_build_volume_slider(vbox, "音效", SettingsManager.sfx_volume, _on_sfx_changed)

	vbox.add_child(HSeparator.new())
	var kb_title := Label.new()
	kb_title.text = "按键设置（点击后按下新键）"
	vbox.add_child(kb_title)
	_build_keybinds(vbox)

	vbox.add_child(HSeparator.new())
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(buttons)
	_add_button(buttons, "恢复默认", _on_reset_pressed)
	_add_button(buttons, "返回", _on_back_pressed)


func _build_window_mode(parent: Node) -> void:
	var row := _labeled_row(parent, "窗口模式")
	var opt := OptionButton.new()
	opt.add_item("窗口", SettingsManager.WindowMode.WINDOWED)
	opt.add_item("全屏", SettingsManager.WindowMode.FULLSCREEN)
	opt.add_item("无边框", SettingsManager.WindowMode.BORDERLESS)
	opt.selected = SettingsManager.window_mode
	opt.item_selected.connect(func(idx): _on_window_mode_selected(opt.get_item_id(idx)))
	row.add_child(opt)


func _build_resolution(parent: Node) -> void:
	var row := _labeled_row(parent, "分辨率")
	var opt := OptionButton.new()
	for i in RESOLUTIONS.size():
		var r := RESOLUTIONS[i]
		opt.add_item("%d × %d" % [r.x, r.y], i)
		if r == SettingsManager.resolution:
			opt.selected = i
	opt.item_selected.connect(_on_resolution_selected)
	row.add_child(opt)


func _build_volume_slider(parent: Node, label: String, value: float, callback: Callable) -> void:
	var row := _labeled_row(parent, label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = value
	slider.custom_minimum_size = Vector2(200, 0)
	slider.value_changed.connect(callback)
	row.add_child(slider)


func _build_keybinds(parent: Node) -> void:
	for action in SettingsManager.REMAPPABLE_ACTIONS:
		var row := _labeled_row(parent, action)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(160, 0)
		btn.text = _keybind_text(action)
		btn.pressed.connect(func(): _start_listening(action, btn))
		row.add_child(btn)


# --- 辅助：构造“标签 + 控件”的一行 ---
func _labeled_row(parent: Node, label: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(160, 0)
	row.add_child(l)
	parent.add_child(row)
	return row


func _add_button(parent: Node, text: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(callback)
	parent.add_child(b)


func _keybind_text(action: String) -> String:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return OS.get_keycode_string(ev.physical_keycode)
	return "未绑定"


# --- 重映射监听 ---
func _start_listening(action: String, button: Button) -> void:
	_listening_action = action
	_listening_button = button
	button.text = "按下新键…"


func _input(event: InputEvent) -> void:
	if _listening_action.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var new_event := InputEventKey.new()
		new_event.physical_keycode = event.physical_keycode
		SettingsManager.set_keybind(_listening_action, new_event)
		_listening_button.text = _keybind_text(_listening_action)
		_listening_action = ""
		_listening_button = null
		get_viewport().set_input_as_handled()


# --- 回调 ---
func _on_window_mode_selected(mode: int) -> void:
	SettingsManager.window_mode = mode
	SettingsManager.apply_display()
	SettingsManager.save_settings()


func _on_resolution_selected(idx: int) -> void:
	SettingsManager.resolution = RESOLUTIONS[idx]
	SettingsManager.apply_display()
	SettingsManager.save_settings()


func _on_master_changed(value: float) -> void:
	SettingsManager.master_volume = value
	SettingsManager.apply_audio()
	SettingsManager.save_settings()


func _on_music_changed(value: float) -> void:
	SettingsManager.music_volume = value
	SettingsManager.apply_audio()
	SettingsManager.save_settings()


func _on_sfx_changed(value: float) -> void:
	SettingsManager.sfx_volume = value
	SettingsManager.apply_audio()
	SettingsManager.save_settings()


func _on_reset_pressed() -> void:
	SettingsManager.reset_to_default()
	# 重新实例化自身以反映默认值（比手动刷新各控件更稳妥）。
	var parent := get_parent()
	parent.add_child(load(scene_file_path).instantiate())
	queue_free()


func _on_back_pressed() -> void:
	queue_free()
