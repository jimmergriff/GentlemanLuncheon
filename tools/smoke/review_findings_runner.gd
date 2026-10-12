extends Node

const GAME_CONFIG_SCRIPT: GDScript = preload("res://scripts/config/game_config.gd")
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const LOCALIZATION_SCRIPT: GDScript = preload("res://scripts/i18n/localization.gd")
func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var results: Array[Dictionary] = []
	results.append(await _check_keybinding_conflict_resolution())
	results.append(await _check_pause_menu_localization())
	results.append(await _check_demo_restart_after_draw())

	var failed: Array[String] = []
	for result in results:
		var name: String = String(result.get("name", "unknown"))
		var ok: bool = bool(result.get("ok", false))
		print("REVIEW_FIX %s %s" % [name, "PASS" if ok else "FAIL"])
		if not ok:
			var message: String = String(result.get("message", ""))
			push_error("%s: %s" % [name, message])
			failed.append(name)

	print("REVIEW_FIX_RESULTS=%s" % JSON.stringify(results))
	print("REVIEW_FIX_STATUS=%s" % ("PASS" if failed.is_empty() else "FAIL:" + ",".join(failed)))
	get_tree().quit(0 if failed.is_empty() else 1)


func _check_keybinding_conflict_resolution() -> Dictionary:
	var config = GAME_CONFIG_SCRIPT.new()
	var bindings: Dictionary = config.DEFAULT_KEYS.duplicate()

	var left_before: int = int(bindings["p1_left"])
	var jump_before: int = int(bindings["p1_jump"])
	var planned_bindings: Dictionary = config._plan_key_binding_update("p1_left", jump_before, bindings)
	var left_after: int = int(planned_bindings.get("p1_left", left_before))
	var jump_after: int = int(planned_bindings.get("p1_jump", jump_before))
	return {
		"name": "keybinding_conflict_resolution",
		"ok": left_after == jump_before and jump_after == left_before,
		"message": "Expected swap left=%d jump=%d, got left=%d jump=%d" % [jump_before, left_before, left_after, jump_after],
	}


func _check_pause_menu_localization() -> Dictionary:
	LOCALIZATION_SCRIPT.ensure_registered()
	var battle_scene: BattleScene = BATTLE_SCENE.instantiate() as BattleScene
	add_child(battle_scene)
	await get_tree().process_frame

	LOCALIZATION_SCRIPT.set_locale("en")
	battle_scene._refresh_pause_menu_text()
	var en_title: String = battle_scene._pause_menu_title.text
	var en_restart: String = battle_scene._pause_buttons[1].text if battle_scene._pause_buttons.size() > 1 else ""

	LOCALIZATION_SCRIPT.set_locale("zh_CN")
	battle_scene._refresh_pause_menu_text()
	var zh_title: String = battle_scene._pause_menu_title.text
	var zh_restart: String = battle_scene._pause_buttons[1].text if battle_scene._pause_buttons.size() > 1 else ""

	battle_scene.queue_free()
	await get_tree().process_frame
	LOCALIZATION_SCRIPT.set_locale("en")

	return {
		"name": "pause_menu_localization",
		"ok": en_title != zh_title and en_restart != zh_restart,
		"message": "Expected locale-sensitive pause labels, got en_title='%s', zh_title='%s', en_restart='%s', zh_restart='%s'" % [en_title, zh_title, en_restart, zh_restart],
	}


func _check_demo_restart_after_draw() -> Dictionary:
	var battle_scene: BattleScene = BATTLE_SCENE.instantiate() as BattleScene
	add_child(battle_scene)
	await get_tree().process_frame

	battle_scene.start_session({
		"player_role_id": "kunio",
		"player_mode": "cpu",
		"cpu_role_ids": ["riki"],
		"mute_audio": true,
		"loop_demo": true,
		"ai_difficulty": "normal",
	})
	await get_tree().process_frame

	for fighter in battle_scene.fighters:
		fighter.hp = 0
	battle_scene._check_ffa_battle_state()
	var restart_timer: float = battle_scene._demo_restart_timer

	battle_scene.queue_free()
	await get_tree().process_frame

	return {
		"name": "demo_restart_after_draw",
		"ok": restart_timer > 0.0,
		"message": "Expected demo restart timer to be armed after draw, got %f" % restart_timer,
	}
