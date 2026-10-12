extends Control

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const UI_THEME: Theme = preload("res://resources/fury_poster_theme.tres")
const PRIMARY_LOGO_PATH: String = "res://assets/branding/fury_fist_logo.png"

const SPLASH_FADE_IN: float = 1.0
const SPLASH_HOLD: float = 1.0
const SPLASH_FADE_OUT: float = 0.5
const MENU_REFERENCE_SIZE: Vector2 = Vector2(1280.0, 720.0)
const POSTER_COMPACT_ASPECT: float = 1.55
const MENU_BUTTON_BASE_FONT_COLOR: Color = Color(0.94902, 0.960784, 0.988235, 1.0)
const MENU_BUTTON_HOVER_FONT_COLOR: Color = Color(1.0, 0.94902, 0.705882, 1.0)
const MENU_BUTTON_FOCUS_FONT_COLOR: Color = Color(0.172549, 0.0470588, 0.0392157, 1.0)
const MENU_BUTTON_FOCUS_HOVER_COLOR: Color = Color(0.231373, 0.0705882, 0.054902, 1.0)



@onready var tiled_background: TextureRect = $Background
@onready var background_shade: ColorRect = $BackgroundShade
@onready var menu_layer: Node2D = $MenuLayer
@onready var logo_stack: Control = $MenuLayer/LogoStack
@onready var logo_slash_top: ColorRect = $MenuLayer/LogoStack/LogoSlashTop
@onready var logo: TextureRect = $MenuLayer/LogoStack/Logo
@onready var logo_underline: ColorRect = $MenuLayer/LogoStack/LogoUnderline
@onready var menu_ticket: Panel = $MenuLayer/MenuTicket
@onready var ticket_accent_top: ColorRect = $MenuLayer/MenuTicket/TicketAccentTop
@onready var ticket_accent_glow: ColorRect = $MenuLayer/MenuTicket/TicketAccentGlow
@onready var main_menu: VBoxContainer = $MenuLayer/MenuTicket/MainMenu
@onready var hero_poster: Panel = get_node_or_null("MenuLayer/HeroPoster") as Panel
@onready var submenu_panel: Panel = $MenuLayer/SubmenuPanel
@onready var submenu_title: Label = $MenuLayer/SubmenuPanel/Title
@onready var submenu_buttons: VBoxContainer = $MenuLayer/SubmenuPanel/Buttons
@onready var single_game_button: Button = $MenuLayer/MenuTicket/MainMenu/SingleGame
@onready var network_battle_button: Button = $MenuLayer/MenuTicket/MainMenu/NetworkBattle
@onready var options_button: Button = $MenuLayer/MenuTicket/MainMenu/Options
@onready var help_button: Button = $MenuLayer/MenuTicket/MainMenu/Help
@onready var quit_button: Button = $MenuLayer/MenuTicket/MainMenu/Quit

@onready var front_wave_a: Sprite2D = $MenuLayer/FrontWaveA
@onready var front_wave_b: Sprite2D = $MenuLayer/FrontWaveB
@onready var back_wave_a: Sprite2D = $MenuLayer/BackWaveA
@onready var back_wave_b: Sprite2D = $MenuLayer/BackWaveB
@onready var role_select: Panel = $RoleSelectLayer/RoleSelect
@onready var role_select_title: Label = $RoleSelectLayer/RoleSelect/Title
@onready var role_select_subtitle: Label = $RoleSelectLayer/RoleSelect/Subtitle
@onready var role_select_info_board: Panel = $RoleSelectLayer/RoleSelect/InfoBoard
@onready var role_select_info: Control = $RoleSelectLayer/RoleSelect/InfoBoard/Info
@onready var role_preview_box: Panel = $RoleSelectLayer/RoleSelect/InfoBoard/Info/PreviewBox
@onready var role_name: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/RoleName
@onready var role_preview: TextureRect = $RoleSelectLayer/RoleSelect/InfoBoard/Info/PreviewBox/Preview
@onready var role_stats_grid: GridContainer = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid
@onready var hp_label: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/HpLabel
@onready var hp_value: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/HpValue
@onready var punch_label: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/PunchLabel
@onready var punch_bar: ProgressBar = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/PunchBar
@onready var kick_label: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/KickLabel
@onready var kick_bar: ProgressBar = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/KickBar
@onready var defense_label: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/DefenseLabel
@onready var defense_bar: ProgressBar = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/DefenseBar
@onready var throw_label: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/ThrowLabel
@onready var throw_bar: ProgressBar = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/ThrowBar
@onready var speed_label: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/SpeedLabel
@onready var speed_bar: ProgressBar = $RoleSelectLayer/RoleSelect/InfoBoard/Info/StatsGrid/SpeedBar
@onready var skill_panel: Panel = $RoleSelectLayer/RoleSelect/InfoBoard/Skills
@onready var skill_title: Label = $RoleSelectLayer/RoleSelect/InfoBoard/Skills/SkillTitle
@onready var skill_list: RichTextLabel = $RoleSelectLayer/RoleSelect/InfoBoard/Skills/SkillList
@onready var role_select_roster_strip: Panel = $RoleSelectLayer/RoleSelect/RosterStrip
@onready var role_select_roster_label: Label = $RoleSelectLayer/RoleSelect/RosterStrip/StripLabel
@onready var role_select_roster_cards: HBoxContainer = $RoleSelectLayer/RoleSelect/RosterStrip/Cards
@onready var role_select_buttons: HBoxContainer = $RoleSelectLayer/RoleSelect/RosterStrip/Buttons
@onready var prev_role_button: Button = $RoleSelectLayer/RoleSelect/RosterStrip/Buttons/PrevButton
@onready var next_role_button: Button = $RoleSelectLayer/RoleSelect/RosterStrip/Buttons/NextButton
@onready var select_role_button: Button = $RoleSelectLayer/RoleSelect/RosterStrip/Buttons/SelectButton
@onready var back_role_button: Button = $RoleSelectLayer/RoleSelect/RosterStrip/Buttons/BackButton
@onready var message_dialog: AcceptDialog = $MessageDialog
@onready var battle_host: Node = $BattleHost

var _selected_role_index: int = 0
var _role_ids: Array[String] = []
var _preview_frames: Array = []
var _preview_index: int = 0
var _preview_elapsed: float = 0.0
var _front_wave_width: float = 0.0
var _back_wave_width: float = 0.0
var _current_submenu: String = ""
var _current_battle: BattleScene
var _role_card_panels: Array[Panel] = []
var _role_card_number_labels: Array[Label] = []
var _role_card_name_labels: Array[Label] = []

# Splash state
var _splash_phase: int = -1  # -1=not started, 0=fade_in, 1=hold, 2=fade_out, 3=done
var _splash_timer: float = 0.0
var _splash_logo: TextureRect = null
var _primary_logo_texture: Texture2D = null

# Menu focus
var _menu_focus_index: int = 0
var _active_menu: String = "none"  # "none", "main", "submenu", "role_select"
var _menu_buttons: Array[Button] = []

# Demo battle
var _demo_battle: BattleScene = null

# Menu BGM
var _menu_bgm_player: AudioStreamPlayer = null
var _menu_bgm_index: int = 0
const MENU_BGM_PATHS: Array[String] = [
	"res://assets/audio/bgm/start01.wav",
	"res://assets/audio/bgm/start02.wav",
	"res://assets/audio/bgm/start03.wav",
]


func _ready() -> void:
	_role_ids = GameData.get_role_ids()
	_connect_language_signal()
	tiled_background.texture = _load_optional_texture("res://assets/extracted/main/background-image.png")
	front_wave_a.texture = _load_optional_texture("res://assets/extracted/main/front-wave-img.png")
	front_wave_b.texture = front_wave_a.texture
	back_wave_a.texture = _load_optional_texture("res://assets/extracted/main/back-wave-img.png")
	back_wave_b.texture = back_wave_a.texture
	_front_wave_width = float(front_wave_a.texture.get_width()) if front_wave_a.texture != null else 1.0
	_back_wave_width = float(back_wave_a.texture.get_width()) if back_wave_a.texture != null else 1.0
	front_wave_a.modulate = Color(1.0, 1.0, 1.0, 0.42)
	front_wave_b.modulate = Color(1.0, 1.0, 1.0, 0.42)
	back_wave_a.modulate = Color(1.0, 1.0, 1.0, 0.24)
	back_wave_b.modulate = Color(1.0, 1.0, 1.0, 0.24)
	_reset_waves()
	_primary_logo_texture = _load_primary_logo()
	logo.texture = _primary_logo_texture

	role_select.visible = false
	submenu_panel.visible = false
	_setup_main_menu()
	_setup_role_select()
	_refresh_localized_text()
	_apply_menu_layout()
	_apply_role_select_layout()
	_menu_bgm_player = AudioStreamPlayer.new()
	_menu_bgm_player.bus = "Master"
	_menu_bgm_player.volume_db = -6.0
	add_child(_menu_bgm_player)
	_start_splash()


func _process(delta: float) -> void:
	if _splash_phase >= 0 and _splash_phase < 3:
		_update_splash(delta)
		return
	_animate_waves(delta)
	_advance_role_preview(delta)


func _input(event: InputEvent) -> void:
	if _current_battle == null:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event.keycode != KEY_ESCAPE and key_event.physical_keycode != KEY_ESCAPE and not key_event.is_action_pressed("ui_cancel"):
		return
	if _current_battle.request_exit_confirm():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_update_menu_focus()
	elif what == NOTIFICATION_RESIZED:
		_apply_menu_layout()
		_apply_role_select_layout()


func _unhandled_input(event: InputEvent) -> void:
	if _splash_phase >= 0 and _splash_phase < 3:
		if event is InputEventKey and event.pressed:
			_finish_splash()
		return
	if not (event is InputEventKey and event.pressed):
		return
	var key_event: InputEventKey = event as InputEventKey
	match _active_menu:
		"main":
			_handle_menu_keys(key_event)
		"submenu":
			_handle_menu_keys(key_event)
		"role_select":
			_handle_role_select_keys(key_event)


func _setup_main_menu() -> void:
	for child in main_menu.get_children():
		if child is Button:
			child.pressed.connect(_on_main_menu_pressed.bind(child.name))
			_apply_menu_button_theme(child as Button)
	for child in submenu_buttons.get_children():
		if child is Button:
			child.pressed.connect(_on_submenu_pressed.bind(child.name))
			_apply_menu_button_theme(child as Button)


func _setup_role_select() -> void:
	prev_role_button.pressed.connect(_on_prev_role)
	next_role_button.pressed.connect(_on_next_role)
	select_role_button.pressed.connect(_on_confirm_role)
	back_role_button.pressed.connect(_on_cancel_role)
	for button in [prev_role_button, next_role_button, select_role_button, back_role_button]:
		_apply_menu_button_theme(button)
	for bar in [punch_bar, kick_bar, defense_bar, throw_bar, speed_bar]:
		bar.max_value = 300
	_build_role_roster_cards()
	_update_role_selection()


func _apply_menu_button_theme(button: Button) -> void:
	if button == null:
		return
	button.theme = UI_THEME
	button.focus_mode = Control.FOCUS_NONE
	button.flat = false
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _connect_language_signal() -> void:
	var config: Node = get_node_or_null("/root/GameConfig")
	if config == null or not config.has_signal("language_changed"):
		return
	if not config.language_changed.is_connected(_on_language_changed):
		config.language_changed.connect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	_refresh_localized_text()


func _refresh_localized_text() -> void:
	single_game_button.text = Localization.text("menu.single_game")
	network_battle_button.text = Localization.text("menu.network_battle")
	options_button.text = Localization.text("menu.options")
	help_button.text = Localization.text("menu.help")
	quit_button.text = Localization.text("menu.quit")
	message_dialog.title = Localization.text("menu.notice")
	message_dialog.ok_button_text = Localization.text("dialog.ok")
	role_select_title.text = Localization.text("menu.role_select")
	role_select_subtitle.text = "FIGHTER DOSSIER / 热血阵容"
	hp_label.text = Localization.text("role.stats.hp")
	punch_label.text = Localization.text("role.stats.punch")
	kick_label.text = Localization.text("role.stats.kick")
	defense_label.text = Localization.text("role.stats.defense")
	throw_label.text = Localization.text("role.stats.throw")
	speed_label.text = Localization.text("role.stats.speed")
	skill_title.text = Localization.text("role.skills")
	role_select_roster_label.text = "ROSTER / 阵容"
	prev_role_button.text = _with_button_hint(Localization.text("role.prev"), "A")
	next_role_button.text = _with_button_hint(Localization.text("role.next"), "D")
	select_role_button.text = _with_button_hint(Localization.text("role.select"), "ENTER")
	back_role_button.text = _with_button_hint(Localization.text("menu.back"), "ESC")
	_refresh_submenu_text()
	_refresh_role_roster_cards()
	_apply_menu_layout()
	_apply_role_select_layout()
	if role_select.visible:
		_update_role_selection()


func _with_button_hint(label: String, hint: String) -> String:
	return "%s  [%s]" % [label, hint]


func _refresh_submenu_text() -> void:
	var back_btn: Button = submenu_buttons.get_node_or_null("Back") as Button
	if back_btn != null:
		back_btn.text = Localization.text("menu.back")
	match _current_submenu:
		"single":
			_apply_single_game_submenu()
		"options":
			_apply_options_submenu()
		"help":
			_apply_help_submenu()
		_:
			var mode_2v2_btn: Button = submenu_buttons.get_node_or_null("Mode2v2") as Button
			if mode_2v2_btn != null:
				mode_2v2_btn.text = Localization.text("menu.mode_2v2")
			var scuffle_btn: Button = submenu_buttons.get_node_or_null("Scuffle") as Button
			if scuffle_btn != null:
				scuffle_btn.text = Localization.text("menu.mode_scuffle")


# --- Splash Screen ---

func _start_splash() -> void:
	_set_menu_overlay_visible(false)
	_splash_logo = TextureRect.new()
	_splash_logo.texture = _primary_logo_texture
	_splash_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_splash_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_splash_logo.modulate = Color(1.0, 1.0, 1.0, 0.0)
	add_child(_splash_logo)
	_layout_splash_logo()
	logo.texture = _splash_logo.texture
	_splash_phase = 0
	_splash_timer = 0.0


func _update_splash(delta: float) -> void:
	_splash_timer += delta
	match _splash_phase:
		0:  # Fade in
			var t: float = minf(_splash_timer / SPLASH_FADE_IN, 1.0)
			_splash_logo.modulate.a = t
			if _splash_timer >= SPLASH_FADE_IN:
				_splash_phase = 1
				_splash_timer = 0.0
		1:  # Hold
			if _splash_timer >= SPLASH_HOLD:
				_splash_phase = 2
				_splash_timer = 0.0
		2:  # Fade out
			var t: float = minf(_splash_timer / SPLASH_FADE_OUT, 1.0)
			_splash_logo.modulate.a = 1.0 - t
			if _splash_timer >= SPLASH_FADE_OUT:
				_finish_splash()


func _finish_splash() -> void:
	_splash_phase = 3
	if _splash_logo != null:
		_splash_logo.queue_free()
		_splash_logo = null
	_set_menu_overlay_visible(true)
	_start_demo_battle()
	_activate_menu("main")
	_start_menu_bgm()


# --- Demo Battle ---

func _start_demo_battle() -> void:
	if _demo_battle != null:
		return
	_demo_battle = BATTLE_SCENE.instantiate() as BattleScene
	_demo_battle.z_index = -10
	_demo_battle.modulate = Color(0.5, 0.5, 0.5, 0.4)
	battle_host.add_child(_demo_battle)
	$BattleHost.visible = true
	var demo_hud: CanvasLayer = _demo_battle.get_node_or_null("HUD") as CanvasLayer
	if demo_hud != null:
		demo_hud.visible = false
	var demo_overlay: CanvasItem = _demo_battle.get_node_or_null("HUD/Overlay") as CanvasItem
	if demo_overlay != null:
		demo_overlay.visible = false
	var demo_panel: CanvasItem = _demo_battle.get_node_or_null("HUD/Panel") as CanvasItem
	if demo_panel != null:
		demo_panel.visible = false
	# Run a muted looping CPU-vs-CPU battle behind the menu.
	var config: Node = get_node_or_null("/root/GameConfig")
	var ai_difficulty: String = "normal"
	if config != null:
		ai_difficulty = String(config.get("ai_difficulty"))
	_demo_battle.start_session({
		"player_role_id": "beach",
		"player_mode": "cpu",
		"cpu_role_ids": ["spence"],
		"mute_audio": true,
		"loop_demo": true,
		"menu_demo_camera": true,
		"ai_difficulty": ai_difficulty,
	})
	if demo_hud != null:
		demo_hud.visible = false
	if demo_overlay != null:
		demo_overlay.visible = false
	if demo_panel != null:
		demo_panel.visible = false


func _pause_demo_battle() -> void:
	if _demo_battle != null:
		_demo_battle.process_mode = Node.PROCESS_MODE_DISABLED
		_demo_battle.visible = false


func _resume_demo_battle() -> void:
	if _demo_battle != null:
		_demo_battle.process_mode = Node.PROCESS_MODE_INHERIT
		_demo_battle.visible = true
		var demo_hud: CanvasLayer = _demo_battle.get_node_or_null("HUD") as CanvasLayer
		if demo_hud != null:
			demo_hud.visible = false


func _start_menu_bgm() -> void:
	if _menu_bgm_player == null or MENU_BGM_PATHS.is_empty():
		return
	if not _menu_bgm_player.finished.is_connected(_on_menu_bgm_finished):
		_menu_bgm_player.finished.connect(_on_menu_bgm_finished)
	_play_menu_bgm_track()


func _play_menu_bgm_track() -> void:
	var path: String = MENU_BGM_PATHS[_menu_bgm_index % MENU_BGM_PATHS.size()]
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	_menu_bgm_player.stream = stream
	_menu_bgm_player.play()


func _on_menu_bgm_finished() -> void:
	_menu_bgm_index = (_menu_bgm_index + 1) % MENU_BGM_PATHS.size()
	_play_menu_bgm_track()


func _stop_menu_bgm() -> void:
	if _menu_bgm_player != null:
		_menu_bgm_player.stop()


# --- Menu Keyboard Navigation ---

func _activate_menu(menu_name: String) -> void:
	_active_menu = menu_name
	_menu_buttons.clear()
	_menu_focus_index = 0
	match menu_name:
		"main":
			for child in main_menu.get_children():
				if child is Button and child.visible:
					_menu_buttons.append(child as Button)
		"submenu":
			for child in submenu_buttons.get_children():
				if child is Button and child.visible:
					_menu_buttons.append(child as Button)
	_update_menu_focus()


func _update_menu_focus() -> void:
	var focus_style: StyleBox = UI_THEME.get_stylebox("focus", "Button")
	for i in range(_menu_buttons.size()):
		var btn: Button = _menu_buttons[i]
		if i == _menu_focus_index:
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


func _apply_menu_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var aspect: float = viewport_size.x / maxf(viewport_size.y, 1.0)
	var compact: bool = aspect < POSTER_COMPACT_ASPECT
	var scale: float = clampf(
		minf(viewport_size.x / MENU_REFERENCE_SIZE.x, viewport_size.y / MENU_REFERENCE_SIZE.y),
		0.85,
		1.5
	)
	var gutter: float = roundf((24.0 if compact else 44.0) * scale)
	var gap: float = roundf((18.0 if compact else 42.0) * scale)
	var top_margin: float = roundf((22.0 if compact else 28.0) * scale)
	var bottom_margin: float = roundf(34.0 * scale)

	var left_column_x: float = gutter if compact else roundf(clampf(viewport_size.x * 0.08, gutter, 120.0 * scale))
	var logo_size: Vector2 = Vector2(
		clampf(viewport_size.x * (0.4 if compact else 0.36), 300.0 * scale, 470.0 * scale),
		clampf(viewport_size.y * (0.23 if compact else 0.22), 148.0 * scale, 210.0 * scale)
	)
	_place_control(logo_stack, Vector2(left_column_x, top_margin), logo_size)
	_place_control(
		logo_slash_top,
		Vector2(logo_size.x * 0.03, logo_size.y * 0.05),
		Vector2(logo_size.x * 0.82, maxf(10.0 * scale, logo_size.y * 0.07))
	)
	_place_control(
		logo,
		Vector2(0.0, logo_size.y * 0.12),
		Vector2(logo_size.x, logo_size.y * 0.78)
	)
	_place_control(
		logo_underline,
		Vector2(logo_size.x * 0.06, logo_size.y * 0.86),
		Vector2(logo_size.x * 0.68, maxf(8.0 * scale, logo_size.y * 0.05))
	)

	var ticket_position: Vector2 = Vector2(
		left_column_x,
		logo_stack.position.y + logo_stack.size.y - (2.0 * scale)
	)
	var ticket_size: Vector2 = Vector2(
		clampf(viewport_size.x * (0.38 if compact else 0.34), 292.0 * scale, 408.0 * scale),
		clampf(
			viewport_size.y - ticket_position.y - bottom_margin - (14.0 * scale),
			348.0 * scale,
			440.0 * scale
		)
	)
	_place_control(menu_ticket, ticket_position, ticket_size)
	_place_control(
		ticket_accent_top,
		Vector2(18.0 * scale, 18.0 * scale),
		Vector2(ticket_size.x * 0.58, maxf(8.0 * scale, 8.0))
	)
	_place_control(
		ticket_accent_glow,
		Vector2(18.0 * scale, 30.0 * scale),
		Vector2(ticket_size.x * 0.72, maxf(4.0 * scale, 4.0))
	)

	var menu_margin: float = clampf(ticket_size.x * 0.07, 20.0 * scale, 30.0 * scale)
	var menu_top: float = clampf(ticket_size.y * 0.15, 68.0 * scale, 92.0 * scale)
	_place_control(
		main_menu,
		Vector2(menu_margin, menu_top),
		Vector2(ticket_size.x - (menu_margin * 2.0), ticket_size.y - menu_top - (22.0 * scale))
	)
	main_menu.add_theme_constant_override("separation", int(roundf(clampf(13.0 * scale, 11.0, 17.0))))

	if hero_poster != null:
		hero_poster.visible = false
	_place_control(hero_poster, Vector2.ZERO, Vector2.ZERO)

	var submenu_size: Vector2 = Vector2(
		clampf(ticket_size.x * (0.94 if compact else 0.9), 246.0 * scale, 312.0 * scale),
		clampf(ticket_size.y - (28.0 * scale), 246.0 * scale, 324.0 * scale)
	)
	var submenu_x: float = menu_ticket.position.x + menu_ticket.size.x + gap
	if not compact:
		submenu_x = maxf(submenu_x, viewport_size.x * 0.6 - (submenu_size.x * 0.5))
	submenu_x = minf(submenu_x, viewport_size.x - submenu_size.x - gutter)
	_place_control(
		submenu_panel,
		Vector2(submenu_x, menu_ticket.position.y + (10.0 * scale)),
		submenu_size
	)
	_place_control(
		submenu_title,
		Vector2(18.0 * scale, 16.0 * scale),
		Vector2(submenu_size.x - (36.0 * scale), 40.0 * scale)
	)
	submenu_title.add_theme_font_size_override("font_size", int(roundf(clampf(24.0 * scale, 22.0, 30.0))))
	_place_control(
		submenu_buttons,
		Vector2(18.0 * scale, 58.0 * scale),
		Vector2(submenu_size.x - (36.0 * scale), submenu_size.y - (82.0 * scale))
	)
	submenu_buttons.add_theme_constant_override("separation", int(roundf(clampf(10.0 * scale, 10.0, 14.0))))

	_update_menu_button_sizes(scale)
	_layout_splash_logo()


func _place_control(node: Control, position: Vector2, size: Vector2) -> void:
	if node == null:
		return
	node.position = position
	node.size = size


func _update_menu_button_sizes(scale: float) -> void:
	var main_button_size: Vector2 = Vector2(
		maxf(main_menu.size.x, 212.0 * scale),
		roundf(clampf(46.0 * scale, 42.0, 54.0))
	)
	for child in main_menu.get_children():
		if child is Button:
			(child as Button).custom_minimum_size = main_button_size

	var submenu_button_size: Vector2 = Vector2(
		maxf(submenu_buttons.size.x, 188.0 * scale),
		roundf(clampf(40.0 * scale, 38.0, 48.0))
	)
	for child in submenu_buttons.get_children():
		if child is Button:
			(child as Button).custom_minimum_size = submenu_button_size


func _layout_splash_logo() -> void:
	if _splash_logo == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var aspect: float = viewport_size.x / maxf(viewport_size.y, 1.0)
	var compact: bool = aspect < POSTER_COMPACT_ASPECT
	var texture_size: Vector2 = Vector2(900.0, 360.0)
	if _splash_logo.texture != null:
		texture_size = _splash_logo.texture.get_size()
	var logo_bounds: Vector2 = Vector2(
		clampf(viewport_size.x * (0.74 if compact else 0.62), 420.0, 820.0),
		clampf(viewport_size.y * 0.38, 160.0, 280.0)
	)
	var texture_ratio: float = texture_size.x / maxf(texture_size.y, 1.0)
	var logo_size: Vector2 = logo_bounds
	if logo_bounds.x / maxf(logo_bounds.y, 1.0) > texture_ratio:
		logo_size.x = logo_bounds.y * texture_ratio
	else:
		logo_size.y = logo_bounds.x / texture_ratio
	_place_control(
		_splash_logo,
		(viewport_size - logo_size) * 0.5,
		logo_size
	)


func _load_primary_logo() -> Texture2D:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(PRIMARY_LOGO_PATH))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)


func _load_optional_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return null
	return load(path) as Texture2D


func _get_layout_scale() -> float:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return 1.0
	return clampf(
		minf(viewport_size.x / MENU_REFERENCE_SIZE.x, viewport_size.y / MENU_REFERENCE_SIZE.y),
		0.85,
		1.5
	)


func _apply_role_select_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var aspect: float = viewport_size.x / maxf(viewport_size.y, 1.0)
	var compact: bool = aspect < POSTER_COMPACT_ASPECT
	var scale: float = _get_layout_scale()
	var panel_size: Vector2 = Vector2(
		clampf(viewport_size.x * (0.92 if compact else 0.84), 720.0 * scale, 1120.0),
		clampf(viewport_size.y * 0.88, 540.0 * scale, 760.0)
	)
	_place_control(role_select, (viewport_size - panel_size) * 0.5, panel_size)
	_place_control(
		role_select_title,
		Vector2(28.0 * scale, 18.0 * scale),
		Vector2(panel_size.x * 0.44, 34.0 * scale)
	)
	role_select_title.add_theme_font_size_override("font_size", int(roundf(clampf(28.0 * scale, 24.0, 34.0))))
	_place_control(
		role_select_subtitle,
		Vector2(30.0 * scale, 54.0 * scale),
		Vector2(panel_size.x * 0.38, 18.0 * scale)
	)
	role_select_subtitle.add_theme_font_size_override("font_size", int(roundf(clampf(12.0 * scale, 11.0, 14.0))))

	var padding: float = 22.0 * scale
	var section_top: float = 92.0 * scale
	var section_gap: float = 18.0 * scale
	var roster_height: float = clampf(panel_size.y * 0.18, 102.0 * scale, 136.0 * scale)
	var board_height: float = maxf(panel_size.y - section_top - roster_height - padding - section_gap, 320.0 * scale)

	_place_control(
		role_select_info_board,
		Vector2(padding, section_top),
		Vector2(panel_size.x - (padding * 2.0), board_height)
	)
	_place_control(
		role_select_roster_strip,
		Vector2(padding, section_top + board_height + section_gap),
		Vector2(panel_size.x - (padding * 2.0), roster_height)
	)
	var board_padding: float = 20.0 * scale
	var board_content_size: Vector2 = role_select_info_board.size - Vector2(board_padding * 2.0, board_padding * 2.0)
	var left_column_width: float = clampf(board_content_size.x * 0.22, 170.0 * scale, 240.0 * scale)
	var column_gap: float = 20.0 * scale
	var right_column_x: float = left_column_width + column_gap
	var right_column_width: float = maxf(board_content_size.x - right_column_x, 250.0 * scale)
	_place_control(
		role_select_info,
		Vector2(board_padding, board_padding),
		board_content_size
	)
	var preview_box_size: Vector2 = Vector2(
		left_column_width,
		clampf(role_select_info.size.y - (48.0 * scale), 190.0 * scale, 278.0 * scale)
	)
	_place_control(
		role_name,
		Vector2.ZERO,
		Vector2(left_column_width, 34.0 * scale)
	)
	role_name.add_theme_font_size_override("font_size", int(roundf(clampf(24.0 * scale, 21.0, 30.0))))
	_place_control(role_preview_box, Vector2(0.0, 46.0 * scale), preview_box_size)
	_place_control(
		role_preview,
		Vector2(10.0 * scale, 10.0 * scale),
		preview_box_size - Vector2(20.0 * scale, 20.0 * scale)
	)
	var stat_label_width: float = clampf(110.0 * scale, 96.0, 128.0)
	var stats_height: float = clampf(role_select_info.size.y * 0.4, 164.0 * scale, 220.0 * scale)
	_place_control(
		role_stats_grid,
		Vector2(right_column_x, 2.0 * scale),
		Vector2(right_column_width, stats_height)
	)
	role_stats_grid.add_theme_constant_override("h_separation", int(roundf(clampf(14.0 * scale, 12.0, 18.0))))
	role_stats_grid.add_theme_constant_override("v_separation", int(roundf(clampf(11.0 * scale, 10.0, 14.0))))
	for label in [hp_label, punch_label, kick_label, defense_label, throw_label, speed_label]:
		label.add_theme_font_size_override("font_size", int(roundf(clampf(17.0 * scale, 14.0, 20.0))))
	hp_value.add_theme_font_size_override("font_size", int(roundf(clampf(20.0 * scale, 17.0, 24.0))))
	var stat_bar_width: float = maxf(
		role_stats_grid.size.x - stat_label_width - float(role_stats_grid.get_theme_constant("h_separation")),
		160.0 * scale
	)
	for bar in [punch_bar, kick_bar, defense_bar, throw_bar, speed_bar]:
		bar.custom_minimum_size = Vector2(stat_bar_width, roundf(clampf(20.0 * scale, 17.0, 24.0)))

	var skill_panel_top: float = role_stats_grid.position.y + role_stats_grid.size.y + (16.0 * scale)
	var skill_panel_height: float = maxf(role_select_info.size.y - skill_panel_top, 132.0 * scale)
	_place_control(
		skill_panel,
		Vector2(board_padding + right_column_x, board_padding + skill_panel_top),
		Vector2(right_column_width, skill_panel_height)
	)
	_place_control(
		skill_title,
		Vector2(14.0 * scale, 12.0 * scale),
		Vector2(skill_panel.size.x - (28.0 * scale), 26.0 * scale)
	)
	skill_title.add_theme_font_size_override("font_size", int(roundf(clampf(22.0 * scale, 18.0, 24.0))))
	_place_control(
		skill_list,
		Vector2(14.0 * scale, 40.0 * scale),
		Vector2(skill_panel.size.x - (28.0 * scale), skill_panel.size.y - (54.0 * scale))
	)
	skill_list.scroll_active = true

	_place_control(
		role_select_roster_label,
		Vector2(18.0 * scale, 12.0 * scale),
		Vector2(150.0 * scale, 18.0 * scale)
	)
	role_select_roster_label.add_theme_font_size_override("font_size", int(roundf(clampf(12.0 * scale, 11.0, 14.0))))
	var roster_content_top: float = 34.0 * scale
	var roster_side_padding: float = 18.0 * scale
	var roster_section_gap: float = 12.0 * scale
	var action_buttons: Array[Button] = [prev_role_button, next_role_button, select_role_button, back_role_button]
	var button_count: int = max(action_buttons.size(), 1)
	var button_gap: float = clampf(8.0 * scale, 6.0, 10.0)
	var card_spacing: float = clampf(8.0 * scale, 6.0, 10.0)
	var roster_inner_width: float = role_select_roster_strip.size.x - (roster_side_padding * 2.0)
	var button_height: float = roundf(clampf(42.0 * scale, 40.0, 52.0))
	var button_font_size: int = int(roundf(clampf(16.0 * scale, 13.0, 18.0)))
	var widest_button_width: float = 48.0 * scale
	for button in action_buttons:
		button.add_theme_font_size_override("font_size", button_font_size)
		button.custom_minimum_size = Vector2(0.0, button_height)
		widest_button_width = maxf(widest_button_width, button.get_combined_minimum_size().x)
	var minimum_cards_width: float = (
		float(max(_role_ids.size(), 1)) * (44.0 * scale)
		+ float(max(_role_ids.size() - 1, 0)) * card_spacing
	)
	var buttons_width: float = maxf(
		float(button_count) * widest_button_width + float(max(button_count - 1, 0)) * button_gap,
		roster_inner_width * 0.34
	)
	var max_buttons_width: float = maxf(roster_inner_width - minimum_cards_width - roster_section_gap, buttons_width)
	buttons_width = minf(buttons_width, max_buttons_width)
	var cards_width: float = maxf(roster_inner_width - buttons_width - roster_section_gap, minimum_cards_width)
	var button_width: float = widest_button_width
	_place_control(
		role_select_buttons,
		Vector2(
			role_select_roster_strip.size.x - buttons_width - roster_side_padding,
			roster_content_top - (2.0 * scale)
		),
		Vector2(buttons_width, role_select_roster_strip.size.y - roster_content_top - (14.0 * scale))
	)
	role_select_buttons.add_theme_constant_override("separation", int(roundf(button_gap)))
	for button in action_buttons:
		button.custom_minimum_size = Vector2(button_width, button_height)
	_place_control(
		role_select_roster_cards,
		Vector2(roster_side_padding, roster_content_top),
		Vector2(cards_width, role_select_roster_strip.size.y - roster_content_top - (14.0 * scale))
	)
	role_select_roster_cards.add_theme_constant_override("separation", int(roundf(card_spacing)))

	_refresh_role_roster_cards()


func _build_role_roster_cards() -> void:
	for child in role_select_roster_cards.get_children():
		child.queue_free()
	_role_card_panels.clear()
	_role_card_number_labels.clear()
	_role_card_name_labels.clear()

	for i in range(_role_ids.size()):
		var card: Panel = Panel.new()
		card.theme = UI_THEME
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var content: VBoxContainer = VBoxContainer.new()
		content.anchor_right = 1.0
		content.anchor_bottom = 1.0
		content.offset_left = 8.0
		content.offset_top = 8.0
		content.offset_right = -8.0
		content.offset_bottom = -8.0
		content.add_theme_constant_override("separation", 1)

		var number_label: Label = Label.new()
		number_label.text = "%02d" % (i + 1)
		number_label.add_theme_font_size_override("font_size", 11)

		var name_label: Label = Label.new()
		name_label.text = _role_ids[i]
		name_label.clip_text = true
		name_label.add_theme_font_size_override("font_size", 14)

		content.add_child(number_label)
		content.add_child(name_label)
		card.add_child(content)
		role_select_roster_cards.add_child(card)

		_role_card_panels.append(card)
		_role_card_number_labels.append(number_label)
		_role_card_name_labels.append(name_label)


func _refresh_role_roster_cards() -> void:
	if _role_card_panels.is_empty():
		return

	var scale: float = _get_layout_scale()
	var card_count: int = max(_role_card_panels.size(), 1)
	var card_spacing: float = clampf(8.0 * scale, 6.0, 10.0)
	var available_width: float = maxf(
		role_select_roster_cards.size.x - (float(card_count - 1) * card_spacing),
		220.0 * scale
	)
	var base_width: float = clampf(available_width / float(card_count), 44.0 * scale, 148.0 * scale)
	var base_height: float = clampf(role_select_roster_cards.size.y, 46.0 * scale, 74.0 * scale)

	for i in range(_role_card_panels.size()):
		var role_data: Dictionary = GameData.load_role(_role_ids[i])
		var is_selected: bool = i == _selected_role_index
		var card: Panel = _role_card_panels[i]
		card.add_theme_stylebox_override("panel", _make_role_card_style(is_selected))
		card.custom_minimum_size = Vector2(base_width, base_height)

		var number_label: Label = _role_card_number_labels[i]
		number_label.add_theme_font_size_override("font_size", int(roundf(clampf(11.0 * scale, 10.0, 13.0))))
		number_label.add_theme_color_override(
			"font_color",
			MENU_BUTTON_FOCUS_FONT_COLOR if is_selected else Color(1.0, 0.823529, 0.552941, 0.76)
		)

		var name_label: Label = _role_card_name_labels[i]
		name_label.text = GameData.get_role_display_name(role_data)
		name_label.add_theme_font_size_override("font_size", int(roundf(clampf(14.0 * scale, 12.0, 18.0))))
		name_label.add_theme_color_override(
			"font_color",
			MENU_BUTTON_FOCUS_FONT_COLOR if is_selected else MENU_BUTTON_BASE_FONT_COLOR
		)


func _make_role_card_style(is_selected: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.content_margin_left = 12.0
	style.content_margin_top = 10.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 10.0
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	if is_selected:
		style.bg_color = Color(0.996078, 0.772549, 0.411765, 1.0)
		style.border_color = Color(1.0, 0.545098, 0.301961, 1.0)
		style.shadow_color = Color(0.141176, 0.0352941, 0.027451, 0.35)
		style.shadow_size = 10
		style.shadow_offset = Vector2(0, 4)
	else:
		style.bg_color = Color(0.188235, 0.0823529, 0.0705882, 0.92)
		style.border_color = Color(1.0, 0.545098, 0.301961, 0.78)
	return style


func _handle_menu_keys(event: InputEventKey) -> void:
	if _menu_buttons.is_empty():
		return
	match event.keycode:
		KEY_W, KEY_UP:
			_menu_focus_index = wrapi(_menu_focus_index - 1, 0, _menu_buttons.size())
			_update_menu_focus()
			get_viewport().set_input_as_handled()
		KEY_S, KEY_DOWN:
			_menu_focus_index = wrapi(_menu_focus_index + 1, 0, _menu_buttons.size())
			_update_menu_focus()
			get_viewport().set_input_as_handled()
		KEY_J, KEY_D, KEY_ENTER, KEY_KP_ENTER:
			if _menu_focus_index < _menu_buttons.size():
				_menu_buttons[_menu_focus_index].emit_signal("pressed")
			get_viewport().set_input_as_handled()
		KEY_K, KEY_A, KEY_ESCAPE:
			if _active_menu == "submenu":
				submenu_panel.visible = false
				_current_submenu = ""
				_activate_menu("main")
			get_viewport().set_input_as_handled()


func _handle_role_select_keys(event: InputEventKey) -> void:
	match event.keycode:
		KEY_A, KEY_LEFT:
			_on_prev_role()
			get_viewport().set_input_as_handled()
		KEY_D, KEY_RIGHT:
			_on_next_role()
			get_viewport().set_input_as_handled()
		KEY_J, KEY_ENTER, KEY_KP_ENTER:
			_on_confirm_role()
			get_viewport().set_input_as_handled()
		KEY_K, KEY_ESCAPE:
			_on_cancel_role()
			get_viewport().set_input_as_handled()


# --- Menu Actions ---

func _on_main_menu_pressed(action: String) -> void:
	match action:
		"SingleGame":
			_show_single_game_submenu()
		"NetworkBattle":
			_show_message(Localization.text("menu.network_unavailable"))
		"Options":
			_show_options_submenu()
		"Help":
			_show_help_submenu()
		"Quit":
			_show_quit_confirm()


func _on_submenu_pressed(action: String) -> void:
	match action:
		"Mode2v2":
			_show_role_select_2v2()
		"Scuffle":
			_show_role_select()
		"UnusedA":
			_show_role_select_story()
		"TrainingDummy":
			_show_role_select(true)
		"KeyboardSettings":
			_open_keyboard_settings()
		"WindowToggle":
			var config: Node = get_node_or_null("/root/GameConfig")
			if config != null and config.has_method("toggle_window_mode"):
				config.call("toggle_window_mode")
			else:
				var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
				DisplayServer.window_set_mode(
					DisplayServer.WINDOW_MODE_WINDOWED
					if is_fullscreen
					else DisplayServer.WINDOW_MODE_FULLSCREEN
				)
		"LanguageToggle":
			var config: Node = get_node_or_null("/root/GameConfig")
			if config != null and config.has_method("toggle_language"):
				config.call("toggle_language")
			else:
				Localization.set_locale(Localization.get_next_locale(TranslationServer.get_locale()))
				_refresh_localized_text()
		"AiDifficultyToggle":
			var config: Node = get_node_or_null("/root/GameConfig")
			if config != null and config.has_method("cycle_ai_difficulty"):
				config.call("cycle_ai_difficulty")
			_refresh_localized_text()
		"HowToPlay":
			_show_info_window(Localization.text("help.title"), Localization.text("help.body"))
		"Back":
			submenu_panel.visible = false
			_current_submenu = ""
			_activate_menu("main")


func _show_single_game_submenu() -> void:
	_current_submenu = "single"
	_apply_single_game_submenu()
	submenu_panel.visible = true
	_activate_menu("submenu")


func _show_options_submenu() -> void:
	_current_submenu = "options"
	_apply_options_submenu()
	submenu_panel.visible = true
	_activate_menu("submenu")


func _show_help_submenu() -> void:
	_current_submenu = "help"
	_apply_help_submenu()
	submenu_panel.visible = true
	_activate_menu("submenu")


func _apply_single_game_submenu() -> void:
	submenu_title.text = Localization.text("menu.single_game")
	_set_submenu_buttons(true, true, true, false)
	var training_btn: Button = _find_or_create_submenu_button("TrainingDummy", Localization.text("menu.training_dummy"))
	training_btn.visible = true
	var mode_2v2_btn: Button = submenu_buttons.get_node_or_null("Mode2v2") as Button
	if mode_2v2_btn != null:
		mode_2v2_btn.text = Localization.text("menu.mode_2v2")
	var scuffle_btn: Button = submenu_buttons.get_node_or_null("Scuffle") as Button
	if scuffle_btn != null:
		scuffle_btn.text = Localization.text("menu.mode_scuffle")
	var back_btn: Button = submenu_buttons.get_node_or_null("Back") as Button
	if back_btn != null:
		back_btn.text = Localization.text("menu.back")
		_move_button_before(training_btn, back_btn)


func _apply_options_submenu() -> void:
	submenu_title.text = Localization.text("menu.options")
	for child in submenu_buttons.get_children():
		if child is Button:
			child.visible = false
	var btn_keyboard: Button = _find_or_create_submenu_button("KeyboardSettings", Localization.text("menu.keyboard_settings"))
	btn_keyboard.visible = true
	var btn_window: Button = _find_or_create_submenu_button("WindowToggle", Localization.text("menu.window_toggle"))
	btn_window.visible = true
	var btn_language: Button = _find_or_create_submenu_button("LanguageToggle", _get_language_toggle_text())
	btn_language.visible = true
	var btn_ai: Button = _find_or_create_submenu_button("AiDifficultyToggle", _get_ai_difficulty_toggle_text())
	btn_ai.visible = true
	var back_btn: Button = submenu_buttons.get_node_or_null("Back") as Button
	if back_btn != null:
		back_btn.visible = true
		back_btn.text = Localization.text("menu.back")


func _apply_help_submenu() -> void:
	submenu_title.text = Localization.text("menu.help")
	for child in submenu_buttons.get_children():
		if child is Button:
			child.visible = false
	var btn_usage: Button = _find_or_create_submenu_button("HowToPlay", Localization.text("menu.how_to_play"))
	btn_usage.visible = true
	var back_btn: Button = submenu_buttons.get_node_or_null("Back") as Button
	if back_btn != null:
		back_btn.visible = true
		back_btn.text = Localization.text("menu.back")


func _find_or_create_submenu_button(btn_name: String, btn_text: String) -> Button:
	var existing: Node = submenu_buttons.get_node_or_null(btn_name)
	if existing != null and existing is Button:
		(existing as Button).text = btn_text
		_apply_menu_button_theme(existing as Button)
		return existing as Button
	var btn: Button = Button.new()
	btn.name = btn_name
	btn.text = btn_text
	_apply_menu_button_theme(btn)
	btn.custom_minimum_size = Vector2(220.0, 42.0)
	btn.pressed.connect(_on_submenu_pressed.bind(btn_name))
	# Insert before Back button
	var back_btn: Node = submenu_buttons.get_node_or_null("Back")
	if back_btn != null:
		submenu_buttons.add_child(btn)
		submenu_buttons.move_child(btn, back_btn.get_index())
	else:
		submenu_buttons.add_child(btn)
	_update_menu_button_sizes(
		clampf(
			minf(get_viewport_rect().size.x / MENU_REFERENCE_SIZE.x, get_viewport_rect().size.y / MENU_REFERENCE_SIZE.y),
			0.85,
			1.5
		)
	)
	return btn


func _move_button_before(button: Button, anchor_button: Button) -> void:
	if button == null or anchor_button == null or button == anchor_button:
		return
	var anchor_index: int = anchor_button.get_index()
	var target_index: int = anchor_index
	if button.get_index() < anchor_index:
		target_index -= 1
	if button.get_index() == target_index:
		return
	submenu_buttons.move_child(button, max(target_index, 0))


func _get_language_toggle_text() -> String:
	var config: Node = get_node_or_null("/root/GameConfig")
	var current_locale: String = TranslationServer.get_locale()
	if config != null:
		current_locale = String(config.get("language"))
	return Localization.text(
		"menu.language_toggle",
		[Localization.get_locale_display_name(current_locale)]
	)


func _get_ai_difficulty_toggle_text() -> String:
	var config: Node = get_node_or_null("/root/GameConfig")
	var current_difficulty: String = "normal"
	if config != null:
		current_difficulty = String(config.get("ai_difficulty"))
	return Localization.text(
		"menu.ai_difficulty_toggle",
		[Localization.text("ai.difficulty.%s" % current_difficulty)]
	)


func _apply_dialog_theme(dialog: Window) -> void:
	if dialog == null:
		return
	dialog.theme = UI_THEME


func _focus_accept_dialog(dialog: AcceptDialog) -> void:
	if dialog == null:
		return
	_apply_dialog_theme(dialog)
	var ok_button: Button = dialog.get_ok_button()
	if ok_button == null:
		return
	ok_button.focus_mode = Control.FOCUS_ALL
	ok_button.call_deferred("grab_focus")


func _show_quit_confirm() -> void:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	_apply_dialog_theme(dialog)
	dialog.dialog_text = Localization.text("menu.quit_confirm")
	dialog.ok_button_text = Localization.text("menu.quit_yes")
	dialog.cancel_button_text = Localization.text("menu.quit_no")
	dialog.min_size = Vector2i(460, 180)
	dialog.confirmed.connect(func(): get_tree().quit())
	dialog.canceled.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(460, 180))
	_focus_accept_dialog(dialog)


func _show_info_window(title_text: String, body_text: String) -> void:
	var dialog: AcceptDialog = AcceptDialog.new()
	_apply_dialog_theme(dialog)
	dialog.title = title_text
	dialog.dialog_text = body_text
	dialog.ok_button_text = Localization.text("dialog.ok")
	dialog.min_size = Vector2i(660, 500)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(660, 500))
	_focus_accept_dialog(dialog)


func _open_keyboard_settings() -> void:
	var kb_script: GDScript = load("res://scripts/ui/keyboard_settings.gd") as GDScript
	var win: Window = Window.new()
	win.theme = UI_THEME
	win.set_script(kb_script)
	add_child(win)
	win.popup_centered(Vector2i(520, 420))


func _set_submenu_buttons(show_2v2: bool, show_scuffle: bool, show_placeholder_a: bool, show_placeholder_b: bool) -> void:
	# Hide all dynamic buttons first
	for child in submenu_buttons.get_children():
		if child is Button and child.name not in ["Mode2v2", "Scuffle", "UnusedA", "UnusedB", "Back"]:
			child.visible = false
	var node_2v2: Node = submenu_buttons.get_node_or_null("Mode2v2")
	if node_2v2 != null:
		node_2v2.visible = show_2v2
	var node_scuffle: Node = submenu_buttons.get_node_or_null("Scuffle")
	if node_scuffle != null:
		node_scuffle.visible = show_scuffle
	var node_a: Node = submenu_buttons.get_node_or_null("UnusedA")
	if node_a != null:
		node_a.visible = show_placeholder_a
		if node_a is Button:
			(node_a as Button).text = Localization.text("menu.mode_story")
	var node_b: Node = submenu_buttons.get_node_or_null("UnusedB")
	if node_b != null:
		node_b.visible = show_placeholder_b
	$MenuLayer/SubmenuPanel/Buttons/Back.visible = true


var _pending_training_dummy: bool = false
var _pending_2v2: bool = false
var _pending_story: bool = false

func _show_role_select(training_dummy: bool = false) -> void:
	_pending_training_dummy = training_dummy
	_pending_2v2 = false
	_pending_story = false
	role_select.visible = true
	submenu_panel.visible = false
	_selected_role_index = 0
	_active_menu = "role_select"
	_apply_role_select_layout()
	_update_role_selection()


func _show_role_select_story() -> void:
	_pending_training_dummy = false
	_pending_2v2 = false
	_pending_story = true
	role_select.visible = true
	submenu_panel.visible = false
	_selected_role_index = 0
	_active_menu = "role_select"
	_apply_role_select_layout()
	_update_role_selection()


func _show_role_select_2v2() -> void:
	_pending_training_dummy = false
	_pending_2v2 = true
	_pending_story = false
	role_select.visible = true
	submenu_panel.visible = false
	_selected_role_index = 0
	_active_menu = "role_select"
	_apply_role_select_layout()
	_update_role_selection()


func _on_prev_role() -> void:
	if _role_ids.is_empty():
		return
	_selected_role_index = wrapi(_selected_role_index - 1, 0, _role_ids.size())
	_update_role_selection()


func _on_next_role() -> void:
	if _role_ids.is_empty():
		return
	_selected_role_index = wrapi(_selected_role_index + 1, 0, _role_ids.size())
	_update_role_selection()


func _on_confirm_role() -> void:
	role_select.visible = false
	_active_menu = "none"
	var role_id: String = _role_ids[_selected_role_index]
	if _pending_story:
		_pending_story = false
		_start_battle_story(role_id)
	elif _pending_2v2:
		_pending_2v2 = false
		_start_battle_2v2(role_id)
	else:
		_start_battle(role_id, _pending_training_dummy)
		_pending_training_dummy = false


func _on_cancel_role() -> void:
	role_select.visible = false
	_pending_training_dummy = false
	_pending_2v2 = false
	submenu_panel.visible = true
	_activate_menu("submenu")


func _update_role_selection() -> void:
	if _role_ids.is_empty():
		return
	var role_id: String = _role_ids[_selected_role_index]
	var role_data: Dictionary = GameData.load_role(role_id)
	role_name.text = GameData.get_role_display_name(role_data)
	var stats: Dictionary = role_data.get("stats", {})
	hp_value.text = str(stats.get("max_hp", 0))
	punch_bar.value = float(stats.get("punch", 0))
	kick_bar.value = float(stats.get("kick", 0))
	defense_bar.value = float(stats.get("defense", 0))
	throw_bar.value = float(stats.get("throw", 0))
	speed_bar.value = float(stats.get("speed", 0))
	var skill_lines: Array[String] = []
	for skill_id in role_data.get("skills", []):
		skill_lines.append(GameData.get_skill_label(String(skill_id)))
	skill_list.text = _format_skill_list(skill_lines)
	skill_list.scroll_to_line(0)
	_refresh_role_roster_cards()
	_preview_frames = role_data.get("actions", {}).get("start", {}).get("frames", [])
	_preview_index = 0
	_preview_elapsed = 0.0
	_apply_preview_frame()


func _apply_preview_frame() -> void:
	if _preview_frames.is_empty():
		role_preview.texture = null
		return
	var frame: Dictionary = _preview_frames[_preview_index]
	var texture: Texture2D = load("res://%s" % frame.get("texture", "")) as Texture2D
	role_preview.texture = texture


func _format_skill_list(skill_lines: Array[String]) -> String:
	if skill_lines.is_empty():
		return "-"
	var rows: Array[String] = []
	var current_row: Array[String] = []
	for skill_name in skill_lines:
		current_row.append("• %s" % skill_name)
		if current_row.size() == 2:
			rows.append("    ".join(current_row))
			current_row.clear()
	if not current_row.is_empty():
		rows.append("    ".join(current_row))
	return "\n".join(rows)


func _advance_role_preview(delta: float) -> void:
	if not role_select.visible or _preview_frames.is_empty():
		return
	_preview_elapsed += delta
	var duration: float = float(_preview_frames[_preview_index].get("duration_sec", 0.1))
	if _preview_elapsed < duration:
		return
	_preview_elapsed = 0.0
	_preview_index = (_preview_index + 1) % _preview_frames.size()
	_apply_preview_frame()


func _start_battle(player_role_id: String, training_dummy: bool = false) -> void:
	_pause_demo_battle()
	_stop_menu_bgm()
	main_menu.visible = false
	submenu_panel.visible = false

	logo.visible = false
	var cpu_roles: Array[String] = []
	if training_dummy:
		cpu_roles = [player_role_id]
	else:
		cpu_roles = _pick_unique_cpu_roles(player_role_id, 3)
	_current_battle = BATTLE_SCENE.instantiate() as BattleScene
	battle_host.add_child(_current_battle)
	_current_battle.exit_requested.connect(_on_battle_exit_requested)
	var config: Node = get_node_or_null("/root/GameConfig")
	var ai_difficulty: String = "normal"
	if config != null:
		ai_difficulty = String(config.get("ai_difficulty"))
	_current_battle.start_session({
		"player_role_id": player_role_id,
		"cpu_role_ids": cpu_roles,
		"training_dummy": training_dummy,
		"ai_difficulty": ai_difficulty,
	})
	_set_menu_overlay_visible(false)


func _start_battle_story(player_role_id: String) -> void:
	_pause_demo_battle()
	_stop_menu_bgm()
	main_menu.visible = false
	submenu_panel.visible = false
	logo.visible = false
	_current_battle = BATTLE_SCENE.instantiate() as BattleScene
	battle_host.add_child(_current_battle)
	_current_battle.exit_requested.connect(_on_battle_exit_requested)
	var config: Node = get_node_or_null("/root/GameConfig")
	var ai_difficulty: String = "normal"
	if config != null:
		ai_difficulty = String(config.get("ai_difficulty"))
	_current_battle.start_session({
		"story": true,
		"stage_id": "kitchen",
		"player_role_id": player_role_id,
		"ai_difficulty": ai_difficulty,
	})
	_set_menu_overlay_visible(false)


func _start_battle_2v2(player_role_id: String) -> void:
	_pause_demo_battle()
	_stop_menu_bgm()
	main_menu.visible = false
	submenu_panel.visible = false
	logo.visible = false
	# Pick 1 random partner + 2 random enemies from remaining roles
	var others: Array[String] = []
	for role_id in _role_ids:
		if role_id != player_role_id:
			others.append(role_id)
	others.shuffle()
	var partner_id: String = others[0]
	var enemy_ids: Array[String] = [others[1], others[2]]
	_current_battle = BATTLE_SCENE.instantiate() as BattleScene
	battle_host.add_child(_current_battle)
	_current_battle.exit_requested.connect(_on_battle_exit_requested)
	var config: Node = get_node_or_null("/root/GameConfig")
	var ai_difficulty: String = "normal"
	if config != null:
		ai_difficulty = String(config.get("ai_difficulty"))
	_current_battle.start_session({
		"mode": "2v2",
		"player_role_id": player_role_id,
		"partner_role_id": partner_id,
		"enemy_role_ids": enemy_ids,
		"ai_difficulty": ai_difficulty,
	})
	_set_menu_overlay_visible(false)


func _on_battle_exit_requested() -> void:
	if _current_battle != null:
		_current_battle.queue_free()
		_current_battle = null
	_set_menu_overlay_visible(true)
	main_menu.visible = true

	logo.visible = true
	submenu_panel.visible = false
	role_select.visible = false
	_resume_demo_battle()
	_activate_menu("main")
	_start_menu_bgm()


func _set_menu_overlay_visible(visible_state: bool) -> void:
	menu_layer.visible = visible_state
	background_shade.visible = visible_state


func _pick_unique_cpu_roles(player_role_id: String, amount: int) -> Array[String]:
	var choices: Array[String] = []
	for role_id in _role_ids:
		if role_id != player_role_id:
			choices.append(role_id)
	choices.shuffle()
	var result: Array[String] = []
	for i in range(min(amount, choices.size())):
		result.append(choices[i])
	return result


func _animate_waves(delta: float) -> void:
	var front_speed: float = 30.0 * delta
	var back_speed: float = 11.0 * delta
	front_wave_a.position.x -= front_speed
	front_wave_b.position.x -= front_speed
	back_wave_a.position.x -= back_speed
	back_wave_b.position.x -= back_speed
	if front_wave_a.position.x <= -_front_wave_width:
		front_wave_a.position.x = front_wave_b.position.x + _front_wave_width
	if front_wave_b.position.x <= -_front_wave_width:
		front_wave_b.position.x = front_wave_a.position.x + _front_wave_width
	if back_wave_a.position.x <= -_back_wave_width:
		back_wave_a.position.x = back_wave_b.position.x + _back_wave_width
	if back_wave_b.position.x <= -_back_wave_width:
		back_wave_b.position.x = back_wave_a.position.x + _back_wave_width


func _reset_waves() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var front_texture_height: float = float(front_wave_a.texture.get_height()) if front_wave_a.texture != null else 0.0
	var back_texture_height: float = float(back_wave_a.texture.get_height()) if back_wave_a.texture != null else 0.0
	var front_y: float = maxf(viewport_size.y - front_texture_height, 0.0)
	var back_y: float = maxf(viewport_size.y - back_texture_height - (14.0 * _get_layout_scale()), 0.0)
	front_wave_a.position = Vector2(0.0, front_y)
	front_wave_b.position = Vector2(_front_wave_width, front_y)
	back_wave_a.position = Vector2(0.0, back_y)
	back_wave_b.position = Vector2(_back_wave_width, back_y)


func _show_message(text: String) -> void:
	message_dialog.dialog_text = text
	message_dialog.popup_centered()
	_focus_accept_dialog(message_dialog)
