class_name CreatureCatalog
extends RefCounted

const SYNERGY_ORDER: Array[String] = ["火焰", "水流", "自然", "猛兽", "虫群", "精神"]
const ELEMENTS: Array[String] = ["火焰", "水流", "自然"]
const RACES: Array[String] = ["猛兽", "虫群", "精神"]

const CREATURE_FILES: Array[String] = [
	"1 (1).png", "1 (2).png", "1 (3).png", "1 (4).png", "1 (5).png",
	"1 (6).png", "1 (7).png", "1 (8).png", "1 (9).png", "1 (10).png",
	"图层 2.png", "图层 3.png", "图层 4.png", "图层 5.png", "图层 6.png",
]

# Every creature owns exactly one element and one race.
const CREATURE_TRAITS: Array = [
	["自然", "猛兽"], ["水流", "猛兽"], ["火焰", "精神"], ["自然", "猛兽"],
	["火焰", "精神"], ["水流", "猛兽"], ["自然", "精神"], ["水流", "精神"],
	["自然", "猛兽"], ["火焰", "猛兽"], ["自然", "猛兽"], ["火焰", "虫群"],
	["水流", "精神"], ["自然", "虫群"], ["火焰", "虫群"],
]

const THRESHOLDS: Dictionary = {
	"火焰": [2, 4, 6],
	"水流": [2, 4, 6],
	"自然": [2, 4, 6],
	"猛兽": [2, 3, 5, 6],
	"虫群": [2, 3],
	"精神": [2, 3],
}

const EFFECT_VALUES: Dictionary = {
	"火焰": [0.10, 0.20, 0.35],
	"水流": [0.10, 0.25, 0.40],
	"自然": [0.10, 0.20, 0.35],
	"猛兽": [0.08, 0.12, 0.20, 0.30],
	"虫群": [0.15, 0.35],
	"精神": [0.08, 0.18],
}

const EFFECT_LINES: Dictionary = {
	"火焰": ["全队技能伤害 +10%", "全队技能伤害 +20%", "全队技能伤害 +35%"],
	"水流": ["水流角色充能速度 +10%", "水流角色充能速度 +25%", "水流角色充能速度 +40%"],
	"自然": ["全队最大生命 +10%", "全队最大生命 +20%", "全队最大生命 +35%"],
	"猛兽": ["猛兽角色受到伤害 -8%", "猛兽角色受到伤害 -12%", "猛兽角色受到伤害 -20%", "猛兽角色受到伤害 -30%"],
	"虫群": ["虫群角色充能速度 +15%", "虫群角色充能速度 +35%"],
	"精神": ["精神角色施放技能恢复 8% 生命", "精神角色施放技能恢复 18% 生命"],
}


static func traits_for_texture(texture_path: String) -> PackedStringArray:
	var index := CREATURE_FILES.find(texture_path.get_file())
	return PackedStringArray(CREATURE_TRAITS[index]) if index >= 0 else PackedStringArray()


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
