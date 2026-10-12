extends Control
class_name LifeBar

const BAR_COLORS: Array[Color] = [
	Color(0.86, 0.0, 0.0),     # red
	Color(1.0, 0.51, 0.0),     # orange
	Color(0.55, 0.80, 0.0),    # green
	Color(0.04, 0.43, 0.82),   # blue
	Color(0.55, 0.53, 0.98),   # purple
]
const SHADOW_DARKEN: float = 0.80
const FLASH_FADE_SPEED: float = 8.0
const SHADOW_WAIT_TIME: float = 0.5
const SHADOW_ACCEL: float = 1.0
const BAR_HEIGHT: float = 14.0

var max_hp: int = 1000
var hp_per_bar: int = 500
var current_hp: int = 1000
var shadow_hp: int = 1000
var flash_alpha: float = 0.0
var flash_hp_pos: float = 0.0
var shadow_wait: float = 0.0
var shadow_erase_speed: float = 1.0
var _bar_width: float = 135.0

static var _x_texture: Texture2D = null
static var _digit_textures: Array[Texture2D] = []
static var _bar_font_loaded: bool = false


static func _load_bar_font() -> void:
	if _bar_font_loaded:
		return
	_x_texture = load("res://assets/extracted/font/x.png") as Texture2D
	_digit_textures.resize(10)
	for i in range(10):
		_digit_textures[i] = load("res://assets/extracted/font/%d.png" % i) as Texture2D
	_bar_font_loaded = true


func setup(max_health: int, per_bar: int = 500) -> void:
	_load_bar_font()
	max_hp = max_health
	hp_per_bar = per_bar
	current_hp = max_health
	shadow_hp = max_health
	flash_alpha = 0.0
	shadow_wait = 0.0
	shadow_erase_speed = 1.0
	queue_redraw()


func set_health(new_hp: int) -> void:
	var old_hp: int = current_hp
	current_hp = clampi(new_hp, 0, max_hp)
	if current_hp < old_hp:
		flash_alpha = 1.0
		flash_hp_pos = float(old_hp)
		shadow_wait = SHADOW_WAIT_TIME
		shadow_erase_speed = 1.0
	queue_redraw()


func _process(delta: float) -> void:
	var changed: bool = false
	if flash_alpha > 0.0:
		flash_alpha = maxf(flash_alpha - FLASH_FADE_SPEED * delta, 0.0)
		changed = true
	if shadow_hp > current_hp:
		if shadow_wait > 0.0:
			shadow_wait = maxf(shadow_wait - delta, 0.0)
		else:
			shadow_erase_speed += SHADOW_ACCEL * delta * 60.0
			shadow_hp = maxi(current_hp, shadow_hp - int(shadow_erase_speed))
		changed = true
	elif shadow_hp < current_hp:
		shadow_hp = current_hp
		changed = true
	if changed:
		queue_redraw()


func _get_bar_color(bar_index: int) -> Color:
	return BAR_COLORS[bar_index % BAR_COLORS.size()]


func _hp_to_bar_fraction(hp_value: int) -> Dictionary:
	var bar_index: int = (hp_value - 1) / hp_per_bar if hp_value > 0 else 0
	var fraction: float = float(hp_value - bar_index * hp_per_bar) / float(hp_per_bar)
	fraction = clampf(fraction, 0.0, 1.0)
	if hp_value <= 0:
		fraction = 0.0
		bar_index = 0
	return {"bar": bar_index, "fraction": fraction}


func _draw() -> void:
	_bar_width = size.x
	var bar_h: float = minf(BAR_HEIGHT, size.y)

	# Background (previous bar color or dark)
	var current_info: Dictionary = _hp_to_bar_fraction(current_hp)
	var bg_color: Color = Color(0.15, 0.12, 0.12)
	if current_info["bar"] > 0:
		bg_color = _get_bar_color(int(current_info["bar"]) - 1)
	draw_rect(Rect2(0.0, 0.0, _bar_width, bar_h), bg_color)

	# Shadow trail
	if shadow_hp > current_hp:
		var shadow_info: Dictionary = _hp_to_bar_fraction(shadow_hp)
		var shadow_width: float = float(shadow_info["fraction"]) * _bar_width
		var shadow_color: Color = _get_bar_color(int(shadow_info["bar"]))
		shadow_color = shadow_color.darkened(1.0 - SHADOW_DARKEN)
		draw_rect(Rect2(0.0, 0.0, shadow_width, bar_h), shadow_color)

	# Current HP bar
	var hp_width: float = float(current_info["fraction"]) * _bar_width
	var hp_color: Color = _get_bar_color(int(current_info["bar"]))
	if hp_width > 0.0:
		draw_rect(Rect2(0.0, 0.0, hp_width, bar_h), hp_color)

	# Flash overlay
	if flash_alpha > 0.0:
		var flash_info: Dictionary = _hp_to_bar_fraction(int(flash_hp_pos))
		var flash_width: float = float(flash_info["fraction"]) * _bar_width
		var flash_color: Color = Color(1.0, 1.0, 1.0, flash_alpha * 0.7)
		draw_rect(Rect2(0.0, 0.0, flash_width, bar_h), flash_color)

	# Border
	draw_rect(Rect2(0.0, 0.0, _bar_width, bar_h), Color(0.3, 0.3, 0.3), false, 1.0)

	# xN bar count indicator
	var bar_count: int = (current_hp - 1) / hp_per_bar + 1 if current_hp > 0 else 0
	if bar_count > 1 and _x_texture != null:
		var indicator_x: float = _bar_width - 2.0
		var digits_text: String = str(bar_count)
		# Draw right-to-left: digits then "x"
		for j in range(digits_text.length() - 1, -1, -1):
			var d: int = int(digits_text[j])
			if d >= 0 and d < 10 and _digit_textures[d] != null:
				var dtex: Texture2D = _digit_textures[d]
				indicator_x -= dtex.get_width() * 0.5
				draw_texture_rect(dtex, Rect2(indicator_x, 1.0, dtex.get_width() * 0.5, dtex.get_height() * 0.5), false)
		indicator_x -= _x_texture.get_width() * 0.5
		draw_texture_rect(_x_texture, Rect2(indicator_x, 1.0, _x_texture.get_width() * 0.5, _x_texture.get_height() * 0.5), false)
