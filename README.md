# 最后一单 2D像素外卖系统

v0.2 · Godot 4.6 / GDScript · 2D俯视角像素风原型。

这版以接单、到店取餐、到址交付和结算为完整流程，包含两家餐馆、三个收货点和六笔预设订单。角色、相机、碰撞和取送点均为原生2D节点。街区和四向配送员使用可替换的代码像素素材，无需外部插件或素材包。

## 打开和运行

1. 解压整个 `last-order` 文件夹。
2. 在 **Godot 4.6标准版**的项目管理器点击「导入」，选择 `project.godot`，不需要 .NET。
3. 等待第一次资源导入结束，按 F5 运行工程；主场景为 `scenes/main.tscn`。
4. 本版实际验证引擎为 **4.6.stable.official.89cea1439**。

## 操作

| 按键 | 功能 |
| --- | --- |
| WASD 或方向键 | 四向移动，支持斜向移动 |
| Shift | 快走 |
| E | 靠近地面标记后取餐或交付 |
| Tab / Esc | 打开或关闭城市通 |
| F5（游戏窗口内） | 重置本轮订单和收入 |
| 鼠标 | 接单、查看记录、切换目标、取消订单 |

建议使用独立游戏窗口，或先将输入焦点放入嵌入的游戏视图。编辑器自身的F5与游戏窗口内的F5是不同的上下文。

## 第一笔订单

1. 游戏启动时显示「城市通」，接取 **A01 深夜牛肉面**。
2. 按 Tab 返回街区。小地图虚线和底部文字提示目标方向。
3. 前往青色标记「回声面馆」，距离不超过24像素时按 E 取餐。
4. 目标自动切换到橙色标记「住区 A 栋」。绕过建筑，前往对应位置按 E。
5. 完成后收入增加28，贡献增加3，终端记录和右上角结算同步更新。
6. 可同时接取A02，在同一餐馆一次取两单，再决定配送顺序。点击左侧订单按钮可切换跟踪目标。

小地图提供方向，不计算可通行路径。镜头跟随配送员，靠近街区边界时停止跟随，以免露出地图外。

## 订单规则

- 同时最多两单，待取餐和配送中都占名额。
- 接单后才倒计时；打开终端或取消确认窗口时，计时继续。
- 对应餐馆才能取餐，对应地址才能交付；未取餐不能交付。
- 支持同店批量取餐、同址批量交付，按每笔订单分别结算。
- 已送达为终态，重复交互不重复发放货币和贡献。
- 到截止时间即失败；取消和超时均无收益，并释放名额。
- 取消前需要确认；取消或超时的订单本轮不能重接。
- 六笔订单是有限的测试内容，不自动刷新；F5开始新一轮。
- 本版收入和订单不保存，退出游戏后清空。

## 像素显示设置

| 设置 | 本版值 |
| --- | --- |
| 设计分辨率 | 640 × 360 |
| 默认窗口 | 1280 × 720，也就是2倍 |
| Stretch Mode | viewport |
| Stretch Aspect | keep |
| Stretch Scale Mode | integer |
| 默认纹理过滤 | Nearest |
| 2D变换像素吸附 | 开启 |
| 相机平滑 | 关闭 |

非整数尺寸的窗口可能出现黑边，这是为了保留等大的清晰像素。完整画面可在640×360、1280×720和1920×1080等尺寸显示。

中文使用关闭抗锯齿的字体字形，界面采用直角边框。角色与场景没有平滑缩放的位图，绘制细节按整数像素组织。

## 在Godot编辑器里修改地图

打开 `scenes/main.tscn`，切换到2D视图：

- `PixelCity`：地面道路、人行道、路灯和小物的代码像素绘制，脚本使用 `@tool`，编辑器可见。
- `Actors`：启用Y排序，包含五栋建筑和配送员；脚底位置决定前后遮挡。
- 建筑节点：可调整 `title`、`kind`、`building_width`、`building_height`，并直接移动节点。
- 建筑下的 `Body/CollisionShape2D`：实际占地碰撞，修改建筑占地时需同步调整；只修改一个共享形状时，先在Inspector中将资源设为唯一。
- `Points`：移动对应的取餐和送达标记。移动建筑后，应一起调整它的地面标记。
- `Boundaries`：与可见外墙对应的地图边界碰撞。
- `Camera2D`：跟随配送员，限制范围与街区大小一致。

配送员脚本 `courier.gd` 内包含四向站立、行走和送餐箱的像素绘制。后续可换为 `AnimatedSprite2D`，保留 `CharacterBody2D`、碰撞和交互接口。

## 工程结构

```text
project.godot
scenes/main.tscn                 可在2D编辑器调整的主场景
scripts/delivery/
  order_spec.gd                  可编辑的订单模板 Resource
  delivery_order.gd              单笔订单状态
  delivery_service.gd            状态流转、计时、结算与信号
scripts/world/
  main.gd                        模块连接、相机跟随与距离交互
  courier.gd                     CharacterBody2D移动与像素角色
  delivery_point.gd              2D取送标记
  pixel_city.gd                  像素街区地面绘制
  pixel_building.gd              可编辑的像素建筑绘制
scripts/ui/
  delivery_hud.gd                640×360界面与城市通终端
  street_map.gd                  2D小地图与目标方向
data/orders/*.tres               六笔订单资源
tests/                          核心与场景检查
assets/fonts/                   中文字形子集与许可证
```

## 修改订单

在文件系统中选中 `data/orders/a01.tres`，Inspector里可修改以下字段：

| 属性 | 含义 |
| --- | --- |
| order_id | 唯一编号 |
| meal_name | 餐品名称 |
| pickup_id | 餐馆编号 |
| dropoff_id | 送达点编号 |
| reward | 完成收入 |
| contribution | 完成贡献 |
| time_limit | 接单后的时限，单位秒 |

现有取餐点为 `noodle`、`bento`；送达点为 `residence`、`workshop`、`clinic`。

增加订单时复制一个 `.tres`，修改编号，将文件名加入 `main.gd` 的 `ORDER_FILES`。新增取送点时在场景的 `Points` 下复制一个 `DeliveryPoint`，设置唯一 `point_id`，再由订单引用该编号。

订单系统的距离判断使用像素单位。当前交互半径24像素；界面按16像素对应1米显示近似距离。这个换算用于提示，不影响移动速度和计时。

## 状态与接口

可接单 → 待取餐 → 配送中 → 已送达。待取餐和配送中也可以进入超时或取消终态。

`DeliveryService.accept(id)`、`pickup_at(point_id)`、`deliver_at(point_id)`、`cancel(id)`负责状态和结算；地图控制器在调用取送接口前检查玩家距离。订单核心与视觉维度无关，未来可继续用于载具。

主要信号：`orders_changed`、`balance_changed`、`feedback`、`order_completed`。

## 验证方式

将 `godot` 替换为本机Godot 4.6的可执行文件路径，在工程目录运行：

```bash
godot --headless --editor --import --path .
godot --headless --path . --script res://tests/test_delivery.gd
godot --headless --path . --script res://tests/test_scene.gd
```

核心检查覆盖结算幂等、错误地址、两单上限、批量取送、取消和超时。场景检查包含原生2D类型、实际移动输入、建筑碰撞、24像素交互距离、取消确认、目标切换及本轮重置。

`tests/capture.gd`可在图形环境下捕获终端和街区画面，属于可选检查工具。

## 本阶段范围与后续

当前阶段先验证步行配送。载具、婴儿照料、地下平台、食物温度、存档和完整剧情留作后续模块。美术是可替换的像素占位素材，未定义最终人物和城市造型。

下一步可先调整街区路线与订单时间，再把配送车接入同一套取送接口。

新增中文文案若有缺字，可将 `assets/fonts/LastOrderCN.otf` 替换为完整中文字体；若更换路径，同步修改 `delivery_hud.gd` 与 `pixel_building.gd`。

## 字体与官方参考

字体为Noto Sans CJK SC的字形子集，族名修改为Last Order CN；来源与SIL Open Font License 1.1分别见 `assets/fonts/SOURCE.txt`、`OFL.txt`。

- https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html
- https://docs.godotengine.org/en/4.6/tutorials/rendering/multiple_resolutions.html
