extends RefCounted
class_name Localization

const DEFAULT_LANGUAGE: String = "en"
const SUPPORTED_LANGUAGES: Array[String] = ["en", "zh_CN"]

const LANGUAGE_FALLBACK_NAMES: Dictionary = {
	"en": "English",
	"zh_CN": "简体中文",
}

const TRANSLATIONS: Dictionary = {
	"en": {
		"language.name.en": "English",
		"language.name.zh_CN": "Simplified Chinese",
		"dialog.ok": "OK",
		"menu.notice": "Notice",
		"menu.single_game": "Single Game",
		"menu.network_battle": "Network Battle",
		"menu.options": "Options",
		"menu.help": "Help",
		"menu.quit": "Quit",
		"menu.mode_2v2": "2v2 Battle",
		"menu.mode_scuffle": "4-Player Scuffle",
		"menu.mode_story": "Story: Eril's Kitchen",
		"menu.training_dummy": "Training Dummy",
		"menu.keyboard_settings": "Keyboard Settings",
		"menu.window_toggle": "Toggle Fullscreen",
		"menu.language_toggle": "Language: %s",
		"menu.ai_difficulty_toggle": "AI Difficulty: %s",
		"menu.how_to_play": "How to Play",
		"ai.difficulty.easy": "Easy",
		"ai.difficulty.normal": "Normal",
		"ai.difficulty.hard": "Hard",
		"menu.back": "Back",
		"menu.role_select": "Select Fighter",
		"menu.network_unavailable": "Network battle is not implemented yet.",
		"menu.quit_confirm": "Are you sure you want to quit?",
		"menu.quit_yes": "Yes",
		"menu.quit_no": "No",
		"role.name.kunio": "Kunio",
		"role.name.beach": "Jimmer",
		"role.name.spence": "Spence",
		"role.name.vince": "Vince",
		"role.name.rick": "Rick",
		"role.name.ryguy": "Ryguy",
		"role.name.nate": "Nate-O-Rade",
		"role.name.eril": "Eril",
		"role.name.riki": "Riki",
		"role.name.mike": "Mike",
		"role.name.ben": "Ben",
		"role.name.toraji": "Toraji",
		"role.stats.hp": "HP",
		"role.stats.punch": "Punch",
		"role.stats.kick": "Kick",
		"role.stats.defense": "Defense",
		"role.stats.throw": "Throw",
		"role.stats.speed": "Speed",
		"role.skills": "Skills",
		"role.prev": "Prev",
		"role.next": "Next",
		"role.select": "Select",
		"help.title": "How to Play",
		"help.body": """How to Play

Movement:
  W/A/S/D - Move up/left/down/right
  Double-tap A or D - Sprint

Actions:
  J - Punch (A Attack)
  K - Kick (B Attack)
  L - Guard / Solid Defense
  Space - Jump

Ground Skills:
  J near downed enemy - Jump Elbow / Mach Stomp
  K near downed enemy - Jump Tread
  J near resting enemy - Catch (while walking toward)
  Up/Down near downed enemy - Ride

Catch Skills:
  J/K while catching - Role-specific grapple skill
  K while catching - Push

Air Skills:
  J during jump - Jump Punch
  K during jump - Jump Kick
  J on landing - Spin Hit
  K on landing - Bomb Kick
  J while falling - Big Elbow
  K while falling - Guillotine
  S after sprint jump - High Jump Spin Drop Kick

Sprint Skills:
  J while sprinting - Sprint Punch
  K while sprinting - Sprint Kick
  Space while sprinting - Sprint Jump

Lift Skills:
  J/K near downed enemy (standing) - Lift
  J while lifting - Throw forward
  K while lifting - Throw upward
  Space while lifting - Lift Jump

Special:
  J near resting enemy (standing) - Final Blow
  Esc - Exit battle
""",
		"battle.help": "WASD Move  Double-Tap A/D Run  J Punch  K Kick  L Guard  Space Jump  Esc Exit",
		"battle.mode.team": "2v2 Team Battle",
		"battle.mode.ffa": "4-Player Scuffle",
		"battle.result.draw": "Draw",
		"battle.result.wins": "%s Wins",
		"battle.result.team_win": "Your Team Wins!",
		"battle.result.team_lose": "Enemy Team Wins!",
		"battle.result.return_hint": "Press Esc to return",
		"battle.pause.title": "Pause Menu",
		"battle.pause.subtitle": "Fight Card",
		"battle.pause.continue": "Continue",
		"battle.pause.restart": "Restart",
		"battle.pause.menu": "Main Menu",
		"battle.exit_confirm": "Exit this battle?",
		"battle.exit_yes": "Yes",
		"battle.exit_no": "No",
		"battle.tag.player": " [1P]",
		"battle.tag.cpu": " [CPU]",
		"battle.tag.ally": " [Ally]",
		"battle.tag.enemy": " [Enemy]",
		"keyboard.title": "Keyboard Settings",
		"keyboard.instructions": "Click a button, then press the new key",
		"keyboard.restore_defaults": "Restore Defaults",
		"keyboard.capture_prompt": "Press the key to use...",
		"keyboard.capture_action": "Press the key for [%s]...",
		"keyboard.invalid_key": "Invalid key! Try again...",
		"action.left": "Left",
		"action.right": "Right",
		"action.up": "Up",
		"action.down": "Down",
		"action.jump": "Jump",
		"action.guard": "Guard",
		"action.punch": "Punch",
		"action.kick": "Kick",
		"key.space": "Space",
		"key.up": "Up",
		"key.down": "Down",
		"key.left": "Left",
		"key.right": "Right",
		"key.shift": "Shift",
		"key.ctrl": "Ctrl",
		"key.tab": "Tab",
		"key.generic": "Key %d",
		"skill.mach_a_attack": "Mach Punch",
		"skill.mach_b_attack": "Mach Kick",
		"skill.big_elbow": "Big Elbow",
		"skill.guillotine": "Guillotine",
		"skill.tornado_attack": "Tornado Attack",
		"skill.jump_spinkick": "Jump Spin Kick",
		"skill.bombkick": "Bomb Kick",
		"skill.solid_defense": "Solid Defense",
		"skill.spinhit": "Spin Hit",
		"skill.mach_stomp": "Mach Stomp",
		"skill.hug_front_put": "Front Hug Throw",
		"skill.hug_back_put": "Back Hug Throw",
		"skill.elbow": "Elbow",
		"skill.kneehit": "Knee Hit",
		"skill.hug_jump": "Hug Jump",
		"skill.lift_jump": "Lift Jump",
		"skill.judo": "Judo",
		"skill.back_judo": "Back Judo",
		"skill.final_blow": "Final Blow",
		"skill.a_finalblow": "Final Blow",
		"skill.b_finalblow": "Final Blow",
	},
	"zh_CN": {
		"language.name.en": "英语",
		"language.name.zh_CN": "简体中文",
		"dialog.ok": "确定",
		"menu.notice": "提示",
		"menu.single_game": "单人游戏",
		"menu.network_battle": "网络对战",
		"menu.options": "选项",
		"menu.help": "帮助",
		"menu.quit": "退出",
		"menu.mode_2v2": "2v2 对战",
		"menu.mode_scuffle": "4人乱斗",
		"menu.mode_story": "剧情：Eril的厨房",
		"menu.training_dummy": "训练假人",
		"menu.keyboard_settings": "按键设置",
		"menu.window_toggle": "切换全屏",
		"menu.language_toggle": "语言：%s",
		"menu.ai_difficulty_toggle": "AI强度：%s",
		"menu.how_to_play": "玩法说明",
		"ai.difficulty.easy": "简单",
		"ai.difficulty.normal": "普通",
		"ai.difficulty.hard": "困难",
		"menu.back": "返回",
		"menu.role_select": "选择角色",
		"menu.network_unavailable": "网络对战功能暂未实现。",
		"menu.quit_confirm": "确定要退出游戏吗？",
		"menu.quit_yes": "是",
		"menu.quit_no": "否",
		"role.name.kunio": "国夫",
		"role.name.beach": "Jimmer",
		"role.name.spence": "Spence",
		"role.name.vince": "Vince",
		"role.name.rick": "Rick",
		"role.name.ryguy": "Ryguy",
		"role.name.nate": "Nate-O-Rade",
		"role.name.eril": "Eril",
		"role.name.riki": "力奇",
		"role.name.mike": "麦克",
		"role.name.ben": "本",
		"role.name.toraji": "虎次",
		"role.stats.hp": "体力",
		"role.stats.punch": "拳击",
		"role.stats.kick": "踢击",
		"role.stats.defense": "防御",
		"role.stats.throw": "投技",
		"role.stats.speed": "速度",
		"role.skills": "技能",
		"role.prev": "上一个",
		"role.next": "下一个",
		"role.select": "选择",
		"help.title": "玩法说明",
		"help.body": """玩法说明

移动：
  W/A/S/D - 上、左、下、右移动
  连按 A 或 D - 冲刺

基础动作：
  J - 出拳（A 攻击）
  K - 踢击（B 攻击）
  L - 防御 / 铁壁防御
  Space - 跳跃

倒地追击：
  靠近倒地敌人按 J - 跳肘 / 马赫践踏
  靠近倒地敌人按 K - 踩踏
  靠近静止敌人按 J - 抓取（向前行走时）
  靠近倒地敌人按上/下 - 骑乘

抓取技能：
  抓住对手后按 J/K - 角色专属投技
  抓住对手后按 K - 推开

空中技能：
  跳跃中按 J - 跳跃拳
  跳跃中按 K - 跳跃踢
  落地瞬间按 J - 回旋击
  落地瞬间按 K - 炸弹踢
  下落时按 J - 大肘击
  下落时按 K - 断头台
  冲刺跳跃后按 S - 高跳旋风落踢

冲刺技能：
  冲刺中按 J - 冲刺拳
  冲刺中按 K - 冲刺踢
  冲刺中按 Space - 冲刺跳

举起技能：
  站立状态下靠近倒地敌人按 J/K - 举起
  举起时按 J - 向前投掷
  举起时按 K - 向上投掷
  举起时按 Space - 举投跳跃

特殊：
  站立状态下靠近静止敌人按 J - 终结一击
  Esc - 退出战斗
""",
		"battle.help": "WASD 移动  连按 A/D 冲刺  J 拳击  K 踢击  L 防御  Space 跳跃  Esc 退出",
		"battle.mode.team": "2v2 团队战",
		"battle.mode.ffa": "4人乱斗",
		"battle.result.draw": "平局",
		"battle.result.wins": "%s 获胜",
		"battle.result.team_win": "我方胜利！",
		"battle.result.team_lose": "敌方胜利！",
		"battle.result.return_hint": "按 Esc 返回",
		"battle.pause.title": "暂停菜单",
		"battle.pause.subtitle": "战斗卡片",
		"battle.pause.continue": "继续",
		"battle.pause.restart": "重新开始",
		"battle.pause.menu": "返回主菜单",
		"battle.exit_confirm": "退出当前战斗？",
		"battle.exit_yes": "是",
		"battle.exit_no": "否",
		"battle.tag.player": " [1P]",
		"battle.tag.cpu": " [电脑]",
		"battle.tag.ally": " [友方]",
		"battle.tag.enemy": " [敌方]",
		"keyboard.title": "按键设置",
		"keyboard.instructions": "点击按钮后按下新的按键",
		"keyboard.restore_defaults": "恢复默认",
		"keyboard.capture_prompt": "请按下要使用的按键……",
		"keyboard.capture_action": "请为 [%s] 按下新的按键……",
		"keyboard.invalid_key": "按键无效，请重试……",
		"action.left": "向左",
		"action.right": "向右",
		"action.up": "向上",
		"action.down": "向下",
		"action.jump": "跳跃",
		"action.guard": "防御",
		"action.punch": "拳击",
		"action.kick": "踢击",
		"key.space": "空格",
		"key.up": "上箭头",
		"key.down": "下箭头",
		"key.left": "左箭头",
		"key.right": "右箭头",
		"key.shift": "Shift",
		"key.ctrl": "Ctrl",
		"key.tab": "Tab",
		"key.generic": "按键 %d",
		"skill.mach_a_attack": "马赫拳",
		"skill.mach_b_attack": "马赫踢",
		"skill.big_elbow": "大肘击",
		"skill.guillotine": "断头台",
		"skill.tornado_attack": "龙卷攻击",
		"skill.jump_spinkick": "跳跃旋踢",
		"skill.bombkick": "炸弹踢",
		"skill.solid_defense": "铁壁防御",
		"skill.spinhit": "回旋击",
		"skill.mach_stomp": "马赫践踏",
		"skill.hug_front_put": "正面抱摔",
		"skill.hug_back_put": "背后抱摔",
		"skill.elbow": "肘击",
		"skill.kneehit": "膝撞",
		"skill.hug_jump": "抱摔跳跃",
		"skill.lift_jump": "举投跳跃",
		"skill.judo": "过肩摔",
		"skill.back_judo": "反身过肩摔",
		"skill.final_blow": "终结一击",
		"skill.a_finalblow": "终结一击",
		"skill.b_finalblow": "终结一击",
	},
}

static var _registered: bool = false


static func ensure_registered() -> void:
	if _registered:
		return
	for locale in TRANSLATIONS.keys():
		var translation: Translation = Translation.new()
		translation.locale = String(locale)
		var messages: Dictionary = TRANSLATIONS[locale]
		for key in messages.keys():
			translation.add_message(String(key), String(messages[key]))
		TranslationServer.add_translation(translation)
	_registered = true


static func normalize_locale(locale: String) -> String:
	var lowered: String = locale.strip_edges()
	if lowered.is_empty():
		return DEFAULT_LANGUAGE
	if lowered.begins_with("zh"):
		return "zh_CN"
	if SUPPORTED_LANGUAGES.has(lowered):
		return lowered
	return DEFAULT_LANGUAGE


static func set_locale(locale: String) -> String:
	ensure_registered()
	var normalized: String = normalize_locale(locale)
	TranslationServer.set_locale(normalized)
	return normalized


static func get_next_locale(current_locale: String) -> String:
	var normalized: String = normalize_locale(current_locale)
	return "zh_CN" if normalized == "en" else "en"


static func text(key: String, args: Array = []) -> String:
	ensure_registered()
	var translated: String = TranslationServer.translate(key)
	if translated == key and TRANSLATIONS[DEFAULT_LANGUAGE].has(key):
		translated = String(TRANSLATIONS[DEFAULT_LANGUAGE][key])
	if args.is_empty():
		return translated
	return translated % args


static func get_locale_display_name(locale: String) -> String:
	var normalized: String = normalize_locale(locale)
	var key: String = "language.name.%s" % normalized
	var translated: String = text(key)
	if translated == key:
		return String(LANGUAGE_FALLBACK_NAMES.get(normalized, normalized))
	return translated
