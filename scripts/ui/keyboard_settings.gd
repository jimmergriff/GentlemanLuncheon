extends Window

signal closed()

const GameConfigScript = preload("res://scripts/config/game_config.gd")
const UI_THEME: Theme = preload("res://resources/retro_arcade_theme.tres")

const ACTION_LABEL_KEYS: Dictionary = {
	"p1_left": "action.left",
	"p1_right": "action.right",
	"p1_up": "action.up",
	"p1_down": "action.down",
	"p1_jump": "action.jump",
	"p1_defend": "action.guard",
	"p1_attack_a": "action.punch",
	"p1_attack_b": "action.kick",
}

const ACTION_ORDER: Array[String] = [
	"p1_left", "p1_right", "p1_up", "p1_down",
	"p1_attack_a", "p1_attack_b", "p1_defend", "p1_jump",
]

var _key_buttons: Dictionary = {}  # action_name -> Button
var _action_labels: Dictionary = {}  # action_name -> Label
var _capturing_action: String = ""
var _capture_overlay: Panel = null
var _capture_label: Label = null
var _instruction_label: Label = null
var _defaults_button: Button = null
var _ok_button: Button = null


func _ready() -> void:
	theme = UI_THEME
	size = Vector2i(520, 420)
	min_size = Vector2i(520, 420)
	unresizable = true
	close_requested.connect(_on_close)
	_connect_language_signal()
	_build_ui()
	_refresh_translations()
	_refresh_labels()
	call_deferred("_focus_initial_button")


func _connect_language_signal() -> void:
	var config: Node = get_node_or_null("/root/GameConfig")
	if config == null or not config.has_signal("language_changed"):
		return
	if not config.language_changed.is_connected(_on_language_changed):
		config.language_changed.connect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	_refresh_translations()
	_refresh_labels()


func _build_ui() -> void:
	var root: VBoxContainer = VBoxContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 16.0
	root.offset_top = 16.0
	root.offset_right = -16.0
	root.offset_bottom = -16.0
	add_child(root)

	_instruction_label = Label.new()
	_instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_instruction_label)

	root.add_child(HSeparator.new())

	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(grid)

	for action_name in ACTION_ORDER:
		var label: Label = Label.new()
		label.custom_minimum_size.x = 80.0
		grid.add_child(label)
		_action_labels[action_name] = label

		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(120.0, 36.0)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_key_button_pressed.bind(action_name))
		btn.focus_mode = Control.FOCUS_ALL
		grid.add_child(btn)
		_key_buttons[action_name] = btn

	root.add_child(HSeparator.new())

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(btn_row)

	_defaults_button = Button.new()
	_defaults_button.pressed.connect(_on_restore_defaults)
	_defaults_button.focus_mode = Control.FOCUS_ALL
	btn_row.add_child(_defaults_button)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size.x = 20.0
	btn_row.add_child(spacer)

	_ok_button = Button.new()
	_ok_button.custom_minimum_size.x = 60.0
	_ok_button.pressed.connect(_on_close)
	_ok_button.focus_mode = Control.FOCUS_ALL
	btn_row.add_child(_ok_button)

	# Capture overlay (hidden by default)
	_capture_overlay = Panel.new()
	_capture_overlay.anchor_right = 1.0
	_capture_overlay.anchor_bottom = 1.0
	_capture_overlay.visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.75)
	_capture_overlay.add_theme_stylebox_override("panel", style)
	add_child(_capture_overlay)

	_capture_label = Label.new()
	_capture_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_capture_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_capture_label.anchor_right = 1.0
	_capture_label.anchor_bottom = 1.0
	_capture_overlay.add_child(_capture_label)


func _refresh_translations() -> void:
	title = Localization.text("keyboard.title")
	if _instruction_label != null:
		_instruction_label.text = Localization.text("keyboard.instructions")
	for action_name in _action_labels.keys():
		var label: Label = _action_labels[action_name]
		label.text = _get_action_label(action_name)
	if _defaults_button != null:
		_defaults_button.text = Localization.text("keyboard.restore_defaults")
	if _ok_button != null:
		_ok_button.text = Localization.text("dialog.ok")
	_update_capture_prompt(false)


func _refresh_labels() -> void:
	var config: Node = get_node_or_null("/root/GameConfig")
	if config == null:
		return
	for action_name in _key_buttons.keys():
		var key_code: int = int(config.key_bindings.get(action_name, 0))
		var btn: Button = _key_buttons[action_name]
		btn.text = _get_key_display(key_code)


func _get_action_label(action_name: String) -> String:
	return Localization.text(String(ACTION_LABEL_KEYS.get(action_name, action_name)))


func _update_capture_prompt(is_invalid: bool) -> void:
	if _capture_label == null:
		return
	if is_invalid:
		_capture_label.text = Localization.text("keyboard.invalid_key")
	elif _capturing_action.is_empty():
		_capture_label.text = Localization.text("keyboard.capture_prompt")
	else:
		_capture_label.text = Localization.text("keyboard.capture_action", [_get_action_label(_capturing_action)])


func _on_key_button_pressed(action_name: String) -> void:
	_capturing_action = action_name
	_capture_overlay.visible = true
	_update_capture_prompt(false)


func _unhandled_key_input(event: InputEvent) -> void:
	if _capturing_action.is_empty():
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key_event: InputEventKey = event as InputEventKey
	var key_code: int = int(key_event.keycode)

	# Validate: only accept printable keys, arrows, space, numpad
	if not _is_valid_key(key_code):
		_update_capture_prompt(true)
		get_viewport().set_input_as_handled()
		return

	var config: Node = get_node_or_null("/root/GameConfig")
	if config != null:
		config.set_key_binding(_capturing_action, key_code)

	_capturing_action = ""
	_capture_overlay.visible = false
	_update_capture_prompt(false)
	_refresh_labels()
	get_viewport().set_input_as_handled()


func _is_valid_key(key_code: int) -> bool:
	# Letters A-Z
	if key_code >= KEY_A and key_code <= KEY_Z:
		return true
	# Digits 0-9
	if key_code >= KEY_0 and key_code <= KEY_9:
		return true
	# Arrow keys
	if key_code in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		return true
	# Space, shift, ctrl, etc.
	if key_code in [KEY_SPACE, KEY_SHIFT, KEY_CTRL, KEY_TAB, KEY_BACKSPACE]:
		return true
	# Numpad
	if key_code >= KEY_KP_0 and key_code <= KEY_KP_9:
		return true
	# Punctuation
	if key_code in [KEY_COMMA, KEY_PERIOD, KEY_SLASH, KEY_SEMICOLON, KEY_APOSTROPHE, KEY_BRACKETLEFT, KEY_BRACKETRIGHT, KEY_MINUS, KEY_EQUAL]:
		return true
	return false


func _get_key_display(key_code: int) -> String:
	return GameConfigScript.get_key_label(key_code)


func _focus_initial_button() -> void:
	if _key_buttons.has(ACTION_ORDER[0]):
		(_key_buttons[ACTION_ORDER[0]] as Button).grab_focus()


func _on_restore_defaults() -> void:
	var config: Node = get_node_or_null("/root/GameConfig")
	if config != null:
		config.reset_to_defaults()
	_refresh_labels()


func _on_close() -> void:
	closed.emit()
	queue_free()
