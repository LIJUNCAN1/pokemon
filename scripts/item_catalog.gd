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
const ITEM_DISPLAY_NAMES: Array[String] = [
	"旅行药壶", "冲锋手套", "风行羽", "未知糖果", "彩虹果实", "晶蓝药剂", "石臼药粉", "炽热浓汤",
	"幽光药粉", "森林药粉", "胜者奖杯", "火种辣椒", "赤铜短杖", "营地烛火", "旧驿烛火", "潮汐短杖",
	"旅行木杖", "硬壳果", "岩盐块", "赤晶矿", "远征卷轴", "火纹卷轴", "岩纹卷轴", "雷纹卷轴",
	"自然卷轴", "虫群卷轴", "龙纹卷轴", "古银代币", "翠晶代币", "破口钱袋", "韧皮护片", "轻灵羽",
	"烈焰羽", "浓缩药剂", "遗迹钥匙", "琥珀化石", "淬毒短刃", "火花短弓", "月光树果", "旅行肉派",
	"旧式提灯", "粉帽蘑菇", "星辉魔杖", "花蕾魔杖", "怪力树果", "赤晶方糖", "瓶装火种", "猎人短刀",
]
const ACCESSORY_DISPLAY_NAMES: Array[String] = [
	"钢铁面甲", "尖晶护符", "月白宝珠", "贤者宝珠", "旅行宝箱", "彩礼宝箱", "绿叶手册", "赤焰手册",
	"冠军徽杯", "赤铜宝箱", "幽紫宝箱", "岩甲胸铠", "迅行皮靴", "攀岩战靴", "轻羽便鞋", "守卫头盔",
	"古堡模型", "尖塔模型", "蓝顶巫帽", "翠风吊坠", "花冠吊坠", "碧叶圣杯", "森绿圣杯", "烈焰圣杯",
	"火纹圣杯", "潮汐圣杯", "古银钥匙", "石门钥匙", "塔楼钥匙", "遗迹钥匙", "赤铜钥匙", "熔岩钥匙",
	"龙骨钥匙", "火羽钥匙", "幽影钥匙", "机械钥匙", "雷光提灯", "琥珀提灯", "幽紫提灯", "翠光提灯",
	"王冠残片", "赤晶核心", "炎纹核心", "紫晶核心", "星火核心", "潮汐核心", "龙焰核心", "森绿核心",
]
const ITEM_EFFECT_TYPES: Array[String] = [
	"next_health", "next_damage", "next_charge", "next_all",
	"run_health", "run_damage", "coins", "restore_life",
]
const ACCESSORY_EFFECT_TYPES: Array[String] = [
	"health", "damage", "charge", "battle_gold", "interest_cap", "shop_discount",
]


static func rarity_for_id(id: int) -> int:
	var digit := posmod(id, 10)
	return 0 if digit < 6 else (1 if digit < 9 else 2)


static func entry_for_id(kind: String, id: int) -> Dictionary:
	return _make_accessory(id) if kind == "accessory" else _make_consumable(id)


static func random_entry(kind: String, rng: RandomNumberGenerator, rarity := -1, source := "any") -> Dictionary:
	var source_ids: Array[int] = ACCESSORY_IDS if kind == "accessory" else CONSUMABLE_IDS
	var candidates: Array[int] = []
	for id in source_ids:
		var entry := entry_for_id(kind, id)
		var source_matches := source == "any" or String(source) in Array(entry.get("sources", []))
		if (rarity < 0 or rarity_for_id(id) == rarity) and source_matches:
			candidates.append(id)
	if candidates.is_empty():
		for id in source_ids:
			if rarity < 0 or rarity_for_id(id) == rarity:
				candidates.append(id)
	if candidates.is_empty():
		candidates = source_ids.duplicate()
	return entry_for_id(kind, candidates[rng.randi_range(0, candidates.size() - 1)])


static func entry_from_path(path: String, kind_hint := "item") -> Dictionary:
	var basename := path.get_file().get_basename()
	var kind := "accessory" if basename.begins_with("accessory_") or kind_hint == "accessory" else "item"
	var id_text := basename.trim_prefix("accessory_").trim_prefix("item_").trim_prefix("fc")
	return entry_for_id(kind, maxi(id_text.to_int(), 1))


static func normalize_entry(value: Variant, kind_hint := "item") -> Dictionary:
	if value is Dictionary:
		var stored: Dictionary = value
		var stored_kind := String(stored.get("kind", kind_hint))
		var stored_id := int(stored.get("id", 0))
		if stored_id > 0:
			return entry_for_id(stored_kind, stored_id)
		return stored.duplicate(true)
	return entry_from_path(String(value), kind_hint)


static func _make_consumable(id: int) -> Dictionary:
	var rarity := rarity_for_id(id)
	var catalog_index := maxi(CONSUMABLE_IDS.find(id), 0)
	var effect_index := posmod(catalog_index, ITEM_EFFECT_TYPES.size())
	var name := ITEM_DISPLAY_NAMES[catalog_index]
	var amount := 0.0
	var effect_type := ITEM_EFFECT_TYPES[effect_index]
	var effect_text := ""
	match effect_type:
		"next_health":
			amount = [0.20, 0.28, 0.36][rarity]
			effect_text = "使用后，下场战斗全队最大生命 +%d%%" % roundi(amount * 100.0)
		"next_damage":
			amount = [0.15, 0.22, 0.30][rarity]
			effect_text = "使用后，下场战斗全队伤害 +%d%%" % roundi(amount * 100.0)
		"next_charge":
			amount = [0.15, 0.22, 0.30][rarity]
			effect_text = "使用后，下场战斗全队充能速度 +%d%%" % roundi(amount * 100.0)
		"next_all":
			amount = [0.08, 0.12, 0.16][rarity]
			effect_text = "使用后，下场战斗全队生命、伤害和充能速度 +%d%%" % roundi(amount * 100.0)
		"run_health":
			amount = [0.04, 0.06, 0.08][rarity]
			effect_text = "使用后，本轮远征全队最大生命永久 +%d%%" % roundi(amount * 100.0)
		"run_damage":
			amount = [0.03, 0.045, 0.06][rarity]
			effect_text = "使用后，本轮远征全队伤害永久 +%d%%" % roundi(amount * 100.0)
		"coins":
			amount = [3.0, 5.0, 8.0][rarity]
			effect_text = "使用后，立即获得 %d 金币" % roundi(amount)
		"restore_life":
			amount = 1.0
			effect_text = "使用后，恢复 1 点远征生命；生命已满时转化为 3 金币"
	return {
		"id": id,
		"kind": "item",
		"path": ITEM_ROOT + "item_%04d.png" % id,
		"name": name,
		"effect_type": effect_type,
		"amount": amount,
		"effect": effect_text,
		"rarity": rarity,
		"price": [2, 3, 5][rarity],
		"sell_price": [1, 1, 2][rarity],
		"stack_limit": [3, 2, 1][rarity],
		"exclusive_group": "",
		"sources": _drop_sources(rarity),
	}


static func _make_accessory(id: int) -> Dictionary:
	var rarity := rarity_for_id(id)
	var catalog_index := maxi(ACCESSORY_IDS.find(id), 0)
	var effect_index := posmod(catalog_index, ACCESSORY_EFFECT_TYPES.size())
	var name := ACCESSORY_DISPLAY_NAMES[catalog_index]
	var amounts := [0.04, 0.07, 0.10]
	var effect_type := ACCESSORY_EFFECT_TYPES[effect_index]
	var amount: float = amounts[rarity] if effect_index < 3 else 1.0
	var effect_text := ""
	match effect_type:
		"health": effect_text = "持有时，本轮远征全队最大生命 +%d%%" % roundi(amount * 100.0)
		"damage": effect_text = "持有时，本轮远征全队伤害 +%d%%" % roundi(amount * 100.0)
		"charge": effect_text = "持有时，本轮远征全队充能速度 +%d%%" % roundi(amount * 100.0)
		"battle_gold": effect_text = "每次战斗胜利额外获得 1 金币"
		"interest_cap": effect_text = "金币利息上限提高 1"
		"shop_discount": effect_text = "商店中价格高于 1 的商品便宜 1 金币"
	var exclusive_group := "" if effect_index < 3 else "economy_%s" % effect_type
	return {
		"id": id,
		"kind": "accessory",
		"path": ACCESSORY_ROOT + "accessory_%04d.png" % id,
		"name": name,
		"effect_type": effect_type,
		"amount": amount,
		"effect": effect_text,
		"rarity": rarity,
		"price": [3, 5, 7][rarity],
		"sell_price": [1, 2, 3][rarity],
		"stack_limit": 1 if not exclusive_group.is_empty() else [3, 2, 1][rarity],
		"exclusive_group": exclusive_group,
		"sources": _drop_sources(rarity),
	}


static func _drop_sources(rarity: int) -> Array[String]:
	match clampi(rarity, 0, 2):
		0: return ["shop", "event", "chest", "battle"]
		1: return ["shop", "event", "chest", "elite"]
		_: return ["shop", "chest", "elite", "boss"]
