extends Control
## 加载进度画面（LoadingScreen）
##
## 由 SceneManager 在异步加载大场景期间显示。通过 set_progress() 更新进度条。

var _bar: ProgressBar
var _label: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(400, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	_label = Label.new()
	_label.text = "加载中…"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label)

	_bar = ProgressBar.new()
	_bar.min_value = 0.0
	_bar.max_value = 1.0
	_bar.custom_minimum_size = Vector2(400, 24)
	vbox.add_child(_bar)


## 更新进度，value 范围 0.0~1.0。
func set_progress(value: float) -> void:
	if _bar != null:
		_bar.value = value
