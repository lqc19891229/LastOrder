tests 目录说明

最后源码核对：2026-10-21
源码基线：372725c0d2a4e014207c7e81f7d8a683fbea1da3

目录职责
提供可执行的订单规则检查、主场景集成检查和可选画面捕获。

文件与状态
- test_delivery.gd：已提供。37项检查，覆盖无效/重复接单、两单上限、错误取送点、批量取送、结算幂等、取消和超时。
- test_scene.gd：已提供。27项检查，覆盖原生2D节点、移动输入、建筑碰撞、24像素交互距离、取消确认、目标切换与F5重置。
- capture.gd：已提供。加载主场景并捕获终端和街区PNG，需要图形渲染环境；可传入输出目录。
- test_delivery.gd.uid、test_scene.gd.uid、capture.gd.uid：Godot脚本标识，已提供，由编辑器维护。
- readme.txt：检查内容、运行方法与验证状态。

验证状态
- 上述64项为源码中定义的检查数量，不等同于本次重新执行结果。
- 本次目录文档维护只做文件清单、引用和变更范围核对，未重新运行Godot测试。

运行方式
在项目根目录执行，将godot替换为本机Godot 4.6可执行文件：
godot --headless --editor --import --path .
godot --headless --path . --script res://tests/test_delivery.gd
godot --headless --path . --script res://tests/test_scene.gd

图形环境下可执行：
godot --path . --script res://tests/capture.gd -- /已有输出目录

维护要求
- 修改订单规则后执行test_delivery.gd；修改场景、输入或交互后执行test_scene.gd。
- 更新结果时记录引擎版本、源码版本、执行日期、通过数量和失败信息。
- 检查场景布局有变化时，同步调整依赖具体坐标的场景检查。

维护约定
- 新增、删除、重命名文件或改变职责时，同步更新本目录readme.txt。
- 功能状态改变时，同时更新根目录README.md的整体状态表。
- 状态区分已实现、原型、已提供和规划；未运行的检查不标为通过。

