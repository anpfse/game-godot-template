extends Node
## 全局事件总线（EventBus）
##
## 集中声明跨模块的全局信号，让互相不认识的节点也能解耦通信。
## 任意脚本通过 `EventBus.信号名.emit(...)` 发送，
## 通过 `EventBus.信号名.connect(回调)` 订阅。
##
## 约定：只放真正“全局”的事件；局部交互请用节点自身的信号。

## 游戏暂停状态发生变化（true=已暂停）。
signal game_paused(is_paused: bool)

## 请求切换场景（path 为目标场景资源路径）。
signal scene_change_requested(path: String)

## 一次存档写入完成（slot 为槽位编号）。
signal save_completed(slot: int)

## 一次读档完成（slot 为槽位编号，data 为读取到的数据）。
signal load_completed(slot: int, data: Dictionary)

## 设置项发生变更并已应用。
signal settings_changed

## 玩家死亡（示例事件，可按需删除/替换）。
signal player_died
