extends Node

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURE_CATALOG = preload("res://scripts/creature_catalog.gd")
const ACHIEVEMENT_TROPHY := 1
const ACHIEVEMENT_MEDAL := 2
const ACHIEVEMENT_STAR := 4
const STARTING_COINS := 8
const BATTLE_BASE_GOLD := 5
const ELITE_BATTLE_BONUS := 2
const BOSS_BATTLE_BONUS := 5
const MAX_INTEREST_GOLD := 5
const EVENT_GOLD_SMALL := 3
const EVENT_GOLD_MEDIUM := 4
const EVENT_GOLD_LARGE := 5
const CHEST_GOLD_MIN := 4
const CHEST_GOLD_MAX := 6
const FIRST_BATTLE_CHEST_GOLD := 3
const CREATURE_BUY_PRICES: Array[int] = [1, 2, 3, 4, 5]
const CREATURE_STAR_COPIES: Array[int] = [1, 3, 9]
const CREATURE_SELL_RATE := 0.70
const SAVE_PATH := "user://run_save.cfg"
const MAX_FLOORS := 9
const FLOORS_PER_REGION := 3
const MAX_RUN_LIVES := 3
const CREATURE_POOL_COPIES: Array[int] = [10, 8, 6, 4, 2]

var coins := STARTING_COINS
var run_lives := 3
var floor := 1
var region := 1
var pending_life_loss_animation := false
var player_team: Array[String] = []
var player_bench: Array[String] = []
var player_team_levels: Array[int] = []
var player_bench_levels: Array[int] = []
var item_inventory: Array[Dictionary] = []
var accessory_inventory: Array[Dictionary] = []
var creature_shop_pool: Dictionary = {}
var seen_creatures: Dictionary = {}
var seen_items: Dictionary = {}
var seen_accessories: Dictionary = {}
var creature_achievements: Dictionary = {}
var unlocked_trainers: Dictionary = {}
var map_initialized := false
var map_intro_played := false
var map_seed := 0
var map_nodes: Array[Dictionary] = []
var map_edges: Dictionary = {}
var current_map_node := 0
var completed_map_nodes: Dictionary = {}
var run_health_bonus := 0.0
var run_damage_bonus := 0.0
var run_charge_bonus := 0.0
var next_battle_health_bonus := 0.0
var next_battle_damage_bonus := 0.0
var next_battle_charge_bonus := 0.0
var battle_victories := 0
var has_started_new_game := false
var trainer_id := ""
var tutorial_completed := false


func reset_run() -> void:
	coins = STARTING_COINS
	run_lives = 3
	floor = 1
	region = 1
	pending_life_loss_animation = false
	player_team.clear()
	player_bench.clear()
	player_team_levels.clear()
	player_bench_levels.clear()
	item_inventory.clear()
	accessory_inventory.clear()
	_reset_creature_shop_pool()
	map_initialized = false
	map_intro_played = false
	map_seed = 0
	map_nodes.clear()
	map_edges.clear()
	current_map_node = 0
	completed_map_nodes.clear()
	run_health_bonus = 0.0
	run_damage_bonus = 0.0
	run_charge_bonus = 0.0
	next_battle_health_bonus = 0.0
	next_battle_damage_bonus = 0.0
	next_battle_charge_bonus = 0.0
	battle_victories = 0
	trainer_id = ""


func apply_trainer_choice(choice: String) -> void:
	trainer_id = choice
	unlocked_trainers[choice] = true
	match trainer_id:
		"researcher":
			coins += 2
		"vanguard":
			run_damage_bonus += 0.06
		"scout":
			var starters := CREATURE_CATALOG.textures_for_rarity(0)
			if not starters.is_empty():
				var starter := starters[posmod(map_seed + 7, starters.size())]
				player_bench = [starter]
				player_bench_levels = [1]
				take_creature_from_pool(starter)
				mark_creature_seen(starter)


func has_unlocked_trainer(choice: String) -> bool:
	return bool(unlocked_trainers.get(choice, false))


func set_player_team(team: Array[String], levels: Array[int] = []) -> void:
	player_team = team.duplicate()
	player_team_levels = _normalized_creature_levels(player_team, levels)
	save_run()


func set_player_bench(bench: Array[String], levels: Array[int] = []) -> void:
	player_bench = bench.duplicate()
	player_bench_levels = _normalized_creature_levels(player_bench, levels)
	save_run()


func _normalized_creature_levels(creatures: Array[String], levels: Array[int]) -> Array[int]:
	var result: Array[int] = []
	for index in creatures.size():
		if creatures[index].is_empty():
			result.append(0)
		else:
			result.append(clampi(levels[index] if index < levels.size() else 1, 1, 3))
	return result


func add_item(value: Variant) -> Dictionary:
	var entry := ITEM_CATALOG.normalize_entry(value, "item")
	if not can_add_item(entry):
		return {}
	item_inventory.append(entry)
	mark_item_seen(entry)
	save_run()
	return entry


func add_accessory(value: Variant) -> Dictionary:
	var entry := ITEM_CATALOG.normalize_entry(value, "accessory")
	if not can_add_accessory(entry):
		return {}
	accessory_inventory.append(entry)
	mark_item_seen(entry)
	if String(entry["effect_type"]) in ["health", "damage", "charge"]:
		add_event_attribute(String(entry["effect_type"]), float(entry["amount"]))
	save_run()
	return entry


func can_add_item(value: Variant) -> bool:
	var entry := ITEM_CATALOG.normalize_entry(value, "item")
	return _inventory_entry_count(item_inventory, entry) < int(entry.get("stack_limit", 1))


func can_add_accessory(value: Variant) -> bool:
	var entry := ITEM_CATALOG.normalize_entry(value, "accessory")
	var group := String(entry.get("exclusive_group", ""))
	if not group.is_empty():
		for owned in accessory_inventory:
			if String(owned.get("exclusive_group", "")) == group:
				return false
	return _inventory_entry_count(accessory_inventory, entry) < int(entry.get("stack_limit", 1))


func _inventory_entry_count(inventory: Array[Dictionary], entry: Dictionary) -> int:
	var count := 0
	for owned in inventory:
		if int(owned.get("id", -1)) == int(entry.get("id", -2)):
			count += 1
	return count


func use_item(index: int) -> String:
	if index < 0 or index >= item_inventory.size():
		return "道具不存在"
	var entry: Dictionary = item_inventory[index]
	var amount := float(entry.get("amount", 0.0))
	match String(entry.get("effect_type", "")):
		"next_health": next_battle_health_bonus += amount
		"next_damage": next_battle_damage_bonus += amount
		"next_charge": next_battle_charge_bonus += amount
		"next_all":
			next_battle_health_bonus += amount
			next_battle_damage_bonus += amount
			next_battle_charge_bonus += amount
		"run_health": run_health_bonus += amount
		"run_damage": run_damage_bonus += amount
		"coins": add_coins(roundi(amount))
		"restore_life":
			if run_lives < MAX_RUN_LIVES:
				restore_run_life(roundi(amount))
			else:
				add_coins(3)
		_: return "该道具暂时无法使用"
	item_inventory.remove_at(index)
	save_run()
	return "%s已使用：%s" % [String(entry.get("name", "道具")), String(entry.get("effect", "效果已生效"))]


func take_next_battle_bonuses() -> Dictionary:
	var bonuses := {
		"health": next_battle_health_bonus,
		"damage": next_battle_damage_bonus,
		"charge": next_battle_charge_bonus,
	}
	next_battle_health_bonus = 0.0
	next_battle_damage_bonus = 0.0
	next_battle_charge_bonus = 0.0
	save_run()
	return bonuses


func add_event_attribute(attribute: String, amount: float) -> void:
	match attribute:
		"health": run_health_bonus += amount
		"damage": run_damage_bonus += amount
		"charge": run_charge_bonus += amount
	save_run()


func add_coins(amount: int) -> void:
	coins = maxi(coins + amount, 0)
	save_run()


func try_spend_coins(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	save_run()
	return true


func battle_gold_breakdown(node_type: String) -> Dictionary:
	var node_bonus := 0
	match node_type:
		"elite": node_bonus = ELITE_BATTLE_BONUS + floori(float(floor - 1) / FLOORS_PER_REGION)
		"boss": node_bonus = BOSS_BATTLE_BONUS + maxi(region - 1, 0)
	var scaled_base := BATTLE_BASE_GOLD + floori(float(floor - 1) / FLOORS_PER_REGION)
	var interest_cap := MAX_INTEREST_GOLD + roundi(accessory_effect_total("interest_cap"))
	var interest := mini(coins / 10, interest_cap)
	var accessory_gold := roundi(accessory_effect_total("battle_gold"))
	return {
		"base": scaled_base,
		"node_bonus": node_bonus,
		"interest": interest,
		"accessory_gold": accessory_gold,
		"total": scaled_base + node_bonus + interest + accessory_gold,
	}


func accessory_effect_total(effect_type: String) -> float:
	var total := 0.0
	for entry in accessory_inventory:
		if String(entry.get("effect_type", "")) == effect_type:
			total += float(entry.get("amount", 0.0))
	return total


func shop_price(base_price: int) -> int:
	var discount := roundi(accessory_effect_total("shop_discount"))
	return maxi(1, base_price - discount)


func floor_in_region() -> int:
	return 1 + (floor - 1) % FLOORS_PER_REGION


func is_region_boss_floor() -> bool:
	return floor_in_region() == FLOORS_PER_REGION


func scaled_event_gold(base_amount: int) -> int:
	return base_amount + floori(float(floor - 1) / 2.0)


func chest_gold_range() -> Vector2i:
	var floor_bonus := floori(float(floor - 1) / 2.0)
	return Vector2i(CHEST_GOLD_MIN + floor_bonus, CHEST_GOLD_MAX + floor_bonus)


func creature_sell_value(rarity: int, level: int) -> int:
	var safe_rarity := clampi(rarity, 0, CREATURE_BUY_PRICES.size() - 1)
	var safe_level := clampi(level, 1, CREATURE_STAR_COPIES.size())
	var invested := CREATURE_BUY_PRICES[safe_rarity] * CREATURE_STAR_COPIES[safe_level - 1]
	return maxi(1, floori(float(invested) * CREATURE_SELL_RATE))


func lose_run_life() -> int:
	if run_lives > 0:
		run_lives -= 1
		pending_life_loss_animation = true
	save_run()
	return run_lives


func restore_run_life(amount := 1) -> int:
	run_lives = mini(run_lives + maxi(amount, 0), MAX_RUN_LIVES)
	save_run()
	return run_lives


func _reset_creature_shop_pool() -> void:
	creature_shop_pool.clear()
	for texture_path in CREATURE_CATALOG.all_textures():
		var rarity := CREATURE_CATALOG.rarity_for_texture(texture_path)
		creature_shop_pool[texture_path] = CREATURE_POOL_COPIES[rarity]


func available_creatures_for_rarity(rarity: int) -> Array[String]:
	var result: Array[String] = []
	for texture_path in CREATURE_CATALOG.textures_for_rarity(rarity):
		if int(creature_shop_pool.get(texture_path, 0)) > 0:
			result.append(texture_path)
	return result


func take_creature_from_pool(texture_path: String, count := 1) -> bool:
	var available := int(creature_shop_pool.get(texture_path, 0))
	if count <= 0 or available < count:
		return false
	creature_shop_pool[texture_path] = available - count
	save_run()
	return true


func return_creature_to_pool(texture_path: String, count := 1) -> void:
	if texture_path.is_empty() or count <= 0:
		return
	var rarity := CREATURE_CATALOG.rarity_for_texture(texture_path)
	var maximum := CREATURE_POOL_COPIES[rarity]
	creature_shop_pool[texture_path] = mini(int(creature_shop_pool.get(texture_path, 0)) + count, maximum)
	save_run()


func add_creature_reward(texture_path: String) -> bool:
	if player_bench.size() < 4:
		player_bench.append(texture_path)
		player_bench_levels.append(1)
		return true
	for index in player_team.size():
		if player_team[index].is_empty():
			player_team[index] = texture_path
			while player_team_levels.size() <= index:
				player_team_levels.append(0)
			player_team_levels[index] = 1
			return true
	if player_team.size() < 6:
		player_team.append(texture_path)
		player_team_levels.append(1)
		return true
	return false


func set_map_data(seed_value: int, nodes: Array[Dictionary], edges: Dictionary) -> void:
	map_seed = seed_value
	map_nodes = nodes.duplicate(true)
	map_edges = edges.duplicate(true)
	current_map_node = 0
	completed_map_nodes = {}
	map_initialized = true
	map_intro_played = false
	save_run()


func set_current_map_node(node_id: int) -> void:
	current_map_node = node_id
	save_run()


func complete_current_map_node() -> void:
	completed_map_nodes[current_map_node] = true
	save_run()


func advance_floor() -> bool:
	if floor >= MAX_FLOORS:
		return false
	floor += 1
	region = 1 + floori(float(floor - 1) / FLOORS_PER_REGION)
	map_initialized = false
	map_intro_played = false
	map_seed = 0
	map_nodes.clear()
	map_edges.clear()
	current_map_node = 0
	completed_map_nodes.clear()
	save_run()
	return true


func is_final_floor() -> bool:
	return floor >= MAX_FLOORS


func is_map_node_completed(node_id: int) -> bool:
	return bool(completed_map_nodes.get(node_id, false))


func current_map_node_data() -> Dictionary:
	if current_map_node >= 0 and current_map_node < map_nodes.size():
		return map_nodes[current_map_node]
	return {}


func current_map_node_type() -> String:
	return String(current_map_node_data().get("type", ""))


func creature_key(texture_path: String) -> String:
	return texture_path


func mark_creature_seen(texture_path: String) -> void:
	if texture_path.is_empty():
		return
	seen_creatures[creature_key(texture_path)] = true
	save_run()


func has_seen_creature(texture_path: String) -> bool:
	return bool(seen_creatures.get(creature_key(texture_path), false))


func unlock_creature_achievement(texture_path: String, achievement: int) -> void:
	if texture_path.is_empty():
		return
	mark_creature_seen(texture_path)
	var key := creature_key(texture_path)
	creature_achievements[key] = int(creature_achievements.get(key, 0)) | achievement
	save_run()


func creature_achievement_mask(texture_path: String) -> int:
	return int(creature_achievements.get(creature_key(texture_path), 0))


func item_key(value: Variant, kind_hint := "item") -> String:
	var entry := ITEM_CATALOG.normalize_entry(value, kind_hint)
	return "%s:%d" % [String(entry.get("kind", kind_hint)), int(entry.get("id", 0))]


func mark_item_seen(value: Variant, kind_hint := "item") -> void:
	var entry := ITEM_CATALOG.normalize_entry(value, kind_hint)
	var collection := seen_accessories if String(entry.get("kind", kind_hint)) == "accessory" else seen_items
	collection[item_key(entry, kind_hint)] = true
	save_run()


func has_seen_item(value: Variant, kind_hint := "item") -> bool:
	var entry := ITEM_CATALOG.normalize_entry(value, kind_hint)
	var collection := seen_accessories if String(entry.get("kind", kind_hint)) == "accessory" else seen_items
	return bool(collection.get(item_key(entry, kind_hint), false))


func has_saved_run() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false
	return bool(config.get_value("run", "active", false))


func save_run() -> void:
	if not has_started_new_game:
		return
	var config := ConfigFile.new()
	config.set_value("run", "active", true)
	config.set_value("run", "coins", coins)
	config.set_value("run", "lives", run_lives)
	config.set_value("run", "floor", floor)
	config.set_value("run", "region", region)
	config.set_value("run", "team", player_team)
	config.set_value("run", "team_levels", player_team_levels)
	config.set_value("run", "bench", player_bench)
	config.set_value("run", "bench_levels", player_bench_levels)
	config.set_value("run", "items", item_inventory)
	config.set_value("run", "accessories", accessory_inventory)
	config.set_value("run", "creature_shop_pool", creature_shop_pool)
	config.set_value("run", "map_initialized", map_initialized)
	config.set_value("run", "map_intro_played", map_intro_played)
	config.set_value("run", "map_seed", map_seed)
	config.set_value("run", "map_nodes", map_nodes)
	config.set_value("run", "map_edges", map_edges)
	config.set_value("run", "current_map_node", current_map_node)
	config.set_value("run", "completed_map_nodes", completed_map_nodes)
	config.set_value("run", "health_bonus", run_health_bonus)
	config.set_value("run", "damage_bonus", run_damage_bonus)
	config.set_value("run", "charge_bonus", run_charge_bonus)
	config.set_value("run", "next_health_bonus", next_battle_health_bonus)
	config.set_value("run", "next_damage_bonus", next_battle_damage_bonus)
	config.set_value("run", "next_charge_bonus", next_battle_charge_bonus)
	config.set_value("run", "battle_victories", battle_victories)
	config.set_value("run", "trainer_id", trainer_id)
	config.set_value("meta", "seen_creatures", seen_creatures)
	config.set_value("meta", "seen_items", seen_items)
	config.set_value("meta", "seen_accessories", seen_accessories)
	config.set_value("meta", "creature_achievements", creature_achievements)
	config.set_value("meta", "tutorial_completed", tutorial_completed)
	config.set_value("meta", "unlocked_trainers", unlocked_trainers)
	config.save(SAVE_PATH)


func load_run() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK or not bool(config.get_value("run", "active", false)):
		return false
	coins = int(config.get_value("run", "coins", STARTING_COINS))
	run_lives = int(config.get_value("run", "lives", 3))
	floor = clampi(int(config.get_value("run", "floor", 1)), 1, MAX_FLOORS)
	region = maxi(int(config.get_value("run", "region", 1)), 1)
	player_team = _string_array(config.get_value("run", "team", []))
	player_team_levels = _int_array(config.get_value("run", "team_levels", []))
	player_bench = _string_array(config.get_value("run", "bench", []))
	player_bench_levels = _int_array(config.get_value("run", "bench_levels", []))
	item_inventory = _dictionary_array(config.get_value("run", "items", []))
	accessory_inventory = _dictionary_array(config.get_value("run", "accessories", []))
	creature_shop_pool = Dictionary(config.get_value("run", "creature_shop_pool", {}))
	if creature_shop_pool.is_empty():
		_reset_creature_shop_pool()
	map_initialized = bool(config.get_value("run", "map_initialized", false))
	map_intro_played = bool(config.get_value("run", "map_intro_played", false))
	map_seed = int(config.get_value("run", "map_seed", 0))
	map_nodes = _dictionary_array(config.get_value("run", "map_nodes", []))
	map_edges = Dictionary(config.get_value("run", "map_edges", {}))
	current_map_node = int(config.get_value("run", "current_map_node", 0))
	completed_map_nodes = Dictionary(config.get_value("run", "completed_map_nodes", {}))
	run_health_bonus = float(config.get_value("run", "health_bonus", 0.0))
	run_damage_bonus = float(config.get_value("run", "damage_bonus", 0.0))
	run_charge_bonus = float(config.get_value("run", "charge_bonus", 0.0))
	next_battle_health_bonus = float(config.get_value("run", "next_health_bonus", 0.0))
	next_battle_damage_bonus = float(config.get_value("run", "next_damage_bonus", 0.0))
	next_battle_charge_bonus = float(config.get_value("run", "next_charge_bonus", 0.0))
	battle_victories = int(config.get_value("run", "battle_victories", 0))
	trainer_id = String(config.get_value("run", "trainer_id", ""))
	seen_creatures = Dictionary(config.get_value("meta", "seen_creatures", {}))
	seen_items = Dictionary(config.get_value("meta", "seen_items", {}))
	seen_accessories = Dictionary(config.get_value("meta", "seen_accessories", {}))
	creature_achievements = Dictionary(config.get_value("meta", "creature_achievements", {}))
	tutorial_completed = bool(config.get_value("meta", "tutorial_completed", false))
	unlocked_trainers = Dictionary(config.get_value("meta", "unlocked_trainers", {}))
	if not trainer_id.is_empty():
		unlocked_trainers[trainer_id] = true
	has_started_new_game = true
	return true


func clear_run_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for entry in Array(value):
		result.append(String(entry))
	return result


func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	for entry in Array(value):
		result.append(int(entry))
	return result


func _dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in Array(value):
		result.append(Dictionary(entry))
	return result
