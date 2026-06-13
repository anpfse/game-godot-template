extends Node
## 启动场景（Main）
##
## 工程入口。负责在进入主菜单前完成一次性初始化（设置已由
## SettingsManager 自身在 _ready 中加载并应用），随后切换到主菜单。

const MAIN_MENU := "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	# 这里可放置一次性引导逻辑（加载本地化、远端配置等）。
	# 等一帧确保所有 autoload 就绪后再切场景。
	await get_tree().process_frame
	SceneManager.change_scene(MAIN_MENU)
