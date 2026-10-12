extends SceneTree

const OUTPUT_DIR: String = "user://ui_captures"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_path: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_path)

	var capture_size: Vector2i = _get_capture_size()
	var viewport: SubViewport = SubViewport.new()
	viewport.size = capture_size
	viewport.size_2d_override = capture_size
	viewport.size_2d_override_stretch = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var scene: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	if scene == null:
		push_error("Failed to load main scene for capture")
		quit(1)
		return

	var main_scene: Control = scene.instantiate() as Control
	viewport.add_child(main_scene)
	await process_frame
	await process_frame
	var splash_logo: TextureRect = main_scene.get("_splash_logo") as TextureRect
	if splash_logo != null:
		splash_logo.modulate = Color.WHITE
	_save_viewport(viewport, output_path, "splash_fresh.png")

	main_scene.call("_finish_splash")
	await process_frame
	await process_frame
	_save_viewport(viewport, output_path, "menu_fresh.png")

	main_scene.call("_show_role_select")
	await process_frame
	await process_frame
	_save_viewport(viewport, output_path, "role_select_fresh.png")
	print(output_path)

	quit()


func _save_viewport(viewport: SubViewport, output_path: String, file_name: String) -> void:
	var image: Image = viewport.get_texture().get_image()
	image.save_png("%s/%s" % [output_path, file_name])


func _get_capture_size() -> Vector2i:
	return Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width", 1280)),
		int(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
	)
