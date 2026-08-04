extends Node

const ACHIEVEMENT_TROPHY := 1
const ACHIEVEMENT_MEDAL := 2
const ACHIEVEMENT_STAR := 4

var day := 1
var progress := 1
var coins := 8
var player_team: Array[String] = []
var player_bench: Array[String] = []
var item_inventory: Array[String] = []
var seen_creatures: Dictionary = {}
var creature_achievements: Dictionary = {}
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
var battle_victories := 0


func reset_run() -> void:
	day = 1
	progress = 1
	coins = 8
	player_team.clear()
	player_bench.clear()
	item_inventory.clear()
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
	battle_victories = 0


func set_player_team(team: Array[String]) -> void:
	player_team = team.duplicate()


func set_player_bench(bench: Array[String]) -> void:
	player_bench = bench.duplicate()


func add_item(texture_path: String) -> void:
	if not texture_path.is_empty():
		item_inventory.append(texture_path)


func add_event_attribute(attribute: String, amount: float) -> void:
	match attribute:
		"health": run_health_bonus += amount
		"damage": run_damage_bonus += amount
		"charge": run_charge_bonus += amount


func add_creature_reward(texture_path: String) -> bool:
	if player_bench.size() < 4:
		player_bench.append(texture_path)
		return true
	for index in player_team.size():
		if player_team[index].is_empty():
			player_team[index] = texture_path
			return true
	if player_team.size() < 6:
		player_team.append(texture_path)
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


func set_current_map_node(node_id: int) -> void:
	current_map_node = node_id


func complete_current_map_node() -> void:
	completed_map_nodes[current_map_node] = true


func is_map_node_completed(node_id: int) -> bool:
	return bool(completed_map_nodes.get(node_id, false))


func current_map_node_data() -> Dictionary:
	if current_map_node >= 0 and current_map_node < map_nodes.size():
		return map_nodes[current_map_node]
	return {}


func current_map_node_type() -> String:
	return String(current_map_node_data().get("type", ""))


func creature_key(texture_path: String) -> String:
	return texture_path.get_file()


func mark_creature_seen(texture_path: String) -> void:
	if texture_path.is_empty():
		return
	seen_creatures[creature_key(texture_path)] = true


func has_seen_creature(texture_path: String) -> bool:
	return bool(seen_creatures.get(creature_key(texture_path), false))


func unlock_creature_achievement(texture_path: String, achievement: int) -> void:
	if texture_path.is_empty():
		return
	mark_creature_seen(texture_path)
	var key := creature_key(texture_path)
	creature_achievements[key] = int(creature_achievements.get(key, 0)) | achievement


func creature_achievement_mask(texture_path: String) -> int:
	return int(creature_achievements.get(creature_key(texture_path), 0))
