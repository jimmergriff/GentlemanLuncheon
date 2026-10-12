extends Control
## The original intro sequence, ported from the HTML game:
##   logo (JI Slop splat)  ->  Brady-style lineup  ->  title screen
## Drawn at the HTML game's 960x540 logical size and scaled to fit the window.
## Emits `finished` when the player presses a key on the title screen.

signal finished

const LOGICAL: Vector2 = Vector2(960.0, 540.0)
const LOGO_W: float = 320.0
const LOGO_H: float = 180.0
var LOGO_BG: Color = Color("#8fc9a0")
const PLATE_Y: float = 100.0
const PLATE_BOTTOM: float = 149.0
const LOGO_END: float = 6.4
const BRADY_FADE_START: float = 6.4
const BRADY_END: float = 7.4
const GRID_CW: float = 226.0
const GRID_CH: float = 166.0
const GRID_GAP: float = 14.0
const GRID_M: float = 7.0
var BULB_COLS: Array[Color] = [Color("#ff4040"), Color("#ffd23f"), Color("#44d46f"), Color("#40a8ff"), Color("#ff7ad9")]
const TITLE_FIGHTERS: Array[String] = ["beach", "spence", "vince", "rick", "ryguy", "nate", "eril"]

# [column, row, what, background]; the middle two cells of the top row hold the title panel
const CELLS: Array = [
	[0, 0, "beach", "#f2a541"], [1, 0, "spence", "#e05c5c"], [2, 0, "vince", "#3bb3a7"], [3, 0, "can", "#4f9e6e"],
	[0, 1, "rick", "#8a5bd6"], [3, 1, "nate", "#9fb6cc"],
	[0, 2, "horse", "#81afc5"], [1, 2, "ryguy", "#f0d25a"], [2, 2, "dart", "#6cbf6a"], [3, 2, "eril", "#5f7a4e"],
]

# head crops are stored as separate images; the rects below are the crop sizes they came from
const HEAD_KEYS: Array[String] = ["beach", "spence", "vince", "rick", "nate", "ryguy", "eril"]

const SHINE_SHADER: String = """
shader_type canvas_item;
uniform float amt = 1.0;
uniform float out_amt = 0.0;
uniform float shine = -1000.0;
uniform vec2 origin = vec2(0.0);
uniform vec2 psize = vec2(1.0);
uniform sampler2D noise_tex : filter_nearest;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec2 lp = origin + UV * psize;
	float n = texture(noise_tex, (lp + vec2(0.5)) / vec2(320.0, 180.0)).r;
	if (out_amt > 0.0 && n < out_amt) { discard; }
	if (amt < 1.0 || shine > -900.0) {
		if (c.a < 0.5 || n >= amt) { discard; }
		c.a = 1.0;
	}
	if (shine > -900.0 && abs(lp.x + lp.y * 0.5 - shine) < 3.0) {
		c.rgb = vec3(1.0, 1.0, 0.88);
	}
	COLOR = c;
}
"""

var phase: String = "logo"
var logo_t: float = 0.0
var brady_t: float = 0.0
var title_t: float = 0.0
var shake: float = 0.0
var brady_last: Array[int] = []
var _stage: Control = null
var _letterbox: ColorRect = null
var _logo_bg: ColorRect = null
var _logo_layer: Control = null
var _canvas: Control = null
var _droplets_layer: Control = null
var _pieces: Dictionary = {}
var _noise: ImageTexture = null
var _droplets: Array[Dictionary] = []
var _splat_spawned: bool = false
var _snow: Array[Dictionary] = []
var _strands: Array[Array] = []
var _bulbs: Array[Dictionary] = []
var _textures: Dictionary = {}
var _banner: Texture2D = null
var _horse: Texture2D = null
var _font: Font = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	top_level = true
	position = Vector2.ZERO
	size = get_viewport_rect().size
	get_viewport().size_changed.connect(_fit_to_viewport)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rng.seed = 7
	_font = ThemeDB.fallback_font
	_load_assets()
	_build_noise()
	_build_snow()
	_build_lights()
	brady_last.resize(CELLS.size())
	brady_last.fill(-1)
	var letterbox := ColorRect.new()
	letterbox.color = Color.BLACK
	_letterbox = letterbox
	letterbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(letterbox)
	letterbox.size = get_viewport_rect().size
	_stage = Control.new()
	_stage.size = LOGICAL
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	_logo_bg = ColorRect.new()
	_logo_bg.color = LOGO_BG
	_logo_bg.size = LOGICAL
	_stage.add_child(_logo_bg)
	_build_logo()
	_canvas = Control.new()
	_canvas.size = LOGICAL
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.visible = false
	_stage.add_child(_canvas)
	_canvas.draw.connect(_on_canvas_draw)
	_layout()


func _load_assets() -> void:
	for key in ["plate", "blob", "splat", "pile", "wordmark", "presents"]:
		_textures[key] = load("res://assets/intro/logo/%s.png" % key)
	for key in HEAD_KEYS:
		_textures["head_" + key] = load("res://assets/intro/heads/%s.png" % key)
	for key in TITLE_FIGHTERS:
		_textures["fighter_" + key] = load("res://assets/roles/%s/front.png" % key)
	_banner = load("res://assets/intro/banner.jpg")
	_horse = load("res://assets/intro/horse.png")


func _build_noise() -> void:
	var img: Image = Image.create(320, 180, false, Image.FORMAT_RGBA8)
	for y in range(180):
		for x in range(320):
			var v: float = _rng.randf()
			img.set_pixel(x, y, Color(v, v, v, 1.0))
	_noise = ImageTexture.create_from_image(img)


func _build_snow() -> void:
	for i in range(70):
		_snow.append({
			"x": _rng.randf() * LOGICAL.x, "y": _rng.randf() * LOGICAL.y,
			"v": 20.0 + _rng.randf() * 40.0, "r": 1.0 + _rng.randf() * 2.0,
		})


func _build_lights() -> void:
	var cell_y: Callable = func(r: int) -> float: return GRID_M + r * (GRID_CH + GRID_GAP)
	var cell_x: Callable = func(c: int) -> float: return GRID_M + c * (GRID_CW + GRID_GAP)
	var horizontal: Array[float] = [3.5, cell_y.call(0) + GRID_CH + GRID_GAP / 2.0, cell_y.call(1) + GRID_CH + GRID_GAP / 2.0, 536.5]
	for y in horizontal:
		_strands.append([Vector2(0, y), Vector2(960, y)])
	var vertical: Array[float] = [3.5, cell_x.call(1) - GRID_GAP / 2.0, cell_x.call(2) - GRID_GAP / 2.0, cell_x.call(3) - GRID_GAP / 2.0, 956.5]
	for x in vertical:
		_strands.append([Vector2(x, 0), Vector2(x, 540)])
	for si in range(_strands.size()):
		var a: Vector2 = _strands[si][0]
		var b: Vector2 = _strands[si][1]
		var n: int = int(floor(a.distance_to(b) / 20.0))
		for k in range(n + 1):
			var f: float = float(k) / float(n)
			_bulbs.append({
				"pos": a.lerp(b, f),
				"c": BULB_COLS[(k + si) % BULB_COLS.size()],
				"ph": float(k) * 0.7 + float(si),
			})


# --- logo -------------------------------------------------------------------

func _build_logo() -> void:
	_logo_layer = Control.new()
	_logo_layer.size = LOGICAL
	_logo_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_logo_layer)
	for key in ["plate", "blob", "splat", "pile"]:
		_add_piece(key)
	_droplets_layer = Control.new()
	_droplets_layer.size = LOGICAL
	_droplets_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_droplets_layer.draw.connect(_on_droplets_draw)
	_logo_layer.add_child(_droplets_layer)
	for key in ["wordmark", "presents"]:
		_add_piece(key)


func _add_piece(key: String) -> void:
	var tex: Texture2D = _textures[key]
	var rect := TextureRect.new()
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.size = tex.get_size() * 3.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = SHINE_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("noise_tex", _noise)
	rect.material = mat
	_logo_layer.add_child(rect)
	_pieces[key] = rect


func _set_piece(key: String, logo_pos: Vector2, amt: float, shine: float = -1000.0, out_amt: float = 0.0) -> void:
	var rect: TextureRect = _pieces[key]
	var tex_size: Vector2 = (_textures[key] as Texture2D).get_size()
	rect.visible = true
	rect.position = Vector2(round(logo_pos.x), round(logo_pos.y)) * 3.0
	var mat: ShaderMaterial = rect.material as ShaderMaterial
	mat.set_shader_parameter("amt", amt)
	mat.set_shader_parameter("shine", shine)
	mat.set_shader_parameter("out_amt", out_amt)
	mat.set_shader_parameter("origin", Vector2(round(logo_pos.x), round(logo_pos.y)))
	mat.set_shader_parameter("psize", tex_size)


func _hide_piece(key: String) -> void:
	(_pieces[key] as TextureRect).visible = false


func _update_logo(delta: float) -> void:
	var cx: float = LOGO_W / 2.0
	var t: float = logo_t
	var out_amt: float = clampf((t - 5.4) / 0.9, 0.0, 1.0)
	# 1) the plate slides in from the right
	if t < 1.6:
		var k: float = minf(1.0, t / 0.9)
		var e: float = 1.0 - pow(1.0 - k, 3.0)
		var px: float = cx - 65.0 + (1.0 - e) * 240.0
		_set_piece("plate", Vector2(px, PLATE_BOTTOM - 49.0 + 1.0), 1.0, -1000.0, out_amt)
	else:
		_hide_piece("plate")
	# 2) the slop falls and lands on the plate
	if t > 0.9 and t < 1.6:
		var tf: float = t - 0.9
		var y: float = -60.0 + 0.5 * 441.0 * tf * tf
		_set_piece("blob", Vector2(cx - 26.0, y), 1.0, -1000.0, out_amt)
	else:
		_hide_piece("blob")
	# 3) splat, which hands over to the storyboard pile
	if t >= 1.6 and t < 2.9:
		var splat_amt: float = 1.0 if t < 2.2 else clampf(1.0 - (t - 2.2) / 0.7, 0.0, 1.0)
		_set_piece("splat", Vector2(cx - 70.0, PLATE_BOTTOM - 67.0 + 1.0), splat_amt, -1000.0, out_amt)
	else:
		_hide_piece("splat")
	if t >= 2.2:
		var pile_amt: float = 1.0 if t >= 2.9 else clampf((t - 2.2) / 0.7, 0.0, 1.0)
		_set_piece("pile", Vector2(cx - 72.5, PLATE_BOTTOM - 61.0 + 1.0), pile_amt, -1000.0, out_amt)
	else:
		_hide_piece("pile")
	# 4) "JI Slop" fades in on top; "presents" fades in at the bottom
	if t > 2.2:
		var amt: float = minf(1.0, (t - 2.2) / 0.8)
		var shine: float = -60.0 + (t - 3.6) * 440.0 if (t > 3.6 and t < 4.6) else -1000.0
		_set_piece("wordmark", Vector2(cx - 100.0, 10.0), amt, shine, out_amt)
	else:
		_hide_piece("wordmark")
	if t > 3.0:
		_set_piece("presents", Vector2(cx - 56.0, 147.0), minf(1.0, (t - 3.0) / 0.6), -1000.0, out_amt)
	else:
		_hide_piece("presents")
	_update_droplets(delta)
	_droplets_layer.queue_redraw()


func _spawn_splat() -> void:
	_droplets.clear()
	for i in range(36):
		_droplets.append({
			"x": LOGO_W / 2.0, "y": PLATE_Y - 6.0,
			"vx": (_rng.randf() - 0.5) * 140.0, "vy": -40.0 - _rng.randf() * 90.0,
			"c": Color("#6b3a1e") if _rng.randf() < 0.7 else Color("#4a2410"),
			"s": 1.0 if _rng.randf() < 0.5 else 2.0,
		})


func _update_droplets(delta: float) -> void:
	for d in _droplets:
		d["vy"] = float(d["vy"]) + 260.0 * delta
		d["x"] = float(d["x"]) + float(d["vx"]) * delta
		d["y"] = float(d["y"]) + float(d["vy"]) * delta
	var kept: Array[Dictionary] = []
	for d in _droplets:
		if float(d["y"]) < PLATE_Y + 2.0:
			kept.append(d)
	_droplets = kept


func _on_droplets_draw() -> void:
	for d in _droplets:
		var s: float = float(d["s"])
		_droplets_layer.draw_rect(Rect2(round(float(d["x"])) * 3.0, round(float(d["y"])) * 3.0, s * 3.0, s * 3.0), d["c"])


# --- Brady lineup ----------------------------------------------------------

func _cell_x(c: int) -> float:
	return GRID_M + c * (GRID_CW + GRID_GAP)


func _cell_y(r: int) -> float:
	return GRID_M + r * (GRID_CH + GRID_GAP)


func _update_brady(delta: float) -> void:
	for i in range(CELLS.size()):
		var tt: float = brady_t + float(i) * 0.35
		var loop_idx: int = int(floor(tt / 4.0))
		var local: float = fmod(tt, 4.0)
		if local >= 1.3 and brady_last[i] != loop_idx:
			brady_last[i] = loop_idx
			shake = maxf(shake, 0.25)


# --- drawing ----------------------------------------------------------------

func _on_canvas_draw() -> void:
	if phase == "brady":
		_draw_brady()
	elif phase == "title":
		_draw_title()


func _draw_brady() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, LOGICAL), Color("#120a22"))
	var t: float = brady_t
	for i in range(CELLS.size()):
		var cell: Array = CELLS[i]
		var c: int = cell[0]
		var r: int = cell[1]
		var what: String = cell[2]
		var bg: Color = Color(String(cell[3]))
		var x: float = _cell_x(c)
		var y: float = _cell_y(r)
		var cx: float = x + GRID_CW / 2.0
		var cy: float = y + GRID_CH / 2.0
		var tt: float = t + float(i) * 0.4
		_canvas.draw_rect(Rect2(x, y, GRID_CW, GRID_CH), bg)
		if what in HEAD_KEYS:
			var face: float = 1.0 if c < 2 else -1.0
			var dir: float = -face if sin(tt * 1.3 + float(i) * 1.7) > 0.7 else face
			var tilt: float = sin(tt * 1.3 + float(i) * 1.7) * 0.05
			_draw_head(what, Vector2(cx, cy + 4.0 - absf(sin(tt * 3.0)) * 4.0), dir, tilt)
		elif what == "can":
			_draw_can(Vector2(cx, cy + 4.0 + sin(tt * 2.0) * 2.0))
		elif what == "dart":
			_draw_dartboard(Vector2(cx, cy + 2.0), 60.0, t * 0.12)
		elif what == "horse":
			var sc: float = 150.0 / float(_horse.get_width())
			var w: float = float(_horse.get_width()) * sc
			var h: float = float(_horse.get_height()) * sc
			_canvas.draw_set_transform(Vector2(cx, cy + 6.0), sin(tt * 2.0) * 0.03, Vector2.ONE)
			_canvas.draw_texture_rect(_horse, Rect2(-w / 2.0, -h / 2.0, w, h), false)
			_canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_lights(t)
	_draw_snow()
	# the title panel in the middle two cells
	var px: float = _cell_x(1)
	var py: float = _cell_y(1)
	var pw: float = GRID_CW * 2.0 + GRID_GAP
	_canvas.draw_rect(Rect2(px, py, pw, GRID_CH), Color("#1b0a12"))
	var bw: float = 440.0
	var bh: float = round(440.0 * 292.0 / 935.0)
	_canvas.draw_texture_rect(_banner, Rect2(px + (pw - bw) / 2.0, py + (GRID_CH - bh) / 2.0, bw, bh), false)
	if brady_t > BRADY_FADE_START:
		var a: float = clampf((brady_t - BRADY_FADE_START) / 0.8, 0.0, 1.0)
		_canvas.draw_rect(Rect2(Vector2.ZERO, LOGICAL), Color(0, 0, 0, a))


func _draw_head(what: String, center: Vector2, dir: float, tilt: float) -> void:
	var tex: Texture2D = _textures["head_" + what]
	var sw: float = float(tex.get_width())
	var sh: float = float(tex.get_height())
	var sc: float = minf(150.0 / sh, 206.0 / sw)
	var w: float = sw * sc
	var h: float = sh * sc
	_canvas.draw_set_transform(center, tilt, Vector2(dir, 1.0))
	_canvas.draw_texture_rect(tex, Rect2(-w / 2.0, -h / 2.0, w, h), false)
	_canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_can(center: Vector2) -> void:
	var w: float = 46.0
	var h: float = 104.0
	var x: float = center.x - w / 2.0
	var y: float = center.y - h / 2.0
	# metallic gradient in vertical strips
	var stops: Array[Color] = [Color("#8d949c"), Color("#f4f7fa"), Color("#c9d0d8"), Color("#6d747c")]
	var stop_at: Array[float] = [0.0, 0.35, 0.7, 1.0]
	for i in range(int(w)):
		var f: float = float(i) / w
		var col: Color = stops[3]
		for s in range(3):
			if f >= stop_at[s] and f <= stop_at[s + 1]:
				col = stops[s].lerp(stops[s + 1], (f - stop_at[s]) / (stop_at[s + 1] - stop_at[s]))
		_canvas.draw_rect(Rect2(x + float(i), y, 1.0, h), col)
	_canvas.draw_rect(Rect2(x, y + 30.0, w, 36.0), Color("#c0392b"))
	_canvas.draw_rect(Rect2(x, y + 30.0, w, 3.0), Color("#ffd166"))
	_canvas.draw_rect(Rect2(x, y + 63.0, w, 3.0), Color("#ffd166"))
	_canvas.draw_rect(Rect2(x + 4.0, y, w - 8.0, 6.0), Color("#9aa3ad"))
	_canvas.draw_string(_font, Vector2(x, y + 48.0 + 4.0), "LAGER", HORIZONTAL_ALIGNMENT_CENTER, w, 9, Color.WHITE)


func _draw_dartboard(center: Vector2, radius: float, rot: float) -> void:
	var nums: Array[int] = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5]
	_canvas.draw_circle(center, radius + 6.0, Color("#2b2b2b"))
	for i in range(20):
		var a0: float = deg_to_rad(float(i) * 18.0 - 9.0) + rot
		var a1: float = deg_to_rad(float(i) * 18.0 + 9.0) + rot
		var dark: bool = i % 2 == 0
		var black: Color = Color("#161616")
		var cream: Color = Color("#efe6cc")
		var red: Color = Color("#c0392b")
		var green: Color = Color("#2e8b57")
		_canvas.draw_colored_polygon(_wedge(center, radius, a0, a1), black if dark else cream)
		_canvas.draw_colored_polygon(_wedge(center, radius * 0.62, a0, a1), red if dark else green)
		_canvas.draw_colored_polygon(_wedge(center, radius * 0.56, a0, a1), black if dark else cream)
	_canvas.draw_circle(center, radius * 0.08, Color("#2e8b57"))
	_canvas.draw_circle(center, radius * 0.036, Color("#c0392b"))
	for i in range(nums.size()):
		var a: float = deg_to_rad(float(i) * 18.0) + rot
		var p: Vector2 = center + Vector2(sin(a), -cos(a)) * (radius + 15.0)
		_canvas.draw_string(_font, p + Vector2(-6.0, 4.0), str(nums[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)


func _wedge(center: Vector2, radius: float, a0: float, a1: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	pts.append(center)
	var steps: int = 6
	for k in range(steps + 1):
		var a: float = lerpf(a0, a1, float(k) / float(steps))
		pts.append(center + Vector2(sin(a), -cos(a)) * radius)
	return pts


func _draw_lights(t: float) -> void:
	for s in _strands:
		_canvas.draw_line(s[0], s[1], Color("#17301f"), 2.0)
	for b in _bulbs:
		var on: float = 0.3 + 0.7 * maxf(0.0, sin(t * 4.0 + float(b["ph"])))
		var c: Color = b["c"]
		var p: Vector2 = b["pos"]
		_canvas.draw_circle(p, 7.0, Color(c.r, c.g, c.b, 0.25 * on))
		_canvas.draw_circle(p, 3.4, Color(c.r, c.g, c.b, on))
		_canvas.draw_circle(p + Vector2(-1.0, -1.0), 1.0, Color(1, 1, 1, 0.8 * on))


func _draw_snow() -> void:
	for s in _snow:
		_canvas.draw_circle(Vector2(s["x"], s["y"]), s["r"], Color.WHITE)


func _draw_title() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, LOGICAL), Color("#0b0816"))
	var frame: int = int(floor(title_t * 4.0))
	for i in range(70):
		var x: float = fmod(float(i) * 137.0, LOGICAL.x)
		var y: float = fmod(float(i) * 71.0, LOGICAL.y)
		var col: Color = Color("#4a3f7a") if (i + frame) % 6 != 0 else Color.WHITE
		_canvas.draw_rect(Rect2(x, y, 2.0, 2.0), col)
	var tw: float = 700.0
	var th: float = round(700.0 * 292.0 / 935.0)
	_canvas.draw_texture_rect(_banner, Rect2((LOGICAL.x - tw) / 2.0, 40.0, tw, th), false)
	_canvas.draw_string_outline(_font, Vector2(0, 300 + 7), "THE VIDEO GAME", HORIZONTAL_ALIGNMENT_CENTER, LOGICAL.x, 20, 6, Color.BLACK)
	_canvas.draw_string(_font, Vector2(0, 300 + 7), "THE VIDEO GAME", HORIZONTAL_ALIGNMENT_CENTER, LOGICAL.x, 20, Color("#ffd166"))
	for i in range(TITLE_FIGHTERS.size()):
		var tex: Texture2D = _textures["fighter_" + TITLE_FIGHTERS[i]]
		var sc: float = 0.9
		var w: float = float(tex.get_width()) * sc
		var h: float = float(tex.get_height()) * sc
		var x: float = 68.0 + float(i) * 137.0
		var dir: float = -1.0 if i % 2 == 1 else 1.0
		_canvas.draw_set_transform(Vector2(x, 510.0 - h / 2.0), 0.0, Vector2(dir, 1.0))
		_canvas.draw_texture_rect(tex, Rect2(-w / 2.0, -h / 2.0, w, h), false)
		_canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if int(floor(title_t * 2.0)) % 2 == 0:
		_canvas.draw_string(_font, Vector2(0, 362 + 8), "PRESS START", HORIZONTAL_ALIGNMENT_CENTER, LOGICAL.x, 22, Color.WHITE)
	_canvas.draw_string(_font, Vector2(0, 525 + 4), "(C) JI SLOP", HORIZONTAL_ALIGNMENT_CENTER, LOGICAL.x, 10, Color("#8a7fb0"))


# --- flow -------------------------------------------------------------------

func _process(delta: float) -> void:
	shake = maxf(0.0, shake - delta * 2.0)
	for s in _snow:
		s["y"] = float(s["y"]) + float(s["v"]) * delta
		s["x"] = float(s["x"]) + sin(float(s["y"]) * 0.02) * 0.3
		if float(s["y"]) > LOGICAL.y:
			s["y"] = -4.0
			s["x"] = _rng.randf() * LOGICAL.x
	if phase == "logo":
		logo_t += delta
		if not _splat_spawned and logo_t >= 1.6:
			_splat_spawned = true
			_spawn_splat()
			shake = 0.6
		_update_logo(delta)
		if logo_t > LOGO_END:
			_start_brady()
	elif phase == "brady":
		brady_t += delta
		_update_brady(delta)
		if brady_t > BRADY_END:
			_start_title()
	elif phase == "title":
		title_t += delta
	_apply_shake()
	if _canvas != null:
		_canvas.queue_redraw()


func _apply_shake() -> void:
	var offset: Vector2 = Vector2.ZERO
	if shake > 0.0:
		offset = Vector2((_rng.randf() - 0.5) * shake * 24.0, (_rng.randf() - 0.5) * shake * 24.0)
	_logo_layer.position = offset
	_canvas.position = offset


func _start_brady() -> void:
	phase = "brady"
	brady_t = 0.0
	brady_last.fill(-1)
	_logo_bg.visible = false
	_logo_layer.visible = false
	_canvas.visible = true


func _start_title() -> void:
	phase = "title"
	title_t = 0.0
	_canvas.visible = true


func _skip_to_title() -> void:
	if phase == "logo" or phase == "brady":
		_start_title()


func _input(event: InputEvent) -> void:
	var pressed: bool = (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventJoypadButton and event.pressed)
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	if phase == "title":
		finished.emit()
	else:
		_skip_to_title()


func _fit_to_viewport() -> void:
	size = get_viewport_rect().size
	if _letterbox != null:
		_letterbox.size = size
	_layout()


func _layout() -> void:
	var s: float = minf(size.x / LOGICAL.x, size.y / LOGICAL.y)
	if s <= 0.0:
		return
	_stage.scale = Vector2(s, s)
	_stage.position = (size - LOGICAL * s) * 0.5
