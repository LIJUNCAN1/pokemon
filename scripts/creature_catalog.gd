class_name CreatureCatalog
extends RefCounted

const SYNERGY_ORDER: Array[String] = ["自然", "火", "雷", "岩", "植物", "虫群", "龙族", "机械", "亡灵"]
const ELEMENTS: Array[String] = ["自然", "火", "雷", "岩"]
const RACES: Array[String] = ["植物", "虫群", "龙族", "机械", "亡灵"]

const CREATURE_FILES: Array[String] = [
	"1 (1).png", "1 (2).png", "1 (3).png", "1 (4).png", "1 (5).png",
	"1 (6).png", "1 (7).png", "1 (8).png", "1 (9).png", "1 (10).png",
	"图层 2.png", "图层 3.png", "图层 4.png", "图层 5.png", "图层 6.png",
]

# Every creature owns one element and one race; a few creatures own a second element.
const CREATURE_TRAITS: Array = [
	["自然", "植物"], ["岩", "机械"], ["火", "亡灵"], ["岩", "机械"],
	["雷", "亡灵"], ["自然", "雷", "龙族"], ["自然", "植物"], ["雷", "龙族"],
	["雷", "植物"], ["火", "龙族"], ["自然", "植物"], ["岩", "虫群"],
	["雷", "火", "机械"], ["自然", "虫群"], ["火", "岩", "虫群"],
]

# Parallel to CREATURE_FILES. Combat roles affect target selection, not synergies.
const CREATURE_ATTACK_RANGES: Array[String] = [
	"melee", "melee", "ranged", "melee", "ranged",
	"ranged", "ranged", "ranged", "ranged", "melee",
	"melee", "melee", "ranged", "melee", "ranged",
]
const RARITY_NAMES: Array[String] = ["普通", "稀有", "史诗"]
const RARITY_STAT_MULTIPLIERS: Array[float] = [1.0, 1.25, 1.6]
const RARITY_CHARGE_MULTIPLIERS: Array[float] = [1.0, 1.08, 1.16]

const THRESHOLDS: Dictionary = {
	"自然": [2, 4, 6],
	"火": [2, 4, 6],
	"雷": [2, 4, 6],
	"岩": [2, 4, 6],
	"植物": [2, 4, 6],
	"虫群": [2, 4, 6],
	"龙族": [2, 4, 6],
	"机械": [2, 4, 6],
	"亡灵": [2, 4, 6],
}

const EFFECT_VALUES: Dictionary = {
	"自然": [0.10, 0.20, 0.35],
	"火": [0.10, 0.20, 0.35],
	"雷": [0.10, 0.25, 0.40],
	"岩": [0.10, 0.16, 0.24],
	"植物": [0.08, 0.14, 0.22],
	"虫群": [0.12, 0.22, 0.35],
	"龙族": [0.15, 0.28, 0.45],
	"机械": [0.08, 0.16, 0.28],
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


static func traits_for_texture(texture_path: String) -> PackedStringArray:
	var index := CREATURE_FILES.find(texture_path.get_file())
	return PackedStringArray(CREATURE_TRAITS[index]) if index >= 0 else PackedStringArray()


static func attack_range_for_texture(texture_path: String) -> String:
	var index := CREATURE_FILES.find(texture_path.get_file())
	return CREATURE_ATTACK_RANGES[index] if index >= 0 else "melee"


static func combat_role_name(texture_path: String) -> String:
	return "远程" if attack_range_for_texture(texture_path) == "ranged" else "近战"


static func rarity_for_texture(texture_path: String) -> int:
	var index := CREATURE_FILES.find(texture_path.get_file())
	if index < 0:
		return 0
	return 0 if index < 8 else (1 if index < 12 else 2)


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
	for synergy in SYNERGY_ORDER:
		counts[synergy] = 0
	for texture_path in team:
		if texture_path.is_empty():
			continue
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
