extends Node
## 音频管理器（AudioManager）
##
## 统一管理背景音乐（BGM）与音效（SFX）：
##   - BGM 用两个播放器实现交叉淡入淡出，切歌不突兀
##   - SFX 用播放器池并发播放，避免相互打断
##   - 音量按总线（Master / Music / SFX）控制，线性值经
##     linear_to_db 转换后写入 AudioServer
##
## 音量值范围 0.0~1.0；0 表示静音。

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const SFX_POOL_SIZE := 8

# 两个 BGM 播放器交替使用以实现交叉淡入。
var _music_players: Array[AudioStreamPlayer] = []
var _active_music_index: int = 0
# SFX 播放器池。
var _sfx_players: Array[AudioStreamPlayer] = []
var _current_music: AudioStream = null


func _ready() -> void:
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = MUSIC_BUS
		add_child(p)
		_music_players.append(p)

	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = SFX_BUS
		add_child(p)
		_sfx_players.append(p)


## 播放背景音乐；若与当前曲目相同则忽略。fade 为交叉淡入秒数。
func play_music(stream: AudioStream, fade: float = 1.0) -> void:
	if stream == null or stream == _current_music:
		return
	_current_music = stream

	var next_index := 1 - _active_music_index
	var next_player := _music_players[next_index]
	var prev_player := _music_players[_active_music_index]

	next_player.stream = stream
	next_player.volume_db = -80.0
	next_player.play()

	var tween := create_tween().set_parallel(true)
	tween.tween_property(next_player, "volume_db", 0.0, fade)
	if prev_player.playing:
		tween.tween_property(prev_player, "volume_db", -80.0, fade)
		tween.chain().tween_callback(prev_player.stop)

	_active_music_index = next_index


## 停止背景音乐，fade 为淡出秒数。
func stop_music(fade: float = 1.0) -> void:
	_current_music = null
	var player := _music_players[_active_music_index]
	if not player.playing:
		return
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -80.0, fade)
	tween.tween_callback(player.stop)


## 播放一次性音效，使用池中空闲的播放器。
func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	# 池满则复用第一个。
	_sfx_players[0].stream = stream
	_sfx_players[0].play()


## 设置某条总线的线性音量（0.0~1.0）。
func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	if linear <= 0.0:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
