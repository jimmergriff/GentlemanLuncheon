extends Node

const CONFIG_PATH: String = "user://config.cfg"
const DEFAULT_LANGUAGE: String = Localization.DEFAULT_LANGUAGE

const DEFAULT_KEYS: Dictionary = {
	"p1_left": KEY_A,
	"p1_right": KEY_D,
	"p1_up": KEY_W,
	"p1_down": KEY_S,
	"p1_attack_a": KEY_J,
	"p1_attack_b": KEY_K,
	"p1_defend": KEY_L,
	"p1_jump": KEY_SPACE,
}

signal language_changed(locale: String)

var windowed: bool = true
var language: String = DEFAULT_LANGUAGE
var ai_difficulty: String = "normal"
var key_bindings: Dictionary = {}


func _ready() -> void:
	key_bindings = DEFAULT_KEYS.duplicate()
	_ensure_menu_actions()
	Localization.ensure_registered()
	load_config()
	_apply_window_mode()
	_apply_language(false)
	_apply_key_bindings()


func load_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	windowed = bool(config.get_value("display", "windowed", true))
	language = Localization.normalize_locale(String(config.get_value("general", "language", DEFAULT_LANGUAGE)))
	ai_difficulty = String(config.get_value("general", "ai_difficulty", "normal"))
	for action_name in DEFAULT_KEYS.keys():
		var key_code: int = config.get_value("keys", action_name, int(DEFAULT_KEYS[action_name]))
		key_bindings[action_name] = key_code


func save_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("display", "windowed", windowed)
	config.set_value("general", "language", language)
	config.set_value("general", "ai_difficulty", ai_difficulty)
	for action_name in key_bindings.keys():
		config.set_value("keys", action_name, int(key_bindings[action_name]))
	config.save(CONFIG_PATH)


func set_language(locale: String) -> void:
	var previous: String = language
	language = Localization.normalize_locale(locale)
	_apply_language(previous != language or TranslationServer.get_locale() != language)
	save_config()


func toggle_language() -> void:
	set_language(Localization.get_next_locale(language))


func set_ai_difficulty(value: String) -> void:
	var allowed: Array[String] = ["easy", "normal", "hard"]
	ai_difficulty = value if allowed.has(value) else "normal"
	save_config()


func cycle_ai_difficulty() -> void:
	match ai_difficulty:
		"easy":
			set_ai_difficulty("normal")
		"normal":
			set_ai_difficulty("hard")
		_:
			set_ai_difficulty("easy")


func set_windowed(is_windowed: bool) -> void:
	windowed = is_windowed
	_apply_window_mode()
	save_config()


func toggle_window_mode() -> void:
	set_windowed(not windowed)


func set_key_binding(action_name: String, key_code: int) -> void:
	var planned_bindings: Dictionary = _plan_key_binding_update(action_name, key_code)
	for planned_action in planned_bindings.keys():
		var planned_key_code: int = int(planned_bindings[planned_action])
		key_bindings[planned_action] = planned_key_code
		_remap_action(String(planned_action), planned_key_code)
	save_config()


func reset_to_defaults() -> void:
	key_bindings = DEFAULT_KEYS.duplicate()
	_apply_key_bindings()
	save_config()


func _apply_key_bindings() -> void:
	for action_name in key_bindings.keys():
		_remap_action(action_name, int(key_bindings[action_name]))


func _apply_window_mode() -> void:
	var target_mode: DisplayServer.WindowMode = (
		DisplayServer.WINDOW_MODE_WINDOWED
		if windowed
		else DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	if DisplayServer.window_get_mode() != target_mode:
		DisplayServer.window_set_mode(target_mode)


func _remap_action(action_name: String, key_code: int) -> void:
	if not InputMap.has_action(action_name):
		return
	InputMap.action_erase_events(action_name)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key_code as Key
	InputMap.action_add_event(action_name, event)


func _plan_key_binding_update(action_name: String, key_code: int, source_bindings: Dictionary = {}) -> Dictionary:
	var bindings: Dictionary = key_bindings if source_bindings.is_empty() else source_bindings
	var previous_key_code: int = int(bindings.get(action_name, int(DEFAULT_KEYS.get(action_name, key_code))))
	var planned_bindings: Dictionary = {action_name: key_code}
	var conflicting_action: String = _find_action_bound_to_key(key_code, action_name, bindings)
	if not conflicting_action.is_empty():
		planned_bindings[conflicting_action] = previous_key_code
	return planned_bindings


func _find_action_bound_to_key(key_code: int, excluding_action_name: String = "", source_bindings: Dictionary = {}) -> String:
	var bindings: Dictionary = key_bindings if source_bindings.is_empty() else source_bindings
	for action_name in bindings.keys():
		if action_name == excluding_action_name:
			continue
		if int(bindings[action_name]) == key_code:
			return String(action_name)
	return ""


func _ensure_menu_actions() -> void:
	_ensure_action_has_key("ui_accept", KEY_ENTER)
	_ensure_action_has_key("ui_accept", KEY_KP_ENTER)
	_ensure_action_has_key("ui_cancel", KEY_ESCAPE)
	_ensure_action_has_key("ui_up", KEY_W)
	_ensure_action_has_key("ui_up", KEY_UP)
	_ensure_action_has_key("ui_down", KEY_S)
	_ensure_action_has_key("ui_down", KEY_DOWN)
	_ensure_action_has_key("ui_left", KEY_A)
	_ensure_action_has_key("ui_left", KEY_LEFT)
	_ensure_action_has_key("ui_right", KEY_D)
	_ensure_action_has_key("ui_right", KEY_RIGHT)


func _ensure_action_has_key(action_name: String, key_code: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventKey:
			var key_event: InputEventKey = existing as InputEventKey
			if int(key_event.keycode) == key_code or int(key_event.physical_keycode) == key_code:
				return
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key_code as Key
	event.physical_keycode = key_code as Key
	InputMap.action_add_event(action_name, event)


static func get_key_label(key_code: int) -> String:
	match key_code:
		KEY_SPACE:
			return Localization.text("key.space")
		KEY_UP:
			return Localization.text("key.up")
		KEY_DOWN:
			return Localization.text("key.down")
		KEY_LEFT:
			return Localization.text("key.left")
		KEY_RIGHT:
			return Localization.text("key.right")
		KEY_SHIFT:
			return Localization.text("key.shift")
		KEY_CTRL:
			return Localization.text("key.ctrl")
		KEY_TAB:
			return Localization.text("key.tab")
		_:
			var label: String = OS.get_keycode_string(key_code as Key)
			if label.is_empty():
				return Localization.text("key.generic", [key_code])
			return label


func _apply_language(notify: bool) -> void:
	language = Localization.set_locale(language)
	if notify:
		language_changed.emit(language)
