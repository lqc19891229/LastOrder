scripts 目录说明

最后源码核对：2026-10-21
源码基线：372725c0d2a4e014207c7e81f7d8a683fbea1da3

目录职责
按订单规则、世界交互和界面分层组织GDScript实现。

子目录与状态
- delivery/：已实现订单模板、状态、计时和结算，详见delivery/readme.txt。
- world/：已实现2D移动、碰撞、场景协调和代码像素占位绘制，详见world/readme.txt。
- ui/：已实现城市通、任务追踪、提示与小地图，详见ui/readme.txt。
- readme.txt：脚本层次与模块边界索引。

调用关系
- main.gd加载OrderSpec模板，DeliveryService创建DeliveryOrder实例。
- HUD的接单按钮调用DeliveryService.accept()。
- 地图按E时由main.gd判断距离，再调用pickup_at()或deliver_at()。
- 服务通过信号通知HUD刷新状态与收益。
- 打开终端由HUD禁用角色移动，不暂停订单计时。

约定
- 订单状态与收益通过DeliveryService接口修改。
- 交互距离属于世界层，界面不直接判断玩家是否到达地址。
- OrderSpec保存静态配置，DeliveryOrder保存单笔运行状态。
- .gd.uid为Godot脚本资源标识，不包含玩法逻辑，由编辑器维护。

当前边界与后续
- UI目前由代码构建，布局与操作集中在delivery_hud.gd。
- 地图范围和距离换算分散在多个脚本，后续适合集中为配置。

维护约定
- 新增、删除、重命名文件或改变职责时，同步更新本目录readme.txt。
- 功能状态改变时，同时更新根目录README.md的整体状态表。
- 状态区分已实现、原型、已提供和规划；未运行的检查不标为通过。

