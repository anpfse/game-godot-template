extends Node
## 场景管理器（SceneManager）
##
## 统一负责场景切换，提供：
##   - 转场遮罩（淡出 -> 切换 -> 淡入），常驻于一个高层级 CanvasLayer
##   - 基于 ResourceLoader 线程加载的异步切换，避免大场景卡顿
##   - 可选的加载进度画面
##
## 用法：
##   SceneManager.change_scene("res://scenes/game/demo_level.tscn")
##   SceneManager.change_scene(path, true)   # 显示加载进度画面
##   SceneManager.reload_current()

const TRANSITION_SCENE := preload("res://scenes/ui/transition.tscn")
const LOADING_SCENE := preload("res://scenes/ui/loading_screen.tscn")

var _transition: CanvasLayer
var _is_changing: bool = false


func _ready() -> void:
	# 转场层延迟实例化，确保根节点已就绪。
	_transition = TRANSITION_SCENE.instantiate()
	get_tree().root.call_deferred("add_child", _transition)


## 切换到指定场景。use_loading=true 时显示加载进度画面（适合大场景）。
func change_scene(path: String, use_loading: bool = false) -> void:
	if _is_changing:
		return
	_is_changing = true
	EventBus.scene_change_requested.emit(path)
	# 切场景前确保解除暂停。
	get_tree().paused = false

	await _transition.fade_out()

	var loading: Control = null
	if use_loading:
		loading = LOADING_SCENE.instantiate()
		_transition.add_child(loading)

	var packed := await _load_threaded(path, loading)

	if loading != null:
		loading.queue_free()

	if packed != null:
		get_tree().change_scene_to_packed(packed)
		# 等一帧让新场景进入树。
		await get_tree().process_frame

	await _transition.fade_in()
	_is_changing = false


## 重新加载当前场景。
func reload_current() -> void:
	var current := get_tree().current_scene
	if current == null:
		return
	change_scene(current.scene_file_path)


## 线程加载资源，期间更新 loading 画面进度。返回 PackedScene 或 null。
func _load_threaded(path: String, loading: Control) -> PackedScene:
	if ResourceLoader.load_threaded_request(path) != OK:
		push_error("无法发起场景加载：%s" % path)
		return null

	var progress: Array = []
	while true:
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				return ResourceLoader.load_threaded_get(path)
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if loading != null and loading.has_method("set_progress"):
					loading.set_progress(progress[0] if not progress.is_empty() else 0.0)
				await get_tree().process_frame
			_:
				push_error("场景加载失败：%s" % path)
				return null
	return null
