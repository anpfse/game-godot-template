# Godot 2D 游戏模板

一个可复用的 **Godot 4.6+ / GDScript** 2D 游戏起步模板。内置了大多数 2D 项目都会用到的基础设施，让你跳过重复搭建、直接开始做玩法。

> 通用类型模板：不绑定具体玩法。自带的玩家与示例关卡仅作演示，开新项目时可直接删除替换。

## 内置系统

| 系统 | Autoload | 职责 |
| --- | --- | --- |
| 事件总线 | `EventBus` | 跨模块解耦的全局信号 |
| 音频管理 | `AudioManager` | BGM 交叉淡入、SFX 池、总线音量 |
| 设置管理 | `SettingsManager` | 显示/音量/按键，持久化到 `user://settings.cfg` |
| 存档管理 | `SaveManager` | 多槽位 JSON 存档（`user://saves/`） |
| 场景管理 | `SceneManager` | 异步加载 + 淡入淡出转场 + 加载画面 |

此外还提供：通用**有限状态机**框架（`scripts/framework/`）、组件式示例（`scripts/components/health.gd`）。

## 目录结构

```
autoload/      全局单例（按依赖顺序在 project.godot 注册）
scenes/
  main/        启动场景
  ui/          主菜单 / 设置 / 暂停 / 转场 / 加载
  game/        示例关卡与玩家
scripts/
  framework/   StateMachine / State 基类
  components/   可复用组件示例
  player/       示例玩家控制器与状态
assets/        audio / fonts / sprites / themes
docs/          架构说明
.github/       CI 工作流
```

## 快速上手

1. 用 Godot 4.6+ 打开本目录（存在 `project.godot`）。
2. 直接运行（F5）：启动 → 主菜单 → 开始游戏 → 示例关卡。
3. 在关卡中：`WASD` 移动，`E` 保存进度，`Esc` 暂停，暂停菜单可调设置/返回主菜单。

## 常用 API 速查

```gdscript
# 切换场景（可选加载画面）
SceneManager.change_scene("res://scenes/game/demo_level.tscn")
SceneManager.change_scene(path, true)

# 音频
AudioManager.play_music(stream, 1.0)
AudioManager.play_sfx(stream)

# 存档（约定：节点实现 save_data()/load_data()）
SaveManager.save_game(0, {"player": player.save_data()})
var data := SaveManager.load_game(0)

# 设置
SettingsManager.set_keybind("jump", event)
SettingsManager.reset_to_default()

# 事件总线
EventBus.player_died.connect(_on_player_died)
```

## 基于模板开新项目

1. 修改 `project.godot` 的 `config/name` 与图标。
2. 删除 `scenes/game/`（示例关卡、玩家）与 `scripts/player/`、`scripts/components/health.gd`。
3. 保留 `autoload/`、`scripts/framework/`、`scenes/ui/` 与 `scenes/main/`，按需扩展。

详见 [docs/architecture.md](docs/architecture.md)。
