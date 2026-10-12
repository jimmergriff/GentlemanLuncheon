extends SceneTree

const LAYOUT_EPSILON: float = 1.0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Missing smoke target")
		quit(1)
		return

	var ok: bool = false
	match args[0]:
		"assets_brand":
			ok = _check_assets_brand()
		"menu_layout":
			ok = await _check_menu_layout()
		"role_select_layout":
			ok = await _check_role_select_layout()
		"battle_hud_layout":
			ok = await _check_battle_hud_layout()
		"all":
			ok = await _check_all()
		_:
			push_error("Unknown smoke target: %s" % args[0])
			quit(1)
			return

	quit(0 if ok else 1)

func _check_all() -> bool:
	if not _check_assets_brand():
		return false
	if not await _check_menu_layout():
		return false
	if not await _check_role_select_layout():
		return false
	if not await _check_battle_hud_layout():
		return false
	return true


func _check_assets_brand() -> bool:
	var required_assets := [
		"res://assets/branding/fury_fist_logo.png",
	]

	for asset_path in required_assets:
		var exists: bool = ResourceLoader.exists(asset_path)
		if not exists and asset_path.ends_with(".png"):
			exists = FileAccess.file_exists(ProjectSettings.globalize_path(asset_path))
		if not exists:
			return _fail("Missing brand asset: %s" % asset_path)

	return _pass("assets_brand")


func _check_menu_layout() -> bool:
	var test_viewport: SubViewport = _create_test_viewport()
	await process_frame

	var scene: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	if scene == null:
		return _fail("Main scene could not be loaded")

	var main_scene: Control = scene.instantiate() as Control
	test_viewport.add_child(main_scene)
	await process_frame
	main_scene.call("_apply_menu_layout")
	await process_frame

	if main_scene.theme == null:
		return _fail("Main scene theme is missing")
	if main_scene.theme.resource_path != "res://resources/fury_poster_theme.tres":
		return _fail("Main scene theme mismatch: %s" % main_scene.theme.resource_path)

	var logo_stack: Node = main_scene.get_node_or_null("MenuLayer/LogoStack")
	if logo_stack == null:
		return _fail("Missing node: MenuLayer/LogoStack")

	var menu_ticket: Node = main_scene.get_node_or_null("MenuLayer/MenuTicket")
	if menu_ticket == null:
		return _fail("Missing node: MenuLayer/MenuTicket")

	var hero_poster: Node = main_scene.get_node_or_null("MenuLayer/HeroPoster")

	var logo_mark: TextureRect = main_scene.get_node_or_null("MenuLayer/LogoStack/Logo") as TextureRect
	if logo_mark == null or logo_mark.texture == null:
		return _fail("Logo mark texture is not assigned")

	var viewport_size: Vector2i = _get_test_viewport_size()
	var viewport_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(viewport_size))
	if not _require_control_inside("MenuLayer/LogoStack", logo_stack as Control, viewport_rect):
		return false
	if not _require_control_inside("MenuLayer/MenuTicket", menu_ticket as Control, viewport_rect):
		return false
	if hero_poster != null and (hero_poster as Control).visible:
		return _fail("MenuLayer/HeroPoster should stay hidden on the start menu")

	var main_menu: VBoxContainer = main_scene.get_node_or_null("MenuLayer/MenuTicket/MainMenu") as VBoxContainer
	if main_menu == null:
		return _fail("Missing node: MenuLayer/MenuTicket/MainMenu")
	if not _require_vbox_content_fit("MenuLayer/MenuTicket/MainMenu", main_menu):
		return false
	main_scene.call("_activate_menu", "main")
	await process_frame
	var first_button: Button = main_scene.get_node_or_null("MenuLayer/MenuTicket/MainMenu/SingleGame") as Button
	if first_button == null:
		return _fail("Missing node: MenuLayer/MenuTicket/MainMenu/SingleGame")
	var focus_color: Color = first_button.get_theme_color("font_color")
	var normal_style: StyleBoxFlat = first_button.get_theme_stylebox("normal") as StyleBoxFlat
	if normal_style == null:
		return _fail("Main menu focus style is missing")
	if _contrast_ratio(focus_color, normal_style.bg_color) < 4.5:
		return _fail("Main menu focus contrast is too low: font=%s bg=%s" % [focus_color, normal_style.bg_color])

	main_scene.call("_show_single_game_submenu")
	await process_frame
	var submenu_panel: Panel = main_scene.get_node_or_null("MenuLayer/SubmenuPanel") as Panel
	if submenu_panel == null:
		return _fail("Missing node: MenuLayer/SubmenuPanel")
	if not _require_control_inside("MenuLayer/SubmenuPanel", submenu_panel, viewport_rect):
		return false
	var submenu_buttons: VBoxContainer = main_scene.get_node_or_null("MenuLayer/SubmenuPanel/Buttons") as VBoxContainer
	if submenu_buttons == null:
		return _fail("Missing node: MenuLayer/SubmenuPanel/Buttons")
	if not _require_vbox_content_fit("MenuLayer/SubmenuPanel/Buttons", submenu_buttons):
		return false

	return _pass("menu_layout")


func _check_role_select_layout() -> bool:
	var test_viewport: SubViewport = _create_test_viewport()
	await process_frame

	var scene: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	if scene == null:
		return _fail("Main scene could not be loaded")

	var main_scene: Control = scene.instantiate() as Control
	test_viewport.add_child(main_scene)
	await process_frame
	main_scene.call("_show_role_select")
	await process_frame

	var info_board: Node = main_scene.get_node_or_null("RoleSelectLayer/RoleSelect/InfoBoard")
	if info_board == null:
		return _fail("Missing node: RoleSelectLayer/RoleSelect/InfoBoard")

	var hero_poster: Node = main_scene.get_node_or_null("RoleSelectLayer/RoleSelect/HeroPoster")

	var roster_strip: Node = main_scene.get_node_or_null("RoleSelectLayer/RoleSelect/RosterStrip")
	if roster_strip == null:
		return _fail("Missing node: RoleSelectLayer/RoleSelect/RosterStrip")

	var roster_cards: HBoxContainer = main_scene.get_node_or_null("RoleSelectLayer/RoleSelect/RosterStrip/Cards") as HBoxContainer
	if roster_cards == null:
		return _fail("Missing node: RoleSelectLayer/RoleSelect/RosterStrip/Cards")
	if roster_cards.get_child_count() == 0:
		return _fail("Role roster cards were not populated")

	var viewport_size: Vector2i = _get_test_viewport_size()
	var viewport_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(viewport_size))
	var role_select: Panel = main_scene.get_node_or_null("RoleSelectLayer/RoleSelect") as Panel
	if role_select == null:
		return _fail("Missing node: RoleSelectLayer/RoleSelect")
	if not _require_control_inside("RoleSelectLayer/RoleSelect", role_select, viewport_rect):
		return false
	var role_select_rect: Rect2 = role_select.get_global_rect()
	if not _require_control_inside("RoleSelectLayer/RoleSelect/InfoBoard", info_board as Control, role_select_rect):
		return false
	if hero_poster != null and (hero_poster as Control).visible:
		return _fail("RoleSelectLayer/RoleSelect/HeroPoster should be hidden in compact info layout")
	if not _require_control_inside("RoleSelectLayer/RoleSelect/InfoBoard/Info/PreviewBox", main_scene.get_node_or_null("RoleSelectLayer/RoleSelect/InfoBoard/Info/PreviewBox") as Control, (info_board as Control).get_global_rect()):
		return false
	if not _require_control_inside("RoleSelectLayer/RoleSelect/RosterStrip", roster_strip as Control, role_select_rect):
		return false

	var roster_buttons: HBoxContainer = main_scene.get_node_or_null("RoleSelectLayer/RoleSelect/RosterStrip/Buttons") as HBoxContainer
	if roster_buttons == null:
		return _fail("Missing node: RoleSelectLayer/RoleSelect/RosterStrip/Buttons")
	if not _require_control_inside("RoleSelectLayer/RoleSelect/RosterStrip/Cards", roster_cards, (roster_strip as Control).get_global_rect()):
		return false
	if not _require_control_inside("RoleSelectLayer/RoleSelect/RosterStrip/Buttons", roster_buttons, (roster_strip as Control).get_global_rect()):
		return false
	if not _require_hbox_content_fit("RoleSelectLayer/RoleSelect/RosterStrip/Cards", roster_cards):
		return false
	if not _require_hbox_content_fit("RoleSelectLayer/RoleSelect/RosterStrip/Buttons", roster_buttons):
		return false

	return _pass("role_select_layout")


func _check_battle_hud_layout() -> bool:
	var test_viewport: SubViewport = _create_test_viewport()
	await process_frame

	var scene: PackedScene = load("res://scenes/battle/BattleScene.tscn") as PackedScene
	if scene == null:
		return _fail("BattleScene could not be loaded")

	var battle_scene: Node = scene.instantiate()
	test_viewport.add_child(battle_scene)
	await process_frame
	if battle_scene.has_method("start_session"):
		battle_scene.call("start_session", {
			"player_role_id": "kunio",
			"cpu_role_ids": ["riki"],
			"mute_audio": true,
		})
		await process_frame

	var battle_hud: Node = battle_scene.get_node_or_null("HUD/BattleHud")
	if battle_hud == null:
		return _fail("Missing node: HUD/BattleHud")

	var player_left: Control = battle_scene.get_node_or_null("HUD/BattleHud/TopRow/PlayerLeft") as Control
	if player_left == null:
		return _fail("Missing node: HUD/BattleHud/TopRow/PlayerLeft")
	if not player_left.visible:
		return _fail("HUD/BattleHud/TopRow/PlayerLeft is not visible after session start")

	if battle_scene.get_node_or_null("HUD/BattleHud/CenterCore") == null:
		return _fail("Missing node: HUD/BattleHud/CenterCore")

	var center_label: Label = battle_scene.get_node_or_null("HUD/BattleHud/CenterCore/Banner/Label") as Label
	if center_label == null or center_label.text.is_empty():
		return _fail("Battle HUD center banner text was not populated")

	var battle_hud_control: Control = battle_hud as Control
	if battle_hud_control == null:
		return _fail("HUD/BattleHud is not a Control")
	var viewport_size: Vector2i = _get_test_viewport_size()
	var viewport_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(viewport_size))
	if not _require_control_inside("HUD/BattleHud/TopRow", battle_scene.get_node_or_null("HUD/BattleHud/TopRow") as Control, viewport_rect):
		return false
	if not _require_control_inside("HUD/BattleHud/CenterCore", battle_scene.get_node_or_null("HUD/BattleHud/CenterCore") as Control, viewport_rect):
		return false
	if not _require_control_inside("HUD/BattleHud/BottomHelp", battle_scene.get_node_or_null("HUD/BattleHud/BottomHelp") as Control, viewport_rect):
		return false
	for slot_path in [
		"HUD/BattleHud/TopRow/PlayerLeft",
		"HUD/BattleHud/TopRow/PlayerRight",
	]:
		var slot_root: Panel = battle_scene.get_node_or_null(slot_path) as Panel
		if slot_root == null:
			return _fail("Missing node: %s" % slot_path)
		if not _require_control_inside(slot_path, slot_root, viewport_rect):
			return false
		var slot_rect: Rect2 = slot_root.get_global_rect()
		var slot_content: HBoxContainer = slot_root.get_child(0) as HBoxContainer
		if slot_content == null:
			return _fail("Missing slot content container: %s" % slot_path)
		if not _require_control_inside("%s/content" % slot_path, slot_content, slot_rect):
			return false
		var avatar_frame: Panel = slot_content.get_child(0) as Panel
		if avatar_frame == null:
			return _fail("Missing avatar frame: %s" % slot_path)
		if not _require_control_inside("%s/avatar" % slot_path, avatar_frame, slot_rect):
			return false

	return _pass("battle_hud_layout")


func _pass(label: String) -> bool:
	print("OK: %s" % label)
	return true


func _fail(message: String) -> bool:
	push_error(message)
	return false


func _create_test_viewport() -> SubViewport:
	var viewport_size: Vector2i = _get_test_viewport_size()
	var viewport: SubViewport = SubViewport.new()
	viewport.disable_3d = false
	viewport.gui_embed_subwindows = true
	viewport.size = viewport_size
	viewport.size_2d_override = viewport_size
	viewport.size_2d_override_stretch = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport


func _get_test_viewport_size() -> Vector2i:
	return Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width", 1280)),
		int(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
	)


func _require_control_inside(label: String, control: Control, bounds: Rect2) -> bool:
	if control == null:
		return _fail("Missing control for bounds check: %s" % label)
	var rect: Rect2 = control.get_global_rect()
	if rect.position.x < bounds.position.x - LAYOUT_EPSILON:
		return _fail("%s starts outside bounds on X: %.2f < %.2f (rect=%s bounds=%s)" % [label, rect.position.x, bounds.position.x, rect, bounds])
	if rect.position.y < bounds.position.y - LAYOUT_EPSILON:
		return _fail("%s starts outside bounds on Y: %.2f < %.2f (rect=%s bounds=%s)" % [label, rect.position.y, bounds.position.y, rect, bounds])
	if rect.end.x > bounds.end.x + LAYOUT_EPSILON:
		return _fail("%s exceeds bounds on X: %.2f > %.2f (rect=%s bounds=%s)" % [label, rect.end.x, bounds.end.x, rect, bounds])
	if rect.end.y > bounds.end.y + LAYOUT_EPSILON:
		return _fail("%s exceeds bounds on Y: %.2f > %.2f (rect=%s bounds=%s)" % [label, rect.end.y, bounds.end.y, rect, bounds])
	return true


func _require_vbox_content_fit(label: String, box: VBoxContainer) -> bool:
	var child_count: int = 0
	var total_height: float = 0.0
	for child in box.get_children():
		if child is Control and (child as Control).visible:
			var control: Control = child as Control
			total_height += _get_control_required_height(control)
			child_count += 1
	if child_count > 1:
		total_height += float(box.get_theme_constant("separation")) * float(child_count - 1)
	if total_height > box.size.y + LAYOUT_EPSILON:
		return _fail("%s content height exceeds container: %.2f > %.2f" % [label, total_height, box.size.y])
	return true


func _require_hbox_content_fit(label: String, box: HBoxContainer) -> bool:
	var child_count: int = 0
	var total_width: float = 0.0
	for child in box.get_children():
		if child is Control and (child as Control).visible:
			var control: Control = child as Control
			total_width += _get_control_required_width(control)
			child_count += 1
	if child_count > 1:
		total_width += float(box.get_theme_constant("separation")) * float(child_count - 1)
	if total_width > box.size.x + LAYOUT_EPSILON:
		return _fail("%s content width exceeds container: %.2f > %.2f" % [label, total_width, box.size.x])
	return true


func _get_control_required_width(control: Control) -> float:
	var minimum_size: Vector2 = control.custom_minimum_size
	if minimum_size.x > 0.0:
		return minimum_size.x
	return control.get_combined_minimum_size().x


func _get_control_required_height(control: Control) -> float:
	var minimum_size: Vector2 = control.custom_minimum_size
	if minimum_size.y > 0.0:
		return minimum_size.y
	return control.get_combined_minimum_size().y


func _relative_luminance(color: Color) -> float:
	var r: float = _to_linear_channel(color.r)
	var g: float = _to_linear_channel(color.g)
	var b: float = _to_linear_channel(color.b)
	return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)


func _contrast_ratio(a: Color, b: Color) -> float:
	var a_luminance: float = _relative_luminance(a)
	var b_luminance: float = _relative_luminance(b)
	var lighter: float = maxf(a_luminance, b_luminance)
	var darker: float = minf(a_luminance, b_luminance)
	return (lighter + 0.05) / (darker + 0.05)


func _to_linear_channel(value: float) -> float:
	if value <= 0.04045:
		return value / 12.92
	return pow((value + 0.055) / 1.055, 2.4)
