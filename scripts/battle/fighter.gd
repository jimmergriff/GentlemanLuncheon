extends Node2D
class_name Fighter

signal hp_changed(current_hp: int, max_hp: int)
signal defeated(fighter: Fighter)

const GRAVITY: float = 1500.0
const JUMP_SPEED: float = 500.0
const WALK_X_SPEED: float = 90.0
const WALK_Y_SPEED: float = 45.0
const RUN_SPEED: float = 300.0
const FLOOR_FRICTION: float = 2200.0
const AIR_FRICTION: float = 180.0
const DOUBLE_TAP_WINDOW: float = 0.25
const READY_TIME: float = 1.0
const DOWNED_TIME: float = 0.9
const RIDE_HIT_DOWNED_TIME: float = 0.72
const LANDED_INPUT_TIME: float = 0.18
const HITSTUN_TIME: float = 0.28
const ATTACK_FALLBACK_X: float = 78.0
const ATTACK_FALLBACK_Y: float = 26.0
const ATTACK_FALLBACK_Z: float = 52.0
const HITBOX_EXPAND_X: float = 8.0
const HITBOX_EXPAND_Y: float = 6.0
const HITBOX_EXPAND_Z: float = 8.0
const XSPEED_SPINHIT: float = 600.0
const ZSPEED_SPINHIT: float = 200.0
const ZACC_SPINHIT: float = 550.0
const ZSPEED_JUMP_SPINKICK: float = 900.0
const ZACC_JUMP_SPINKICK_ASCEND: float = 3250.0
const ZACC_JUMP_SPINKICK_DESCEND: float = 4700.0
const XSPEED_SPINHIT_2: float = 300.0
const ZSPEED_SPINHIT_2: float = 550.0
const ZACC_SPINHIT_2: float = 1000.0
const XSPEED_BOMBKICK: float = 800.0
const ZSPEED_BOMBKICK: float = 200.0
const ZACC_BOMBKICK: float = 800.0
const ZSPEED_HUG_JUMP: float = 400.0
const ZACC_HUG_JUMP: float = 1000.0
const XSPEED_SKILL_BOUNCE: float = 100.0
const ZSPEED_SKILL_BOUNCE: float = 100.0
const ZACC_SKILL_BOUNCE: float = 500.0
const XSPEED_X_HIT_FLY: float = 500.0
const ZSPEED_XB_HIT_FLY: float = 300.0
const ZSPEED_XF_HIT_FLY: float = 800.0
const XSPEED_X_HIT_FLY2: float = 100.0
const ZSPEED_XF_HIT_FLY2: float = 200.0
const ZACC_XF_HIT_FLY2: float = 1000.0
const XSPEED_HIT_FLY: float = 200.0
const ZSPEED_HIT_FLY: float = 600.0
const XSPEED_S_HIT_FLY: float = 500.0
const ZSPEED_S_HIT_FLY: float = 200.0
const ZACC_S_HIT_FLY: float = 1000.0
const XSPEED_BE_PUSH: float = 100.0
const ZSPEED_BE_PUSH: float = 100.0
const ZSPEED_SPIN_DRILL: float = 1400.0
const ZACC_SPIN_DRILL: float = 2000.0
const XSPEED_SPIN_DRILL_BOUNCE: float = 150.0
const ZSPEED_SPIN_DRILL_BOUNCE: float = 550.0
const ZACC_SPIN_DRILL_BOUNCE: float = 1500.0
const XSPEED_THROWUP_FLY: float = 400.0
const XSPEED_THROWDOWN_FLY: float = 1000.0
const ZSPEED_THROWUP_FLY: float = 500.0
const ZSPEED_THROWDOWN_FLY: float = 1000.0
const ZACC_THROWUP_FLY: float = 2000.0
const ZACC_THROWDOWN_FLY: float = 2000.0
const BE_THROW_DOWNED_TIME: float = 2.0
const BE_LIFT_REST_TIME: float = 4.5
const SHORT_REST_TIME: float = 2.0
const LONG_REST_TIME: float = 3.0
const WEAK_RUN_TIME: float = 2.5
const ATTACK_CHAIN_REST_THRESHOLD: int = 4
const SHADOW_TEXTURE: Texture2D = preload("res://assets/extracted/main/shadow.png")

const SFX_PATHS: Dictionary = {
	"attack": "res://assets/audio/bgm/attack.wav",
	"hit": "res://assets/audio/bgm/hit.wav",
	"hit_fly": "res://assets/audio/bgm/hit_fly.wav",
	"jump": "res://assets/audio/bgm/jump.wav",
	"catch": "res://assets/audio/bgm/catch.wav",
	"final_blow": "res://assets/audio/bgm/final_blow.wav",
	"knock_ground": "res://assets/audio/bgm/knockGround.wav",
	"lost": "res://assets/audio/bgm/lost.wav",
}
static var _sfx_cache: Dictionary = {}

const BASE_SKILLS: Array[String] = [
	"a_finalblow",
	"b_finalblow",
	"defense",
	"a_attack",
	"b_attack",
	"jump",
	"jump_a_attack",
	"jump_b_attack",
	"sprint_a_attack",
	"sprint_b_attack",
	"sprint_jump_a_attack",
	"sprint_jump_b_attack",
	"a_lift",
	"b_lift",
	"a_throw",
	"b_throw",
	"jump_elbow",
	"jump_tread",
	"ride",
	"ride_a_attack",
	"ride_b_attack",
	"catch",
	"push",
]

const NORMAL_ATTACK_STATES := [
	"ready",
	"stance",
	"walk",
	"defense",
]

const AIR_ATTACK_STATES := [
	"jump",
	"sjump",
	"fall",
	"ride_jump",
	"jsquat",
	"ssquat",
	"aj_attack",
	"bj_attack",
	"maj_attack",
	"mbj_attack",
	"asj_attack",
	"bsj_attack",
	"jump_elbow",
	"jump_stomp",
	"spinhit",
	"kick",
	"big_elbow",
	"guillotine",
	"bombkick",
	"lift_jump",
	"lift_fall",
]

const DEFENSE_STATES := [
	"defense",
	"solid_defense",
	"be_lift_defense",
	"be_lift_solid_defense",
]

const STATE_ACTION_MAP := {
	"start": "start",
	"lying_dying": "lying_dying",
	"tummy_dying": "tummy_dying",
	"ready": "ready",
	"be_lift_stance": "stance",
	"stance": "stance",
	"walk": "walk",
	"leftrun": "run",
	"rightrun": "run",
	"defense": "defense",
	"be_lift_defense": "defense",
	"solid_defense": "solid_defense",
	"be_lift_solid_defense": "solid_defense",
	"a_attack": "a_attack",
	"be_lift_a_attack": "a_attack",
	"b_attack": "b_attack",
	"be_lift_b_attack": "b_attack",
	"mach_a_attack": "mach_a_attack",
	"be_lift_mach_a_attack": "mach_a_attack",
	"mach_b_attack": "mach_b_attack",
	"be_lift_mach_b_attack": "mach_b_attack",
	"as_attack": "as_attack",
	"bs_attack": "bs_attack",
	"asj_attack": "asj_attack",
	"bsj_attack": "bsj_attack",
	"aj_attack": "aj_attack",
	"bj_attack": "bj_attack",
	"maj_attack": "jump_mach_a_attack",
	"mbj_attack": "jump_mach_b_attack",
	"final_blow": "final_blow",
	"squat": "squat",
	"be_lift_squat": "squat",
	"lift_squat": "squat",
	"jump_done": "squat",
	"jump": "jump",
	"sjump": "jump",
	"fall": "fall",
	"ride_jump": "fall",
	"jsquat": "squat",
	"ssquat": "squat",
	"hit": "hit",
	"hit_fly": "hit_fly",
	"hit_fly_fall": "hit_fly_fall",
	"lying": "lying",
	"be_lift_lying": "lying",
	"lying_hit": "lying_hit",
	"be_lift_lying_hit": "lying_hit",
	"tummy_hit_fly": "tummy_hit_fly",
	"tummy": "tummy",
	"be_lift_tummy": "tummy",
	"tummy_hit": "tummy_hit",
	"be_lift_tummy_hit": "tummy_hit",
	"rest": "rest",
	"roll_down": "roll_down",
	"roll_up": "roll_up",
	"f_roll": "f_roll",
	"b_roll": "b_roll",
	"kick": "kick",
	"spinhit": "spinhit",
	"bombkick": "bombkick",
	"mach_stomp": "mach_stomp",
	"jump_elbow": "jump_elbow",
	"jump_stomp": "jump_stomp",
	"big_elbow": "jump_elbow",
	"guillotine": "guillotine",
	"weak_run": "weak_run",
	"weak_run_attack": "weak_run",
	"catch": "catch",
	"be_catch": "be_catch",
	"back_be_catch": "back_be_catch",
	"catch_skill_fa": "catch_skill_fa",
	"catch_skill_ba": "catch_skill_ba",
	"catch_skill_bb": "catch_skill_bb",
	"catch_skill_fb": "catch_skill_fb",
	"be_push": "be_push",
	"half_lying": "half_lying",
	"half_stance": "half_stance",
	"throw": "throw",
	"lift_stance": "lift_stance",
	"lift_walk": "lift_walk",
	"lift_run": "lift_run",
	"lift_jump": "lift_jump",
	"lift_fall": "lift_fall",
	"ride": "ride",
	"ride_attack": "ride_attack",
}

@onready var shadow: Sprite2D = $Shadow
@onready var visual: Sprite2D = $Visual

var control_mode: String = "human"
var control_prefix: String = "p1"
var ai_difficulty: String = "normal"
var team_id: int = -1  # -1 = free-for-all, 0/1 = team
var role_data: Dictionary = {}
var actions: Dictionary = {}
var opponents: Array[Fighter] = []
var battle_rect: Rect2 = Rect2(0.0, 0.0, 1240.0, 242.0)
var ground_position: Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO
var z_height: float = 0.0
var facing: int = 1

var current_state: String = "stance"
var current_action: String = "stance"
var current_frames: Array = []
var current_frame_index: int = 0
var current_frame_elapsed: float = 0.0
var current_frame_data: Dictionary = {}
var current_attack_name: String = ""
var _attack_sfx_hit_count: int = 0
var pending_state_on_descend: String = ""
var linked_fighter: Fighter = null
var skill_target: Fighter = null
var link_mode: String = ""
var catch_hold_timer: float = 0.0
var role_skill_event_frame: int = -1
var role_skill_timer: float = 0.0
var airborne_script: String = ""
var airborne_script_source: Fighter = null
var pending_throw_attacker: Fighter = null

var lock_action: bool = false
var lock_motion: bool = false
var hitstun: float = 0.0
var invulnerable_time: float = 0.0
var ready_timer: float = 0.0
var downed_timer: float = 0.0
var rest_timer: float = 0.0
var be_throw_stand_timer: float = 0.0
var be_lift_stand_timer: float = 0.0
var special_state_timer: float = 0.0
var landed_recent: float = 0.0
var sprint_attack_decel: float = 0.0
var sprint_recovery_timer: float = 0.0
var attack_chain_count: int = 0
var attack_chain_timeout: float = 0.0
var mach_stomp_loops_left: int = 0
var state_script_timer: float = 0.0
var pending_landing_state: String = ""
var return_to_be_lift_stance_after_attack: bool = false
var buffer_unlock_after_motion: bool = false
var hp: int = 1
var max_hp: int = 1
var last_damage_attack_name: String = ""

var texture_cache: Dictionary = {}
var hit_targets: Dictionary = {}
var enabled_skills: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var control_run: bool = false
var control_left_motion: bool = false
var control_right_motion: bool = false
var control_up_motion: bool = false
var control_down_motion: bool = false
var control_a_attack: bool = false
var control_b_attack: bool = false
var control_jump: bool = false
var control_defense: bool = false

var last_left_tap: float = -10.0
var last_right_tap: float = -10.0
var elapsed_time: float = 0.0

var ai_timer: float = 0.0
var story_profile: Dictionary = {}
var _story_windup_t: float = 0.0
var _story_cool_t: float = 0.0
var ai_action: String = "observe"
var _sfx_action: AudioStreamPlayer = null
var _sfx_react: AudioStreamPlayer = null


func _ready() -> void:
	rng.randomize()
	_sfx_action = AudioStreamPlayer.new()
	_sfx_action.bus = "Master"
	add_child(_sfx_action)
	_sfx_react = AudioStreamPlayer.new()
	_sfx_react.bus = "Master"
	add_child(_sfx_react)
	shadow.texture = SHADOW_TEXTURE
	shadow.position = Vector2(0.0, 8.0)
	shadow.z_index = -1
	shadow.modulate = Color(0.0, 0.0, 0.0, 0.9)
	shadow.scale = Vector2(1.5, 0.78)


static func _load_sfx(key: String) -> AudioStream:
	if _sfx_cache.has(key):
		return _sfx_cache[key] as AudioStream
	var path: String = SFX_PATHS.get(key, "")
	if path.is_empty():
		return null
	var stream: AudioStream = load(path) as AudioStream
	if stream != null:
		_sfx_cache[key] = stream
	return stream


func _play_sfx(key: String, use_react: bool = false) -> void:
	var stream: AudioStream = _load_sfx(key)
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_react if use_react else _sfx_action
	player.stream = stream
	player.play()


func setup(config: Dictionary, stage_rect: Rect2, mode: String, prefix: String) -> void:
	role_data = config
	actions = config.get("actions", {})
	control_mode = mode
	control_prefix = prefix
	battle_rect = stage_rect
	story_profile = config.get("ai", {})
	max_hp = int(role_data.get("stats", {}).get("max_hp", 1000))
	hp = max_hp
	last_damage_attack_name = ""
	_init_skills()
	_set_state(String(role_data.get("default_action", "stance")), true)
	hp_changed.emit(hp, max_hp)


func set_spawn_position(world_position: Vector2) -> void:
	ground_position = world_position
	_sync_scene_position()


func set_opponents(values: Array[Fighter]) -> void:
	opponents = values


func get_hp_ratio() -> float:
	if max_hp <= 0:
		return 0.0
	return float(hp) / float(max_hp)


func is_defeated() -> bool:
	return hp <= 0


func _physics_process(delta: float) -> void:
	if actions.is_empty():
		return
	elapsed_time += delta
	hitstun = maxf(hitstun - delta, 0.0)
	invulnerable_time = maxf(invulnerable_time - delta, 0.0)
	ready_timer = maxf(ready_timer - delta, 0.0)
	downed_timer = maxf(downed_timer - delta, 0.0)
	rest_timer = maxf(rest_timer - delta, 0.0)
	be_throw_stand_timer = maxf(be_throw_stand_timer - delta, 0.0)
	be_lift_stand_timer = maxf(be_lift_stand_timer - delta, 0.0)
	special_state_timer = maxf(special_state_timer - delta, 0.0)
	landed_recent = maxf(landed_recent - delta, 0.0)
	sprint_recovery_timer = maxf(sprint_recovery_timer - delta, 0.0)
	ai_timer = maxf(ai_timer - delta, 0.0)
	catch_hold_timer = maxf(catch_hold_timer - delta, 0.0)
	role_skill_timer = maxf(role_skill_timer - delta, 0.0)
	attack_chain_timeout = maxf(attack_chain_timeout - delta, 0.0)
	state_script_timer = maxf(state_script_timer - delta, 0.0)
	if attack_chain_timeout <= 0.0 and attack_chain_count > 0:
		attack_chain_count = 0
	_update_be_throw_recovery()
	_update_be_lift_recovery()

	if is_defeated():
		_update_animation(delta)
		_simulate_vertical(delta)
		_sync_scene_position()
		return

	if link_mode.begins_with("target_") and link_mode != "target_lift":
		if link_mode == "target_ride" and downed_timer <= 0.0 and state_script_timer <= 0.0 and not is_defeated():
			_start_stand()
			_update_animation(delta)
			_sync_scene_position()
			return
		_update_animation(delta)
		_sync_scene_position()
		return

	if control_mode == "cpu":
		_update_ai()
	elif control_mode == "dummy":
		control_left_motion = false
		control_right_motion = false
		control_up_motion = false
		control_down_motion = false
		control_a_attack = false
		control_b_attack = false
		control_jump = false
		control_defense = false
		control_run = false
	else:
		_sync_key_control()

	_update_facing()
	_sync_data()
	_update_motion(delta)
	_update_sprint_attack_state()
	_update_special_state()
	_simulate_vertical(delta)
	_update_jump_touch()
	_update_common_lift_jump_state()
	_update_linked_state(delta)
	_update_animation(delta)
	_update_role_skill_state()
	_update_throw_body_hits()
	_update_weak_run_attack_hits()
	if _frame_has_attack_box():
		_try_attack()
	_sync_scene_position()

	if downed_timer <= 0.0 and be_throw_stand_timer <= 0.0 and current_state == "lying" and not is_defeated():
		_start_stand()
	if rest_timer <= 0.0 and current_state == "rest" and not is_defeated():
		attack_chain_count = 0
		attack_chain_timeout = 0.0
		_set_ready()
	if catch_hold_timer <= 0.0 and current_state == "catch" and linked_fighter != null:
		_finish_catch_timeout()


func _init_skills() -> void:
	enabled_skills.clear()
	for skill_id in BASE_SKILLS:
		enabled_skills[skill_id] = true
	var role_skills: Array = role_data.get("skills", [])
	for entry in role_skills:
		var skill_name: String = String(entry)
		enabled_skills[skill_name] = true
		if skill_name == "mach_a_attack":
			enabled_skills["jump_mach_a_attack"] = true
		elif skill_name == "mach_b_attack":
			enabled_skills["jump_mach_b_attack"] = true
	match String(role_data.get("player_type", "")):
		"fighter":
			enabled_skills["hug_front_put"] = true
			enabled_skills["hug_back_put"] = true
		"martial_artist":
			enabled_skills["elbow"] = true
			enabled_skills["kneehit"] = true
		"kung_fu":
			enabled_skills["hug_jump"] = true
			enabled_skills["lift_jump"] = true
		"judo_master":
			enabled_skills["judo"] = true
			enabled_skills["back_judo"] = true
		"tiger":
			enabled_skills["spin_drill"] = true


func _sync_key_control() -> void:
	control_left_motion = Input.is_action_pressed("%s_left" % control_prefix)
	control_right_motion = Input.is_action_pressed("%s_right" % control_prefix)
	control_up_motion = Input.is_action_pressed("%s_up" % control_prefix)
	control_down_motion = Input.is_action_pressed("%s_down" % control_prefix)
	control_defense = Input.is_action_pressed("%s_defend" % control_prefix)

	var now: float = elapsed_time
	if Input.is_action_just_pressed("%s_left" % control_prefix):
		if sprint_recovery_timer <= 0.0 and now - last_left_tap <= DOUBLE_TAP_WINDOW:
			control_run = true
		last_left_tap = now
	if Input.is_action_just_pressed("%s_right" % control_prefix):
		if sprint_recovery_timer <= 0.0 and now - last_right_tap <= DOUBLE_TAP_WINDOW:
			control_run = true
		last_right_tap = now

	control_a_attack = Input.is_action_just_pressed("%s_attack_a" % control_prefix)
	control_b_attack = Input.is_action_just_pressed("%s_attack_b" % control_prefix)
	control_jump = Input.is_action_just_pressed("%s_jump" % control_prefix)

	if not control_left_motion and not control_right_motion and not ["leftrun", "rightrun", "sjump", "ssquat", "as_attack", "bs_attack"].has(current_state):
		control_run = false
	elif sprint_recovery_timer > 0.0:
		control_run = false


func _update_story_ai(target: Fighter) -> void:
	control_left_motion = false
	control_right_motion = false
	control_up_motion = false
	control_down_motion = false
	control_a_attack = false
	control_b_attack = false
	control_jump = false
	control_defense = false
	control_run = false
	var delta: float = get_physics_process_delta_time()
	_story_cool_t = maxf(_story_cool_t - delta, 0.0)
	var dx: float = target.ground_position.x - ground_position.x
	var dy: float = target.ground_position.y - ground_position.y
	var reach: float = float(story_profile.get("range", 110.0))
	var in_range: bool = absf(dx) <= reach and absf(dy) <= 24.0
	if not in_range:
		_story_windup_t = 0.0
		_set_ai_horizontal(dx)
		_set_ai_vertical(dy)
		return
	if _story_cool_t > 0.0 or not (current_state in ["stance", "walk", "ready"]):
		return
	_story_windup_t += delta
	if _story_windup_t < float(story_profile.get("windup", 0.5)):
		ai_action = "windup"
		return
	control_a_attack = true
	_story_windup_t = 0.0
	_story_cool_t = float(story_profile.get("cooldown", 1.5)) * rng.randf_range(0.85, 1.15)


func _update_ai() -> void:
	control_left_motion = false
	control_right_motion = false
	control_up_motion = false
	control_down_motion = false
	control_a_attack = false
	control_b_attack = false
	control_jump = false
	control_defense = false

	var aggression_scale: float = 1.0
	var punish_scale: float = 1.0
	var defense_scale: float = 1.0
	match ai_difficulty:
		"easy":
			aggression_scale = 0.78
			punish_scale = 0.74
			defense_scale = 0.9
		"hard":
			aggression_scale = 1.22
			punish_scale = 1.26
			defense_scale = 1.1

	var target: Fighter = _get_primary_target()
	if target == null or is_defeated():
		control_run = false
		return

	if not story_profile.is_empty():
		_update_story_ai(target)
		return

	var dx: float = target.ground_position.x - ground_position.x
	var dy: float = target.ground_position.y - ground_position.y
	var abs_dx: float = absf(dx)
	var abs_dy: float = absf(dy)
	var lane_threshold: float = 24.0 - (3.0 * (defense_scale - 1.0))
	var on_same_lane: bool = abs_dy <= lane_threshold
	var attack_close: bool = abs_dx <= (128.0 * aggression_scale) and abs_dy <= 30.0
	var walk_close: bool = abs_dx <= (156.0 * aggression_scale) and abs_dy <= 26.0
	var sprint_close: bool = abs_dx <= (210.0 * aggression_scale) and abs_dy <= 30.0
	var target_vulnerable: bool = target.current_state in ["rest", "lying", "lying_hit", "half_lying", "tummy", "tummy_hit"]
	var target_is_resting: bool = target.current_state == "rest"
	var should_space_out: bool = on_same_lane and abs_dx < (54.0 / aggression_scale) and not target_vulnerable

	if current_state == "catch" and linked_fighter != null:
		if _has_skill("hug_front_put") or _has_skill("elbow") or _has_skill("hug_jump") or _has_skill("judo") or _has_skill("spin_drill"):
			control_a_attack = true
		elif _has_skill("hug_back_put") or _has_skill("kneehit") or _has_skill("lift_jump") or _has_skill("back_judo"):
			control_a_attack = true
		else:
			control_b_attack = true
		return
	if _is_in_lift_state() and linked_fighter != null and ai_timer <= 0.0:
		if rng.randf() > 0.5:
			control_a_attack = true
		else:
			control_b_attack = true
		return
	if current_state == "ride" and linked_fighter != null and ai_timer <= 0.0:
		if rng.randf() > 0.35:
			control_a_attack = true
		else:
			control_b_attack = true
		return

	if target_vulnerable:
		if abs_dx > (120.0 / punish_scale) or abs_dy > 16.0:
			control_run = abs_dx > (96.0 / punish_scale)
			_set_ai_horizontal(dx)
			_set_ai_vertical(dy)
			ai_action = "punish_close"
			return
		_set_ai_horizontal(dx)
		if ai_timer <= 0.0:
			if target_is_resting and _get_ground_target() != null:
				if _has_skill("jump_tread"):
					control_b_attack = true
				elif _has_skill("jump_elbow") or _has_skill("mach_stomp"):
					control_a_attack = true
				elif _has_skill("a_finalblow") or _has_skill("b_finalblow"):
					control_a_attack = true
				else:
					control_a_attack = true
			elif ["lying", "lying_hit", "tummy", "tummy_hit", "half_lying"].has(target.current_state):
				if _get_ground_target() != null and _has_skill("mach_stomp"):
					control_a_attack = true
				elif _get_ground_target() != null and _has_skill("jump_tread"):
					control_b_attack = true
				elif _get_ground_target() != null and _has_skill("jump_elbow"):
					control_a_attack = true
				elif _get_lift_target() != null:
					control_a_attack = true
				elif _get_ride_target() != null:
					control_up_motion = true
				else:
					control_a_attack = true
			ai_timer = rng.randf_range(0.08, 0.18) / punish_scale
			ai_action = "ground_punish"
		return

	if current_state in ["sjump", "ssquat"]:
		_set_ai_horizontal(dx)
		if on_same_lane and abs_dx <= 176.0:
			if _has_skill("jump_spinkick") and attack_close and rng.randf() > 0.58:
				control_down_motion = true
			elif _has_skill("sprint_jump_b_attack"):
				control_b_attack = true
			elif _has_skill("sprint_jump_a_attack"):
				control_a_attack = true
			elif _has_skill("jump_mach_a_attack") and rng.randf() > 0.35:
				control_a_attack = true
			elif _has_skill("jump_mach_b_attack") and rng.randf() > 0.35:
				control_b_attack = true
			elif rng.randf() > 0.45:
				control_a_attack = true
			else:
				control_b_attack = true
		return

	if current_state == "jump_done" and attack_close:
		if _has_skill("spinhit") and rng.randf() > 0.25:
			control_a_attack = true
		elif _has_skill("bombkick"):
			control_b_attack = true
		_set_ai_horizontal(dx)
		return

	if velocity.z < -10.0 and attack_close:
		if _has_skill("big_elbow") and rng.randf() > 0.4:
			control_a_attack = true
			return
		if _has_skill("guillotine") and rng.randf() > 0.4:
			control_b_attack = true
			return

	if target.current_state in ["a_attack", "b_attack", "mach_a_attack", "mach_b_attack", "as_attack", "bs_attack", "jump_elbow", "jump_stomp"] and attack_close and rng.randf() > (0.64 - (0.12 * defense_scale)):
		control_defense = true
		ai_action = "guard"
		return

	if should_space_out and ai_timer <= 0.0:
		control_run = true
		_set_ai_escape_direction(target, dx)
		if not control_left_motion and not control_right_motion:
			_set_ai_horizontal(-dx)
		ai_action = "space_out"
		return

	if attack_close and ai_timer <= 0.0:
		if _has_skill("mach_a_attack") and rng.randf() > 0.52:
			control_a_attack = true
		elif _has_skill("mach_b_attack") and rng.randf() > 0.52:
			control_b_attack = true
		elif rng.randf() > 0.44:
			control_a_attack = true
		else:
			control_b_attack = true
		_set_ai_horizontal(dx)
		ai_timer = rng.randf_range(0.18, 0.32) / aggression_scale
		ai_action = "close_attack"
		return

	if sprint_close and on_same_lane and ai_timer <= 0.0 and abs_dx > (88.0 / aggression_scale):
		control_run = true
		_set_ai_horizontal(dx)
		if _has_skill("sprint_jump_b_attack") and rng.randf() > (0.58 - (0.1 * aggression_scale)):
			control_jump = true
			ai_timer = 0.12 / aggression_scale
			ai_action = "sprint_jump"
		elif rng.randf() > (0.5 - (0.08 * aggression_scale)):
			control_b_attack = true
			ai_timer = 0.12 / aggression_scale
			ai_action = "sprint_b"
		else:
			control_a_attack = true
			ai_timer = 0.12 / aggression_scale
			ai_action = "sprint_a"
		return

	if walk_close:
		control_run = false
		_set_ai_horizontal(dx)
		_set_ai_vertical(dy)
		ai_action = "walk_in"
		if on_same_lane and abs_dx > (84.0 / aggression_scale) and abs_dx < (148.0 * aggression_scale) and rng.randf() > (0.88 - (0.08 * aggression_scale)):
			control_jump = true
		return

	if abs_dx > (150.0 / aggression_scale):
		control_run = true
		ai_action = "run_close"
	else:
		control_run = false
		ai_action = "walk_close"
	_set_ai_horizontal(dx)
	_set_ai_vertical(dy)

	if _has_skill("bombkick") and landed_recent > 0.0 and rng.randf() > 0.62:
		control_b_attack = true
	elif _has_skill("spinhit") and landed_recent > 0.0 and rng.randf() > 0.62:
		control_a_attack = true
	elif abs_dx > 96.0 and abs_dx < 164.0 and on_same_lane and rng.randf() > 0.78:
		control_jump = true


func _set_ai_horizontal(dx: float) -> void:
	control_left_motion = false
	control_right_motion = false
	if dx < -8.0:
		control_left_motion = true
	elif dx > 8.0:
		control_right_motion = true


func _set_ai_escape_direction(target: Fighter, dx: float) -> void:
	control_left_motion = false
	control_right_motion = false
	if dx < -8.0:
		control_right_motion = true
		return
	if dx > 8.0:
		control_left_motion = true
		return
	if target != null and target.facing != 0:
		if target.facing < 0:
			control_right_motion = true
		else:
			control_left_motion = true
		return
	if facing < 0:
		control_left_motion = true
	else:
		control_right_motion = true


func _set_ai_vertical(dy: float) -> void:
	control_up_motion = false
	control_down_motion = false
	if dy < -14.0:
		control_up_motion = true
	elif dy > 14.0:
		control_down_motion = true


func _update_facing() -> void:
	var target: Fighter = _get_primary_target()
	if control_mode == "cpu" and target != null and not lock_action:
		var cpu_dx: float = target.ground_position.x - ground_position.x
		if absf(cpu_dx) > 8.0:
			facing = 1 if cpu_dx >= 0.0 else -1
		elif absf(target.ground_position.y - ground_position.y) <= 18.0:
			facing = -target.facing if target.facing != 0 else facing
		return
	if control_left_motion and not lock_action:
		facing = -1
	elif control_right_motion and not lock_action:
		facing = 1


func _sync_data() -> void:
	var stop_xmotion: bool = false
	var stop_ymotion: bool = false

	if control_left_motion:
		_set_left_motion()
	else:
		if control_right_motion:
			_set_right_motion()
		else:
			stop_xmotion = true
			if current_state in ["leftrun", "rightrun"]:
				_stop_run()
			else:
				_stop_x_walk()

	if control_up_motion:
		_set_up_motion()
	else:
		if control_down_motion:
			_set_down_motion()
		else:
			stop_ymotion = true
			if current_state in ["leftrun", "rightrun", "walk", "ready", "stance", "defense", "solid_defense"]:
				_stop_y_motion()

	if stop_xmotion and stop_ymotion and current_state == "walk":
		_set_ready()

	if not _has_any_control() and not DEFENSE_STATES.has(current_state):
		_reset_transient_controls()
		return

	var skill_name: String = _find_runnable_skill()
	if not skill_name.is_empty():
		_run_skill(skill_name)
		_reset_attack_controls()
		return

	_reset_attack_controls()
	if current_state in DEFENSE_STATES and not lock_action and not control_defense:
		lock_motion = false
		_set_ready()


func _set_left_motion() -> void:
	if lock_motion:
		if current_state in ["jump", "sjump", "fall", "ride_jump", "squat", "ssquat", "jump_done", "hit_fly", "hit_fly_fall", "lift_jump", "lift_fall"]:
			facing = -1
		elif current_state == "be_lift_stance":
			facing = -1
		elif current_state == "catch" and linked_fighter != null and linked_fighter.current_state == "back_be_catch":
			facing = -1
			linked_fighter.facing = -1
			_update_catch_alignment()
		return
	var walk_speed: float = WALK_X_SPEED * _speed_scale()
	var run_speed: float = RUN_SPEED * _speed_scale()
	match current_state:
		"lift_stance", "lift_walk":
			facing = -1
			velocity.x = -run_speed if control_run else -walk_speed
			_set_state("lift_run" if control_run else "lift_walk")
		"ready", "stance", "defense", "solid_defense", "walk":
			facing = -1
			velocity.x = -run_speed if control_run else -walk_speed
			if control_run:
				_set_state("leftrun")
			else:
				_set_state("walk")
		"leftrun":
			velocity.x = -run_speed
		"rightrun":
			_stop_run()
		_:
			if z_height > 0.0:
				facing = -1


func _set_right_motion() -> void:
	if lock_motion:
		if current_state in ["jump", "sjump", "fall", "ride_jump", "squat", "ssquat", "jump_done", "hit_fly", "hit_fly_fall", "lift_jump", "lift_fall"]:
			facing = 1
		elif current_state == "be_lift_stance":
			facing = 1
		elif current_state == "catch" and linked_fighter != null and linked_fighter.current_state == "back_be_catch":
			facing = 1
			linked_fighter.facing = 1
			_update_catch_alignment()
		return
	var walk_speed: float = WALK_X_SPEED * _speed_scale()
	var run_speed: float = RUN_SPEED * _speed_scale()
	match current_state:
		"lift_stance", "lift_walk":
			facing = 1
			velocity.x = run_speed if control_run else walk_speed
			_set_state("lift_run" if control_run else "lift_walk")
		"ready", "stance", "defense", "solid_defense", "walk":
			facing = 1
			velocity.x = run_speed if control_run else walk_speed
			if control_run:
				_set_state("rightrun")
			else:
				_set_state("walk")
		"rightrun":
			velocity.x = run_speed
		"leftrun":
			_stop_run()
		_:
			if z_height > 0.0:
				facing = 1


func _set_up_motion() -> void:
	if lock_motion:
		return
	match current_state:
		"lift_stance", "lift_walk", "lift_run":
			_set_state("lift_walk")
		"ready", "stance", "defense", "solid_defense":
			_set_state("walk")
		"walk", "leftrun", "rightrun":
			pass
		_:
			return
	velocity.y = -WALK_Y_SPEED * _speed_scale()


func _set_down_motion() -> void:
	if lock_motion:
		return
	match current_state:
		"lift_stance", "lift_walk", "lift_run":
			_set_state("lift_walk")
		"ready", "stance", "defense", "solid_defense":
			_set_state("walk")
		"walk", "leftrun", "rightrun":
			pass
		_:
			return
	velocity.y = WALK_Y_SPEED * _speed_scale()


func _stop_run() -> void:
	control_run = false
	lock_motion = false
	velocity.x = move_toward(velocity.x, 0.0, 250.0)
	_set_ready()


func _stop_x_walk() -> void:
	if lock_motion:
		return
	if current_state in ["leftrun", "rightrun", "as_attack", "bs_attack", "ssquat", "sjump"]:
		return
	velocity.x = 0.0


func _stop_y_motion() -> void:
	velocity.y = 0.0


func _has_any_control() -> bool:
	return (
		control_a_attack or control_b_attack or control_jump or control_defense or
		control_left_motion or control_right_motion or control_up_motion or control_down_motion
	)


func _find_runnable_skill() -> String:
	var utility_priority: Array[String] = [
		"a_throw",
		"b_throw",
		"ride_a_attack",
		"ride_b_attack",
		"a_lift",
		"b_lift",
		"push",
		"catch",
		"ride",
		"hug_front_put",
		"hug_back_put",
		"elbow",
		"kneehit",
		"hug_jump",
		"lift_jump",
		"judo",
		"back_judo",
		"spin_drill",
	]
	for skill_name in utility_priority:
		if _has_skill(skill_name) and _can_use_skill(skill_name):
			return skill_name

	var a_priority: Array[String] = [
		"a_finalblow",
		"mach_stomp",
		"jump_elbow",
		"spinhit",
		"sprint_a_attack",
		"sprint_jump_a_attack",
		"big_elbow",
		"jump_mach_a_attack",
		"jump_a_attack",
		"mach_a_attack",
		"a_attack",
	]
	for skill_name in a_priority:
		if _has_skill(skill_name) and _can_use_skill(skill_name):
			return skill_name

	var b_priority: Array[String] = [
		"b_finalblow",
		"jump_tread",
		"bombkick",
		"sprint_b_attack",
		"sprint_jump_b_attack",
		"guillotine",
		"jump_mach_b_attack",
		"jump_b_attack",
		"mach_b_attack",
		"b_attack",
	]
	for skill_name in b_priority:
		if _has_skill(skill_name) and _can_use_skill(skill_name):
			return skill_name

	if _has_skill("jump_spinkick") and _can_use_skill("jump_spinkick"):
		return "jump_spinkick"
	if _has_skill("jump") and _can_use_skill("jump"):
		return "jump"
	if _has_skill("defense") and _can_use_skill("defense"):
		return "defense"
	return ""


func _has_skill(skill_name: String) -> bool:
	return bool(enabled_skills.get(skill_name, false))


func _can_use_skill(skill_name: String) -> bool:
	match skill_name:
		"a_attack":
			return not lock_action and control_a_attack and _can_normal_attack()
		"b_attack":
			return not lock_action and control_b_attack and _can_normal_attack()
		"mach_a_attack":
			return not lock_action and control_a_attack and _can_normal_attack() and _has_action("mach_a_attack")
		"mach_b_attack":
			return not lock_action and control_b_attack and _can_normal_attack() and _has_action("mach_b_attack")
		"jump_a_attack":
			return not lock_action and control_a_attack and _can_jump_attack()
		"jump_b_attack":
			return not lock_action and control_b_attack and _can_jump_attack()
		"jump_mach_a_attack":
			return not lock_action and control_a_attack and _can_jump_attack() and _has_action("jump_mach_a_attack")
		"jump_mach_b_attack":
			return not lock_action and control_b_attack and _can_jump_attack() and _has_action("jump_mach_b_attack")
		"sprint_a_attack":
			return not lock_action and control_a_attack and _can_sprint_attack()
		"sprint_b_attack":
			return not lock_action and control_b_attack and _can_sprint_attack()
		"sprint_jump_a_attack":
			return not lock_action and control_a_attack and _can_sprint_jump_attack()
		"sprint_jump_b_attack":
			return not lock_action and control_b_attack and _can_sprint_jump_attack()
		"jump":
			return _can_jump()
		"defense":
			return not lock_action and control_defense and _can_normal_attack()
		"jump_elbow":
			return control_a_attack and _can_attack_ground() and _has_action("jump_elbow")
		"jump_tread":
			return control_b_attack and _can_attack_ground() and _has_action("jump_stomp")
		"mach_stomp":
			return control_a_attack and _can_attack_ground() and _has_action("mach_stomp")
		"a_finalblow", "b_finalblow":
			return _can_use_final_blow()
		"spinhit":
			return current_state == "jump_done" and control_a_attack and _has_action("spinhit")
		"bombkick":
			return current_state == "jump_done" and control_b_attack and _has_action("bombkick")
		"big_elbow":
			return control_a_attack and _can_use_descend_attack() and _has_action("jump_elbow")
		"guillotine":
			return control_b_attack and _can_use_descend_attack() and _has_action("guillotine")
		"jump_spinkick":
			return not lock_action and current_state in ["sjump", "ssquat"] and control_down_motion and _has_action("kick")
		"catch":
			return _can_use_catch()
		"ride":
			return _can_use_ride()
		"a_lift":
			return control_a_attack and _can_use_lift()
		"b_lift":
			return control_b_attack and _can_use_lift()
		"a_throw":
			return not lock_action and control_a_attack and _can_use_throw(false)
		"b_throw":
			return not lock_action and control_b_attack and _can_use_throw(true)
		"push":
			return current_state == "catch" and linked_fighter != null and control_b_attack
		"ride_a_attack":
			return current_state == "ride" and linked_fighter != null and control_a_attack and _can_attack_ride_target()
		"ride_b_attack":
			return current_state == "ride" and linked_fighter != null and control_b_attack and _can_attack_ride_target()
		"hug_front_put":
			return _can_use_role_catch_skill("hug_front_put", "front", true)
		"hug_back_put":
			return _can_use_role_catch_skill("hug_back_put", "back", false)
		"elbow":
			return _can_use_role_catch_skill("elbow", "front", true)
		"kneehit":
			return _can_use_role_catch_skill("kneehit", "back", false)
		"hug_jump":
			return _can_use_role_catch_skill("hug_jump", "front", true)
		"lift_jump":
			return _can_use_role_catch_skill("lift_jump", "back", false)
		"judo":
			return _can_use_role_catch_skill("judo", "front", true)
		"back_judo":
			return _can_use_role_catch_skill("back_judo", "back", false)
		"spin_drill":
			return _can_use_role_catch_skill("spin_drill", "front", true, true)
		_:
			return false


func _can_normal_attack() -> bool:
	if hitstun > 0.0 or current_state == "lying":
		return false
	return current_state in NORMAL_ATTACK_STATES or current_state == "be_lift_stance"


func _can_jump_attack() -> bool:
	return current_state in ["jump", "jsquat"]


func _can_sprint_attack() -> bool:
	return current_state in ["leftrun", "rightrun"]


func _can_sprint_jump_attack() -> bool:
	return current_state in ["sjump", "ssquat"]


func _can_jump() -> bool:
	if not control_jump:
		return false
	match current_state:
		"be_lift_squat", "be_lift_stance":
			return true
		"walk", "stance", "ready", "leftrun", "rightrun", "as_attack", "bs_attack", "lift_stance", "lift_walk", "lift_run":
			return not lock_action
		_:
			return false


func _can_use_descend_attack() -> bool:
	return current_state in ["jump", "jsquat"] and velocity.z < 0.0


func _can_attack_ground() -> bool:
	if current_state not in NORMAL_ATTACK_STATES:
		return false
	var target: Fighter = _get_ground_target()
	if target == null:
		return false
	var dx: float = target.ground_position.x - ground_position.x
	if facing < 0 and dx >= 0.0:
		return false
	if facing > 0 and dx <= 0.0:
		return false
	return true


func _can_use_final_blow() -> bool:
	if lock_action or not _has_action("final_blow"):
		return false
	if not (control_a_attack or control_b_attack):
		return false
	if not _can_normal_attack():
		return false
	return _get_action_target("final_blow", ["rest"]) != null


func _can_use_catch() -> bool:
	if lock_motion:
		return false
	if not (control_left_motion or control_right_motion):
		return false
	if not ["ready", "stance", "walk"].has(current_state):
		return false
	return _get_rest_target_in_front() != null


func _can_use_ride() -> bool:
	if lock_motion:
		return false
	if not (control_up_motion or control_down_motion):
		return false
	if not _can_normal_attack():
		return false
	return _get_ride_target() != null


func _can_use_lift() -> bool:
	if lock_action:
		return false
	if not _can_normal_attack():
		return false
	return _get_lift_target() != null


func _can_use_throw(_upward: bool) -> bool:
	if linked_fighter == null:
		return false
	if not ["lift_stance", "lift_walk", "lift_run", "lift_jump", "lift_fall"].has(current_state):
		return false
	return not linked_fighter.is_defeated()


func _can_attack_ride_target() -> bool:
	if linked_fighter == null:
		return false
	return _is_rideable_state(linked_fighter.current_state)


func _can_use_role_catch_skill(skill_name: String, side: String, allow_direct: bool, allow_both: bool = false) -> bool:
	if not control_a_attack:
		return false
	if current_state == "catch" and linked_fighter != null:
		if allow_both:
			return ["be_catch", "back_be_catch"].has(linked_fighter.current_state)
		if side == "front":
			return linked_fighter.current_state == "be_catch"
		return linked_fighter.current_state == "back_be_catch"
	if not allow_direct:
		return false
	return _get_rush_catch_target(skill_name) != null


func _run_skill(skill_name: String) -> void:
	match skill_name:
		"a_attack":
			_start_ground_attack("be_lift_a_attack" if current_state == "be_lift_stance" else "a_attack", "a_attack")
		"b_attack":
			_start_ground_attack("be_lift_b_attack" if current_state == "be_lift_stance" else "b_attack", "b_attack")
		"mach_a_attack":
			_start_ground_attack("be_lift_mach_a_attack" if current_state == "be_lift_stance" else "mach_a_attack", "mach_a_attack")
		"mach_b_attack":
			_start_ground_attack("be_lift_mach_b_attack" if current_state == "be_lift_stance" else "mach_b_attack", "mach_b_attack")
		"a_finalblow", "b_finalblow":
			_start_ground_attack("final_blow", "final_blow")
		"jump_a_attack":
			_start_air_attack("aj_attack", "jump_a_attack")
		"jump_b_attack":
			_start_air_attack("bj_attack", "jump_b_attack")
		"jump_mach_a_attack":
			_start_air_attack("maj_attack", "jump_mach_a_attack")
		"jump_mach_b_attack":
			_start_air_attack("mbj_attack", "jump_mach_b_attack")
		"sprint_a_attack":
			_start_sprint_attack("as_attack", "sprint_a_attack")
		"sprint_b_attack":
			_start_sprint_attack("bs_attack", "sprint_b_attack")
		"sprint_jump_a_attack":
			_start_air_attack("asj_attack", "sprint_jump_a_attack")
		"sprint_jump_b_attack":
			_start_air_attack("bsj_attack", "sprint_jump_b_attack")
		"jump":
			_start_jump()
		"defense":
			_start_defense()
		"jump_elbow":
			_start_jump_elbow()
		"jump_tread":
			_start_jump_tread()
		"mach_stomp":
			_start_mach_stomp()
		"spinhit":
			_start_spinhit()
		"bombkick":
			_start_bombkick()
		"big_elbow":
			_start_descend_attack("big_elbow", "big_elbow")
		"guillotine":
			_start_descend_attack("guillotine", "guillotine")
		"jump_spinkick":
			_start_jump_spinkick()
		"catch":
			_start_catch()
		"ride":
			_start_ride()
		"a_lift":
			_start_lift()
		"b_lift":
			_start_lift()
		"a_throw":
			_start_throw(false)
		"b_throw":
			_start_throw(true)
		"push":
			_start_push()
		"ride_a_attack":
			_start_ride_attack(false)
		"ride_b_attack":
			_start_ride_attack(true)
		"hug_front_put":
			_start_role_catch_skill("hug_front_put", "front", "catch_skill_fa", "normal")
		"hug_back_put":
			_start_role_catch_skill("hug_back_put", "back", "catch_skill_ba", "long_fly")
		"elbow":
			_start_role_catch_skill("elbow", "front", "catch_skill_fa", "normal")
		"kneehit":
			_start_role_catch_skill("kneehit", "back", "catch_skill_ba", "long_fly")
		"hug_jump":
			_start_role_catch_skill("hug_jump", "front", "catch_skill_fa", "long_fly")
		"lift_jump":
			_start_role_catch_skill("lift_jump", "back", "catch_skill_ba", "long_fly")
		"judo":
			_start_role_catch_skill("judo", "front", "catch_skill_fa", "long_fly")
		"back_judo":
			_start_role_catch_skill("back_judo", "back", "catch_skill_ba", "long_fly")
		"spin_drill":
			_start_role_catch_skill("spin_drill", "front", "catch_skill_fa", "long_fly")
		_:
			pass


func _start_ground_attack(state_name: String, attack_name: String) -> void:
	current_attack_name = attack_name
	_attack_sfx_hit_count = 0
	return_to_be_lift_stance_after_attack = current_state in ["be_lift_stance", "be_lift_squat"]
	lock_action = true
	lock_motion = true
	_stop_x_walk()
	_stop_y_motion()
	_set_state(state_name, true)
	if attack_name == "final_blow":
		_play_sfx("final_blow")
	elif attack_name not in ["mach_a_attack", "mach_b_attack"]:
		_play_sfx("attack")


func _start_air_attack(state_name: String, attack_name: String) -> void:
	current_attack_name = attack_name
	_attack_sfx_hit_count = 0
	lock_action = true
	_set_state(state_name, true)
	_play_sfx("attack")


func _start_sprint_attack(state_name: String, attack_name: String) -> void:
	current_attack_name = attack_name
	_attack_sfx_hit_count = 0
	lock_action = true
	lock_motion = true
	velocity.y = 0.0
	velocity.x = facing * RUN_SPEED * _speed_scale() * 1.05
	sprint_attack_decel = absf(velocity.x) * 2
	_set_state(state_name, true)
	_play_sfx("attack")


func _start_jump() -> void:
	control_jump = false
	current_attack_name = ""
	hit_targets.clear()
	_play_sfx("jump")
	if current_state in ["be_lift_squat", "be_lift_stance"]:
		_start_active_jump_on_be_lift()
		return
	if current_state in ["leftrun", "rightrun", "as_attack", "bs_attack"]:
		lock_motion = true
		lock_action = true
		_set_state("ssquat", true)
		velocity.z = JUMP_SPEED
		z_height = maxf(z_height, 1.0)
		return
	if _is_in_lift_state():
		lock_motion = true
		lock_action = false
		velocity.z = JUMP_SPEED
		z_height = maxf(z_height, 1.0)
		_set_state("lift_jump", true)
		return
	lock_motion = true
	lock_action = false
	velocity.z = JUMP_SPEED
	z_height = maxf(z_height, 1.0)
	_set_state("jump", true)


func _start_active_jump_on_be_lift() -> void:
	var lifter: Fighter = linked_fighter
	be_lift_stand_timer = 0.0
	if lifter != null and lifter.linked_fighter == self:
		lifter.linked_fighter = null
		lifter.link_mode = ""
		match lifter.current_state:
			"lift_fall", "lift_jump":
				lifter.lock_action = true
				lifter.lock_motion = true
				lifter._set_state("jump", true)
			"lift_stance":
				lifter.lock_action = false
				lifter.lock_motion = false
				lifter._set_state("stance", true)
			"lift_walk":
				lifter.lock_action = false
				lifter.lock_motion = false
				lifter._set_state("walk", true)
			"lift_run":
				lifter.lock_action = false
				lifter.lock_motion = false
				lifter._set_state("leftrun" if lifter.facing < 0 else "rightrun", true)
			_:
				lifter.lock_action = false
				lifter.lock_motion = false
				lifter._set_ready()
	linked_fighter = null
	link_mode = ""
	lock_motion = true
	lock_action = false
	if control_left_motion:
		velocity.x = -WALK_X_SPEED
		facing = -1
	elif control_right_motion:
		velocity.x = WALK_X_SPEED
		facing = 1
	else:
		velocity.x = 0.0
	velocity.y = 0.0
	velocity.z = JUMP_SPEED
	z_height = maxf(z_height, 1.0)
	_set_state("jump", true)


func _start_defense() -> void:
	current_attack_name = ""
	lock_motion = true
	_stop_x_walk()
	_stop_y_motion()
	if current_state == "be_lift_stance":
		if _has_skill("solid_defense") and _has_action("solid_defense"):
			_set_state("be_lift_solid_defense", true)
		else:
			_set_state("be_lift_defense", true)
		return
	if _has_skill("solid_defense") and _has_action("solid_defense"):
		_set_state("solid_defense", true)
	else:
		_set_state("defense", true)


func _start_spinhit() -> void:
	current_attack_name = "spinhit"
	lock_action = true
	lock_motion = true
	_set_state("spinhit", true)
	velocity.z = ZSPEED_SPINHIT
	if control_left_motion:
		velocity.x = -XSPEED_SPINHIT
		facing = -1
	elif control_right_motion:
		velocity.x = XSPEED_SPINHIT
		facing = 1
	else:
		velocity.x = float(facing) * XSPEED_SPINHIT
	velocity.y = 0.0


func _start_second_spinhit() -> void:
	current_attack_name = "tornado_attack"
	lock_action = true
	lock_motion = true
	_set_state("spinhit", true)
	velocity.z = ZSPEED_SPINHIT_2
	velocity.x = float(facing) * XSPEED_SPINHIT_2
	velocity.y = 0.0


func _start_bombkick() -> void:
	current_attack_name = "bombkick"
	lock_action = true
	lock_motion = true
	_set_state("bombkick", true)
	velocity.z = ZSPEED_BOMBKICK
	if control_left_motion:
		velocity.x = -XSPEED_BOMBKICK
		facing = -1
	elif control_right_motion:
		velocity.x = XSPEED_BOMBKICK
		facing = 1
	else:
		velocity.x = float(facing) * XSPEED_BOMBKICK
	velocity.y = 0.0


func _start_descend_attack(state_name: String, attack_name: String) -> void:
	current_attack_name = attack_name
	lock_action = true
	lock_motion = true
	_set_state(state_name, true)
	velocity.y = 0.0
	velocity.x = move_toward(velocity.x, 0.0, 80.0)


func _start_jump_spinkick() -> void:
	current_attack_name = "jump_spinkick"
	lock_action = true
	lock_motion = true
	velocity.z = ZSPEED_JUMP_SPINKICK
	z_height = maxf(z_height, 1.0)
	_set_state("spinhit", true)
	pending_state_on_descend = "kick"


func _start_jump_elbow() -> void:
	current_attack_name = "jump_elbow"
	lock_action = true
	lock_motion = true
	hit_targets.clear()
	_stop_x_walk()
	_stop_y_motion()
	velocity.z = JUMP_SPEED
	z_height = maxf(z_height, 1.0)
	special_state_timer = 0.0
	_set_state("jump", true)


func _start_jump_tread() -> void:
	current_attack_name = "jump_stomp"
	lock_action = true
	lock_motion = true
	hit_targets.clear()
	_stop_x_walk()
	_stop_y_motion()
	velocity.z = JUMP_SPEED
	z_height = maxf(z_height, 1.0)
	special_state_timer = 0.0
	_set_state("jump", true)


func _start_mach_stomp() -> void:
	current_attack_name = "mach_stomp"
	mach_stomp_loops_left = 5
	lock_action = true
	lock_motion = true
	hit_targets.clear()
	_stop_x_walk()
	_stop_y_motion()
	velocity.z = 0.0
	special_state_timer = 0.0
	_set_state("mach_stomp", true)


func _start_catch() -> void:
	var target: Fighter = _get_rest_target_in_front()
	if target == null:
		return
	_link_with(target, "catch")
	current_attack_name = ""
	catch_hold_timer = 2.0
	lock_action = true
	lock_motion = true
	target.lock_action = true
	target.lock_motion = true
	target.velocity = Vector3.ZERO
	_set_state("catch", true)
	_update_catch_alignment()
	_play_sfx("catch")


func _start_lift() -> void:
	var target: Fighter = _get_lift_target()
	if target == null:
		return
	var be_lift_state: String = _get_be_lift_state_for_target(target.current_state)
	_link_with(target, "lift")
	current_attack_name = ""
	velocity.x = 0.0
	velocity.y = 0.0
	lock_action = true
	lock_motion = true
	target.lock_action = true
	target.lock_motion = true
	target.velocity = Vector3.ZERO
	target.current_attack_name = ""
	target.rest_timer = 0.0
	target.be_throw_stand_timer = 0.0
	target.be_lift_stand_timer = BE_LIFT_REST_TIME if _is_be_lift_prone_state(be_lift_state) else 0.0
	target._set_state(be_lift_state, true)
	_set_state("lift_squat", true)
	_update_lift_alignment()


func _start_throw(upward: bool) -> void:
	if linked_fighter == null:
		return
	var target: Fighter = linked_fighter
	current_attack_name = "b_throw" if upward else "a_throw"
	lock_action = true
	lock_motion = true
	if current_state == "lift_run":
		velocity.x *= 0.5
	_set_state("throw", true)
	target.linked_fighter = null
	target.link_mode = ""
	linked_fighter = null
	link_mode = ""
	catch_hold_timer = 0.0
	_start_throw_flight(target, upward)


func _start_ride() -> void:
	var target: Fighter = _get_ride_target()
	if target == null:
		return
	_link_with(target, "ride")
	current_attack_name = ""
	velocity.x = 0.0
	velocity.y = 0.0
	lock_action = false
	lock_motion = true
	target.lock_action = true
	target.lock_motion = true
	target.velocity = Vector3.ZERO
	target.downed_timer = INF
	target.be_throw_stand_timer = INF
	target.rest_timer = 0.0
	_set_state("ride", true)
	_update_ride_alignment()


func _start_ride_attack(is_jump: bool) -> void:
	if linked_fighter == null:
		return
	current_attack_name = "ride_b_attack" if is_jump else "ride_a_attack"
	var target: Fighter = linked_fighter
	if is_jump:
		lock_action = true
		lock_motion = true
		velocity = Vector3.ZERO
		velocity.z = JUMP_SPEED
		z_height = maxf(z_height, 1.0)
		airborne_script = "ride_jump"
		airborne_script_source = target
		_set_state("ride_jump", true)
		return
	lock_action = true
	lock_motion = true
	hit_targets.erase("ride_attack_applied")
	_set_state("ride_attack", true)
	if linked_fighter != null and _is_rideable_state(target.current_state):
		hit_targets["ride_attack_applied"] = true
		_apply_ride_damage(target, false)


func _get_be_lift_state_for_target(state_name: String) -> String:
	match state_name:
		"lying_hit", "be_lift_lying_hit":
			return "be_lift_lying_hit"
		"lying", "rest", "half_lying", "be_lift_lying":
			return "be_lift_lying"
		"tummy_hit", "tummy_hit_fly", "be_lift_tummy_hit":
			return "be_lift_tummy_hit"
		"tummy", "be_lift_tummy":
			return "be_lift_tummy"
		"defense", "be_lift_defense":
			return "be_lift_defense"
		"solid_defense", "be_lift_solid_defense":
			return "be_lift_solid_defense"
		"a_attack", "be_lift_a_attack":
			return "be_lift_a_attack"
		"b_attack", "be_lift_b_attack":
			return "be_lift_b_attack"
		"mach_a_attack", "be_lift_mach_a_attack":
			return "be_lift_mach_a_attack"
		"mach_b_attack", "be_lift_mach_b_attack":
			return "be_lift_mach_b_attack"
		"squat", "be_lift_squat":
			return "be_lift_squat"
		_:
			return "be_lift_stance"


func _is_be_lift_upright_state(state_name: String) -> bool:
	return state_name in [
		"squat",
		"be_lift_squat",
		"be_lift_stance",
		"be_lift_defense",
		"be_lift_solid_defense",
		"be_lift_a_attack",
		"be_lift_b_attack",
		"be_lift_mach_a_attack",
		"be_lift_mach_b_attack",
	]


func _is_be_lift_prone_state(state_name: String = "") -> bool:
	var probe_state: String = state_name if not state_name.is_empty() else current_state
	return probe_state in [
		"be_lift_lying",
		"be_lift_lying_hit",
		"be_lift_tummy",
		"be_lift_tummy_hit",
	]


func _start_be_lift_passive_jump(target: Fighter) -> void:
	var launch_speed: float = float(facing) * (RUN_SPEED * 0.5 + velocity.x * 0.5)
	target.pending_throw_attacker = null
	target.be_throw_stand_timer = 0.0
	target.be_lift_stand_timer = 0.0
	target.rest_timer = 0.0
	target.lock_action = true
	target.lock_motion = true
	target.current_attack_name = "be_lift_passive_jump"
	target._clear_airborne_skill_state()
	target.velocity.x = launch_speed
	target.velocity.y = 0.0
	target.velocity.z = JUMP_SPEED
	target.z_height = maxf(target.z_height, z_height + 24.0)
	target._set_state("be_lift_squat", true)


func _start_throw_flight(target: Fighter, upward: bool) -> void:
	var throw_speed: float
	target.pending_throw_attacker = self
	target.be_throw_stand_timer = 0.0
	target.be_lift_stand_timer = 0.0
	target.current_attack_name = ""
	target.hit_targets.clear()
	target.rest_timer = 0.0
	target.lock_action = true
	target.lock_motion = true
	target.velocity.y = 0.0
	target.facing = -facing
	target.airborne_script_source = self
	if upward:
		throw_speed = float(facing) * XSPEED_THROWUP_FLY + velocity.x * 0.25
		target.airborne_script = "throw_up_fly"
		target.velocity.x = throw_speed
		target.velocity.z = ZSPEED_THROWUP_FLY
		target.z_height = maxf(target.z_height, z_height + 24.0)
		target._set_state("hit_fly_fall", true)
		target.hit_targets.clear()
		return
	throw_speed = float(facing) * XSPEED_THROWDOWN_FLY + velocity.x * 0.5
	target.airborne_script = "throw_down_slam"
	target.velocity.x = throw_speed
	target.velocity.z = -700.0
	target.z_height = maxf(target.z_height, z_height + 96.0)
	target.hit_targets.clear()
	target._set_state("half_lying", true)


func _start_push() -> void:
	if linked_fighter == null:
		return
	var target: Fighter = linked_fighter
	current_attack_name = "push"
	lock_action = true
	lock_motion = true
	var is_back_catch: bool = target.current_state == "back_be_catch"
	var action_state: String = "catch_skill_bb" if is_back_catch else "catch_skill_fb"
	if not is_back_catch:
		facing = target.facing
		target.ground_position = Vector2(ground_position.x + 30.0 * float(facing), ground_position.y)
		target.z_height = z_height
		target.velocity = Vector3.ZERO
	_set_state(action_state, true)
	target.lock_action = true
	target.lock_motion = true
	target.special_state_timer = WEAK_RUN_TIME
	if is_back_catch:
		target._set_state("weak_run", true)
	else:
		target._set_state("weak_run_attack", true)
	target.velocity.x = float(facing) * 200.0
	target.velocity.y = 0.0
	target.hit_targets.clear()
	_release_catch(false, false, false)


func _start_role_catch_skill(skill_name: String, _side: String, action_state: String, effect_type: String) -> void:
	if linked_fighter == null:
		var rush_target: Fighter = _get_rush_catch_target(skill_name)
		if rush_target != null:
			_link_with(rush_target, "catch")
			rush_target.lock_action = true
			rush_target.lock_motion = true
			_update_catch_alignment()
	if linked_fighter == null:
		return
	var target: Fighter = linked_fighter
	skill_target = target
	current_attack_name = skill_name
	lock_action = true
	lock_motion = true
	role_skill_event_frame = -1
	_set_state(action_state, true)
	target.lock_action = true
	target.lock_motion = true
	target.velocity = Vector3.ZERO
	if skill_name in ["hug_front_put", "hug_back_put", "elbow", "kneehit", "judo", "back_judo"]:
		_start_staged_role_catch_skill(skill_name, target)
		return
	if skill_name in ["hug_jump", "lift_jump", "spin_drill"]:
		_start_air_role_catch_skill(skill_name, target)
		return
	var base_damage: int = _get_role_grapple_damage(skill_name, target)
	_apply_grapple_damage(target, base_damage, effect_type)
	if effect_type == "long_fly":
		target._set_state("half_lying", true)
		target.velocity.x = float(facing) * 260.0
		target.velocity.z = JUMP_SPEED * 0.55
		target.special_state_timer = 0.25
	else:
		target.special_state_timer = 0.2
		target._set_state("lying_hit", true)
		target.velocity.x = float(facing) * 160.0
	_release_catch(false, false, false)


func _start_staged_role_catch_skill(skill_name: String, target: Fighter) -> void:
	match skill_name:
		"hug_front_put":
			target.facing = -facing
			_place_skill_target(target, 30.0 * float(facing), 0.0, "roll_down")
		"hug_back_put":
			target.facing = facing
			_update_catch_alignment()
		"elbow":
			target.facing = -facing
			_place_skill_target(target, 28.0 * float(facing), 0.0, "hit")
		"kneehit":
			target.facing = facing
			_place_skill_target(target, 0.0, 56.0, "lying_hit")
		"judo":
			target.facing = -facing
			_place_skill_target(target, 0.0, 0.0, "hit")
		"back_judo":
			target.facing = facing
			_update_catch_alignment()
		_:
			pass


func _start_air_role_catch_skill(skill_name: String, target: Fighter) -> void:
	match skill_name:
		"hug_jump":
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, 15.0 * float(facing), 0.0, "roll_down")
			_release_catch(false, false, false)
			airborne_script = "hug_jump_prepare"
			role_skill_timer = 0.0
		"lift_jump":
			target.pending_throw_attacker = self
			target._set_state("lying_hit", true)
			target.airborne_script = "lift_jump_target"
			target.airborne_script_source = self
			_release_catch(false, false, false)
			_set_state("lift_jump", true)
			airborne_script = "lift_jump_up"
			role_skill_timer = 0.1
			velocity = Vector3.ZERO
			velocity.z = JUMP_SPEED
			z_height = maxf(z_height, 1.0)
		"spin_drill":
			target._set_state("half_lying", true)
			target.ground_position = ground_position
			target.velocity = Vector3.ZERO
			target.pending_throw_attacker = self
			target.airborne_script = "spin_drill_target_launch"
			target.airborne_script_source = self
			_release_catch(false, false, false)
			airborne_script = "spin_drill_launch"
			velocity = Vector3.ZERO
			velocity.z = ZSPEED_SPIN_DRILL
			z_height = maxf(z_height, 1.0)
			target.velocity.z = ZSPEED_SPIN_DRILL
			target.z_height = maxf(target.z_height, 1.0)
		_:
			pass


func _update_role_skill_state() -> void:
	if airborne_script == "lift_jump_target":
		_update_lift_jump_target_from_source()
	if current_state == "ride_attack" and current_attack_name == "ride_a_attack":
		_update_ride_attack_state()
	if current_attack_name in ["hug_front_put", "hug_back_put", "elbow", "kneehit", "judo", "back_judo"]:
		if current_frame_index == role_skill_event_frame:
			return
		role_skill_event_frame = current_frame_index
		var staged_target: Fighter = skill_target if skill_target != null else linked_fighter
		if staged_target == null or staged_target.is_defeated():
			return
		match current_attack_name:
			"hug_front_put":
				_update_hug_front_put(staged_target, current_frame_index)
			"hug_back_put":
				_update_hug_back_put(staged_target, current_frame_index)
			"elbow":
				_update_elbow(staged_target, current_frame_index)
			"kneehit":
				_update_kneehit(staged_target, current_frame_index)
			"judo":
				_update_judo(staged_target, current_frame_index)
			"back_judo":
				_update_back_judo(staged_target, current_frame_index)
			_:
				pass
		return
	match current_attack_name:
		"hug_jump":
			if airborne_script == "hug_jump_prepare" and current_frame_index >= 2:
				_start_hug_jump_launch()
		"lift_jump":
			_update_lift_jump_state()
		_:
			pass


func _update_ride_attack_state() -> void:
	if bool(hit_targets.get("ride_attack_applied", false)):
		return
	var target: Fighter = linked_fighter
	if target == null or target.is_defeated():
		return
	if current_frame_index < current_frames.size() - 1:
		return
	hit_targets["ride_attack_applied"] = true
	_apply_ride_damage(target, false)


func _place_skill_target(target: Fighter, offset_x: float, offset_z: float, state_name: String = "") -> void:
	target.ground_position = Vector2(ground_position.x + offset_x, ground_position.y)
	target.z_height = maxf(z_height + offset_z, 0.0)
	target.velocity = Vector3.ZERO
	target.lock_action = true
	target.lock_motion = true
	if not state_name.is_empty():
		target._set_state(state_name, true)


func _deal_grapple_damage_only(target: Fighter, damage: int) -> void:
	var mitigated: int = target._reduce_damage_for_state(damage)
	target.last_damage_attack_name = current_attack_name
	target.invulnerable_time = 0.08
	target.current_attack_name = ""
	target.hitstun = HITSTUN_TIME
	target.hp = max(target.hp - mitigated, 0)
	target.hp_changed.emit(target.hp, target.max_hp)
	if target.hp <= 0:
		target._handle_defeat(self)


func _finish_staged_grapple(target: Fighter, set_rest: bool = false) -> void:
	target.linked_fighter = null
	target.link_mode = ""
	target.lock_action = true
	if not (target.airborne_script == "throw_down_slam" or target.airborne_script == "throw_up_fly"):
		target.lock_motion = false
	linked_fighter = null
	link_mode = ""
	catch_hold_timer = 0.0
	if set_rest and not target.is_defeated():
		target._start_rest()
	current_attack_name = ""
	lock_action = false
	lock_motion = false
	_reset_attack_controls()
	_set_ready()


func _update_hug_front_put(target: Fighter, frame: int) -> void:
	match frame:
		1:
			target.facing = -facing
			_place_skill_target(target, 30.0 * float(facing), 20.0, "hit_fly_fall")
		2:
			target.facing = facing
			_place_skill_target(target, -15.0 * float(facing), 25.0, "roll_up")
		3:
			target.facing = -facing
			_place_skill_target(target, 25.0 * float(facing), 20.0, "half_stance")
		4:
			target.facing = facing
			_place_skill_target(target, -25.0 * float(facing), 15.0, "roll_up")
		5:
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, 40.0 * float(facing), 10.0, "half_lying")
			_deal_grapple_damage_only(target, _get_role_grapple_damage("hug_front_put", target))
			target.velocity.x = float(facing) * 100.0
			target.velocity.z = 120.0
			target.special_state_timer = 0.35
			_finish_staged_grapple(target)
			return
		_:
			pass


func _update_hug_back_put(target: Fighter, frame: int) -> void:
	match frame:
		2:
			target.facing = facing
			_place_skill_target(target, -30.0 * float(facing), 30.0, "lying_hit")
		4:
			target.facing = facing
			target.pending_throw_attacker = self
			_place_skill_target(target, -35.0 * float(facing), 0.0, "half_lying")
			_deal_grapple_damage_only(target, _get_role_grapple_damage("hug_back_put", target))
			target.velocity.z = 100.0
			target.special_state_timer = 0.35
			_finish_staged_grapple(target)
			return
		_:
			pass


func _update_elbow(target: Fighter, frame: int) -> void:
	var punch: float = float(role_data.get("stats", {}).get("punch", 60))
	var max_hp_value: float = float(role_data.get("stats", {}).get("max_hp", max_hp))
	var missing_hp_ratio: float = 0.0
	if max_hp_value > 0.0:
		missing_hp_ratio = (max_hp_value - float(hp)) / max_hp_value
	match frame:
		1:
			target.facing = -facing
			_place_skill_target(target, 28.0 * float(facing), 0.0, "hit")
			_deal_grapple_damage_only(target, int(round(20.0 + punch / 5.0)))
		2:
			target.facing = -facing
			_place_skill_target(target, 30.0 * float(facing), 8.0, "hit_fly")
		3:
			target.facing = -facing
			_place_skill_target(target, 34.0 * float(facing), 4.0, "lying_hit")
		4:
			target.facing = -facing
			_place_skill_target(target, 38.0 * float(facing), 0.0, "lying_hit")
			_deal_grapple_damage_only(target, int(round(punch * missing_hp_ratio + punch / 3.0)))
		5:
			target.facing = -facing
			_place_skill_target(target, 42.0 * float(facing), 0.0, "lying")
			target.downed_timer = 0.0
			target.be_throw_stand_timer = SHORT_REST_TIME
			_finish_staged_grapple(target)
		_:
			pass


func _update_kneehit(target: Fighter, frame: int) -> void:
	var stats: Dictionary = role_data.get("stats", {})
	var kick: float = float(stats.get("kick", 90))
	var throw_value: float = float(stats.get("throw", 80))
	var max_hp_value: float = float(stats.get("max_hp", max_hp))
	var missing_hp_ratio: float = 0.0
	if max_hp_value > 0.0:
		missing_hp_ratio = (max_hp_value - float(hp)) / max_hp_value
	match frame:
		1:
			_deal_grapple_damage_only(target, int(round(kick * missing_hp_ratio + kick * 0.2)))
			target._set_state("lying_hit", true)
		2:
			target.z_height = 24.0
		3:
			_deal_grapple_damage_only(target, int(round(throw_value * 0.5)))
			target.facing = -facing
			target.pending_throw_attacker = self
			target._set_state("lying", true)
			target.downed_timer = 0.0
			target.be_throw_stand_timer = SHORT_REST_TIME
			_finish_staged_grapple(target)
			return
		_:
			pass


func _update_judo(target: Fighter, frame: int) -> void:
	var throw_value: float = float(role_data.get("stats", {}).get("throw", 80))
	var front_hit_offset_x: float = 24.0 * float(facing)
	var rear_fall_offset_x: float = -42.0 * float(facing)
	var overhead_offset_x: float = rear_fall_offset_x
	var overhead_offset_y: float = 40.0
	var rear_ground_offset_x: float = -46.0 * float(facing)
	match frame:
		0:
			target.facing = facing
			target.pending_throw_attacker = self
			_place_skill_target(target, front_hit_offset_x, 0.0, "hit")
		1:
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, overhead_offset_x, overhead_offset_y, "tummy_hit_fly")
			_deal_grapple_damage_only(target, int(round(throw_value * 0.45)))
		2:
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, rear_fall_offset_x, 8.0, "hit_fly_fall")
		3:
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, rear_ground_offset_x, 0.0, "lying_hit")
		4:
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, rear_ground_offset_x, 0.0, "lying_hit")
			target.velocity.z = 140.0
			target.velocity.x = -float(facing) * 120.0
			_deal_grapple_damage_only(target, int(round(throw_value * 0.35)))
			_finish_staged_grapple(target)
			return
		_:
			pass


func _update_back_judo(target: Fighter, frame: int) -> void:
	match frame:
		1:
			target._set_state("hit_fly", true)
		2:
			target.facing = -facing
			target.pending_throw_attacker = self
			_place_skill_target(target, 0.0, 42.0, "hit_fly")
		4:
			var throw_direction: float = -float(facing)
			var throw_release_offset: float = 12.0
			var throw_launch_speed: float = XSPEED_THROWDOWN_FLY * 0.95
			var throw_launch_z: float = 36.0
			var throw_launch_height: float = 24.0
			target.facing = -facing
			target.linked_fighter = null
			target.link_mode = ""
			target.pending_throw_attacker = self
			target.be_throw_stand_timer = 0.0
			target.be_lift_stand_timer = 0.0
			target.rest_timer = 0.0
			target.lock_action = true
			target.lock_motion = true
			target.current_attack_name = ""
			target.airborne_script_source = self
			target.airborne_script = "throw_down_slam"
			target.ground_position = Vector2(ground_position.x + throw_direction * throw_release_offset, ground_position.y)
			target.velocity.x = throw_direction * throw_launch_speed
			target.velocity.y = 0.0
			target.velocity.z = throw_launch_z
			target.z_height = maxf(z_height + throw_launch_height, throw_launch_height)
			target.hit_targets.clear()
			target._set_state("hit_fly", true)
			_finish_staged_grapple(target)
			return
		_:
			pass


func _start_hug_jump_launch() -> void:
	var target: Fighter = skill_target
	if target == null or target.is_defeated():
		current_attack_name = ""
		_clear_airborne_skill_state()
		lock_action = false
		lock_motion = false
		_set_ready()
		return
	airborne_script = "hug_jump_rise"
	velocity = Vector3.ZERO
	velocity.z = ZSPEED_HUG_JUMP
	z_height = maxf(z_height, 1.0)
	target.lock_action = true
	target.lock_motion = true
	target.current_attack_name = ""
	target.pending_throw_attacker = self
	target.airborne_script = "hug_jump_target_rise"
	target.airborne_script_source = self
	target._set_state("half_lying", true)
	target.velocity = Vector3.ZERO
	target.velocity.z = ZSPEED_HUG_JUMP
	target.z_height = maxf(target.z_height, 1.0)


func _update_lift_jump_state() -> void:
	if airborne_script == "lift_jump_up" and role_skill_timer <= 0.0 and velocity.z <= 0.0:
		_start_lift_jump_slam()


func _start_lift_jump_slam() -> void:
	airborne_script = "lift_jump_slam"
	lock_action = true
	lock_motion = true
	velocity.x = 0.0
	velocity.y = 0.0
	velocity.z = minf(velocity.z, -JUMP_SPEED)
	_set_state("half_lying", true)
	var target: Fighter = skill_target
	if target == null or target.is_defeated():
		return
	target.lock_action = true
	target.lock_motion = true
	target.ground_position = ground_position
	target.z_height = maxf(z_height - 28.0, 0.0)
	target.velocity.x = 0.0
	target.velocity.y = 0.0
	target.velocity.z = velocity.z
	target._set_state("lying_hit", true)


func _update_common_lift_jump_state() -> void:
	if current_attack_name == "lift_jump":
		return
	if current_state not in ["lift_jump", "lift_fall"]:
		return
	if linked_fighter == null:
		if z_height > 0.0:
			_set_state("jump" if velocity.z > 0.0 else "fall", true)
		return
	if current_state == "lift_jump" and velocity.z <= 0.0 and _has_action("lift_fall"):
		_set_state("lift_fall", true)


func _update_jump_touch() -> void:
	if current_state == "jump" and velocity.z <= 0.0:
		if current_attack_name == "jump_stomp":
			hit_targets.clear()
			_set_state("jump_stomp", true)
		elif current_attack_name == "jump_elbow":
			hit_targets.clear()
			_set_state("jump_elbow", true)
	if linked_fighter != null:
		return
	if current_state not in ["jump", "sjump"]:
		return
	if velocity.z > -10.0 or z_height <= 0.0:
		return
	var own_box: Dictionary = _box_to_world(current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
	var foot_box: Dictionary = {
		"min_x": float(own_box["min_x"]) + 5.0,
		"max_x": float(own_box["max_x"]) - 5.0,
		"min_y": float(own_box["min_y"]),
		"max_y": float(own_box["max_y"]),
		"min_z": float(own_box["min_z"]),
		"max_z": float(own_box["min_z"]) + 5.0,
	}
	for target in _get_active_targets():
		if target.linked_fighter != null:
			continue
		var carrier_state: String = _get_be_lift_carrier_state(target.current_state)
		if carrier_state.is_empty():
			continue
		if target.z_height + 15.0 < z_height - 72.0:
			continue
		var target_box: Dictionary = target._box_to_world(target.current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
		var head_box: Dictionary = {
			"min_x": float(target_box["min_x"]) + 5.0,
			"max_x": float(target_box["max_x"]) - 5.0,
			"min_y": float(target_box["min_y"]),
			"max_y": float(target_box["max_y"]),
			"min_z": float(target_box["max_z"]) - 5.0,
			"max_z": float(target_box["max_z"]),
		}
		if not _boxes_overlap(foot_box, head_box):
			continue
		_break_links()
		target._break_links()
		target.linked_fighter = self
		target.link_mode = "lift"
		linked_fighter = target
		link_mode = "target_lift"
		target._set_state(carrier_state, true)
		target.lock_action = false
		target.lock_motion = false
		ground_position = target.ground_position
		velocity.x = 0.0
		velocity.y = 0.0
		velocity.z = 0.0
		z_height = maxf(target.z_height + 56.0, 1.0)
		lock_action = true
		lock_motion = true
		_set_state("be_lift_squat", true)
		target._update_lift_alignment()
		break


func _update_lift_jump_target_from_source() -> void:
	var source: Fighter = airborne_script_source
	if source == null or source.is_defeated():
		_clear_airborne_skill_state()
		lock_action = false
		lock_motion = false
		return
	ground_position = source.ground_position
	facing = source.facing
	velocity = source.velocity
	var carry_height: float = 28.0
	if source.airborne_script == "lift_jump_up":
		carry_height = 56.0
	elif source.airborne_script == "lift_jump_slam":
		carry_height = 10.0
		velocity.x = 0.0
		velocity.y = 0.0
	elif source.airborne_script == "lift_jump_fall":
		carry_height = 30.0
	z_height = maxf(source.z_height + carry_height, 0.0)


func _set_ready() -> void:
	lock_action = false
	lock_motion = false
	current_attack_name = ""
	skill_target = null
	pending_throw_attacker = null
	be_throw_stand_timer = 0.0
	be_lift_stand_timer = 0.0
	_clear_airborne_skill_state()
	state_script_timer = 0.0
	pending_landing_state = ""
	return_to_be_lift_stance_after_attack = false
	buffer_unlock_after_motion = false
	sprint_attack_decel = 0.0
	catch_hold_timer = 0.0
	rest_timer = 0.0
	mach_stomp_loops_left = 0
	ready_timer = READY_TIME
	velocity.x = 0.0
	velocity.y = 0.0
	play_action("ready", true)
	current_state = "ready"


func _start_stand() -> void:
	if is_defeated():
		return
	if linked_fighter != null:
		var other: Fighter = linked_fighter
		match other.current_state:
			"lift_squat":
				return
			"ride", "ride_attack":
				if other.linked_fighter == self:
					other.linked_fighter = null
					other.link_mode = ""
				linked_fighter = null
				link_mode = ""
				other._start_stand()
	lock_action = true
	lock_motion = true
	current_attack_name = "stand_up"
	skill_target = null
	pending_throw_attacker = null
	be_throw_stand_timer = 0.0
	be_lift_stand_timer = 0.0
	_clear_airborne_skill_state()
	state_script_timer = 0.0
	pending_landing_state = ""
	return_to_be_lift_stance_after_attack = false
	buffer_unlock_after_motion = false
	sprint_attack_decel = 0.0
	catch_hold_timer = 0.0
	rest_timer = 0.0
	ready_timer = 0.0
	downed_timer = 0.0
	velocity = Vector3.ZERO
	if control_left_motion:
		facing = -1
	elif control_right_motion:
		facing = 1
	_set_state("squat", true)


func _start_landing_squat() -> void:
	lock_action = true
	lock_motion = true
	current_attack_name = "landing_done"
	state_script_timer = 0.0
	special_state_timer = 0.1
	_reset_attack_controls()
	velocity.x = 0.0
	velocity.y = 0.0
	if control_left_motion:
		facing = -1
	elif control_right_motion:
		facing = 1
	_set_state("squat", true)


func _start_be_lift_stand() -> void:
	if linked_fighter == null or not _is_be_lift_state():
		return
	lock_action = true
	lock_motion = true
	current_attack_name = "be_lift_stand_up"
	be_lift_stand_timer = 0.0
	pending_throw_attacker = null
	_reset_attack_controls()
	velocity = Vector3.ZERO
	_set_state("be_lift_squat", true)


func _start_rest() -> void:
	lock_action = true
	lock_motion = true
	current_attack_name = ""
	pending_throw_attacker = null
	be_throw_stand_timer = 0.0
	be_lift_stand_timer = 0.0
	_clear_airborne_skill_state()
	state_script_timer = 0.0
	pending_landing_state = ""
	return_to_be_lift_stance_after_attack = false
	buffer_unlock_after_motion = false
	sprint_attack_decel = 0.0
	downed_timer = 0.0
	rest_timer = SHORT_REST_TIME
	special_state_timer = 0.0
	velocity = Vector3.ZERO
	_set_state("rest", true)


func _set_state(state_name: String, force: bool = false) -> void:
	if not force and lock_action:
		return
	if state_name.is_empty():
		return
	if not force and current_state == state_name:
		return
	current_state = state_name
	var action_name: String = String(STATE_ACTION_MAP.get(state_name, state_name))
	if not _has_action(action_name):
		if action_name != "stance" and _has_action("stance"):
			action_name = "stance"
		else:
			return
	play_action(action_name, true)


func _has_action(action_name: String) -> bool:
	if not actions.has(action_name):
		return false
	var action_data: Dictionary = actions.get(action_name, {})
	var frames: Array = action_data.get("frames", [])
	return not frames.is_empty()


func _update_motion(delta: float) -> void:
	if hitstun > 0.0 and current_state not in ["hit_fly", "hit_fly_fall", "fall"]:
		velocity.x = move_toward(velocity.x, 0.0, FLOOR_FRICTION * delta)
		velocity.y = move_toward(velocity.y, 0.0, FLOOR_FRICTION * delta)
	elif current_state in ["catch", "ride", "ride_attack", "rest"]:
		velocity.x = 0.0
		velocity.y = 0.0
	elif current_state in ["weak_run", "weak_run_attack"]:
		velocity.y = move_toward(velocity.y, 0.0, FLOOR_FRICTION * delta)
	elif current_state == "be_push":
		velocity.y = move_toward(velocity.y, 0.0, FLOOR_FRICTION * delta)
	elif current_state in ["f_roll", "b_roll"]:
		var next_roll_x: float = velocity.x + (-velocity.x * 4.0) * delta
		if signf(velocity.x) != signf(next_roll_x):
			velocity.x = 0.0
		else:
			velocity.x = next_roll_x
		velocity.y = move_toward(velocity.y, 0.0, FLOOR_FRICTION * delta)
	elif current_state in ["as_attack", "bs_attack"]:
		var sprint_drag: float = sprint_attack_decel if sprint_attack_decel > 0.0 else FLOOR_FRICTION
		velocity.x = move_toward(velocity.x, 0.0, sprint_drag * delta)
		velocity.y = move_toward(velocity.y, 0.0, FLOOR_FRICTION * delta)
	elif z_height <= 0.0:
		if not ["walk", "leftrun", "rightrun", "lift_walk", "lift_run"].has(current_state):
			velocity.x = move_toward(velocity.x, 0.0, FLOOR_FRICTION * delta)
		if not ["walk", "lift_walk"].has(current_state):
			velocity.y = move_toward(velocity.y, 0.0, FLOOR_FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, AIR_FRICTION * delta)
		velocity.y = move_toward(velocity.y, 0.0, AIR_FRICTION * delta)

	ground_position.x += velocity.x * delta
	ground_position.y += velocity.y * delta
	ground_position.x = clampf(ground_position.x, battle_rect.position.x, battle_rect.position.x + battle_rect.size.x)
	ground_position.y = clampf(ground_position.y, battle_rect.position.y, battle_rect.position.y + battle_rect.size.y)


func _update_sprint_attack_state() -> void:
	if not ["as_attack", "bs_attack"].has(current_state):
		return
	if z_height > 0.0:
		return
	if absf(velocity.x) > 26.0 or absf(velocity.y) > 10.0:
		return
	lock_action = false
	lock_motion = false
	velocity.x = 0.0
	velocity.y = 0.0
	sprint_attack_decel = 0.0
	sprint_recovery_timer = 0.16
	control_run = false
	_set_ready()


func _update_special_state() -> void:
	if current_state in ["weak_run", "weak_run_attack"]:
		if special_state_timer > 0.0:
			return
		if pending_landing_state.is_empty():
			pending_landing_state = "f_roll"
		_start_roll_state(pending_landing_state)
		return
	if _is_be_lift_state() and linked_fighter == null and current_attack_name != "be_lift_passive_jump":
		_cancel_state_at_lift()
		return
	if buffer_unlock_after_motion:
		if absf(velocity.x) > 12.0 or absf(velocity.y) > 8.0:
			return
		buffer_unlock_after_motion = false
		special_state_timer = 0.0
		lock_action = false
		lock_motion = false
		return
	if current_state == "half_lying" and current_attack_name == "lift_jump_recover":
		if state_script_timer > 0.0:
			return
		lock_action = false
		lock_motion = false
		current_attack_name = ""
		_set_ready()
		return
	if current_state == "hit" and special_state_timer > 0.0:
		if absf(velocity.x) > 12.0:
			return
		special_state_timer = 0.0
		lock_action = false
		lock_motion = false
		_set_ready()
		return
	if current_state == "squat" and current_attack_name == "landing_done":
		if special_state_timer > 0.0:
			return
		lock_action = true
		lock_motion = true
		current_attack_name = ""
		_set_state("jump_done", true)
		return
	if current_state in ["f_roll", "b_roll"]:
		if state_script_timer > 0.0:
			return
		lock_action = true
		lock_motion = true
		velocity.x = 0.0
		velocity.y = 0.0
		_set_state("tummy" if current_state == "f_roll" else "lying", true)
		downed_timer = 0.0
		be_throw_stand_timer = LONG_REST_TIME
		return
	if current_state == "half_lying" and z_height <= 0.0 and special_state_timer <= 0.0:
		lock_action = true
		lock_motion = true
		_set_state("lying", true)
		downed_timer = 0.0
		be_throw_stand_timer = SHORT_REST_TIME


func _simulate_vertical(delta: float) -> void:
	if pending_state_on_descend == "kick" and velocity.z <= 0.0:
		pending_state_on_descend = ""
		_set_state("kick", true)

	if z_height <= 0.0 and velocity.z <= 0.0:
		z_height = 0.0
		velocity.z = 0.0
		return

	if current_attack_name == "jump_spinkick":
		velocity.z -= (
			ZACC_JUMP_SPINKICK_ASCEND
			if velocity.z > 0.0
			else ZACC_JUMP_SPINKICK_DESCEND
		) * delta
	elif current_state == "bombkick":
		velocity.z -= ZACC_BOMBKICK * delta
	elif current_state == "spinhit":
		velocity.z -= ZACC_SPINHIT * delta
	elif airborne_script in ["hug_jump_rise", "hug_jump_target_rise"]:
		velocity.z -= ZACC_HUG_JUMP * delta
	elif airborne_script in ["hug_jump_self_bounce", "hug_jump_target_bounce"]:
		velocity.z -= ZACC_SKILL_BOUNCE * delta
	elif airborne_script in ["spin_drill_launch", "spin_drill_target_launch"]:
		velocity.z -= ZACC_SPIN_DRILL * delta
	elif airborne_script in ["spin_drill_self_bounce", "spin_drill_target_bounce"]:
		velocity.z -= ZACC_SPIN_DRILL_BOUNCE * delta
	elif airborne_script == "lift_jump_slam":
		velocity.z -= GRAVITY * 5.0 * delta
	elif airborne_script == "long_hit_fly_front_bounce":
		velocity.z -= ZACC_XF_HIT_FLY2 * delta
	else:
		velocity.z -= GRAVITY * delta

	if airborne_script == "long_hit_fly_front":
		if current_state == "hit_fly" and velocity.z <= 20.0:
			_set_state("lying_hit", true)
		elif current_state == "lying_hit" and velocity.z <= -20.0:
			_set_state("hit_fly_fall", true)

	z_height += velocity.z * delta
	if z_height > 0.0:
		return

	z_height = 0.0
	velocity.z = 0.0
	_on_landed()


func _on_landed() -> void:
	match airborne_script:
		"be_push_bounce_1":
			airborne_script = "be_push_bounce_2"
			velocity.z = ZSPEED_BE_PUSH
			z_height = maxf(z_height, 1.0)
			return
		"be_push_bounce_2":
			airborne_script = "be_push_bounce_3"
			velocity.z = ZSPEED_BE_PUSH
			z_height = maxf(z_height, 1.0)
			return
		"be_push_bounce_3":
			_clear_airborne_skill_state()
			if pending_landing_state.is_empty():
				pending_landing_state = "f_roll"
			_start_roll_state(pending_landing_state)
			return
		"hug_jump_rise":
			_on_hug_jump_self_landed()
			return
		"hug_jump_self_bounce":
			_finish_hug_jump_self()
			return
		"hug_jump_target_rise":
			_on_hug_jump_target_landed()
			return
		"hug_jump_target_bounce":
			_finish_hug_jump_target()
			return
		"lift_jump_up", "lift_jump_fall", "lift_jump_slam":
			_finish_lift_jump()
			return
		"spin_drill_launch":
			_on_spin_drill_self_landed()
			return
		"spin_drill_self_bounce":
			_finish_spin_drill_self()
			return
		"spin_drill_target_launch":
			_on_spin_drill_target_landed()
			return
		"spin_drill_target_bounce":
			_finish_spin_drill_target()
			return
		"throw_up_fly":
			_on_throw_up_landed()
			return
		"throw_up_bounce":
			_finish_throw_up()
			return
		"throw_down_slam":
			_on_throw_down_landed()
			return
		"throw_down_bounce":
			_finish_throw_down()
			return
		"long_hit_fly_front":
			_start_frontal_long_hit_fly_bounce()
			return
		"long_hit_fly_front_bounce":
			_finish_frontal_long_hit_fly()
			return
		"ride_jump":
			_finish_ride_jump()
			return
		_:
			pass

	if current_state in ["hit_fly", "hit_fly_fall"]:
		if not pending_landing_state.is_empty():
			_start_roll_state(pending_landing_state)
			_play_sfx("knock_ground", true)
			return
		lock_action = true
		lock_motion = true
		_set_state("lying", true)
		downed_timer = 0.0
		be_throw_stand_timer = SHORT_REST_TIME
		current_attack_name = ""
		attack_chain_count = 0
		attack_chain_timeout = 0.0
		_play_sfx("knock_ground", true)
		return

	if current_state in ["lift_jump", "lift_fall"]:
		lock_action = false
		lock_motion = false
		_set_state("lift_stance", true)
		return

	if current_state == "throw":
		_start_stand()
		return

	if current_state == "be_push":
		if pending_landing_state.is_empty():
			pending_landing_state = "f_roll"
		_start_roll_state(pending_landing_state)
		return

	if current_state in AIR_ATTACK_STATES or current_state in ["jump", "sjump", "fall"]:
		_start_landing_squat()
		landed_recent = LANDED_INPUT_TIME
		return

	if current_state == "kick":
		lock_action = false
		lock_motion = false
		_set_ready()


func _on_throw_up_landed() -> void:
	var attacker: Fighter = pending_throw_attacker
	hit_targets.clear()
	current_attack_name = ""
	_deal_direct_damage_from(attacker, _get_common_throw_damage(true))
	if is_defeated():
		return
	airborne_script = "throw_up_bounce"
	velocity.x *= 0.5
	velocity.y = 0.0
	velocity.z = ZSPEED_XF_HIT_FLY2
	z_height = maxf(z_height, 1.0)


func _finish_throw_up() -> void:
	_clear_airborne_skill_state()
	pending_throw_attacker = null
	lock_action = true
	lock_motion = true
	current_attack_name = ""
	velocity.x = 0.0
	velocity.y = 0.0
	_set_state("lying", true)
	downed_timer = 0.0
	be_throw_stand_timer = BE_THROW_DOWNED_TIME
	hit_targets.clear()


func _on_throw_down_landed() -> void:
	var attacker: Fighter = pending_throw_attacker
	var next_state: String = _get_grounded_reaction_state()
	hit_targets.clear()
	current_attack_name = ""
	_set_state(next_state, true)
	_deal_direct_damage_from(attacker, _get_common_throw_damage(false))
	if is_defeated():
		return
	airborne_script = "throw_down_bounce"
	velocity.x *= 0.2
	velocity.y = 0.0
	velocity.z = ZSPEED_XF_HIT_FLY2
	z_height = maxf(z_height, 1.0)


func _finish_throw_down() -> void:
	var next_state: String = _get_grounded_reaction_state()
	_clear_airborne_skill_state()
	pending_throw_attacker = null
	lock_action = true
	lock_motion = true
	current_attack_name = ""
	velocity.x = 0.0
	velocity.y = 0.0
	_set_state(next_state, true)
	downed_timer = 0.0
	be_throw_stand_timer = BE_THROW_DOWNED_TIME
	hit_targets.clear()


func _finish_ride_jump() -> void:
	var target: Fighter = linked_fighter
	_clear_airborne_skill_state()
	lock_motion = true
	hit_targets.erase("ride_attack_applied")
	if target == null or target.is_defeated():
		lock_action = false
		lock_motion = false
		_start_stand()
		return
	if not _is_rideable_state(target.current_state):
		_release_ride(false)
		lock_action = false
		lock_motion = false
		_start_stand()
		return
	_apply_ride_damage(target, true)
	if linked_fighter == null or target.is_defeated():
		_release_ride(false)
		lock_action = false
		lock_motion = false
		_start_stand()
		return
	_start_ride_attack(false)


func _on_hug_jump_self_landed() -> void:
	var target: Fighter = skill_target
	if target != null and not target.is_defeated():
		_deal_grapple_damage_only(target, _get_role_grapple_damage("hug_jump", target))
	airborne_script = "hug_jump_self_bounce"
	current_attack_name = ""
	lock_action = true
	lock_motion = true
	velocity.x = 0.0
	velocity.y = 0.0
	velocity.z = ZSPEED_SKILL_BOUNCE
	z_height = maxf(z_height, 1.0)
	_set_state("squat", true)


func _finish_hug_jump_self() -> void:
	skill_target = null
	_clear_airborne_skill_state()
	lock_action = false
	lock_motion = false
	_start_stand()


func _on_hug_jump_target_landed() -> void:
	var source: Fighter = airborne_script_source
	var bounce_facing: int = facing
	if source != null:
		bounce_facing = source.facing
	airborne_script = "hug_jump_target_bounce"
	lock_action = true
	lock_motion = true
	velocity.x = float(bounce_facing) * XSPEED_SKILL_BOUNCE
	velocity.y = 0.0
	velocity.z = ZSPEED_SKILL_BOUNCE
	z_height = maxf(z_height, 1.0)


func _finish_hug_jump_target() -> void:
	_clear_airborne_skill_state()
	lock_action = true
	lock_motion = true
	velocity.x = 0.0
	velocity.y = 0.0
	_set_state("lying", true)
	downed_timer = 0.0
	be_throw_stand_timer = SHORT_REST_TIME


func _finish_lift_jump() -> void:
	var target: Fighter = skill_target
	_clear_airborne_skill_state()
	if target != null:
		target._finish_lift_jump_target(self)
	skill_target = null
	current_attack_name = "lift_jump_recover"
	lock_action = true
	lock_motion = true
	velocity = Vector3.ZERO
	state_script_timer = 0.1
	_set_state("half_lying", true)


func _finish_lift_jump_target(attacker: Fighter) -> void:
	_clear_airborne_skill_state()
	current_attack_name = ""
	lock_action = true
	lock_motion = true
	velocity = Vector3.ZERO
	pending_throw_attacker = attacker
	if attacker != null and not is_defeated():
		invulnerable_time = 0.08
		hitstun = HITSTUN_TIME
		hp = max(hp - _reduce_damage_for_state(attacker._get_role_grapple_damage("lift_jump", self)), 0)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			_handle_defeat(attacker)
	if is_defeated():
		return
	_set_state("lying_hit", true)
	state_script_timer = 0.12
	downed_timer = 0.0
	be_throw_stand_timer = SHORT_REST_TIME


func _on_spin_drill_self_landed() -> void:
	var target: Fighter = skill_target
	if target != null and not target.is_defeated():
		_deal_grapple_damage_only(target, _get_role_grapple_damage("spin_drill", target))
	skill_target = null
	current_attack_name = ""
	airborne_script = "spin_drill_self_bounce"
	lock_action = true
	lock_motion = true
	velocity.x = -float(facing) * XSPEED_SPIN_DRILL_BOUNCE
	velocity.y = 0.0
	velocity.z = ZSPEED_SPIN_DRILL_BOUNCE
	z_height = maxf(z_height, 1.0)
	_set_state("fall", true)


func _finish_spin_drill_self() -> void:
	_clear_airborne_skill_state()
	lock_action = false
	lock_motion = false
	_start_stand()


func _on_spin_drill_target_landed() -> void:
	var source: Fighter = airborne_script_source
	var source_facing: int = -facing
	if source != null:
		source_facing = source.facing
	airborne_script = "spin_drill_target_bounce"
	current_attack_name = ""
	lock_action = true
	lock_motion = true
	facing = -source_facing
	velocity.x = float(source_facing) * XSPEED_SPIN_DRILL_BOUNCE
	velocity.y = 0.0
	velocity.z = ZSPEED_SPIN_DRILL_BOUNCE
	z_height = maxf(z_height, 1.0)
	_set_state("lying_hit", true)


func _finish_spin_drill_target() -> void:
	_clear_airborne_skill_state()
	lock_action = true
	lock_motion = true
	velocity.x = 0.0
	velocity.y = 0.0
	_set_state("lying", true)
	downed_timer = 0.0
	be_throw_stand_timer = BE_THROW_DOWNED_TIME


func _start_frontal_long_hit_fly_bounce() -> void:
	airborne_script = "long_hit_fly_front_bounce"
	lock_action = true
	lock_motion = true
	velocity.x = -float(facing) * XSPEED_X_HIT_FLY2
	velocity.y = 0.0
	velocity.z = ZSPEED_XF_HIT_FLY2
	z_height = maxf(z_height, 1.0)
	_set_state("lying_hit", true)


func _finish_frontal_long_hit_fly() -> void:
	_clear_airborne_skill_state()
	lock_action = true
	lock_motion = true
	velocity = Vector3.ZERO
	_set_state("lying", true)
	downed_timer = 0.0
	be_throw_stand_timer = SHORT_REST_TIME


func _update_animation(delta: float) -> void:
	if current_frames.is_empty():
		return
	current_frame_elapsed += delta
	var duration: float = float(current_frame_data.get("duration_sec", 0.1))
	if current_frame_elapsed < duration:
		visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if invulnerable_time > 0.0 and int(Time.get_ticks_msec() / 60.0) % 2 == 0:
			visual.modulate = Color(1.0, 1.0, 1.0, 0.5)
		return
	current_frame_elapsed = 0.0
	if current_state == "mach_stomp" and mach_stomp_loops_left <= 0 and bool(current_frame_data.get("new_attack", false)):
		_finish_action()
		return
	current_frame_index += 1
	if current_frame_index >= current_frames.size():
		if _should_loop_action():
			current_frame_index = 0

		elif _should_hold_last_frame():
			current_frame_index = current_frames.size() - 1
			return
		else:
			_finish_action()
			return
	_apply_frame()


func _should_loop_action() -> bool:
	if current_state in ["defense", "solid_defense", "be_lift_defense", "be_lift_solid_defense"]:
		return control_defense
	if current_state == "mach_stomp":
		return mach_stomp_loops_left > 0
	if current_attack_name == "spin_drill" and current_state == "catch_skill_fa":
		return false

	return bool(actions.get(current_action, {}).get("replay", false))


func _should_hold_last_frame() -> bool:
	if current_frames.is_empty():
		return false
	if airborne_script in ["hug_jump_self_bounce", "hug_jump_target_bounce", "spin_drill_self_bounce", "spin_drill_target_bounce"]:
		return true
	if airborne_script == "long_hit_fly_front_bounce":
		return true
	if current_state in ["f_roll", "b_roll"] and state_script_timer > 0.0:
		return true
	if z_height <= 0.0:
		return false
	if current_state in ["jump", "sjump", "fall", "ride_jump", "hit_fly", "hit_fly_fall", "lift_jump", "lift_fall", "throw"]:
		return not _should_loop_action()
	if current_attack_name in ["hug_jump", "lift_jump", "spin_drill"] and current_state in ["catch_skill_fa", "catch_skill_ba", "catch_skill_bb", "catch_skill_fb"]:
		return true
	if current_attack_name == "":
		return false
	return current_state in AIR_ATTACK_STATES and not _should_loop_action()


func _finish_action() -> void:
	match current_state:
		"ready":
			if ready_timer <= 0.0:
				_set_state("stance", true)
			else:
				current_frame_index = 0
				current_frame_elapsed = 0.0
				_apply_frame()
		"walk", "stance", "leftrun", "rightrun", "defense", "solid_defense", "lying", "tummy", "rest", "be_catch", "back_be_catch", "half_lying", "half_stance", "be_lift_lying", "be_lift_tummy", "be_lift_stance":
			if current_state in ["defense", "solid_defense"] and not control_defense:
				_set_ready()
			elif current_state == "half_lying" and current_attack_name == "lift_jump_recover":
				play_action(current_action, true)
			elif current_state == "be_lift_stance" and linked_fighter == null:
				_set_ready()
			else:
				play_action(current_action, true)
			return
		"be_lift_defense", "be_lift_solid_defense":
			if linked_fighter == null:
				_set_ready()
			elif not control_defense:
				lock_action = false
				_set_state("be_lift_stance", true)
			else:
				play_action(current_action, true)
			return
		"lying_hit", "tummy_hit":
			if state_script_timer > 0.0:
				play_action(current_action, true)
				return
			lock_action = true
			lock_motion = true
			_set_state("tummy" if _is_tummy_state() else "lying", true)
			downed_timer = maxf(downed_timer, 0.22)
		"be_lift_lying_hit", "be_lift_tummy_hit":
			if state_script_timer > 0.0:
				play_action(current_action, true)
				return
			lock_action = true
			lock_motion = true
			_set_state("be_lift_tummy" if _is_tummy_state() else "be_lift_lying", true)
		"lying_dying", "tummy_dying":
			lock_action = true
			lock_motion = true
			play_action(current_action, true)
		"ssquat":
			lock_action = false
			lock_motion = true
			if z_height > 0.0 or velocity.z > 0.0:
				_set_state("sjump", true)
			else:
				_set_ready()
		"squat":
			if current_attack_name == "landing_done" and special_state_timer > 0.0:
				play_action(current_action, true)
				return
			if current_attack_name == "landing_done":
				lock_action = true
				lock_motion = true
				current_attack_name = ""
				_set_state("jump_done", true)
				return
			lock_action = false
			lock_motion = false
			if current_attack_name == "stand_up":
				current_attack_name = ""
				_reset_attack_controls()
			_set_ready()
		"lift_squat":
			if linked_fighter == null:
				lock_action = false
				lock_motion = false
				_set_ready()
			else:
				lock_action = false
				lock_motion = false
				_set_state("lift_stance", true)
		"be_lift_squat":
			lock_motion = true
			if linked_fighter != null and _is_be_lift_state():
				lock_action = false
				if current_attack_name == "be_lift_stand_up":
					current_attack_name = ""
					_reset_attack_controls()
				_set_state("be_lift_stance", true)
			elif z_height > 0.0 or velocity.z > 0.0:
				lock_action = false
				current_attack_name = ""
				_clear_airborne_skill_state()
				_set_state("sjump", true)
			else:
				lock_action = false
				lock_motion = false
				_set_ready()
		"catch":
			if linked_fighter == null:
				lock_action = false
				lock_motion = false
				_set_ready()
			else:
				play_action("catch", true)
		"throw":
			if z_height > 0.0:
				lock_action = true
				lock_motion = false
				return
			velocity.x = 0.0
			velocity.y = 0.0
			lock_action = false
			lock_motion = false
			current_attack_name = ""
			_set_ready()
		"ride":
			if linked_fighter == null:
				hit_targets.erase("ride_attack_applied")
				lock_action = false
				lock_motion = false
				_set_ready()
			else:
				current_attack_name = ""
				play_action("ride", true)
		"ride_attack":
			lock_action = false
			lock_motion = true
			hit_targets.erase("ride_attack_applied")
			if linked_fighter != null:
				current_attack_name = ""
				_set_state("ride", true)
			else:
				lock_motion = false
				current_attack_name = ""
				_set_ready()
		"be_lift_a_attack", "be_lift_b_attack", "be_lift_mach_a_attack", "be_lift_mach_b_attack":
			lock_action = false
			lock_motion = true
			if linked_fighter != null:
				current_attack_name = ""
				_set_state("be_lift_stance", true)
			else:
				lock_motion = false
				_set_ready()
		"lift_stance", "lift_walk", "lift_run":
			if linked_fighter == null:
				lock_action = false
				lock_motion = false
				_set_ready()
			else:
				play_action(current_action, true)
		"catch_skill_fa", "catch_skill_ba", "catch_skill_bb", "catch_skill_fb":
			if current_attack_name in ["hug_jump", "lift_jump", "spin_drill"]:
				play_action(current_action, true)
				return
			_break_links()
			lock_action = false
			lock_motion = false
			_set_ready()
		"weak_run", "weak_run_attack", "be_push":
			if current_state == "be_push" and (z_height > 0.0 or state_script_timer > 0.0):
				play_action(current_action, true)
				return
			if current_state in ["weak_run", "weak_run_attack"]:
				play_action(current_action, true)
				return
			lock_action = false
			lock_motion = false
			_set_ready()
		"jump_done":
			lock_action = false
			lock_motion = false
			_set_ready()
		"a_attack", "b_attack", "mach_a_attack", "mach_b_attack", "as_attack", "bs_attack", "jump_elbow", "jump_stomp", "mach_stomp":
			lock_action = false
			lock_motion = false
			if current_state in ["as_attack", "bs_attack"]:
				velocity.x = 0.0
				velocity.y = 0.0
				sprint_attack_decel = 0.0
				sprint_recovery_timer = 0.16
				control_run = false
			if current_state == "mach_stomp":
				current_attack_name = ""
				mach_stomp_loops_left = 0
				special_state_timer = 0.0
			if return_to_be_lift_stance_after_attack and linked_fighter != null:
				return_to_be_lift_stance_after_attack = false
				lock_motion = true
				_set_state("be_lift_stance", true)
				return
			_set_ready()
		"final_blow":
			lock_action = false
			lock_motion = false
			if return_to_be_lift_stance_after_attack and linked_fighter != null:
				return_to_be_lift_stance_after_attack = false
				lock_motion = true
				current_attack_name = ""
				_set_state("be_lift_stance", true)
				return
			_set_ready()
		"aj_attack", "bj_attack", "maj_attack", "mbj_attack", "asj_attack", "bsj_attack", "big_elbow", "guillotine":
			lock_action = false
			if z_height > 0.0:
				_set_state("sjump" if current_state in ["asj_attack", "bsj_attack"] else "jump", true)
			else:
				_set_ready()
		"spinhit", "bombkick", "kick", "roll_down", "roll_up", "f_roll", "b_roll":
			if z_height <= 0.0:
				if current_state in ["f_roll", "b_roll"] and state_script_timer > 0.0:
					play_action(current_action, true)
					return
				lock_action = false
				lock_motion = false
				_set_ready()
		"hit":
			if special_state_timer > 0.0 and absf(velocity.x) > 12.0:
				play_action(current_action, true)
				return
			lock_action = false
			lock_motion = false
			if attack_chain_count >= ATTACK_CHAIN_REST_THRESHOLD:
				_start_rest()
			else:
				_set_ready()
		"hit_fly", "hit_fly_fall":
			if z_height > 0.0:
				lock_action = true
				lock_motion = true
				return
			lock_action = true
			lock_motion = true
			_set_state("lying", true)
			downed_timer = 0.0
			be_throw_stand_timer = SHORT_REST_TIME
		_:
			lock_action = false
			lock_motion = false
			_set_ready()


func play_action(action_name: String, reset_locks: bool = false) -> void:
	var action_data: Dictionary = actions.get(action_name, {})
	if action_data.is_empty():
		if action_name != "stance" and actions.has("stance"):
			play_action("stance", reset_locks)
		return
	if reset_locks:
		hit_targets.clear()
	current_action = action_name
	current_frames = action_data.get("frames", [])
	current_frame_index = 0
	current_frame_elapsed = 0.0
	role_skill_event_frame = -1
	_apply_frame()


func _apply_frame() -> void:
	if current_frames.is_empty():
		return
	current_frame_data = current_frames[current_frame_index]
	var texture_path: String = "res://%s" % String(current_frame_data.get("texture", ""))
	var texture: Texture2D = _load_texture(texture_path)
	visual.texture = texture
	var frame_flip: bool = bool(current_frame_data.get("horiz_flip", false))
	var final_flip: bool = (facing < 0) != frame_flip
	if texture != null:
		var offset: Array = current_frame_data.get("offset", [0, 0])
		var root_offset: Vector2 = Vector2(float(offset[0]), float(offset[1]))
		var visual_x: float = -root_offset.x
		if final_flip:
			visual_x = root_offset.x
		visual.position = Vector2(visual_x, -texture.get_height() / 2.0 - root_offset.y)
	visual.flip_h = final_flip
	var is_new_attack: bool = bool(current_frame_data.get("new_attack", false))
	var skip_attack_frame: bool = false
	if is_new_attack:
		if current_state == "mach_stomp":
			if mach_stomp_loops_left <= 0:
				skip_attack_frame = true
			else:
				mach_stomp_loops_left -= 1
		if not skip_attack_frame:
			hit_targets.clear()
			if current_attack_name in ["mach_a_attack", "mach_b_attack"] and _attack_sfx_hit_count < 2:
				_play_sfx("attack")
				_attack_sfx_hit_count += 1
	if not skip_attack_frame and (_frame_has_attack_box() or is_new_attack):
		_try_attack()


func _sync_scene_position() -> void:
	position = Vector2(ground_position.x, ground_position.y - z_height)
	z_index = int(ground_position.y)
	var shadow_ground_factor: float = clampf(1.0 - z_height / 260.0, 0.0, 1.0)
	shadow.position = Vector2(0.0, z_height + 8.0)
	shadow.scale = Vector2(
		lerpf(0.72, 1.5, shadow_ground_factor),
		lerpf(0.34, 0.78, shadow_ground_factor)
	)
	shadow.modulate = Color(0.0, 0.0, 0.0, lerpf(0.22, 0.9, shadow_ground_factor))


func _load_texture(path: String) -> Texture2D:
	if texture_cache.has(path):
		return texture_cache[path] as Texture2D
	var texture: Texture2D = load(path)
	texture_cache[path] = texture
	return texture


func _try_attack() -> void:
	var valid_targets: Array[Fighter] = _get_active_targets()
	if valid_targets.is_empty():
		return
	var attack_box: Array = current_frame_data.get("attack_box", [])
	if attack_box.size() < 6 or int(attack_box[3]) <= 0:
		return
	var own_box: Dictionary = _box_to_world(attack_box, true)
	for target in valid_targets:
		var target_key: String = str(target.get_instance_id())
		if hit_targets.has(target_key):
			continue
		var target_box: Dictionary = target._box_to_world(target.current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
		if _boxes_overlap(own_box, target_box) or _fallback_attack_hits(target):
			hit_targets[target_key] = true
			var damage: int = _get_attack_damage()
			var effect_type: String = _get_attack_effect(target)
			target.receive_hit(damage, self, effect_type)
			if current_attack_name == "sprint_jump_b_attack" and _has_skill("tornado_attack"):
				_start_second_spinhit()
			break


func _frame_has_attack_box() -> bool:
	var attack_box: Array = current_frame_data.get("attack_box", [])
	return attack_box.size() >= 6 and float(attack_box[3]) > 0.0


func receive_hit(damage: int, attacker: Fighter, effect_type: String = "normal") -> void:
	if invulnerable_time > 0.0 or is_defeated():
		return
	skill_target = null
	var preserve_prone_recovery_timer: bool = (
		effect_type in ["normal", "normal2", "long_fly"]
		and current_state in ["lying", "lying_hit", "tummy", "tummy_hit", "be_lift_lying", "be_lift_lying_hit", "be_lift_tummy", "be_lift_tummy_hit"]
	)
	if not preserve_prone_recovery_timer:
		be_throw_stand_timer = 0.0
		be_lift_stand_timer = 0.0
	return_to_be_lift_stance_after_attack = false
	_clear_airborne_skill_state()
	var preserve_be_lift_prone_link: bool = effect_type in ["normal", "normal2", "long_fly"] and _is_be_lift_prone_state()
	if not preserve_prone_recovery_timer:
		if not preserve_be_lift_prone_link:
			_cancel_linked_combat_state()
			_break_links()
	var mitigated: int = _reduce_damage_for_state(damage)
	last_damage_attack_name = attacker.current_attack_name if attacker != null else ""
	match effect_type:
		"long_fly":
			_apply_long_hit_fly(attacker)
			_play_sfx("hit_fly", true)
		"short_fly":
			_apply_short_hit_fly(attacker, "")
			_play_sfx("hit_fly", true)
		"touch_hit_fly":
			_apply_touch_hit_fly(attacker)
			_play_sfx("hit_fly", true)
		"bump_to_fly":
			_apply_bump_to_fly(attacker)
			_play_sfx("hit_fly", true)
		"normal2":
			_apply_normal2_effect(attacker)
			_play_sfx("hit", true)
		_:
			_apply_normal_effect(attacker)
			_play_sfx("hit", true)
	invulnerable_time = 0.12
	hp = max(hp - mitigated, 0)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		_handle_defeat(attacker)


func _handle_defeat(attacker: Fighter) -> void:
	hp = 0
	skill_target = null
	pending_throw_attacker = null
	be_throw_stand_timer = 0.0
	be_lift_stand_timer = 0.0
	_clear_airborne_skill_state()
	_break_links()
	attack_chain_count = 0
	attack_chain_timeout = 0.0
	state_script_timer = 0.0
	pending_landing_state = ""
	return_to_be_lift_stance_after_attack = false
	buffer_unlock_after_motion = false
	lock_action = true
	lock_motion = true
	velocity = Vector3.ZERO
	if attacker != null:
		facing = -attacker.facing
	var defeat_state: String = "tummy_dying" if _is_tummy_state() and _has_action("tummy_dying") else "lying_dying"
	if not _has_action(defeat_state):
		defeat_state = "tummy" if _is_tummy_state() and _has_action("tummy") else "lying"
	_set_state(defeat_state, true)
	defeated.emit(self)


func _is_tummy_state(state_name: String = "") -> bool:
	var probe_state: String = state_name if not state_name.is_empty() else current_state
	return probe_state in [
		"tummy",
		"tummy_hit",
		"tummy_hit_fly",
		"tummy_dying",
		"be_lift_tummy",
		"be_lift_tummy_hit",
	]


func _get_attack_damage() -> int:
	var stats: Dictionary = role_data.get("stats", {})
	var punch: float = float(stats.get("punch", 60))
	var kick: float = float(stats.get("kick", 90))
	var throw_value: float = float(stats.get("throw", 80))
	match current_attack_name:
		"mach_a_attack", "jump_mach_a_attack":
			return int(round(punch / 20.0))
		"mach_b_attack":
			return int(round(kick / 20.0))
		"jump_b_attack", "jump_mach_b_attack":
			return int(round(kick / 10.0))
		"sprint_a_attack":
			return int(round(punch / 3.0))
		"sprint_b_attack":
			return int(round(kick / 3.0))
		"sprint_jump_a_attack":
			return int(round(punch / 3.0))
		"sprint_jump_b_attack":
			return int(round(kick / 2.0))
		"bombkick":
			return int(round(50.0 + kick / 4.0))
		"spinhit", "tornado_attack":
			return int(round(30.0 + punch / 4.0 + kick / 4.0))
		"jump_spinkick":
			return int(round(40.0 + kick / 4.0))
		"jump_elbow":
			return int(round(punch / 6.0))
		"big_elbow":
			return int(round(20.0 + punch / 3.0))
		"jump_stomp", "mach_stomp":
			return int(round(kick / 6.0))
		"guillotine":
			return int(round(20.0 + kick / 3.0))
		"ride_a_attack":
			return int(round(10.0 + punch / 8.0))
		"ride_b_attack":
			return int(round(20.0 + (punch + kick) / 8.0))
		"throw":
			return int(round(20.0 + throw_value / 2.0))
		"final_blow":
			return int(round((punch / 4.0 + kick / 4.0) * 2.0))
		"a_throw", "b_throw":
			return int(round(20.0 + throw_value / 2.0))
		"a_attack":
			return int(round(punch / 10.0))
		"jump_a_attack":
			return int(round(punch / 20.0))
		_:
			if current_attack_name == "b_attack":
				return int(round(kick / 10.0))
			if current_attack_name.contains("kick"):
				return int(round(kick / 6.0))
			return int(round(punch / 10.0))


func _get_common_throw_damage(_upward: bool) -> int:
	var throw_value: float = float(role_data.get("stats", {}).get("throw", 80))
	return int(round(20.0 + throw_value * 0.5))


func _deal_direct_damage_from(attacker: Fighter, damage: int) -> void:
	if is_defeated():
		return
	var mitigated: int = _reduce_damage_for_state(damage)
	last_damage_attack_name = attacker.current_attack_name if attacker != null else ""
	invulnerable_time = maxf(invulnerable_time, 0.12)
	hp = max(hp - mitigated, 0)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		_handle_defeat(attacker)


func _reduce_damage_for_state(damage: int, state_name: String = "") -> int:
	if damage <= 0:
		return 0
	var defense_value: float = float(role_data.get("stats", {}).get("defense", 100))
	var reduce: float = 1.0 - 100.0 / (defense_value + 100.0)
	var probe_state: String = state_name if not state_name.is_empty() else current_state
	match probe_state:
		"solid_defense":
			reduce += 0.40
		"defense", "tummy", "tummy_hit", "lying", "lying_hit", "be_lift_tummy", "be_lift_tummy_hit", "be_lift_lying", "be_lift_lying_hit":
			reduce += 0.20
		"f_roll", "b_roll":
			reduce += 0.10
		_:
			pass
	reduce = minf(reduce, 0.95)
	return max(damage - int(damage * reduce), 0)


func _get_grounded_reaction_state(state_name: String = "") -> String:
	return "tummy_hit" if _is_tummy_state(state_name) else "lying_hit"


func _get_grounded_idle_state(state_name: String = "") -> String:
	return "tummy" if _is_tummy_state(state_name) else "lying"


func _apply_ride_damage(target: Fighter, is_jump: bool) -> void:
	var reaction_state: String = target._get_grounded_reaction_state()
	target.be_throw_stand_timer = RIDE_HIT_DOWNED_TIME
	target.be_lift_stand_timer = 0.0
	target.rest_timer = 0.0
	target.current_attack_name = ""
	target.lock_action = true
	target.lock_motion = true
	target._set_state(reaction_state, true)
	target._deal_direct_damage_from(self, _get_ride_attack_damage(is_jump, target))
	if target.is_defeated():
		return
	target.state_script_timer = 0.12 if is_jump else 0.08
	target.downed_timer = RIDE_HIT_DOWNED_TIME


func _get_bumped_damage(attacker: Fighter) -> int:
	var base_damage: float = 50.0
	if attacker != null:
		base_damage += float(attacker.role_data.get("stats", {}).get("defense", 100)) * 0.5
	return int(round(base_damage))


func _get_ride_attack_damage(is_jump: bool, _target: Fighter) -> int:
	var stats: Dictionary = role_data.get("stats", {})
	var punch: float = float(stats.get("punch", 60))
	var kick: float = float(stats.get("kick", 90))
	if is_jump:
		return int(round(20.0 + (punch + kick) * 0.125))
	return int(round(10.0 + punch * 0.125))


func _get_role_grapple_damage(skill_name: String, target: Fighter) -> int:
	var stats: Dictionary = role_data.get("stats", {})
	var punch: float = float(stats.get("punch", 60))
	var kick: float = float(stats.get("kick", 90))
	var throw_value: float = float(stats.get("throw", 80))
	var max_hp_value: float = float(stats.get("max_hp", max_hp))
	var missing_hp_ratio: float = 0.0
	if max_hp_value > 0.0:
		missing_hp_ratio = (max_hp_value - float(hp)) / max_hp_value
	var target_max_hp: float = float(target.max_hp)
	var target_hp: float = float(target.hp)
	var target_defense: float = float(target.role_data.get("stats", {}).get("defense", 100))
	match skill_name:
		"hug_front_put":
			return int(round(throw_value + target_max_hp * 0.05))
		"hug_back_put":
			var hug_back_damage: float = throw_value + target_max_hp * 0.05
			hug_back_damage += hug_back_damage * missing_hp_ratio
			return int(round(hug_back_damage))
		"elbow":
			return int(round(20.0 + punch * 0.2 + punch * missing_hp_ratio + punch / 3.0))
		"kneehit":
			return int(round(kick * missing_hp_ratio + kick * 0.2 + throw_value * 0.5))
		"hug_jump":
			return int(round(target_defense + target_max_hp * 0.05))
		"lift_jump":
			return int(round(target_defense + target_max_hp * 0.05 + throw_value))
		"judo":
			return int(round(punch + throw_value))
		"back_judo":
			return int(round((punch + kick) * 0.5 + throw_value))
		"spin_drill":
			return int(clampf(target_hp * 0.5, 100.0, 800.0))
		_:
			return int(round(throw_value))


func _get_attack_effect(target: Fighter = null) -> String:
	match current_attack_name:
		"jump_a_attack", "jump_b_attack", "jump_mach_a_attack", "jump_mach_b_attack", "jump_elbow", "jump_stomp", "mach_stomp":
			return "normal2"
		"sprint_a_attack", "sprint_b_attack":
			if target != null and target.current_state in ["lying", "lying_hit", "tummy", "tummy_hit", "rest", "half_lying"]:
				return "normal"
			return "bump_to_fly"
		"bombkick", "spinhit", "jump_spinkick", "guillotine", "big_elbow", "final_blow":
			return "long_fly"
		"sprint_jump_a_attack", "sprint_jump_b_attack":
			return "short_fly"
		_:
			return "normal"


func _box_to_world(box: Array, is_attack: bool) -> Dictionary:
	return _box_to_world_with_pose(box, is_attack, ground_position, z_height, facing)


func _box_to_world_with_pose(box: Array, is_attack: bool, origin: Vector2, origin_z: float, orientation: int) -> Dictionary:
	var x: float = float(box[0])
	var y: float = float(box[1])
	var z: float = float(box[2])
	var width: float = float(box[3])
	var depth: float = float(box[4])
	var height: float = float(box[5])
	var min_x: float = origin.x + x
	if orientation < 0:
		min_x = origin.x - x - width
	if not is_attack and width <= 0.0:
		width = 32.0
	if depth <= 0.0:
		depth = 12.0
	if height <= 0.0:
		height = 56.0
	return {
		"min_x": min_x,
		"max_x": min_x + width,
		"min_y": origin.y + y,
		"max_y": origin.y + y + depth,
		"min_z": origin_z + z,
		"max_z": origin_z + z + height,
	}


func _boxes_overlap(a: Dictionary, b: Dictionary) -> bool:
	return (
		float(a["min_x"]) - HITBOX_EXPAND_X < float(b["max_x"]) and
		float(a["max_x"]) + HITBOX_EXPAND_X > float(b["min_x"]) and
		float(a["min_y"]) - HITBOX_EXPAND_Y < float(b["max_y"]) and
		float(a["max_y"]) + HITBOX_EXPAND_Y > float(b["min_y"]) and
		float(a["min_z"]) - HITBOX_EXPAND_Z < float(b["max_z"]) and
		float(a["max_z"]) + HITBOX_EXPAND_Z > float(b["min_z"])
	)


func _get_active_targets() -> Array[Fighter]:
	var targets: Array[Fighter] = []
	for target in opponents:
		if target != null and target != self and not target.is_defeated():
			targets.append(target)
	return targets


func _get_action_target(action_name: String, required_states: Array = []) -> Fighter:
	if not _has_action(action_name):
		return null
	var frames: Array = actions.get(action_name, {}).get("frames", [])
	if frames.is_empty():
		return null
	for target in _get_active_targets():
		if target.linked_fighter != null:
			continue
		if not required_states.is_empty() and not required_states.has(target.current_state):
			continue
		var target_box: Dictionary = target._box_to_world(target.current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
		for frame_data in frames:
			var attack_box: Array = frame_data.get("attack_box", [])
			if attack_box.size() < 6 or float(attack_box[3]) <= 0.0:
				continue
			var own_box: Dictionary = _box_to_world_with_pose(attack_box, true, ground_position, z_height, facing)
			if _boxes_overlap(own_box, target_box):
				return target
	return null


func _get_primary_target() -> Fighter:
	var best_target: Fighter = null
	var best_distance: float = INF
	for target in _get_active_targets():
		var distance: float = ground_position.distance_squared_to(target.ground_position)
		if distance < best_distance:
			best_distance = distance
			best_target = target
	return best_target


func _get_ground_target() -> Fighter:
	for target in _get_active_targets():
		if target.linked_fighter != null:
			continue
		if absf(target.z_height - z_height) > 18.0:
			continue
		if target.current_state in ["lying", "lying_hit", "tummy", "tummy_hit", "rest", "half_lying"] and ground_position.distance_to(target.ground_position) < 52.0:
			return target
	return null


func _get_lift_target() -> Fighter:
	for target in _get_active_targets():
		if target.linked_fighter != null:
			continue
		if absf(ground_position.x - target.ground_position.x) >= 22.0:
			continue
		if absf(ground_position.y - target.ground_position.y) > 10.0:
			continue
		if absf(target.z_height - z_height) > 18.0:
			continue
		if _is_liftable_state(target.current_state):
			return target
	return null


func _is_liftable_state(state_name: String) -> bool:
	return state_name in ["lying", "lying_hit", "tummy", "tummy_hit"]


func _get_be_lift_carrier_state(state_name: String) -> String:
	match state_name:
		"ready", "stance":
			return "lift_stance"
		"walk":
			return "lift_walk"
		"leftrun", "rightrun":
			return "lift_run"
		_:
			return ""


func _get_ride_target() -> Fighter:
	for target in _get_active_targets():
		if target.linked_fighter != null:
			continue
		if absf(ground_position.x - target.ground_position.x) >= 22.0:
			continue
		if absf(ground_position.y - target.ground_position.y) > 10.0:
			continue
		if absf(target.z_height - z_height) > 18.0:
			continue
		if _is_rideable_state(target.current_state):
			return target
	return null


func _is_rideable_state(state_name: String) -> bool:
	return state_name in ["lying", "lying_hit", "tummy", "tummy_hit"]


func _get_rest_target_in_front() -> Fighter:
	for target in _get_active_targets():
		if target.linked_fighter != null:
			continue
		if target.current_state != "rest":
			continue
		if target.z_height < z_height or target.z_height > z_height + 72.0:
			continue
		var dx: float = target.ground_position.x - ground_position.x
		if facing < 0 and (dx > -8.0 or dx < -24.0):
			continue
		if facing > 0 and (dx < 8.0 or dx > 24.0):
			continue
		if absf(target.ground_position.y - ground_position.y) > 10.0:
			continue
		return target
	return null


func _get_rush_catch_target(skill_name: String = "") -> Fighter:
	if not ["ready", "stance", "walk"].has(current_state):
		return null
	for target in _get_active_targets():
		if not ["as_attack", "bs_attack", "weak_run"].has(target.current_state):
			continue
		if target.linked_fighter != null:
			continue
		if target.facing == facing:
			continue
		if absf(target.z_height - z_height) > 15.0:
			continue
		if absf(target.ground_position.x - ground_position.x) > 42.0:
			continue
		if absf(target.ground_position.y - ground_position.y) > 18.0:
			continue
		if skill_name == "spin_drill":
			return target
		if skill_name in ["hug_front_put", "elbow", "hug_jump", "judo"]:
			return target
		return target
	return null


func _is_in_lift_state() -> bool:
	return ["lift_squat", "lift_stance", "lift_walk", "lift_run", "lift_jump", "lift_fall"].has(current_state)


func _is_be_lift_state(state_name: String = "") -> bool:
	var probe_state: String = state_name if not state_name.is_empty() else current_state
	return probe_state in [
		"be_lift_lying",
		"be_lift_lying_hit",
		"be_lift_tummy",
		"be_lift_tummy_hit",
		"be_lift_squat",
		"be_lift_stance",
		"be_lift_defense",
		"be_lift_solid_defense",
		"be_lift_a_attack",
		"be_lift_b_attack",
		"be_lift_mach_a_attack",
		"be_lift_mach_b_attack",
	]


func _is_staged_grapple_active() -> bool:
	return current_attack_name in ["hug_front_put", "hug_back_put", "elbow", "kneehit", "judo", "back_judo"]


func _update_linked_state(_delta: float) -> void:
	if linked_fighter == null:
		return
	if linked_fighter.is_defeated():
		_break_links()
		return
	if link_mode == "catch":
		if not _is_staged_grapple_active():
			_update_catch_alignment()
	elif link_mode == "lift":
		_update_lift_alignment()
	elif link_mode == "ride":
		if not _can_attack_ride_target() and not (linked_fighter.current_state in ["lying", "tummy", "rest", "half_lying"] and linked_fighter.link_mode == "target_ride"):
			_release_ride(false)
			return
		if current_state == "ride_jump":
			ground_position = linked_fighter.ground_position
			velocity.x = 0.0
			velocity.y = 0.0
			return
		_update_ride_alignment()


func _update_catch_alignment() -> void:
	if linked_fighter == null:
		return
	var offset_x: float = 30.0 * float(facing)
	var caught_back: bool = linked_fighter.facing == facing
	var target_state: String = "be_catch"
	if caught_back:
		offset_x = 25.0 * float(facing)
		target_state = "back_be_catch"
	if linked_fighter.current_state != target_state:
		linked_fighter._set_state(target_state, true)
	linked_fighter.ground_position = Vector2(ground_position.x + offset_x, ground_position.y)
	linked_fighter.velocity = Vector3.ZERO
	linked_fighter.z_height = z_height
	linked_fighter.lock_action = true
	linked_fighter.lock_motion = true


func _update_lift_alignment() -> void:
	if linked_fighter == null:
		return
	var carry_height: float = 56.0
	if current_state == "lift_squat":
		carry_height = 20.0
	var target_state: String = linked_fighter.current_state
	linked_fighter.ground_position = ground_position
	linked_fighter.velocity = Vector3.ZERO
	linked_fighter.z_height = z_height + carry_height
	linked_fighter.lock_motion = true
	match target_state:
		"be_lift_stance", "be_lift_defense", "be_lift_solid_defense":
			linked_fighter.lock_action = false
		"be_lift_a_attack", "be_lift_b_attack", "be_lift_mach_a_attack", "be_lift_mach_b_attack":
			pass
		_:
			linked_fighter.lock_action = true


func _update_ride_alignment() -> void:
	if linked_fighter == null:
		return
	ground_position = linked_fighter.ground_position
	z_height = linked_fighter.z_height + 18.0
	velocity = Vector3.ZERO
	lock_motion = true
	linked_fighter.lock_action = true
	linked_fighter.lock_motion = true
	linked_fighter.linked_fighter = self
	linked_fighter.link_mode = "target_ride"


func _link_with(target: Fighter, mode: String) -> void:
	_break_links()
	target._break_links()
	linked_fighter = target
	link_mode = mode
	target.linked_fighter = self
	target.link_mode = "target_" + mode
	catch_hold_timer = 2.0 if mode == "catch" else 0.0


func _finish_catch_timeout() -> void:
	if linked_fighter == null:
		link_mode = ""
		catch_hold_timer = 0.0
		lock_action = false
		lock_motion = false
		_set_ready()
		return
	var target: Fighter = linked_fighter
	linked_fighter = null
	link_mode = ""
	catch_hold_timer = 0.0
	lock_action = false
	lock_motion = false
	_set_ready()
	target.linked_fighter = null
	target.link_mode = ""
	target.lock_action = false
	target.lock_motion = true
	if not target.is_defeated():
		target._start_rest()


func _release_catch(set_target_rest: bool, unlock_self: bool = true, unlock_target: bool = true) -> void:
	if linked_fighter == null:
		link_mode = ""
		catch_hold_timer = 0.0
		return
	var target: Fighter = linked_fighter
	linked_fighter = null
	link_mode = ""
	catch_hold_timer = 0.0
	if unlock_self:
		lock_action = false
		lock_motion = false
	target.linked_fighter = null
	target.link_mode = ""
	if unlock_target:
		target.lock_action = false
		target.lock_motion = false
	if set_target_rest and not target.is_defeated():
		target._start_rest()


func _release_ride(set_target_rest: bool, unlock_self: bool = true) -> void:
	if linked_fighter == null:
		link_mode = ""
		return
	var target: Fighter = linked_fighter
	linked_fighter = null
	link_mode = ""
	if unlock_self:
		lock_motion = false
	target.linked_fighter = null
	target.link_mode = ""
	target.lock_action = false
	target.lock_motion = false
	if is_inf(target.downed_timer):
		target.downed_timer = 0.18
	if is_inf(target.be_throw_stand_timer):
		target.be_throw_stand_timer = 0.0
	if set_target_rest and not target.is_defeated():
		target._start_rest()


func _break_links() -> void:
	skill_target = null
	be_throw_stand_timer = 0.0
	be_lift_stand_timer = 0.0
	return_to_be_lift_stance_after_attack = false
	buffer_unlock_after_motion = false
	_clear_airborne_skill_state()
	if linked_fighter == null:
		link_mode = ""
		catch_hold_timer = 0.0
		return
	var target: Fighter = linked_fighter
	linked_fighter = null
	link_mode = ""
	catch_hold_timer = 0.0
	if target.linked_fighter == self:
		target.linked_fighter = null
		target.link_mode = ""
		target.be_throw_stand_timer = 0.0
		target.be_lift_stand_timer = 0.0
		target._clear_airborne_skill_state()
		target.lock_action = false
		target.lock_motion = false


func _apply_grapple_damage(target: Fighter, damage: int, effect_type: String) -> void:
	var mitigated: int = target._reduce_damage_for_state(damage)
	target.last_damage_attack_name = current_attack_name
	target.invulnerable_time = 0.12
	target.current_attack_name = ""
	target.hitstun = HITSTUN_TIME
	target.hp = max(target.hp - mitigated, 0)
	target.hp_changed.emit(target.hp, target.max_hp)
	match effect_type:
		"long_fly":
			target.velocity.x = float(facing) * 240.0
			target.velocity.z = JUMP_SPEED * 0.7
		"short_fly":
			target.velocity.x = float(facing) * 160.0
			target.velocity.z = JUMP_SPEED * 0.35
		_:
			target.velocity.x = float(facing) * 120.0
	if target.hp <= 0:
		target._handle_defeat(self)


func _cancel_linked_combat_state() -> void:
	if linked_fighter == null:
		return
	if _cancel_state_at_catch():
		return
	if _cancel_state_at_be_catch():
		return
	_cancel_state_at_lift()


func _cancel_state_at_catch() -> bool:
	var target: Fighter = linked_fighter
	if target == null:
		return false
	match current_state:
		"catch":
			target.linked_fighter = null
			target.link_mode = ""
			linked_fighter = null
			link_mode = ""
			catch_hold_timer = 0.0
			target.lock_action = true
			target.lock_motion = true
			if not target.is_defeated():
				target._start_rest()
			return true
		"catch_skill_fa", "catch_skill_ba", "catch_skill_bb", "catch_skill_fb":
			target.linked_fighter = null
			target.link_mode = ""
			linked_fighter = null
			link_mode = ""
			catch_hold_timer = 0.0
			target.lock_action = true
			target.lock_motion = true
			if not target.is_defeated():
				target._start_rest()
				target._apply_short_hit_fly(self, "")
			return true
		_:
			return false


func _cancel_state_at_be_catch() -> bool:
	if current_state not in ["be_catch", "back_be_catch"]:
		return false
	var catcher: Fighter = linked_fighter
	if catcher == null:
		return false
	match catcher.current_state:
		"catch":
			catcher.linked_fighter = null
			catcher.link_mode = ""
			catcher.catch_hold_timer = 0.0
			linked_fighter = null
			link_mode = ""
			catcher.lock_action = false
			catcher.lock_motion = false
			catcher._set_ready()
			return true
		"catch_skill_fa", "catch_skill_ba", "catch_skill_bb", "catch_skill_fb":
			catcher.linked_fighter = null
			catcher.link_mode = ""
			catcher.catch_hold_timer = 0.0
			linked_fighter = null
			link_mode = ""
			catcher.lock_action = true
			catcher.lock_motion = true
			catcher._start_rest()
			_apply_short_hit_fly(catcher, "")
			return true
		_:
			return false


func _cancel_state_at_lift() -> void:
	if _is_be_lift_state():
		if linked_fighter == null:
			be_lift_stand_timer = 0.0
			lock_action = true
			lock_motion = true
			current_attack_name = ""
			velocity.y = 0.0
			velocity.z = maxf(velocity.z, 120.0)
			z_height = maxf(z_height, 1.0)
			_set_state("fall", true)
			return
		var lifter: Fighter = linked_fighter
		linked_fighter = null
		link_mode = ""
		lock_action = false
		lock_motion = false
		if lifter.linked_fighter == self:
			lifter.linked_fighter = null
			lifter.link_mode = ""
			match lifter.current_state:
				"lift_fall":
					lifter._set_state("fall", true)
					lifter.lock_action = true
					lifter.lock_motion = true
				"lift_jump":
					lifter._set_state("jump", true)
					lifter.lock_action = true
					lifter.lock_motion = true
				"lift_run":
					lifter.lock_action = false
					lifter.lock_motion = false
					lifter._set_state("leftrun" if lifter.facing < 0 else "rightrun", true)
				"lift_walk":
					lifter.lock_action = false
					lifter.lock_motion = false
					lifter._set_state("walk", true)
				"lift_stance":
					lifter._set_ready()
				"lift_squat":
					_start_stand()
				_:
					pass
		return
	if linked_fighter == null:
		return
	if not _is_in_lift_state() or current_state == "throw":
		return
	var target: Fighter = linked_fighter
	target.linked_fighter = null
	target.link_mode = ""
	linked_fighter = null
	link_mode = ""
	target.lock_action = false
	target.lock_motion = false
	target.be_lift_stand_timer = 0.0
	target.current_attack_name = ""
	target.velocity = velocity
	target.velocity.y = 0.0
	if z_height > 0.0 or target.z_height > 0.0 or velocity.z > 0.0:
		target.velocity.z = maxf(velocity.z, 120.0)
		target.z_height = maxf(target.z_height, z_height + 24.0)
		target._set_state("fall", true)
		return
	if _is_tummy_state(target.current_state):
		target._set_state("tummy", true)
	elif target.current_state in ["half_lying", "lying", "lying_hit", "rest", "be_lift_lying", "be_lift_lying_hit"]:
		target._set_state("lying", true)
	else:
		target._set_ready()


func _fallback_attack_hits(target: Fighter) -> bool:
	var dx: float = target.ground_position.x - ground_position.x
	var dy: float = absf(target.ground_position.y - ground_position.y)
	var dz: float = absf(target.z_height - z_height)
	if sign(dx) != facing and absf(dx) > 18.0:
		return false
	if current_attack_name.contains("jump") and dz > ATTACK_FALLBACK_Z * 1.6:
		return false
	return absf(dx) <= ATTACK_FALLBACK_X and dy <= ATTACK_FALLBACK_Y and dz <= ATTACK_FALLBACK_Z


func _get_throw_body_source() -> Fighter:
	if airborne_script not in [
		"throw_up_fly",
		"throw_up_bounce",
		"throw_down_slam",
	]:
		return null
	if pending_throw_attacker != null:
		return pending_throw_attacker
	if airborne_script_source != null:
		return airborne_script_source
	return null


func _is_throwing_body() -> bool:
	return _get_throw_body_source() != null


func _update_throw_body_hits() -> void:
	if not _is_throwing_body():
		return
	var attacker: Fighter = _get_throw_body_source()
	var own_box: Dictionary = _box_to_world(current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
	for target in _get_active_targets():
		if target == attacker and attacker != null:
			continue
		var target_key: String = str(target.get_instance_id())
		if hit_targets.has(target_key):
			continue
		var target_box: Dictionary = target._box_to_world(target.current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
		if not _boxes_overlap(own_box, target_box):
			continue
		hit_targets[target_key] = true
		target.attack_chain_count = 0
		target.attack_chain_timeout = 0.0
		target.receive_hit(_get_bumped_damage(attacker), attacker, "touch_hit_fly")


func _update_weak_run_attack_hits() -> void:
	if current_state != "weak_run_attack":
		return
	var own_box: Dictionary = _box_to_world(current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
	for target in _get_active_targets():
		var target_key: String = str(target.get_instance_id())
		if hit_targets.has(target_key):
			continue
		# 只碰撞面朝方向前方的对手
		var dx: float = target.ground_position.x - ground_position.x
		if facing < 0 and dx > -10.0:
			continue
		if facing > 0 and dx < 10.0:
			continue
		var target_box: Dictionary = target._box_to_world(target.current_frame_data.get("hit_box", [0, 0, 0, 32, 12, 56]), false)
		if not _boxes_overlap(own_box, target_box):
			continue
		hit_targets[target_key] = true
		# 自己被反弹击飞（反方向short_hit_fly）
		_apply_short_hit_fly(null, "", -facing)
		attack_chain_count = 0
		# 对方：同方向则be_push，否则short_hit_fly
		if target.facing == facing and target._can_receive_attack_effect():
			target._apply_be_push()
		else:
			target._apply_short_hit_fly(self, "")
		target.attack_chain_count = 0
		# 双方受碰撞伤害
		var bump_dmg: int = _get_bumped_damage(self)
		target._deal_direct_damage_from(self, bump_dmg)
		_deal_direct_damage_from(target, bump_dmg)
		hit_targets.clear()
		special_state_timer = 0.0
		break


func _speed_scale() -> float:
	return float(role_data.get("stats", {}).get("speed", 100)) / 100.0


func _reset_attack_controls() -> void:
	control_a_attack = false
	control_b_attack = false
	control_jump = false


func _reset_transient_controls() -> void:
	_reset_attack_controls()
	if not control_left_motion and not control_right_motion:
		control_run = false


func _clear_airborne_skill_state() -> void:
	role_skill_event_frame = -1
	role_skill_timer = 0.0
	airborne_script = ""
	airborne_script_source = null


func _update_be_lift_recovery() -> void:
	if be_lift_stand_timer > 0.0:
		return
	if linked_fighter == null:
		be_lift_stand_timer = 0.0
		if _is_be_lift_prone_state():
			_start_stand()
		return
	if not _is_be_lift_state() or not _is_be_lift_prone_state():
		be_lift_stand_timer = 0.0
		return
	_start_be_lift_stand()


func _update_be_throw_recovery() -> void:
	if be_throw_stand_timer > 0.0:
		return
	if current_state not in ["lying", "lying_hit", "tummy", "tummy_hit"]:
		be_throw_stand_timer = 0.0
		return
	if current_state in ["lying_hit", "tummy_hit"]:
		return
	if pending_throw_attacker != null or _is_throwing_body():
		return
	be_throw_stand_timer = 0.0
	_start_stand()


func _apply_normal_effect(attacker: Fighter) -> void:
	if attacker != null and current_state in ["a_attack", "b_attack", "mach_a_attack", "mach_b_attack"] and attacker.facing == facing:
		attack_chain_count = 0
		attack_chain_timeout = 0.0
		_apply_be_push()
		return
	attack_chain_count += 1
	attack_chain_timeout = 2.0
	_apply_basic_hit(attacker)


func _apply_normal2_effect(attacker: Fighter) -> void:
	if not _can_receive_attack_effect():
		_apply_basic_hit(attacker)
		return
	if attack_chain_count >= ATTACK_CHAIN_REST_THRESHOLD or current_state == "rest":
		attack_chain_count = 0
		attack_chain_timeout = 0.0
		if linked_fighter != null:
			_cancel_linked_combat_state()
			_break_links()
		_apply_short_hit_fly(attacker, "")
		return
	attack_chain_count += 1
	attack_chain_timeout = SHORT_REST_TIME
	_apply_basic_hit(attacker)


func _apply_basic_hit(attacker: Fighter) -> void:
	pending_landing_state = ""
	if current_state in ["be_lift_lying", "be_lift_lying_hit"]:
		attack_chain_count = 0
		lock_action = true
		lock_motion = true
		_set_state("be_lift_lying_hit", true)
		return
	if current_state in ["lying", "lying_hit"]:
		attack_chain_count = 0
		lock_action = true
		lock_motion = true
		_set_state("lying_hit", true)
		downed_timer = maxf(downed_timer, 0.18)
		return
	if current_state in ["be_lift_tummy", "be_lift_tummy_hit"]:
		attack_chain_count = 0
		lock_action = true
		lock_motion = true
		_set_state("be_lift_tummy_hit", true)
		return
	if _is_tummy_state():
		attack_chain_count = 0
		lock_action = true
		lock_motion = true
		_set_state("tummy_hit", true)
		downed_timer = maxf(downed_timer, 0.18)
		return
	if current_state in ["f_roll", "b_roll", "hit_fly", "hit_fly_fall", "be_push", "defense", "solid_defense", "be_lift_defense", "be_lift_solid_defense"]:
		attack_chain_count = 0
		return
	velocity.x = float(attacker.facing if attacker != null else facing) * 80.0
	velocity.y = 0.0
	hitstun = HITSTUN_TIME
	lock_action = true
	lock_motion = true
	_set_state("hit", true)


func _reduce_attack_source_speed(attacker: Fighter, ratio: float = 0.5) -> void:
	if attacker == null:
		return
	if (attacker.velocity.x > 0.0 and attacker.facing > 0) or (attacker.velocity.x < 0.0 and attacker.facing < 0):
		attacker.velocity.x *= ratio


func _apply_attack_effect_buffer(buffer_speed: float) -> void:
	attack_chain_count = 0
	attack_chain_timeout = 0.0
	pending_landing_state = ""
	lock_action = true
	lock_motion = true
	buffer_unlock_after_motion = true
	special_state_timer = maxf(absf(buffer_speed) / 500.0, 0.12)
	if current_state in ["lying", "lying_hit"]:
		_set_state("lying_hit", true)
	elif current_state in ["tummy", "tummy_hit"]:
		_set_state("tummy_hit", true)
	elif current_state in ["be_lift_lying", "be_lift_lying_hit"]:
		_set_state("be_lift_lying_hit", true)
	elif current_state in ["be_lift_tummy", "be_lift_tummy_hit"]:
		_set_state("be_lift_tummy_hit", true)
	velocity.x = buffer_speed
	velocity.y = 0.0
	hitstun = 0.0


func _apply_be_push() -> void:
	_cancel_state_at_lift()
	_cancel_linked_combat_state()
	_break_links()
	_clear_airborne_skill_state()
	lock_action = true
	lock_motion = true
	pending_landing_state = "f_roll"
	state_script_timer = 0.08
	special_state_timer = 0.08
	airborne_script = "be_push_bounce_1"
	airborne_script_source = null
	velocity.x = float(facing) * XSPEED_BE_PUSH
	velocity.y = 0.0
	velocity.z = ZSPEED_BE_PUSH
	z_height = maxf(z_height, 1.0)
	_set_state("be_push", true)


func _apply_short_hit_fly(attacker: Fighter, land_state: String, forced_facing: int = 0) -> void:
	if not _can_receive_attack_effect():
		var buffer_facing: int = forced_facing if forced_facing != 0 else (attacker.facing if attacker != null else facing)
		var buffer_speed: float = float(buffer_facing) * XSPEED_HIT_FLY * 0.5 + velocity.x
		_apply_attack_effect_buffer(buffer_speed)
		return
	_cancel_state_at_lift()
	_cancel_linked_combat_state()
	_break_links()
	_clear_airborne_skill_state()
	lock_action = true
	lock_motion = true
	attack_chain_count = 0
	attack_chain_timeout = 0.0
	pending_landing_state = land_state
	var hit_facing: int = forced_facing if forced_facing != 0 else facing
	if forced_facing == 0 and attacker != null:
		hit_facing = attacker.facing
		_reduce_attack_source_speed(attacker)
	velocity.x = float(hit_facing) * XSPEED_HIT_FLY
	velocity.y = 0.0
	velocity.z = ZSPEED_HIT_FLY
	z_height = maxf(z_height, 1.0)
	_set_state("hit_fly", true)


func _apply_touch_hit_fly(attacker: Fighter) -> void:
	var hit_facing: int = facing
	if attacker != null:
		_reduce_attack_source_speed(attacker)
	if attacker != null:
		var delta_x: float = attacker.ground_position.x - ground_position.x
		if delta_x > 5.0:
			hit_facing = -1
		elif delta_x < -5.0:
			hit_facing = 1
		else:
			hit_facing = -facing
	_apply_short_hit_fly(attacker, "", hit_facing)


func _apply_long_hit_fly(attacker: Fighter) -> void:
	if not _can_receive_attack_effect():
		var hit_facing_buffer: int = attacker.facing if attacker != null else facing
		var buffer_speed: float = float(hit_facing_buffer) * XSPEED_X_HIT_FLY * 0.5 + velocity.x
		_apply_attack_effect_buffer(buffer_speed)
		return
	_cancel_state_at_lift()
	_cancel_linked_combat_state()
	_break_links()
	_clear_airborne_skill_state()
	var skip_speed_reduce: bool = false
	if attacker != null and attacker.current_attack_name == "spinhit" and attacker._has_skill("tornado_attack"):
		attacker._start_second_spinhit()
		skip_speed_reduce = true
	if not skip_speed_reduce:
		_reduce_attack_source_speed(attacker)
	lock_action = true
	lock_motion = true
	attack_chain_count = 0
	attack_chain_timeout = 0.0
	pending_landing_state = ""
	var hit_facing: int = facing
	if attacker != null:
		hit_facing = attacker.facing
	velocity.x = float(hit_facing) * XSPEED_X_HIT_FLY
	velocity.y = 0.0
	velocity.z = ZSPEED_XB_HIT_FLY
	airborne_script = ""
	if facing != hit_facing:
		velocity.z = ZSPEED_XF_HIT_FLY
		airborne_script = "long_hit_fly_front"
	z_height = maxf(z_height, 1.0)
	_set_state("hit_fly", true)


func _apply_bump_to_fly(attacker: Fighter) -> void:
	if current_state == "catch_skill_fa" and skill_target == attacker:
		return
	if not _can_receive_attack_effect():
		var attacker_speed: float = attacker.velocity.x if attacker != null else 0.0
		_apply_attack_effect_buffer(velocity.x + attacker_speed)
		return
	_reduce_attack_source_speed(attacker)
	var roll_state: String = "b_roll"
	if attacker != null and attacker.facing == facing:
		roll_state = "f_roll"
	_apply_bump_hit_fly(attacker, roll_state)


func _apply_bump_hit_fly(attacker: Fighter, land_state: String) -> void:
	_cancel_state_at_lift()
	_cancel_linked_combat_state()
	_break_links()
	_clear_airborne_skill_state()
	lock_action = true
	lock_motion = true
	attack_chain_count = 0
	attack_chain_timeout = 0.0
	pending_landing_state = land_state
	var hit_facing: int = facing
	if attacker != null:
		hit_facing = attacker.facing
	velocity.x = float(hit_facing) * XSPEED_S_HIT_FLY
	velocity.y = 0.0
	velocity.z = ZSPEED_S_HIT_FLY
	z_height = maxf(z_height, 1.0)
	_set_state("hit_fly", true)


func _start_roll_state(state_name: String) -> void:
	pending_landing_state = ""
	lock_action = true
	lock_motion = true
	state_script_timer = 0.2
	velocity.y = 0.0
	if absf(velocity.x) <= 1.0:
		velocity.x = 1.0 * float(facing)
	if state_name == "f_roll" and absf(velocity.x) > 1.0:
		facing = int(sign(velocity.x))
	_set_state(state_name, true)


func _can_receive_attack_effect() -> bool:
	return not [
		"lying",
		"lying_hit",
		"tummy",
		"tummy_hit",
		"f_roll",
		"b_roll",
		"hit_fly",
		"hit_fly_fall",
		"defense",
		"solid_defense",
		"be_push",
	].has(current_state)
