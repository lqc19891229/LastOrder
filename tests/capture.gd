extends SceneTree
## 可选视觉检查，需要真实渲染驱动；输出到用户传入的目录。

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for frame in range(12):
		await process_frame
	var args := OS.get_cmdline_user_args()
	var directory := args[0] if not args.is_empty() else "user://"
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join("terminal.png"))
	scene.service.accept(&"A01")
	scene.service.accept(&"A02")
	scene.hud._navigate(&"A01")
	for frame in range(12):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join("street.png"))
	quit()
