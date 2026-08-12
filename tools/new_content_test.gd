extends Node

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const MAP_SCRIPT = preload("res://scripts/map.gd")
const BATTLE_SCRIPT = preload("res://scripts/battle.gd")
const CREATURE_CATALOG = preload("res://scripts/creature_catalog.gd")
const DEX_SCRIPT = preload("res://scripts/dex_overlay.gd")

var failures: Array[String] = []


func _ready() -> void:
	_test_new_accessories()
	_test_creature_combat_rules()
	_test_synergy_extension_api()
	_test_collection_progress()
	_test_chest_choices()
	_test_conditional_events()
	_test_biomes_and_boss()
	_test_trainer_openings()
	await _test_visual_layout_contracts()
	if failures.is_empty():
		print("NEW_CONTENT_TEST: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("NEW_CONTENT_TEST: %s" % failure)
	get_tree().quit(1)


func _test_new_accessories() -> void:
	var effect_types: Dictionary = {}
	for id in range(9001, 9033):
		var entry := ITEM_CATALOG.entry_for_id("accessory", id)
		_check(String(entry.get("path", "")).contains("assets/items/shipin"), "饰品 %d 未使用新增图标" % id)
		_check(ResourceLoader.exists(String(entry.get("path", ""))), "饰品 %d 图标不存在" % id)
		_check(int(entry.get("rarity", -1)) in [0, 1, 2], "饰品 %d 品质无效" % id)
		_check(not String(entry.get("exclusive_group", "")).is_empty(), "饰品 %d 缺少互斥组" % id)
		_check(not Array(entry.get("sources", [])).is_empty(), "饰品 %d 缺少掉落来源" % id)
		effect_types[String(entry.get("effect_type", ""))] = true
	_check(effect_types.size() >= 12, "32 个饰品仍只复用少量效果")


func _test_creature_combat_rules() -> void:
	for texture_path in CREATURE_CATALOG.all_textures():
		_check(FileAccess.file_exists(texture_path), "角色源立绘不存在：%s" % texture_path)
		_check(CREATURE_CATALOG.target_rule_for_texture(texture_path) in ["front_row", "rear_chance", "lowest_hp"], "%s 目标规则无效" % texture_path)
		_check(not CREATURE_CATALOG.trigger_rule_for_texture(texture_path).is_empty(), "%s 缺少技能触发规则" % texture_path)
		var one_star := CREATURE_CATALOG.star_growth_for_texture(texture_path, 1)
		var three_star := CREATURE_CATALOG.star_growth_for_texture(texture_path, 3)
		_check(float(three_star.get("hp", 0.0)) > float(one_star.get("hp", 0.0)), "%s 升星生命没有成长" % texture_path)
		_check(float(three_star.get("damage", 0.0)) > float(one_star.get("damage", 0.0)), "%s 升星伤害没有成长" % texture_path)


func _test_synergy_extension_api() -> void:
	var synergy_ids: Array[String] = CREATURE_CATALOG.synergy_ids()
	for expected in ["水", "冰", "灵体", "守护", "野兽"]:
		_check(expected in synergy_ids, "新增羁绊没有注册：%s" % expected)
	for synergy in synergy_ids:
		_check(not CREATURE_CATALOG.synergy_thresholds(synergy).is_empty(), "羁绊缺少档位：%s" % synergy)
		_check(CREATURE_CATALOG.synergy_effect_lines(synergy).size() == CREATURE_CATALOG.synergy_thresholds(synergy).size(), "羁绊说明与档位数量不一致：%s" % synergy)
		_check(ResourceLoader.exists(CREATURE_CATALOG.synergy_icon_path(synergy)), "羁绊图标不存在：%s" % synergy)
	var available_ids: Array[String] = CREATURE_CATALOG.available_synergy_ids()
	_check(available_ids.is_empty(), "七个新羁绊启用后不应继续留在预留列表")
	for synergy in available_ids:
		_check(not CREATURE_CATALOG.synergy_icon_path(synergy).is_empty(), "预留羁绊图标路径为空：%s" % synergy)
		_check(ResourceLoader.exists(CREATURE_CATALOG.synergy_icon_path(synergy)), "预留羁绊图标不存在：%s" % synergy)
	var new_icon_paths: Dictionary = {}
	for synergy in synergy_ids + available_ids:
		var icon_path := CREATURE_CATALOG.synergy_icon_path(synergy)
		if icon_path.begins_with("res://assets/ui/trait_icons/new_set/"):
			new_icon_paths[icon_path] = true
	_check(new_icon_paths.size() == 18, "新羁绊图标应注册 18 个不重复资源")
	var expected_new_creatures := {
		"月痕灵狐": "月影", "星辉术师": "星辉", "赤拳斗士": "格斗", "苍羽狮鹫": "飞行",
		"幽焰亡灵": "亡灵", "翠风精灵": "风", "晶铠巨人": "晶石",
	}
	for creature_name in expected_new_creatures:
		var found_path := ""
		for candidate_path in CREATURE_CATALOG.all_textures():
			if CREATURE_CATALOG.name_for_texture(candidate_path) == creature_name:
				found_path = candidate_path
				break
		_check(not found_path.is_empty(), "新增角色没有注册：%s" % creature_name)
		if not found_path.is_empty():
			_check(FileAccess.file_exists(found_path), "新增角色立绘不存在：%s" % creature_name)
			_check(String(expected_new_creatures[creature_name]) in CREATURE_CATALOG.traits_for_texture(found_path), "新增角色属性不正确：%s" % creature_name)
	var texture_path := CREATURE_CATALOG.all_textures()[0]
	var creature_name := CREATURE_CATALOG.name_for_texture(texture_path)
	CREATURE_CATALOG.set_trait_override(creature_name, ["水", "守护"])
	_check(CREATURE_CATALOG.traits_for_texture(texture_path) == PackedStringArray(["水", "守护"]), "运行时标签修改接口未生效")
	CREATURE_CATALOG.clear_trait_override(creature_name)


func _test_collection_progress() -> void:
	GameState.reset_run()
	var texture_path := CREATURE_CATALOG.all_textures()[0]
	GameState.mark_creature_owned(texture_path, 2)
	GameState.mark_creature_defeated(texture_path)
	GameState.mark_creature_win(texture_path)
	var progress := GameState.creature_progress_for(texture_path)
	_check(bool(progress.get("seen", false)), "图鉴进度没有记录见过")
	_check(bool(progress.get("owned", false)), "图鉴进度没有记录拥有")
	_check(int(progress.get("max_star", 0)) == 2, "图鉴进度没有记录最高星级")
	_check(int(progress.get("defeated", 0)) == 1, "图鉴进度没有记录击败")
	_check(int(progress.get("wins", 0)) == 1, "图鉴进度没有记录参战胜场")


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


func _test_conditional_events() -> void:
	GameState.reset_run()
	GameState.coins = 10
	GameState.run_lives = 2
	var map := MAP_SCRIPT.new()
	map.event_story_id = 6
	map.event_stage_id = ""
	map.event_loot = ITEM_CATALOG.entry_for_id("accessory", 9001)
	var stage: Dictionary = map.call("_event_stage_data")
	_check(Array(stage.get("options", [])).size() == 3, "持有 10 金币时条件选项未出现")
	map.event_stage_id = "crystal_depth"
	stage = map.call("_event_stage_data")
	var has_risk := false
	for option in Array(stage.get("options", [])):
		has_risk = has_risk or String(option.get("kind", "")) == "risk_loot"
	_check(has_risk, "连续事件第二层缺少风险奖励")
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


func _test_visual_layout_contracts() -> void:
	var dex := DEX_SCRIPT.new()
	add_child(dex)
	await get_tree().process_frame
	dex.call("_on_tab_pressed", 3)
	await get_tree().process_frame
	_check(dex.monster_page.size.x > dex.monster_scroll.size.x + 100.0, "训练家图鉴没有形成可感知的横向浏览区域")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	dex.call("_input", wheel)
	_check(dex.monster_scroll.scroll_horizontal > 0, "训练家图鉴滚轮不能横向滚动")
	dex.queue_free()
	await get_tree().process_frame

	var battle := BATTLE_SCRIPT.new()
	var player := BATTLE_SCRIPT.Fighter.new()
	player.player_side = true
	player.sprite = TextureRect.new()
	player.sprite.position = Vector2(100, 100)
	player.sprite.size = Vector2(80, 80)
	var enemy := BATTLE_SCRIPT.Fighter.new()
	enemy.player_side = false
	enemy.sprite = TextureRect.new()
	enemy.sprite.position = Vector2(700, 100)
	enemy.sprite.size = Vector2(80, 80)
	_check(battle.call("_fighter_attack_origin", player).x > battle.call("_fighter_visual_center", player).x, "我方攻击特效没有从角色右侧发出")
	_check(battle.call("_fighter_attack_origin", enemy).x < battle.call("_fighter_visual_center", enemy).x, "敌方攻击特效没有从角色左侧发出")
	player.sprite.free()
	enemy.sprite.free()
	battle.free()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
