scenes 目录说明

最后源码核对：2026-10-21
源码基线：372725c0d2a4e014207c7e81f7d8a683fbea1da3

目录职责
保存可在Godot编辑器调整的场景节点、布局和碰撞配置。

文件与状态
- main.tscn：已实现单街区原型，是project.godot配置的唯一启动场景。
- readme.txt：场景职责、节点关系和拆分状态说明。

main.tscn节点职责
- LastOrder：Node2D根节点，挂载scripts/world/main.gd，组装订单、角色和界面。
- PixelCity：绘制地面与道路。
- Actors：启用Y排序；包含五栋建筑和Courier。
- 建筑/Body/CollisionShape2D：提供实体碰撞；与建筑外观参数分别维护。
- Courier：CharacterBody2D，负责移动和角色像素绘制。
- Points：两个取餐点和三个送达点；编号用于匹配订单。
- Boundaries：四个外沿碰撞。
- Camera2D：跟随角色，地图范围为x=-576至576、y=-448至448。
- DeliveryService：普通Node，负责本轮外卖数据；当前不是Autoload。
- DeliveryHUD：不在静态场景文件中，由main.gd运行时创建。

编辑约定
- 移动建筑时同时调整对应Points标记。
- 改建筑占地时同步碰撞形状；共享形状需要独立修改时先设为唯一资源。
- 改地图大小时同步地面、边界、相机限制和小地图换算。

规划中的拆分
- 城市、角色、建筑、取送点分别做成可复用场景。
- HUD、城市通和订单卡分别做成UI场景。
- 上述拆分尚未实施，不应当作现有文件或已完成功能。

维护约定
- 新增、删除、重命名文件或改变职责时，同步更新本目录readme.txt。
- 功能状态改变时，同时更新根目录README.md的整体状态表。
- 状态区分已实现、原型、已提供和规划；未运行的检查不标为通过。

