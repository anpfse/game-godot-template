# 架构说明

## 总览

模板以 **Autoload 单例** 为骨架，各系统职责单一、互不直接依赖，靠 `EventBus`
信号解耦。游戏内容（场景、玩家）通过这些单例提供的服务运转。

```
启动(main) ──> SceneManager ──> 主菜单 ──> 关卡
                  │
   ┌──────────────┼───────────────┬───────────────┐
EventBus    AudioManager    SettingsManager    SaveManager
（信号）      （音频）          （设置/输入）       （存档）
```

## Autoload 注册顺序

在 `project.godot` 的 `[autoload]` 中按依赖排序，被依赖者在前：

```
EventBus → AudioManager → SettingsManager → SaveManager → SceneManager
```

`SettingsManager._ready()` 会调用 `AudioManager` 应用音量，故 `AudioManager`
必须先注册；`SceneManager` 通过 `preload` 引用转场与加载场景。

## 各系统要点

### EventBus
纯信号集合。只承载真正全局的事件（暂停、存读档完成、设置变更等）。
局部交互请用节点自身信号，避免一切都往总线塞。

### AudioManager
- 两个 `AudioStreamPlayer` 交替播放 BGM，实现交叉淡入。
- `SFX_POOL_SIZE` 个播放器组成音效池，并发播放不互相打断。
- 音量按总线（`Master/Music/SFX`，见 `default_bus_layout.tres`）控制。

### SettingsManager
- 用 `ConfigFile` 持久化到 `user://settings.cfg`。
- `REMAPPABLE_ACTIONS` 列出可重映射的动作；按键以**物理键码**存储，
  兼容不同键盘布局。
- 启动时加载并 `apply_all()`，变更后发 `EventBus.settings_changed`。

### SaveManager
- 多槽位 JSON 存档，写入 `version` 字段便于未来迁移。
- **存档协议**：需要持久化的节点实现 `save_data() -> Dictionary` 与
  `load_data(data: Dictionary)`，由关卡（如 `demo_level.gd`）收集后调用
  `save_game()` / `load_game()`。

### SceneManager
- 用 `ResourceLoader.load_threaded_*` 后台加载，避免主线程卡顿。
- 流程：淡出 → (可选)加载画面 → `change_scene_to_packed` → 淡入。
- 转场层 `transition.tscn` 常驻于 layer 128 的 CanvasLayer。

## 状态机框架

- `State`（`scripts/framework/state.gd`）：基类，重写 `enter/exit/update/
  physics_update/handle_input`，通过 `transitioned` 信号请求切换。
- `StateMachine`（`scripts/framework/state_machine.gd`）：导出 `initial_state`，
  转发各回调给当前状态，响应 `transitioned` 完成切换。
- 示例：`scenes/game/player.tscn` 用 `Idle`/`Move` 两个状态驱动玩家。
  注意 `StateMachine._ready()` 会 `await owner.ready`，因此状态机应作为已保存
  场景的一部分使用（`owner` 自动指向场景根）。

## 组件式写法

`scripts/components/health.gd`（`HealthComponent`）演示「组合优于继承」：
作为子节点挂到任意实体即可赋予生命值/受伤/死亡能力，无需改动实体本体。
