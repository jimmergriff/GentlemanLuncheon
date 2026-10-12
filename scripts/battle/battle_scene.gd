extends Node2D
class_name BattleScene

signal exit_requested()

const FIGHTER_SCENE: PackedScene = preload("res://scenes/battle/Fighter.tscn")
const UI_THEME: Theme = preload("res://resources/fury_poster_theme.tres")
const SHAKE_DECAY: float = 8.0
const SHAKE_INTENSITY: float = 6.0
const MAX_DAMAGE_NUMBERS: int = 16
const DEMO_RESTART_DELAY: float = 0.6
const CAMERA_STAGE_FIT_OVERSCAN: float = 0.94
const MENU_DEMO_ZOOM_MIN_MULT: float = 0.94
const MENU_DEMO_ZOOM_MAX_MULT: float = 1.42
const MENU_DEMO_ZOOM_TARGET_BIAS: float = 1.46
const MENU_DEMO_ZOOM_SPREAD_DIVISOR: float = 640.0
const MENU_DEMO_CENTER_ZONE_RATIO: float = 0.58
const MENU_DEMO_TRACK_BASE_SPEED: float = 7.2
const MENU_DEMO_HIT_ZOOM_BOOST_SCALE: float = 0.004
const PAUSE_REFERENCE_SIZE: Vector2 = Vector2(1280.0, 720.0)
const PAUSE_COMPACT_ASPECT: float = 1.55
const MENU_BUTTON_BASE_FONT_COLOR: Color = Color(0.94902, 0.960784, 0.988235, 1.0)
const MENU_BUTTON_HOVER_FONT_COLOR: Color = Color(1.0, 0.94902, 0.705882, 1.0)
const MENU_BUTTON_FOCUS_FONT_COLOR: Color = Color(0.172549, 0.0470588, 0.0392157, 1.0)
const MENU_BUTTON_FOCUS_HOVER_COLOR: Color = Color(0.231373, 0.0705882, 0.054902, 1.0)

@onready var background: Sprite2D = $StageRoot/Background
@onready var fighters_root: Node2D = $StageRoot/Fighters
@onready var camera: Camera2D = $Camera2D
@onready var battle_hud: Node = $HUD/BattleHud

var stage_data: Dictionary = {}
var session_data: Dictionary = {}
var stage_rect: Rect2 = Rect2()
var _stage_size: Vector2 = Vector2.ZERO
var fighters: Array[Fighter] = []
var battle_finished: bool = false
var battle_mode: String = "ffa"  # "ffa" or "2v2"
var _paused: bool = false
var _shake_amount: float = 0.0
var _camera_base: Vector2 = Vector2.ZERO
var _shake_offset: Vector2 = Vector2.ZERO
var _damage_numbers: Array[DamageNumber] = []
var _damage_number_root: Node2D = null
var _hit_flash_material: ShaderMaterial = null
var _prev_hp: Dictionary = {}
var _bg_anim_frames: Array[Texture2D] = []
var _bg_anim_interval: float = 0.0
var _bg_anim_timer: float = 0.0
var _bg_anim_index: int = 0
var _bgm_player: AudioStreamPlayer = null
var _result_sfx_player: AudioStreamPlayer = null
var _mute_audio: bool = false
var _loop_demo: bool = false
var _menu_demo_camera: bool = false
var _demo_restart_timer: float = 0.0
var _last_viewport_size: Vector2 = Vector2.ZERO
var _demo_base_zoom: float = 1.0
var _demo_zoom: float = 1.0
var _pause_menu_layer: CanvasLayer = null
var _pause_menu_scrim: ColorRect = null
var _pause_menu_panel: Panel = null
var _pause_menu_accent_top: ColorRect = null
var _pause_menu_accent_glow: ColorRect = null
var _pause_menu_title: Label = null
var _pause_menu_subtitle: Label = null
var _pause_menu_buttons: VBoxContainer = null
var _pause_buttons: Array[Button] = []
var _pause_focus_index: int = 0


func _ready() -> void:
	_connect_language_signal()
	_damage_number_root = Node2D.new()
	_damage_number_root.name = "DamageNumbers"
	$StageRoot.add_child(_damage_number_root)
	var shader: Shader = load("res://shaders/hit_flash.gdshader") as Shader
	if shader != null:
		_hit_flash_material = ShaderMaterial.new()
		_hit_flash_material.shader = shader
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	_bgm_player.volume_db = -6.0
	add_child(_bgm_player)
	_result_sfx_player = AudioStreamPlayer.new()
	_result_sfx_player.bus = "Master"
	add_child(_result_sfx_player)
	_ensure_pause_menu()
	_refresh_localized_text()


func start_session(session: Dictionary) -> void:
	session_data = session
	battle_finished = false
	battle_mode = String(session.get("mode", "ffa"))
	_set_battle_paused(false)
	if _pause_menu_layer != null:
		_pause_menu_layer.visible = false
	_mute_audio = bool(session.get("mute_audio", false))
	_loop_demo = bool(session.get("loop_demo", false))
	_menu_demo_camera = bool(session.get("menu_demo_camera", false))
	_demo_restart_timer = 0.0
	_shake_amount = 0.0
	_shake_offset = Vector2.ZERO
	_demo_base_zoom = 1.0
	_demo_zoom = 1.0
	$StageRoot.position = Vector2.ZERO
	$StageRoot.scale = Vector2.ONE
	camera.offset = Vector2.ZERO
	_stop_audio()
	for child in fighters_root.get_children():
		child.queue_free()
	fighters.clear()
	_prev_hp.clear()
	_load_stage()
	_spawn_fighters()
	_configure_ui()
	_start_bgm()
	if _menu_demo_camera:
		camera.enabled = false
		_apply_embedded_demo_camera()
	elif camera.enabled:
		camera.make_current()


func _connect_language_signal() -> void:
	var config: Node = get_node_or_null("/root/GameConfig")
	if config == null or not config.has_signal("language_changed"):
		return
	if not config.language_changed.is_connected(_on_language_changed):
		config.language_changed.connect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	_refresh_localized_text()


func _refresh_localized_text() -> void:
	battle_hud.set_help_text(Localization.text("battle.help"))
	_refresh_name_labels()
	_refresh_info_label()
	_refresh_pause_menu_text()


func _ensure_pause_menu() -> void:
	if _pause_menu_layer != null:
		return

	_pause_menu_layer = CanvasLayer.new()
	_pause_menu_layer.layer = 24
	add_child(_pause_menu_layer)

	_pause_menu_scrim = ColorRect.new()
	_pause_menu_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_menu_scrim.color = Color(0.03, 0.01, 0.01, 0.74)
	_pause_menu_layer.add_child(_pause_menu_scrim)

	_pause_menu_panel = Panel.new()
	_pause_menu_panel.theme = UI_THEME
	_pause_menu_layer.add_child(_pause_menu_panel)

	_pause_menu_accent_top = ColorRect.new()
	_pause_menu_accent_top.color = Color(0.968627, 0.4, 0.137255, 1.0)
	_pause_menu_panel.add_child(_pause_menu_accent_top)

	_pause_menu_accent_glow = ColorRect.new()
	_pause_menu_accent_glow.color = Color(1.0, 0.85098, 0.364706, 0.92)
	_pause_menu_panel.add_child(_pause_menu_accent_glow)

	_pause_menu_title = Label.new()
	_pause_menu_title.theme = UI_THEME
	_pause_menu_panel.add_child(_pause_menu_title)

	_pause_menu_subtitle = Label.new()
	_pause_menu_subtitle.theme = UI_THEME
	_pause_menu_panel.add_child(_pause_menu_subtitle)

	_pause_menu_buttons = VBoxContainer.new()
	_pause_menu_buttons.theme = UI_THEME
	_pause_menu_panel.add_child(_pause_menu_buttons)

	for button_id in ["continue", "restart", "menu"]:
		var button: Button = Button.new()
		button.name = button_id
		button.theme = UI_THEME
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_pause_menu_pressed.bind(button_id))
		_pause_menu_buttons.add_child(button)
		_pause_buttons.append(button)

	_pause_menu_layer.visible = false
	_refresh_pause_menu_text()
	_layout_pause_menu()


func _refresh_pause_menu_text() -> void:
	if _pause_menu_title == null:
		return
	_pause_menu_title.text = Localization.text("battle.pause.title")
	_pause_menu_subtitle.text = Localization.text("battle.pause.subtitle")
	if _pause_buttons.size() >= 3:
		_pause_buttons[0].text = _with_button_hint(Localization.text("battle.pause.continue"), "ESC")
		_pause_buttons[1].text = _with_button_hint(Localization.text("battle.pause.restart"), "R")
		_pause_buttons[2].text = _with_button_hint(Localization.text("battle.pause.menu"), "ENTER")
	_update_pause_menu_focus()


func _with_button_hint(label: String, hint: String) -> String:
	return "%s  [%s]" % [label, hint]


func _show_pause_menu() -> void:
	_ensure_pause_menu()
	_set_battle_paused(true)
	_pause_focus_index = 0
	_pause_menu_layer.visible = true
	_layout_pause_menu()
	_update_pause_menu_focus()


func _hide_pause_menu() -> void:
	_set_battle_paused(false)
	if _pause_menu_layer != null:
		_pause_menu_layer.visible = false


func _toggle_pause_menu() -> void:
	if _pause_menu_layer != null and _pause_menu_layer.visible:
		_hide_pause_menu()
	else:
		_show_pause_menu()


func _set_battle_paused(paused: bool) -> void:
	_paused = paused
	var process_mode: int = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	for fighter in fighters:
		if fighter != null:
			fighter.process_mode = process_mode
	if fighters_root != null:
		fighters_root.process_mode = process_mode
	if camera != null:
		camera.process_mode = process_mode
	if _damage_number_root != null:
		_damage_number_root.process_mode = process_mode
	if _bgm_player != null:
		_bgm_player.stream_paused = paused
	if _result_sfx_player != null:
		_result_sfx_player.stream_paused = paused


func _layout_pause_menu() -> void:
	if _pause_menu_layer == null or _pause_menu_panel == null:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var aspect: float = viewport_size.x / maxf(viewport_size.y, 1.0)
	var compact: bool = aspect < PAUSE_COMPACT_ASPECT
	var scale: float = clampf(
		minf(viewport_size.x / PAUSE_REFERENCE_SIZE.x, viewport_size.y / PAUSE_REFERENCE_SIZE.y),
		0.85,
		1.4
	)
	_pause_menu_scrim.position = Vector2.ZERO
	_pause_menu_scrim.size = viewport_size

	var panel_size: Vector2 = Vector2(
		clampf(viewport_size.x * (0.38 if compact else 0.32), 330.0 * scale, 460.0 * scale),
		clampf(viewport_size.y * 0.52, 300.0 * scale, 440.0 * scale)
	)
	_pause_menu_panel.position = (viewport_size - panel_size) * 0.5
	_pause_menu_panel.size = panel_size

	_pause_menu_accent_top.position = Vector2(18.0 * scale, 18.0 * scale)
	_pause_menu_accent_top.size = Vector2(panel_size.x * 0.56, maxf(9.0 * scale, 9.0))
	_pause_menu_accent_glow.position = Vector2(18.0 * scale, 30.0 * scale)
	_pause_menu_accent_glow.size = Vector2(panel_size.x * 0.72, maxf(4.0 * scale, 4.0))

	_pause_menu_title.position = Vector2(24.0 * scale, 48.0 * scale)
	_pause_menu_title.size = Vector2(panel_size.x - (48.0 * scale), 42.0 * scale)
	_pause_menu_title.add_theme_font_size_override("font_size", int(roundf(clampf(28.0 * scale, 24.0, 34.0))))

	_pause_menu_subtitle.position = Vector2(26.0 * scale, 84.0 * scale)
	_pause_menu_subtitle.size = Vector2(panel_size.x - (52.0 * scale), 20.0 * scale)
	_pause_menu_subtitle.add_theme_font_size_override("font_size", int(roundf(clampf(12.0 * scale, 11.0, 14.0))))

	_pause_menu_buttons.position = Vector2(24.0 * scale, 126.0 * scale)
	_pause_menu_buttons.size = Vector2(panel_size.x - (48.0 * scale), panel_size.y - (150.0 * scale))
	_pause_menu_buttons.add_theme_constant_override("separation", int(roundf(clampf(12.0 * scale, 10.0, 16.0))))

	var button_size: Vector2 = Vector2(
		_pause_menu_buttons.size.x,
		roundf(clampf(48.0 * scale, 44.0, 56.0))
	)
	for button in _pause_buttons:
		button.custom_minimum_size = button_size


func _update_pause_menu_focus() -> void:
	if _pause_buttons.is_empty():
		return
	var focus_style: StyleBox = UI_THEME.get_stylebox("focus", "Button")
	for i in range(_pause_buttons.size()):
		var btn: Button = _pause_buttons[i]
		if i == _pause_focus_index:
			btn.add_theme_stylebox_override("normal", focus_style)
			btn.add_theme_stylebox_override("hover", focus_style)
			btn.add_theme_stylebox_override("pressed", focus_style)
			btn.add_theme_color_override("font_color", MENU_BUTTON_FOCUS_FONT_COLOR)
			btn.add_theme_color_override("font_hover_color", MENU_BUTTON_FOCUS_HOVER_COLOR)
			btn.add_theme_color_override("font_pressed_color", MENU_BUTTON_FOCUS_FONT_COLOR)
			btn.add_theme_color_override("font_focus_color", MENU_BUTTON_FOCUS_FONT_COLOR)
		else:
			btn.remove_theme_stylebox_override("normal")
			btn.remove_theme_stylebox_override("hover")
			btn.remove_theme_stylebox_override("pressed")
			btn.add_theme_color_override("font_color", MENU_BUTTON_BASE_FONT_COLOR)
			btn.add_theme_color_override("font_hover_color", MENU_BUTTON_HOVER_FONT_COLOR)
			btn.add_theme_color_override("font_pressed_color", MENU_BUTTON_BASE_FONT_COLOR)
			btn.add_theme_color_override("font_focus_color", MENU_BUTTON_BASE_FONT_COLOR)


func _move_pause_focus(direction: int) -> void:
	if _pause_buttons.is_empty():
		return
	_pause_focus_index = wrapi(_pause_focus_index + direction, 0, _pause_buttons.size())
	_update_pause_menu_focus()


func _activate_pause_menu_action() -> void:
	if _pause_buttons.is_empty():
		return
	_on_pause_menu_pressed(_pause_buttons[_pause_focus_index].name)


func _on_pause_menu_pressed(action: String) -> void:
	match action:
		"continue":
			_hide_pause_menu()
		"restart":
			_hide_pause_menu()
			start_session(session_data.duplicate(true))
		"menu":
			_hide_pause_menu()
			exit_requested.emit()


func _notification(what: int) -> void:
	if false:
		pass


func _refresh_name_labels() -> void:
	var fallback_avatar: Texture2D = _load_optional_texture("res://assets/extracted/main/avatar-unknown.png")
	battle_hud.configure_slots(fighters.size())
	for i in range(fighters.size()):
		var fighter: Fighter = fighters[i]
		var label_tint: Color = Color(0.96, 0.97, 1.0)
		if battle_mode == "2v2":
			if fighter.team_id == 0:
				label_tint = Color(0.4, 0.85, 1.0)
			else:
				label_tint = Color(1.0, 0.6, 0.45)
		var label_text: String = "%s%s" % [GameData.get_role_display_name(fighter.role_data), _get_fighter_tag(fighter, i)]
		battle_hud.set_slot_name(i, label_text, label_tint)
		battle_hud.set_slot_hp(i, fighter.hp, fighter.max_hp)
		battle_hud.set_slot_defeated(i, fighter.is_defeated())
		var role_id: String = String(fighter.role_data.get("id", ""))
		var avatar_path: String = "res://assets/extracted/main/avatar-%s.png" % role_id
		var avatar_tex: Texture2D = _load_optional_texture(avatar_path)
		battle_hud.set_slot_avatar(i, avatar_tex if avatar_tex != null else fallback_avatar)


func _get_fighter_tag(fighter: Fighter, fighter_index: int) -> String:
	if battle_mode == "2v2":
		if fighter.control_mode == "human":
			return Localization.text("battle.tag.player")
		if fighter.team_id == 0:
			return Localization.text("battle.tag.ally")
		return Localization.text("battle.tag.enemy")
	if fighter.control_mode == "cpu":
		return Localization.text("battle.tag.cpu")
	if fighter_index == 0:
		return Localization.text("battle.tag.player")
	return ""


func _refresh_info_label() -> void:
	if fighters.is_empty():
		battle_hud.set_center_text(Localization.text("battle.mode.ffa"))
		return
	if not battle_finished:
		battle_hud.set_center_text(
			Localization.text("battle.mode.team") if battle_mode == "2v2" else Localization.text("battle.mode.ffa")
		)
		return
	if battle_mode == "2v2":
		battle_hud.show_result_banner(_get_team_result_text())
	else:
		battle_hud.show_result_banner(_get_ffa_result_text())


func _format_result_banner(message: String) -> String:
	return "%s  |  %s" % [message, Localization.text("battle.result.return_hint")]


func _get_ffa_result_text() -> String:
	var living: Array[Fighter] = []
	for fighter in fighters:
		if not fighter.is_defeated():
			living.append(fighter)
	if living.is_empty():
		return _format_result_banner(Localization.text("battle.result.draw"))
	var winner: Fighter = living[0]
	var title: String = GameData.get_role_display_name(winner.role_data)
	if winner.control_mode == "cpu":
		title += Localization.text("battle.tag.cpu")
	else:
		title += Localization.text("battle.tag.player")
	return _format_result_banner(Localization.text("battle.result.wins", [title]))


func _get_team_result_text() -> String:
	var team0_alive: bool = false
	var team1_alive: bool = false
	for fighter in fighters:
		if not fighter.is_defeated():
			if fighter.team_id == 0:
				team0_alive = true
			elif fighter.team_id == 1:
				team1_alive = true
	if not team0_alive and not team1_alive:
		return _format_result_banner(Localization.text("battle.result.draw"))
	if team0_alive:
		return _format_result_banner(Localization.text("battle.result.team_win"))
	return _format_result_banner(Localization.text("battle.result.team_lose"))


func _load_optional_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return null
	return load(path) as Texture2D


func _fit_camera_to_stage() -> void:
	if camera == null or _stage_size.x <= 0.0 or _stage_size.y <= 0.0:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_zoom: float = (viewport_size.y / _stage_size.y) * CAMERA_STAGE_FIT_OVERSCAN
	fit_zoom = clampf(fit_zoom, 1.12, 1.55)
	_demo_base_zoom = fit_zoom
	if _menu_demo_camera:
		if _demo_zoom <= 0.0:
			_demo_zoom = fit_zoom * 1.08
		_demo_zoom = clampf(_demo_zoom, fit_zoom * MENU_DEMO_ZOOM_MIN_MULT, fit_zoom * MENU_DEMO_ZOOM_MAX_MULT)
		camera.zoom = Vector2(_demo_zoom, _demo_zoom)
		_apply_embedded_demo_camera()
		return
	camera.zoom = Vector2(fit_zoom, fit_zoom)


func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size != _last_viewport_size:
		_last_viewport_size = viewport_size
		_fit_camera_to_stage()
	if _pause_menu_layer != null and _pause_menu_layer.visible:
		_layout_pause_menu()
	if _paused:
		return
	if battle_finished and _loop_demo and _demo_restart_timer > 0.0:
		_demo_restart_timer = maxf(_demo_restart_timer - delta, 0.0)
		if _demo_restart_timer <= 0.0:
			start_session(session_data.duplicate(true))
		return
	if fighters.size() >= 2:
		_update_camera()
		_check_battle_state()
	elif _menu_demo_camera:
		_apply_embedded_demo_camera()
	_update_shake(delta)
	_update_hit_flash(delta)
	_update_bg_anim(delta)


func _apply_embedded_demo_camera() -> void:
	if not _menu_demo_camera or _stage_size == Vector2.ZERO:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var zoom_value: float = maxf(_demo_zoom, 0.001)
	$StageRoot.scale = Vector2.ONE * zoom_value
	$StageRoot.position = (viewport_size * 0.5) - (_camera_base * zoom_value) + _shake_offset


func _unhandled_input(event: InputEvent) -> void:
	if _pause_menu_layer != null and _pause_menu_layer.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.is_action_pressed("ui_up"):
				_move_pause_focus(-1)
				get_viewport().set_input_as_handled()
				return
			if event.is_action_pressed("ui_down"):
				_move_pause_focus(1)
				get_viewport().set_input_as_handled()
				return
			if event.is_action_pressed("ui_accept"):
				_activate_pause_menu_action()
				get_viewport().set_input_as_handled()
				return
			if event.is_action_pressed("ui_cancel"):
				_hide_pause_menu()
				get_viewport().set_input_as_handled()
				return
			var key_event: InputEventKey = event as InputEventKey
			if key_event.keycode == KEY_R or key_event.physical_keycode == KEY_R:
				_on_pause_menu_pressed("restart")
				get_viewport().set_input_as_handled()
				return
		return
	if event is InputEventKey and event.pressed and not event.echo and event.is_action_pressed("ui_cancel"):
		if request_exit_confirm():
			get_viewport().set_input_as_handled()


func request_exit_confirm() -> bool:
	_toggle_pause_menu()
	return true


func _load_stage() -> void:
	var stage_id: String = String(session_data.get("stage_id", ""))
	if stage_id.is_empty():
		stage_id = _pick_random_stage()
	stage_data = GameData.load_stage(stage_id)
	if stage_data.is_empty():
		stage_data = GameData.load_stage("arena_1")
	var size_values: Array = stage_data.get("size", [1280, 510])
	var stage_size: Vector2 = Vector2(float(size_values[0]), float(size_values[1]))
	_stage_size = stage_size
	var texture: Texture2D = _load_optional_texture("res://%s" % stage_data.get("background", ""))
	background.texture = texture
	background.position = stage_size / 2.0
	$StageRoot.position = Vector2.ZERO
	_camera_base = Vector2(stage_size.x / 2.0, stage_size.y / 2.0)
	camera.position = _camera_base
	_fit_camera_to_stage()
	camera.offset = Vector2.ZERO
	stage_rect = Rect2(
		Vector2(float(stage_data.get("land_origin", [20, 268])[0]), float(stage_data.get("land_origin", [20, 268])[1])),
		Vector2(float(stage_data.get("land_size", [1240, 242])[0]), float(stage_data.get("land_size", [1240, 242])[1]))
	)
	_load_bg_anim()


func _spawn_fighters() -> void:
	var roster: Array[Dictionary] = []
	var training_dummy: bool = bool(session_data.get("training_dummy", false))
	var player_mode: String = String(session_data.get("player_mode", "human"))
	var player_prefix: String = "p1" if player_mode == "human" else ""
	var ai_difficulty: String = String(session_data.get("ai_difficulty", "normal"))

	if battle_mode == "2v2":
		# Team 0: player + partner, Team 1: two enemies
		roster.append({
			"role_id": String(session_data.get("player_role_id", "beach")),
			"mode": player_mode, "prefix": player_prefix, "team": 0,
		})
		roster.append({
			"role_id": String(session_data.get("partner_role_id", "spence")),
			"mode": "cpu", "prefix": "", "team": 0,
		})
		for role_id in session_data.get("enemy_role_ids", []):
			roster.append({
				"role_id": String(role_id),
				"mode": "cpu", "prefix": "", "team": 1,
			})
	else:
		# FFA: all-vs-all
		roster.append({
			"role_id": String(session_data.get("player_role_id", "beach")),
			"mode": player_mode, "prefix": player_prefix, "team": -1,
		})
		for role_id in session_data.get("cpu_role_ids", []):
			roster.append({
				"role_id": String(role_id),
				"mode": "dummy" if training_dummy else "cpu",
				"prefix": "", "team": -1,
			})

	for entry in roster:
		var fighter: Fighter = FIGHTER_SCENE.instantiate() as Fighter
		fighters_root.add_child(fighter)
		fighter.setup(GameData.load_role(entry["role_id"]), stage_rect, entry["mode"], entry["prefix"])
		fighter.ai_difficulty = ai_difficulty if String(entry["mode"]) == "cpu" else "normal"
		fighter.team_id = int(entry["team"])
		fighter.hp_changed.connect(_on_fighter_hp_changed.bind(fighter))
		fighter.defeated.connect(_on_fighter_defeated.bind(fighter))
		fighters.append(fighter)
		_prev_hp[fighter.get_instance_id()] = fighter.max_hp
		if _hit_flash_material != null:
			fighter.visual.material = _hit_flash_material.duplicate() as ShaderMaterial

	# Set opponents: in 2v2 only enemy team, in FFA everyone else
	for fighter in fighters:
		var others: Array[Fighter] = []
		for other in fighters:
			if other == fighter:
				continue
			if battle_mode == "2v2":
				if other.team_id != fighter.team_id:
					others.append(other)
			else:
				others.append(other)
		fighter.set_opponents(others)
		if fighter.control_mode == "dummy":
			fighter.max_hp = 999999
			fighter.hp = fighter.max_hp
			fighter.hp_changed.emit(fighter.hp, fighter.max_hp)

	# Spawn positions: team 0 on left, team 1 on right
	var mid_x: float = stage_rect.position.x + stage_rect.size.x / 2.0
	var base_y: float = stage_rect.position.y + stage_rect.size.y / 2.0
	var spawn_points: Array[Vector2] = [
		Vector2(mid_x - 180.0, base_y - 55.0),
		Vector2(mid_x - 90.0, base_y + 25.0),
		Vector2(mid_x + 180.0, base_y - 55.0),
		Vector2(mid_x + 90.0, base_y + 25.0),
	]
	for i in range(min(spawn_points.size(), fighters.size())):
		fighters[i].set_spawn_position(spawn_points[i])


func _configure_ui() -> void:
	battle_hud.configure_slots(fighters.size())
	_refresh_localized_text()


func _on_fighter_hp_changed(current_hp: int, _max_hp: int, fighter: Fighter) -> void:
	var fighter_index: int = fighters.find(fighter)
	if fighter_index >= 0:
		battle_hud.set_slot_hp(fighter_index, current_hp, fighter.max_hp)
	# Damage number
	var fid: int = fighter.get_instance_id()
	var old_hp: int = int(_prev_hp.get(fid, current_hp))
	_prev_hp[fid] = current_hp
	var damage: int = old_hp - current_hp
	if damage > 0:
		_spawn_damage_number(damage, fighter.position, fid)
	# Hit flash
	if damage > 0 and fighter.visual.material is ShaderMaterial:
		(fighter.visual.material as ShaderMaterial).set_shader_parameter("flash_amount", 1.0)
	# Screen shake only on final blow
	if damage > 0 and fighter.last_damage_attack_name == "final_blow":
		_shake_amount = SHAKE_INTENSITY


func _on_fighter_defeated(_defeated_fighter: Fighter, fighter: Fighter) -> void:
	var fighter_index: int = fighters.find(fighter)
	if fighter_index >= 0:
		battle_hud.set_slot_defeated(fighter_index, true)


func _check_battle_state() -> void:
	if battle_finished:
		return
	if battle_mode == "2v2":
		_check_team_battle_state()
	else:
		_check_ffa_battle_state()


func _check_ffa_battle_state() -> void:
	var living: Array[Fighter] = []
	for fighter in fighters:
		if not fighter.is_defeated():
			living.append(fighter)
	if living.size() > 1:
		return
	battle_finished = true
	if living.is_empty():
		_refresh_info_label()
		if _loop_demo:
			_demo_restart_timer = DEMO_RESTART_DELAY
		return
	var winner: Fighter = living[0]
	if winner.control_mode == "cpu":
		_play_result_sfx("lost")
	else:
		_play_result_sfx("win")
	_refresh_info_label()
	if _loop_demo:
		_demo_restart_timer = DEMO_RESTART_DELAY


func _check_team_battle_state() -> void:
	var team0_alive: bool = false
	var team1_alive: bool = false
	for fighter in fighters:
		if not fighter.is_defeated():
			if fighter.team_id == 0:
				team0_alive = true
			elif fighter.team_id == 1:
				team1_alive = true
	if team0_alive and team1_alive:
		return
	battle_finished = true
	if team0_alive:
		_play_result_sfx("win")
	elif team1_alive:
		_play_result_sfx("lost")
	_refresh_info_label()
	if _loop_demo:
		_demo_restart_timer = DEMO_RESTART_DELAY


func _update_camera() -> void:
	var delta: float = get_process_delta_time()
	var alive_xs: Array[float] = []
	for fighter in fighters:
		if not fighter.is_defeated():
			alive_xs.append(fighter.ground_position.x)
	if alive_xs.is_empty():
		return
	var min_alive_x: float = alive_xs[0]
	var max_alive_x: float = alive_xs[0]
	for x in alive_xs:
		min_alive_x = minf(min_alive_x, x)
		max_alive_x = maxf(max_alive_x, x)
	var target_x: float = (min_alive_x + max_alive_x) / 2.0
	var follow_speed: float = 1.0 - exp(-5.0 * delta)
	if _menu_demo_camera:
		var spread: float = max_alive_x - min_alive_x
		var target_zoom: float = clampf(
			_demo_base_zoom * (MENU_DEMO_ZOOM_TARGET_BIAS - (spread / MENU_DEMO_ZOOM_SPREAD_DIVISOR)) + (_shake_amount * MENU_DEMO_HIT_ZOOM_BOOST_SCALE),
			_demo_base_zoom * MENU_DEMO_ZOOM_MIN_MULT,
			_demo_base_zoom * MENU_DEMO_ZOOM_MAX_MULT
		)
		_demo_zoom = lerpf(_demo_zoom, target_zoom, 1.0 - exp(-4.8 * delta))
		camera.zoom = Vector2(_demo_zoom, _demo_zoom)
		follow_speed = 1.0 - exp(-(MENU_DEMO_TRACK_BASE_SPEED + minf(spread / 180.0, 2.6)) * delta)
	var viewport_size: Vector2 = get_viewport_rect().size
	var visible_ratio: float = MENU_DEMO_CENTER_ZONE_RATIO if _menu_demo_camera else 1.0
	var half_vp: float = viewport_size.x * 0.5 * visible_ratio / maxf(camera.zoom.x, 0.001)
	var camera_min_x: float = maxf(half_vp, stage_rect.position.x + half_vp)
	var camera_max_x: float = minf(
		_stage_size.x - half_vp,
		stage_rect.position.x + stage_rect.size.x - half_vp
	)
	var desired_x: float = clampf(target_x, camera_min_x, maxf(camera_max_x, camera_min_x))
	_camera_base.x = lerpf(_camera_base.x, desired_x, follow_speed)
	camera.position = _camera_base
	camera.offset = _shake_offset
	var camera_margin: float = 24.0 / maxf(camera.zoom.x, 0.001)
	var cam_left: float = _camera_base.x - half_vp + camera_margin
	var cam_right: float = _camera_base.x + half_vp - camera_margin
	for fighter in fighters:
		if not fighter.is_defeated() and fighter.current_state not in ["hit_fly", "hit_fly_fall", "fall", "ride_jump", "lift_jump", "lift_fall"]:
			fighter.ground_position.x = clampf(fighter.ground_position.x, cam_left, cam_right)
	if _menu_demo_camera:
		_apply_embedded_demo_camera()


func _update_shake(delta: float) -> void:
	if _shake_amount <= 0.1:
		_shake_amount = 0.0
		_shake_offset = Vector2.ZERO
		camera.offset = Vector2.ZERO
		if _menu_demo_camera:
			_apply_embedded_demo_camera()
		return
	_shake_amount = move_toward(_shake_amount, 0.0, SHAKE_DECAY * delta)
	_shake_offset = Vector2(
		randf_range(-_shake_amount, _shake_amount),
		randf_range(-_shake_amount, _shake_amount)
	)
	camera.offset = _shake_offset
	if _menu_demo_camera:
		_apply_embedded_demo_camera()


func _update_hit_flash(delta: float) -> void:
	for fighter in fighters:
		if fighter.visual.material is ShaderMaterial:
			var mat: ShaderMaterial = fighter.visual.material as ShaderMaterial
			var current_flash: float = 0.0
			var flash_value: Variant = mat.get_shader_parameter("flash_amount")
			if flash_value is float or flash_value is int:
				current_flash = flash_value
			if current_flash > 0.0:
				mat.set_shader_parameter("flash_amount", maxf(current_flash - 10.0 * delta, 0.0))


func _spawn_damage_number(damage: int, world_pos: Vector2, target_id: int) -> void:
	# Try to accumulate on existing
	for dn in _damage_numbers:
		if dn.is_active() and dn.can_accumulate() and dn.get_target_id() == target_id:
			dn.accumulate(damage)
			return
	# Find or create
	var dn: DamageNumber = null
	for existing in _damage_numbers:
		if not existing.is_active():
			dn = existing
			break
	if dn == null:
		if _damage_numbers.size() >= MAX_DAMAGE_NUMBERS:
			dn = _damage_numbers[0]
		else:
			dn = DamageNumber.new()
			_damage_number_root.add_child(dn)
			_damage_numbers.append(dn)
	dn.show_damage(damage, world_pos, target_id)


func _pick_random_stage() -> String:
	var all_stages: Array = GameData.get_stage_ids()
	if all_stages.is_empty():
		return "arena_1"
	return all_stages[randi() % all_stages.size()]


func _start_bgm() -> void:
	if _mute_audio:
		return
	var path: String = "res://%s" % String(stage_data.get("bgm", "assets/audio/bgm/stage01.ogg"))
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	_bgm_player.stream = stream
	_bgm_player.play()


func _play_result_sfx(key: String) -> void:
	if _mute_audio:
		return
	_bgm_player.stop()
	var path: String = ""
	match key:
		"win":
			path = "res://assets/audio/bgm/win.wav"
		"lost":
			path = "res://assets/audio/bgm/lost.wav"
	if path.is_empty():
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	_result_sfx_player.stream = stream
	_result_sfx_player.play()


func _stop_audio() -> void:
	if _bgm_player != null:
		_bgm_player.stop()
		_bgm_player.stream = null
	if _result_sfx_player != null:
		_result_sfx_player.stop()
		_result_sfx_player.stream = null


func _load_bg_anim() -> void:
	_bg_anim_frames.clear()
	_bg_anim_timer = 0.0
	_bg_anim_index = 0
	var frame_count: int = int(stage_data.get("anim_frames", 1))
	var pattern: String = String(stage_data.get("anim_pattern", ""))
	_bg_anim_interval = float(stage_data.get("anim_interval", 0.28))
	if frame_count <= 1 or pattern.is_empty():
		return
	for i in range(frame_count):
		var path: String = "res://%s" % (pattern % i)
		var tex: Texture2D = load(path) as Texture2D
		if tex != null:
			_bg_anim_frames.append(tex)


func _update_bg_anim(delta: float) -> void:
	if _bg_anim_frames.size() <= 1:
		return
	_bg_anim_timer += delta
	if _bg_anim_timer < _bg_anim_interval:
		return
	_bg_anim_timer = 0.0
	_bg_anim_index = (_bg_anim_index + 1) % _bg_anim_frames.size()
	background.texture = _bg_anim_frames[_bg_anim_index]
