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
	_check(GameState.coins == 12, "新游戏必须从 12 金币开始")
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
	_check(textures.size() == 41, "图鉴和卡池应包含 15 个原角色与 26 个新增角色")
	var unique_paths: Dictionary = {}
	var unique_skill_ids: Dictionary = {}
	var unique_skill_names: Dictionary = {}
	var unique_skill_texts: Dictionary = {}
	var unique_skill_signatures: Dictionary = {}
	var new_count := 0
	for texture_path in textures:
		unique_paths[texture_path] = true
		_check(ResourceLoader.exists(texture_path), "角色素材无法加载：%s" % texture_path)
		var elements := CATALOG.elements_for_texture(texture_path)
		var races := CATALOG.races_for_texture(texture_path)
		_check(not elements.is_empty(), "角色缺少元素标签：%s" % texture_path)
		_check(not races.is_empty(), "角色缺少种族标签：%s" % texture_path)
		_check(not CATALOG.skill_name_for_texture(texture_path).is_empty(), "角色缺少技能：%s" % texture_path)
		var skill_id := CATALOG.skill_id_for_texture(texture_path)
		var skill_name := CATALOG.skill_name_for_texture(texture_path)
		var skill_text := CATALOG.skill_text_for_texture(texture_path)
		var skill_effects := CATALOG.skill_effects_for_texture(texture_path)
		var skill_signature := JSON.stringify(skill_effects)
		_check(not unique_skill_ids.has(skill_id), "角色技能 ID 重复：%s" % skill_id)
		_check(not unique_skill_names.has(skill_name), "角色技能名称重复：%s" % skill_name)
		_check(not unique_skill_texts.has(skill_text), "角色技能说明重复：%s" % skill_text)
		_check(not unique_skill_signatures.has(skill_signature), "角色技能效果组合重复：%s" % skill_name)
		unique_skill_ids[skill_id] = texture_path
		unique_skill_names[skill_name] = texture_path
		unique_skill_texts[skill_text] = texture_path
		unique_skill_signatures[skill_signature] = texture_path
		_check(not skill_effects.is_empty(), "角色技能缺少实战效果：%s" % skill_name)
		var energy_per_attack := CATALOG.energy_per_attack_for_texture(texture_path)
		_check(energy_per_attack > 0.0 and energy_per_attack <= 1.0, "角色普攻能量值非法：%s" % skill_name)
		_check(CATALOG.trigger_rule_for_texture(texture_path) == "on_full_charge", "角色技能必须在满能量时自动释放：%s" % skill_name)
		if texture_path.begins_with(NEW_ROOT):
			new_count += 1
	_check(unique_paths.size() == textures.size(), "角色卡池包含重复路径")
	_check(new_count == 19, "新增角色数量应为 19")
	var repeated_creature: String = textures[0]
	var repeated_traits := CATALOG.traits_for_texture(repeated_creature)
	var repeated_counts := CATALOG.count_synergies([repeated_creature, repeated_creature])
	for trait_name in repeated_traits:
		_check(int(repeated_counts.get(trait_name, 0)) == 1, "相同角色上阵多只时羁绊只能计算一次：%s" % trait_name)
	for rarity in CATALOG.RARITY_NAMES.size():
		_check(not CATALOG.textures_for_rarity(rarity).is_empty(), "品质 %d 的卡池为空" % rarity)
	var growth_one := CATALOG.star_growth(1)
	var growth_three := CATALOG.star_growth(3)
	_check(float(growth_three["hp"]) > float(growth_one["hp"]), "三星生命成长必须高于一星")
	_check(float(growth_three["damage"]) > float(growth_one["damage"]), "三星伤害成长必须高于一星")


func _test_map_and_first_battle() -> void:
	var map := MAP_SCENE.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(GameState.map_initialized and GameState.map_nodes.size() == 23, "地图必须生成 23 个节点")
	_check(GameState.current_map_node_type() == "chest", "新游戏必须停留在宝箱关")
	_check(bool(GameState.current_map_node_data().get("mimic", false)), "首节点必须固定为宝箱怪战斗")
	_check(bool(GameState.current_map_node_data().get("opening", false)), "首节点必须带有开局奖励标记")
	_check(map._route_edges_are_ordered(GameState.map_edges), "相邻地图列之间的路线不能交叉打结")
	for illustration_path in map.EVENT_STORY_ILLUSTRATIONS + [map.EVENT_CHEST_ILLUSTRATION]:
		_check(ResourceLoader.exists(illustration_path), "事件占位插画无法加载：%s" % illustration_path)
	map.chest_event = false
	map.rest_event = false
	map._prepare_event_rewards()
	for story_id in map.EVENT_STORY_ILLUSTRATIONS.size():
		map.event_story_id = story_id
		map.event_stage_id = "root"
		var story_data: Dictionary = map._event_stage_data()
		_check(Array(story_data.get("options", [])).size() == 3, "每个随机事件根节点必须提供三个路线选择：%d" % story_id)
	map.rest_event = true
	map.event_stage_id = "root"
	var rest_data: Dictionary = map._event_stage_data()
	_check(Array(rest_data.get("options", [])).size() == 3, "休息节点必须提供恢复、训练和补给三种选择")
	map.rest_event = false
	GameState.coins = 10
	map.event_story_id = 6
	map.event_stage_id = "root"
	var conditional_event: Dictionary = map._event_stage_data()
	_check(Array(conditional_event.get("options", [])).size() == 3, "条件事件必须保留三个选择")
	map.event_stage_id = "crystal_depth"
	var risk_event: Dictionary = map._event_stage_data()
	_check(Array(risk_event.get("options", [])).any(func(option): return String(option.get("kind", "")) == "risk_loot"), "连续事件必须包含风险回报")
	GameState.coins = GameState.STARTING_COINS
	for _iteration in 100:
		_check(map._route_edges_are_ordered(map._generate_route_edges()), "随机路线模板不能生成交叉连线")
	_check(String(GameState.map_nodes[22]["type"]) != "boss", "区域第 1 层不能生成区域 BOSS")
	var generated_types: Dictionary = {}
	for node in GameState.map_nodes:
		generated_types[String(node["type"])] = true
	for required_type in ["event", "chest", "shop", "rest", "battle"]:
		_check(generated_types.has(required_type), "随机地图必须包含%s节点" % required_type)
	floor_one_edges = GameState.map_edges.duplicate(true)
	map.queue_free()
	await get_tree().process_frame
	var prep := PREP_SCENE.instantiate()
	add_child(prep)
	await get_tree().process_frame
	_check(_tree_has_label(prep, "挑战宝箱怪"), "开局备战按钮必须显示挑战宝箱怪")
	_check(not _tree_has_label(prep, "第 1 天"), "备战界面不能保留旧天数文本")
	_check(not _tree_has_nonempty_tooltip(prep), "备战界面不能保留系统悬停介绍框")
	prep.queue_free()
	await get_tree().process_frame

	var test_creature := NEW_ROOT + "1 (3).png"
	GameState.set_player_team([test_creature], [1])
	var coins_before := GameState.coins
	var opening_gold := GameState.battle_gold_breakdown("chest")
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	battle.set_process(false)
	_check(battle.call("_is_first_battle_node"), "第一个实际战斗节点必须被识别为首战")
	var enemy_count := 0
	var player_count := 0
	var inspected_enemy = null
	for fighter in battle.fighters:
		if fighter.player_side:
			player_count += 1
		else:
			enemy_count += 1
			inspected_enemy = fighter
	_check(player_count == 1, "战斗必须载入玩家队伍")
	_check(enemy_count == 1, "宝箱怪战斗必须只有 1 名敌人")
	for fighter in battle.fighters:
		if not fighter.player_side:
			_check(not fighter.can_attack, "宝箱怪不能获得充能或发动攻击")
			_check(fighter.texture_path.ends_with("宝箱怪.png") and fighter.sprite.scale.x > 0.0, "宝箱怪应保持素材原始朝向，面向我方")
	battle.call("_show_fighter_info", inspected_enemy)
	_check(battle.fighter_info_panel.visible, "战斗角色必须支持右键固定详情面板")
	_check(battle.fighter_info_name.text == "宝箱怪", "战斗详情面板必须显示当前角色资料")
	battle.call("_hide_fighter_info")
	battle.call("_show_status_info", "减速 0.3s")
	_check(is_instance_valid(battle.status_info_panel), "右键状态图标必须打开固定详情面板")
	battle.call("_hide_status_info")
	_check(not is_instance_valid(battle.status_info_panel), "状态详情必须可以通过空白区域关闭")
	battle.call("_finish_battle", true)
	_check(GameState.battle_victories == 1, "首战胜利次数没有记录")
	_check(GameState.is_map_node_completed(0), "胜利后必须完成开局宝箱节点")
	_check(GameState.item_inventory.size() == 2, "首战宝箱必须发放 2 个不同道具")
	_check(GameState.coins == coins_before + int(opening_gold["total"]) + GameState.FIRST_BATTLE_CHEST_GOLD, "首战金币奖励不正确")
	var result_coin := battle.get_node_or_null("ResultCoinIcon") as TextureRect
	_check(result_coin != null and result_coin.texture == battle.RESULT_COIN_ICON, "战斗结算金币必须使用素材 icon")
	var gold_text := battle.get_node_or_null("ResultGoldText") as Label
	_check(gold_text != null and not gold_text.text.contains("战斗金币") and not gold_text.text.contains("金币"), "金币明细不能重复写金币文字")
	var reward_sources := battle.get_node_or_null("ResultRewardSources") as Label
	_check(reward_sources != null and reward_sources.text == "宝箱奖励", "宝箱奖励标题必须和其他奖励来源使用同一行")
	var reward_cards: Array[Control] = []
	for child in battle.get_children():
		if child is Control and String(child.name).begins_with("ResultItemCard"):
			reward_cards.append(child)
	_check(reward_cards.size() == 2, "首战宝箱必须显示两张道具奖励卡")
	if reward_cards.size() == 2:
		var cards_center := (reward_cards[0].position.x + reward_cards[1].position.x + reward_cards[1].size.x) * 0.5
		_check(is_equal_approx(cards_center, battle.DESIGN_SIZE.x * 0.5), "道具奖励卡组必须作为整体水平居中")
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
	var pool_creature: String = CATALOG.all_textures()[0]
	var pool_stock_before := int(GameState.creature_shop_pool.get(pool_creature, 0))
	_check(pool_stock_before > 0, "共享角色池测试角色必须有库存")
	_check(GameState.take_creature_from_pool(pool_creature), "共享角色池无法扣除角色")
	var saved_pool_stock := pool_stock_before - 1
	GameState.save_run()
	var saved_coins := GameState.coins
	GameState.coins = 0
	GameState.creature_shop_pool[pool_creature] = 0
	_check(GameState.load_run(), "本地远征存档无法读取")
	_check(GameState.coins == saved_coins, "继续游戏没有恢复金币")
	_check(GameState.player_team.size() == 1, "继续游戏没有恢复队伍")
	_check(int(GameState.creature_shop_pool.get(pool_creature, 0)) == saved_pool_stock, "继续游戏没有恢复共享角色池库存")
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


func _tree_has_nonempty_tooltip(root: Node) -> bool:
	if root is Control and not (root as Control).tooltip_text.is_empty():
		return true
	for child in root.get_children():
		if _tree_has_nonempty_tooltip(child):
			return true
	return false
