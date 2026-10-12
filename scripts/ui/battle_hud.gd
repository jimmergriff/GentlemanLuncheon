extends Control
class_name BattleHud

const UI_THEME: Theme = preload("res://resources/fury_poster_theme.tres")
const MENU_BUTTON_FOCUS_FONT_COLOR: Color = Color(0.172549, 0.0470588, 0.0392157, 1.0)

@onready var top_row: Control = $TopRow
@onready var center_core: Control = $CenterCore
@onready var center_banner: Panel = $CenterCore/Banner
@onready var center_label: Label = $CenterCore/Banner/Label
@onready var help_strip: Panel = $BottomHelp
@onready var help_label: Label = $BottomHelp/Label

var _slot_roots: Array[Panel] = []
var _slot_contents: Array[HBoxContainer] = []
var _slot_avatar_frames: Array[Panel] = []
var _slot_meta_boxes: Array[VBoxContainer] = []
var _slot_name_labels: Array[Label] = []
var _slot_avatar_rects: Array[TextureRect] = []
var _slot_hp_bars: Array[ProgressBar] = []
var _active_slot_indices: Array[int] = [0, 2]
var _banner_is_result: bool = false


func _ready() -> void:
	theme = UI_THEME
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slot_roots = [
		$TopRow/PlayerLeft,
		$TopRow/PlayerLeftSupport,
		$TopRow/PlayerRight,
		$TopRow/PlayerRightSupport,
	]
	for slot_root in _slot_roots:
		_build_slot_widgets(slot_root)
	center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_apply_surface_styles()
	configure_slots(0)
	_apply_layout()
	set_process(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()


func configure_slots(slot_count: int) -> void:
	var clamped_count: int = clampi(slot_count, 0, _slot_roots.size())
	match clamped_count:
		0:
			_active_slot_indices = []
		1:
			_active_slot_indices = [0]
		2:
			_active_slot_indices = [0, 2]
		3:
			_active_slot_indices = [0, 2, 3]
		_:
			_active_slot_indices = [0, 1, 2, 3]

	for i in range(_slot_roots.size()):
		var slot_visible: bool = _active_slot_indices.has(i)
		_slot_roots[i].visible = slot_visible
		if slot_visible:
			_slot_roots[i].modulate = Color.WHITE
		else:
			_slot_name_labels[i].text = ""
			_slot_avatar_rects[i].texture = null
			_slot_hp_bars[i].value = 0.0

	_apply_layout()


func set_slot_name(slot_index: int, text: String, tint: Color) -> void:
	var resolved_index: int = _resolve_slot_index(slot_index)
	if resolved_index == -1:
		return
	_slot_name_labels[resolved_index].text = text
	_slot_name_labels[resolved_index].add_theme_color_override("font_color", tint)


func set_slot_avatar(slot_index: int, texture: Texture2D) -> void:
	var resolved_index: int = _resolve_slot_index(slot_index)
	if resolved_index == -1:
		return
	_slot_avatar_rects[resolved_index].texture = texture


func set_slot_hp(slot_index: int, current_hp: int, max_hp: int) -> void:
	var resolved_index: int = _resolve_slot_index(slot_index)
	if resolved_index == -1:
		return
	var bar: ProgressBar = _slot_hp_bars[resolved_index]
	var safe_max_hp: int = maxi(max_hp, 1)
	bar.max_value = safe_max_hp
	bar.value = clampi(current_hp, 0, safe_max_hp)


func set_slot_defeated(slot_index: int, defeated: bool) -> void:
	var resolved_index: int = _resolve_slot_index(slot_index)
	if resolved_index == -1:
		return
	_slot_roots[resolved_index].modulate = Color(0.72, 0.52, 0.52, 0.95) if defeated else Color.WHITE


func set_center_text(text: String) -> void:
	_banner_is_result = false
	center_label.text = text
	center_label.add_theme_color_override("font_color", Color(1.0, 0.94902, 0.862745, 1.0))
	center_banner.add_theme_stylebox_override("panel", _make_banner_style(false))


func show_result_banner(text: String) -> void:
	_banner_is_result = true
	center_label.text = text
	center_label.add_theme_color_override("font_color", MENU_BUTTON_FOCUS_FONT_COLOR)
	center_banner.add_theme_stylebox_override("panel", _make_banner_style(true))


func set_help_text(text: String) -> void:
	help_label.text = text


func _apply_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var scale: float = clampf(
		minf(viewport_size.x / 800.0, viewport_size.y / 600.0),
		0.85,
		1.6
	)
	var margin: float = 18.0 * scale
	var slot_width: float = clampf(viewport_size.x * 0.28, 230.0 * scale, 320.0 * scale)
	var slot_height: float = clampf(viewport_size.y * 0.085, 56.0 * scale, 82.0 * scale)
	var slot_gap: float = 10.0 * scale
	var stack_height: float = (slot_height * 2.0) + slot_gap
	_place_control(top_row, Vector2(margin, 14.0 * scale), Vector2(viewport_size.x - (margin * 2.0), stack_height))

	var left_x: float = 0.0
	var right_x: float = top_row.size.x - slot_width
	_place_control(_slot_roots[0], Vector2(left_x, 0.0), Vector2(slot_width, slot_height))
	_place_control(_slot_roots[1], Vector2(left_x, slot_height + slot_gap), Vector2(slot_width, slot_height))
	_place_control(_slot_roots[2], Vector2(right_x, 0.0), Vector2(slot_width, slot_height))
	_place_control(_slot_roots[3], Vector2(right_x, slot_height + slot_gap), Vector2(slot_width, slot_height))
	_apply_slot_content_layout(scale, slot_height)

	var center_width: float = clampf(
		viewport_size.x * (0.34 if _banner_is_result else 0.22),
		(260.0 if _banner_is_result else 170.0) * scale,
		(420.0 if _banner_is_result else 240.0) * scale
	)
	var center_height: float = clampf(
		(72.0 if _banner_is_result else 52.0) * scale,
		56.0 if _banner_is_result else 44.0,
		90.0 if _banner_is_result else 62.0
	)
	_place_control(
		center_core,
		Vector2((viewport_size.x - center_width) * 0.5, (16.0 if _banner_is_result else 10.0) * scale),
		Vector2(center_width, center_height)
	)
	_place_control(center_banner, Vector2.ZERO, center_core.size)
	_place_control(
		center_label,
		Vector2((18.0 if _banner_is_result else 12.0) * scale, (10.0 if _banner_is_result else 7.0) * scale),
		Vector2(center_core.size.x - ((36.0 if _banner_is_result else 24.0) * scale), center_core.size.y - ((20.0 if _banner_is_result else 14.0) * scale))
	)
	center_label.add_theme_font_size_override("font_size", int(roundf(clampf((24.0 if _banner_is_result else 17.0) * scale, 16.0, 28.0))))

	var help_height: float = clampf(36.0 * scale, 34.0, 48.0)
	_place_control(help_strip, Vector2(20.0 * scale, viewport_size.y - help_height - (16.0 * scale)), Vector2(viewport_size.x - (40.0 * scale), help_height))
	_place_control(help_label, Vector2(12.0 * scale, 6.0 * scale), Vector2(help_strip.size.x - (24.0 * scale), help_strip.size.y - (12.0 * scale)))
	help_label.add_theme_font_size_override("font_size", int(roundf(clampf(18.0 * scale, 15.0, 20.0))))

	if _banner_is_result:
		center_banner.add_theme_stylebox_override("panel", _make_banner_style(true))
	else:
		center_banner.add_theme_stylebox_override("panel", _make_banner_style(false))


func _build_slot_widgets(slot_root: Panel) -> void:
	slot_root.theme = UI_THEME
	slot_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var content: HBoxContainer = HBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_left = 12.0
	content.offset_top = 10.0
	content.offset_right = -12.0
	content.offset_bottom = -10.0
	content.add_theme_constant_override("separation", 12)

	var avatar_frame: Panel = Panel.new()
	avatar_frame.theme = UI_THEME
	avatar_frame.custom_minimum_size = Vector2(52.0, 52.0)
	avatar_frame.add_theme_stylebox_override("panel", _make_avatar_frame_style())

	var avatar: TextureRect = TextureRect.new()
	avatar.anchor_right = 1.0
	avatar.anchor_bottom = 1.0
	avatar.offset_left = 6.0
	avatar.offset_top = 6.0
	avatar.offset_right = -6.0
	avatar.offset_bottom = -6.0
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_frame.add_child(avatar)

	var meta: VBoxContainer = VBoxContainer.new()
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.add_theme_constant_override("separation", 4)

	var name_label: Label = Label.new()
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 18)

	var hp_bar: ProgressBar = ProgressBar.new()
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.custom_minimum_size = Vector2(0.0, 16.0)
	hp_bar.show_percentage = false
	hp_bar.add_theme_stylebox_override("background", _make_hp_bar_background())
	hp_bar.add_theme_stylebox_override("fill", _make_hp_bar_fill())

	meta.add_child(name_label)
	meta.add_child(hp_bar)
	content.add_child(avatar_frame)
	content.add_child(meta)
	slot_root.add_child(content)

	_slot_contents.append(content)
	_slot_avatar_frames.append(avatar_frame)
	_slot_meta_boxes.append(meta)
	_slot_name_labels.append(name_label)
	_slot_avatar_rects.append(avatar)
	_slot_hp_bars.append(hp_bar)


func _apply_surface_styles() -> void:
	for slot_root in _slot_roots:
		slot_root.add_theme_stylebox_override("panel", _make_slot_style())
	center_banner.add_theme_stylebox_override("panel", _make_banner_style(false))
	help_strip.add_theme_stylebox_override("panel", _make_help_style())


func _resolve_slot_index(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= _active_slot_indices.size():
		return -1
	return _active_slot_indices[slot_index]


func _place_control(node: Control, position: Vector2, control_size: Vector2) -> void:
	node.position = position
	node.size = control_size


func _apply_slot_content_layout(scale: float, slot_height: float) -> void:
	var horizontal_padding: float = clampf(12.0 * scale, 8.0, 14.0)
	var vertical_padding: float = clampf(6.0 * scale, 4.0, 8.0)
	var content_gap: float = clampf(10.0 * scale, 8.0, 12.0)
	var avatar_size: float = clampf(slot_height - (vertical_padding * 2.0), 38.0 * scale, 52.0 * scale)
	var avatar_inset: float = clampf(5.0 * scale, 4.0, 6.0)
	var meta_gap: float = clampf(3.0 * scale, 2.0, 4.0)
	var name_font_size: int = int(roundf(clampf(16.0 * scale, 13.0, 18.0)))
	var hp_bar_height: float = roundf(clampf(14.0 * scale, 11.0, 16.0))

	for i in range(_slot_contents.size()):
		var content: HBoxContainer = _slot_contents[i]
		content.offset_left = horizontal_padding
		content.offset_top = vertical_padding
		content.offset_right = -horizontal_padding
		content.offset_bottom = -vertical_padding
		content.add_theme_constant_override("separation", int(roundf(content_gap)))

		var avatar_frame: Panel = _slot_avatar_frames[i]
		avatar_frame.custom_minimum_size = Vector2(avatar_size, avatar_size)

		var avatar: TextureRect = _slot_avatar_rects[i]
		avatar.offset_left = avatar_inset
		avatar.offset_top = avatar_inset
		avatar.offset_right = -avatar_inset
		avatar.offset_bottom = -avatar_inset

		var meta: VBoxContainer = _slot_meta_boxes[i]
		meta.add_theme_constant_override("separation", int(roundf(meta_gap)))

		var name_label: Label = _slot_name_labels[i]
		name_label.add_theme_font_size_override("font_size", name_font_size)

		var hp_bar: ProgressBar = _slot_hp_bars[i]
		hp_bar.custom_minimum_size = Vector2(0.0, hp_bar_height)


func _make_slot_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.141176, 0.0352941, 0.027451, 0.94)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(1.0, 0.545098, 0.301961, 0.92)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0.0, 4.0)
	return style


func _make_avatar_frame_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.231373, 0.0705882, 0.054902, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.996078, 0.772549, 0.411765, 0.95)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style


func _make_hp_bar_background() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.235294, 0.0901961, 0.0705882, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 0.909804, 0.776471, 0.82)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_right = 7
	style.corner_radius_bottom_left = 7
	return style


func _make_hp_bar_fill() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.545098, 0.301961, 1.0)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style


func _make_banner_style(is_result: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.content_margin_left = 16.0
	style.content_margin_top = 12.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 12.0
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0.0, 4.0)
	if is_result:
		style.bg_color = Color(0.996078, 0.772549, 0.411765, 1.0)
		style.border_color = Color(1.0, 0.545098, 0.301961, 1.0)
	else:
		style.bg_color = Color(0.121569, 0.0352941, 0.027451, 0.94)
		style.border_color = Color(0.996078, 0.772549, 0.411765, 0.96)
	return style


func _make_help_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.109804, 0.0313726, 0.0235294, 0.88)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.545098, 0.301961, 0.9)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	return style

