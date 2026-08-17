class_name EquipmentCatalog
extends RefCounted

const RARITY_NAMES: Array[String] = ["普通", "稀有", "史诗"]

const EQUIPMENT: Array[Dictionary] = [
	{"id":"stoneplate", "name":"重岩胸甲", "path":"res://assets/items/shipin/icon1.png", "rarity":0, "stat":"health", "amount":0.15, "effect_type":"low_hp_shield", "effect_amount":0.20, "effect":"最大生命 +15%；首次低于50%生命时获得20%最大生命护盾。", "sources":["shop","elite","chest"]},
	{"id":"berserker_claw", "name":"狂战利爪", "path":"res://assets/items/shipin/icon2.png", "rarity":0, "stat":"damage", "amount":0.12, "effect_type":"missing_hp_damage", "effect_amount":0.02, "effect":"攻击力 +12%；每损失10%生命，普通攻击伤害提高2%，最多五层。", "sources":["shop","battle","elite"]},
	{"id":"gale_bow", "name":"疾风羽弓", "path":"res://assets/items/shipin/icon3.png", "rarity":0, "stat":"attack_speed", "amount":0.12, "effect_type":"third_hit_energy", "effect_amount":0.08, "effect":"攻击速度 +12%；每第三次普通攻击额外获得8%能量。", "sources":["shop","chest","event"]},
	{"id":"watcher_helm", "name":"守望头盔", "path":"res://assets/items/shipin/icon4.png", "rarity":0, "stat":"control_resist", "amount":0.20, "effect_type":"opening_reduction", "effect_amount":0.10, "effect":"控制抗性 +20%；开战前5秒受到的伤害降低10%。", "sources":["shop","chest","event"]},
	{"id":"starlight_tome", "name":"星辉法典", "path":"res://assets/items/shipin/icon5.png", "rarity":1, "stat":"skill_damage", "amount":0.15, "effect_type":"retain_energy", "effect_amount":0.10, "effect":"技能伤害 +15%；释放技能后保留10%能量。", "sources":["elite","chest","boss"]},
	{"id":"echo_orb", "name":"回响宝珠", "path":"res://assets/items/shipin/icon6.png", "rarity":1, "stat":"energy_gain", "amount":0.10, "effect_type":"first_cast_team_energy", "effect_amount":0.15, "effect":"普攻获得能量 +10%；首次释放技能时，为能量最低友军恢复15%能量。", "sources":["elite","chest","event"]},
	{"id":"thorn_bracer", "name":"荆棘护腕", "path":"res://assets/items/shipin/icon7.png", "rarity":1, "stat":"health", "amount":0.10, "effect_type":"basic_reflect", "effect_amount":0.20, "effect":"最大生命 +10%；受到普通攻击时，对攻击者造成自身攻击力20%的反伤。", "sources":["elite","chest","shop"]},
	{"id":"frost_pendant", "name":"冰霜吊坠", "path":"res://assets/items/shipin/icon8.png", "rarity":1, "stat":"dodge", "amount":0.06, "effect_type":"control_immunity", "effect_amount":0.12, "effect":"闪避率 +6%；第一次受到控制时免疫，并获得12%能量。", "sources":["elite","chest","boss"]},
	{"id":"ember_lamp", "name":"燃芯灯", "path":"res://assets/items/shipin/icon9.png", "rarity":1, "stat":"damage", "amount":0.08, "effect_type":"burn_target_damage", "effect_amount":0.20, "effect":"攻击力 +8%；对燃烧目标造成的伤害提高20%。", "sources":["elite","shop","boss"]},
	{"id":"forest_seed", "name":"森灵种子", "path":"res://assets/items/shipin/icon10.png", "rarity":2, "stat":"healing", "amount":0.18, "effect_type":"overheal_shield", "effect_amount":0.15, "effect":"治疗和护盾 +18%；过量治疗转为护盾，最多15%目标最大生命。", "sources":["boss","elite"]},
	{"id":"dragon_badge", "name":"龙骨徽章", "path":"res://assets/items/shipin/icon11.png", "rarity":2, "stat":"skill_damage", "amount":0.12, "effect_type":"skill_kill_energy", "effect_amount":0.25, "effect":"技能伤害 +12%；技能击败目标后立即获得25%能量。", "sources":["boss","elite"]},
	{"id":"revival_plume", "name":"复苏羽饰", "path":"res://assets/items/shipin/icon12.png", "rarity":2, "stat":"health", "amount":0.12, "effect_type":"revive", "effect_amount":0.25, "effect":"最大生命 +12%；首次死亡时以25%生命复活。", "sources":["boss","elite"]},
]


static func all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in EQUIPMENT:
		result.append(data(String(entry["id"])))
	return result


static func data(id: String) -> Dictionary:
	for entry in EQUIPMENT:
		if String(entry["id"]) == id:
			var result := entry.duplicate(true)
			result["kind"] = "equipment"
			result["price"] = [3, 5, 8][clampi(int(result["rarity"]), 0, 2)]
			result["sell_price"] = [1, 2, 4][clampi(int(result["rarity"]), 0, 2)]
			result["stack_limit"] = 99
			result["exclusive_group"] = ""
			return result
	return {}


static func normalize(value: Variant) -> Dictionary:
	if value is Dictionary:
		return data(String(value.get("id", "")))
	return data(String(value))


static func random_entry(rng: RandomNumberGenerator, rarity := -1, source := "any") -> Dictionary:
	var candidates: Array[Dictionary] = []
	for entry in EQUIPMENT:
		if rarity >= 0 and int(entry["rarity"]) != rarity:
			continue
		if source != "any" and source not in Array(entry["sources"]):
			continue
		candidates.append(entry)
	if candidates.is_empty():
		for entry in EQUIPMENT:
			if rarity < 0 or int(entry["rarity"]) == rarity:
				candidates.append(entry)
	if candidates.is_empty():
		candidates = EQUIPMENT.duplicate()
	return data(String(candidates[rng.randi_range(0, candidates.size() - 1)]["id"]))
