extends Node
## 设置管理器（SettingsManager）
##
## 负责游戏设置的读取、应用与持久化：
##   - 显示：窗口模式、分辨率
##   - 音频：Master / Music / SFX 音量
##   - 输入：按键重映射（序列化为物理键码）
##
## 数据持久化到 user://settings.cfg（ConfigFile 格式）。
## 任何模块都可通过 SettingsManager 读写设置，变更后会发出
## EventBus.settings_changed。

const SETTINGS_PATH := "user://settings.cfg"

## 可被玩家重映射的输入动作（不含引擎内置 ui_* 动作）。
const REMAPPABLE_ACTIONS: Array[String] = [
	"move_left", "move_right", "move_up", "move_down",
	"jump", "interact", "pause",
]

## 窗口模式枚举。
enum WindowMode { WINDOWED, FULLSCREEN, BORDERLESS }

# 当前生效的设置值（线性音量 0.0~1.0）。
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var window_mode: WindowMode = WindowMode.WINDOWED
var resolution: Vector2i = Vector2i(1280, 720)

# 默认按键映射快照，用于“恢复默认”。
var _default_keybinds: Dictionary = {}


func _ready() -> void:
	_snapshot_default_keybinds()
	load_settings()
	apply_all()


## 把工程默认的按键映射缓存起来，供 reset 使用。
func _snapshot_default_keybinds() -> void:
	for action in REMAPPABLE_ACTIONS:
		if InputMap.has_action(action):
			_default_keybinds[action] = InputMap.action_get_events(action).duplicate()


## 从磁盘读取设置；文件不存在则保持默认值。
func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return

	master_volume = cfg.get_value("audio", "master", master_volume)
	music_volume = cfg.get_value("audio", "music", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
	window_mode = cfg.get_value("display", "window_mode", window_mode)
	resolution = cfg.get_value("display", "resolution", resolution)

	# 读取自定义按键（以物理键码列表存储）。
	for action in REMAPPABLE_ACTIONS:
		var codes: Array = cfg.get_value("input", action, [])
		if codes.is_empty():
			continue
		InputMap.action_erase_events(action)
		for code in codes:
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			InputMap.action_add_event(action, ev)


## 把当前设置写入磁盘。
func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("display", "window_mode", window_mode)
	cfg.set_value("display", "resolution", resolution)

	for action in REMAPPABLE_ACTIONS:
		var codes: Array[int] = []
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				codes.append(ev.physical_keycode)
		cfg.set_value("input", action, codes)

	cfg.save(SETTINGS_PATH)


## 把全部设置应用到引擎当前状态。
func apply_all() -> void:
	apply_audio()
	apply_display()
	EventBus.settings_changed.emit()


## 应用音量到音频总线。
func apply_audio() -> void:
	AudioManager.set_bus_volume("Master", master_volume)
	AudioManager.set_bus_volume("Music", music_volume)
	AudioManager.set_bus_volume("SFX", sfx_volume)


## 应用窗口模式与分辨率。
func apply_display() -> void:
	match window_mode:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(resolution)
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())


## 设置某个动作的按键映射（替换该动作的全部事件）。
func set_keybind(action: String, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		return
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	save_settings()
	EventBus.settings_changed.emit()


## 恢复所有设置为默认值并保存。
func reset_to_default() -> void:
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	window_mode = WindowMode.WINDOWED
	resolution = Vector2i(1280, 720)
	for action in _default_keybinds:
		InputMap.action_erase_events(action)
		for ev in _default_keybinds[action]:
			InputMap.action_add_event(action, ev)
	apply_all()
	save_settings()
