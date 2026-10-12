extends Node2D
class_name DamageNumber

const EXPAND_DURATION: float = 0.08
const SHRINK_DURATION: float = 0.08
const HOLD_DURATION: float = 0.32
const FLOAT_DURATION: float = 0.48
const FLOAT_DISTANCE: float = 80.0

var _value: int = 0
var _step: int = 0  # 0=expand, 1=shrink, 2=hold, 3=float+fade
var _timer: float = 0.0
var _base_position: Vector2 = Vector2.ZERO
var _digit_sprites: Array[Sprite2D] = []
var _active: bool = false
var _target_id: int = -1

static var _digit_textures: Array[Texture2D] = []
static var _textures_loaded: bool = false


static func _load_digit_textures() -> void:
	if _textures_loaded:
		return
	_digit_textures.resize(10)
	for i in range(10):
		_digit_textures[i] = load("res://assets/extracted/font/red-%d.png" % i) as Texture2D
	_textures_loaded = true


func _ready() -> void:
	_load_digit_textures()
	visible = false


func show_damage(value: int, world_pos: Vector2, target_id: int) -> void:
	_value = value
	_base_position = world_pos + Vector2(0.0, -60.0)
	_target_id = target_id
	_step = 0
	_timer = 0.0
	_active = true
	visible = true
	position = _base_position
	_rebuild_digits()
	scale = Vector2(1.5, 1.5)
	modulate = Color(1.0, 1.0, 1.0, 1.0)


func accumulate(extra_value: int) -> void:
	_value += extra_value
	_step = 0
	_timer = 0.0
	scale = Vector2(1.5, 1.5)
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_rebuild_digits()


func can_accumulate() -> bool:
	return _active and _step < 3


func get_target_id() -> int:
	return _target_id


func is_active() -> bool:
	return _active


func _process(delta: float) -> void:
	if not _active:
		return
	_timer += delta
	match _step:
		0:  # Expand
			var t: float = minf(_timer / EXPAND_DURATION, 1.0)
			scale = Vector2.ONE * lerpf(1.0, 1.5, t)
			if _timer >= EXPAND_DURATION:
				_timer = 0.0
				_step = 1
		1:  # Shrink
			var t: float = minf(_timer / SHRINK_DURATION, 1.0)
			scale = Vector2.ONE * lerpf(1.5, 1.0, t)
			if _timer >= SHRINK_DURATION:
				_timer = 0.0
				_step = 2
				scale = Vector2.ONE
		2:  # Hold
			if _timer >= HOLD_DURATION:
				_timer = 0.0
				_step = 3
		3:  # Float + Fade
			var t: float = minf(_timer / FLOAT_DURATION, 1.0)
			position.y = _base_position.y - FLOAT_DISTANCE * t
			modulate.a = 1.0 - t
			if _timer >= FLOAT_DURATION:
				_active = false
				visible = false


func _rebuild_digits() -> void:
	for sprite in _digit_sprites:
		sprite.queue_free()
	_digit_sprites.clear()

	var text: String = str(_value)
	var total_width: float = 0.0
	var widths: Array[float] = []
	for ch in text:
		var digit: int = int(ch)
		if digit >= 0 and digit < 10 and _digit_textures[digit] != null:
			var w: float = _digit_textures[digit].get_width()
			widths.append(w)
			total_width += w
		else:
			widths.append(0.0)

	var x_offset: float = -total_width / 2.0
	for i in range(text.length()):
		var digit: int = int(text[i])
		if digit < 0 or digit >= 10 or _digit_textures[digit] == null:
			continue
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = _digit_textures[digit]
		sprite.centered = false
		sprite.position.x = x_offset
		sprite.position.y = -sprite.texture.get_height() / 2.0
		add_child(sprite)
		_digit_sprites.append(sprite)
		x_offset += widths[i]
