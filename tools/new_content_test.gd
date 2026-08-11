extends Node

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const MAP_SCRIPT = preload("res://scripts/map.gd")
const BATTLE_SCRIPT = preload("res://scripts/battle.gd")

var failures: Array[String] = []


func _ready() -> void:
	_test_new_accessories()
	_test_chest_choices()
	_test_biomes_and_boss()
	_test_trainer_openings()
	if failures.is_empty():
		print("NEW_CONTENT_TEST: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("NEW_CONTENT_TEST: %s" % failure)
	get_tree().quit(1)


func _test_new_accessories() -> void:
	for id in range(9001, 9033):
		var entry := ITEM_CATALOG.entry_for_id("accessory", id)
		_check(String(entry.get("path", "")).contains("assets/items/shipin"), "饰品 %d 未使用新增图标" % id)
		_check(ResourceLoader.exists(String(entry.get("path", ""))), "饰品 %d 图标不存在" % id)
		_check(int(entry.get("rarity", -1)) in [0, 1, 2], "饰品 %d 品质无效" % id)


func _test_chest_choices() -> void:
	GameState.reset_run()
	GameState.map_seed = 314159
	GameState.map_initialized = true
	GameState.map_nodes = [{"id": 0, "type": "chest", "column": 2}]
	GameState.current_map_node = 0
	var map := MAP_SCRIPT.new()
	map.chest_event = true
	map.call("_prepare_event_rewards")
	_check(map.chest_choices.size() == 3, "宝箱没有生成三选一")
	var unique: Dictionary = {}
	for entry in map.chest_choices:
		unique["%s:%d" % [entry.get("kind", ""), int(entry.get("id", -1))]] = true
	_check(unique.size() == 3, "宝箱三选一出现重复奖励")
	map.free()


func _test_biomes_and_boss() -> void:
	GameState.map_initialized = true
	GameState.map_nodes = [{"id": 0, "type": "battle", "column": 2}]
	GameState.current_map_node = 0
	GameState.battle_victories = 2
	var battle := BATTLE_SCRIPT.new()
	GameState.region = 2
	_check(String(battle.call("_battle_biome")) == "snow", "区域 2 未切换雪地")
	GameState.region = 3
	_check(String(battle.call("_battle_biome")) == "cave", "区域 3 未切换矿洞")
	GameState.map_nodes[0]["type"] = "boss"
	_check(int(battle.call("_enemy_count_for_current_node")) == 1, "BOSS 节点仍生成多个普通敌人")
	battle.free()


func _test_trainer_openings() -> void:
	GameState.reset_run()
	GameState.apply_trainer_choice("researcher")
	_check(GameState.coins == GameState.STARTING_COINS + 2, "研究员初始金币未生效")
	GameState.reset_run()
	GameState.apply_trainer_choice("vanguard")
	_check(is_equal_approx(GameState.run_damage_bonus, 0.06), "先锋伤害被动未生效")
	GameState.reset_run()
	GameState.apply_trainer_choice("scout")
	_check(GameState.player_bench.size() == 1, "探索者初始怪兽未发放")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
