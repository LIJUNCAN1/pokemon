extends Node

const CATALOG = preload("res://scripts/creature_catalog.gd")
const MAP_SCENE: PackedScene = preload("res://map.tscn")
const PREP_SCENE: PackedScene = preload("res://battle_prep.tscn")
const BATTLE_SCENE: PackedScene = preload("res://battle.tscn")
const NEW_ROOT := "res://素材/图鉴/角色/"

var failures: Array[String] = []
var floor_one_edges: Dictionary = {}


func _ready() -> void:
	GameState.clear_run_save()
	GameState.has_started_new_game = true
	GameState.reset_run()
	_check(GameState.coins == 8, "新游戏必须从 8 金币开始")
	_check(GameState.player_team.is_empty() and GameState.player_bench.is_empty(), "新游戏阵容必须为空")
	_check(GameState.floor == 1 and GameState.region == 1, "新游戏必须从第 1 层、第 1 区域开始")
	_test_catalog()
	await _test_map_and_first_battle()
	await _test_save_and_floor_advance()
	GameState.has_started_new_game = false
	GameState.clear_run_save()
	if failures.is_empty():
		print("GAME_LOOP_TEST: PASS")
		get_tree().quit()
		return
	for failure in failures:
		push_error("GAME_LOOP_TEST: %s" % failure)
	get_tree().quit(1)


func _test_catalog() -> void:
	var textures := CATALOG.all_textures()
	_check(textures.size() == 34, "图鉴和卡池应包含 15 个原角色与 19 个新增角色")
	var unique_paths: Dictionary = {}
	var new_count := 0
	for texture_path in textures:
		unique_paths[texture_path] = true
		_check(ResourceLoader.exists(texture_path), "角色素材无法加载：%s" % texture_path)
		var elements := CATALOG.elements_for_texture(texture_path)
		var races := CATALOG.races_for_texture(texture_path)
		_check(not elements.is_empty(), "角色缺少元素标签：%s" % texture_path)
		_check(not races.is_empty(), "角色缺少种族标签：%s" % texture_path)
		_check(not CATALOG.skill_name_for_texture(texture_path).is_empty(), "角色缺少技能：%s" % texture_path)
		if texture_path.begins_with(NEW_ROOT):
			new_count += 1
	_check(unique_paths.size() == textures.size(), "角色卡池包含重复路径")
	_check(new_count == 19, "新增角色数量应为 19")
	var repeated_creature: String = textures[0]
	var repeated_traits := CATALOG.traits_for_texture(repeated_creature)
	var repeated_counts := CATALOG.count_synergies([repeated_creature, repeated_creature])
	for trait_name in repeated_traits:
		_check(int(repeated_counts.get(trait_name, 0)) == 1, "相同角色上阵多只时羁绊只能计算一次：%s" % trait_name)
	for rarity in 3:
		_check(not CATALOG.textures_for_rarity(rarity).is_empty(), "品质 %d 的卡池为空" % rarity)


func _test_map_and_first_battle() -> void:
	var map := MAP_SCENE.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(GameState.map_initialized and GameState.map_nodes.size() == 23, "地图必须生成 23 个节点")
	_check(GameState.current_map_node_type() == "start", "新游戏必须停留在起点")
	_check(String(GameState.map_nodes[22]["type"]) != "boss", "区域第 1 层不能生成区域 BOSS")
	floor_one_edges = GameState.map_edges.duplicate(true)
	map.queue_free()
	await get_tree().process_frame
	var prep := PREP_SCENE.instantiate()
	add_child(prep)
	await get_tree().process_frame
	_check(_tree_has_label(prep, "开始远征"), "起点备战按钮必须显示开始远征")
	_check(not _tree_has_label(prep, "第 1 天"), "备战界面不能保留旧天数文本")
	prep.call("_leave_start")
	_check(not GameState.is_map_node_completed(0), "空队伍不能离开起点")
	prep.queue_free()
	await get_tree().process_frame

	GameState.complete_current_map_node()
	GameState.set_current_map_node(1)
	var test_creature := NEW_ROOT + "1 (3).png"
	GameState.set_player_team([test_creature], [1])
	var coins_before := GameState.coins
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	battle.set_process(false)
	_check(battle.call("_is_first_battle_node"), "第一个实际战斗节点必须被识别为首战")
	var enemy_count := 0
	var player_count := 0
	for fighter in battle.fighters:
		if fighter.player_side:
			player_count += 1
		else:
			enemy_count += 1
	_check(player_count == 1, "战斗必须载入玩家队伍")
	_check(enemy_count == 1, "首战必须只有 1 名敌人")
	battle.call("_finish_battle", true)
	_check(GameState.battle_victories == 1, "首战胜利次数没有记录")
	_check(GameState.is_map_node_completed(1), "胜利后必须完成当前地图节点")
	_check(GameState.item_inventory.size() == 2, "首战宝箱必须发放 2 个不同道具")
	_check(GameState.coins == coins_before + GameState.BATTLE_BASE_GOLD + GameState.FIRST_BATTLE_CHEST_GOLD, "首战金币奖励不正确")
	battle.battle_music.stop()
	battle.battle_music.stream = null
	await get_tree().process_frame
	battle.queue_free()
	await get_tree().process_frame
	battle = null
	await get_tree().create_timer(0.1).timeout

	var loss_node: Dictionary = GameState.map_nodes[2]
	loss_node["type"] = "battle"
	GameState.map_nodes[2] = loss_node
	GameState.set_current_map_node(2)
	var lives_before_loss := GameState.run_lives
	var coins_before_loss := GameState.coins
	var loss_breakdown := GameState.battle_gold_breakdown("battle")
	var expected_loss_gold := int(loss_breakdown["base"]) + int(loss_breakdown["interest"])
	var lost_battle := BATTLE_SCENE.instantiate()
	add_child(lost_battle)
	await get_tree().process_frame
	lost_battle.set_process(false)
	lost_battle.call("_finish_battle", false)
	_check(GameState.run_lives == lives_before_loss - 1, "战败必须且只能扣除 1 颗心")
	_check(GameState.is_map_node_completed(2), "战败节点必须视为已通过")
	_check(GameState.coins == coins_before_loss + expected_loss_gold, "战败必须获得基础金币和利息")
	_check(not _tree_has_label(lost_battle, "重新战斗"), "地图战败后不能出现重新战斗")
	_check(_tree_has_label(lost_battle, "继续远征"), "仍有生命时战败必须能够继续地图")
	lost_battle.battle_music.stop()
	lost_battle.battle_music.stream = null
	lost_battle.queue_free()
	await get_tree().process_frame


func _test_save_and_floor_advance() -> void:
	GameState.save_run()
	var saved_coins := GameState.coins
	GameState.coins = 0
	_check(GameState.load_run(), "本地远征存档无法读取")
	_check(GameState.coins == saved_coins, "继续游戏没有恢复金币")
	_check(GameState.player_team.size() == 1, "继续游戏没有恢复队伍")
	_check(GameState.advance_floor(), "完成首层后无法进入下一层")
	_check(GameState.floor == 2 and GameState.region == 1, "第二层区域信息不正确")
	_check(not GameState.map_initialized, "进入下一层时旧地图没有清空")
	var floor_two_map := MAP_SCENE.instantiate()
	add_child(floor_two_map)
	await get_tree().process_frame
	_check(GameState.map_edges != floor_one_edges, "不同楼层必须生成不同的路线连接")
	_check(String(GameState.map_nodes[22]["type"]) != "boss", "区域第 2 层不能生成区域 BOSS")
	floor_two_map.queue_free()
	await get_tree().process_frame
	_check(GameState.advance_floor(), "无法进入区域 BOSS 层")
	var boss_floor_map := MAP_SCENE.instantiate()
	add_child(boss_floor_map)
	await get_tree().process_frame
	_check(GameState.floor == 3 and GameState.region == 1, "首个区域 BOSS 必须位于第 3 层")
	_check(String(GameState.map_nodes[22]["type"]) == "boss", "区域末层必须生成 BOSS")
	boss_floor_map.queue_free()
	await get_tree().process_frame
	_check(GameState.advance_floor(), "区域 BOSS 后无法进入下一区域")
	_check(GameState.floor == 4 and GameState.region == 2, "第 4 层必须进入区域 2")
	while GameState.floor < GameState.MAX_FLOORS:
		_check(GameState.advance_floor(), "多层远征在第 %d 层提前中断" % GameState.floor)
	_check(GameState.floor == 9 and GameState.region == 3 and GameState.is_final_floor(), "最终通关必须位于区域 3 第 9 层")
	_check(GameState.is_region_boss_floor(), "最终层必须是区域 BOSS 层")
	_check(not GameState.advance_floor(), "最终层之后不能继续生成楼层")
	var prep := PREP_SCENE.instantiate()
	add_child(prep)
	await get_tree().process_frame
	var late_chances: PackedFloat32Array = prep.call("_shop_rarity_chances")
	_check(late_chances[2] > 0.10 and late_chances[0] < 0.60, "商店品质概率必须随层数成长")
	prep.queue_free()
	await get_tree().process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _tree_has_label(root: Node, expected_text: String) -> bool:
	if root is Label and (root as Label).text == expected_text:
		return true
	if root is Button and (root as Button).text == expected_text:
		return true
	for child in root.get_children():
		if _tree_has_label(child, expected_text):
			return true
	return false
