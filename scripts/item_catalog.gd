class_name ItemCatalog
extends RefCounted

const ITEM_ROOT := "res://assets/items/generated/item/"
const ACCESSORY_ROOT := "res://assets/items/generated/accessory/"
const RARITY_NAMES: Array[String] = ["普通", "稀有", "史诗"]
const CONSUMABLE_IDS: Array[int] = [
	1, 3, 7, 13, 14, 26, 49, 53, 57, 61, 67, 81,
	82, 83, 84, 87, 88, 93, 94, 96, 105, 109, 110, 111,
	112, 113, 114, 130, 167, 185, 204, 240, 259, 277, 296, 351,
	388, 406, 443, 480, 498, 535, 553, 572, 609, 682, 756, 811,
]
const ACCESSORY_IDS: Array[int] = [
	2, 4, 5, 6, 9, 10, 11, 12, 15, 25, 27, 28,
	33, 34, 35, 36, 37, 38, 62, 63, 64, 65, 66, 68,
	69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
	85, 86, 91, 92, 95, 97, 98, 99, 100, 101, 102, 103,
]
const NAME_PREFIXES: Array[String] = [
	"苔纹", "晨露", "赤铜", "月辉", "霜蓝", "琥珀",
	"星砂", "幽紫", "翠晶", "烈阳", "古银", "虹光",
]
const ITEM_NAMES: Array = [
	["活力药剂", "守护口粮", "岩肤药水"],
	["力量药剂", "锋刃油", "狂战果实"],
	["迅捷药剂", "清醒茶", "充能粉末"],
	["旅行钱袋", "旧代代币", "商会票据"],
]
const ACCESSORY_NAMES: Array = [
	["生命护符", "守御徽章", "古木指环"],
	["力量吊坠", "锋芒戒指", "赤晶勋章"],
	["迅捷核心", "充能耳饰", "风语挂坠"],
]


static func rarity_for_id(id: int) -> int:
	var digit := posmod(id, 10)
	return 0 if digit < 6 else (1 if digit < 9 else 2)


static func entry_for_id(kind: String, id: int) -> Dictionary:
	return _make_accessory(id) if kind == "accessory" else _make_consumable(id)


static func random_entry(kind: String, rng: RandomNumberGenerator, rarity := -1) -> Dictionary:
	var source: Array[int] = ACCESSORY_IDS if kind == "accessory" else CONSUMABLE_IDS
	var candidates: Array[int] = []
	for id in source:
		if rarity < 0 or rarity_for_id(id) == rarity:
			candidates.append(id)
	if candidates.is_empty():
		candidates = source.duplicate()
	return entry_for_id(kind, candidates[rng.randi_range(0, candidates.size() - 1)])


static func entry_from_path(path: String, kind_hint := "item") -> Dictionary:
	var basename := path.get_file().get_basename()
	var kind := "accessory" if basename.begins_with("accessory_") or kind_hint == "accessory" else "item"
	var id_text := basename.trim_prefix("accessory_").trim_prefix("item_").trim_prefix("fc")
	return entry_for_id(kind, maxi(id_text.to_int(), 1))


static func normalize_entry(value: Variant, kind_hint := "item") -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return entry_from_path(String(value), kind_hint)


static func _make_consumable(id: int) -> Dictionary:
	var rarity := rarity_for_id(id)
	var effect_index := posmod(id, 4)
	var name_options: Array = ITEM_NAMES[effect_index]
	var prefix := NAME_PREFIXES[posmod(floori(float(id) / 4.0), NAME_PREFIXES.size())]
	var name := "%s%s" % [prefix, name_options[posmod(floori(float(id) / 7.0), name_options.size())]]
	var amount := 0.0
	var effect_type := ""
	var effect_text := ""
	match effect_index:
		0:
			amount = [0.20, 0.28, 0.36][rarity]
			effect_type = "next_health"
			effect_text = "使用后，下场战斗全队最大生命 +%d%%" % roundi(amount * 100.0)
		1:
			amount = [0.15, 0.22, 0.30][rarity]
			effect_type = "next_damage"
			effect_text = "使用后，下场战斗全队伤害 +%d%%" % roundi(amount * 100.0)
		2:
			amount = [0.15, 0.22, 0.30][rarity]
			effect_type = "next_charge"
			effect_text = "使用后，下场战斗全队充能速度 +%d%%" % roundi(amount * 100.0)
		_:
			amount = [2.0, 3.0, 5.0][rarity]
			effect_type = "coins"
			effect_text = "使用后，立即获得 %d 金币" % roundi(amount)
	return {
		"id": id,
		"kind": "item",
		"path": ITEM_ROOT + "item_%04d.png" % id,
		"name": name,
		"effect_type": effect_type,
		"amount": amount,
		"effect": effect_text,
		"rarity": rarity,
		"price": [1, 2, 3][rarity],
	}


static func _make_accessory(id: int) -> Dictionary:
	var rarity := rarity_for_id(id)
	var effect_index := posmod(id, 3)
	var name_options: Array = ACCESSORY_NAMES[effect_index]
	var prefix := NAME_PREFIXES[posmod(floori(float(id) / 3.0), NAME_PREFIXES.size())]
	var name := "%s%s" % [prefix, name_options[posmod(floori(float(id) / 5.0), name_options.size())]]
	var amounts := [0.04, 0.07, 0.10]
	var amount: float = amounts[rarity]
	var attributes := ["health", "damage", "charge"]
	var labels := ["最大生命", "伤害", "充能速度"]
	return {
		"id": id,
		"kind": "accessory",
		"path": ACCESSORY_ROOT + "accessory_%04d.png" % id,
		"name": name,
		"effect_type": attributes[effect_index],
		"amount": amount,
		"effect": "持有时，本轮远征全队%s +%d%%" % [labels[effect_index], roundi(amount * 100.0)],
		"rarity": rarity,
		"price": [2, 3, 5][rarity],
	}
