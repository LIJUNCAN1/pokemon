class_name CreatureCatalog
extends RefCounted

const LEGACY_ROOT := "res://素材/宝可梦图/"
const NEW_ROOT := "res://素材/图鉴/角色/"

const SYNERGY_ORDER: Array[String] = ["自然", "火", "雷", "岩", "植物", "虫群", "龙族", "机械", "亡灵"]
const ELEMENTS: Array[String] = ["自然", "火", "雷", "岩"]
const RACES: Array[String] = ["植物", "虫群", "龙族", "机械", "亡灵"]
const RARITY_NAMES: Array[String] = ["普通", "优秀", "稀有", "史诗", "传说"]
const RARITY_STAT_MULTIPLIERS: Array[float] = [1.0, 1.12, 1.25, 1.42, 1.62]
const RARITY_CHARGE_MULTIPLIERS: Array[float] = [1.0, 1.04, 1.08, 1.12, 1.16]

# Every entry is a complete gameplay definition. Paths are intentionally stored
# in full because the new collection contains filenames also used by legacy art.
const CREATURE_DATA: Array[Dictionary] = [
	{"path": LEGACY_ROOT + "1 (1).png", "name": "芽叶兽", "traits": ["自然", "植物"], "range": "melee", "rarity": 0, "hp": 72, "damage": [9, 15], "cooldown": 4.2, "skill": "seed_burst", "skill_name": "种子爆破", "skill_text": "攻击目标并对另一名敌人造成溅射伤害"},
	{"path": LEGACY_ROOT + "1 (2).png", "name": "钢甲象", "traits": ["岩", "机械"], "range": "melee", "rarity": 1, "hp": 92, "damage": [8, 13], "cooldown": 4.8, "skill": "shield_self", "skill_name": "钢铁壁垒", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": LEGACY_ROOT + "1 (3).png", "name": "烛灵", "traits": ["火", "亡灵"], "range": "ranged", "rarity": 0, "hp": 62, "damage": [11, 17], "cooldown": 3.8, "skill": "burn", "skill_name": "幽火", "skill_text": "攻击并为目标附加额外燃烧"},
	{"path": LEGACY_ROOT + "1 (4).png", "name": "岩甲龟", "traits": ["岩", "机械"], "range": "melee", "rarity": 1, "hp": 98, "damage": [7, 12], "cooldown": 5.0, "skill": "shield_self", "skill_name": "缩壳防御", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": LEGACY_ROOT + "1 (5).png", "name": "夜翼兽", "traits": ["雷", "亡灵"], "range": "ranged", "rarity": 0, "hp": 66, "damage": [10, 18], "cooldown": 3.6, "skill": "double_hit", "skill_name": "夜袭", "skill_text": "对目标追加一次 55% 伤害的攻击"},
	{"path": LEGACY_ROOT + "1 (6).png", "name": "冰角鹿", "traits": ["自然", "雷", "龙族"], "range": "ranged", "rarity": 2, "hp": 76, "damage": [10, 16], "cooldown": 4.0, "skill": "slow", "skill_name": "寒角冲击", "skill_text": "降低目标的技能充能"},
	{"path": LEGACY_ROOT + "1 (7).png", "name": "菌盖兽", "traits": ["自然", "植物"], "range": "ranged", "rarity": 0, "hp": 70, "damage": [8, 14], "cooldown": 4.3, "skill": "heal_ally", "skill_name": "孢子治愈", "skill_text": "治疗生命比例最低的友军"},
	{"path": LEGACY_ROOT + "1 (8).png", "name": "深海贤者", "traits": ["雷", "龙族"], "range": "ranged", "rarity": 1, "hp": 74, "damage": [11, 16], "cooldown": 4.1, "skill": "team_charge", "skill_name": "潮汐启迪", "skill_text": "为其他友军补充技能充能"},
	{"path": LEGACY_ROOT + "1 (9).png", "name": "绵云羊", "traits": ["雷", "植物"], "range": "ranged", "rarity": 1, "hp": 78, "damage": [12, 19], "cooldown": 3.7, "skill": "chain", "skill_name": "云间闪电", "skill_text": "攻击并跳跃至额外敌人"},
	{"path": LEGACY_ROOT + "1 (10).png", "name": "烈焰犬", "traits": ["火", "龙族"], "range": "melee", "rarity": 2, "hp": 94, "damage": [14, 22], "cooldown": 3.8, "skill": "burn", "skill_name": "烈焰撕咬", "skill_text": "重击目标并附加额外燃烧"},
	{"path": LEGACY_ROOT + "图层 2.png", "name": "花叶兽", "traits": ["自然", "植物"], "range": "melee", "rarity": 1, "hp": 88, "damage": [11, 18], "cooldown": 4.0, "skill": "heal_ally", "skill_name": "花叶祝福", "skill_text": "治疗生命比例最低的友军"},
	{"path": LEGACY_ROOT + "图层 3.png", "name": "铁壳蛛", "traits": ["岩", "虫群"], "range": "melee", "rarity": 2, "hp": 102, "damage": [10, 17], "cooldown": 4.6, "skill": "shield_self", "skill_name": "铁网甲壳", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": LEGACY_ROOT + "图层 4.png", "name": "星云兽", "traits": ["雷", "火", "机械"], "range": "ranged", "rarity": 4, "hp": 92, "damage": [18, 28], "cooldown": 3.4, "skill": "aoe", "skill_name": "星云爆发", "skill_text": "对所有敌人造成范围伤害"},
	{"path": LEGACY_ROOT + "图层 5.png", "name": "花甲虫", "traits": ["自然", "虫群"], "range": "melee", "rarity": 3, "hp": 118, "damage": [15, 23], "cooldown": 3.7, "skill": "team_charge", "skill_name": "虫群号令", "skill_text": "攻击并为其他友军补充技能充能"},
	{"path": LEGACY_ROOT + "图层 6.png", "name": "熔岩蛛", "traits": ["火", "岩", "虫群"], "range": "ranged", "rarity": 3, "hp": 108, "damage": [17, 26], "cooldown": 3.6, "skill": "aoe_burn", "skill_name": "熔岩喷发", "skill_text": "灼烧所有敌人并造成范围伤害"},

	{"path": NEW_ROOT + "1 (1).png", "name": "森冠鹿", "traits": ["自然", "植物"], "range": "ranged", "rarity": 4, "hp": 126, "damage": [17, 26], "cooldown": 3.8, "skill": "heal_ally", "skill_name": "森林恩泽", "skill_text": "重击目标并治疗生命比例最低的友军"},
	{"path": NEW_ROOT + "1 (2).png", "name": "花芽鹿", "traits": ["自然", "植物"], "range": "ranged", "rarity": 2, "hp": 88, "damage": [12, 19], "cooldown": 3.9, "skill": "team_charge", "skill_name": "花芽共鸣", "skill_text": "为其他友军补充技能充能"},
	{"path": NEW_ROOT + "1 (3).png", "name": "青芽团", "traits": ["自然", "植物"], "range": "melee", "rarity": 0, "hp": 82, "damage": [9, 14], "cooldown": 4.4, "skill": "shield_self", "skill_name": "嫩叶护体", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "1 (4).png", "name": "潮汐王", "traits": ["雷", "龙族"], "range": "ranged", "rarity": 4, "hp": 120, "damage": [18, 29], "cooldown": 3.5, "skill": "aoe", "skill_name": "王者海啸", "skill_text": "对所有敌人造成范围伤害"},
	{"path": NEW_ROOT + "1 (5).png", "name": "潮汐卫", "traits": ["雷", "龙族"], "range": "ranged", "rarity": 2, "hp": 94, "damage": [13, 21], "cooldown": 3.8, "skill": "team_charge", "skill_name": "潮流号令", "skill_text": "为其他友军补充技能充能"},
	{"path": NEW_ROOT + "1 (6).png", "name": "泡泡灵", "traits": ["自然", "亡灵"], "range": "ranged", "rarity": 0, "hp": 74, "damage": [9, 15], "cooldown": 4.0, "skill": "heal_ally", "skill_name": "治愈泡泡", "skill_text": "治疗生命比例最低的友军"},
	{"path": NEW_ROOT + "1 (7).png", "name": "水滴灵", "traits": ["雷", "亡灵"], "range": "ranged", "rarity": 0, "hp": 64, "damage": [10, 16], "cooldown": 3.6, "skill": "slow", "skill_name": "水压冲击", "skill_text": "降低目标的技能充能"},
	{"path": NEW_ROOT + "1 (8).png", "name": "炽焰狼王", "traits": ["火", "龙族"], "range": "melee", "rarity": 4, "hp": 138, "damage": [20, 31], "cooldown": 3.4, "skill": "aoe_burn", "skill_name": "炼狱咆哮", "skill_text": "灼烧所有敌人并造成范围伤害"},
	{"path": NEW_ROOT + "1 (9).png", "name": "炎鬃狼", "traits": ["火", "龙族"], "range": "melee", "rarity": 2, "hp": 104, "damage": [15, 23], "cooldown": 3.6, "skill": "burn", "skill_name": "炎牙", "skill_text": "重击目标并附加额外燃烧"},
	{"path": NEW_ROOT + "1 (10).png", "name": "赤尾狐", "traits": ["火", "植物"], "range": "ranged", "rarity": 2, "hp": 86, "damage": [14, 22], "cooldown": 3.5, "skill": "double_hit", "skill_name": "狐火连击", "skill_text": "对目标追加一次 55% 伤害的攻击"},
	{"path": NEW_ROOT + "1 (11).png", "name": "小火狐", "traits": ["火", "植物"], "range": "ranged", "rarity": 0, "hp": 68, "damage": [10, 17], "cooldown": 3.8, "skill": "burn", "skill_name": "火花", "skill_text": "攻击并为目标附加额外燃烧"},
	{"path": NEW_ROOT + "1 (12).png", "name": "小冰企鹅", "traits": ["雷", "植物"], "range": "ranged", "rarity": 0, "hp": 70, "damage": [9, 15], "cooldown": 4.1, "skill": "slow", "skill_name": "冰雪球", "skill_text": "降低目标的技能充能"},
	{"path": NEW_ROOT + "1 (13).png", "name": "冰冠企鹅", "traits": ["雷", "机械"], "range": "ranged", "rarity": 3, "hp": 88, "damage": [13, 20], "cooldown": 3.7, "skill": "chain", "skill_name": "寒潮权杖", "skill_text": "攻击并跳跃至额外敌人"},
	{"path": NEW_ROOT + "1 (14).png", "name": "紫晶巨像", "traits": ["岩", "机械"], "range": "melee", "rarity": 4, "hp": 156, "damage": [18, 27], "cooldown": 4.2, "skill": "aoe", "skill_name": "晶核震荡", "skill_text": "对所有敌人造成范围伤害"},
	{"path": NEW_ROOT + "1 (15).png", "name": "苔岩守卫", "traits": ["岩", "植物"], "range": "melee", "rarity": 2, "hp": 124, "damage": [12, 19], "cooldown": 4.5, "skill": "shield_self", "skill_name": "苔岩壁垒", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "1 (16).png", "name": "小石怪", "traits": ["岩", "机械"], "range": "melee", "rarity": 1, "hp": 96, "damage": [8, 14], "cooldown": 4.8, "skill": "shield_self", "skill_name": "滚石护体", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "图层 3.png", "name": "苔心傀儡", "traits": ["自然", "机械"], "range": "ranged", "rarity": 2, "hp": 92, "damage": [12, 19], "cooldown": 4.0, "skill": "heal_ally", "skill_name": "苔心脉冲", "skill_text": "治疗生命比例最低的友军"},
	{"path": NEW_ROOT + "图层 4.png", "name": "晶背龟", "traits": ["岩", "虫群"], "range": "melee", "rarity": 3, "hp": 116, "damage": [12, 18], "cooldown": 4.4, "skill": "shield_self", "skill_name": "晶壳反射", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "图层 10.png", "name": "林角幼兽", "traits": ["自然", "龙族"], "range": "ranged", "rarity": 3, "hp": 90, "damage": [13, 20], "cooldown": 3.8, "skill": "seed_burst", "skill_name": "林风飞叶", "skill_text": "攻击目标并对另一名敌人造成溅射伤害"},
]

const THRESHOLDS: Dictionary = {
	"自然": [2, 4, 6], "火": [2, 4, 6], "雷": [2, 4, 6], "岩": [2, 4, 6],
	"植物": [2, 4, 6], "虫群": [2, 4, 6], "龙族": [2, 4, 6],
	"机械": [2, 4, 6], "亡灵": [2, 4, 6],
}

const EFFECT_VALUES: Dictionary = {
	"自然": [0.10, 0.20, 0.35], "火": [0.10, 0.20, 0.35],
	"雷": [0.10, 0.25, 0.40], "岩": [0.10, 0.16, 0.24],
	"植物": [0.08, 0.14, 0.22], "虫群": [0.12, 0.22, 0.35],
	"龙族": [0.15, 0.28, 0.45], "机械": [0.08, 0.16, 0.28],
	"亡灵": [0.06, 0.12, 0.20],
}

const EFFECT_LINES: Dictionary = {
	"自然": ["周期性恢复最低生命队友", "过量治疗转化为护盾", "死亡时留下治疗区域"],
	"火": ["攻击有概率点燃", "燃烧可叠加", "燃烧目标死亡后爆炸"],
	"雷": ["攻击有概率连锁", "连锁目标增加", "释放技能时触发全场落雷"],
	"岩": ["岩石单位获得伤害减免", "受到攻击时获得可叠加岩甲", "岩甲破裂时使敌方全体减速"],
	"植物": ["战斗时间越长，生命越高", "每隔数秒生长一次", "首次死亡后以幼苗状态复活"],
	"虫群": ["虫群单位攻击速度提高", "施放技能后为其他虫群充能", "存活虫群越多，全队技能释放越快"],
	"龙族": ["龙族单位技能伤害提高", "技能会对额外目标造成溅射", "生命低于一半时进入狂暴"],
	"机械": ["开局获得护甲", "护甲破裂时释放冲击波", "每个存活机械单位提高全队攻速"],
	"亡灵": ["亡灵单位技能附带吸血", "死亡时恢复其他亡灵生命", "首次死亡后以灵魂形态复活"],
}


static func all_textures() -> Array[String]:
	var result: Array[String] = []
	for entry in CREATURE_DATA:
		result.append(String(entry["path"]))
	return result


static func all_names() -> Array[String]:
	var result: Array[String] = []
	for entry in CREATURE_DATA:
		result.append(String(entry["name"]))
	return result


static func textures_for_rarity(rarity: int) -> Array[String]:
	var result: Array[String] = []
	for entry in CREATURE_DATA:
		if int(entry["rarity"]) == clampi(rarity, 0, RARITY_NAMES.size() - 1):
			result.append(String(entry["path"]))
	return result


static func data_for_texture(texture_path: String) -> Dictionary:
	for entry in CREATURE_DATA:
		if String(entry["path"]) == texture_path:
			return entry
	return {}


static func name_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("name", "未知怪兽"))


static func traits_for_texture(texture_path: String) -> PackedStringArray:
	return PackedStringArray(data_for_texture(texture_path).get("traits", []))


static func attack_range_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("range", "melee"))


static func combat_role_name(texture_path: String) -> String:
	return "远程" if attack_range_for_texture(texture_path) == "ranged" else "近战"


static func rarity_for_texture(texture_path: String) -> int:
	return clampi(int(data_for_texture(texture_path).get("rarity", 0)), 0, RARITY_NAMES.size() - 1)


static func base_hp_for_texture(texture_path: String) -> int:
	return int(data_for_texture(texture_path).get("hp", 72))


static func damage_range_for_texture(texture_path: String) -> Vector2i:
	var values: Array = data_for_texture(texture_path).get("damage", [9, 17])
	return Vector2i(int(values[0]), int(values[1]))


static func cooldown_for_texture(texture_path: String) -> float:
	return float(data_for_texture(texture_path).get("cooldown", 4.0))


static func skill_id_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("skill", "basic"))


static func skill_name_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("skill_name", "基础攻击"))


static func skill_text_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("skill_text", "对目标造成伤害"))


static func rarity_stat_multiplier(texture_path: String) -> float:
	return RARITY_STAT_MULTIPLIERS[rarity_for_texture(texture_path)]


static func rarity_charge_multiplier(texture_path: String) -> float:
	return RARITY_CHARGE_MULTIPLIERS[rarity_for_texture(texture_path)]


static func elements_for_texture(texture_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for trait_name in traits_for_texture(texture_path):
		if trait_name in ELEMENTS:
			result.append(trait_name)
	return result


static func races_for_texture(texture_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for trait_name in traits_for_texture(texture_path):
		if trait_name in RACES:
			result.append(trait_name)
	return result


static func count_synergies(team: Array[String]) -> Dictionary:
	var counts: Dictionary = {}
	var counted_creatures: Dictionary = {}
	for synergy in SYNERGY_ORDER:
		counts[synergy] = 0
	for texture_path in team:
		if texture_path.is_empty() or counted_creatures.has(texture_path):
			continue
		counted_creatures[texture_path] = true
		for tag in traits_for_texture(texture_path):
			counts[tag] = int(counts.get(tag, 0)) + 1
	return counts


static func active_tier(synergy: String, count: int) -> int:
	var tier := -1
	var thresholds: Array = THRESHOLDS[synergy]
	for index in thresholds.size():
		if count >= thresholds[index]:
			tier = index
	return tier


static func effect_value(synergy: String, count: int) -> float:
	var tier := active_tier(synergy, count)
	if tier < 0:
		return 0.0
	var values: Array = EFFECT_VALUES[synergy]
	return values[tier]


static func tooltip_text(synergy: String, current_count: int) -> String:
	var lines: Array[String] = ["当前数量：%d" % current_count]
	var thresholds: Array = THRESHOLDS[synergy]
	var effects: Array = EFFECT_LINES[synergy]
	for index in thresholds.size():
		var marker := "●" if current_count >= thresholds[index] else "○"
		lines.append("%s %d：%s" % [marker, thresholds[index], effects[index]])
	return "\n".join(lines)
