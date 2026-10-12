extends RefCounted
class_name GameData

static var _cache: Dictionary = {}

static var _role_name_fallbacks: Dictionary = {
	"beach": "Jimmer",
	"spence": "Spence",
	"vince": "Vince",
	"rick": "Rick",
	"ryguy": "Ryguy",
	"nate": "Nate-O-Rade",
	"eril": "Eril",
	"brad": "Brad",
	"gladys": "Gladys",
	"hive": "Hive",
	"chadwick": "Chadwick",
}

static var _skill_label_fallbacks: Dictionary = {
	"mach_a_attack": "Mach Punch",
	"mach_b_attack": "Mach Kick",
	"big_elbow": "Big Elbow",
	"guillotine": "Guillotine",
	"tornado_attack": "Tornado Attack",
	"jump_spinkick": "Jump Spin Kick",
	"bombkick": "Bomb Kick",
	"solid_defense": "Solid Defense",
	"spinhit": "Spin Hit",
	"mach_stomp": "Mach Stomp",
	"hug_front_put": "Front Hug Throw",
	"hug_back_put": "Back Hug Throw",
	"elbow": "Elbow",
	"kneehit": "Knee Hit",
	"hug_jump": "Hug Jump",
	"lift_jump": "Lift Jump",
	"judo": "Judo",
	"back_judo": "Back Judo",
	"final_blow": "Final Blow",
	"a_finalblow": "Final Blow",
	"b_finalblow": "Final Blow",
}

static var _action_aliases: Dictionary = {
	"leftrun": "run",
	"rightrun": "run",
	"ssquat": "squat",
	"jsquat": "squat",
	"lift_squat": "squat",
	"jump_done": "squat",
	"sjump": "jump",
	"ride_jump": "fall",
	"be_lift_stance": "stance",
	"be_lift_squat": "squat",
	"be_lift_lying": "lying",
	"be_lift_lying_hit": "lying_hit",
	"be_lift_tummy": "tummy",
	"be_lift_tummy_hit": "tummy_hit",
	"be_lift_defense": "defense",
	"be_lift_solid_defense": "solid_defense",
	"be_lift_a_attack": "a_attack",
	"be_lift_b_attack": "b_attack",
	"be_lift_mach_a_attack": "mach_a_attack",
	"be_lift_mach_b_attack": "mach_b_attack",
	"catch_skill_ba": "catch_skill_fa",
}


static func _load_json(path: String) -> Variant:
	if _cache.has(path):
		return _cache[path]
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open data file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("Failed to parse JSON: %s" % path)
		return {}
	_cache[path] = parsed
	return parsed


static func _normalize_role(role: Dictionary) -> Dictionary:
	var result: Dictionary = role.duplicate(true)
	var role_id: String = String(result.get("id", ""))
	if _role_name_fallbacks.has(role_id):
		result["name"] = _role_name_fallbacks[role_id]
	return result


static func _inject_action_aliases(actions: Dictionary) -> Dictionary:
	var result: Dictionary = actions.duplicate(true)
	for alias_name in _action_aliases.keys():
		if result.has(alias_name):
			continue
		var source_name: String = String(_action_aliases.get(alias_name, ""))
		if source_name.is_empty() or not result.has(source_name):
			continue
		result[alias_name] = (result.get(source_name, {}) as Dictionary).duplicate(true)
	return result


static func load_roles() -> Dictionary:
	var payload: Dictionary = _load_json("res://resources/data/roles.json")
	var normalized_roles: Array = []
	for role in payload.get("roles", []):
		normalized_roles.append(_normalize_role(role))
	return {"roles": normalized_roles}


static func load_stage(stage_id: String = "arena_1") -> Dictionary:
	var stages: Dictionary = _load_json("res://resources/data/stages.json")
	for stage in stages.get("stages", []):
		if stage.get("id", "") == stage_id:
			return stage
	return {}


static func load_role(role_id: String) -> Dictionary:
	var roles: Dictionary = load_roles()
	for role in roles.get("roles", []):
		if role.get("id", "") == role_id:
			var action_path: String = "res://%s" % role.get("action_data", "")
			var action_data: Dictionary = _load_json(action_path)
			var result: Dictionary = role.duplicate(true)
			result["actions"] = _inject_action_aliases(action_data.get("actions", {}))
			return result
	return {}


static func get_role_ids() -> Array[String]:
	var ids: Array[String] = []
	var roles: Dictionary = load_roles()
	for role in roles.get("roles", []):
		if not bool(role.get("playable", true)):
			continue
		ids.append(String(role.get("id", "")))
	return ids


static func get_role_display_name(role: Dictionary) -> String:
	var role_id: String = String(role.get("id", ""))
	if not role_id.is_empty():
		var translation_key: String = "role.name.%s" % role_id
		var translated: String = Localization.text(translation_key)
		if translated != translation_key:
			return translated
	var raw_name: String = String(role.get("name", ""))
	if not raw_name.is_empty():
		return raw_name
	if _role_name_fallbacks.has(role_id):
		return String(_role_name_fallbacks[role_id])
	return role_id


static func get_skill_label(skill_id: String) -> String:
	var translation_key: String = "skill.%s" % skill_id
	var translated: String = Localization.text(translation_key)
	if translated != translation_key:
		return translated
	return String(_skill_label_fallbacks.get(skill_id, skill_id))


static func get_stage_ids() -> Array[String]:
	var ids: Array[String] = []
	var stages: Dictionary = _load_json("res://resources/data/stages.json")
	for stage in stages.get("stages", []):
		ids.append(String(stage.get("id", "")))
	return ids
