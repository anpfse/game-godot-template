extends CanvasLayer
## 转场遮罩（Transition）
##
## 常驻于最高层级的 CanvasLayer，供 SceneManager 在切换场景时做淡入淡出。
## 遮罩为一整块 ColorRect；透明时忽略鼠标输入，不透明时拦截输入。

@export var color: Color = Color.BLACK

var _rect: ColorRect


func _ready() -> void:
	layer = 128
	_rect = ColorRect.new()
	_rect.color = color
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)


## 淡出到全黑（遮挡画面）。返回可 await 的协程。
func fade_out(duration: float = 0.4) -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, duration)
	await tween.finished


## 淡入到透明（显示画面）。返回可 await 的协程。
func fade_in(duration: float = 0.4) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, duration)
	await tween.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
