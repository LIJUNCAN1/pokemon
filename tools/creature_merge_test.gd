extends Node

const PREP_SCENE: PackedScene = preload("res://battle_prep.tscn")
const BATTLE_SCENE: PackedScene = preload("res://battle.tscn")
const TEST_CREATURE := "res://素材/宝可梦图/1 (1).png"
const FILLER_A := "res://素材/宝可梦图/1 (2).png"
const FILLER_B := "res://素材/宝可梦图/1 (3).png"


func _ready() -> void:
	GameState.reset_run()
	GameState.coins = 99
	GameState.set_player_bench(
		[TEST_CREATURE, TEST_CREATURE, FILLER_A, FILLER_B],
		[1, 1, 1, 1]
	)
	var prep := PREP_SCENE.instantiate()
	add_child(prep)
	await get_tree().process_frame
	await get_tree().process_frame

	prep.shop_data[0] = {
		"kind": "creature",
		"path": TEST_CREATURE,
		"rarity": 0,
		"price": 3,
	}
	prep._render_shop_card(0)
	prep._on_shop_card_pressed(0)
	await get_tree().process_frame

	var matching_slots: Array[int] = prep._matching_creature_slots(TEST_CREATURE, 2)
	_assert(matching_slots.size() == 1, "three 1-star copies should produce one 2-star copy")
	_assert(prep._matching_creature_slots(TEST_CREATURE, 1).is_empty(), "no 1-star copy should remain after merge")
	var merged_slot := matching_slots[0]
	_assert(prep.creature_hp_labels[merged_slot].text == "40", "2-star health display should be doubled")
	_assert(_visible_star_count(prep.creature_star_rows[merged_slot]) == 2, "2-star card should show two star icons")
	_assert(prep.shop_sold_out_overlays[0].visible, "purchased shop card should show sold-out art")
	_assert(is_equal_approx(prep.shop_sold_out_overlays[0].rotation, deg_to_rad(30.0)), "sold-out art should rotate 30 degrees")

	prep._save_current_team()
	_assert(GameState.player_bench_levels.has(2), "merged star level should persist in GameState")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://merge_shop_visual.png"))

	prep.queue_free()
	await get_tree().process_frame
	GameState.set_player_bench([], [])
	GameState.set_player_team([TEST_CREATURE], [2])
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	var player_fighter = null
	for fighter in battle.fighters:
		if fighter.player_side:
			player_fighter = fighter
			break
	_assert(player_fighter != null, "battle should create the merged player creature")
	_assert(player_fighter.level == 2, "battle should receive the saved star level")
	_assert(player_fighter.max_hp == 144, "2-star battle health should be doubled")
	_assert(is_equal_approx(player_fighter.damage_multiplier, 2.0), "2-star battle damage should be doubled")

	print("CREATURE_MERGE_TEST: PASS")
	get_tree().quit()


func _visible_star_count(row: Control) -> int:
	var count := 0
	for child in row.get_children():
		if child.visible:
			count += 1
	return count


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("CREATURE_MERGE_TEST: %s" % message)
	get_tree().quit(1)

