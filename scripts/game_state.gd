extends Node

const ACHIEVEMENT_TROPHY := 1
const ACHIEVEMENT_MEDAL := 2
const ACHIEVEMENT_STAR := 4

var day := 1
var progress := 1
var player_team: Array[String] = []
var item_inventory: Array[String] = []
var seen_creatures: Dictionary = {}
var creature_achievements: Dictionary = {}


func reset_run() -> void:
	day = 1
	progress = 1
	player_team.clear()
	item_inventory.clear()


func set_player_team(team: Array[String]) -> void:
	player_team = team.duplicate()


func add_item(texture_path: String) -> void:
	if not texture_path.is_empty():
		item_inventory.append(texture_path)


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
