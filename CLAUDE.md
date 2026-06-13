# CLAUDE.md

本文件为 Claude Code 在本仓库工作时提供指引。

## 项目简介

可复用的 **Godot 4.6+ / GDScript** 2D 游戏起步模板（通用类型，不绑定具体玩法）。
内置 2D 项目常用基础设施，自带的玩家与示例关卡仅作演示，开新项目时可删除替换。

## 技术栈与运行

- 引擎：Godot 4.6+（渲染器 `gl_compatibility`，见 `project.godot`）。
- 语言：GDScript，**文件统一 UTF-8 编码，注释用中文**。
- 启动场景：`scenes/main/main.tscn`。
- 运行：用 Godot 4.6+ 打开本目录后按 F5；或 `godot --headless --path . --import` 做导入校验。
- 本机当前未安装 Godot CLI，涉及实际运行的验证需用户在本机用编辑器确认。

## 架构

核心系统均为 **Autoload 单例**，靠 `EventBus` 信号解耦。详见 `docs/architecture.md`。

- `EventBus`（`autoload/event_bus.gd`）— 全局信号中心
- `AudioManager` — BGM 交叉淡入、SFX 池、总线音量（`Master/Music/SFX`）
- `SettingsManager` — 显示/音量/按键，持久化 `user://settings.cfg`；按键以物理键码存储
- `SaveManager` — 多槽位 JSON 存档（`user://saves/`），带 `version` 字段
- `SceneManager` — `ResourceLoader` 线程异步加载 + 淡入淡出转场 + 加载画面

**Autoload 注册顺序有依赖**（被依赖者在前）：
`EventBus → AudioManager → SettingsManager → SaveManager → SceneManager`。
`SettingsManager._ready()` 会调用 `AudioManager`，故顺序不可随意调整。

## 目录约定

- `autoload/` — 全局单例（在 `project.godot` 的 `[autoload]` 注册）
- `scenes/main|ui|game/` — 启动 / UI / 关卡与玩家
- `scripts/framework/` — `StateMachine` / `State` 基类（通用，勿混入玩法逻辑）
- `scripts/components/` — 组件式示例（组合优于继承）
- `scripts/player/` — 示例玩家（占位，可删）
- `assets/audio|fonts|sprites|themes/` — 资源

## 约定与模式

- UI 场景采用「最小 `.tscn`（根节点+脚本）+ 脚本内构建子节点」的写法。
- 玩家用完整 `.tscn`，以便 `StateMachine` 的 `owner` 自动指向场景根。
- **存档协议**：需持久化的节点实现 `save_data() -> Dictionary` 与
  `load_data(data: Dictionary)`，由关卡收集后调用 `SaveManager`。
- 状态机：状态继承 `State`，通过 `transitioned` 信号请求切换；`StateMachine._ready()`
  会 `await owner.ready`，因此状态机须作为已保存场景的一部分使用。
- 新增可重映射按键时，同步更新 `SettingsManager.REMAPPABLE_ACTIONS` 与 `project.godot` 的 `[input]`。
