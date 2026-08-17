class_name TrainerCatalog

const SELECT_ROOT := "res://assets/ui/trainer_select/psd_exact/"
const CHARACTER_ROOT := "res://assets/characters/trainers/"
const BATTLE_ROOT := "res://assets/ui/battle_intro/"
const SKILL_ICON_ROOT := "res://素材/战斗进场/"

const TRAINERS: Array[Dictionary] = [
	{
		"id": "researcher", "name": "森野", "title": "生态研究员", "element": "植物",
		"color": Color("4f9d69"), "hue": 0.42, "icon_offset": Vector2(-1, 0),
		"select_art": SELECT_ROOT + "portrait_green.png", "dex_art": CHARACTER_ROOT + "trainer_green.png",
		"battle_art": BATTLE_ROOT + "portrait_researcher.png", "skill_icon": SKILL_ICON_ROOT + "生态研究.png", "skill_name": "生态研究", "skill_type": "passive", "cost": 0,
		"description": "每个备战阶段每购买 2 种不同元素的怪兽，获得 1 枚金币；最多触发 2 次。",
		"short_prefix": "生态研究：每购买 2 种不同元素怪兽，金币 ", "short_value": "+1", "short_suffix": "（最多 2 次）",
		"elements_per_reward": 2, "max_triggers": 2,
	},
	{
		"id": "vanguard", "name": "赤城", "title": "先锋训练家", "element": "火",
		"color": Color("c94e4e"), "hue": 0.0, "icon_offset": Vector2(0, -1),
		"select_art": SELECT_ROOT + "portrait_red.png", "dex_art": CHARACTER_ROOT + "trainer_red.png",
		"battle_art": BATTLE_ROOT + "portrait_vanguard.png", "skill_icon": SKILL_ICON_ROOT + "战斗号令.png", "skill_name": "战斗号令", "skill_type": "active", "cost": 2,
		"description": "消耗 2 枚金币。下一场战斗开始时，全队攻击力和攻击速度提高 15%，持续 8 秒。",
		"short_prefix": "战斗号令：下一场全队攻击与攻速 ", "short_value": "+15%", "short_suffix": "（8 秒）",
		"attack_bonus": 0.15, "attack_speed_bonus": 0.15, "duration": 8.0,
	},
	{
		"id": "scout", "name": "紫苑", "title": "遗迹探索者", "element": "雷",
		"color": Color("b79338"), "hue": 0.13, "icon_offset": Vector2(0, 2),
		"select_art": SELECT_ROOT + "portrait_yellow.png", "dex_art": CHARACTER_ROOT + "trainer_yellow.png",
		"battle_art": BATTLE_ROOT + "portrait_scout.png", "skill_icon": SKILL_ICON_ROOT + "遗迹勘探.png", "skill_name": "遗迹勘探", "skill_type": "passive", "cost": 0,
		"description": "每个备战阶段第一次刷新免费，并且该次刷新必定出现 1 张道具卡或饰品卡。",
		"short_prefix": "遗迹勘探：每轮首次刷新免费并必出 ", "short_value": "1", "short_suffix": " 张物品卡",
	},
]


static func all() -> Array[Dictionary]:
	return TRAINERS.duplicate(true)


static func ids() -> Array[String]:
	var result: Array[String] = []
	for trainer in TRAINERS:
		result.append(String(trainer["id"]))
	return result


static func data(trainer_id: String) -> Dictionary:
	for trainer in TRAINERS:
		if String(trainer["id"]) == trainer_id:
			return trainer
	return TRAINERS[0]


static func index_of(trainer_id: String) -> int:
	for index in TRAINERS.size():
		if String(TRAINERS[index]["id"]) == trainer_id:
			return index
	return 0


static func is_active(trainer_id: String) -> bool:
	return String(data(trainer_id).get("skill_type", "passive")) == "active"


static func skill_type_name(trainer_id: String) -> String:
	return "主动技能" if is_active(trainer_id) else "被动技能"
