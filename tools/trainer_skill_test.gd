extends Node

const CATALOG = preload("res://scripts/creature_catalog.gd")
const TRAINERS = preload("res://scripts/trainer_catalog.gd")

var failures: Array[String] = []


func _ready() -> void:
	GameState.clear_run_save()
	GameState.reset_run()
	_check(TRAINERS.all().size() == 3, "训练家目录必须包含三名训练家")
	_test_researcher()
	_test_vanguard()
	_test_scout()
	GameState.reset_run()
	GameState.clear_run_save()
	if failures.is_empty():
		print("TRAINER_SKILL_TEST: PASS")
		get_tree().quit()
		return
	for failure in failures:
		push_error("TRAINER_SKILL_TEST: %s" % failure)
	get_tree().quit(1)


func _test_researcher() -> void:
	GameState.reset_run()
	GameState.apply_trainer_choice("researcher")
	GameState.begin_preparation()
	var chosen: Array[String] = []
	var elements: Array[String] = []
	for texture_path in CATALOG.all_textures():
		var creature_elements := CATALOG.elements_for_texture(texture_path)
		if creature_elements.is_empty() or String(creature_elements[0]) in elements:
			continue
		chosen.append(texture_path)
		elements.append(String(creature_elements[0]))
		if chosen.size() == 2:
			break
	var starting_coins := GameState.coins
	_check(GameState.record_trainer_creature_purchase(chosen[0]) == 0, "第一个不同元素不应立即发放奖励")
	_check(GameState.record_trainer_creature_purchase(chosen[1]) == 1, "第二个不同元素应触发生态研究")
	_check(GameState.coins == starting_coins + 1, "生态研究应增加 1 金币")
	_check(GameState.record_trainer_creature_purchase(chosen[1]) == 0, "重复元素不得重复计数")


func _test_vanguard() -> void:
	GameState.reset_run()
	GameState.apply_trainer_choice("vanguard")
	GameState.begin_preparation()
	var starting_coins := GameState.coins
	var result := GameState.activate_trainer_skill()
	_check(bool(result.get("ok", false)), "战斗号令应能在金币充足时激活")
	_check(GameState.coins == starting_coins - 2, "战斗号令应消耗 2 金币")
	_check(not bool(GameState.activate_trainer_skill().get("ok", true)), "主动技能每个备战阶段只能使用一次")
	var effect := GameState.take_trainer_battle_effect()
	_check(is_equal_approx(float(effect.get("attack_bonus", 0.0)), 0.15), "战斗号令攻击力加成错误")
	_check(is_equal_approx(float(effect.get("duration", 0.0)), 8.0), "战斗号令持续时间错误")
	_check(GameState.take_trainer_battle_effect().is_empty(), "战斗号令只能在下一场战斗生效一次")


func _test_scout() -> void:
	GameState.reset_run()
	GameState.apply_trainer_choice("scout")
	GameState.begin_preparation()
	_check(GameState.consume_scout_free_refresh(), "遗迹勘探的首次刷新应免费")
	_check(not GameState.consume_scout_free_refresh(), "同一备战阶段不能重复免费刷新")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
